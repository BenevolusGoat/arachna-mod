--#region Variables

local Mod = ARACHNAMOD
local ARACHNAS_SPOOL = Mod.Item.ARACHNAS_SPOOL

local DIVINE_CLOTH = {}

ARACHNAMOD.Item.DIVINE_CLOTH = DIVINE_CLOTH

DIVINE_CLOTH.ID = Isaac.GetItemIdByName("Divine Cloth")
DIVINE_CLOTH.TEAR = Isaac.GetEntityVariantByName("Arachna Egg Tear")
DIVINE_CLOTH.ID_GRAB = Isaac.GetItemIdByName("Grab")

DIVINE_CLOTH.DIVINE_WEB_VAR = Isaac.GetEntityVariantByName("Divine Web")
DIVINE_CLOTH.DIVINE_WEB_SUB = Isaac.GetEntitySubTypeByName("Divine Web")

DIVINE_CLOTH.BITE_DURATION = 200
DIVINE_CLOTH.BITE_DURATION_BIRTHRIGHT = 250
DIVINE_CLOTH.TIMER_HEAL = 100
DIVINE_CLOTH.RADIUS_EXTENTION_BIRTHRIGHT = 30

local identifier = "ARACHNA_BITTEN"
local statusSprite = Sprite("gfx/indicator_arachna_b.anm2", false)
statusSprite:Play("Float")
DIVINE_CLOTH.STATUS_BITTEN_CONFIG = StatusEffectLibrary.RegisterStatusEffect(identifier, statusSprite, nil, EntityFlag.FLAG_SLOW, true)
DIVINE_CLOTH.STATUS_BITTEN = StatusEffectLibrary.StatusFlag[identifier]

---@param pos Vector
---@param vel Vector
---@param spawner? Entity
function DIVINE_CLOTH:FireEgg(pos, vel, spawner)
	Mod.sfxman:Play(SoundEffect.SOUND_TEARS_FIRE, 0, 2)
	local eggTear = Mod.Spawn.Tear(DIVINE_CLOTH.TEAR, pos, vel, nil, spawner)
	eggTear.CollisionDamage = 10
	eggTear.FallingSpeed = -5.5
	eggTear.FallingAcceleration = 0.5
	eggTear:GetSprite():Play("Stone5Move")
	Mod.sfxman:Play(SoundEffect.SOUND_FETUS_JUMP, 0.8)
	local player = spawner and spawner:ToPlayer()
	if player then
		local weapon = player:GetWeapon(1)
		local playerFlags = player:GetTearHitParams(weapon and weapon:GetWeaponType() or WeaponType.WEAPON_TEARS, 1, 1,
			eggTear).TearFlags
		for _, tearFlag in ipairs(ARACHNAS_SPOOL.INHERITED_TEAR_FLAGS) do
			if Mod:HasBitFlags(playerFlags, tearFlag) then
				eggTear:AddTearFlags(tearFlag)
			end
		end
		local data = Mod:GetData(player)
		if data.HeldEggColor then
			local tearData = Mod:GetData(eggTear)
			tearData.EggFlags = data.HeldEggFlags
			tearData.EggColor = data.HeldEggColor
			local color = Mod.Entities.SPIDER_EGG:GetEggColor(tearData.EggColor)
			if color then
				eggTear.Color = color
			end
			data.HeldEggFlags = nil
			data.HeldEggColor = nil
		end
	end
end

ThrowableItemLib:RegisterThrowableItem({
	ID = DIVINE_CLOTH.ID_GRAB,
	Type = ThrowableItemLib.Type.ACTIVE,
	Identifier = "Arachna Spider Eggs",
	Flags = ThrowableItemLib.Flag.DISABLE_HIDE | ThrowableItemLib.Flag.PERSISTENT,
	HoldCondition = function (player, config)
		local eggToRemove
		Mod.Foreach.EffectInRadius(player.Position, 90, function(egg, index)
			if egg:GetSprite():IsPlaying("Idle") then
				eggToRemove = egg
				return true
			end
		end, Mod.Entities.SPIDER_EGG.ID, nil, nil, true)
		if eggToRemove then
			Mod:GetData(player).QueuedEggLift = EntityPtr(eggToRemove)
			return ThrowableItemLib.HoldConditionReturnType.ALLOW_HOLD
		else
			return ThrowableItemLib.HoldConditionReturnType.DISABLE_USE
		end
	end,
	ThrowFn = function (player, vect, slot, mimic)
		DIVINE_CLOTH:FireEgg(player.Position, Mod:AddTearVelocity(vect, 12, player), player)
	end,
	LiftFn = function (player, continued, slot, mimic)
		local data = Mod:GetData(player)
		if not continued then
			local egg = data.QueuedEggLift and data.QueuedEggLift.Ref
			if not egg then return end
			local eggData = Mod:GetData(egg)
			data.HeldEggFlags = eggData.EggFlags
			data.HeldEggColor = egg.SubType
			egg:Remove()
		end
		local spiderColor = data.HeldEggColor
		local sprite = player:GetHeldSprite()
		sprite:Load("gfx/002.027_egg tear.anm2", true)
		sprite:Play("Stone5Idle")
		sprite.Offset = Vector(0, -10)
		local color = Mod.Entities.SPIDER_EGG:GetEggColor(spiderColor)
		if color then
			sprite.Color = color
		end
	end,
	AnimateFn = function (player, state)
		if state == ThrowableItemLib.State.THROW then
			player:AnimateCollectible(1, "HideItem")
			player:GetHeldSprite().Color.A = 0
			return true
		end
	end
})

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

