if unlockAPI then return end
unlockAPI = RegisterMod("TSC Unlocks API", 1)
Isaac.ConsoleOutput("TSC Unlocks API v0.2: ")

local mod = unlockAPI
local game = Game()
local sfx = SFXManager()

UnlockReq = {
	REQ_MOMSHEART = 1,
	REQ_ISAAC = 2, 
	REQ_SATAN = 3, 
	REQ_CHEST = 4, 
	REQ_DARKROOM = 5, 
	REQ_BOSSRUSH = 6, 
	REQ_HUSH = 7, 
	REQ_MEGASATAN = 8, 
	REQ_WITNESS = 9, 
	REQ_BEAST = 10, 
	REQ_DELIRIUM = 11, 
	REQ_GREED = 12, 
	REQ_TWOPATHS = 13, 
	REQ_HUSHBR = 14, 
	REQ_TAINTED = 15, 
	REQ_ALL = 16,
	REQ_CHALLENGE = 17, 
	REQ_MAX = 18
}
local debugNames = {"heart", "isaac", "satan", "chest", "darkroom", "br", "hush", "megasatan", "witness", "beast", "delirium", "greed", "2paths", "hush+br", "tainted", "all", "max"}

local bossBeaten = {}
for i=1, UnlockReq.REQ_MAX-1 do
	bossBeaten[i] = {}
end

local lockedEntity = {
	id = {}, 
	variant = {}, 
	subtype = {}, 
	character = {}, 
	req = {}, 
	hm = {}, 
	name = {}, 
	paper = {}, 
	visual = {}, 
	pickuptype = {}
}

-- SAVE DATA
--[[
mod.SavedData = {}
mod.SavedData.UnlockData = {} 
for i=1, UnlockReq.REQ_MAX-1 do
	mod.SavedData.UnlockData[i] = {}
end

local json = require("json")

local function saveUnlockData()
	for i=1, UnlockReq.REQ_MAX-1 do
		for j=1, #bossBeaten do
			mod.SavedData.UnlockData[i][j] = bossBeaten[i][j]
		end
	end
	mod.SaveData(mod, json.encode(mod.SavedData))
end

local function loadUnlockData()
	mod.SavedData = json.decode(Isaac.LoadModData(mod))
	for i=1, UnlockReq.REQ_MAX-1 do
		for j=1, #bossBeaten do
			bossBeaten[i][j] = mod.SavedData.UnlockData[i][j]
		end
	end
end

function mod:gameStart0(player)
	if player.Index == 0 then
		if game:GetRoom():GetFrameCount() <= 2 then
			loadUnlockData()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.gameStart0)

function mod:gameEnd(shouldSave) 
	if shouldSave then
		saveUnlockData()
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.gameEnd)
]]

-- CODE
-- internal functions
local function IsTainted(_player)
	local charType = _player:GetPlayerType()
	local charName = _player:GetName()
	if charType == Isaac.GetPlayerTypeByName(charName, false) then
		return false
	else
		return true
	end
end

local function GetPlayerUnlockName(_player)
	local charName = "0"
	if IsTainted(_player) then
		charName = "1"
	end
	charName = charName .. _player:GetName()
	return charName
end

local function GetPlayerUnlockName2(_charname, _isTainted)
	if not _isTainted then
		return "0" .. _charname
	else
		return "1" .. _charname
	end
end

local function GetUnlockIndexByName(_name)
	for i=1, #lockedEntity.id do
		if (lockedEntity.name[i] == _name) then
			return i
		end
	end
	return nil
end

local function GetUnlockIndexByID(_type, _variant, _subtype)
	for i=1, #lockedEntity.id do
		if (lockedEntity.id[i] == _type) and (lockedEntity.variant[i] == _variant) and (lockedEntity.subtype[i] == _subtype) then
			return i
		end
	end
	return nil
end

local function GetPlayerDataFromUnlockName(_unlockname)
	local unlockIndex = GetUnlockIndexByName(_unlockname)
	local fullName = lockedEntity.character[unlockIndex]
	local isTainted = false
	if fullName[1] == "1" then
		isTainted = true
	end
	return {fullName:sub(2), isTainted}
end

local function PlayerHasThisReq(_req)
	local charName = GetPlayerUnlockName(Isaac.GetPlayer(0))
	for i=1, #lockedEntity.id do
		if (lockedEntity.character[i] == charName) and (lockedEntity.req[i] == _req) then
			return true
		end
	end
	return false
end

