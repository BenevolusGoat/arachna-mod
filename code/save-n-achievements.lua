local mod = ARACHNAMOD
local game = ARACHNAMOD.game
local sfx = ARACHNAMOD.sfx

-- == SAVING DATA == 
mod.Globals = {}

local function getYearDiff()
	if not ARACHNAMOD.luadebug then
		return 1
	else
		local diff = (tonumber(os.date("%Y")) - 2022)
		if diff <= 0 then diff = 1 end
		return diff
	end
end

function ARACHNAMOD.resetData()
	mod.Globals.goldenDudeRoom = {}
	mod.Globals.goldenDudeSubType = {}
	mod.Globals.goldenDudePosX = {}
	mod.Globals.goldenDudePosY = {} 
	mod.Globals.goldenDudeBombedTimes = {}
	mod.Globals.goldenDudeBombedMax = {}

	mod.Globals.geptameronDay = 1	
	
	mod.Globals.goldenDudeRNG = RNG()
	mod.Globals.spiderboiRNG = RNG()
	mod.Globals.garbageRNG = RNG()
	
	mod.Globals.yearDiff = getYearDiff()
end

function ARACHNAMOD.resetRNGSeeds()
	local startSeed = game:GetSeeds():GetStartSeed()
	mod.Globals.goldenDudeRNG:SetSeed(startSeed, 35)
	mod.Globals.spiderboiRNG:SetSeed(startSeed, 35)
	mod.Globals.garbageRNG:SetSeed(startSeed, 35)
end

ARACHNAMOD.resetData()
mod.Globals.lastWillChosenID = 0

function ARACHNAMOD.resetDataPlayer()
	for i=0, game:GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(i)
		local data = mod:GetData(player)
		data.eggOrbitals = 0
		player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
		player:EvaluateItems()
		data.caughtBossType = -1
		data.caughtBossVariant = -1
		data.caughtBossSubType = -1
		rerollMechEyeActive(player)
		data.hasAbaddon = 0
		data.hasDeadCat = 0
		data.usedStrength = 0
	end
end

mod.SavedData = {}
local json = require("json")
function ARACHNAMOD.clearSavedData()
	mod.SavedData.goldenDudeRoom = {}
	mod.SavedData.goldenDudeSubType = {}
	mod.SavedData.goldenDudePosX = {}
	mod.SavedData.goldenDudePosY = {}
	mod.SavedData.goldenDudeBombedTimes = {}
	mod.SavedData.goldenDudeBombedMax = {}
	
	mod.SavedData.playerOrbitalEggs = {}
	
	mod.SavedData.caughtBossType = {}
	mod.SavedData.caughtBossVariant = {}
	mod.SavedData.caughtBossSubType = {}
	
	mod.SavedData.geptameronDay = 1
	
	mod.SavedData.mechEyeItem = {}
	
	mod.SavedData.playerWebHealth = {}
	mod.SavedData.hasAbaddon = {}
	mod.SavedData.hasDeadCat = {}
	mod.SavedData.usedStrength = {}
	
	mod.SavedData.goldenDudeRNG_Seed = 0
	mod.SavedData.spiderboiRNG_Seed = 0
	mod.SavedData.garbageRNG_Seed = 0
	
	mod.SavedData.yearDiff = 0
end
ARACHNAMOD.clearSavedData()
mod.SavedData.lastWillChosenID = 0

