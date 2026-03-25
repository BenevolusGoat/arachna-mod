--#region Variables

local Mod = ARACHNAMOD

local TESTAMENT = {}

ARACHNAMOD.Item.TESTAMENT = TESTAMENT

TESTAMENT.ID = Isaac.GetItemIdByName("The Testament")

--Applied to a player when using the item, teleports them to The Testament room
--
--Applied to the room, teleports them back to the original room they used it in.
local TESTAMENT_CONFIG = Mod.ItemConfig:GetCollectible(TESTAMENT.ID)

TESTAMENT.SPAWNER_ID = Isaac.GetEntityTypeByName("Testament Spawner")
TESTAMENT.SPAWNER_VAR = Isaac.GetEntityVariantByName("Testament Spawner")
TESTAMENT.SPAWNER_SUB = Isaac.GetEntitySubTypeByName("Testament Spawner")

TESTAMENT.REPLACER_VAR = Isaac.GetEntityVariantByName("Testament Replacer")
TESTAMENT.REPLACER_SUB = Isaac.GetEntityVariantByName("Testament Replacer")

TESTAMENT.PEDESTAL_VAR = Isaac.GetEntityVariantByName("Testament Pedestal")

TESTAMENT.ITEMS_PER_ROOM = 6

TESTAMENT.MAX_NEXT_RUN_ITEMS = 2

--Duration of initial on-use effect and threshold when you start teleporting back.
--Is multiplied by 2 for controls cooldown as it updates 60fps as opposed to 30fps
TESTAMENT.IMMOBILE_DURATION = 20

TESTAMENT.PEDESTAL_POSITIONS = {
	[1] = {Vector(320, 400)},
	[2] = {Vector(240, 280), Vector(400, 280)},
	[3] = {Vector(240, 280), Vector(400, 280), Vector(320, 400)},
	[4] = {Vector(240, 200), Vector(400, 200), Vector(240, 360), Vector(400, 360)},
	[5] = {Vector(240, 240), Vector(400, 240), Vector(240, 320), Vector(400, 320), Vector(320, 400)},
	[6] = {Vector(240, 200), Vector(240, 280), Vector(240, 360), Vector(400, 200), Vector(400, 280), Vector(400, 360)},
}

local testamentRoomIndex = 0
local lastDir = Direction.NO_DIRECTION
local doNotTeleport = false
local musicman = MusicManager()
local overrideMusic = false

--#endregion

--#region Helpers

---@param historyItem HistoryItem
function TESTAMENT:IsValidTestamentItem(historyItem)
	local item = historyItem:GetItemID()
	return not historyItem:IsTrinket()
		and historyItem:GetTime() > 0
		and item ~= TESTAMENT.ID
		and not Mod.ItemConfig:GetCollectible(historyItem:GetItemID()):HasTags(ItemConfig.TAG_QUEST)
end

---@param player EntityPlayer
function TESTAMENT:CanUseItem(player)
	if Mod.Game:AchievementUnlocksDisallowed() then
		return false
	end
	local game_save = Mod.SaveManager.GetPersistentSave()
	local blacklist = {}
	if game_save and game_save.TestamentItems then
		if #game_save.TestamentItems >= TESTAMENT.MAX_NEXT_RUN_ITEMS then
			return false
		end
		blacklist = Mod:Set(game_save.TestamentItems)
	end
	blacklist[TESTAMENT.ID] = true
	for _, historyItem in ipairs(player:GetHistory():GetCollectiblesHistory()) do
		if TESTAMENT:IsValidTestamentItem(historyItem) and not blacklist[historyItem:GetItemID()] then
			return true
		end
	end
	return false
end

function TESTAMENT:IsInTestamentRoom()
	local room = Mod.Room()
	local roomDesc = Mod.Level():GetCurrentRoomDesc()
	return room:GetType() == RoomType.ROOM_SACRIFICE
		and roomDesc.Data.OriginalVariant == 20000
		and roomDesc.Data.Name == "[arachnaMod] lastWill"
end

