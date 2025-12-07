local Mod = ARACHNAMOD

local GRAB = {}

ARACHNAMOD.Item.GRAB = GRAB

GRAB.ID = Isaac.GetItemIdByName("Grab")
GRAB.TEAR = Isaac.GetEntityVariantByName("Arachna Egg Tear")

---@param pos Vector
---@param vel Vector
---@param spawner? Entity
---@param player EntityPlayer
function GRAB:FireEgg(pos, vel, spawner, player)
	Mod.sfxman:Play(SoundEffect.SOUND_TEARS_FIRE, 0, 2)
	local eggTear = Mod.Spawn.Tear(GRAB.TEAR, pos, vel, nil, spawner)
	eggTear.CollisionDamage = 10
	eggTear.FallingSpeed = -5.5
	eggTear.FallingAcceleration = 0.5
	eggTear:GetSprite():Play("Stone5Move")
	Mod.sfxman:Play(SoundEffect.SOUND_FETUS_JUMP, 0.8)
	local weapon = player:GetWeapon(1)
	local playerFlags = player:GetTearHitParams(weapon and weapon:GetWeaponType() or WeaponType.WEAPON_TEARS, 1, 1,
		eggTear).TearFlags
	for _, tearFlag in ipairs(Mod.Item.ARACHNAS_SPOOL.INHERITED_TEAR_FLAGS) do
		if Mod:HasBitFlags(playerFlags, tearFlag) then
			eggTear:AddTearFlags(tearFlag)
		end
	end
	local data = Mod:GetData(player)
	local tearData = Mod:GetData(eggTear)

	if spawner and spawner:ToNPC() then
		eggTear.SubType = Mod.Entities.COLORED_SPIDERS:GetRandomSpiderSubtype(true)
		tearData.EggOnLand = true
		tearData.EggPlayer = EntityPtr(player)
	elseif spawner and spawner:ToPlayer() then
		if data.HeldEggColor then
			tearData.EggFlags = data.HeldEggFlags
			eggTear.SubType = data.HeldEggColor
			data.HeldEggFlags = nil
			data.HeldEggColor = nil
		end
	end
	local color = Mod.Entities.SPIDER_EGG:GetEggColor(eggTear.SubType)
	if color then
		eggTear.Color = color
	end
	return eggTear
end

