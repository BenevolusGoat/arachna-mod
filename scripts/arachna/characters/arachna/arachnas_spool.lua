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

ARACHNAS_SPOOL.BOSS_CHARGE_DMG_THRESHOLD = 50
ARACHNAS_SPOOL.BOSS_CHARGE_DMG_STAGE = 5

local SIZE_THRESHOLDS = {
	20,
	40,
	100
}

ARACHNAS_SPOOL.WEB_SPRITE_OFFSET = {
	[tostring(EntityType.ENTITY_BEAST) .. ".0.0"] = 70,
	[tostring(EntityType.ENTITY_HUSH) .. ".0.0"] = 30,
}

--#endregion

--#region Helpers

---@param pos Vector
---@param vel Vector
---@param spawner? Entity
function ARACHNAS_SPOOL:FireSpool(pos, vel, spawner)
	local spoolTear = Mod.Spawn.Tear(ARACHNAS_SPOOL.TEAR, pos, vel, nil, spawner)
	spoolTear.CollisionDamage = 4.2
	spoolTear.FallingSpeed = -5.5
	spoolTear.FallingAcceleration = 0.5
	if Mod:IsLegacyGameplayEnabled() then
		spoolTear:SetSize(8, Vector.One, 8)
	end
	local player = spawner and spawner:ToPlayer()
	if player and Mod:IsJudasBirthrightActive(player) then
		spoolTear:AddTearFlags(TearFlags.TEAR_BURN)
		spoolTear:Update()
		local color = spoolTear.Color
		color:SetColorize(2, 0.25, 0, 1)
		spoolTear.Color = color
		Mod:GetData(spoolTear).JudasBirthright = true
	end
end

---@param pos Vector
---@param spawner? Entity
---@param color? ColoredSpiderSubtype
function ARACHNAS_SPOOL:SpawnWeb(pos, spawner, color)
	return Mod.Spawn.Effect(ARACHNAS_SPOOL.WEB_EFFECT, color or 0, pos, nil, spawner)
end

---How much damage is required in order to fill the chargebar on a boss to spawn a Spider Egg
---...this is literally just the Stage HP formula don't @ me
function ARACHNAS_SPOOL:GetBossChargeDamageThreshold()
	local stage = Mod.Level():GetStage()
	local stageModifier = Mod.math.min(4, stage) + 0.8 * stage
	return ARACHNAS_SPOOL.BOSS_CHARGE_DMG_THRESHOLD + stageModifier * ARACHNAS_SPOOL.BOSS_CHARGE_DMG_STAGE
end

---@param npc EntityNPC
---@param source EntityRef
---@param duration? integer
function ARACHNAS_SPOOL:ApplyWebbed(npc, source, duration)
	return StatusEffectLibrary:AddStatusEffect(npc, ARACHNAS_SPOOL.STATUS_WEBBED, duration or 2, source, nil,
		{ OriginalMass = npc.Mass })
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
function ARACHNAS_SPOOL:OnTearInit(tear)
	tear:SetInitSound(SoundEffect.SOUND_FETUS_JUMP)
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, ARACHNAS_SPOOL.OnTearInit, ARACHNAS_SPOOL.TEAR)

---@param tear EntityTear
function ARACHNAS_SPOOL:OnTearUpdate(tear)
	if Mod:IsLegacyGameplayEnabled() then
		tear:SetSize(8, Vector.One, 8)
	end
	if tear.FrameCount % 2 == 0 then
		local pos = Vector(tear.Position.X, tear.Position.Y + 1.1 + tear.Height)
		if Mod:GetData(tear).JudasBirthright then
			Mod.Spawn.JudasBelialFlame(pos, nil, tear)
		else
			local trail = Mod.Spawn.Effect(EffectVariant.HAEMO_TRAIL, 0, pos, nil, tear)
			trail:GetSprite().Color = Color(1, 1, 1, 1, 1, 1, 1)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, ARACHNAS_SPOOL.OnTearUpdate, ARACHNAS_SPOOL.TEAR)