function ARACHNAMOD.saveData()
	ARACHNAMOD.clearSavedData()
	for i=1, #mod.Globals.goldenDudeRoom do	
		if mod.Globals.goldenDudeRoom[i] ~= nil then
			mod.SavedData.goldenDudeRoom[i] = mod.Globals.goldenDudeRoom[i]
			mod.SavedData.goldenDudeSubType[i] = mod.Globals.goldenDudeSubType[i]
			mod.SavedData.goldenDudePosX[i] = mod.Globals.goldenDudePosX[i]
			mod.SavedData.goldenDudePosY[i] = mod.Globals.goldenDudePosY[i]
			mod.SavedData.goldenDudeBombedTimes[i] = mod.Globals.goldenDudeBombedTimes[i]
			mod.SavedData.goldenDudeBombedMax[i] = mod.Globals.goldenDudeBombedMax[i]
		end
	end
	mod.SavedData.geptameronDay = mod.Globals.geptameronDay
	mod.SavedData.lastWillChosenID = mod.Globals.lastWillChosenID
	for i=0, game:GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(i)
		local data = mod:GetData(player)
		mod.SavedData.playerOrbitalEggs[tostring(i)] = data.eggOrbitals
		mod.SavedData.caughtBossType[tostring(i)] = data.caughtBossType
		mod.SavedData.caughtBossVariant[tostring(i)] = data.caughtBossVariant
		mod.SavedData.caughtBossSubType[tostring(i)] = data.caughtBossSubType
		mod.SavedData.mechEyeItem[tostring(i)] = data.mechEyeItem
		mod.SavedData.hasAbaddon[tostring(i)] = data.hasAbaddon
		mod.SavedData.hasDeadCat[tostring(i)] = data.hasDeadCat
		mod.SavedData.usedStrength[tostring(i)] = data.usedStrength
	end
	mod.SavedData.goldenDudeRNG_Seed = mod.Globals.goldenDudeRNG:GetSeed()
	mod.SavedData.spiderboiRNG_Seed = mod.Globals.spiderboiRNG:GetSeed()
	mod.SavedData.garbageRNG_Seed = mod.Globals.garbageRNG:GetSeed()
	mod.SavedData.yearDiff = mod.Globals.yearDiff
	mod.SaveData(mod, json.encode(mod.SavedData))
end

function ARACHNAMOD.loadData()
	mod.SavedData = json.decode(Isaac.LoadModData(mod))
	for i=1, #mod.SavedData.goldenDudeRoom do	
		if mod.SavedData.goldenDudeRoom[i] ~= nil then
			mod.Globals.goldenDudeRoom[i] = mod.SavedData.goldenDudeRoom[i]
			mod.Globals.goldenDudeSubType[i] = mod.SavedData.goldenDudeSubType[i]
			mod.Globals.goldenDudePosX[i] = mod.SavedData.goldenDudePosX[i]
			mod.Globals.goldenDudePosY[i] = mod.SavedData.goldenDudePosY[i]
			mod.Globals.goldenDudeBombedTimes[i] = mod.SavedData.goldenDudeBombedTimes[i]
			mod.Globals.goldenDudeBombedMax[i] = mod.SavedData.goldenDudeBombedMax[i]
		end
	end
	mod.Globals.geptameronDay = mod.SavedData.geptameronDay
	if (mod.SavedData.lastWillChosenID) and (mod.SavedData.lastWillChosenID ~= 0) then
		mod.Globals.lastWillChosenID = mod.SavedData.lastWillChosenID
	end
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
		data.caughtBossType = mod.SavedData.caughtBossType[tostring(i)]
		data.caughtBossVariant = mod.SavedData.caughtBossVariant[tostring(i)]
		data.caughtBossSubType = mod.SavedData.caughtBossSubType[tostring(i)]
		data.mechEyeItem = mod.SavedData.mechEyeItem[tostring(i)]
		if mod.SavedData.playerWebHealth[tostring(i)] == nil then mod.SavedData.playerWebHealth[tostring(i)] = 0 end
		data.hasAbaddon = mod.SavedData.hasAbaddon[tostring(i)]
		data.hasDeadCat = mod.SavedData.hasDeadCat[tostring(i)]
	end
	mod.Globals.goldenDudeRNG:SetSeed(mod.SavedData.goldenDudeRNG_Seed, 35)
	mod.Globals.spiderboiRNG:SetSeed(mod.SavedData.spiderboiRNG_Seed, 35)
	mod.Globals.garbageRNG:SetSeed(mod.SavedData.garbageRNG_Seed, 35)
	mod.Globals.yearDiff = mod.SavedData.yearDiff
end

function mod:gameStart0(player) 
	if player.Index == 0 then
		--ON CONTINUE
		if game:GetFrameCount() > 0 then
			if game:GetRoom():GetFrameCount() <= 2 then -- STILL WORK ON CONTINUE, BUT DON'T TRIGGER WHEN CREATING OTHER PLAYERS (SOUL OF JE, DEVIL DEALS, ETC)
				--load data
				if mod:HasData() then
					ARACHNAMOD.loadData()
				end
			end
		--ON GAME START
		else
			ARACHNAMOD.resetDataPlayer()
			ARACHNAMOD.resetData()
			ARACHNAMOD.resetRNGSeeds()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.gameStart0)