---@param player EntityPlayer
function TESTAMENT:CopyPlayerInventory(player)
	local hasItem = {}
	local item_list = {}
	for _, historyItem in ipairs(player:GetHistory():GetCollectiblesHistory()) do
		local itemId = historyItem:GetItemID()
		if TESTAMENT:IsValidTestamentItem(historyItem) and not hasItem[itemId] then
			Mod.Insert(item_list, itemId)
			hasItem[itemId] = true
		end
	end
	Mod.SaveManager.GetFloorSave().TestamentInventory = item_list
	Mod:DebugLog("Copied", #item_list, "items for Testament")
end

---@param player EntityPlayer
function TESTAMENT:AnimateTestamentTeleport(player)
	player:AddControlsCooldown(TESTAMENT.IMMOBILE_DURATION * 2)
	player:PlayExtraAnimation("DeathTeleport")
	player.Velocity = Vector.Zero
end

function TESTAMENT:GetNumItemsToSpawn()
	local inventory = Mod.SaveManager.GetFloorSave().TestamentInventory
	if not inventory or not next(inventory) then
		return 0
	end
	local startingIndex = (TESTAMENT.ITEMS_PER_ROOM * testamentRoomIndex) + 1
	for i = 1, TESTAMENT.ITEMS_PER_ROOM - 1 do
		if not inventory[startingIndex + i] then
			return i
		end
	end
	return TESTAMENT.ITEMS_PER_ROOM
end

---@param door GridEntityDoor
function TESTAMENT:UpdateDoorGraphic(door)
	local sprite = door:GetSprite()
	for i = 0, 3 do
		sprite:ReplaceSpritesheet(i, "gfx/effects/lastwill_door.png")
	end
	sprite:LoadGraphics()
end

local function playStatic()
	Mod.sfxman:Play(SoundEffect.SOUND_DEATH_CARD, 0, 2)
	Mod.Game:ShowHallucination(5, 0)
	Mod.sfxman:Play(SoundEffect.SOUND_STATIC, 0.8)
end

function TESTAMENT:TeleportToTestamentRoom()
	playStatic()
	Isaac.ExecuteCommand("goto s.sacrifice.20000")
	musicman:Play(Music.MUSIC_DARK_CLOSET, 1)
	musicman:UpdateVolume()
end

--#endregion

--#region On Use

---@param player EntityPlayer
---@param itemId CollectibleType
---@param useFlags UseFlag
function TESTAMENT:PreUseItem(itemId, rng, player, useFlags, slot)
	if Mod.Level():GetDimension() == Dimension.DEATH_CERTIFICATE
		or Mod.Level():GetCurrentRoomIndex() < 0
	then
		player:AnimateCollectible(TESTAMENT.ID, "UseItem")
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, TESTAMENT.PreUseItem, TESTAMENT.ID)

---@param itemId CollectibleType
---@param rng RNG
---@param player EntityPlayer
function TESTAMENT:OnUse(itemId, rng, player)
	local canUse = TESTAMENT:CanUseItem(player)
	if not canUse then
		local spawnPos = Mod.Room():FindFreePickupSpawnPosition(player.Position, 40)
		Mod.Spawn.Collectible(CollectibleType.COLLECTIBLE_EDENS_BLESSING, spawnPos, player, rng:Next())
		player:AnimateHappy()
		doNotTeleport = true
		player:GetEffects():RemoveCollectibleEffect(itemId, -1)
	else
		doNotTeleport = false
		Mod.Foreach.Player(function (_player, index)
			TESTAMENT:AnimateTestamentTeleport(_player)
		end)
		TESTAMENT:CopyPlayerInventory(player)
		lastDir = Direction.NO_DIRECTION
	end
	return {Discharge = true, Remove = true, ShowAnim = false}
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, TESTAMENT.OnUse, TESTAMENT.ID)

--#endregion

--#region Trigger Teleport to Dimension