---@param tear EntityTear
function ARACHNAS_SPOOL:OnSpoolDeath(tear)
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
		if web.SpawnerEntity
			and Mod:IsSameEntity(web.SpawnerEntity, tear.SpawnerEntity)
			and not Mod:GetData(web).ArachnaBBirthright
		then
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
	local web = ARACHNAS_SPOOL:SpawnWeb(fixedPos, tear.SpawnerEntity)
	if Mod:GetData(tear).JudasBirthright then
		Mod:GetData(web).JudasBirthright = true
		web.Color = tear.Color
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, ARACHNAS_SPOOL.OnSpoolDeath, ARACHNAS_SPOOL.TEAR)

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
	local color = Mod.Entities.SPIDER_EGG:GetEggColor(web.SubType)
	if color then
		web.Color = color
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, ARACHNAS_SPOOL.OnWebInit, ARACHNAS_SPOOL.WEB_EFFECT)

---@param web EntityEffect
---@param npc EntityNPC
---@param source EntityRef
function ARACHNAS_SPOOL:UniqueWebEffects(web, npc, source)
	local SpiderSubType = Mod.Entities.COLORED_SPIDERS.SpiderSubtype
	local damage = source.Entity and source.Entity:ToPlayer() and source.Entity:ToPlayer().Damage or 3.5
	if Mod:GetData(web).JudasBirthright or web.SubType == SpiderSubType.WRATH then
		npc:AddBurn(source, 30, damage)
	end
	if web.SubType == SpiderSubType.PESTILENCE then
		npc:AddPoison(source, 30, damage)
	elseif web.SubType == SpiderSubType.FAMINE then
		npc.Velocity = npc.Velocity * 0.5
	elseif web.SubType == SpiderSubType.DEATH then
		if npc.FrameCount % 2 == 0 then
			npc:TakeDamage(1, 0, source, 0)
		end
		if npc:HasMortalDamage() and not npc:IsDead() then
			Mod.Spawn.Familiar(FamiliarVariant.BONE_SPUR, 0, npc.Position, nil, source.Entity, npc.DropSeed)
		end
	elseif web.SubType == SpiderSubType.GOLDEN and npc:HasMortalDamage() and not npc:IsDead() then
		for _ = 1, 2 do
			local rng = npc:GetDropRNG()
			local coin = Mod.Spawn.Coin(NullPickupSubType.ANY, source.Position, EntityPickup.GetRandomPickupVelocity(source.Position, rng),
				npc, rng:Next())
			coin.Timeout = 60
		end
	elseif web.SubType == SpiderSubType.LOVE and npc:HasMortalDamage() and not npc:IsBoss() then
		npc:SetDead(false)
		npc.HitPoints = npc.MaxHitPoints
		npc:AddCharmed(source, -1)
		local poof = Mod.Spawn.Poof01(0, npc.Position, source.Entity)
		poof.Color = web:GetSprite().Color
	elseif web.SubType == SpiderSubType.ICE then
		npc:AddIce(source, 30)
	elseif web.SubType == SpiderSubType.RAINBOW then
		if npc:IsBoss() then
			if npc:GetWeaknessCountdown() == 0 then
				npc:AddWeakness(source, 2)
			else
				npc:SetWeaknessCountdown(npc:GetWeaknessCountdown() + 1)
			end
		elseif not npc:IsDead() then
			Mod.Entities.COLORED_SPIDERS:SpawnRainbowFart(npc.Position, web:GetSprite().Color)
			npc:Die()
		end
	end