function mod:gameEnd(shouldSave) 
	for i=0, game:GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(i)
		arachnaClearStrength(player)
	end
	if shouldSave then
		mod.saveData()
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.gameEnd)

-- == UNLOCKS == 
local unlockStuff = {
	SPRINDLE = Isaac.GetTrinketIdByName("Sprindle"), 
	INFESTED_PENNY = Isaac.GetTrinketIdByName("Infested Penny"), 
	WHITE_STRING = Isaac.GetTrinketIdByName("White String"), 
	
	MERGED_CARD = Isaac.GetCardIdByName("Merged Card"), 
	ARACHNA_SOUL = Isaac.GetCardIdByName("Soul of Arachna"), 
	
	ARACHNA_SPOOL = Isaac.GetItemIdByName("Arachna's Spool"), 
	THE_YARN = Isaac.GetItemIdByName("The Yarn"), 
	ARACHNIDS_GRIP = Isaac.GetItemIdByName("Arachnid's Grip"), 
	YARN_HEART = Isaac.GetItemIdByName("Yarn Heart"), 
	MECHANICAL_EYE = Isaac.GetItemIdByName("Mechanical Eye"), 
	GEPTAMERON = Isaac.GetItemIdByName("Geptameron"), 
	GLASSES_3D = Isaac.GetItemIdByName("3D Glasses"), 
	MUTAGEN = Isaac.GetItemIdByName("Mutagen"), 
	TESTAMENT = Isaac.GetItemIdByName("Testament"), 
	LIL_ARACHNA = Isaac.GetItemIdByName("Lil Arachna"), 
	DIVINE_CLOTH = Isaac.GetItemIdByName("Divine Cloth"), 
	DADS_NEWSPAPER = Isaac.GetItemIdByName("Dad's Newspaper"), 
	BBB = Isaac.GetItemIdByName("Best Bud Ball"), 
	
	SPIDER_DONUT = Isaac.GetItemIdByName(" Spider Donut "), 
	CANDY_FLOSS = Isaac.GetItemIdByName("Candy Floss"), 
	GUMMY_SPIDERS = Isaac.GetItemIdByName("Gummy Spiders"), 
	OLD_SHOEBOX = Isaac.GetItemIdByName("Old Shoebox"), 
	
	SHOPKEEPER_GOLDEN = Isaac.GetEntityVariantByName("Golden Shopkeeper"), 
	SPIDER_BEGGAR = Isaac.GetEntityVariantByName("Spiderboi (beggar)"), 
	WEB_HEART = Isaac.GetEntityVariantByName("Web Heart"), 
	WEB_HEART_DOUBLE = Isaac.GetEntityVariantByName("Web Heart (Double)"), 
}

unlockAPI:LockTaintedChar("Arachna", "Arachna", "gfx/characters/costumes/character_arachna_b.png", "arachna_normal/tainted")

unlockAPI:LockEntity("Arachna", false, UnlockReq.REQ_MOMSHEART, false, "WEB HEARTS", "arachna_normal/momsheart", true, 5, unlockStuff.WEB_HEART, 0)
unlockAPI:LockEntity("Arachna", false, UnlockReq.REQ_MOMSHEART, false, "BOSS ITEM 1", "arachna_normal/momsheart", false, 5, 100, unlockStuff.SPIDER_DONUT)
unlockAPI:LockEntity("Arachna", false, UnlockReq.REQ_MOMSHEART, false, "BOSS ITEM 2", "arachna_normal/momsheart", false, 5, 100, unlockStuff.CANDY_FLOSS)
unlockAPI:LockEntity("Arachna", false, UnlockReq.REQ_MOMSHEART, false, "BOSS ITEM 3", "arachna_normal/momsheart", false, 5, 100, unlockStuff.GUMMY_SPIDERS)
unlockAPI:LockEntity("Arachna", false, UnlockReq.REQ_MOMSHEART, false, "BOSS ITEM4 ", "arachna_normal/momsheart", false, 5, 100, unlockStuff.OLD_SHOEBOX)

