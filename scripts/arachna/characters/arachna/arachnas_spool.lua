--#region Variables

local Mod = ARACHNAMOD

local ARACHNAS_SPOOL = {}

ARACHNAMOD.Item.ARACHNAS_SPOOL = ARACHNAS_SPOOL

ARACHNAS_SPOOL.ID = Isaac.GetItemIdByName("Arachna's Spool")

ARACHNAS_SPOOL.TEAR = Isaac.GetEntityVariantByName("Spool Tear")
ARACHNAS_SPOOL.WEB_EFFECT = Isaac.GetEntityVariantByName("Spider Web")

local identifier = "ARACHNA_WEBBED"
StatusEffectLibrary.RegisterStatusEffect(identifier, nil, StatusEffectLibrary.StatusColor.SLOW, EntityFlag.FLAG_SLOW,
	true)
ARACHNAS_SPOOL.STATUS_WEBBED = StatusEffectLibrary.StatusFlag[identifier]

ARACHNAS_SPOOL.INHERITED_TEAR_FLAGS = {
	TearFlags.TEAR_SPECTRAL,
	TearFlags.TEAR_HOMING,
	TearFlags.TEAR_WIGGLE,
	TearFlags.TEAR_TURN_HORIZONTAL,
	TearFlags.TEAR_SHIELDED,
	TearFlags.TEAR_CONTINUUM,
	TearFlags.TEAR_TRACTOR_BEAM
}

ARACHNAS_SPOOL.MINIBOSS = Mod:Set({
	tostring(EntityType.ENTITY_SLOTH) .. ".0.0",
	tostring(EntityType.ENTITY_LUST) .. ".0.0",
	tostring(EntityType.ENTITY_WRATH) .. ".0.0",
	tostring(EntityType.ENTITY_GLUTTONY) .. ".0.0",
	tostring(EntityType.ENTITY_GREED) .. ".0.0",
	tostring(EntityType.ENTITY_ENVY) .. ".0.0",
	tostring(EntityType.ENTITY_ENVY) .. ".10.0",
	tostring(EntityType.ENTITY_ENVY) .. ".20.0",
	tostring(EntityType.ENTITY_ENVY) .. ".30.0",
	tostring(EntityType.ENTITY_PRIDE) .. ".0.0",
})
ARACHNAS_SPOOL.BOSS_CHARGE_DMG_THRESHOLD = 50
ARACHNAS_SPOOL.BOSS_CHARGE_DMG_STAGE = 10

--#endregion

--#region Helpers

---@param pos Vector
---@param vel Vector
---@param spawner? Entity
function ARACHNAS_SPOOL:FireSpool(pos, vel, spawner)
	Mod.sfxman:Play(SoundEffect.SOUND_TEARS_FIRE, 0, 2)
	local spoolTear = Mod.Spawn.Tear(ARACHNAS_SPOOL.TEAR, pos, vel, nil, spawner)
	spoolTear.CollisionDamage = 4.2
	spoolTear.FallingSpeed = -5.5
	spoolTear.FallingAcceleration = 0.5
	Mod.sfxman:Play(SoundEffect.SOUND_FETUS_JUMP, 0.8)
	if Mod:IsLegacyGameplayEnabled() then
		spoolTear:SetSize(8, Vector.One, 8)
	end
	local player = spawner and spawner:ToPlayer()
	if player then
		local weapon = player:GetWeapon(1)
		local playerFlags = player:GetTearHitParams(weapon and weapon:GetWeaponType() or WeaponType.WEAPON_TEARS, 1, 1,
			spoolTear).TearFlags
		for _, tearFlag in ipairs(ARACHNAS_SPOOL.INHERITED_TEAR_FLAGS) do
			if Mod:HasBitFlags(playerFlags, tearFlag) then
				spoolTear:AddTearFlags(tearFlag)
			end
		end
	end
end

---@param pos Vector
---@param spawner? Entity
function ARACHNAS_SPOOL:SpawnWeb(pos, spawner)
	return Mod.Spawn.Effect(ARACHNAS_SPOOL.WEB_EFFECT, 0, pos, nil, spawner)
