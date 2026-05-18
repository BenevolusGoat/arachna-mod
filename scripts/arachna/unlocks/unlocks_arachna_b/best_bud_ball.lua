--#region Variables

local Mod = ArachnaMod

local BEST_BUD_BALL = {}

ArachnaMod.Item.BEST_BUD_BALL = BEST_BUD_BALL

BEST_BUD_BALL.ID = Isaac.GetItemIdByName("Best Bud Ball")
BEST_BUD_BALL.EFFECT = Isaac.GetEntityVariantByName("Best Bud Ball")

BEST_BUD_BALL.SFX = {
	RAISE = Isaac.GetSoundIdByName("Best Bud Ball (Raise)"),
	THROW = Isaac.GetSoundIdByName("Best Bud Ball (Throw)"),
	LAND = Isaac.GetSoundIdByName("Best Bud Ball (Land)"),
	PICKUP = Isaac.GetSoundIdByName("Best Bud Ball (Pickup)"),
	CAPTURE = Isaac.GetSoundIdByName("Best Bud Ball (Capture)"),
	RELEASE = Isaac.GetSoundIdByName("Best Bud Ball (Release)")
}

BEST_BUD_BALL.BLACKLISTED_BOSSES = Mod:Set({
	EntityType.ENTITY_MOM,
	EntityType.ENTITY_MOMS_HEART,
	EntityType.ENTITY_ISAAC, --+Blue Baby
	EntityType.ENTITY_SATAN,
	EntityType.ENTITY_THE_LAMB,
	EntityType.ENTITY_DELIRIUM,
	EntityType.ENTITY_ULTRA_GREED, --+Ultra Greedier
	EntityType.ENTITY_MOTHER,
	EntityType.ENTITY_DOGMA,
	EntityType.ENTITY_BEAST, --+Ultra Horsemen
	EntityType.ENTITY_MASK_OF_INFAMY --Temporary until I feel like making a patch
})

---@class BestBudBallData
---@field Type EntityType
---@field Variant integer
---@field Subtype integer
---@field MaxHitPoints integer
---@field HitPoints integer

ThrowableItemLib:RegisterThrowableItem({
	Type = ThrowableItemLib.Type.ACTIVE,
	ID = BEST_BUD_BALL.ID,
	Identifier = "Best Bud Ball",
	ThrowFn = function(player, vect, slot, mimic)
		BEST_BUD_BALL:FireBall(player.Position, Mod:AddTearVelocity(vect, 15, player), player)
		Mod.sfxman:Play(BEST_BUD_BALL.SFX.THROW, 1, 2, false, 0.8)
	end,
	LiftFn = function(player, continued, slot, mimic)
		Mod.sfxman:Play(BEST_BUD_BALL.SFX.RAISE, 1, 2, false, 0.8)
	end
})

--#endregion

--#region Helpers

---@param pos Vector
---@param vel Vector
---@param spawner? Entity
function BEST_BUD_BALL:FireBall(pos, vel, spawner)
	local ball = Mod.Spawn.Effect(BEST_BUD_BALL.EFFECT, 0, pos, vel, spawner)
	ball.PositionOffset = Vector(0, -60)
	ball.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
	ball.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
	local player = spawner and spawner:ToPlayer()
	if player then
		local run_save = Mod.SaveManager.GetRunSave(player)
		if run_save.BestBudBallNPCs then
			Mod:GetData(ball).ReleaseNpcCfgs = Mod:CopyTable(run_save.BestBudBallNPCs)
			run_save.BestBudBallNPCs = nil
		end
	end
end

---@param ent Entity
---@param allowFriendly? boolean
function BEST_BUD_BALL:CanCaptureMonster(ent, allowFriendly)
	local defaultCheck = ent:IsBoss()
		and not ent:ToDelirium()
		and not BEST_BUD_BALL.BLACKLISTED_BOSSES[ent.Type]
		and not ent:GetEntityConfigEntity():HasEntityTags(EntityTag.NODELIRIUM)
		and not ent:IsInvincible()
		and ent:IsActiveEnemy(false)
		and (allowFriendly or not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY))
	if defaultCheck then
		local result = Isaac.RunCallbackWithParam(Mod.ModCallbacks.CAN_CAPTURE_BOSS, ent.Type, ent)
		if result == false then
			return result
		end
	end
	return defaultCheck
