local mod = ARACHNAMOD
local arachnidItem = Isaac.GetItemIdByName("Arachnid's Grip")

--save data
mod.SavedData.playerOrbitalEggs = {}
local json = require("json")

function mod:orbitalEggsGameStart(isContinued) 
	if isContinued then
		--get data from save
		if mod:HasData() then
			mod.SavedData = json.decode(Isaac.LoadModData(mod))
			for i=0, game:GetNumPlayers()-1 do
				local player = Isaac.GetPlayer(i)
				local data = mod:GetData(player)
				if mod.SavedData.playerOrbitalEggs[tostring(i)] ~= nil then
					data.eggOrbitals = mod.SavedData.playerOrbitalEggs[tostring(i)]
					player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
					player:EvaluateItems()
				else
					data.eggOrbitals = 0
				end
			end
			--Isaac.ConsoleOutput("GOT DATA FROM SAVE! \n")
		end
	else
		--set values to default
		for i=0, game:GetNumPlayers()-1 do
			local player = Isaac.GetPlayer(i)
			local data = mod:GetData(player)
			data.eggOrbitals = 0
			player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
			player:EvaluateItems()
			--Isaac.ConsoleOutput("VALUES SET TO DEFAULT! \n")
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.orbitalEggsGameStart)
function mod:orbitalEggsGameExit(shouldSave) 
	if shouldSave then
		--save data
		for i=0, game:GetNumPlayers()-1 do
			local player = Isaac.GetPlayer(i)
			local data = mod:GetData(player)
			mod.SavedData.playerOrbitalEggs[tostring(i)] = data.eggOrbitals
		end
		mod.SaveData(mod, json.encode(mod.SavedData))
		--Isaac.ConsoleOutput("DATA SAVED! \n")
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.orbitalEggsGameExit)
function mod:orbitalEggsNewLvl()
	local level = game:GetLevel()
	if (level:GetStage() ~= 1) and (not level:IsAltStage()) and (not level:IsAscent()) then
		--save data
		for i=0, game:GetNumPlayers()-1 do
			local player = Isaac.GetPlayer(i)
			local data = mod:GetData(player)
			mod.SavedData.playerOrbitalEggs[tostring(i)] = data.eggOrbitals
		end
		mod.SaveData(mod, json.encode(mod.SavedData))
		--Isaac.ConsoleOutput("DATA SAVED! \n")
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.orbitalEggsNewLvl)
function mod:orbitalEggsGameEnd(isGameOver) 
	--clear data
	mod.SavedData.playerOrbitalEggs = {}
	mod.SaveData(mod, json.encode(mod.SavedData))
	--Isaac.ConsoleOutput("DATA CLEARED! \n")
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_END, mod.orbitalEggsGameEnd)

--familiar
local spiderEggOrbital = Isaac.GetEntityVariantByName("Spider Egg (orbital)")
--apply the right amount
function mod:spiderEggOrbitalCache(player, cacheFlag)
	local data = mod:GetData(player)
	local spiderEggAmount = data.eggOrbitals
	if (cacheFlag == CacheFlag.CACHE_FAMILIARS) and (spiderEggAmount ~= nil) and (spiderEggAmount >= 0) then
		player:CheckFamiliar(spiderEggOrbital, data.eggOrbitals, RNG())
	end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.spiderEggOrbitalCache)
--init
function mod:spiderEggOrbitalInit(baby)
	local sprite = baby:GetSprite()
	sprite:ReplaceSpritesheet(0, "gfx/familiars/egg_orbital_" .. tostring(math.random(1,4)) .. ".png")
	sprite:LoadGraphics()
	baby.CollisionDamage = 4
	baby:AddToOrbit(4444)
	baby:GetData().damageTimeout = 0
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.spiderEggOrbitalInit, spiderEggOrbital)
--behaviour
function mod:spiderEggOrbitalUpdate(baby)
	local player = baby.Player
	local sprite = baby:GetSprite()
	local data = baby:GetData()
	if not sprite:IsPlaying("Idle") then
		sprite:Play("Idle")
	end
	baby.OrbitDistance = Vector(30, 30)
	baby.OrbitSpeed = 0.03
	baby.Velocity = baby:GetOrbitPosition(player.Position + player.Velocity) - baby.Position
	if data.damageTimeout and data.damageTimeout > 0 then
		data.damageTimeout = data.damageTimeout - 1
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.spiderEggOrbitalUpdate, spiderEggOrbital)
--when hit by bullets/mobs
function mod:spiderEggOrbitalTouch(baby, ent, _) 
	if baby:GetData().damageTimeout <= 0 then
		local eggTryDie = false
		if ent:ToProjectile() then
			ent:Die()
			eggTryDie = true
		elseif ent:ToNPC() then
			if (ent:ToNPC():IsVulnerableEnemy()) then
				eggTryDie = true
			end
		end
		if eggTryDie then
			if (math.random(1,5) == 1) then
				--action
				local player = baby.Player
				local nearPos = Isaac.GetFreeNearPosition(baby.Position + Vector(math.random(-100, 100), math.random(-100, 100)), 50)
				if player:HasCollectible(Isaac.GetItemIdByName("Mutagen")) then
					throwSpecialSpider(player, returnRandomSpiderSubType(true), baby.Position, nearPos) --mutagen synergy
				else
					throwSpecialSpider(player, 0, baby.Position, nearPos)
				end
				--effects
				local swirlEffect = Isaac.Spawn(1000, 2002, 1, Vector(baby.Position.X, baby.Position.Y-10), Vector(0,0), baby):ToEffect()
				swirlEffect.DepthOffset = 250
				swirlEffect:Update()
				game:SpawnParticles(baby.Position, 5, math.random(3, 5), 4, Color(1, 1, 1, 1, 1, 1, 1))
				sfx:Play(SoundEffect.SOUND_BOIL_HATCH, 1, 0, false, 1)
				addEggOrbital(-1, player)
			end
			baby:GetData().damageTimeout = 30
			eggTryDie = false
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, mod.spiderEggOrbitalTouch, spiderEggOrbital)

