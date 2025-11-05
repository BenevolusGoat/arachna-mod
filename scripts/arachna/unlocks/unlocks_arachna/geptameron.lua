local Mod = ARACHNAMOD

local GEPTAMERON = {}

ARACHNAMOD.Item.GEPTAMERON = GEPTAMERON

GEPTAMERON.ID = Isaac.GetItemIdByName("Geptameron")
GEPTAMERON.OVERLAY = Isaac.GetGiantBookIdByName("Geptameron")

---@enum GeptameronWeek
GEPTAMERON.WeekEffect = {
	MONDAY = 0,
	TUESDAY = 1,
	WEDNESDAY = 2,
	THURSDAY = 3,
	FRIDAY = 4,
	SATURDAY = 5,
	SUNDAY = 6,
	NUM_EFFECTS = 7
}

---@param itemId CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param useFlags UseFlag
---@param slot any
---@param customVarData any
function GEPTAMERON:OnUse(itemId, rng, player, useFlags, slot, customVarData)
	ItemOverlay.Show(GEPTAMERON.OVERLAY, 3, player)
	Mod.sfxman:Play(SoundEffect.SOUND_SUPERHOLY)
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, GEPTAMERON.OnUse, GEPTAMERON.ID)

---@param player EntityPlayer
---@param slot ActiveSlot
function GEPTAMERON:AdjustCropOffset(player, slot, offset, alpha, scale, chargebarOffset)
	local varData = player:GetActiveItemDesc(slot).VarData
	return {CropOffset = Vector(32 * (varData + 1), 0)}
end

Mod:AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_ACTIVE_ITEM, GEPTAMERON.AdjustCropOffset, GEPTAMERON.ID)

---@param player EntityPlayer
function GEPTAMERON:OnRoomClear(player)
	for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do
		local itemDesc = player:GetActiveItemDesc(slot)
		local nextDay = itemDesc.VarData + 1
		if itemDesc.Item == GEPTAMERON.ID then
			if nextDay == GEPTAMERON.WeekEffect.NUM_EFFECTS then
				player:SetActiveVarData(nextDay - GEPTAMERON.WeekEffect.NUM_EFFECTS, slot)
			else
				player:SetActiveVarData(nextDay, slot)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_ROOM_CLEAR, GEPTAMERON.OnRoomClear)