end

---Returns the entire enemy in order
---@param npc EntityNPC
function BEST_BUD_BALL:GetEntireMonster(npc)
	local parent = StatusEffectLibrary.Utils.GetLastParent(npc)
	Mod:GetData(parent).BestBudBallCaptured = true
	if not parent.Child then
		return {EntityPtr(parent)}
	end
	local monsters = {EntityPtr(parent)}
	local currentEnt = parent.Child
	local children = {}
	local entHash = GetPtrHash(currentEnt)
	while currentEnt.Child
		and currentEnt.Child:ToNPC()
		and StatusEffectLibrary.Utils.IsInParentChildChain(currentEnt.Child)
		and not children[entHash]
		and BEST_BUD_BALL:CanCaptureMonster(currentEnt.Child)
	do
		Mod:GetData(currentEnt).BestBudBallCaptured = true
		Mod.Insert(monsters, EntityPtr(currentEnt))
		currentEnt = currentEnt.Child
		entHash = GetPtrHash(currentEnt)
	end

	if currentEnt.Parent
		and currentEnt.Parent:ToNPC()
		and StatusEffectLibrary.Utils.IsInParentChildChain(currentEnt)
		and not children[entHash]
		and BEST_BUD_BALL:CanCaptureMonster(currentEnt)
	then
		Mod.Insert(monsters, EntityPtr(currentEnt))
		Mod:GetData(currentEnt).BestBudBallCaptured = true
	end

	return monsters
end

