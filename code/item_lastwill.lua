local mod = ARACHNAMOD
local game = ARACHNAMOD.game
local sfx = ARACHNAMOD.sfx
local lastWillPreUseRoomIdx = -999 --responsible for player positioning
local lastWillWalkDir = "TP" --responsible for player positioning
local lastWillPlayerInvertory = {} --player's inventory
--variables related to spawning in item (except Global ID)
local lastWillPos = 1 
local lastWillRoomItems = {}

--spawn item
function mod:lastWillGameStart(isContinued) 
	if (not isContinued) and (not game:IsGreedMode()) then
		if (mod.Globals.lastWillChosenID) and (mod.Globals.lastWillChosenID ~= 0) then
			local item = game:Spawn(5, 100, Vector(120, 200), Vector(0,0), nil, mod.Globals.lastWillChosenID, 4442004):ToPickup() --using different spawn function for custom init seed 
			Isaac.Spawn(1000, 15, 0, item.Position, Vector(0,0), nil)
			mod.Globals.lastWillChosenID = 0
			mod.SavedData.lastWillChosenID = mod.Globals.lastWillChosenID
			ARACHNAMOD.saveData()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.lastWillGameStart)

--functions
local function reinitLastWillRoomItems()
	lastWillRoomItems = {}
	for i = 0, 5 do
		local invI = lastWillPos + i
		if lastWillPlayerInvertory[invI] then
			lastWillRoomItems[i+1] = lastWillPlayerInvertory[invI]
		end
	end
end

local function isFinalLastWillRoom()
	if (not lastWillRoomItems[lastWillPos+6]) then
		return true
	end
	return false
end

local function getLastWillRoomItemsAmount()
	for i = 2, 6 do
		if (not lastWillRoomItems[i]) then
			return i-1
		end
	end
	return 6
end

local function lastWillTransition(_dir)
	--direction based
	if _dir == "UP" then
		lastWillPos = lastWillPos - 6
	elseif _dir == "DOWN" then
		lastWillPos = lastWillPos + 6
	elseif _dir == "TP" then
		--set variables
		lastWillPos = 1
		lastWillPreUseRoomIdx = game:GetLevel():GetCurrentRoomDesc().SafeGridIndex
	end
	--always
	lastWillWalkDir = _dir
	reinitLastWillRoomItems()
	Isaac.ExecuteCommand("goto s.shop.20000")
end
--cooldowns
local lastWillControlsCooldown = -1
local lastWillTPCooldown = -1
local lastWillTPDirection = "IN"

function mod:lastWillCoolDowns()
	--TELEPORT
	--go down
	if lastWillTPCooldown > 0 then
		lastWillTPCooldown = lastWillTPCooldown - 1
	end
	--teleport
	if (lastWillTPCooldown == 0) then
		--visual
		game:ShowHallucination(5, 0)
		sfx:Stop(SoundEffect.SOUND_DEATH_CARD)
		sfx:Play(SoundEffect.SOUND_STATIC,0.8,0,false,1)
		--action
		if lastWillTPDirection == "IN" then
			lastWillTransition("TP")
		elseif lastWillTPDirection == "OUT" then
			game:StartRoomTransition(lastWillPreUseRoomIdx, Direction.NO_DIRECTION, RoomTransitionAnim.FADE)
		end
		lastWillTPCooldown = -1
	end
	--CONTROLS
	--go down
	if lastWillControlsCooldown > 0 then
		lastWillControlsCooldown = lastWillControlsCooldown - 1
	end
	--enable controls
	if (lastWillControlsCooldown == 0) then
		for i=0, game:GetNumPlayers()-1 do
			local player = Isaac.GetPlayer(i)
			player.ControlsEnabled = true
		end
		lastWillControlsCooldown = -1
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.lastWillCoolDowns)

--room creation (I'm using shopkeeper and not a simple variable so the thing won't get broken by teleporting items and good timings)
local isNewLastWillRoom = false

function mod:buildLastWillRoom(npc)
	if npc.Variant == 2 and npc.SubType == 2000 then
		isNewLastWillRoom = true
		npc:Remove()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.buildLastWillRoom, 17)

