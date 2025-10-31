local mod = ARACHNAMOD
local game = ARACHNAMOD.game
local sfx = ARACHNAMOD.sfx
--YARN HEART
local yarnHeart = Isaac.GetItemIdByName("Yarn Heart")
function mod:useYarnHeart(item, rng, player)
	if player and player:GetPlayerType() ~= PlayerType.PLAYER_THELOST and player:GetPlayerType() ~= PlayerType.PLAYER_THELOST_B and canPickWebHearts(player) and player:CanPickSoulHearts() then
		addWebHearts(1, player)
		local swirlEffect = Isaac.Spawn(1000, 2002, 1, Vector(player.Position.X, player.Position.Y-10), Vector(0,0), player):ToEffect()
		swirlEffect.DepthOffset = 250
		swirlEffect:Update()
		sfx:Play(SoundEffect.SOUND_SPIDER_SPIT_ROAR, 0.8, 0, false, 1)
	end
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.useYarnHeart, yarnHeart)

--WHITE STRING
local whiteString = Isaac.GetTrinketIdByName("White String")
function mod:whiteStringNewLvl()
	if (not game:GetLevel():IsAscent()) then
		for i=0, game:GetNumPlayers()-1 do
			local player = Isaac.GetPlayer(i)
			if (player:HasTrinket(whiteString)) and player:GetPlayerType() ~= PlayerType.PLAYER_THELOST and player:GetPlayerType() ~= PlayerType.PLAYER_THELOST_B and canPickWebHearts(player) and player:CanPickSoulHearts() then
				addWebHearts(1, player)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.whiteStringNewLvl)

--MUTAGEN
--effect
local mutagenItem = Isaac.GetItemIdByName("Mutagen")
local function doMutagenEffect()
	for i=0, game:GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(i)
		if (player:HasCollectible(mutagenItem)) then
		local rng = player:GetCollectibleRNG(mutagenItem)
			if (rng:RandomInt(5)+1 == 1) then
				for i=1, mod:GetRandomNumber(3, 5, rng) do
					local nearPos = Isaac.GetFreeNearPosition(player.Position + Vector(mod:GetRandomNumber(-100, 100, mod.Globals.garbageRNG), mod:GetRandomNumber(-100, 100)), 75)
					throwSpecialSpider(player, returnRandomSpiderSubType(false, true), player.Position, nearPos)
				end
				sfx:Play(SoundEffect.SOUND_SPIDER_SPIT_ROAR, 0.8, 0, false, 1)
			end
		end
	end
end
--normal room
function mod:mutagenOnNewRoom()
	local room = game:GetRoom()
	if (room:IsFirstVisit()) and (not room:IsClear()) then
		doMutagenEffect()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.mutagenOnNewRoom)
--greed mode
local curWave = 0
function mod:mutagenResetWave()
	curWave = 0
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.mutagenResetWave)
function mod:mutagenGreedReroll()
	if game:IsGreedMode() then
		local realWave = game:GetLevel().GreedModeWave
		if realWave ~= curWave then
			doMutagenEffect()
			curWave = realWave
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.mutagenGreedReroll)

--change stats
function mod:mutagenStatsChange(player, cacheFlag)
	if player:HasCollectible(mutagenItem) then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + 1
		end
	end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.mutagenStatsChange)

--INFESTED PENNY
local infestPenny = Isaac.GetTrinketIdByName("Infested Penny")
function mod:infestPennyTouch(pickup, collider, _)
	local player = collider:ToPlayer()
	if player and pickup.Variant == 20 and pickup.SubType ~= 6 then
		if player:HasTrinket(infestPenny) then
			--spider
			local nearPos = Isaac.GetFreeNearPosition(player.Position + Vector(mod:GetRandomNumber(-100, 100, mod.Globals.garbageRNG), mod:GetRandomNumber(-100, 100, mod.Globals.garbageRNG)), 75)
			if (player:HasCollectible(mutagenItem)) then
				throwSpecialSpider(player, returnRandomSpiderSubType(false), player.Position, nearPos) --synergy with mutagen
			else
				throwSpecialSpider(player, 0, player.Position, nearPos)
			end
			--heart
			local rng = player:GetTrinketRNG(infestPenny)
			if rng:RandomInt(100)+1 <= 5 then
				nearPos = Isaac.GetFreeNearPosition(player.Position + Vector(mod:GetRandomNumber(-100, 100, mod.Globals.garbageRNG), mod:GetRandomNumber(-100, 100, mod.Globals.garbageRNG)), 50)
				Isaac.Spawn(5, 2000, 0, nearPos, Vector(0,0), player)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.infestPennyTouch)