---@param npc EntityNPC
---@param player EntityPlayer
---@param ball EntityEffect
function BEST_BUD_BALL:TryCaptureEnemy(npc, player, ball)
	local data = Mod:GetData(ball)
	local maxHpChance = Mod.math.max(0, (1.25 - (npc.MaxHitPoints / 600)) * 0.5) --+46% chance at 200 max HP, +29% at 400 max hp, and +12.5% at 600 max hp
	local hpChance = (1 - (npc.HitPoints / npc.MaxHitPoints)) * 0.50          --Up to +50% capture chance based on health %
	local luck = Mod:Clamp(player.Luck * 0.025, 0, 0.5)                       --+2.5% per luck, up to 50%
	local roll = player:GetCollectibleRNG(BEST_BUD_BALL.ID):RandomFloat()
	local chance = 0.01 + maxHpChance + hpChance + luck

	data.QueueCapture = BEST_BUD_BALL:GetEntireMonster(npc)
	Mod:DebugLog(npc.Type .. "." .. npc.Variant .. "." .. npc.SubType, "queued for capture.", #data.QueueCapture, "segments contained")

	if roll < chance or Mod:HasBitFlags(Mod.Game:GetDebugFlags(), DebugFlag.INFINITE_ITEM_CHARGES) then
		data.CaptureSuccess = true
	end
end

---@param npcs EntityNPC[]
---@param player EntityPlayer
---@param initialCapture? boolean
function BEST_BUD_BALL:CaptureAndSaveEnemies(npcs, player, initialCapture)
	local run_save = Mod.SaveManager.GetRunSave(player)
	run_save.BestBudBallNPCs = {}
	for _, npc in ipairs(npcs) do
		Mod.Insert(run_save.BestBudBallNPCs, {
			Type = npc.Type,
			Variant = npc.Variant,
			Subtype = npc.SubType,
			MaxHitPoints = npc.MaxHitPoints,
			HitPoints = initialCapture and npc.MaxHitPoints or npc.HitPoints
		})
		npc:Remove()
	end
end

---@param npcs EntityNPC[]
---@param ball EntityEffect
function BEST_BUD_BALL:FailReleaseEnemies(npcs, ball)
	Mod:DebugLog("Capture failed. Releasing", #npcs, "segments")
	for _, npc in ipairs(npcs) do
		npc.Position = ball.Position
		npc.Visible = true
		npc:ClearEntityFlags(EntityFlag.FLAG_FREEZE | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		npc:SetColor(Color(1, 1, 1, 1, 1, 1, 1), 15, 10, true, false)
		Mod:GetData(npc).BestBudBallCaptured = nil
	end
	Mod.Game:SpawnParticles(ball.Position, EffectVariant.TOOTH_PARTICLE, 6, 4)
	Mod.sfxman:Play(SoundEffect.SOUND_CHAIN_BREAK)
	ball:Remove()
end

---@param ent Entity
function BEST_BUD_BALL:IsCapturedBoss(ent)
	local data = Mod:TryGetData(ent)
	return data and data.BestBudBall
end

---@param npc EntityNPC
---@param spawner Entity
function BEST_BUD_BALL:MakeBossFriendly(npc, spawner)
	npc:AddCharmed(EntityRef(spawner), -1)
	---@diagnostic disable-next-line: param-type-mismatch
	npc:AddEntityFlags(EntityFlag.FLAG_PERSISTENT | EntityFlag.FLAG_FRIENDLY_BALL | EntityFlag.FLAG_DONT_COUNT_BOSS_HP | EntityFlag.FLAG_NO_DEATH_TRIGGER)
	Mod:GetData(npc).BestBudBall = true
	npc.SpawnerEntity = spawner
end

---@param cfgs BestBudBallData[]
---@param pos Vector
---@param spawner Entity
---@return EntityNPC[]
function BEST_BUD_BALL:SpawnFriendlyBosses(cfgs, pos, spawner)
	Mod.Foreach.NPC(function(npc, index)
		if BEST_BUD_BALL:IsCapturedBoss(npc) then
			Mod.Spawn.Poof01(0, npc.Position)
			npc:Remove()
		end
	end, nil, nil, nil, { Inverse = true })
	Mod:DebugLog("Attempting release of", #cfgs, "boss segment(s)")
	local bosses = {}
	for i, cfg in ipairs(cfgs) do
		local npc = Mod.Game:Spawn(cfg.Type, cfg.Variant, pos, Vector.Zero, spawner, cfg.Subtype, Mod:Random()):ToNPC()
		---@cast npc EntityNPC
		Mod:DebugLog("Spawned", npc.Type .. "." .. npc.Variant .. "." .. npc.SubType .. ".")
		npc.MaxHitPoints = cfg.MaxHitPoints
		npc.HitPoints = cfg.HitPoints
		npc.SpawnerType = cfg.Type --So that Champions/certain bosses with multiple of the boss don't spawn (Sister Vis, Red Champion Monstro, etc)
		BEST_BUD_BALL:MakeBossFriendly(npc, spawner)
		Mod.Insert(bosses, npc)
		if #cfgs > 1 and i == 1 then
			local bossCount = Isaac.CountEntities(npc)
			npc:Update()
			local spawnedBosses = Isaac.CountEntities(npc)
			--Bosses like Pin will automatically spawn the rest of their segments. Don't bother spawning the rest, as it causes complications otherwise.
			if bossCount < spawnedBosses then
				Mod:DebugLog("Count difference of", bossCount, "and", spawnedBosses, "after update. Segments spawn automatically, ignore remaining spawns")
				for _, boss in ipairs(Isaac.GetRoomEntities()) do
					if boss.FrameCount == 0
						and boss:HasCommonParentWithEntity(npc)
						and not Mod:IsSameEntity(npc, boss)
						and boss:IsBoss()
					then
						BEST_BUD_BALL:MakeBossFriendly(npc, spawner)
						Mod.Insert(bosses, boss:ToNPC())
					end
				end
				return bosses
			end
		end
	end
	return bosses
end

--#endregion

--#region Ball effect update

---@param ball EntityEffect
function BEST_BUD_BALL:UpdatePosition(ball)
	local sprite = ball:GetSprite()
	local data = Mod:GetData(ball)
	if ball.PositionOffset.Y < 0 then
		ball.PositionOffset = ball.PositionOffset + Vector(0, 1.1 ^ ball.FrameCount)
		ball.Velocity = ball.Velocity - ball.Velocity:Resized(0.075 * 1.1 ^ ball.FrameCount)
	elseif not data.BallStationary then
		sprite:SetFrame(4)
		sprite:Stop()
		ball.PositionOffset = Vector.Zero
		ball.Velocity = Vector.Zero
		Mod.sfxman:Play(BEST_BUD_BALL.SFX.LAND, 1, 2, false, 0.8)
		data.BallStationary = true
		ball:SetTimeout(30)
	elseif ball.SpawnerType == EntityType.ENTITY_PLAYER
			and ball.SpawnerEntity
			and (data.CaptureSuccess or data.BlockedCapture)
		then
		local spawner = ball.SpawnerEntity
		Mod.Foreach.PlayerInRadius(ball.Position, ball.Size, function(player, index)
			if spawner and Mod:IsSameEntity(spawner, player) then
				for i = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do
					local itemId = player:GetActiveItem(i)
					if itemId == BEST_BUD_BALL.ID then
						player:AddActiveCharge(player:GetActiveMaxCharge(i), i)
						Mod.sfxman:Play(BEST_BUD_BALL.SFX.PICKUP, 1, 2, false, 0.8)
						ball:Remove()
						return
					end
				end
			end
		end)
	end
end

---@param ball EntityEffect
function BEST_BUD_BALL:SpawnTrail(ball)
	if (ball.FrameCount % 2 == 0) then
		local trail = Mod.Spawn.Effect(EffectVariant.HAEMO_TRAIL, 0, ball.Position + ball.PositionOffset, nil, ball)
		local oldColor = trail:GetSprite().Color
		local newColor = Color(oldColor.R, oldColor.G, oldColor.B, oldColor.A, 0.70, 0.18, 0.69, 1, 1, 1, 1)
		trail:GetSprite().Color = newColor
		trail.DepthOffset = -10
	end
end

---@param ball EntityEffect
---@param player EntityPlayer
function BEST_BUD_BALL:SearchForEnemies(ball, player)
	local data = Mod:GetData(ball)
	if data.QueueCapture or data.BlockedCapture or data.ReleaseNpcCfgs then
		return
	end
	Mod.Foreach.NPCInRadius(ball.Position, ball.Size, function(npc, index)
		if BEST_BUD_BALL:CanCaptureMonster(npc) then
			BEST_BUD_BALL:TryCaptureEnemy(npc, player, ball)
			return true
		elseif not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and npc:IsActiveEnemy(false) then
			data.BlockedCapture = true
			local c = npc.Color
			npc:SetColor(Color(c.R, c.G, c.B, c.A, 0.8), 15, 10, true, false)
			Mod.sfxman:Play(SoundEffect.SOUND_THUMBS_DOWN)
			local pos = ball.Position + (npc.Position - ball.Position):Resized(ball.Size)
			local impact = Mod.Spawn.Effect(EffectVariant.IMPACT, 0, pos)
			impact.PositionOffset = ball.PositionOffset
			ball.Velocity = ball.Velocity:Rotated(180 + Mod:RandomNum(-45, 45))
		end
	end)
end

---@param ball EntityEffect
function BEST_BUD_BALL:OnBallUpdate(ball)
	local data = Mod:GetData(ball)
	local player = ball.SpawnerEntity and ball.SpawnerEntity:ToPlayer()

	BEST_BUD_BALL:UpdatePosition(ball)

	if data.QueueCapture and #data.QueueCapture > 0 and not data.BlockedCapture then
		local bosses = data.QueueCapture
		for i = #bosses, 1, -1 do
			local npc = bosses[i].Ref
			if not npc or not npc:Exists() then
				table.remove(bosses, i)
			elseif npc and npc:Exists() then
				npc.Position = ball.Position
				npc:AddEntityFlags(EntityFlag.FLAG_FREEZE | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
				npc.Visible = false
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			end
		end
		if ball.Timeout == 0 then
			local npcs = {}
			for _, ptr in ipairs(bosses) do
				Mod.Insert(npcs, ptr.Ref:ToNPC())
			end
			if data.CaptureSuccess and player then
				Mod:DebugLog("Capture success. Storing", #npcs, "segments")
				BEST_BUD_BALL:CaptureAndSaveEnemies(npcs, player, true)
				player:AnimateHappy()
				ball.Timeout = -1
			else
				if player then
					player:AnimateSad()
				end
				BEST_BUD_BALL:FailReleaseEnemies(npcs, ball)
			end
		end
	end

	if ball.Timeout == 0 and not data.BlockedCapture then
		local cfg = data.ReleaseNpcCfgs
		if cfg and player then
			BEST_BUD_BALL:SpawnFriendlyBosses(cfg, ball.Position, player)
		end
		Mod.Spawn.Poof01(1, ball.Position, ball)
		ball:Remove()
		return
	end

	if data.BallStationary then return end

	BEST_BUD_BALL:SpawnTrail(ball)

	if player then
		BEST_BUD_BALL:SearchForEnemies(ball, player)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, BEST_BUD_BALL.OnBallUpdate, BEST_BUD_BALL.EFFECT)

--#endregion

--#region Captured enemies immune to damage and collision

---@param source EntityRef
function BEST_BUD_BALL:StopCaptureDamage(ent, amount, flags, source)
	local npc = ent:ToNPC()
	local data = npc and Mod:TryGetData(npc)
	if npc and data and data.BestBudBallCaptured then
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, BEST_BUD_BALL.StopCaptureDamage)

--#endregion

--#region Update boss pos on new room

function BEST_BUD_BALL:FixPosOnNewRoom()
	Mod.Foreach.NPC(function(npc, index)
		if BEST_BUD_BALL:IsCapturedBoss(npc) then
			local room = Mod.Room()
			npc.Position = Isaac.GetPlayer().Position
			npc.Position = room:GetClampedPosition(Isaac.GetPlayer().Position, npc.Size)

			if npc.Mass >= 100 then
				npc.TargetPosition = npc.Position
			end
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BEST_BUD_BALL.FixPosOnNewRoom)

--#endregion

--#region Save and restore bosses as charmed ones aren't normally persistent

function BEST_BUD_BALL:SaveBossOnGameExit(shouldSave)
	if not shouldSave then return end
	local playerToNpcs = {}
	Mod.Foreach.NPC(function(npc, index)
		if BEST_BUD_BALL:IsCapturedBoss(npc) and BEST_BUD_BALL:CanCaptureMonster(npc, true) then
			local player = npc.SpawnerEntity and npc.SpawnerEntity:ToPlayer()
			if player then
				local playerIndex = player:GetPlayerIndex()
				playerToNpcs[playerIndex] = playerToNpcs[playerIndex] or {}
				Mod.Insert(playerToNpcs[playerIndex], npc)
			end
		end
	end, nil, nil, nil, { Inverse = true })
	--Gemini Cord, Blighted Ovum Baby, etc
	Mod.Foreach.NPC(function (npc, index)
		if npc.Parent
			and BEST_BUD_BALL:IsCapturedBoss(npc.Parent)
			and not BEST_BUD_BALL:CanCaptureMonster(npc, true)
		then
			npc:ClearEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM)
			npc:Remove()
		end
	end, nil, nil, nil, {Inverse = true})
	for pIndex, npcs in pairs(playerToNpcs) do
		table.sort(npcs, function (a, b)
			return a.Variant < b.Variant
		end)
		Mod:DebugLog("Storing", #npcs, "segments", "for player", pIndex, "on game exit")
		BEST_BUD_BALL:CaptureAndSaveEnemies(npcs, Isaac.GetPlayer(pIndex))
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, BEST_BUD_BALL.SaveBossOnGameExit)

---@param isContinued boolean
function BEST_BUD_BALL:RestoreBossOnGameContinue(isContinued)
	if not isContinued then return end
	Mod.Foreach.Player(function(player, index)
		local run_save = Mod.SaveManager.GetRunSave(player)
		if run_save.BestBudBallNPCs then
			BEST_BUD_BALL:SpawnFriendlyBosses(run_save.BestBudBallNPCs, player.Position, player)
			run_save.BestBudBallNPCs = nil
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, BEST_BUD_BALL.RestoreBossOnGameContinue)

--#endregion

--#region Unique Active sprite

---@param player EntityPlayer
---@param slot ActiveSlot
function BEST_BUD_BALL:AdjustCropOffset(player, slot, offset, alpha, scale, chargebarOffset)
	local crop = Mod.SaveManager.GetRunSave(player).BestBudBallNPCs ~= nil and 32 or 0
	return { CropOffset = Vector(crop, 0) }
end

Mod:AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_ACTIVE_ITEM, BEST_BUD_BALL.AdjustCropOffset, BEST_BUD_BALL.ID)

--#endregion

--#region Rag Man patch

---@param npc EntityNPC
function BEST_BUD_BALL:StopRaglingSpawn(npc)
	if BEST_BUD_BALL:IsCapturedBoss(npc)
		and npc.State == NpcState.STATE_IDLE
		and npc.StateFrame == npc.I1
	then
		npc:Kill()
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, BEST_BUD_BALL.StopRaglingSpawn, EntityType.ENTITY_RAG_MAN)

--#endregion

--#region Pin patch

--Counteracts the health drain as part of "persistent" bosses because of Delirious' rework in Repentance+
--[[ function BEST_BUD_BALL:StopHealthDrain()
	local frameCount = Mod.Game:GetFrameCount()
	Mod.Foreach.NPC(function (npc, index)
		if frameCount % 15 == 0
			and npc:IsBoss()
			and BEST_BUD_BALL:IsCapturedBoss(npc)
			and npc.HitPoints > 0
			and npc:HasEntityFlags(EntityFlag.FLAG_PERSISTENT)
		then
			npc.HitPoints = npc.HitPoints + 0.25
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, BEST_BUD_BALL.StopHealthDrain) ]]

---The health drain counts as damage for pin's other segments for whatever reason, causing it to flash. This prevents it best I can
---@param ent Entity
---@param source EntityRef
function BEST_BUD_BALL:PinIsStupid(ent, amount, flags, source, countdown)
	if BEST_BUD_BALL:IsCapturedBoss(ent)
		and ent:HasEntityFlags(EntityFlag.FLAG_PERSISTENT)
		and source.Type == EntityType.ENTITY_PIN
		and Mod:HasBitFlags(flags, EntityFlag.FLAG_RENDER_WALL) --Doesn't make sense but its the flag used when damaging other segments
		and amount == 0.25
		and ent.HitPoints > 0
	then
		return false
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.IMPORTANT, BEST_BUD_BALL.PinIsStupid, EntityType.ENTITY_PIN)