end

---How much damage is required in order to fill the chargebar on a boss to spawn a Spider Egg
---...this is literally just the Stage HP formula don't @ me
function ARACHNAS_SPOOL:GetBossChargeDamageThreshold()
	local stage = Mod.Level():GetStage()
	local stageModifier = Mod.math.min(4, stage) + 0.8 * stage
	return ARACHNAS_SPOOL.BOSS_CHARGE_DMG_THRESHOLD + stageModifier * ARACHNAS_SPOOL.BOSS_CHARGE_DMG_STAGE
end

--#endregion

--#region Arachna's Spool

ThrowableItemLib:RegisterThrowableItem({
	Type = ThrowableItemLib.Type.ACTIVE,
	ID = ARACHNAS_SPOOL.ID,
	Identifier = "Arachna's Spool",
	ThrowFn = function(player, vect, slot, mimic)
		ARACHNAS_SPOOL:FireSpool(player.Position, Mod:AddTearVelocity(vect, 12, player), player)
	end
})

---@param tear EntityTear
function ARACHNAS_SPOOL:OnTearUpdate(tear)
	if Mod:IsLegacyGameplayEnabled() then
		tear:SetSize(8, Vector.One, 8)
	end
	if tear.FrameCount % 2 == 0 then
		local pos = Vector(tear.Position.X, tear.Position.Y + 1.1 + tear.Height)
		local trail = Mod.Spawn.Effect(EffectVariant.HAEMO_TRAIL, 0, pos, nil, tear)
		trail:GetSprite().Color = Color(1, 1, 1, 1, 1, 1, 1)
		trail:Update()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, ARACHNAS_SPOOL.OnTearUpdate, ARACHNAS_SPOOL.TEAR)

---@param tear EntityTear
function ARACHNAS_SPOOL:OnTearDeath(tear)
	Mod.sfxman:Play(SoundEffect.SOUND_WOOD_PLANK_BREAK, 1, 7, false, 3)
	Mod.sfxman:Play(SoundEffect.SOUND_SUMMON_POOF, 0.8)
	Mod.Game:SpawnParticles(tear.Position, EffectVariant.WOOD_PARTICLE, Mod:RandomNum(5, 10), 4)
	local maxWebCount = 1
	local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
	if player and Mod.Character.ARACHNA:ArachnaHasBirthright(player) then
		maxWebCount = 2
	end
	local ownedWebs = {}
	Mod.Foreach.Effect(function(web, index)
		if web.SpawnerEntity and Mod:IsSameEntity(web.SpawnerEntity, tear.SpawnerEntity) then
			Mod.Insert(ownedWebs, web)
		end
	end, ARACHNAS_SPOOL.WEB_EFFECT)
	--Oldest webs get removed first
	table.sort(ownedWebs, function(web1, web2)
		return web1.FrameCount > web2.FrameCount
	end)

	while (#ownedWebs >= maxWebCount) do
		local ent = ownedWebs[1]
		ent:GetSprite():Play("Remove")
		table.remove(ownedWebs, 1)
	end
	local fixedPos = Mod.Room():GetClampedPosition(tear.Position, 45)
	ARACHNAS_SPOOL:SpawnWeb(fixedPos, tear.SpawnerEntity)
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, ARACHNAS_SPOOL.OnTearDeath, ARACHNAS_SPOOL.TEAR)

--#endregion

--#region Spider Web

---@param web EntityEffect
function ARACHNAS_SPOOL:OnWebInit(web)
	local rng = web:GetDropRNG()
	local sprite = web:GetSprite()
	sprite:ReplaceSpritesheet(0, "gfx/effects/web_" .. tostring(rng:RandomInt(4) + 1) .. ".png", true)
	if rng:RandomInt(2) == 0 then sprite.FlipX = true end
	if rng:RandomInt(2) == 0 then sprite.FlipY = true end
	web.SortingLayer = SortingLayer.SORTING_BACKGROUND
	web:GetSprite():Play("Appear", true)
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, ARACHNAS_SPOOL.OnWebInit, ARACHNAS_SPOOL.WEB_EFFECT)