function mod:buildLastWillRoom2()
	--on new last will room
	if (isNewLastWillRoom == true) then
		--remove ladder
		for _, ent in pairs(Isaac.FindByType(1000, 156, -1, false, false)) do
			ent:Remove()
		end
		--remove door
		local room = game:GetRoom()
		for gridpos=1, room:GetGridSize() do
			local grid = room:GetGridEntity(gridpos)
			if (grid ~= nil) and (grid:ToDoor()) then
				room:RemoveGridEntity(gridpos, 0, false)
				Isaac.GridSpawn(GridEntityType.GRID_WALL, 0, room:GetGridPosition(gridpos), true)
			end
		end
		--place items (make beautiful positions for all item amounts). ik that it could be done without this copying but with for loops, but I'm too lazy for that shit, sorry
		local itemAmount = getLastWillRoomItemsAmount()
		if itemAmount == 1 then
			Isaac.Spawn(1000, 2006, lastWillRoomItems[1], Vector(320, 400), Vector(0,0), nil)
		elseif itemAmount == 2 then
			Isaac.Spawn(1000, 2006, lastWillRoomItems[1], Vector(240, 280), Vector(0,0), nil)
			Isaac.Spawn(1000, 2006, lastWillRoomItems[2], Vector(400, 280), Vector(0,0), nil)
		elseif itemAmount == 3 then
			Isaac.Spawn(1000, 2006, lastWillRoomItems[1], Vector(240, 280), Vector(0,0), nil)
			Isaac.Spawn(1000, 2006, lastWillRoomItems[2], Vector(400, 280), Vector(0,0), nil)
			Isaac.Spawn(1000, 2006, lastWillRoomItems[3], Vector(320, 400), Vector(0,0), nil)
		elseif itemAmount == 4 then
			Isaac.Spawn(1000, 2006, lastWillRoomItems[1], Vector(240, 200), Vector(0,0), nil)
			Isaac.Spawn(1000, 2006, lastWillRoomItems[2], Vector(400, 200), Vector(0,0), nil)
			Isaac.Spawn(1000, 2006, lastWillRoomItems[3], Vector(240, 360), Vector(0,0), nil)
			Isaac.Spawn(1000, 2006, lastWillRoomItems[4], Vector(400, 360), Vector(0,0), nil)
		elseif itemAmount == 5 then
			Isaac.Spawn(1000, 2006, lastWillRoomItems[1], Vector(240, 240), Vector(0,0), nil)
			Isaac.Spawn(1000, 2006, lastWillRoomItems[2], Vector(400, 240), Vector(0,0), nil)
			Isaac.Spawn(1000, 2006, lastWillRoomItems[3], Vector(240, 320), Vector(0,0), nil)
			Isaac.Spawn(1000, 2006, lastWillRoomItems[4], Vector(400, 320), Vector(0,0), nil)
			Isaac.Spawn(1000, 2006, lastWillRoomItems[5], Vector(320, 400), Vector(0,0), nil)
		elseif itemAmount == 6 then
			Isaac.Spawn(1000, 2006, lastWillRoomItems[1], Vector(240, 200), Vector(0,0), nil)
			Isaac.Spawn(1000, 2006, lastWillRoomItems[2], Vector(240, 280), Vector(0,0), nil)
			Isaac.Spawn(1000, 2006, lastWillRoomItems[3], Vector(240, 360), Vector(0,0), nil)
			Isaac.Spawn(1000, 2006, lastWillRoomItems[4], Vector(400, 200), Vector(0,0), nil)
			Isaac.Spawn(1000, 2006, lastWillRoomItems[5], Vector(400, 280), Vector(0,0), nil)
			Isaac.Spawn(1000, 2006, lastWillRoomItems[6], Vector(400, 360), Vector(0,0), nil)
		end
		--check should I spawn some door or nah
		local shouldSpawnTopDoor = true
		local shouldSpawnBottomDoor = true
		for i=1, 6 do
			if (lastWillRoomItems[i]) and (lastWillRoomItems[i] == lastWillPlayerInvertory[#lastWillPlayerInvertory]) then
				shouldSpawnBottomDoor = false
				break
			end
		end
		if (lastWillPos == 1) then
			shouldSpawnTopDoor = false
		end
		--spawn doors
		if (shouldSpawnTopDoor) then
			local topDoor = Isaac.Spawn(1000, 2005, 0, Vector(320, 140), Vector(0,0), nil):ToEffect() 
			topDoor:GetSprite():Play("Idle")
		end
		if (shouldSpawnBottomDoor) then
			local bottomDoor = Isaac.Spawn(1000, 2005, 0, Vector(320, 420), Vector(0,0), nil):ToEffect()
			bottomDoor:GetSprite():Play("Idle")
			bottomDoor:GetSprite().Rotation = 180
		end
		--player positioning
		for i=0, game:GetNumPlayers()-1 do
			local player = Isaac.GetPlayer(i)
			if lastWillWalkDir == "UP" then
				player.Position = Vector(320, 400)
			elseif lastWillWalkDir == "TP" then
				player.Position = Vector(320, 280)
			elseif lastWillWalkDir == "DOWN" then
				player.Position = Vector(320, 160)
			end
		end
		--change backdrop
		game:ShowHallucination(0, BackdropType.SACRIFICE) 
		sfx:Stop(SoundEffect.SOUND_DEATH_CARD)
		--set back
		isNewLastWillRoom = false
	end
	--on going back to teh starting room, play appear animation
	local roomidx = game:GetLevel():GetCurrentRoomDesc().SafeGridIndex
	if roomidx == lastWillPreUseRoomIdx then
		for i=0, game:GetNumPlayers()-1 do
			local player = Isaac.GetPlayer(i)
			player:PlayExtraAnimation("Appear")
			player.ControlsEnabled = false
		end
		lastWillControlsCooldown = 20
		lastWillPreUseRoomIdx = -999
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.buildLastWillRoom2)

--collision with custom effects
function mod:lastWillTouchEffects(player)
	--doors
    for _, eff in pairs(Isaac.FindByType(1000, 2005, 0, false, false)) do
		local sprite = eff:GetSprite()
		local data = eff:GetData()
		--travel through door
		if (eff.FrameCount > 0) and ((eff.Position - player.Position):Length() < (16)) and (not data.touchedPlayer) and (sprite:IsPlaying("Idle")) then --adding frame count check so the animation check won't crash the game
			if sprite.Rotation == 180 then
				lastWillTransition("DOWN")
			else
				lastWillTransition("UP")
			end
			data.touchedPlayer = true
		end
	end
	--pedestals
	for _, eff in pairs(Isaac.FindByType(1000, 2006, -1, false, false)) do
		local data = eff:GetData()
		--travel through door
		if ((eff.Position - player.Position):Length() < (16)) and (not data.touchedPlayer) then
			--delete all pedestals
			for _, pedestal in pairs(Isaac.FindByType(1000, 2006, -1, false, false)) do
				pedestal:Remove()
				Isaac.Spawn(1000, 15, 0, pedestal.Position, Vector(0,0), pedestal)
			end
			--set variable
			mod.Globals.lastWillChosenID = eff.SubType
			--close doors
			for _, door in pairs(Isaac.FindByType(1000, 2005, 0, false, false)) do
				door:GetSprite():Play("Close")
			end
			--teleport
			lastWillTPCooldown = 120
			lastWillTPDirection = "OUT"
			--visual
			player:AnimateCollectible(eff.SubType, "Pickup", "PlayerPickupSparkle")
			game:GetHUD():ShowItemText(player, Isaac.GetItemConfig():GetCollectible(eff.SubType))
			sfx:Play(SoundEffect.SOUND_POWERUP_SPEWER,0.8,0,false,1)
			game:ShakeScreen(16)
			game:Darken(1, 80)
			data.touchedPlayer = true
		end	
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.lastWillTouchEffects)

