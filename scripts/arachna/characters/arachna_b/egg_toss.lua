local Mod = ARACHNAMOD

local EGG_TOSS = {}

ARACHNAMOD.Item.EGG_TOSS = EGG_TOSS

EGG_TOSS.ID = Isaac.GetItemIdByName("Egg Toss")
EGG_TOSS.TEAR = Isaac.GetEntityVariantByName("Arachna Egg Tear")
EGG_TOSS.SFX_LIFT = Isaac.GetSoundIdByName("Egg Toss Lift")

EGG_TOSS.GRAB_RANGE = 40
EGG_TOSS.THROWN_EGG_RADIUS = 80 --Range of AOE effects
EGG_TOSS.MAX_BIRTHRIGHT_WEB_COUNT = 3

---@param player EntityPlayer
function EGG_TOSS:GetEggTearDamage(player)
	return player.Damage * 2 + (Mod.Level():GetStage() * 0.5)
end

---@param pos Vector
---@param vel Vector
---@param player EntityPlayer
---@param spawner? Entity
function EGG_TOSS:FireEgg(pos, vel, player, spawner)
	Mod.sfxman:Play(SoundEffect.SOUND_TEARS_FIRE, 0, 2)
	local eggTear = Mod.Spawn.Tear(EGG_TOSS.TEAR, pos, vel, nil, spawner)
	eggTear.CollisionDamage = EGG_TOSS:GetEggTearDamage(player)
	eggTear.FallingSpeed = -5.5
	eggTear.FallingAcceleration = 0.5
	Mod.sfxman:Play(SoundEffect.SOUND_FETUS_JUMP, 0.8)
	local data = Mod:GetData(player)
	local tearData = Mod:GetData(eggTear)

	if spawner and spawner:ToNPC() then
		eggTear.SubType = Mod.Entities.COLORED_SPIDERS:GetRandomSpiderSubtype(true)
		tearData.EggOnLandPlayer = EntityPtr(player)
		tearData.EggFlags = Mod.Entities.SPIDER_EGG.EggFlag.SMALL | Mod.Entities.SPIDER_EGG.EggFlag.NO_INSTANT_EXPLODE
	elseif spawner and spawner:ToPlayer() then
		if data.HeldEggColor then
			tearData.EggFlags = data.HeldEggFlags
			eggTear.SubType = data.HeldEggColor
			data.HeldEggFlags = nil
			data.HeldEggColor = nil
		end
	end
	local isSmall = tearData.EggFlags and Mod:HasBitFlags(tearData.EggFlags, Mod.Entities.SPIDER_EGG.EggFlag.SMALL) or false
	local animationSize = isSmall and "4" or "5"
	eggTear:GetSprite():Play("Stone" .. animationSize .. "Move")
	local color = Mod.Entities.SPIDER_EGG:GetEggColor(eggTear.SubType)
	if color then
		eggTear.Color = color
	end
	return eggTear
end

ThrowableItemLib:RegisterThrowableItem({
	ID = EGG_TOSS.ID,
	Type = ThrowableItemLib.Type.ACTIVE,
	Identifier = "Arachna Spider Eggs",
	Flags = ThrowableItemLib.Flag.DISABLE_HIDE | ThrowableItemLib.Flag.PERSISTENT,
	HoldCondition = function(player, config)
		local data = Mod:GetData(player)
		if data.ClosestEgg and data.ClosestEgg.Ref then
			return ThrowableItemLib.HoldConditionReturnType.ALLOW_HOLD
		else
			return ThrowableItemLib.HoldConditionReturnType.DISABLE_USE
		end
	end,
	ThrowFn = function(player, vect, slot, mimic)
		EGG_TOSS:FireEgg(player.Position, Mod:AddTearVelocity(vect, 12, player), player, player)
	end,
	LiftFn = function(player, continued, slot, mimic)
		local data = Mod:GetData(player)
		if not continued then
			local egg = data.ClosestEgg and data.ClosestEgg.Ref
			if not egg then return end
			local eggData = Mod:GetData(egg)
			data.HeldEggFlags = (eggData.EggFlags or 0)
			data.HeldEggColor = egg.SubType
			egg:Remove()
		end
		local spiderColor = data.HeldEggColor
		local sprite = player:GetHeldSprite()
		sprite:Load("gfx/002.027_egg tear.anm2", true)
		local isSmall = Mod:HasBitFlags(data.HeldEggFlags, Mod.Entities.SPIDER_EGG.EggFlag.SMALL)
		local animationSize = isSmall and "4" or "5"
		sprite:Play("Stone" .. animationSize .. "Idle")
		sprite.Offset = Vector(0, -10)
		Mod.sfxman:Play(EGG_TOSS.SFX_LIFT, 1, 2, false, 1 + 0.1 * math.random(-1, 1))
		local color = Mod.Entities.SPIDER_EGG:GetEggColor(spiderColor)
		if color then
			sprite.Color = color
		end
	end,
	HideFn = function(player, slot, mimic)
		local data = Mod:GetData(player)
		data.HeldEggFlags = nil
		data.HeldEggColor = nil
	end,
	AnimateFn = function(player, state)
		if state == ThrowableItemLib.State.THROW then
			player:AnimateCollectible(1, "HideItem")
			player:GetHeldSprite().Color.A = 0
			return true
		end
	end
})