---@param web EntityEffect
function ARACHNAS_SPOOL:OnWebUpdate(web)
	local sprite = web:GetSprite()
	if sprite:IsFinished("Appear") then
		sprite:Play("Idle")
	end
	if sprite:IsFinished("Remove") then
		web:Remove()
	end
	local player = web.SpawnerEntity and web.SpawnerEntity:ToPlayer()
	local source = player and EntityRef(player) or EntityRef(web)
	local room = Mod.Room()
	Mod.Foreach.NPCInRadius(web.Position, web.Size, function(npc, index)
		local grid = room:GetGridEntityFromPos(npc.Position)
		if grid and grid:ToPit() and not Mod:IsLegacyGameplayEnabled() then
			return
		end
		if not StatusEffectLibrary:HasStatusEffect(npc, Mod.Item.DIVINE_CLOTH.STATUS_BITTEN) then
			ARACHNAS_SPOOL:ApplyWebbed(npc, source, 2)
		end
	end, nil, nil, { UseEnemySearchParams = true, Dead = true })
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, ARACHNAS_SPOOL.OnWebUpdate, ARACHNAS_SPOOL.WEB_EFFECT)

--#endregion

--#region Webbed & Spider Bite

--Webbed and Spider Bite statuses share several similarities so the code is stored here

---@param ent Entity
---@param statusEffect StatusFlag
---@param customData table
function ARACHNAS_SPOOL:PreAddWebOrBitten(ent, statusEffect, customData)
	if Mod:HasBitFlags(statusEffect, ARACHNAS_SPOOL.STATUS_WEBBED) or Mod:HasBitFlags(statusEffect, Mod.Item.DIVINE_CLOTH.STATUS_BITTEN) then
		local npc = ent:ToNPC()
		if not npc or not ARACHNAS_SPOOL:ShouldReceiveStatusEffect(npc) then
			return true
		end
	end
end

StatusEffectLibrary.Callbacks.AddCallback(StatusEffectLibrary.Callbacks.ID.PRE_ADD_ENTITY_STATUS_EFFECT,
	ARACHNAS_SPOOL.PreAddWebOrBitten)

---@param ent Entity
function ARACHNAS_SPOOL:PostAddWebOrBitten(ent, statusEffect, statusEffectData)
	if Mod:HasBitFlags(statusEffect, ARACHNAS_SPOOL.STATUS_WEBBED) or Mod:HasBitFlags(statusEffect, Mod.Item.DIVINE_CLOTH.STATUS_BITTEN) then
		local data = Mod:GetData(ent)
		if not data.WebbedStatusSprite then
			local sprite = Sprite("gfx/indicator_arachna_b.anm2", true)
			sprite:Play("Idle")
			data.WebbedStatusSprite = sprite
		end
	end
end

StatusEffectLibrary.Callbacks.AddCallback(StatusEffectLibrary.Callbacks.ID.POST_ADD_ENTITY_STATUS_EFFECT,
	ARACHNAS_SPOOL.PostAddWebOrBitten)

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function ARACHNAS_SPOOL:BossChargebar(ent, amount, flags, source, countdown)
	if ARACHNAMOD:IsLegacyGameplayEnabled() then
		return
	end
	local npc = ent:ToNPC()
	if npc and npc:IsBoss() then
		local hasWebbed = StatusEffectLibrary:HasStatusEffect(npc, ARACHNAS_SPOOL.STATUS_WEBBED)
		local hasSpiderBite = StatusEffectLibrary:HasStatusEffect(npc, Mod.Item.DIVINE_CLOTH.STATUS_BITTEN)

		if hasWebbed or hasSpiderBite then
			local parent = StatusEffectLibrary.Utils.GetLastParent(npc)
			if GetPtrHash(parent) ~= GetPtrHash(npc) then return end
			local player = Mod:TryGetPlayer(source, { LoopSpawnerEnt = true })
			local data = Mod:GetData(parent)
			if not data.SpiderBossChargeSprite then
				data.SpiderBossChargeSprite = Sprite("gfx/ui_arachna_chargebar_boss.anm2", true)
			end
			if not data.SpiderBossChargeDMGNeeded then
				data.SpiderBossChargeDMGNeeded = ARACHNAS_SPOOL:GetBossChargeDamageThreshold()
			end
			data.SpiderBossCharge = (data.SpiderBossCharge or 0) + amount
			Mod:DebugLog("Boss Egg Progress:", "Frame", Mod.Room():GetFrameCount(), "Charge", data.SpiderBossCharge)

			if data.SpiderBossCharge > data.SpiderBossChargeDMGNeeded then
				data.SpiderBossCharge = 0
				Mod:DebugLog("Spawning Boss Egg")
				Mod.Entities.SPIDER_EGG:TrySpawnEgg(ent.Position, ent, player, true)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, ARACHNAS_SPOOL.BossChargebar)