unlockAPI:LockEntity("Arachna", false, UnlockReq.REQ_GREED, false, "INFESTED PENNY", "arachna_normal/greed", true, 5, 350, unlockStuff.INFESTED_PENNY)
unlockAPI:LockEntity("Arachna", false, UnlockReq.REQ_GREED, true, "EXTRA SPECIAL SHOPKEEPERS", "arachna_normal/greedier", true, 1000, unlockStuff.SHOPKEEPER_GOLDEN, 0)
unlockAPI:LockEntity("Arachna", false, UnlockReq.REQ_DARKROOM, false, "WHITE STRING", "arachna_normal/darkroom", true, 5, 350, unlockStuff.WHITE_STRING)
unlockAPI:LockEntity("Arachna", false, UnlockReq.REQ_HUSH, false, "ARACHNID'S GRIP", "arachna_normal/hush", true, 5, 100, unlockStuff.ARACHNIDS_GRIP)
unlockAPI:LockEntity("Arachna", false, UnlockReq.REQ_CHEST, false, "3D GLASSES", "arachna_normal/chest", true, 5, 100, unlockStuff.GLASSES_3D)
unlockAPI:LockEntity("Arachna", false, UnlockReq.REQ_BOSSRUSH, false, "GEPTAMERON", "arachna_normal/br", true, 5, 100, unlockStuff.GEPTAMERON)
unlockAPI:LockEntity("Arachna", false, UnlockReq.REQ_BEAST, false, "TESTAMENT", "arachna_normal/beast", true, 5, 100, unlockStuff.TESTAMENT)
unlockAPI:LockEntity("Arachna", false, UnlockReq.REQ_MEGASATAN, false, "MECHANICAL EYE", "arachna_normal/megasatan", true, 5, 100, unlockStuff.MECHANICAL_EYE)
unlockAPI:LockEntity("Arachna", false, UnlockReq.REQ_DELIRIUM, false, "MUTAGEN", "arachna_normal/delirium", true, 5, 100, unlockStuff.MUTAGEN)
unlockAPI:LockEntity("Arachna", false, UnlockReq.REQ_ISAAC, false, "ARACHNA'S SPOOL", "arachna_normal/isaac", true, 5, 100, unlockStuff.ARACHNA_SPOOL)
unlockAPI:LockEntity("Arachna", false, UnlockReq.REQ_SATAN, false, "THE YARN", "arachna_normal/satan", true, 5, 100, unlockStuff.THE_YARN)
unlockAPI:LockEntity("Arachna", false, UnlockReq.REQ_WITNESS, false, "YARN HEART", "arachna_normal/witness", true, 5, 100, unlockStuff.YARN_HEART)
unlockAPI:LockEntity("Arachna", false, UnlockReq.REQ_ALL, true, "LIL ARACHNA", "arachna_normal/all", true, 5, 100, unlockStuff.LIL_ARACHNA)

unlockAPI:LockEntity("Arachna", true, UnlockReq.REQ_BEAST, true, "BEST BUD BALL", "arachna_alt/beast", true, 5, 100, unlockStuff.BBB)
unlockAPI:LockEntity("Arachna", true, UnlockReq.REQ_DELIRIUM, true, "DIVINE CLOTH", "arachna_alt/delirium", true, 5, 100, unlockStuff.DIVINE_CLOTH)
unlockAPI:LockEntity("Arachna", true, UnlockReq.REQ_MEGASATAN, true, "SPIDER BEGGAR", "arachna_alt/megasatan", true, 6, unlockStuff.SPIDER_BEGGAR, 0)
unlockAPI:LockEntity("Arachna", true, UnlockReq.REQ_TWOPATHS, true, "SPRINDLE", "arachna_alt/twopaths", true, 5, 350, unlockStuff.SPRINDLE)
unlockAPI:LockEntity("Arachna", true, UnlockReq.REQ_WITNESS, true, "DAD'S NEWSPAPER", "arachna_alt/witness", true, 5, 100, unlockStuff.DADS_NEWSPAPER)
unlockAPI:LockEntity("Arachna", true, UnlockReq.REQ_GREED, true, "MERGED CARD", "arachna_alt/greedier", true, 5, 300, unlockStuff.MERGED_CARD, "card")
unlockAPI:LockEntity("Arachna", true, UnlockReq.REQ_HUSHBR, true, "SOUL OF ARACHNA", "arachna_alt/hush+br", true, 5, 300, unlockStuff.ARACHNA_SOUL, "rune")