local function legacyEggInteraction(pos, size)
	local shouldPlayGood = false

	Mod.Foreach.EffectInRadius(pos, size, function(egg, index)
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

---@param player EntityPlayer
function DIVINE_CLOTH:OnUse(itemId, rng, player, useFlags, slot, customBarData)
	local spriteSize = 1
	local size = 90
	local legacy = Mod:IsLegacyGameplayEnabled()

	if not legacy or Mod.Character.ARACHNA_B:ArachnaBHasBirthright(player) then
		if legacy then
			spriteSize = 1.2
			size = size + DIVINE_CLOTH.RADIUS_EXTENTION_BIRTHRIGHT
			legacyEggInteraction(player.Position, size)
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
	ARACHNAS_SPOOL:ApplyWebbed(npc, source, duration)
	return StatusEffectLibrary:AddStatusEffect(
		npc,
		DIVINE_CLOTH.STATUS_BITTEN,
		duration or DIVINE_CLOTH.BITE_DURATION,
		source,
		nil
	)
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
		DIVINE_CLOTH:ApplyBitten(npc, source, duration)
	end, nil, nil, { UseEnemySearchParams = true })

	if web:GetSprite():IsFinished("Poof") then
		web:Remove()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, DIVINE_CLOTH.BiteEnemiesInEffectRadius, DIVINE_CLOTH.DIVINE_WEB_VAR)

--#endregion

--#region Bitten status

function DIVINE_CLOTH:OverrideWebbedCountdown(ent)
	if StatusEffectLibrary:HasStatusEffect(ent, DIVINE_CLOTH.STATUS_BITTEN)
		and StatusEffectLibrary:HasStatusEffect(ent, ARACHNAS_SPOOL.STATUS_WEBBED)
	then
		local status_webbed = StatusEffectLibrary:GetStatusEffectData(ent, ARACHNAS_SPOOL.STATUS_WEBBED)
		local status_bitten = StatusEffectLibrary:GetStatusEffectData(ent, DIVINE_CLOTH.STATUS_BITTEN)
		---@cast status_webbed StatusEffectData
		---@cast status_bitten StatusEffectData
		status_webbed.Countdown = status_bitten.Countdown
		return true
	end
end

StatusEffectLibrary.Callbacks.AddPriorityCallback(StatusEffectLibrary.Callbacks.ID.PRE_ADD_ENTITY_STATUS_EFFECT, CallbackPriority.EARLY,
	DIVINE_CLOTH.OverrideWebbedCountdown, ARACHNAS_SPOOL.STATUS_WEBBED)

function DIVINE_CLOTH:PostAddBite(ent)
	DIVINE_CLOTH:SpawnSwirl(ent.Position, ent)
end

StatusEffectLibrary.Callbacks.AddCallback(StatusEffectLibrary.Callbacks.ID.POST_ADD_ENTITY_STATUS_EFFECT,
	DIVINE_CLOTH.PostAddBite, DIVINE_CLOTH.STATUS_BITTEN)

---@param ent Entity
function DIVINE_CLOTH:PostRemoveWebbed(ent)
	StatusEffectLibrary:RemoveStatusEffect(ent, DIVINE_CLOTH.STATUS_BITTEN)
end

StatusEffectLibrary.Callbacks.AddCallback(StatusEffectLibrary.Callbacks.ID.POST_REMOVE_ENTITY_STATUS_EFFECT,
	DIVINE_CLOTH.PostRemoveWebbed, ARACHNAS_SPOOL.STATUS_WEBBED)

--#endregion

--#region Throwable Eggs

---@param tear EntityTear
function DIVINE_CLOTH:OnEggDeath(tear)
	local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
	local poof = Mod.Spawn.Effect(EffectVariant.TEAR_POOF_A, 0, tear.Position)
	local data = Mod:TryGetData(tear)
	local poofColor = Color(0.5, 0.5, 0.5, 1, 0.5, 0.5, 0.5)

	poof.Color = Color(0.5, 0.5, 0.5, 1, 0.5, 0.5, 0.5)
	Mod.sfxman:Play(SoundEffect.SOUND_BOIL_HATCH)

	if player and data and data.EggColor then
		local color = Mod.Entities.SPIDER_EGG:GetEggColor(data.EggColor)
		local SPIDER_EGG = Mod.Entities.SPIDER_EGG
		local minSpiders, maxSpiders = SPIDER_EGG:GetSpiderCountRange(player, data.EggFlags)
		local rng = player:GetCollectibleRNG(DIVINE_CLOTH.ID)
		local spiderCount = Mod.math.ceil(rng:RandomInt(minSpiders, maxSpiders) / 2)
		Mod.Entities.SPIDER_EGG:SpawnSpiderBurst(player, tear.Position, spiderCount, nil, data.EggFlags, false, data.EggColor)
		if color then
			poofColor = color
		end
	end
	poof.Color = poofColor
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, DIVINE_CLOTH.OnEggDeath, DIVINE_CLOTH.TEAR)

--#endregion

--#region Legacy

function DIVINE_CLOTH:RevertMaxCharge()
	if Mod:IsLegacyGameplayEnabled() then
		return 90
	end
end

Mod:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MAX_CHARGE, DIVINE_CLOTH.RevertMaxCharge, DIVINE_CLOTH.ID)

--#endregion