end

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
	local COLORED_SPIDERS = Mod.Entities.COLORED_SPIDERS
	if web.SubType == COLORED_SPIDERS.SpiderSubtype.RAINBOW then
		local r, g, b = table.unpack(COLORED_SPIDERS:GetRainbowColor())
		web:GetSprite().Color:SetColorize(r, g, b, 0.5)
	elseif web.SubType == COLORED_SPIDERS.SpiderSubtype.GOLDEN then
		if web.FrameCount % 2 == 0 then
			local variance = Vector(Mod:RandomNum(-web.Size, web.Size), Mod:RandomNum(-web.Size, web.Size))
			COLORED_SPIDERS:SpawnSparkle(web.Position + variance)
		end
	end
	Mod.Foreach.NPCInRadius(web.Position, web.Size, function(npc, index)
		local grid = room:GetGridEntityFromPos(npc.Position)
		if grid and grid:ToPit() and not Mod:IsLegacyGameplayEnabled() then
			return
		end
		ARACHNAS_SPOOL:ApplyWebbed(npc, source, 2)
		ARACHNAS_SPOOL:UniqueWebEffects(web, npc, source)
	end, nil, nil, { UseEnemySearchParams = true, Dead = true })
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, ARACHNAS_SPOOL.OnWebUpdate, ARACHNAS_SPOOL.WEB_EFFECT)

--#endregion

--#region Pre/Post Add Webbed

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
function ARACHNAS_SPOOL:PreAddWeb(ent)
	local npc = ent:ToNPC()
	if not npc or not ARACHNAS_SPOOL:ShouldReceiveStatusEffect(npc) then
		return true
	end
end

StatusEffectLibrary.Callbacks.AddCallback(StatusEffectLibrary.Callbacks.ID.PRE_ADD_ENTITY_STATUS_EFFECT,
	ARACHNAS_SPOOL.PreAddWeb, ARACHNAS_SPOOL.STATUS_WEBBED)

local function updateWebbedScale(sprite, ent, data)
	local scale = 1
	for i, size in ipairs(SIZE_THRESHOLDS) do
		if ent.Size >= size then
			scale = i
		end
	end
	sprite:Play("Idle" .. scale)
	local offset = Vector.Zero
	local entString
	local deli = ent:ToDelirium()
	if deli then
		entString = tostring(deli.BossType) .. "." .. tostring(deli.BossVariant) .. ".0"
	else
		entString = Mod:TypeVarSubToString(ent)
	end
	local entOffset = ARACHNAS_SPOOL.WEB_SPRITE_OFFSET[entString]
	if entOffset then
		offset = Vector(0, entOffset)
	end
	data.WebbedOffset = offset
	data.WebbedScale = scale
end

---@param ent Entity
---@param statusEffectData StatusEffectData
function ARACHNAS_SPOOL:PostAddWeb(ent, _, statusEffectData)
	local data = Mod:GetData(ent)
	local sprite = Sprite("gfx/indicator_webbed.anm2", true)
	updateWebbedScale(sprite, ent, data)
	data.WebbedStatusSprite = sprite
	if not Mod:IsLegacyGameplayEnabled() then
		ent.Mass = statusEffectData.CustomData.OriginalMass * 2
	end
end

StatusEffectLibrary.Callbacks.AddCallback(StatusEffectLibrary.Callbacks.ID.POST_ADD_ENTITY_STATUS_EFFECT,
	ARACHNAS_SPOOL.PostAddWeb, ARACHNAS_SPOOL.STATUS_WEBBED)

---@param npc EntityNPC
function ARACHNAS_SPOOL:NPCMorph(npc)
	local data = Mod:TryGetData(npc)
	if data and data.WebbedStatusSprite then
		updateWebbedScale(data.WebbedStatusSprite, npc, data)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_MORPH, ARACHNAS_SPOOL.NPCMorph)
Mod:AddCallback(DeliriumCallbacks.POST_TRANSFORMATION, ARACHNAS_SPOOL.NPCMorph)

--#endregion