local function VisualUnlock(_unlockname, _paper)
	if GiantBookAPI then
		GiantBookAPI.ShowAchievement(_paper)
	else
		local hud = game:GetHUD()
		hud:ShowItemText(_unlockname, "HAS APPEARED IN THE BASEMENT")
	end
end

local function GetUnlockState(_req, _name, _tainted)
	local charName = GetPlayerUnlockName2(_name, _tainted)
	local unlock = bossBeaten[_req][charName]
	if (not unlock) or (unlock == 0) then
		return 0
	else
		return unlock
	end
end

local function IsHardMode()
	local difficulty = game.Difficulty
	if (difficulty == Difficulty.DIFFICULTY_NORMAL) or (difficulty == Difficulty.DIFFICULTY_GREED) then
		return false
	else
		return true
	end
end

-- avaible functions
function unlockAPI:LockEntity(_charname, _isTainted, _req, _hm, _name, _paperSprite, _shouldVisualize, _id, _var, _subtype, _pickupType)
	local index = #lockedEntity.id + 1
	if _hm then
		lockedEntity.hm[index] = 2
	else
		lockedEntity.hm[index] = 1
	end
	if _pickupType then
		lockedEntity.pickuptype[index] = _pickupType
	else
		lockedEntity.pickuptype[index] = nil
	end
	lockedEntity.character[index] = GetPlayerUnlockName2(_charname, _isTainted)
	lockedEntity.req[index] = _req
	lockedEntity.name[index] = _name
	lockedEntity.paper[index] = _paperSprite
	lockedEntity.visual[index] = _shouldVisualize
	lockedEntity.id[index] = _id
	lockedEntity.variant[index] = _var
	lockedEntity.subtype[index] = _subtype
end

function unlockAPI:IsEntityLocked(_type, _variant, _subtype)
	for i=1, #lockedEntity.id do
		if (lockedEntity.id[i] == _type) and (lockedEntity.variant[i] == _variant) and (lockedEntity.subtype[i] == _subtype) then
			local realPlayer = GetPlayerDataFromUnlockName(lockedEntity.name[i])
			if GetUnlockState(lockedEntity.req[i], realPlayer[1], realPlayer[2]) ~= lockedEntity.hm[i] then
				return true
			end
		end
	end
	return false
end

function unlockAPI:SetUnlockState(_req, _name, _tainted, _num)
	bossBeaten[_req][GetPlayerUnlockName2(_name, _tainted)] = _num
end

--another unavaible function but I have to put it below locked check
local function NaturalUnlockUpdate(_req)
	local hmVal = 1
	if IsHardMode() then
		hmVal = 2
	end
	
	local charName = GetPlayerUnlockName(Isaac.GetPlayer(0))
	local curMark = bossBeaten[_req][charName]
	if not curMark then curMark = 0 end
	if curMark < hmVal then
		--animation
		for i=1, #lockedEntity.id do
			if (lockedEntity.character[i] == charName) and (lockedEntity.req[i] == _req) and (hmVal >= lockedEntity.hm[i]) then
				if unlockAPI:IsEntityLocked(lockedEntity.id[i], lockedEntity.variant[i], lockedEntity.subtype[i]) and lockedEntity.visual[i] then
					VisualUnlock(lockedEntity.name[i], lockedEntity.paper[i])
				end
			end
		end
		--evaluate
		bossBeaten[_req][charName] = hmVal
	end
end

-- boss kill check
function mod:marksBossDeath(npc)
	local stageNum = game:GetLevel():GetStage()
	if (game:GetVictoryLap() == 0) then
		--MOM'S HEART
		if stageNum == LevelStage.STAGE4_2 then
			if (npc.Type == 78) and ((npc.Variant == 0) or (npc.Variant == 1)) then
				NaturalUnlockUpdate(UnlockReq.REQ_MOMSHEART)
			end
		elseif stageNum == LevelStage.STAGE5 then
			--ISAAC
			if (npc.Type == 102) and (npc.Variant == 0) then
				NaturalUnlockUpdate(UnlockReq.REQ_ISAAC)
			--SATAN
			elseif (npc.Type == 84) then
				NaturalUnlockUpdate(UnlockReq.REQ_SATAN)
			end
		elseif stageNum == LevelStage.STAGE6 then
			--CHEST (1/2)
			if (npc.Type == 102) and (npc.Variant == 1) then
				blueBabyIsDead = true
			--DARK ROOM (1/2)
			elseif (npc.Type == 273) then
				lambIsDead = true
			--MEGA SATAN
			elseif (npc.Type == 275) and (npc.Variant == 0) then
				NaturalUnlockUpdate(UnlockReq.REQ_MEGASATAN)			
			end
		--DELIRIUM
		elseif (stageNum == LevelStage.STAGE7) then
			if (npc.Type == 412) then
				NaturalUnlockUpdate(UnlockReq.REQ_DELIRIUM)			
			end
		--WITNESS
		elseif (stageNum == LevelStage.STAGE4_1 or stageNum == LevelStage.STAGE4_2) then
			if (npc.Type == 912) and (npc.Variant == 10) then
				NaturalUnlockUpdate(UnlockReq.REQ_WITNESS) 				
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.marksBossDeath)