---@param player EntityPlayer
---@param itemConfigItem ItemConfigItem
function TESTAMENT:TeleportOnPlayerEffectEnd(player, itemConfigItem)
	if doNotTeleport then
		doNotTeleport = false
		return
	end
	local floor_save = Mod.SaveManager.GetFloorSave()
	floor_save.TestamentRoomIndex = Mod.Level():GetCurrentRoomIndex()
	TESTAMENT:TeleportToTestamentRoom()
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_EFFECT_REMOVED, TESTAMENT.TeleportOnPlayerEffectEnd, TESTAMENT_CONFIG)

--#endregion

--#region Enter Testament Room

---@param pos Vector
---@param itemId CollectibleType
function TESTAMENT:SpawnPedestal(pos, itemId)
	--EID doesn't work with any subtype so I'm just doing this instead
	if itemId == CollectibleType.COLLECTIBLE_NULL then
		local pedestal = Mod.Game:Spawn(EntityType.ENTITY_SLOT, TESTAMENT.PEDESTAL_VAR, pos, Vector.Zero, nil, 10, Mod:Random())
		local sprite = pedestal:GetSprite()
		sprite:ReplaceSpritesheet(4, "")
		sprite:ReplaceSpritesheet(1, "")
		sprite:LoadGraphics()
	else
		local pedestal = Mod.Game:Spawn(EntityType.ENTITY_SLOT, TESTAMENT.PEDESTAL_VAR, pos, Vector.Zero, nil, 0, Mod:Random())
		local sprite = pedestal:GetSprite()
		sprite:ReplaceSpritesheet(4, "gfx/items/lastwill-pedestal.png") -- empty shadow
		EntityPickup.SetupCollectibleGraphics(sprite, 1, itemId, false, Mod:Random())
		sprite:LoadGraphics()
		Mod:GetData(pedestal).TestamentItem = itemId
	end
end

---@param entType EntityType
---@param variant integer
---@param subtype integer
---@param gridIndex integer
---@param seed integer
function TESTAMENT:SetupRoom(entType, variant, subtype, gridIndex, seed)
	if entType == TESTAMENT.SPAWNER_ID
		and variant == TESTAMENT.SPAWNER_VAR
		and subtype == TESTAMENT.SPAWNER_SUB
	then
		Mod:DebugLog("Testament: Entered room with Testament Spawner. Current room index is", testamentRoomIndex)
		local curInventoryIndex = (TESTAMENT.ITEMS_PER_ROOM * testamentRoomIndex) + 1
		local inventory = Mod.SaveManager.GetFloorSave().TestamentInventory
		local itemsToSpawn = TESTAMENT:GetNumItemsToSpawn()
		local spawnPositions = TESTAMENT.PEDESTAL_POSITIONS[itemsToSpawn]
		Mod:DebugLog("Testament: Expecting to spawn", itemsToSpawn, "items")
		local game_save = Mod.SaveManager.GetPersistentSave() ---@cast game_save table
		local blacklist = {}
		if game_save.TestamentItems then
			blacklist = Mod:Set(game_save.TestamentItems)
		end
		for i = 0, itemsToSpawn - 1 do
			local itemId = inventory[curInventoryIndex + i]
			Mod:DebugLog("Testament: Spawning ID", tostring(itemId))
			local pedestalSubtype = blacklist[itemId] and 0 or itemId
			TESTAMENT:SpawnPedestal(spawnPositions[i + 1], pedestalSubtype)
		end
		local roomDesc = Mod.Level():GetRoomByIdx(GridRooms.ROOM_DEBUG_IDX, -1)
		roomDesc.Flags = Mod:AddBitFlags(roomDesc.Flags, RoomDescriptor.FLAG_CURSED_MIST)
		return {TESTAMENT.REPLACER_VAR, TESTAMENT.REPLACER_SUB}
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, TESTAMENT.SetupRoom)

function TESTAMENT:RemoveReplacerEffect(effect)
	if effect.SubType == TESTAMENT.REPLACER_SUB then
		effect:Remove()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, TESTAMENT.RemoveReplacerEffect, TESTAMENT.REPLACER_VAR)