---@param npc EntityNPC
---@param offset Vector
function ARACHNAS_SPOOL:RenderWebOnWebbedOrBitten(npc, offset)
	local data = Mod:TryGetData(npc)
	local hasWebbed = StatusEffectLibrary:HasStatusEffect(npc, ARACHNAS_SPOOL.STATUS_WEBBED)
	local hasSpiderBite = StatusEffectLibrary:HasStatusEffect(npc, Mod.Item.DIVINE_CLOTH.STATUS_BITTEN)
	local renderPos = Mod:GetEntityRenderPosition(npc, offset)
	if (hasWebbed or hasSpiderBite) and data and data.WebbedStatusSprite then
		---@type Sprite
		local sprite = data.WebbedStatusSprite
		sprite.Scale = (npc.Size / 15) * npc.SpriteScale
		sprite:Render(renderPos)
		if Mod:ShouldUpdateSprite() then
			sprite:Update()
		end
	end
	if data and data.SpiderBossCharge and data.SpiderBossChargeSprite and data.SpiderBossChargeDMGNeeded then
		local nullFrame = npc:GetSprite():GetNullFrame("OverlayEffect")
		if nullFrame and nullFrame:IsVisible() then
			renderPos = renderPos + nullFrame:GetPos() + Vector(15, 10)
			local progress = data.SpiderBossCharge / data.SpiderBossChargeDMGNeeded
			local percent = Mod.math.floor(progress * 100)
			local frameNum = Mod:Clamp(percent - 1, 0, 99)
			data.SpiderBossChargeSprite.Color.A = Mod:Lerp(data.SpiderBossChargeSprite.Color.A,
				(hasWebbed or hasSpiderBite) and 1 or 0.5, 0.2)
			data.SpiderBossChargeSprite:SetFrame("Charging", frameNum)
			data.SpiderBossChargeSprite:Render(renderPos)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, ARACHNAS_SPOOL.RenderWebOnWebbedOrBitten)

--#endregion

--#region Webbed Status

---@param npc EntityNPC
---@param source EntityRef
---@param duration integer
function ARACHNAS_SPOOL:ApplyWebbed(npc, source, duration)
	return StatusEffectLibrary:AddStatusEffect(npc, ARACHNAS_SPOOL.STATUS_WEBBED, duration, source, nil, {OriginalMass = npc.Mass})
end

---@param npc EntityNPC
function ARACHNAS_SPOOL:ShouldReceiveStatusEffect(npc)
	return not npc:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN)
		and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
		and not npc:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
		and npc:IsActiveEnemy(false)
		and npc:IsVulnerableEnemy()
		and (not ARACHNAMOD:IsLegacyGameplayEnabled() or not npc:IsBoss())
end

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function ARACHNAS_SPOOL:LastWebbedCredit(ent, amount, flags, source, countdown)
	if StatusEffectLibrary:HasStatusEffect(ent, ARACHNAS_SPOOL.STATUS_WEBBED) then
		local player = Mod:TryGetPlayer(source, {LoopSpawnerEnt = true})
		if player then
			Mod:GetData(ent).WebbedKillCredit = EntityPtr(player)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, ARACHNAS_SPOOL.LastWebbedCredit)