--SPRINDLE
local sharpSprindle = Isaac.GetTrinketIdByName("Sprindle")
function mod:sprindleTakeDamage(target, amount, flag, source, num)
	local player = target:ToPlayer()
	if player and player:HasTrinket(sharpSprindle) then
		Isaac.ConsoleOutput("a")
		local ent = source.Entity:ToNPC()
		if (ent) and (not ent:IsBoss()) and (ent:IsVulnerableEnemy()) and (ent.Type ~= EntityType.ENTITY_FIREPLACE) then
			local swirlEffect = Isaac.Spawn(1000, 2002, 1, Vector(ent.Position.X, ent.Position.Y-10), Vector(0,0), player):ToEffect()
			swirlEffect.DepthOffset = 250
			swirlEffect:Update()
			doSpiderBite(ent, 250, player, false)
			return nil
		end
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.sprindleTakeDamage)

--MERGED CARD
local mergedCard = Isaac.GetCardIdByName("Merged Card")
function mod:useMergedCard(card, player)
	local hud = game:GetHUD()
	local effects = {"THE FOOL", "THE MAGICIAN", "THE HIGH PRIESTESS", "THE EMPRESS", "THE EMPEROR", "THE HIEROPHANT", "THE LOVERS", "THE CHARIOT", "JUSTICE", "THE HERMIT", "WHEEL OF FORTUNE", 
	"STRENGTH", "THE HANGED MAN", "DEATH", "TEMPERANCE", "THE DEVIL", "THE TOWER", "THE STARS", "THE MOON", "THE SUN", "JUDGEMENT", "THE WORLD"}
	local effectName = ""
	local effectDesc = ""
	--get the use amount
	local amount = 2
	if player:HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) then
		amount = 3
	end
	local rng = player:GetCardRNG(mergedCard)
	--actual effect
	sfx:Play(Isaac.GetSoundIdByName("snd_merged_card"), 3.5, 0, false, 1)
	for i=1, amount do
		--pick the effect
		local curEffect = rng:RandomInt(#effects)+1
		--add it's name to the text that will be withdrawn later
		if i == 1 then
			effectName = effects[curEffect]
		elseif i == 2 then
			effectName = effectName .. " + " .. effects[curEffect]
		elseif i == 3 then
			effectDesc = "BONUS: " .. effects[curEffect]
		else
			effectDesc = effectDesc .. ", " .. effects[curEffect] --yeah, technically it can display more than 3 effects
		end
		--actual effects
		if effects[curEffect] == "THE FOOL" then
			--action
			player:UseActiveItem(CollectibleType.COLLECTIBLE_D7, false, false, true, false, -1)
			--visual
			sfx:Play(SoundEffect.SOUND_SUMMON_POOF, 2, 0, false, 1)
			
		elseif effects[curEffect] == "THE MAGICIAN" then
			--action
			local enemies = Isaac.GetRoomEntities()
			for i=1, #enemies do
				local enemy = enemies[i]
				if enemy:IsVulnerableEnemy() and not enemy:IsBoss() then
					--debuff
					enemy:AddEntityFlags(EntityFlag.FLAG_SLOW)
					--visual bit
					local swirlEffect = Isaac.Spawn(1000, 2002, 1, Vector(enemy.Position.X, enemy.Position.Y-10), Vector(0,0), enemy):ToEffect()
					swirlEffect.DepthOffset = 250
					swirlEffect:Update()
				end
			end
			--visual
			sfx:Play(SoundEffect.SOUND_SUMMON_POOF, 2, 0, false, 1)
			
		elseif effects[curEffect] == "THE HIGH PRIESTESS" then
			Isaac.Spawn(1000, 29, 0, player.Position, Vector(0,0), player)
			
		elseif effects[curEffect] == "THE EMPRESS" then
			--action
			player:UseActiveItem(CollectibleType.COLLECTIBLE_THE_NAIL, false, false, true, true, -1)
			--visual
			local smokePoof = Isaac.Spawn(1000, 16, 0, Vector(player.Position.X, player.Position.Y-5), Vector(0,0), player):ToEffect() 
			smokePoof.Color = Color(0.1, 0.1, 0.1, 0.8, 0, 0, 0) 
			smokePoof.SpriteScale = smokePoof.SpriteScale*0.8 
			smokePoof:Update() 
			smokePoof.DepthOffset = 255
			
		elseif effects[curEffect] == "THE EMPEROR" then
			--action
			displayRoomType(RoomType.ROOM_BOSS)
			--visual
			sfx:Play(SoundEffect.SOUND_METAL_DOOR_OPEN, 1, 0, false, 1.2)
			
		elseif effects[curEffect] == "THE HIEROPHANT" then
			for i=1, 2 do
				Isaac.Spawn(5, 10, 8, getNearPos(player.Position), Vector(0,0), player)
			end	
			
		elseif effects[curEffect] == "THE LOVERS" then
			for i=1, 2 do
				Isaac.Spawn(5, 10, 2, getNearPos(player.Position), Vector(0,0), player)
			end
			
		elseif effects[curEffect] == "THE CHARIOT" then
			player:UseActiveItem(CollectibleType.COLLECTIBLE_UNICORN_STUMP, false, false, true, true, -1)
			
		elseif effects[curEffect] == "JUSTICE" then
			local pickupVars = {10, 20, 30, 40} --heart, penny, key, bomb
			for i=1, 2 do
				local pickupChoice = rng:RandomInt(#pickupVars)+1
				Isaac.Spawn(5, pickupVars[pickupChoice], 1, getNearPos(player.Position), Vector(0,0), player)
				table.remove(pickupVars, pickupChoice)
			end
			
		elseif effects[curEffect] == "THE HERMIT" then
			player:UseActiveItem(CollectibleType.COLLECTIBLE_KEEPERS_BOX, false, false, true, false, -1)
			
		elseif effects[curEffect] == "WHEEL OF FORTUNE" then
			--action
			for i=1, 5 do
				if player:GetNumCoins() > 0 then
					local chance = rng:RandomInt(100)+1
					if (chance >= 1) and (chance <= 3) then
						player:AddPrettyFly()
					elseif (chance > 3) and (chance <= 6) then -- 3%
						Isaac.Spawn(13, 0, 0, getNearPos(player.Position), Vector(0,0), player)
					elseif (chance > 6) and (chance <= 11) then -- 3%
						Isaac.Spawn(5, 20, 4, getNearPos(player.Position), Vector(0,0), player)
					elseif (chance > 11) and (chance <= 23) then -- 12%
						Isaac.Spawn(5, 20, 1, getNearPos(player.Position), Vector(0,0), player)
					elseif (chance > 23) and (chance <= 28) then -- 5%
						Isaac.Spawn(5, 70, 0, getNearPos(player.Position), Vector(0,0), player) -- "0" subtype gets random pill from the pool. I think
					elseif (chance > 28) and (chance <= 37) then -- 9%
						Isaac.Spawn(5, 10, 1, getNearPos(player.Position), Vector(0,0), player)
					elseif (chance > 37) and (chance <= 40) then -- 3%
						Isaac.Spawn(5, 30, 1, getNearPos(player.Position), Vector(0,0), player)
					elseif (chance > 40) and (chance <= 45) then -- 5%
						Isaac.Spawn(5, 40, 1, getNearPos(player.Position), Vector(0,0), player)
					end
					-- 55% - nothing
					player:AddCoins(-1)
				end
			end
			--visual
			sfx:Play(SoundEffect.SOUND_CASH_REGISTER, 3, 0, false, 1)
			
		elseif effects[curEffect] == "STRENGTH" then
			player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_ODD_MUSHROOM_LARGE, false, 1)
			
		elseif effects[curEffect] == "THE HANGED MAN" then
			local room = Game():GetRoom()
			for gridpos=1, room:GetGridSize() do
				local grid = room:GetGridEntity(gridpos)
				if (grid) then
					--if rock
					if (grid:GetType() == GridEntityType.GRID_ROCK) or (grid:GetType() == GridEntityType.GRID_ROCKB) or (grid:GetType() == GridEntityType.GRID_ROCKT) or (grid:GetType() == GridEntityType.GRID_ROCK_BOMB) or (grid:GetType() == GridEntityType.GRID_ROCK_ALT) or (grid:GetType() == GridEntityType.GRID_LOCK) or (grid:GetType() == GridEntityType.GRID_POOP) or (grid:GetType() == GridEntityType.GRID_ROCK_SS) or (grid:GetType() == GridEntityType.GRID_PILLAR) or (grid:GetType() == GridEntityType.GRID_ROCK_SPIKED) or (grid:GetType() == GridEntityType.GRID_ROCK_ALT2) or (grid:GetType() == GridEntityType.GRID_ROCK_GOLD) then 
						grid:Destroy()
					--if pit
					elseif (grid:GetType() == GridEntityType.GRID_PIT) then
						grid:ToPit():MakeBridge(nil)
						grid:ToPit():UpdateCollision()
					end
				end
			end
			
		elseif effects[curEffect] == "DEATH" then
			--action
			damageAllEnemies(20, player)
			--visual
			local smokePoof = Isaac.Spawn(1000, 16, 2, Vector(player.Position.X, player.Position.Y-15), Vector(0,0), player):ToEffect() 
			smokePoof.Color = Color(0.3, 0.3, 0.3, 0.8, 0, 0, 0) 
			smokePoof.SpriteScale = smokePoof.SpriteScale*0.85 
			smokePoof:Update() 
			local smokePoof2 = Isaac.Spawn(1000, 16, 1, player.Position, Vector(0,0), player):ToEffect() 
			smokePoof2.Color = Color(0.3, 0.3, 0.3, 0.8, 0, 0, 0) 
			smokePoof2.SpriteScale = smokePoof.SpriteScale*0.7 
			smokePoof2:Update() 
			
		elseif effects[curEffect] == "TEMPERANCE" then
			--action
			local pos = Isaac.GetFreeNearPosition(player.Position + Vector(mod:GetRandomNumber(-150, 150, mod.Globals.garbageRNG), mod:GetRandomNumber(-150, 150, mod.Globals.garbageRNG)), 50)
			local boi = Isaac.Spawn(6, 5, 0, pos, Vector(0,0), player)
			--visual
			local poof = Isaac.Spawn(1000, 15, 0, boi.Position, Vector(0,0), nil)
			sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 0.8, 0, false, 1)
			
		elseif effects[curEffect] == "THE DEVIL" then
			--action
			player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_GROWTH_HORMONES, false, 1)
			--visual
			player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_PENTAGRAM, true, 1)
			sfx:Play(SoundEffect.SOUND_SATAN_BLAST, 1, 0, false, 1)
			
		elseif effects[curEffect] == "THE TOWER" then
			for i=1, 3 do
				local nearPos = Isaac.GetRandomPosition()
				Isaac.Spawn(4, 3, 0, nearPos, Vector(0,0), player)
			end	
			
		elseif effects[curEffect] == "THE STARS" then
			--action
			local boi = Isaac.Spawn(5, 60, 0, getNearPos(player.Position), Vector(0,0), player)
			--visual
			local poof = Isaac.Spawn(1000, 15, 0, boi.Position, Vector(0,0), nil)
			sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 0.8, 0, false, 1)
			
		elseif effects[curEffect] == "THE MOON" then
			--action
			displayRoomType(RoomType.ROOM_SECRET)
			displayRoomType(RoomType.ROOM_SUPERSECRET)
			displayRoomType(RoomType.ROOM_ULTRASECRET)
			--visual 
			sfx:Play(SoundEffect.SOUND_GOLDENKEY, 1, 0, false, 1)
			
		elseif effects[curEffect] == "THE SUN" then		
			--action
			player:AddHearts(2)
			damageAllEnemies(5, player)
			displayRoomType(RoomType.ROOM_TREASURE)
			displayRoomType(RoomType.ROOM_PLANETARIUM)
			--visual
			local heartEff = Isaac.Spawn(1000, 49, 0, Vector(player.Position.X, player.Position.Y-20), Vector(0,0), player):ToEffect()
			heartEff.DepthOffset = 250
			heartEff:Update()
			sfx:Play(SoundEffect.SOUND_VAMP_GULP , 1, 0, false, 0.8)
			
		elseif effects[curEffect] == "JUDGEMENT" then
			--action
			local boi = Isaac.Spawn(17, 3, 0, getNearPos(player.Position), Vector(0,0), player)
			--visual
			local poof = Isaac.Spawn(1000, 15, 0, boi.Position, Vector(0,0), nil)
			sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 0.8, 0, false, 1)
			
		elseif effects[curEffect] == "THE WORLD" then
			--action
			displayRoomType(RoomType.ROOM_TREASURE)
			displayRoomType(RoomType.ROOM_PLANETARIUM)
			--visual
			sfx:Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12, 1, 0, false, 1)
			
		end
		--remove the effect from the table so it won't repeat
		table.remove(effects, curEffect)
	end
	--show text and play sound 
	hud:ShowItemText(effectName, effectDesc)
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useMergedCard, mergedCard)