---@param player EntityPlayer
function EGG_TOSS:MarkNearestEgg(player)
	if not player:HasCollectible(EGG_TOSS.ID) then return end
	local closestEgg
	Mod.Foreach.EffectInRadius(player.Position, EGG_TOSS.GRAB_RANGE, function(egg, index)
		if egg:GetSprite():IsPlaying("Idle") then
			if not closestEgg
				or egg.Position:DistanceSquared(player.Position) < closestEgg.Position:DistanceSquared(player.Position)
			then
				closestEgg = egg
			end
		end
	end, Mod.Entities.SPIDER_EGG.ID_SMALL, nil, nil, true)
	Mod.Foreach.EffectInRadius(player.Position, EGG_TOSS.GRAB_RANGE, function(egg, index)
		if egg:GetSprite():IsPlaying("Idle") then
			if not closestEgg
				or egg.Position:DistanceSquared(player.Position) < closestEgg.Position:DistanceSquared(player.Position)
			then
				closestEgg = egg
			end
		end
	end, Mod.Entities.SPIDER_EGG.ID, nil, nil, true)
	local data = Mod:GetData(player)
	if closestEgg then
		if not data.ClosestEgg then
			data.ClosestEgg = EntityPtr(closestEgg)
		elseif not data.ClosestEgg.Ref or not Mod:IsSameEntity(data.ClosestEgg.Ref, closestEgg) then
			data.ClosestEgg:SetReference(closestEgg)
		end
	else
		data.ClosestEgg = nil
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, EGG_TOSS.MarkNearestEgg)

---@param player? EntityPlayer
local function getNecroDamage(player)
	if not player then return 40 end
	local missingPage1 = player:GetTrinketMultiplier(TrinketType.TRINKET_MISSING_PAGE)
	local missingPage2 = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MISSING_PAGE_2)
	return 40 * (1 + (missingPage1 + missingPage2))
end

