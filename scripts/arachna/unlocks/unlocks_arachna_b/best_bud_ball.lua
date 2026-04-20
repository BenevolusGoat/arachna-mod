--#region Variables

local Mod = ARACHNAMOD

local BEST_BUD_BALL = {}

ARACHNAMOD.Item.BEST_BUD_BALL = BEST_BUD_BALL

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
})

---@class BestBudBallNPC
---@field Type EntityType
---@field Variant integer
---@field Subtype integer
---@field ChampionColor ChampionColor
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
	LiftFn = function (player, continued, slot, mimic)
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
		if run_save.BestBudBallNPC then
			Mod:GetData(ball).ReleaseNpcCfg = Mod:CopyTable(run_save.BestBudBallNPC)
			run_save.BestBudBallNPC = nil
		end
	end
end

---@param ent Entity
function BEST_BUD_BALL:CanCaptureEnemy(ent)
	return ent:IsBoss()
		and not ent:ToDelirium()
		and not BEST_BUD_BALL.BLACKLISTED_BOSSES[ent.Type]
end

---@param npc EntityNPC
---@param player EntityPlayer
---@param ball EntityEffect
function BEST_BUD_BALL:TryCaptureEnemy(npc, player, ball)
	local data = Mod:GetData(ball)
	local maxHpChance = Mod.math.max(0, (1.25 - (npc.MaxHitPoints / 600)) * 0.5) --+46% chance at 200 max HP, +29% at 400 max hp, and +12.5% at 600 max hp
	local hpChance = (1 - (npc.HitPoints / npc.MaxHitPoints)) * 0.50 --Up to +50% capture chance based on health %
	local luck = Mod:Clamp(player.Luck * 0.025, 0, 0.5) --+2.5% per luck, up to 50%
	local roll = player:GetCollectibleRNG(BEST_BUD_BALL.ID):RandomFloat()
	local chance = 0.01 + maxHpChance + hpChance + luck

	Mod:GetData(npc).BestBudBallCaptured = true
	data.QueueCapture = EntityPtr(npc)

	if roll < chance then
		data.CaptureSuccess = true
	end
end

---@param npc EntityNPC
---@param player EntityPlayer
---@param initialCapture? boolean
function BEST_BUD_BALL:CaptureAndSaveEnemy(npc, player, initialCapture)
	npc:Remove()
	local run_save = Mod.SaveManager.GetRunSave(player)
	run_save.BestBudBallNPC = {
		Type = npc.Type,
		Variant = npc.Variant,
		Subtype = npc.SubType,
		ChampionColor = npc:GetChampionColorIdx(),
		MaxHitPoints = npc.MaxHitPoints,
		HitPoints = initialCapture and npc.MaxHitPoints or npc.HitPoints
	}
end