--#region Webbed Boss Chargebar

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function ARACHNAS_SPOOL:BossChargebar(ent, amount, flags, source, countdown)
	if Mod:IsLegacyGameplayEnabled() then
		return
	end
	local npc = ent:ToNPC()
	if npc and npc:IsBoss() then
		local hasWebbed = StatusEffectLibrary:HasStatusEffect(npc, ARACHNAS_SPOOL.STATUS_WEBBED)
		if not hasWebbed then
			return
		end
		local parent = StatusEffectLibrary.Utils.GetLastParent(npc)
		if GetPtrHash(parent) ~= GetPtrHash(npc)
			or (
				source.Type == EntityType.ENTITY_FAMILIAR
				and source.Variant == FamiliarVariant.BLUE_SPIDER
			) then
			return
		end
		local player = Mod:TryGetPlayer(source, { LoopSpawnerEnt = true })
		if not player then return end
		local data = Mod:GetData(parent)
		if not data.SpiderBossChargeSprite then
			data.SpiderBossChargeSprite = Sprite("gfx/ui_arachna_chargebar_boss.anm2", true)
		end
		if not data.SpiderBossChargeDMGNeeded then
			data.SpiderBossChargeDMGNeeded = ARACHNAS_SPOOL:GetBossChargeDamageThreshold()
		end
		if Mod:HasBitFlags(flags, DamageFlag.DAMAGE_EXPLOSION) then
			amount = amount / 2
		end
		local armor = npc:GetShieldStrength()
		if armor > 0 then
			--damage per hit
			local dph = npc.MaxHitPoints / armor / 4
			amount = Mod.math.min(amount, dph)
		end
		Mod:DebugLog("Boss Egg Progress:", "Room Frame", Mod.Room():GetFrameCount(), "Charge",
			"+" .. Mod.math.floor((amount / data.SpiderBossChargeDMGNeeded) * 100) .. "%")
		data.SpiderBossCharge = (data.SpiderBossCharge or 0) + amount

		if data.SpiderBossCharge > data.SpiderBossChargeDMGNeeded then
			if StatusEffectLibrary:HasStatusEffect(npc, Mod.Item.DIVINE_CLOTH.STATUS_BITTEN) then
				local dist = player.Position:Distance(npc.Position)
				local vel = (player.Position - npc.Position):Resized(Mod.math.floor(dist / 20)):Rotated(Mod:RandomNum(
				-45, 45))
				local tear = Mod.Item.EGG_TOSS:FireEgg(npc.Position, vel, player, npc)
				tear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			else
				local rng = ent:GetDropRNG()
				local spiderCount = Mod.Entities.SPIDER_EGG:GetSpiderCount(player, rng)
				local dist = npc.Size + 80
				Mod.Entities.SPIDER_EGG:SpawnSpiderBurst(player, npc.Position, spiderCount, dist, nil, true)
			end
			data.SpiderBossCharge = 0
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, ARACHNAS_SPOOL.BossChargebar)

---@param npc EntityNPC
---@param offset Vector
function ARACHNAS_SPOOL:RenderBossCharge(npc, offset)
	local data = Mod:TryGetData(npc)
	local hasWebbed = StatusEffectLibrary:HasStatusEffect(npc, ARACHNAS_SPOOL.STATUS_WEBBED)
	local renderPos = Mod:GetEntityRenderPosition(npc, offset)

	if hasWebbed and data and data.WebbedStatusSprite then
		---@type Sprite
		local sprite = data.WebbedStatusSprite
		local scale = data.WebbedScale
		sprite.Scale = (npc.Size / (SIZE_THRESHOLDS[scale] - (5 * scale))) * npc.SpriteScale
		sprite:Render(renderPos + data.WebbedOffset)
		if Mod:ShouldUpdateSprite() then
			sprite:Update()
		end
	end
	if data
		and data.SpiderBossCharge
		and data.SpiderBossCharge > 0
		and data.SpiderBossChargeSprite
		and data.SpiderBossChargeDMGNeeded
	then
		local nullFrame = npc:GetSprite():GetNullFrame("OverlayEffect")
		if nullFrame and nullFrame:IsVisible() then
			renderPos = renderPos + nullFrame:GetPos() + Vector(15, 10)
			local progress = data.SpiderBossCharge / data.SpiderBossChargeDMGNeeded
			local percent = Mod.math.floor(progress * 100)
			local frameNum = Mod:Clamp(percent - 1, 0, 99)
			data.SpiderBossChargeSprite.Color.A = Mod:Lerp(data.SpiderBossChargeSprite.Color.A, hasWebbed and 1 or 0.5,
				0.2)
			data.SpiderBossChargeSprite:SetFrame("Charging", frameNum)
			data.SpiderBossChargeSprite:Render(renderPos)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, ARACHNAS_SPOOL.RenderBossCharge)