--pickup itself
--init
function mod:spiderEggInit(pickup)
	local sprite = pickup:GetSprite()
	sprite:ReplaceSpritesheet(0, "gfx/familiars/egg_orbital_" .. tostring(math.random(1,4)) .. ".png")
	sprite:LoadGraphics()
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.spiderEggInit, 2003)
--on touch
function mod.spiderEggPickupTouch(_, pickup, collider)
	local player = collider:ToPlayer()
    if (player) then
		local amountCap = 3 + player:GetCollectibleNum(arachnidItem)
		if (mod:GetData(player).eggOrbitals < amountCap) then
			addEggOrbital(1, player)
			pickup:GetSprite():Play("Collect")
			pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			pickup:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
			sfx:Play(SoundEffect.SOUND_SUMMON_POOF, 2, 0, false, 1)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.spiderEggPickupTouch, 2003)
--update
function mod.spiderEggPickupUpdate(_, pickup)
	local sprite = pickup:GetSprite()
	local data = pickup:GetData()
	--triggers
	if sprite:IsEventTriggered("DropSound") then
		sfx:Play(SoundEffect.SOUND_FETUS_JUMP, 1, 0, false, 3) 
	end
	--destroy
	if sprite:IsFinished("Collect") then
		pickup:Remove()
	end
	if (game:GetRoom():IsClear()) then
		local swirlEffect = Isaac.Spawn(1000, 2002, 1, pickup.Position, Vector(0,0), pickup):ToEffect()
		swirlEffect.DepthOffset = 250
		swirlEffect:Update()
		game:SpawnParticles(pickup.Position, 5, math.random(3, 5), 4, Color(1, 1, 1, 1, 1, 1, 1))
		sfx:Play(SoundEffect.SOUND_MEATY_DEATHS , 0.8, 0, false, 1.25)
		pickup:Remove()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.spiderEggPickupUpdate, 2003)

--item itself
function mod:arachnidGripsOnKill(ent)
	if (ent:IsEnemy()) and (ent.Type ~= EntityType.ENTITY_FIREPLACE) and (ent.SpawnerType == 0) and (ent.ParentNPC == nil) then --entity is dead and wasn't spawned by another entity
		--enemies drop eggs
		if (SomeoneHasItem(arachnidItem)) and (not game:GetRoom():IsClear()) then
			if (math.random(1, 100) <= 20) then
				Isaac.Spawn(5, 2003, 0, ent.Position, Vector(0,0), player)
				sfx:Play(SoundEffect.SOUND_SPIDER_SPIT_ROAR, 0.8, 0, false, 1)
			end
		end
		--killing flies heal
		for i=0, game:GetNumPlayers()-1 do
			local player = Isaac.GetPlayer(i)
			if (player:HasCollectible(arachnidItem, true)) and (math.random(1, 100) <= 8) and (isFlyEnemy(ent))then
				player:AddHearts(2)
				local heartEff = Isaac.Spawn(1000, 49, 0, Vector(player.Position.X, player.Position.Y-20), Vector(0,0), player):ToEffect()
				heartEff.DepthOffset = 250
				heartEff:Update()
				sfx:Play(SoundEffect.SOUND_VAMP_GULP , 1, 0, false, 0.8)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.arachnidGripsOnKill)

--chance to shoot poison tear
function mod:arachnidGripsPoison(tear)
	local player = tear.Parent:ToPlayer()
	if player then
		if (player:HasCollectible(arachnidItem, true)) then
			if (math.random(1,4) == 1) then 
				tear:AddTearFlags(TearFlags.TEAR_POISON)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.arachnidGripsPoison)