ThrowableItemLib:RegisterThrowableItem({
	ID = GRAB.ID,
	Type = ThrowableItemLib.Type.ACTIVE,
	Identifier = "Arachna Spider Eggs",
	Flags = ThrowableItemLib.Flag.DISABLE_HIDE | ThrowableItemLib.Flag.PERSISTENT,
	HoldCondition = function (player, config)
		local eggToRemove
		Mod.Foreach.EffectInRadius(player.Position, 40, function(egg, index)
			if egg:GetSprite():IsPlaying("Idle") then
				if not eggToRemove
					or egg.Position:DistanceSquared(player.Position) < eggToRemove.Position:DistanceSquared(player.Position)
				then
					eggToRemove = egg
				end
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
		GRAB:FireEgg(player.Position, Mod:AddTearVelocity(vect, 12, player), player, player)
	end,
	LiftFn = function (player, continued, slot, mimic)
		local data = Mod:GetData(player)
		if not continued then
			local egg = data.QueuedEggLift and data.QueuedEggLift.Ref
			if not egg then return end
			local eggData = Mod:GetData(egg)
			data.HeldEggFlags = (eggData.EggFlags or 0) | Mod.Entities.SPIDER_EGG.EggFlag.THROWN
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
	HideFn = function (player, slot, mimic)
		local data = Mod:GetData(player)
		data.HeldEggFlags = nil
		data.HeldEggColor = nil
	end,
	AnimateFn = function (player, state)
		if state == ThrowableItemLib.State.THROW then
			player:AnimateCollectible(1, "HideItem")
			player:GetHeldSprite().Color.A = 0
			return true
		end
	end
})

---@param spiderColor ColoredSpiderSubtype
---@param ent? Entity
---@param player? EntityPlayer
---@param source EntityRef
---@param playerSource EntityRef
---@param damage number
function GRAB:EggOnDestroyEffect(spiderColor, ent, player, source, playerSource, damage)
	local COLORED_SPIDERS = Mod.Entities.COLORED_SPIDERS
	Mod:DebugLog("Activated effect", spiderColor)
	if spiderColor == COLORED_SPIDERS.SpiderSubtype.WRATH then
		if ent then
			ent:AddBurn(playerSource, 150, damage)
		end
		if player then
			local candle = Mod.Spawn.Effect(EffectVariant.RED_CANDLE_FLAME, 0, source.Position, nil, player, source.Entity:GetDropRNG():Next())
			candle.CollisionDamage = 23
		end
	elseif spiderColor == COLORED_SPIDERS.SpiderSubtype.PESTILENCE then
		local cloud = Mod.Spawn.Effect(EffectVariant.SMOKE_CLOUD, 0, source.Position, nil, player)
		cloud:SetTimeout(150)
		cloud.CollisionDamage = 5
		if ent then
			ent:AddPoison(playerSource, 60, damage)
		end
		elseif spiderColor == COLORED_SPIDERS.SpiderSubtype.FAMINE and ent then
		if ent:IsBoss() then
			ent:AddConfusion(playerSource, 300)
		else
			ent:AddEntityFlags(EntityFlag.FLAG_CONFUSION)
		end
	elseif spiderColor == COLORED_SPIDERS.SpiderSubtype.DEATH and ent then
		local bigHornHand = Mod.Spawn.Effect(EffectVariant.BIG_HORN_HAND, 0, source.Position, nil, player)
		bigHornHand.Target = ent
	elseif spiderColor == COLORED_SPIDERS.SpiderSubtype.GOLDEN then
		for _ = 1, 5 do
			local rng = source.Entity:GetDropRNG()
			local coin = Mod.Spawn.Coin(0, source.Position, EntityPickup.GetRandomPickupVelocity(source.Position, rng), player, rng:Next())
			coin.Timeout = 60
		end
	elseif spiderColor == COLORED_SPIDERS.SpiderSubtype.LOVE and ent then
		ent:AddBaited(playerSource, 150)
	elseif spiderColor == COLORED_SPIDERS.SpiderSubtype.ICE then
		local clouds = Mod.Spawn.DustClouds(source.Position, nil, source.Entity, nil, 3)
		for _, cloud in ipairs(clouds) do
			cloud.Velocity = Vector(Mod:RandomNum(3, 5), 0):Rotated(Mod:RandomNum(360))
			cloud:GetSprite():GetLayer(0):SetColor(Color(1,1,1,0.4,0.8,0.9,1))
		end
		for _, _ent in ipairs(Isaac.FindInRadius(source.Position, 80, EntityPartition.ENEMY)) do
			_ent:AddIce(playerSource, 150)
			_ent:AddSlowing(playerSource, 150, 0.5, StatusEffectLibrary.StatusColor.SLOW)
		end
	end
end

---@param ent? Entity
---@param source EntityRef
function GRAB:OnEggDamage(ent, amount, flags, source, countdown)
	if source.Entity
		and source.Type == EntityType.ENTITY_TEAR
		and source.Variant == GRAB.TEAR
	then
		---@type ColoredSpiderSubtype
		local spiderColor = source.Entity.SubType
		local spawnerEnt = source.Entity.SpawnerEntity
		local player = spawnerEnt and spawnerEnt:ToPlayer()
		local playerSource = EntityRef(player)
		local damage = player and player.Damage or 3.5
		local COLORED_SPIDERS = Mod.Entities.COLORED_SPIDERS
		if spiderColor == COLORED_SPIDERS.SpiderSubtype.RAINBOW then
			local noRainbowSelect = Mod:Set({
				COLORED_SPIDERS.SpiderSubtype.BIG_FLAG,
				COLORED_SPIDERS.SpiderSubtype.RAINBOW,
				COLORED_SPIDERS.SpiderSubtype.CONQUEST,
				COLORED_SPIDERS.SpiderSubtype.NORMAL,
			})
			local randomColors = Mod:GetValues(COLORED_SPIDERS.SpiderSubtype)
			for i = #randomColors, 1, -1 do
				local color = randomColors[i]
				if noRainbowSelect[color] then
					table.remove(randomColors, i)
				end
			end
			local rng = source.Entity:GetDropRNG()
			local colorIndex = rng:RandomInt(#randomColors) + 1
			spiderColor = randomColors[colorIndex]
			table.remove(randomColors, colorIndex)
			GRAB:EggOnDestroyEffect(spiderColor, ent, player, source, playerSource, damage)
			spiderColor = randomColors[rng:RandomInt(#randomColors) + 1]
		end
		GRAB:EggOnDestroyEffect(spiderColor, ent, player, source, playerSource, damage)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, GRAB.OnEggDamage)

---@param player EntityPlayer
function GRAB:RainbowColorHold(player)
	local data = Mod:GetData(player)
	if data.HeldEggColor and data.HeldEggColor == Mod.Entities.COLORED_SPIDERS.SpiderSubtype.RAINBOW then
		local throwConfig = ThrowableItemLib.Utility:GetLiftedItem(player)
		if throwConfig.Type == ThrowableItemLib.Type.ACTIVE
			and throwConfig.ID == GRAB.ID
		then
			local r, g, b = table.unpack(Mod.Entities.COLORED_SPIDERS:GetRainbowColor())
			player:GetHeldSprite().Color:SetColorize(r, g, b, 0.5)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, GRAB.RainbowColorHold)

---@param tear EntityTear
function GRAB:RainbowColorTear(tear)
	if tear.SubType == Mod.Entities.COLORED_SPIDERS.SpiderSubtype.RAINBOW then
		local r, g, b = table.unpack(Mod.Entities.COLORED_SPIDERS:GetRainbowColor())
		tear:GetSprite().Color:SetColorize(r, g, b, 0.5)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, GRAB.RainbowColorTear, GRAB.TEAR)

---@param tear EntityTear
function GRAB:OnEggDeath(tear)
	local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
	local npc = tear.SpawnerEntity and tear.SpawnerEntity:ToNPC()
	local poof = Mod.Spawn.Effect(EffectVariant.TEAR_POOF_A, 0, tear.Position)
	local data = Mod:TryGetData(tear)
	local poofColor = Color(0.5, 0.5, 0.5, 1, 0.5, 0.5, 0.5)
	local color = Mod.Entities.SPIDER_EGG:GetEggColor(tear.SubType)
	local eggFlags = data and data.EggFlags
	local SPIDER_EGG = Mod.Entities.SPIDER_EGG

	poof.Color = Color(0.5, 0.5, 0.5, 1, 0.5, 0.5, 0.5)
	Mod.sfxman:Play(SoundEffect.SOUND_BOIL_HATCH)

	if player then
		local minSpiders, maxSpiders = SPIDER_EGG:GetSpiderCountRange(player, eggFlags)
		local rng = player:GetCollectibleRNG(GRAB.ID)
		local spiderCount = rng:RandomInt(minSpiders, maxSpiders)
		if tear.SubType == Mod.Entities.COLORED_SPIDERS.SpiderSubtype.CONQUEST then
			spiderCount = Mod.math.ceil(spiderCount * 1.5)
		end
		Mod.Entities.SPIDER_EGG:SpawnSpiderBurst(player, tear.Position, spiderCount, nil, eggFlags, false, tear.SubType)
		if color then
			poofColor = color
		end
		if #tear:GetHitList() == 0 then
			GRAB:OnEggDamage(nil, nil, nil, EntityRef(tear))
		end
	elseif npc then
		player = data and data.EggPlayer and data.EggPlayer.Ref and data.EggPlayer.Ref:ToPlayer()
		if not player then return end
		SPIDER_EGG:TrySpawnEgg(tear.Position, npc, player, nil, tear.SubType)
	end
	poof.Color = poofColor
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, GRAB.OnEggDeath, GRAB.TEAR)