---@param spiderColor ColoredSpiderSubtype
---@param ent? Entity
---@param player? EntityPlayer
---@param source EntityRef @Egg tear
---@param playerSource EntityRef
function EGG_TOSS:EggOnDestroyEffect(spiderColor, ent, player, source, playerSource)
	local SpiderSubType = Mod.Entities.COLORED_SPIDERS.SpiderSubtype
	Mod:DebugLog("Activated egg effect", spiderColor)
	local damage = source.Entity.CollisionDamage
	if spiderColor == SpiderSubType.WRATH then
		if player then
			local tearParams = player:GetTearHitParams(WeaponType.WEAPON_BOMBS, 1, 1, source.Entity:ToTear())
			local color = Mod.Entities.SPIDER_EGG:GetEggColor(source.Entity.SubType)
			Mod.Game:BombExplosionEffects(source.Position, 60, tearParams.TearFlags, color, player, 0.5)
		else
			Isaac.Explode(source.Position, source.Entity, damage)
		end
		local candle = Mod.Spawn.Effect(EffectVariant.RED_CANDLE_FLAME, 0, source.Position, nil, player,
			source.Entity:GetDropRNG():Next())
		candle.CollisionDamage = 23
	elseif spiderColor == SpiderSubType.PESTILENCE then
		local cloud = Mod.Spawn.Effect(EffectVariant.SMOKE_CLOUD, 0, source.Position, nil, player)
		cloud:SetTimeout(150)
		cloud.CollisionDamage = damage / 2
		if ent then
			ent:AddPoison(playerSource, 150, damage)
		end
	elseif spiderColor == SpiderSubType.FAMINE and ent then
		if ent then
			ent:AddFreeze(playerSource, 150)
		end
		Mod.Foreach.NPCInRadius(source.Position, EGG_TOSS.THROWN_EGG_RADIUS, function(npc, index)
			npc:AddSlowing(playerSource, 150, 0.5, StatusEffectLibrary.StatusColor.SLOW)
		end, nil, nil, {UseEnemySearchParams = true})
	elseif spiderColor == SpiderSubType.DEATH then
		local poof = Mod.Spawn.Poof02(1, source.Position, source.Entity)
		poof.Color = source.Entity.Color
		poof.SpriteScale = Vector(0.8, 0.8)
		Mod.sfxman:Play(SoundEffect.SOUND_DEATH_CARD)
		local necroDamage = player and getNecroDamage(player) or 40
		Mod.Foreach.NPCInRadius(source.Position, 80, function(npc, index)
			npc:TakeDamage(necroDamage, 0, playerSource, 0)
		end, nil, nil, {UseEnemySearchParams = true})
	elseif spiderColor == SpiderSubType.RAINBOW then
		Mod.Foreach.NPCInRadius(source.Position, EGG_TOSS.THROWN_EGG_RADIUS, function(npc, index)
			if npc:IsBoss() then
				npc:AddWeakness(source, 150)
			else
				Mod.Entities.COLORED_SPIDERS:SpawnRainbowFart(npc.Position, source.Entity:GetSprite().Color)
				npc:Die()
			end
		end, nil, nil, {UseEnemySearchParams = true})
	elseif spiderColor == SpiderSubType.GOLDEN then
		if ent then
			ent:AddMidasFreeze(playerSource, 150)
		end
		for _ = 1, 5 do
			local rng = source.Entity:GetDropRNG()
			local coin = Mod.Spawn.Coin(NullPickupSubType.ANY, source.Position, EntityPickup.GetRandomPickupVelocity(source.Position, rng),
				player, rng:Next())
			coin.Timeout = 60
		end
	elseif spiderColor == SpiderSubType.LOVE then
		local poof = Mod.Spawn.Poof02(1, source.Position, source.Entity)
		poof.Color = source.Entity.Color
		poof.SpriteScale = Vector(0.8, 0.8)
		if ent and not ent:IsBoss() then
			ent:AddCharmed(playerSource, -1)
		end
		Mod.Foreach.NPCInRadius(source.Position, EGG_TOSS.THROWN_EGG_RADIUS, function(npc, index)
			npc:AddCharmed(playerSource, 150)
		end, nil, nil, {UseEnemySearchParams = true})
	elseif spiderColor == SpiderSubType.ICE then
		local clouds = Mod.Spawn.DustClouds(source.Position, nil, source.Entity, nil, 3)
		for _, cloud in ipairs(clouds) do
			cloud.Velocity = Vector(Mod:RandomNum(3, 5), 0):Rotated(Mod:RandomNum(360))
			cloud:GetSprite():GetLayer(0):SetColor(Color(1, 1, 1, 0.4, 0.8, 0.9, 1))
		end
		if ent and not ent:IsBoss() then
			ent:AddEntityFlags(EntityFlag.FLAG_ICE)
			ent.HitPoints = 0
			ent:TakeDamage(1, DamageFlag.DAMAGE_IGNORE_ARMOR, playerSource, 0)
		end
		for _, _ent in ipairs(Isaac.FindInRadius(source.Position, EGG_TOSS.THROWN_EGG_RADIUS, EntityPartition.ENEMY)) do
			if _ent:IsActiveEnemy(false) then
				_ent:AddIce(playerSource, 150)
				_ent:AddSlowing(playerSource, 150, 0.5, StatusEffectLibrary.StatusColor.SLOW)
			end
		end
	end
end

---@param ent? Entity
---@param source EntityRef
function EGG_TOSS:OnEggDamage(ent, amount, flags, source, countdown)
	if source.Entity
		and source.Type == EntityType.ENTITY_TEAR
		and source.Variant == EGG_TOSS.TEAR
	then
		---@type ColoredSpiderSubtype
		local spiderColor = source.Entity.SubType
		local spawnerEnt = source.Entity.SpawnerEntity
		local player = spawnerEnt and spawnerEnt:ToPlayer()
		local playerSource = EntityRef(player)
		EGG_TOSS:EggOnDestroyEffect(spiderColor, ent, player, source, playerSource)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, EGG_TOSS.OnEggDamage)

---@param player EntityPlayer
function EGG_TOSS:RainbowColorHold(player)
	local data = Mod:GetData(player)
	if data.HeldEggColor and data.HeldEggColor == Mod.Entities.COLORED_SPIDERS.SpiderSubtype.RAINBOW then
		local throwConfig = ThrowableItemLib.Utility:GetLiftedItem(player)
		if throwConfig.Type == ThrowableItemLib.Type.ACTIVE
			and throwConfig.ID == EGG_TOSS.ID
		then
			local r, g, b = table.unpack(Mod.Entities.COLORED_SPIDERS:GetRainbowColor())
			player:GetHeldSprite().Color:SetColorize(r, g, b, 0.5)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, EGG_TOSS.RainbowColorHold)