--spawn entities
local function ValidShopKeeperVariant(variant)
    if variant == 0 -- Base shopkeeper
    or variant == 1 -- Hanging Shoopkeeper
    or variant == 3 -- Special Shoopkeeper (Nickle eyes)
    or variant == 4 then -- Hanging Special Shoopkeeper
        return true
    end
    return false
end

function mod:replaceStuffOnSpawn(entType, variant, subType, pos, velocity, spawnerEntity, seed)
	--golden shopkeeper
	if (entType == 17) and ValidShopKeeperVariant(variant) and (subType ~= 6969) and (subType ~= 2000) and (seed ~= 4354) then --shopkeeper, but not an EID test, testament or I am error one
		if (not unlockAPI:IsEntityLocked(1000, unlockStuff.SHOPKEEPER_GOLDEN, 0)) then
			local room = game:GetRoom()
			local roomidx = game:GetLevel():GetCurrentRoomDesc().SafeGridIndex
			if (room:GetType() == RoomType.ROOM_SHOP) then
				local rng = RNG()
				rng:SetSeed(seed, 35)
				local randomNum = rng:RandomFloat()
				local replaceChance = 20
				if randomNum <= replaceChance/100 then
					return {1000, unlockStuff.SHOPKEEPER_GOLDEN, 0}
				end
			end
		end
	--spider beggar
	elseif (entType == 6) and ((variant == 4) or (variant == 7)) then --normal or key beggar
		if (not unlockAPI:IsEntityLocked(6, unlockStuff.SPIDER_BEGGAR, 0)) then
			local rng = RNG()
			rng:SetSeed(seed, 35)
			local randomNum = rng:RandomFloat()
			local replaceChance = 20
			if randomNum <= replaceChance/100 then
				return {6, unlockStuff.SPIDER_BEGGAR, 0}
			end
		end
	--web heart
	elseif (game:GetRoom():GetType() ~= RoomType.ROOM_SUPERSECRET) and (entType == 5) and (variant == 10) and ((subType == 6) or (subType == 10) or (subType == 11) or (subType == 12)) then --black, blended, bone, rotten
		if (not unlockAPI:IsEntityLocked(5, unlockStuff.WEB_HEART, 0)) then
			--replace other hearts
			local rng = RNG()
			rng:SetSeed(seed, 35)
			local randomNum = rng:RandomFloat()
			local replaceChance = 20
			--increase replace chance if someone has sprindle
			if SomeoneHasTrinket(Isaac.GetTrinketIdByName("Sprindle")) then
				replaceChance = 30
			end
			if randomNum <= replaceChance/100 then		
				--single or double
				local randomNumTwo = rng:RandomFloat()
				if randomNumTwo <= 5/100 then
					return {5, unlockStuff.WEB_HEART_DOUBLE, 0} 
				else
					return {5, unlockStuff.WEB_HEART, 0} 
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, mod.replaceStuffOnSpawn)

-- == DEBUG COMMANDS == 
local function arachnaSetAllUnlocks(_num)
	for i=1, 2 do
		local tainted = false
		if i==2 then tainted = true end
		for req=1, UnlockReq.REQ_ALL do
			unlockAPI:SetUnlockState(req, "Arachna", tainted, 2)
		end
	end
end

function mod:unlocksOnCmd(cmd, text)
	if cmd == "arachnaMod" then
		if text == "unlockall" then
			arachnaSetAllUnlocks(2)
			Isaac.ConsoleOutput("Done! \n")
		elseif text == "unlocktainted" then
			unlockAPI:SetUnlockState(UnlockReq.REQ_TAINTED, "Arachna", false, 2)
		elseif text == "lockall" then
			arachnaSetAllUnlocks(0)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, mod.unlocksOnCmd)