function TESTAMENT:PostEnterTestamentRoom()
	if TESTAMENT:IsInTestamentRoom() then
		Mod:DebugLog("Testament: Handling doors and removing ladders")
		--Remove ladders
		for _, ent in pairs(Isaac.FindByType(1000, 156, -1, false, false)) do
			ent:Remove()
		end
		local curInventoryIndex = (TESTAMENT.ITEMS_PER_ROOM * testamentRoomIndex) + 1
		local nextIndexSet = curInventoryIndex + TESTAMENT.ITEMS_PER_ROOM
		local inventory = Mod.SaveManager.GetFloorSave().TestamentInventory
		local level = Mod.Level()
		local oppositeDoorSlot = level.EnterDoor == DoorSlot.DOWN0 and DoorSlot.UP0 or DoorSlot.DOWN0
		Mod.sfxman:Play(SoundEffect.SOUND_UNLOCK00, 0)
		--This function reopens doors already previously removed. Create both and then remove/update them
		level:MakeRedRoomDoor(GridRooms.ROOM_DEBUG_IDX, oppositeDoorSlot)
		Mod.Foreach.Door(function (door, doorSlot)
			local name = doorSlot == DoorSlot.DOWN0 and "DOWN" or "UP"
			if doorSlot == DoorSlot.DOWN0 and not (inventory[nextIndexSet])
				or doorSlot == DoorSlot.UP0 and testamentRoomIndex == 0
			then
				Mod:DebugLog("Testament: Removing door", name)
				Mod.Room():RemoveDoor(doorSlot)
			else
				Mod:DebugLog("Testament: Updating graphic of door", name)
				TESTAMENT:UpdateDoorGraphic(door)
			end
		end)
		Mod.Foreach.Player(function (player, index)
			if lastDir == Direction.UP then
				player.Position = Vector(320, 400)
			elseif lastDir == Direction.NO_DIRECTION then
				player.Position = Vector(320, 280)
			elseif lastDir == Direction.DOWN then
				player.Position = Vector(320, 160)
			end
		end)
		overrideMusic = false
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, TESTAMENT.PostEnterTestamentRoom)

--#endregion

--#region Exiting Room

---@param player EntityPlayer
---@param newLevel boolean
function TESTAMENT:PreExitRoom(player, newLevel)
	if newLevel
		or not TESTAMENT:IsInTestamentRoom()
		or RoomTransition.GetTransitionMode() == 1 --Exiting room normally, like doors
	then
		return
	end
	local debugRoomDesc = Mod.Level():GetRoomByIdx(GridRooms.ROOM_DEBUG_IDX, -1)
	debugRoomDesc.Flags = Mod:RemoveBitFlags(debugRoomDesc.Flags, RoomDescriptor.FLAG_CURSED_MIST)

	local gridEnt = Mod.Room():GetGridEntityFromPos(player.Position)
	local door = gridEnt and gridEnt:ToDoor()
	if door then
		Mod:DebugLog("Testament: Exiting room through door! Setup next teleport.")
		local doorSlot = door.Slot
		local roomShift = doorSlot == DoorSlot.UP0 and -1 or 1
		lastDir = doorSlot == DoorSlot.UP0 and Direction.UP or Direction.DOWN
		testamentRoomIndex = testamentRoomIndex + roomShift
		overrideMusic = true
		TESTAMENT:TeleportToTestamentRoom()
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, TESTAMENT.PreExitRoom)

--#endregion

--#region Exiting Dimension

function TESTAMENT:SleepPlayersNearEndOfEffect()
	if TESTAMENT:IsInTestamentRoom() then
		local effects = Mod.Room():GetEffects()
		local effect = effects:GetCollectibleEffect(TESTAMENT.ID)
		if effect and effect.Cooldown == TESTAMENT.IMMOBILE_DURATION then
			Mod.Foreach.Player(function (player, index)
				TESTAMENT:AnimateTestamentTeleport(player)
			end)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, TESTAMENT.SleepPlayersNearEndOfEffect)