function mod:marksConstantCheck()
	local room = game:GetRoom()
	local stage = game:GetLevel()
	if game:GetVictoryLap() == 0 then
		if stage:GetStage() == LevelStage.STAGE6 and room:GetType() == RoomType.ROOM_BOSS and room:IsClear() then
			--CHEST (2/2)
			if blueBabyIsDead then
				NaturalUnlockUpdate(UnlockReq.REQ_CHEST)					
				blueBabyIsDead = false
			--DARK ROOM (2/2)
			elseif lambIsDead then
				NaturalUnlockUpdate(UnlockReq.REQ_DARKROOM)
				lambIsDead = false
			end
		end
		--BOSS RUSH
		if game:GetStateFlag(GameStateFlag.STATE_BOSSRUSH_DONE) and (stage:GetStage() == LevelStage.STAGE3_1 or stage:GetStage() == LevelStage.STAGE3_2) then
			NaturalUnlockUpdate(UnlockReq.REQ_BOSSRUSH)				
		end
		--HUSH
		if game:GetStateFlag(GameStateFlag.STATE_BLUEWOMB_DONE) and stage:GetStage() == LevelStage.STAGE4_3 then
			NaturalUnlockUpdate(UnlockReq.REQ_HUSH)				
		end		
		--GREED AND GREEDIER
		if game:IsGreedMode() and stage:GetStage() == LevelStage.STAGE7_GREED then
			if room:GetRoomShape() == RoomShape.ROOMSHAPE_1x2 and room:IsClear() then
				NaturalUnlockUpdate(UnlockReq.REQ_GREED)
			end
		end
		-- CONSTANTLY CHECKED ACHIEVEMENTS
		local player = Isaac.GetPlayer(0)
		local playerName = player:GetName()
		local playerAlt = IsTainted(player)
		--TWO PATHS
		if (GetUnlockState(UnlockReq.REQ_ISAAC, playerName, playerAlt) == 2) and (GetUnlockState(UnlockReq.REQ_SATAN, playerName, playerAlt) == 2) and (GetUnlockState(UnlockReq.REQ_CHEST, playerName, playerAlt) == 2) and (GetUnlockState(UnlockReq.REQ_DARKROOM, playerName, playerAlt) == 2) then
			NaturalUnlockUpdate(UnlockReq.REQ_TWOPATHS)
		end
		--HUSH + BOSS RUSH
		if (GetUnlockState(UnlockReq.REQ_HUSH, playerName, playerAlt) == 2) and (GetUnlockState(UnlockReq.REQ_BOSSRUSH, playerName, playerAlt) == 2) then
			NaturalUnlockUpdate(UnlockReq.REQ_HUSHBR)
		end
		--ALL ON HARD MODE
		if (GetUnlockState(UnlockReq.REQ_MOMSHEART, playerName, playerAlt) == 2) and (GetUnlockState(UnlockReq.REQ_MEGASATAN, playerName, playerAlt) == 2) and 
		(GetUnlockState(UnlockReq.REQ_WITNESS, playerName, playerAlt) == 2) and (GetUnlockState(UnlockReq.REQ_BEAST, playerName, playerAlt) == 2) and 
		(GetUnlockState(UnlockReq.REQ_DELIRIUM, playerName, playerAlt) == 2) and (GetUnlockState(UnlockReq.REQ_GREED, playerName, playerAlt) == 2) and 
		(GetUnlockState(UnlockReq.REQ_HUSHBR, playerName, playerAlt) == 2) and (GetUnlockState(UnlockReq.REQ_TWOPATHS, playerName, playerAlt) == 2) then
			NaturalUnlockUpdate(UnlockReq.REQ_ALL)
		end	
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.marksConstantCheck)

--BEAST
function mod:postDeath(ent)
	NaturalUnlockUpdate(UnlockReq.REQ_BEAST)
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mod.postDeath, EntityType.ENTITY_BEAST)

