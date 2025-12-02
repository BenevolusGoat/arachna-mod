--#region Variables

local Mod = ARACHNAMOD

local TESTAMENT = {}

ARACHNAMOD.Item.TESTAMENT = TESTAMENT

TESTAMENT.ID = Isaac.GetItemIdByName("Testament")

TESTAMENT.SPAWNER_ID = Isaac.GetEntityTypeByName("Testament Spawner")
TESTAMENT.SPAWNER_VAR = Isaac.GetEntityVariantByName("Testament Spawner")
TESTAMENT.SPAWNER_SUB = Isaac.GetEntitySubTypeByName("Testament Spawner")

TESTAMENT.REPLACER_VAR = Isaac.GetEntityVariantByName("Testament Replacer")
TESTAMENT.REPLACER_SUB = Isaac.GetEntityVariantByName("Testament Replacer")

TESTAMENT.ITEMS_PER_ROOM = 6

TESTAMENT.MAX_NEXT_RUN_ITEMS = 2

--Duration of initial on-use effect and threshold when you start teleporting back.
--Is multiplied by 2 for controls cooldown as it updates 60fps as opposed to 30fps
TESTAMENT.IMMOBILE_DURATION = 20

--Kid named "I'm too lazy to give this pedestal save data for the sole purpose of giving it a different cool sprite but also it's what the original code did so who am I to judge"
TESTAMENT.GAME_START_PEDESTAL_INITSEED = 4442004

TESTAMENT.PEDESTAL_POSITIONS = {
	[1] = {Vector(320, 400)},
	[2] = {Vector(240, 280), Vector(400, 280)},
	[3] = {Vector(240, 280), Vector(400, 280), Vector(320, 400)},
	[4] = {Vector(240, 200), Vector(400, 200), Vector(240, 360), Vector(400, 360)},
	[5] = {Vector(240, 240), Vector(400, 240), Vector(240, 320), Vector(400, 320), Vector(320, 400)},
	[6] = {Vector(240, 200), Vector(240, 280), Vector(240, 360), Vector(400, 200), Vector(400, 280), Vector(400, 360)},
}

local inTheRoom = false
local testamentRoomIndex = 0
local lastDir = Direction.NO_DIRECTION
local doNotTeleport = false

--#endregion

--#region Helpers

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
		blacklist = Mod:Set({game_save.TestamentItems})
	end
	blacklist[TESTAMENT.ID] = true
	for _, historyItem in ipairs(player:GetHistory():GetCollectiblesHistory()) do
		if not historyItem:IsTrinket() and not blacklist[historyItem:GetItemID()] then
			return true
		end
	end
	return false
end

function TESTAMENT:IsInTestamentRoom()
	return inTheRoom
end

---@param pedestal EntityPickup
function TESTAMENT:IsNewGameTestamentPedestal(pedestal)
	local level = Mod.Level()
	return pedestal.InitSeed == TESTAMENT.GAME_START_PEDESTAL_INITSEED
		and level:GetStage() == LevelStage.STAGE1_1
		and level:GetStageType() < StageType.STAGETYPE_REPENTANCE
		and level:GetCurrentRoomIndex() == level:GetStartingRoomIndex()
end

---@param player EntityPlayer
function TESTAMENT:CopyPlayerInventory(player)
	local item_list = {}
	for _, historyItem in ipairs(player:GetHistory():GetCollectiblesHistory()) do
		if not historyItem:IsTrinket() and historyItem:GetItemID() ~= TESTAMENT.ID then
			Mod.Insert(item_list, historyItem:GetItemID())
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

function TESTAMENT:TeleportToTestamentRoom()
	Mod.sfxman:Play(SoundEffect.SOUND_DEATH_CARD, 0, 2)
	Mod.Game:ShowHallucination(5, 0)
	Mod.sfxman:Play(SoundEffect.SOUND_STATIC, 0.8)
	Isaac.ExecuteCommand("goto s.shop.20000")
end

--#endregion

--#region On Use

