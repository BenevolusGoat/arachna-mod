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

--#region Bitten status (Most already handled in Arachna's Spool code since they share many similarities)

function DIVINE_CLOTH:OnAddBite(ent)
	DIVINE_CLOTH:SpawnSwirl(ent.Position, ent)
end

StatusEffectLibrary.Callbacks.AddCallback(StatusEffectLibrary.Callbacks.ID.POST_ADD_ENTITY_STATUS_EFFECT,
	DIVINE_CLOTH.OnAddBite, DIVINE_CLOTH.STATUS_BITTEN)

---@param ent Entity
function DIVINE_CLOTH:OnNPCKill(ent)
	if StatusEffectLibrary:HasStatusEffect(ent, DIVINE_CLOTH.STATUS_BITTEN) then
		Mod:GetData(ent).QueueTimedSpiderEgg = true
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, DIVINE_CLOTH.OnNPCKill)

---@param npc EntityNPC
function DIVINE_CLOTH:OnNPCDeath(npc)
	if Mod:GetData(npc).QueueTimedSpiderEgg and not npc:IsBoss() then
		local egg = Mod.Entities.SPIDER_EGG:TrySpawnEgg(npc.Position, npc, Isaac.GetPlayer())
		if egg then
			egg:SetTimeout(Mod.Entities.SPIDER_EGG.MAX_EGG_TIMEOUT)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, DIVINE_CLOTH.OnNPCDeath)

--#endregion

--#region Legacy Charge Time

function DIVINE_CLOTH:RevertMaxCharge()
	if Mod:IsLegacyGameplayEnabled() then
		return 90
	end
end

Mod:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MAX_CHARGE, DIVINE_CLOTH.RevertMaxCharge, DIVINE_CLOTH.ID)

--#endregion