--fake pedestals done as effects (so they won't get affected by fucking enything)
function mod:fakeLastWillPedestalInit(eff)
	local sprite = eff:GetSprite()
	sprite:Play("Idle")
	sprite:ReplaceSpritesheet(0, Isaac.GetItemConfig():GetCollectible(eff.SubType).GfxFileName)
	sprite:LoadGraphics()
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.fakeLastWillPedestalInit, 2006)

--item pedestal sprite
function mod:lastWillPedestalSprite(pickup)
	local roomidx = game:GetLevel():GetCurrentRoomDesc().SafeGridIndex
	if (roomidx == 84) and (pickup.InitSeed == 4442004) then
		local sprite = pickup:GetSprite()
		sprite:ReplaceSpritesheet(4, "gfx/items/lastwill-pedestal.png") -- empty shadow
		sprite:ReplaceSpritesheet(5, "gfx/items/lastwill-pedestal.png") -- pedestal itself
		sprite:LoadGraphics()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.lastWillPedestalSprite, 100)

--on item use
local lastWill = Isaac.GetItemIdByName("Testament")
function mod:lastWillUse(item, rng, player, useflags, slot, customvardata)
	--fill the array of items 
	lastWillPlayerInvertory = {}
	for id=1, Isaac.GetItemConfig():GetCollectibles().Size -1 do
		if (player:HasCollectible(id, true)) and (id ~= lastWill) then
			lastWillPlayerInvertory[#lastWillPlayerInvertory+1] = id
		end
	end
	-- teleport player to the room
	if #lastWillPlayerInvertory > 0 then
		for i=0, game:GetNumPlayers()-1 do
			local player2 = Isaac.GetPlayer(i)
			player2:PlayExtraAnimation("DeathTeleport")
			player2.ControlsEnabled = false
		end
		lastWillControlsCooldown = 20
		lastWillTPCooldown = 20
		lastWillTPDirection = "IN"
	-- if player somehow has nothing in inventory, spawn eden's blessing
	else
		local item = Isaac.Spawn(5, 100, 381, Isaac.GetFreeNearPosition(player.Position, 75), Vector(0,0), nil)
		player:AnimateHappy()
	end
	return  { Discharge = false, Remove = true, ShowAnim = false }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.lastWillUse, lastWill)

--debug
--[[
function mod:randomItemsCmd(cmd, text)
	local command = tostring(cmd)
	local amount = tonumber(text)
	if (command == "randomitems") and (amount) then
		for i=1, amount do
			local randomItem = math.random(1, Isaac.GetItemConfig():GetCollectibles().Size - 1)
			Isaac.GetPlayer(0):AddCollectible(randomItem)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, mod.randomItemsCmd)]]