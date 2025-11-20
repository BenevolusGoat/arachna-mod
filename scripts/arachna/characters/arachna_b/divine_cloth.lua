--#region Variables

local Mod = ARACHNAMOD

local DIVINE_CLOTH = {}

ARACHNAMOD.Item.DIVINE_CLOTH = DIVINE_CLOTH

DIVINE_CLOTH.ID = Isaac.GetItemIdByName("Divine Cloth")

DIVINE_CLOTH.DIVINE_WEB_VAR = Isaac.GetEntityVariantByName("Divine Web")
DIVINE_CLOTH.DIVINE_WEB_SUB = Isaac.GetEntitySubTypeByName("Divine Web")

DIVINE_CLOTH.BITE_DURATION = 200
DIVINE_CLOTH.BITE_DURATION_BIRTHRIGHT = 250
DIVINE_CLOTH.TIMER_HEAL = 100
DIVINE_CLOTH.RADIUS_EXTENTION_BIRTHRIGHT = 30

local identifier = "ARACHNA_BITTEN"
local statusSprite = Sprite("gfx/indicator_arachna_b.anm2", false)
statusSprite:Play("Float")
DIVINE_CLOTH.STATUS_BITTEN_CONFIG = StatusEffectLibrary.RegisterStatusEffect(identifier, statusSprite,
	StatusEffectLibrary.StatusColor.SLOW, EntityFlag.FLAG_SLOW, true)
DIVINE_CLOTH.STATUS_BITTEN = StatusEffectLibrary.StatusFlag[identifier]

--#endregion

--#region Helpers

---@param pos Vector
---@param spawner? Entity
function DIVINE_CLOTH:SpawnSwirl(pos, spawner)
	local swirl = Mod.Spawn.Poof02(0, pos, spawner)
	swirl:GetSprite():Load("gfx/effect_webpoof.anm2", true)
	swirl:GetSprite():Play("Poof")
	swirl.SpriteScale = swirl.SpriteScale * 0.8
	return swirl
end

--#endregion

--#region On Use

---@param player EntityPlayer
function DIVINE_CLOTH:OnUse(itemId, rng, player, useFlags, slot, customBarData)
	local spriteSize = 1
	local size = 90

	if Mod.Character.ARACHNA_B:ArachnaBHasBirthright(player) then
		spriteSize = 1.2
		size = size + DIVINE_CLOTH.RADIUS_EXTENTION_BIRTHRIGHT
		local shouldPlayGood = false

		Mod.Foreach.EffectInRadius(player.Position, size, function(egg, index)
			shouldPlayGood = true
			if egg.Timeout > 0 then
				egg:SetTimeout(Mod.math.min(Mod.Entities.SPIDER_EGG.MAX_EGG_TIMEOUT,
					egg.Timeout + DIVINE_CLOTH.TIMER_HEAL))
			end
			Mod.Spawn.Notification(egg.Position, 0)
		end, Mod.Entities.SPIDER_EGG.ID, nil, nil, true)

		if shouldPlayGood then
			Mod.sfxman:Play(SoundEffect.SOUND_THUMBSUP, 0.8)
		end
	end
	Mod.Game:ShakeScreen(8)
	DIVINE_CLOTH:SpawnSwirl(player.Position, player)

	local floorWeb = Mod.Spawn.Effect(DIVINE_CLOTH.DIVINE_WEB_VAR, DIVINE_CLOTH.DIVINE_WEB_SUB, player.Position, nil,
		player)
	floorWeb.Color = Color(1, 1, 1, 0.45, 0, 0, 0)
	floorWeb.SpriteScale = floorWeb.SpriteScale * spriteSize
	floorWeb:SetSize(size, Vector.One, 8)

	Mod.sfxman:Play(SoundEffect.SOUND_SPIDER_SPIT_ROAR, 0.8)
	Mod.sfxman:Play(SoundEffect.SOUND_FETUS_JUMP, 0.8)
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, DIVINE_CLOTH.OnUse, DIVINE_CLOTH.ID)

--#endregion

--#region Apply Bitten

---@param npc EntityNPC
---@param source EntityRef
---@param duration? integer @default: `DIVINE_CLOTH.BITE_DURATION`
function DIVINE_CLOTH:ApplyBitten(npc, source, duration)
	return StatusEffectLibrary:AddStatusEffect(npc, DIVINE_CLOTH.STATUS_BITTEN, duration or DIVINE_CLOTH.BITE_DURATION,
		source, nil)
end