---@param npc EntityNPC
---@param ball EntityEffect
function BEST_BUD_BALL:FailReleaseEnemy(npc, ball)
	npc.Position = ball.Position
	npc.Visible = true
	npc:ClearEntityFlags(EntityFlag.FLAG_FREEZE | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
	npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
	npc:SetColor(Color(1, 1, 1, 1, 1, 1, 1), 15, 10, true, false)
	Mod.Game:SpawnParticles(ball.Position, EffectVariant.TOOTH_PARTICLE, 6, 4)
	Mod.sfxman:Play(SoundEffect.SOUND_CHAIN_BREAK)
	ball:Remove()
end

---@param cfg BestBudBallNPC
---@param pos Vector
---@param player EntityPlayer
function BEST_BUD_BALL:SpawnFriendlyBoss(cfg, pos, player)
	Mod.Foreach.NPC(function (npc, index)
		local data = Mod:TryGetData(npc)
		if data
			and data.BestBudBall
			and npc.SpawnerEntity
			and Mod:IsSameEntity(npc.SpawnerEntity, player)
		then
			npc:Remove()
			Mod.Spawn.Poof01(3, npc.Position)
		end
	end, nil, nil, nil, {Inverse = true})
	local npc = Mod.Game:Spawn(cfg.Type, cfg.Variant, pos, Vector.Zero, player, cfg.Subtype, Mod:Random())
	npc.MaxHitPoints = cfg.MaxHitPoints
	npc.HitPoints = cfg.HitPoints
	npc:AddCharmed(EntityRef(player), -1)
	---@diagnostic disable-next-line: param-type-mismatch
	npc:AddEntityFlags(EntityFlag.FLAG_PERSISTENT | EntityFlag.FLAG_FRIENDLY_BALL)
	Mod:GetData(npc).BestBudBall = true
end

--#endregion

--#region Ball effect update

---@param ball EntityEffect
function BEST_BUD_BALL:UpdatePosition(ball)
	local sprite = ball:GetSprite()
	local data = Mod:GetData(ball)
	if ball.PositionOffset.Y < 0 then
		ball.PositionOffset = ball.PositionOffset + Vector(0, 1.1^ball.FrameCount)
		ball.Velocity = ball.Velocity - ball.Velocity:Resized(0.075 * 1.1^ball.FrameCount)
	elseif not data.BallStationary then
		sprite:SetFrame(4)
		sprite:Stop()
		ball.PositionOffset = Vector.Zero
		ball.Velocity = Vector.Zero
		Mod.sfxman:Play(BEST_BUD_BALL.SFX.LAND, 1, 2, false, 0.8)
		data.BallStationary = true
		ball:SetTimeout(30)
	elseif ball.SpawnerType == EntityType.ENTITY_PLAYER and ball.SpawnerEntity and data.CaptureSuccess then
		local spawner = ball.SpawnerEntity
		Mod.Foreach.PlayerInRadius(ball.Position, ball.Size, function (player, index)
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
	if data.QueueCapture then
		return
	end
	Mod.Foreach.NPCInRadius(ball.Position, ball.Size, function (npc, index)
		if BEST_BUD_BALL:CanCaptureEnemy(npc) then
			BEST_BUD_BALL:TryCaptureEnemy(npc, player, ball)
			return true
		end
	end, nil, nil, {UseEnemySearchParams = true})
end

---@param ball EntityEffect
function BEST_BUD_BALL:OnBallUpdate(ball)
	local data = Mod:GetData(ball)
	local player = ball.SpawnerEntity and ball.SpawnerEntity:ToPlayer()
	local npc = data.QueueCapture and data.QueueCapture.Ref and data.QueueCapture.Ref:ToNPC()

	BEST_BUD_BALL:UpdatePosition(ball)

	if npc then
		npc:AddEntityFlags(EntityFlag.FLAG_FREEZE | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
		npc.Visible = false
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		if ball.Timeout == 0 then
			Mod:GetData(npc).BestBudBallCaptured = nil
			if data.CaptureSuccess and player then
				BEST_BUD_BALL:CaptureAndSaveEnemy(npc, player, true)
				player:AnimateHappy()
				ball.Timeout = -1
			else
				BEST_BUD_BALL:FailReleaseEnemy(npc, ball)
			end
		end
	end

	if ball.Timeout == 0 then
		local cfg = Mod:GetData(ball).ReleaseNpcCfg
		if cfg and player then
			BEST_BUD_BALL:SpawnFriendlyBoss(cfg, ball.Position, player)
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
	Mod.Foreach.NPC(function (npc, index)
		local data = Mod:TryGetData(npc)
		if data and data.BestBudBall then
			npc.Position = Isaac.GetPlayer().Position
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BEST_BUD_BALL.FixPosOnNewRoom)

--#endregion

--#region Save and restore bosses as charmed ones aren't normally persistent

function BEST_BUD_BALL:SaveBossOnGamExit()
	Mod.Foreach.NPC(function (npc, index)
		local data = Mod:TryGetData(npc)
		if data and data.BestBudBall then
			local player = npc.SpawnerEntity and npc.SpawnerEntity:ToPlayer()
			if player then
				BEST_BUD_BALL:CaptureAndSaveEnemy(npc, player)
			end
		end
	end, nil, nil, nil, {Inverse = true})
end

Mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, BEST_BUD_BALL.SaveBossOnGamExit)

---@param isContinued boolean
function BEST_BUD_BALL:RestoreBossOnGameContinue(isContinued)
	if not isContinued then return end
	Mod.Foreach.Player(function (player, index)
		local run_save = Mod.SaveManager.GetRunSave(player)
		if run_save.BestBudBallNPC then
			BEST_BUD_BALL:SpawnFriendlyBoss(run_save.BestBudBallNPC, player.Position, player)
			run_save.BestBudBallNPC = nil
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, BEST_BUD_BALL.RestoreBossOnGameContinue)

--#endregion

--#region Unique Active sprite

---@param player EntityPlayer
---@param slot ActiveSlot
function BEST_BUD_BALL:AdjustCropOffset(player, slot, offset, alpha, scale, chargebarOffset)
	local crop = Mod.SaveManager.GetRunSave(player).BestBudBallNPC ~= nil and 32 or 0
	return {CropOffset = Vector(crop, 0)}
end

Mod:AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_ACTIVE_ITEM, BEST_BUD_BALL.AdjustCropOffset, BEST_BUD_BALL.ID)

--#endregion