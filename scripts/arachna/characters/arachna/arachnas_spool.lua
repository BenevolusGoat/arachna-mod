--#region Variables

local Mod = ARACHNAMOD

local ARACHNAS_SPOOL = {}

ARACHNAMOD.Item.ARACHNAS_SPOOL = ARACHNAS_SPOOL

ARACHNAS_SPOOL.ID = Isaac.GetItemIdByName("Arachna's Spool")

ARACHNAS_SPOOL.TEAR = Isaac.GetEntityVariantByName("Spool Tear")
ARACHNAS_SPOOL.WEB_EFFECT = Isaac.GetEntityVariantByName("Spider Web")

local identifier = "ARACHNA_WEBBED"
StatusEffectLibrary.RegisterStatusEffect(identifier, nil, nil, EntityFlag.FLAG_SLOW, true)
ARACHNAS_SPOOL.STATUS_WEBBED = StatusEffectLibrary.StatusFlag[identifier]

ARACHNAS_SPOOL.INHERITED_TEAR_FLAGS = {
	TearFlags.TEAR_SPECTRAL,
	TearFlags.TEAR_PIERCING
}

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
	Mod.sfxman:Play(SoundEffect.SOUND_FETUS_JUMP, 0.8, 0, false, 1)
	local player = spawner and spawner:ToPlayer()
	if player then
		local weapon = player:GetWeapon(1)
		local playerFlags = player:GetTearHitParams(weapon and weapon:GetWeaponType() or WeaponType.WEAPON_TEARS, 1, 1, spoolTear).TearFlags
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

--#endregion

--#region Arachna's Spool

ThrowableItemLib:RegisterThrowableItem({
	Type = ThrowableItemLib.Type.ACTIVE,
	ID = ARACHNAS_SPOOL.ID,
	Identifier = "Arachna",
	ThrowFn = function (player, vect, slot, mimic)
		ARACHNAS_SPOOL:FireSpool(player.Position, Mod:AddTearVelocity(vect, 12, player), player)
	end
})

---@param tear EntityTear
function ARACHNAS_SPOOL:OnTearUpdate(tear)
	if tear.FrameCount % 2 == 0 then
		local pos =  Vector(tear.Position.X, tear.Position.Y + 1.1 + tear.Height)
		local trail = Mod.Spawn.Effect(EffectVariant.HAEMO_TRAIL, 0, pos, nil, tear)
		trail:GetSprite().Color = Color(1,1,1,1,1,1,1)
		trail:Update()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, ARACHNAS_SPOOL.OnTearUpdate, ARACHNAS_SPOOL.TEAR)

---@param tear EntityTear
function ARACHNAS_SPOOL:OnTearDeath(tear)
	Mod.sfxman:Play(SoundEffect.SOUND_WOOD_PLANK_BREAK, 1, 7, false, 3)
	Mod.sfxman:Play(SoundEffect.SOUND_SUMMON_POOF, 0.8, 1, false, 1)
	Mod.Game:SpawnParticles(tear.Position, EffectVariant.WOOD_PARTICLE, Mod:RandomNum(5, 10), 4)
	local maxWebCount = 1
	local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
	if player and Mod.Character.ARACHNA:ArachnaHasBirthright(player) then
		maxWebCount = 2
	end
	local ownedWebs = {}
	Mod.Foreach.Effect(function (web, index)
		if web.SpawnerEntity and Mod:IsSameEntity(web.SpawnerEntity, tear.SpawnerEntity) then
			Mod.Insert(ownedWebs, web)
		end
	end, ARACHNAS_SPOOL.WEB_EFFECT)
	--Oldest webs get removed first
	table.sort(ownedWebs, function (web1, web2)
		return web1.FrameCount > web2.FrameCount
	end)

	while (#ownedWebs >= maxWebCount) do
		local ent = ownedWebs[1]
		ent:GetSprite():Play("Remove")
		table.remove(ownedWebs, 1)
	end
	ARACHNAS_SPOOL:SpawnWeb(tear.Position, tear.SpawnerEntity)
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, ARACHNAS_SPOOL.OnTearDeath, ARACHNAS_SPOOL.TEAR)

--#endregion

--#region Spider Web

---@param web EntityEffect
function ARACHNAS_SPOOL:OnWebInit(web)
	local rng = web:GetDropRNG()
	local sprite = web:GetSprite()
	sprite:ReplaceSpritesheet(0, "gfx/backdrop/web_" .. tostring(rng:RandomInt(4) + 1) .. ".png", true)
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
	Mod.Foreach.NPCInRadius(web.Position, web.Size, function (npc, index)
		if not StatusEffectLibrary:HasStatusEffect(npc, Mod.Item.DIVINE_CLOTH.STATUS_BITTEN) then
			ARACHNAS_SPOOL:ApplyWebbed(npc, source, 2)
			npc:AddSlowing(source, 2, 0.5, StatusEffectLibrary.StatusColor.SLOW)
		end
	end, nil, nil, {UseEnemySearchParams = true, Dead = true})
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, ARACHNAS_SPOOL.OnWebUpdate, ARACHNAS_SPOOL.WEB_EFFECT)

--#endregion

--#region Webbed status

---@param npc EntityNPC
---@param source EntityRef
---@param duration integer
function ARACHNAS_SPOOL:ApplyWebbed(npc, source, duration)
	StatusEffectLibrary:AddStatusEffect(npc, ARACHNAS_SPOOL.STATUS_WEBBED, duration, source)
end

---@param npc EntityNPC
function ARACHNAS_SPOOL:ShouldSpawnWebOnEnemyDeath(npc)
	return not npc:IsBoss()
		and npc.SpawnerType == 0
		and npc.MaxHitPoints >= 10
		and not npc:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN)
end

---@param ent Entity
---@param statusEffect StatusFlag
---@param customData table
function ARACHNAS_SPOOL:PreAddWeb(ent, statusEffect, customData)
	local npc = ent:ToNPC()
	if not npc or not ARACHNAS_SPOOL:ShouldSpawnWebOnEnemyDeath(npc) then
		return true
	end
end

StatusEffectLibrary.Callbacks.AddCallback(StatusEffectLibrary.Callbacks.ID.PRE_ADD_ENTITY_STATUS_EFFECT, ARACHNAS_SPOOL.PreAddWeb, ARACHNAS_SPOOL.STATUS_WEBBED)

---We want this on POST_NPC_DEATH but StatusEffectLibrary (yes the library I coded) removes all status effect data when an entity is removed, like it should.
---
---Save the information that the enemy has the status effect to our own custom data which does save for POST_NPC_DEATH.
---@param ent Entity
function ARACHNAS_SPOOL:OnNPCKill(ent)
	if StatusEffectLibrary:HasStatusEffect(ent, ARACHNAS_SPOOL.STATUS_WEBBED) then
		Mod:GetData(ent).QueueSpiderEgg = true
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, ARACHNAS_SPOOL.OnNPCKill)

---@param npc EntityNPC
function ARACHNAS_SPOOL:OnNPCDeath(npc)
	if Mod:GetData(npc).QueueSpiderEgg then
		Mod.Entities.SPIDER_EGG:SpawnEgg(npc.Position, npc)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, ARACHNAS_SPOOL.OnNPCDeath)

--#endregion