-- BOSS ITEMS
local bossItem = {
	SPIDER_DONUT = Isaac.GetItemIdByName(" Spider Donut "), 
	OLD_SHOEBOX = Isaac.GetItemIdByName("Old Shoebox"), 
	GUMMY_SPIDERS = Isaac.GetItemIdByName("Gummy Spiders"), 
	CANDY_FLOSS = Isaac.GetItemIdByName("Candy Floss"), 
}

-- SPIDER DONUT
function mod:cacheSpiderDonut(player, cacheFlag)
    if player:HasCollectible(bossItem.SPIDER_DONUT) then
        if cacheFlag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + (1*player:GetCollectibleNum(bossItem.SPIDER_DONUT))
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.cacheSpiderDonut)

local function collectingSpiderDonut(player, item)
	addWebHearts(1, player)
	local rng = player:GetCollectibleRNG(bossItem.SPIDER_DONUT)
	for i=1, mod:GetRandomNumber(2, 3, rng) do
		local nearPos = Isaac.GetFreeNearPosition(player.Position + Vector(mod:GetRandomNumber(-100, 100, mod.Globals.garbageRNG), mod:GetRandomNumber(-100, 100, mod.Globals.garbageRNG)), 50)
		throwSpecialSpider(player, 10, player.Position, nearPos)
	end