---@param web EntityEffect
function DIVINE_CLOTH:BiteEnemiesInEffectRadius(web)
	if web.SubType ~= DIVINE_CLOTH.DIVINE_WEB_SUB then
		return
	end
	local duration = DIVINE_CLOTH.BITE_DURATION
	local player = web.SpawnerEntity and web.SpawnerEntity:ToPlayer()
	local source = player and EntityRef(player) or EntityRef(web)

	Mod.Foreach.NPCInRadius(web.Position, web.Size, function(npc, index)
		if not StatusEffectLibrary:HasStatusEffect(npc, DIVINE_CLOTH.STATUS_BITTEN) then
			DIVINE_CLOTH:ApplyBitten(npc, source, duration)
		end
	end, nil, nil, { UseEnemySearchParams = true })

	if web:GetSprite():IsFinished("Poof") then
		web:Remove()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, DIVINE_CLOTH.BiteEnemiesInEffectRadius, DIVINE_CLOTH.DIVINE_WEB_VAR)

--#endregion

--#region Bitten status

function DIVINE_CLOTH:OnAddBite(ent)
	DIVINE_CLOTH:SpawnSwirl(ent.Position, ent)
end

StatusEffectLibrary.Callbacks.AddCallback(StatusEffectLibrary.Callbacks.ID.POST_ADD_ENTITY_STATUS_EFFECT,
	DIVINE_CLOTH.OnAddBite, DIVINE_CLOTH.STATUS_BITTEN)

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function DIVINE_CLOTH:LastBittenCredit(ent, amount, flags, source, countdown)
	if StatusEffectLibrary:HasStatusEffect(ent, DIVINE_CLOTH.STATUS_BITTEN) then
		local player = Mod:TryGetPlayer(source, {LoopSpawnerEnt = true})
		if player then
			Mod:GetData(ent).BittenKillCredit = EntityPtr(player)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, DIVINE_CLOTH.LastBittenCredit)

---We want this on POST_NPC_DEATH but StatusEffectLibrary (yes the library I coded) removes all status effect data when an entity is removed, like it should.
---
---Save the information that the enemy has the status effect to our own custom data which does save for POST_NPC_DEATH.
---@param ent Entity
---@param source EntityRef
function DIVINE_CLOTH:OnNPCKill(ent, source)
	local isLegacy = ARACHNAMOD:IsLegacyGameplayEnabled()
	if StatusEffectLibrary:HasStatusEffect(ent, DIVINE_CLOTH.STATUS_BITTEN) then
		if ent:IsBoss() and isLegacy then
			return
		end
		Mod:GetData(ent).QueueTimedSpiderEgg = source
		if ent:HasEntityFlags(EntityFlag.FLAG_ICE) then
			Mod:GetData(ent).WebbedOverrideHitPoints = ent.MaxHitPoints
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, DIVINE_CLOTH.OnNPCKill)

---@param npc EntityNPC
function DIVINE_CLOTH:OnNPCDeath(npc)
	if Mod:GetData(npc).QueueTimedSpiderEgg then
		if npc:IsBoss() and Isaac.CountBosses() == 1 and Mod:SomeoneIsArachna() then
			Mod.Foreach.Pickup(function(heart, index)
				if heart.SpawnerType == npc.Type and heart.FrameCount == 0 then
					local newSubtype = heart.SubType == HeartSubType.HEART_DOUBLEPACK and Mod.Pickup.WEB_HEART.ID_DOUBLE or
					Mod.Pickup.WEB_HEART.ID
					heart:Morph(heart.Type, heart.Variant, newSubtype, true, true, true)
				end
			end, PickupVariant.PICKUP_HEART)
		end
		local SPIDER_EGG = Mod.Entities.SPIDER_EGG
		local entityPtr = Mod:GetData(npc).BittenKillCredit
		local player = entityPtr and entityPtr.Ref and entityPtr.Ref:ToPlayer()
		local eggSubtype = SPIDER_EGG.EggSubtype.NORMAL
		if npc:IsBoss() then
			if npc.Parent or npc.Child then
				eggSubtype = SPIDER_EGG.EggSubtype.SMALL
			else
				eggSubtype = SPIDER_EGG.EggSubtype.BOSS
			end
		end
		local egg = SPIDER_EGG:TrySpawnEgg(npc.Position, npc, player, eggSubtype)
		if egg and egg.SubType == SPIDER_EGG.EggSubtype.NORMAL then
			egg:SetTimeout(SPIDER_EGG.MAX_EGG_TIMEOUT)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, DIVINE_CLOTH.OnNPCDeath)

---@param ent Entity
function DIVINE_CLOTH:BittenUpdate(ent)
	local speed = ent:IsBoss() and 0.75 or 0.5
	if ent:GetSpeedMultiplier() < speed then return end
	ent:SetSpeedMultiplier(speed)
end

StatusEffectLibrary.Callbacks.AddCallback(StatusEffectLibrary.Callbacks.ID.ENTITY_STATUS_EFFECT_UPDATE,
	DIVINE_CLOTH.BittenUpdate, DIVINE_CLOTH.STATUS_BITTEN)

--#endregion

--#region Legacy Charge Time

function DIVINE_CLOTH:RevertMaxCharge()
	if Mod:IsLegacyGameplayEnabled() then
		return 90
	end
end

Mod:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MAX_CHARGE, DIVINE_CLOTH.RevertMaxCharge, DIVINE_CLOTH.ID)

--#endregion