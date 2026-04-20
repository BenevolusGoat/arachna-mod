--#region Variables

local Mod = ArachnaMod
local ARACHNAS_SPOOL = Mod.Item.ARACHNAS_SPOOL

local DIVINE_CLOTH = {}

ArachnaMod.Item.DIVINE_CLOTH = DIVINE_CLOTH

DIVINE_CLOTH.ID = Isaac.GetItemIdByName("Divine Cloth")

DIVINE_CLOTH.DIVINE_WEB_VAR = Isaac.GetEntityVariantByName("Divine Web")
DIVINE_CLOTH.DIVINE_WEB_SUB = Isaac.GetEntitySubTypeByName("Divine Web")

DIVINE_CLOTH.BITE_DURATION = 200
DIVINE_CLOTH.RADIUS = 120

local identifier = "ARACHNA_BITTEN"
local statusSprite = Sprite("gfx/indicator_arachna_b.anm2", false)
statusSprite:Play("Float")
DIVINE_CLOTH.STATUS_BITTEN_CONFIG = StatusEffectLibrary.RegisterStatusEffect(identifier, statusSprite, nil,
	EntityFlag.FLAG_SLOW, true)
DIVINE_CLOTH.STATUS_BITTEN = StatusEffectLibrary.StatusFlag[identifier]

--#endregion

--#region Helpers

local function setJudasColor(sprite)
	local layer = sprite:GetLayer(0)
	if not layer then
		return
	end
	layer:GetBlendMode():SetMode(BlendType.ADDITIVE)

	local color = layer:GetColor()
	color:Reset()
	color:SetTint(5.0, 0.5, 0.2, 1.0)
	layer:SetColor(color)
end

---@param pos Vector
---@param spawner? Entity
function DIVINE_CLOTH:SpawnSwirl(pos, spawner)
	local swirl = Mod.Spawn.Poof02(0, pos, spawner)
	swirl:GetSprite():Load("gfx/effect_webpoof.anm2", true)
	swirl:GetSprite():Play("Poof")
	swirl.SpriteScale = swirl.SpriteScale * 0.8
	if spawner and not Mod:IsLegacyGameplayEnabled() then
		swirl.Parent = spawner
		swirl:FollowParent(spawner)
	end
	local player = spawner and spawner:ToPlayer()
	if player and Mod:IsJudasBirthrightActive(player) then
		setJudasColor(swirl:GetSprite())
	end
	return swirl
end

--#endregion

--#region On Use

local function legacyEggInteraction(pos, size)
	local shouldPlayGood = false

	Mod.Foreach.EffectInRadius(pos, size, function(egg, index)
		shouldPlayGood = true
		if egg.Timeout > 0 then
			egg:SetTimeout(Mod.math.min(Mod.Entities.SPIDER_EGG.LEGACY_EGG_TIMEOUT,
				egg.Timeout + 100))
		end
		Mod.Spawn.Notification(egg.Position, 0)
	end, Mod.Entities.SPIDER_EGG.ID, nil, nil, true)

	if shouldPlayGood then
		Mod.sfxman:Play(SoundEffect.SOUND_THUMBSUP, 0.8)
	end
end

---@param player EntityPlayer
function DIVINE_CLOTH:OnUse(itemId, rng, player, useFlags, slot, customBarData)
	local legacy = Mod:IsLegacyGameplayEnabled()
	local spriteSize = legacy and 1 or 1.25
	local size = legacy and 90 or DIVINE_CLOTH.RADIUS

	if legacy and Mod.Character.ARACHNA_B:ArachnaBHasBirthright(player) then
		spriteSize = 1.2
		size = 120
		legacyEggInteraction(player.Position, size)
	end
	Mod.Game:ShakeScreen(8)
	DIVINE_CLOTH:SpawnSwirl(player.Position, player)

	local floorWeb = Mod.Spawn.Effect(DIVINE_CLOTH.DIVINE_WEB_VAR, DIVINE_CLOTH.DIVINE_WEB_SUB, player.Position, nil,
		player)
	if Mod:IsJudasBirthrightActive(player) then
		Mod.Spawn.JudasBelialFlamePillar(player.Position, player)
		Mod.Spawn.JudasBelialPoof(player, 1)
		setJudasColor(floorWeb:GetSprite())
		Mod.sfxman:Play(SoundEffect.SOUND_CANDLE_LIGHT)
	else
		floorWeb.Color = Color(1, 1, 1, 0.45)
	end
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

	if web:GetSprite():IsFinished("Poof") then
		web:Remove()
	end

	if not player then return end

	if Mod:IsLegacyGameplayEnabled() and Mod.Character.ARACHNA_B:ArachnaBHasBirthright(player) then
		duration = 250
	end
	local source = EntityRef(player)
	local data = Mod:GetData(web)
	data.HitList = data.HitList or {}

	Mod.Foreach.NPCInRadius(web.Position, web.Size, function(npc, index)
		local ptrHash = GetPtrHash(npc)
		if not data.HitList[ptrHash] then
			local damage = player.Damage * 0.5
			data.HitList[ptrHash] = true
			npc:TakeDamage(damage, 0, source, 0)
			if Mod:IsJudasBirthrightActive(player) then
				npc:AddBurn(source, 150, player.Damage)
			end
		end
		DIVINE_CLOTH:ApplyBitten(npc, source, duration)
	end, nil, nil, { UseEnemySearchParams = true })
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

StatusEffectLibrary.Callbacks.AddPriorityCallback(StatusEffectLibrary.Callbacks.ID.PRE_ADD_ENTITY_STATUS_EFFECT,
	CallbackPriority.EARLY,
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

--#region Legacy

function DIVINE_CLOTH:RevertMaxCharge()
	if Mod:IsLegacyGameplayEnabled() then
		return 90
	end
end

Mod:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MAX_CHARGE, DIVINE_CLOTH.RevertMaxCharge, DIVINE_CLOTH.ID)

--#endregion