end
ARACHNAMOD:addPostItemGetFunction(collectingSpiderDonut, bossItem.SPIDER_DONUT)

-- OLD SHOEBOX
function mod:cacheOldShoebox(player, cacheFlag)
    if player:HasCollectible(bossItem.OLD_SHOEBOX) then
		local shoeboxCount = player:GetCollectibleNum(bossItem.OLD_SHOEBOX)
        if cacheFlag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay - (1.2*shoeboxCount)
        end
        if shoeboxCount == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed + (0.15*shoeboxCount)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.cacheOldShoebox)

local function collectingOldShoebox(player, item)
	Isaac.Spawn(5, 2000, 0, Isaac.GetFreeNearPosition(player.Position, 25), Vector(0,0), player)
	local rng = player:GetCollectibleRNG(bossItem.OLD_SHOEBOX)
	for i=1, mod:GetRandomNumber(7, 14, rng) do
		local nearPos = Isaac.GetFreeNearPosition(player.Position + Vector(mod:GetRandomNumber(-100, 100, mod.Globals.garbageRNG), mod:GetRandomNumber(-100, 100, mod.Globals.garbageRNG)), 50)
		throwSpecialSpider(player, 0, player.Position, nearPos)
	end	
end
ARACHNAMOD:addPostItemGetFunction(collectingOldShoebox, bossItem.OLD_SHOEBOX)