--#endregion

--#region Webbed Update/On Death

---We want this on POST_NPC_DEATH but StatusEffectLibrary (yes the library I coded) removes all status effect data when an entity is removed, like it should.
---
---Save the information that the enemy has the status effect to our own custom data which does save for POST_NPC_DEATH.
---@param ent Entity
---@param source EntityRef
function ARACHNAS_SPOOL:OnNPCKill(ent, source)
	local webbed_data = StatusEffectLibrary:GetStatusEffectData(ent, ARACHNAS_SPOOL.STATUS_WEBBED)
	if webbed_data
		or (not ARACHNAMOD:IsLegacyGameplayEnabled() and source.Type == EntityType.ENTITY_TEAR and source.Variant == ARACHNAS_SPOOL.TEAR)
	then
		if ent:IsBoss() and ARACHNAMOD:IsLegacyGameplayEnabled() then
			return
		end
		local data = Mod:GetData(ent)
		data.QueueSpiderEgg = true
		data.SpiderBitten = StatusEffectLibrary:HasStatusEffect(ent, Mod.Item.DIVINE_CLOTH.STATUS_BITTEN)
		if webbed_data then
			data.SpiderEggSource = webbed_data.Source
		else
			data.SpiderEggSource = EntityRef(source.Entity.SpawnerEntity)
		end
		if ent:HasEntityFlags(EntityFlag.FLAG_ICE) then
			Mod:GetData(ent).WebbedOverrideHitPoints = ent.MaxHitPoints
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, ARACHNAS_SPOOL.OnNPCKill)

---@param npc EntityNPC
function ARACHNAS_SPOOL:OnNPCDeath(npc)
	local data = Mod:TryGetData(npc)
	if data and data.QueueSpiderEgg then
		---@type EntityRef
		local source = data.SpiderEggSource
		local player = source and source.Entity and source.Entity:ToPlayer()
		if not player then return end
		local eggFlags = 0
		local SPIDER_EGG = Mod.Entities.SPIDER_EGG
		if npc:IsBoss() then
			eggFlags = SPIDER_EGG.EggFlag.BOSS
			if npc.Parent or npc.Child or npc.SpawnerType ~= EntityType.ENTITY_NULL then
				eggFlags = Mod:AddBitFlags(eggFlags, SPIDER_EGG.EggFlag.SMALL)
			end
		end
		if Mod.Character.ARACHNA_B:IsArachnaB(player) and not Mod:IsLegacyGameplayEnabled() then
			eggFlags = Mod:AddBitFlags(eggFlags, SPIDER_EGG.EggFlag.SMALL | SPIDER_EGG.EggFlag.NO_INSTANT_EXPLODE)
		end

		local spiderColor
		if data.SpiderBitten and not Mod:IsLegacyGameplayEnabled() then
			spiderColor = Mod.Entities.COLORED_SPIDERS:GetRandomSpiderSubtype()
		end
		---@cast eggFlags SpiderEggFlag
		SPIDER_EGG:TrySpawnEgg(npc.Position, npc, player, eggFlags, spiderColor)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, ARACHNAS_SPOOL.OnNPCDeath)

---@param ent Entity
---@param statusEffectData StatusEffectData
function ARACHNAS_SPOOL:PostRemoveWebbed(ent, _, statusEffectData)
	if not Mod:IsLegacyGameplayEnabled() then
		ent.Mass = statusEffectData.CustomData.OriginalMass
	end
end

StatusEffectLibrary.Callbacks.AddCallback(StatusEffectLibrary.Callbacks.ID.POST_REMOVE_ENTITY_STATUS_EFFECT,
	ARACHNAS_SPOOL.PostRemoveWebbed, ARACHNAS_SPOOL.STATUS_WEBBED)

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
