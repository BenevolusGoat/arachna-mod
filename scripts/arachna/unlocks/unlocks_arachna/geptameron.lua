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

GEPTAMERON.WEEK_NAME = {
	[GEPTAMERON.WeekEffect.MONDAY] = "Mighty Monday",
	[GEPTAMERON.WeekEffect.TUESDAY] = "Terrific Tuesday",
	[GEPTAMERON.WeekEffect.WEDNESDAY] = "Wise Wednesday",
	[GEPTAMERON.WeekEffect.THURSDAY] = "Torrid Thursday",
	[GEPTAMERON.WeekEffect.FRIDAY] = "Fleeting Friday",
	[GEPTAMERON.WeekEffect.SATURDAY] = "Sanguineous Saturday",
	[GEPTAMERON.WeekEffect.SUNDAY] = "Stingy Sunday"
}

function GEPTAMERON:GetDayOfTheWeek()
	local run_save = Mod.SaveManager.GetRunSave()
	if not run_save.GeptameronWeek then
		run_save.GeptameronWeek = 0
	end
	return run_save.GeptameronWeek
end

---@param itemId CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param useFlags UseFlag
---@param slot ActiveSlot
---@param customVarData integer
function GEPTAMERON:OnUse(itemId, rng, player, useFlags, slot, customVarData)
	if Mod.GetSetting(Mod.Setting.GeptameronGiantbook)
		and (not Mod:HasBitFlags(useFlags, UseFlag.USE_OWNED) or player:GetEffects():GetCollectibleEffectNum(GEPTAMERON.ID) == 0)
	then
		ItemOverlay.Show(GEPTAMERON.OVERLAY, 3, player)
	end
	Mod.sfxman:Play(SoundEffect.SOUND_SUPERHOLY)
	local effect = Mod:HasBitFlags(useFlags, UseFlag.USE_CUSTOMVARDATA) and customVarData or player:GetActiveItemDesc(slot).VarData
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

function GEPTAMERON:UpdateVarDataOnCollectibleAdd(itemId, charge, firstTime, slot, varData, player)
	player:SetActiveVarData(GEPTAMERON:GetDayOfTheWeek(), slot)
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, GEPTAMERON.UpdateVarDataOnCollectibleAdd)

function GEPTAMERON:OnRoomClear()
	if not PlayerManager.AnyoneHasCollectible(GEPTAMERON.ID) then return end
	local nextDay = GEPTAMERON:GetDayOfTheWeek() + 1
	if nextDay >= GEPTAMERON.WeekEffect.NUM_EFFECTS then
		nextDay = GEPTAMERON.WeekEffect.MONDAY
	end
	local run_save = Mod.SaveManager.GetRunSave()
	run_save.GeptameronWeek = nextDay
	Mod.Foreach.Player(function (player, index)
		local slots = Mod:GetActiveItemSlots(player, GEPTAMERON.ID)
		for _, slot in ipairs(slots) do
			player:SetActiveVarData(nextDay, slot)
		end
	end)
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, CallbackPriority.LATE, GEPTAMERON.OnRoomClear)
Mod:AddCallback(ModCallbacks.MC_POST_START_GREED_WAVE, GEPTAMERON.OnRoomClear)