-- GUMMY SPIDERS
function mod:cacheGummySpiders(player, cacheFlag)
    if player:HasCollectible(bossItem.GUMMY_SPIDERS) then
        if cacheFlag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay - (2*player:GetCollectibleNum(bossItem.GUMMY_SPIDERS))
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.cacheGummySpiders)

local function collectingGummySpiders(player, item)
	addWebHearts(2, player)
	local rng = player:GetCollectibleRNG(bossItem.GUMMY_SPIDERS)
	for i=1, mod:GetRandomNumber(4, 8, rng) do
		local nearPos = Isaac.GetFreeNearPosition(player.Position + Vector(mod:GetRandomNumber(-100, 100, mod.Globals.garbageRNG), mod:GetRandomNumber(-100, 100, mod.Globals.garbageRNG)), 50)
		local spider = returnRandomSpiderSubType(false, true)
		throwSpecialSpider(player, spider, player.Position, nearPos)
	end	
end
ARACHNAMOD:addPostItemGetFunction(collectingGummySpiders, bossItem.GUMMY_SPIDERS)

-- CANDY FLOSS
function mod:candyFlossTearEffect(tear)
	local player = tear.Parent:ToPlayer()
	if player then
		if (player:HasCollectible(bossItem.CANDY_FLOSS, true)) then
			local rng = player:GetCollectibleRNG(bossItem.CANDY_FLOSS)
			if (rng:RandomInt(100)+1 <= (5 + (5*player:GetCollectibleNum(bossItem.CANDY_FLOSS)) + player.Luck)) then
				tear:GetData().spiderBiteOnHit = true
				tear:AddTearFlags(TearFlags.TEAR_SLOW | TearFlags.TEAR_QUADSPLIT) 
				tear.Color = Color(2, 2, 2, 1, 0.196, 0.196, 0.196) 
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.candyFlossTearEffect)

local function collectingCandyFloss(player, item)
	local heartCount = 0
	if player:GetHearts() > 1 then
		heartCount = math.ceil((player:GetHearts()-1)/2)
		player:AddHearts(-1*(player:GetHearts()-1))
	end
	if heartCount < 3 then heartCount = 3 end
	
	for i=1, heartCount do
		local nearPos = Isaac.GetFreeNearPosition(player.Position, 25)
		Isaac.Spawn(5, 2000, 0, nearPos, Vector(0,0), player)
	end
end
ARACHNAMOD:addPostItemGetFunction(collectingCandyFloss, bossItem.CANDY_FLOSS)