---@param itemConfigItem ItemConfigItem
function TESTAMENT:ReturnToRegularDimension(itemConfigItem)
	testamentRoomIndex = 0
	lastDir = Direction.NO_DIRECTION
	local roomIndex = Mod.SaveManager.GetFloorSave().TestamentRoomIndex
		or Mod.Level():GetStartingRoomIndex()
	Mod.Game:StartRoomTransition(roomIndex, Direction.NO_DIRECTION, RoomTransitionAnim.FADE)
	playStatic()
end

Mod:AddCallback(ModCallbacks.MC_POST_ROOM_TRIGGER_EFFECT_REMOVED, TESTAMENT.ReturnToRegularDimension, TESTAMENT_CONFIG)

--#endregion

--#region Pedestal Handling

---@param pedestal EntityPickup
function TESTAMENT:OnPedestalInit(pedestal)
	local data = Mod:TryGetData(pedestal)
	if data and data.NewGameTestamentPedestal then
		local sprite = pedestal:GetSprite()
		sprite:ReplaceSpritesheet(4, "gfx/items/lastwill-pedestal.png") -- empty shadow
		sprite:ReplaceSpritesheet(5, "gfx/items/lastwill-pedestal.png") -- pedestal itself
		sprite:LoadGraphics()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, TESTAMENT.OnPedestalInit, PickupVariant.PICKUP_COLLECTIBLE)

---@param pedestal EntitySlot
function TESTAMENT:OnSlotPedestalInit(pedestal)
	local sprite = pedestal:GetSprite()
	sprite:SetFrame("Alternates", 0)
	sprite:PlayOverlay("Idle")
	sprite:ReplaceSpritesheet(5, "gfx/items/lastwill-pedestal.png") -- pedestal itself
--[[ 	if pedestal.SubType == 0 then
		sprite:ReplaceSpritesheet(4, "")
		sprite:ReplaceSpritesheet(1, "")
	else
		sprite:ReplaceSpritesheet(4, "gfx/items/lastwill-pedestal.png") -- empty shadow
		EntityPickup.SetupCollectibleGraphics(sprite, 1, pedestal.SubType, false, Mod:Random())
	end ]]
	sprite:LoadGraphics()
end

Mod:AddCallback(ModCallbacks.MC_POST_SLOT_INIT, TESTAMENT.OnSlotPedestalInit, TESTAMENT.PEDESTAL_VAR)

---@param pedestal EntitySlot
---@param collider Entity
function TESTAMENT:OnTestamentPedestalCollision(pedestal, collider)
	local player = collider:ToPlayer()
	local data = Mod:GetData(pedestal)
	if player
		and pedestal.SubType == 0
		and player:IsExtraAnimationFinished()
		and player.ItemHoldCooldown == 0
		and data.TestamentItem
	then
		local item = data.TestamentItem
		local effects = Mod.Room():GetEffects()
		if TESTAMENT:IsInTestamentRoom() then
			Mod:DebugLog("Testament: Collected pedestal item ID", item .. ".", "Removing other pedestals and doors")
			if not Mod.Game:AchievementUnlocksDisallowed() then
				local game_save = Mod.SaveManager.GetPersistentSave()
				---@cast game_save table
				game_save.TestamentItems = game_save.TestamentItems or {}
				Mod.Insert(game_save.TestamentItems, item)
			end
			effects:AddCollectibleEffect(TESTAMENT.ID)
			effects:GetCollectibleEffect(TESTAMENT.ID).Cooldown = 120
			Mod.Game:ShakeScreen(16)
			Mod.Game:Darken(1, 80)
			Mod.Foreach.Door(function (door, doorSlot)
				Mod.Spawn.Poof01(0, door.Position)
				Mod.Room():RemoveDoor(doorSlot)
			end)
		end
		local itemConfigItem = Mod.ItemConfig:GetCollectible(item)
		player:AnimateCollectible(item)
		player:RemoveCollectible(item)
		Mod.Game:GetHUD():ShowItemText(player, itemConfigItem)
		Mod.sfxman:Play(SoundEffect.SOUND_CHOIR_UNLOCK, 0.5)
		pedestal.SubType = 10
		pedestal:GetSprite():ReplaceSpritesheet(1, "")
		pedestal:GetSprite():ReplaceSpritesheet(4, "", true)
		Mod.Foreach.Slot(function (slot, index)
			if GetPtrHash(slot) ~= GetPtrHash(pedestal) then
				slot:Remove()
				Mod.Spawn.Poof01(0, slot.Position)
			end
		end, TESTAMENT.PEDESTAL_VAR, nil, {Inverse = true})
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_SLOT_COLLISION, TESTAMENT.OnTestamentPedestalCollision, TESTAMENT.PEDESTAL_VAR)