--#endregion

--#region Gemini patch

---@param npc EntityNPC
function BEST_BUD_BALL:GeminiChain(npc)
	if npc.Variant ~= 20 then return end
	if npc.Parent then
		local data = Mod:TryGetData(npc.Parent)
		if data and (data.BestBudBallCaptured or data.BestBudBall) then
			local chainData = Mod:GetData(npc)
			if not chainData.GeminiChain then
				chainData.GeminiChain = true
			end
			if data.BestBudBallCaptured then
				return false
			end
		end
	else
		local chainData = Mod:TryGetData(npc)
		if chainData and chainData.GeminiChain then
			npc:Remove()
			return false
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_NPC_RENDER, BEST_BUD_BALL.GeminiChain, EntityType.ENTITY_GEMINI)

--#endregion

--#region Big Horn patch

function BEST_BUD_BALL:StopBigHornHandCapture(ent)
	if ent.Variant ~= 0 then
		return false
	end
end

Mod:AddCallback(Mod.ModCallbacks.CAN_CAPTURE_BOSS, BEST_BUD_BALL.StopBigHornHandCapture, EntityType.ENTITY_BIG_HORN)

--#endregion

--#region Patch for on-death spawns

---@param npc EntityNPC
function BEST_BUD_BALL:MarkFriendlyBossSpawns(npc)
	if npc.SpawnerEntity
		and npc:IsBoss()
		and BEST_BUD_BALL:IsCapturedBoss(npc.SpawnerEntity)
	then
		BEST_BUD_BALL:MakeBossFriendly(npc, npc.SpawnerEntity.SpawnerEntity)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, BEST_BUD_BALL.MarkFriendlyBossSpawns)

---@param npc EntityNPC
function BEST_BUD_BALL:MarkFriendlyBossMorphs(npc, type, var, sub)
	if BEST_BUD_BALL:IsCapturedBoss(npc) then
		BEST_BUD_BALL:MakeBossFriendly(npc, npc.SpawnerEntity)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_MORPH, BEST_BUD_BALL.MarkFriendlyBossMorphs)

--#endregion