---@param player EntityPlayer
---@param itemId CollectibleType
---@param useFlags UseFlag
function TESTAMENT:PreUseItem(itemId, rng, player, useFlags, slot)
	--[[ local canUse = TESTAMENT:CanUseItem(player)
	if not canUse then
		if not Mod:HasBitFlags(useFlags, UseFlag.USE_NOANIM) then
			player:AnimateCollectible(itemId, "UseItem", "PlayerPickup")
		end
		Mod.sfxman:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
		--Shouldn't be using this item as it serves no purpose otherwise
		if Mod.Game:AchievementUnlocksDisallowed() and slot ~= -1 and player:GetActiveItem(slot) == itemId then
			player:RemoveCollectible(itemId, false, slot, true)
			Mod.Spawn.Poof01(0, player.Position)
		end
		return true
	end ]]
end

--Mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, TESTAMENT.PreUseItem)

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
	if itemConfigItem:IsCollectible() and itemConfigItem.ID == TESTAMENT.ID then
		local floor_save = Mod.SaveManager.GetFloorSave()
		floor_save.TestamentRoomIndex = Mod.Level():GetCurrentRoomIndex()
		TESTAMENT:TeleportToTestamentRoom()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_EFFECT_REMOVED, TESTAMENT.TeleportOnPlayerEffectEnd)

--#endregion

--#region Enter Testament Room

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
		inTheRoom = true
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
			local pedestal = Mod.Spawn.Collectible(itemId, spawnPositions[i + 1])
			if blacklist[itemId] then
				pedestal:TryRemoveCollectible()
			else
				pedestal.OptionsPickupIndex = 1
				pedestal:Morph(pedestal.Type, pedestal.Variant, pedestal.SubType, true, true, true)
			end
		end
		Mod.Room():SetBackdropType(BackdropType.SACRIFICE, 1)
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
	local gridEnt = Mod.Room():GetGridEntityFromPos(player.Position)
	local door = gridEnt and gridEnt:ToDoor()
	if door then
		Mod:DebugLog("Testament: Exiting room through door! Setup next teleport.")
		local doorSlot = door.Slot
		local roomShift = doorSlot == DoorSlot.UP0 and -1 or 1
		lastDir = doorSlot == DoorSlot.UP0 and Direction.UP or Direction.DOWN
		testamentRoomIndex = testamentRoomIndex + roomShift
		TESTAMENT:TeleportToTestamentRoom()
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, TESTAMENT.PreExitRoom)

function TESTAMENT:ResetRoomStatus()
	if TESTAMENT:IsInTestamentRoom() then
		local roomDesc = Mod.Level():GetRoomByIdx(GridRooms.ROOM_DEBUG_IDX, -1)
		--Because otherwise it sticks even when generating new rooms
		roomDesc.Flags = Mod:RemoveBitFlags(roomDesc.Flags, RoomDescriptor.FLAG_CURSED_MIST)
	end
	inTheRoom = false
end

Mod:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, TESTAMENT.ResetRoomStatus)

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
	if itemConfigItem:IsCollectible() and itemConfigItem.ID == TESTAMENT.ID then
		Mod.Game:StartRoomTransition(Mod.SaveManager.GetFloorSave().TestamentRoomIndex, Direction.NO_DIRECTION, RoomTransitionAnim.FADE)
		Mod.sfxman:Play(SoundEffect.SOUND_DEATH_CARD, 0, 2)
		Mod.Game:ShowHallucination(5, 0)
		Mod.sfxman:Play(SoundEffect.SOUND_STATIC, 0.8)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ROOM_TRIGGER_EFFECT_REMOVED, TESTAMENT.ReturnToRegularDimension)

--#endregion

--#region Pedestal Handling

---@param pedestal EntityPickup
function TESTAMENT:OnPedestalInit(pedestal)
	if (TESTAMENT:IsInTestamentRoom() or TESTAMENT:IsNewGameTestamentPedestal(pedestal))
		and Mod.Room():GetFrameCount() <= 0
	then
		local sprite = pedestal:GetSprite()
		sprite:ReplaceSpritesheet(4, "gfx/items/lastwill-pedestal.png") -- empty shadow
		sprite:ReplaceSpritesheet(5, "gfx/items/lastwill-pedestal.png") -- pedestal itself
		sprite:LoadGraphics()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, TESTAMENT.OnPedestalInit, PickupVariant.PICKUP_COLLECTIBLE)