---@param slot EntitySlot
function TESTAMENT:PreventBombing(slot)
	slot:SetState(SlotState.IDLE)
end

Mod:AddCallback(ModCallbacks.MC_PRE_SLOT_CREATE_EXPLOSION_DROPS, TESTAMENT.PreventBombing, TESTAMENT.PEDESTAL_VAR)

--#endregion

--#region Spawn Testament items on new room

function TESTAMENT:OnGameStart()
	if Mod.Game:GetFrameCount() == 1 and not Mod.Game:AchievementUnlocksDisallowed() then
		local game_save = Mod.SaveManager.GetPersistentSave()
		if game_save and game_save.TestamentItems then
			local room = Mod.Room()
			Mod:DebugLog("Spawning items from previous Testament run")
			for _, itemId in ipairs(game_save.TestamentItems) do
				Mod:DebugLog("Spawning item ID", itemId)
				local pos = room:FindFreePickupSpawnPosition(Vector(120, 200))
				local pedestal = Mod.Spawn.Collectible(itemId, pos, Isaac.GetPlayer())
				local sprite = pedestal:GetSprite()
				sprite:ReplaceSpritesheet(4, "gfx/items/lastwill-pedestal.png") -- empty shadow
				sprite:ReplaceSpritesheet(5, "gfx/items/lastwill-pedestal.png") -- pedestal itself
				sprite:LoadGraphics()
				Mod:GetData(pedestal).NewGameTestamentPedestal = true
				Mod.Spawn.Poof01(0, pos)
			end
			game_save.TestamentItems = nil
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, TESTAMENT.OnGameStart)

--#endregion

--#region Override music

function TESTAMENT:UpdateMusic()
	if TESTAMENT:IsInTestamentRoom() or overrideMusic then
		return Music.MUSIC_DARK_CLOSET
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_MUSIC_PLAY, TESTAMENT.UpdateMusic)

--#endregion

--#region PANIC IF PEDESTALS ARE GONE

function TESTAMENT:EmergencyExit()
	local room = Mod.Room()
	if TESTAMENT:IsInTestamentRoom()
		and not room:GetEffects():HasCollectibleEffect(TESTAMENT.ID)
		and room:GetFrameCount() > 0
		and RoomTransition.GetTransitionMode() == 0
	then
		local pedestals = Isaac.FindByType(EntityType.ENTITY_SLOT, TESTAMENT.PEDESTAL_VAR)
		local hasItem = false
		for _, ent in ipairs(pedestals) do
			local data = Mod:GetData(ent)
			if data.TestamentItem and data.TestamentItem > 0 then
				hasItem = true
			end
		end
		if hasItem then return end
		local hasDoor = Mod.Foreach.Door(function (door, doorSlot)
			return true
		end) or false
		if hasDoor then return end
		Mod:DebugLog("Pedestals missing! Initiating emergency exit.")
		local effects = room:GetEffects()
		effects:AddCollectibleEffect(TESTAMENT.ID)
		effects:GetCollectibleEffect(TESTAMENT.ID).Cooldown = 120
		Mod.sfxman:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
		Mod.Game:ShakeScreen(16)
		Mod.Game:Darken(1, 80)
		Mod.Foreach.Door(function (door, doorSlot)
			Mod.Spawn.Poof01(0, door.Position)
			Mod.Room():RemoveDoor(doorSlot)
		end)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, TESTAMENT.EmergencyExit)

--#endregion