---@param tear EntityTear
function EGG_TOSS:RainbowColorTear(tear)
	if tear.SubType == Mod.Entities.COLORED_SPIDERS.SpiderSubtype.RAINBOW then
		local r, g, b = table.unpack(Mod.Entities.COLORED_SPIDERS:GetRainbowColor())
		tear:GetSprite().Color:SetColorize(r, g, b, 0.5)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, EGG_TOSS.RainbowColorTear, EGG_TOSS.TEAR)

---@param player EntityPlayer
---@param spiderColor ColoredSpiderSubtype
---@param pos Vector
function EGG_TOSS:SpawnMiniWeb(player, spiderColor, pos)
	local ownedWebs = {}
	Mod.Foreach.Effect(function(web, index)
		if web.SpawnerEntity
			and Mod:IsSameEntity(web.SpawnerEntity, player)
			and Mod:GetData(web).ArachnaBBirthright
		then
			Mod.Insert(ownedWebs, web)
		end
	end, Mod.Item.ARACHNAS_SPOOL.WEB_EFFECT)
	--Oldest webs get removed first
	table.sort(ownedWebs, function(web1, web2)
		return web1.FrameCount > web2.FrameCount
	end)

	while (#ownedWebs >= EGG_TOSS.MAX_BIRTHRIGHT_WEB_COUNT) do
		local ent = ownedWebs[1]
		ent:GetSprite():Play("Remove")
		table.remove(ownedWebs, 1)
	end
	local web = Mod.Item.ARACHNAS_SPOOL:SpawnWeb(pos, player, spiderColor)
	Mod:GetData(web).ArachnaBBirthright = true
	web.SpriteScale = Vector(0.5, 0.5)
	web:SetSize(web.Size / 2, Vector.One, 8)
end

---@param tear EntityTear
function EGG_TOSS:OnEggDeath(tear)
	local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
	local npc = tear.SpawnerEntity and tear.SpawnerEntity:ToNPC()
	local poof = Mod.Spawn.Effect(EffectVariant.TEAR_POOF_A, 0, tear.Position)
	local data = Mod:TryGetData(tear)
	local poofColor = Color(0.5, 0.5, 0.5, 1, 0.5, 0.5, 0.5)
	local color = Mod.Entities.SPIDER_EGG:GetEggColor(tear.SubType)
	local eggFlags = data and data.EggFlags or 0
	---@cast eggFlags SpiderEggFlag
	local SPIDER_EGG = Mod.Entities.SPIDER_EGG

	poof.Color = Color(0.5, 0.5, 0.5, 1, 0.5, 0.5, 0.5)
	Mod.sfxman:Play(SoundEffect.SOUND_BOIL_HATCH)

	if player then
		local rng = player:GetCollectibleRNG(EGG_TOSS.ID)

		if #tear:GetHitList() == 0 then
			EGG_TOSS:OnEggDamage(nil, nil, nil, EntityRef(tear))
		else
			eggFlags = Mod:AddBitFlags(eggFlags, SPIDER_EGG.EggFlag.THROWN_HIT)
		end
		local spiderCount = Mod.Entities.SPIDER_EGG:GetSpiderCount(player, rng, eggFlags)

		if tear.SubType == Mod.Entities.COLORED_SPIDERS.SpiderSubtype.CONQUEST then
			spiderCount = Mod.math.ceil(spiderCount * 1.5)
		end
		if color then
			poofColor = color
		end
		Mod.Entities.SPIDER_EGG:SpawnSpiderBurst(player, tear.Position, spiderCount, nil, eggFlags, false, tear.SubType)
		if Mod.Character.ARACHNA_B:ArachnaBHasBirthright(player) then
			EGG_TOSS:SpawnMiniWeb(player, tear.SubType, tear.Position)
		end
	elseif npc then
		player = data and data.EggOnLandPlayer and data.EggOnLandPlayer.Ref and data.EggOnLandPlayer.Ref:ToPlayer()
		if not player then return end
		local fixedPos = Mod.Room():GetClampedPosition(tear.Position, 20)
		SPIDER_EGG:TrySpawnEgg(fixedPos, npc, player, eggFlags, tear.SubType)
	end
	poof.Color = poofColor
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, EGG_TOSS.OnEggDeath, EGG_TOSS.TEAR)