--morph pickups on spawn
function mod:rerollLockedPickups(pickup)
	if unlockAPI:IsEntityLocked(pickup.Type, pickup.Variant, pickup.SubType) then
		--trinkets
		if pickup.Variant == 350 then
			pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, true, false, true)
		--cards/runes
		elseif pickup.Variant == 300 then
			local index = GetUnlockIndexByID(pickup.Type, pickup.Variant, pickup.SubType)
			local rune = 0 --would always spawn only CARDS
			if (lockedEntity.pickuptype[index]) and (lockedEntity.pickuptype[index] == "rune") then --morph runes into runes
				rune = game:GetItemPool():GetCard(pickup.InitSeed, false, true, true)
			end
			pickup:Morph(5, 300, rune, true, false, true)
		--items
		elseif pickup.Variant == 100 then
			local pool = game:GetItemPool():GetPoolForRoom(game:GetRoom():GetType(), game:GetSeeds():GetStartSeed())
			if pool == ItemPoolType.POOL_NULL then
				pool = ItemPoolType.POOL_TREASURE
			end
			local newItem = game:GetItemPool():GetCollectible(pool, true, pickup.InitSeed)
			pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, newItem, true, false, true)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.rerollLockedPickups)

-- TAINTED CHAR LOCK SYSTEM 
local postCS = false

local lockedTainted = {
	id = {}, 
	name = {}, 
	og = {}, 
	sprite = {}, 
	paper = {}
}

function unlockAPI:LockTaintedChar(_ogname, _taintedname, _taintedspritesheet, _paper)
	local index = #lockedTainted.id+1
	lockedTainted.id[index] = index 
	lockedTainted.name[index] = _taintedname 
	lockedTainted.og[index] = _ogname 
	lockedTainted.sprite[index] = _taintedspritesheet
	lockedTainted.paper[index] = _paper 
end

--unavaible functions
local function spawnLayingIsaac(_sprite)
	local room = game:GetRoom()
	local roomCenter = room:GetCenterPos() + Vector(0, 0)
	--removals
	local toRemove = {5, 6, 17}
	for i=1, #toRemove do
		for _, ent in pairs(Isaac.FindByType(toRemove[i])) do
			ent:Remove()
		end
	end
	--tainted laying isaac
	local isaacLay = Isaac.Spawn(6, 14, 0, roomCenter, Vector(0,0), nil)
	isaacLay:GetSprite():ReplaceSpritesheet(0, _sprite)
	isaacLay:GetSprite():LoadGraphics()
end

local function getLockedTSprite(_player)
	if IsTainted(_player) then return nil end
	local thisCharName = _player:GetName()
	for i=1, #lockedTainted.id do
		if (thisCharName == lockedTainted.og[i]) then
			return lockedTainted.sprite[i]
		end
	end
	return nil
end

function unlockAPI:isLockedTainted(_player)
	if not IsTainted(_player) then return nil end
	local thisCharName = _player:GetName()
	for i=1, #lockedTainted.id do
		if (thisCharName == lockedTainted.name[i]) and (GetUnlockState(UnlockReq.REQ_TAINTED, lockedTainted.og[i], false) ~= 2) then
			return i
		end
	end
	return nil
end

local function getPaperFromOG(_player)
	if IsTainted(_player) then return nil end
	local thisCharName = _player:GetName()
	for i=1, #lockedTainted.id do
		if (thisCharName == lockedTainted.og[i]) then
			return lockedTainted.paper[i]
		end
	end
	return nil
end

-- LOCKER SEQUENCE CODE
function mod:lockerSequenceQuit() --quit
	if postCS then
		for i=0, game:GetNumPlayers()-1 do
			local player = Isaac.GetPlayer(i)
			player.Visible = false
			player.ControlsEnabled = false
			local controllerid = player.ControllerIndex
			if Input.IsActionTriggered(ButtonAction.ACTION_MENUBACK, controllerid) then
				postCS = false
				game:Fadeout(1.0/0.0,1)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.lockerSequenceQuit)

local function doLockerSequence() -- locker sequence (1/3)
	--don't execute in greed mode
	if game.Difficulty < Difficulty.DIFFICULTY_GREED then
		local playerZero = Isaac.GetPlayer(0)
		local level = game:GetLevel()
		--open the door
		Isaac.ExecuteCommand("stage 13")
		level:ChangeRoom(95)
		playerZero.Position = Vector(245, 280)
		playerZero:SetPocketActiveItem(CollectibleType.COLLECTIBLE_RED_KEY, ActiveSlot.SLOT_POCKET2)
		playerZero:UseActiveItem(CollectibleType.COLLECTIBLE_RED_KEY, UseFlag.USE_OWNED + UseFlag.USE_NOANIM, ActiveSlot.SLOT_POCKET2)
		playerZero:RemoveCollectible(CollectibleType.COLLECTIBLE_RED_KEY)
		sfx:Stop(SoundEffect.SOUND_UNLOCK00)
		--set
		postCS = true
	end
