local Mod = ARACHNAMOD

local TAINTED_UNLOCK = {}

local function checkArachnaTaintedLocked()
	local player = Isaac.GetPlayer()
	local playerType = player:GetPlayerType()
	return playerType == Mod.PlayerType.ARACHNA and not Mod.PersistGameData:Unlocked(Mod.Character.ARACHNA_B.ACHIEVEMENT)
end

function TAINTED_UNLOCK:OnClosetEntry()
	if not REPENTOGON then return end
	local level = Mod.Level()
	local room = Mod.Room()

	if level:GetStage() == LevelStage.STAGE8 --Home
		and level:GetCurrentRoomIndex() == 94 --Closet
		and room:IsFirstVisit()
		and checkArachnaTaintedLocked()
	then
		local innerChild = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE,
			CollectibleType.COLLECTIBLE_INNER_CHILD)[1]
		local shopKeeper = Isaac.FindByType(EntityType.ENTITY_SHOPKEEPER)[1]

		if innerChild then
			innerChild:Remove()
		elseif shopKeeper then
			shopKeeper:Remove()
		end

		local player = Isaac.GetPlayer()
		Mod.Spawn.Slot(SlotVariant.HOME_CLOSET_PLAYER, room:GetCenterPos(), player)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, TAINTED_UNLOCK.OnClosetEntry)

---@param slot EntitySlot
function TAINTED_UNLOCK:CryingTaintedSpriteOnInit(slot)
	local player = Isaac.GetPlayer()
	if player:GetPlayerType() == Mod.PlayerType.ARACHNA then
		local sprite = slot:GetSprite()
		sprite:ReplaceSpritesheet(0, player:GetEntityConfigPlayer():GetTaintedCounterpart():GetSkinPath(), true)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_SLOT_INIT, TAINTED_UNLOCK.CryingTaintedSpriteOnInit, SlotVariant.HOME_CLOSET_PLAYER)

---@param slot EntitySlot
function TAINTED_UNLOCK:UnlockTainted(slot)
	if checkArachnaTaintedLocked() then
		local sprite = slot:GetSprite()
		local unlock_table = Mod.PlayerTypeToCompletionTable[Mod.PlayerType.ARACHNA]
		local tainted = unlock_table[Mod.CompletionType.TAINTED]
		if sprite:IsFinished("PayPrize") then
			Mod.PersistGameData:TryUnlock(tainted)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, TAINTED_UNLOCK.UnlockTainted, SlotVariant.HOME_CLOSET_PLAYER)