---@param pedestal EntityPickup
function TESTAMENT:PreventConsumingItem(pedestal)
	if TESTAMENT:IsInTestamentRoom() then
		if pedestal.OptionsPickupIndex == 1
			and not Mod.Room():GetEffects():HasCollectibleEffect(TESTAMENT.ID)
		then
			--This should hopefully prevent it from being targeted by literally anything as game thinks its about to disappear.
			--This is before I decided "wait, the curse mist could solve all my problems" but this is a precautionary measure just in case.
			pedestal.Timeout = 2
		elseif pedestal.SubType == 0 then
			pedestal.Timeout = 0
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, TESTAMENT.PreventConsumingItem, PickupVariant.PICKUP_COLLECTIBLE)

---@param pickup EntityPickup
function TESTAMENT:PreventMorph(pickup)
	if TESTAMENT:IsInTestamentRoom() and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
		return {pickup.Type, pickup.Variant, pickup.SubType, true, true, true}
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_MORPH, CallbackPriority.IMPORTANT, TESTAMENT.PreventMorph)

---@param pedestal EntityPickup
---@param collider Entity
function TESTAMENT:PrePedestalCollision(pedestal, collider)
	local player = collider:ToPlayer()
	if player
		and TESTAMENT:IsInTestamentRoom()
		and pedestal.SubType ~= CollectibleType.COLLECTIBLE_NULL
		and player:IsExtraAnimationFinished()
		and player.ItemHoldCooldown == 0
		and not pedestal.Touched
	then
		Mod:DebugLog("Testament: Collected pedestal. Removing other pedestals and doors")
		if not Mod.Game:AchievementUnlocksDisallowed() then
			local game_save = Mod.SaveManager.GetPersistentSave()
			---@cast game_save table
			game_save.TestamentItems = game_save.TestamentItems or {}
			Mod.Insert(game_save.TestamentItems, pedestal.SubType)
		end
		local itemConfigItem = Mod.ItemConfig:GetCollectible(pedestal.SubType)
		local effects = Mod.Room():GetEffects()
		player:AnimateCollectible(pedestal.SubType)
		Mod.Game:GetHUD():ShowItemText(player, itemConfigItem)
		pedestal:TryRemoveCollectible()
		pedestal:TriggerTheresOptionsPickup()
		effects:AddCollectibleEffect(TESTAMENT.ID)
		effects:GetCollectibleEffect(TESTAMENT.ID).Cooldown = 120
		Mod.Game:ShakeScreen(16)
		Mod.Game:Darken(1, 80)
		Mod.Foreach.Door(function (door, doorSlot)
			Mod.Spawn.Poof01(0, door.Position)
			Mod.Room():RemoveDoor(doorSlot)
		end)
		Mod.sfxman:Play(SoundEffect.SOUND_CHOIR_UNLOCK, 0.5)
		return true
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.IMPORTANT, TESTAMENT.PrePedestalCollision, PickupVariant.PICKUP_COLLECTIBLE)

--#endregion

--#region Spawn Testament items on new room

---@param isContinued boolean
function TESTAMENT:OnGameStart(isContinued)
	if not isContinued and not Mod.Game:AchievementUnlocksDisallowed() then
		local game_save = Mod.SaveManager.GetPersistentSave()
		if game_save and game_save.TestamentItems then
			local room = Mod.Room()
			Mod:DebugLog("Spawning items from previous Testament run")
			for _, itemId in ipairs(game_save.TestamentItems) do
				Mod:DebugLog("Spawning item ID", itemId)
				local pos = room:FindFreePickupSpawnPosition(Vector(120, 200))
				Mod.Spawn.Collectible(itemId, pos, Isaac.GetPlayer(), TESTAMENT.GAME_START_PEDESTAL_INITSEED)
				Mod.Spawn.Poof01(0, pos)
			end
			game_save.TestamentItems = nil
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, TESTAMENT.OnGameStart)

--#endregion