---We want this on POST_NPC_DEATH but StatusEffectLibrary (yes the library I coded) removes all status effect data when an entity is removed, like it should.
---
---Save the information that the enemy has the status effect to our own custom data which does save for POST_NPC_DEATH.
---@param ent Entity
---@param source EntityRef
function ARACHNAS_SPOOL:OnNPCKill(ent, source)
	local isLegacy = ARACHNAMOD:IsLegacyGameplayEnabled()
	if StatusEffectLibrary:HasStatusEffect(ent, ARACHNAS_SPOOL.STATUS_WEBBED)
		or (not isLegacy and source.Type == EntityType.ENTITY_TEAR and source.Variant == ARACHNAS_SPOOL.TEAR)
	then
		if ent:IsBoss() and isLegacy then
			return
		end
		Mod:GetData(ent).QueueSpiderEgg = source
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, ARACHNAS_SPOOL.OnNPCKill)

---@param npc EntityNPC
function ARACHNAS_SPOOL:OnNPCDeath(npc)
	if Mod:GetData(npc).QueueSpiderEgg then
		if npc:IsBoss() and Isaac.CountBosses() == 1 and Mod:SomeoneIsArachna() then
			Mod.Foreach.Pickup(function(heart, index)
				if heart.SpawnerType == npc.Type and heart.FrameCount == 0 then
					local newSubtype = heart.SubType == HeartSubType.HEART_DOUBLEPACK and Mod.Pickup.WEB_HEART.ID_DOUBLE or
					Mod.Pickup.WEB_HEART.ID
					heart:Morph(heart.Type, heart.Variant, newSubtype, true, true, true)
				end
			end, PickupVariant.PICKUP_HEART)
		end
		local entityPtr = Mod:GetData(npc).WebbedKillCredit
		local player = entityPtr and entityPtr.Ref and entityPtr.Ref:ToPlayer()
		local egg = Mod.Entities.SPIDER_EGG:TrySpawnEgg(npc.Position, npc, player)
		if egg and egg.SubType == 0 then
			--egg:SetTimeout(Mod.Entities.SPIDER_EGG.MAX_EGG_TIMEOUT)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, ARACHNAS_SPOOL.OnNPCDeath)

---@param ent Entity
---@param statusEffectData StatusEffectData
function ARACHNAS_SPOOL:PostAddWebbed(ent, _, statusEffectData)
	if not Mod:IsLegacyGameplayEnabled() then
		ent.Mass = statusEffectData.CustomData.OriginalMass * 2
	end
end

StatusEffectLibrary.Callbacks.AddCallback(StatusEffectLibrary.Callbacks.ID.POST_ADD_ENTITY_STATUS_EFFECT,
	ARACHNAS_SPOOL.PostAddWebbed, ARACHNAS_SPOOL.STATUS_WEBBED)

---@param ent Entity
---@param statusEffectData StatusEffectData
function ARACHNAS_SPOOL:PostRemoveWebbed(ent, _, statusEffectData)
	if not Mod:IsLegacyGameplayEnabled() then
		ent.Mass = statusEffectData.CustomData.OriginalMass
	end
end

StatusEffectLibrary.Callbacks.AddCallback(StatusEffectLibrary.Callbacks.ID.POST_REMOVE_ENTITY_STATUS_EFFECT,
	ARACHNAS_SPOOL.PostRemoveWebbed)

---@param ent Entity
function ARACHNAS_SPOOL:WebbedUpdate(ent)
	local speed = ent:IsBoss() and 0.75 or 0.5
	if ent:GetSpeedMultiplier() < speed then return end
	ent:SetSpeedMultiplier(speed)
end

StatusEffectLibrary.Callbacks.AddCallback(StatusEffectLibrary.Callbacks.ID.ENTITY_STATUS_EFFECT_UPDATE,
	ARACHNAS_SPOOL.WebbedUpdate, ARACHNAS_SPOOL.STATUS_WEBBED)

--#endregion

--#region Legacy Charge Time

function ARACHNAS_SPOOL:RevertMaxCharge()
	if Mod:IsLegacyGameplayEnabled() then
		return 90
	end
end

Mod:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MAX_CHARGE, ARACHNAS_SPOOL.RevertMaxCharge, ARACHNAS_SPOOL.ID)

--#endregion