end

function mod:teleportToOpenedDoor() -- locker sequence (2/3)
	if postCS then
		Isaac.GetPlayer(0).Position = Vector(160, 280)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.teleportToOpenedDoor)

function mod:taintedNewRoom(pickup) -- locker sequence (3/3)
	if postCS then
		local room = game:GetRoom()
		--player changes
		for _, p in pairs(Isaac.FindByType(1)) do
			local player = p:ToPlayer()
			player:GetData().pauseCS = true
		end
		--laying isaac
		spawnLayingIsaac(lockedTainted.sprite[unlockAPI:isLockedTainted(Isaac.GetPlayer(0))])
		--door clear
		local door = room:GetDoor(2)
		if door then
			room:RemoveGridEntity(door:GetGridIndex(), 0)
		end
		--invisible hud
		game:GetHUD():SetVisible(false)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.taintedNewRoom)

-- TAINTED CHAR LOCK IMPLEMENTATION
function mod:lockedTaintedSequencePlay2()
	local isLocked = unlockAPI:isLockedTainted(Isaac.GetPlayer(0))
	if (isLocked ~= nil) and (game:GetLevel():GetStage() == 1) then
		doLockerSequence(lockedTainted.sprite[IsLocked])
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.lockedTaintedSequencePlay2)

-- TAINTED CHAR UNLOCK IMPLEMENTATION
function mod:spawnInCloset()
	local room = game:GetRoom()
	if (game:GetLevel():GetStage() == 13) and (room:GetRoomShape() == 2) and (room:GetBackdropType() == 53) and (game:GetRoom():IsFirstVisit()) then
		local player = Isaac.GetPlayer(0)
		local laySprite = getLockedTSprite(player)
		if (laySprite) and (GetUnlockState(UnlockReq.REQ_TAINTED, player:GetName(), false) ~= 2) then
			spawnLayingIsaac(laySprite)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.spawnInCloset)

function mod:layingIsaacUpdate()
	local tainteds = Isaac.FindByType(6, 14)
	for _, ent in pairs(tainteds) do
		local player = Isaac.GetPlayer(0)
		local laySprite = getLockedTSprite(player)
		if laySprite then
			local sprite = ent:GetSprite()
			local data = ent:GetData()

			if not data.init then
				sprite:ReplaceSpritesheet(0, laySprite)
				sprite:LoadGraphics()
				data.init = true
			end

			if sprite:IsFinished("PayPrize") then
				unlockAPI:SetUnlockState(UnlockReq.REQ_TAINTED, player:GetName(), false, 2)
				VisualUnlock("TAINTED " .. player:GetName(), getPaperFromOG(player))
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.layingIsaacUpdate)

-- DEBUG
local debugRender = false
function mod:debugUnlockRender()
	if debugRender then
		local player = Isaac.GetPlayer(0)
		local playerName = player:GetName()
		local playerAlt = IsTainted(player)
		Isaac.RenderText(GetPlayerUnlockName(player) .. " " .. tostring(IsTainted(player)), 50, 20, 1, 1, 1, 255)
		for i=1, UnlockReq.REQ_MAX-1 do
			local line = tostring(i) .. ". " .. debugNames[i] .. ": " .. tostring(GetUnlockState(i, playerName, playerAlt))
			Isaac.RenderText(line, 50, 30 + 10*i, 1, 1, 1, 255)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.debugUnlockRender)

function mod:onCmd(cmd, text)
	if cmd == "unlockapi" then
		if text == "render" then
			if not debugRender then 
				debugRender = true
				Isaac.ConsoleOutput("Flag Enabled!" .. "\n")	
			else
				debugRender = false
				Isaac.ConsoleOutput("Flag Disabled" .. "\n")	
			end
		--[[
		elseif text == "cutscenetest" then
			doLockerSequence("gfx/characters/costumes/character_001b_isaac.png")
		]]
		end
	end
end
mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, mod.onCmd)

--TODO: Save Data
--TODO: Pause Menu Completion Marks
--https://github.com/ConnorForan/PauseScreenCompletionMarksAPI

Isaac.ConsoleOutput("Loaded!\n")
