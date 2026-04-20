--#region Variables

local Mod = ArachnaMod

local MECHANICAL_EYE = {}

ArachnaMod.Item.MECHANICAL_EYE = MECHANICAL_EYE

MECHANICAL_EYE.ID = Isaac.GetItemIdByName("Mechanical Eye")
MECHANICAL_EYE.FAMILIAR = Isaac.GetEntityVariantByName("Mechanical Eye (orbital)")

MECHANICAL_EYE.EFFECT_VAR = Isaac.GetEntityVariantByName("Mechanical Eye Effect")
MECHANICAL_EYE.EFFECT_SUB = Isaac.GetEntitySubTypeByName("Mechanical Eye Effect")

MECHANICAL_EYE.ITEM_TAG = "arachna_nomechanicaleye"

MECHANICAL_EYE.ACTIVE_GENERATE_BLACKLIST = {
	CollectibleType.COLLECTIBLE_BLANK_CARD,
	CollectibleType.COLLECTIBLE_PLACEBO,
	CollectibleType.COLLECTIBLE_CLEAR_RUNE,
	CollectibleType.COLLECTIBLE_PONY,
	CollectibleType.COLLECTIBLE_WHITE_PONY,
	CollectibleType.COLLECTIBLE_CONVERTER,
	CollectibleType.COLLECTIBLE_ESAU_JR,
	CollectibleType.COLLECTIBLE_EVERYTHING_JAR,
	CollectibleType.COLLECTIBLE_FLIP,
	CollectibleType.COLLECTIBLE_RED_KEY,
	CollectibleType.COLLECTIBLE_D4,
	CollectibleType.COLLECTIBLE_D100,
	CollectibleType.COLLECTIBLE_GLASS_CANNON
}

for _, itemID in ipairs(MECHANICAL_EYE.ACTIVE_GENERATE_BLACKLIST) do
	Mod.ItemConfig:GetCollectible(itemID):AddCustomTag(MECHANICAL_EYE.ITEM_TAG)
end

---A list of every valid active, mapped by its max charge
local activeList = {}

--#endregion

--#region Helpers

---Returns if the item is valid for the Mechanical Eye to generate an active of equal charge from.
---@param itemConfig ItemConfigItem
function MECHANICAL_EYE:IsValidItem(itemConfig)
	return itemConfig
		and itemConfig.Type == ItemType.ITEM_ACTIVE
		and itemConfig.ChargeType == ItemConfig.CHARGE_NORMAL
		and itemConfig.MaxCharges > 0
		and itemConfig.MaxCharges <= 12
end

function MECHANICAL_EYE:GenerateActiveChargeList()
	local numCollectibles = #Mod.ItemConfig:GetCollectibles()
	for itemId = 1, numCollectibles do
		local itemConfig = Mod.ItemConfig:GetCollectible(itemId)
		if MECHANICAL_EYE:IsValidItem(itemConfig)
			and not itemConfig:HasCustomTag(MECHANICAL_EYE.ITEM_TAG)
			and not itemConfig:HasTags(ItemConfig.TAG_QUEST)
			and itemConfig:IsAvailable()
		then
			local maxCharges = itemConfig.MaxCharges
			activeList[maxCharges] = (activeList[maxCharges] or {})
			Mod.Insert(activeList[maxCharges], itemId)
		end
	end
end

---@param player EntityPlayer
local function getChargeReference(player)
	local curCharge = player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY)
		+ player:GetBloodCharge()
		+ player:GetSoulCharge()
	local minCharge = player:GetActiveMinUsableCharge(ActiveSlot.SLOT_PRIMARY)
	local maxCharge = player:GetActiveMaxCharge(ActiveSlot.SLOT_PRIMARY)
	return Mod:Clamp(curCharge, minCharge, maxCharge)
end

---@param player EntityPlayer
function MECHANICAL_EYE:HasValidActive(player)
	local itemId = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
	local itemConfig = Mod.ItemConfig:GetCollectible(itemId)
	local curCharge = player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY)
		+ player:GetBloodCharge()
		+ player:GetSoulCharge()
	return MECHANICAL_EYE:IsValidItem(itemConfig)
		and curCharge >= player:GetActiveMinUsableCharge(ActiveSlot.SLOT_PRIMARY)
end

---@param familiar EntityFamiliar
---@param filePath string
function MECHANICAL_EYE:UpdateActiveGraphic(familiar, filePath)
	if Mod:HasBitFlags(Mod.Level():GetCurses(), LevelCurse.CURSE_OF_BLIND) then
		filePath = "gfx/items/collectibles/questionmark.png"
	end
	familiar:GetSprite():ReplaceSpritesheet(2, filePath, true)
end

---@param familiar EntityFamiliar
function MECHANICAL_EYE:GenerateActiveCopy(familiar)
	if not next(activeList) then
		MECHANICAL_EYE:GenerateActiveChargeList()
	end
	local player = familiar.Player
	local primaryActive = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
	if not MECHANICAL_EYE:IsValidItem(Mod.ItemConfig:GetCollectible(primaryActive)) then
		return
	end
	--Make a copy of the list and remove the currently held active
	local itemPool = Mod.Game:GetItemPool()
	local chargeRef = getChargeReference(player)
	local chargeList
	repeat
		Mod:DebugLog("Desired Mechanical Eye charge:", chargeRef)
		chargeList = Mod:FilterList(activeList[chargeRef] or {}, function(val, key)
			--Does not allow the same item or items removed from the pool
			return val ~= primaryActive and itemPool:HasCollectible(val)
		end)
		Mod:DebugLog(#chargeList, "items available in list")
		--If no charges available at the current charge, find charges below it
		if #chargeList == 0 then
			chargeRef = chargeRef - 1
		end
	until chargeRef == 0 or #chargeList > 0
	local data = Mod:GetData(familiar)
	local rng = player:GetCollectibleRNG(MECHANICAL_EYE.ID)
	local item = #chargeList > 0 and chargeList[rng:RandomInt(#chargeList) + 1] or CollectibleType.COLLECTIBLE_POOP
	local familiar_run_save = Mod.SaveManager.GetRunSave(familiar)
	familiar_run_save.MechanicalActive = item
	local itemConfig = Mod.ItemConfig:GetCollectible(item)
	data.MechEyeCurReferenceActive = primaryActive
	data.MechEyeCurReferenceCharge = getChargeReference(player)
	MECHANICAL_EYE:UpdateActiveGraphic(familiar, itemConfig.GfxFileName)
end

--#endregion

--#region Familiar Init/Update

---@param familiar EntityFamiliar
function MECHANICAL_EYE:OnFamiliarInit(familiar)
	if not next(activeList) then
		MECHANICAL_EYE:GenerateActiveChargeList()
	end
	familiar:AddToOrbit(8)
	local familiar_run_save = Mod.SaveManager.GetRunSave(familiar)
	local sprite = familiar:GetSprite()
	if familiar_run_save.MechanicalActive then
		local data = Mod:GetData(familiar)
		local player = familiar.Player
		data.MechEyeCurReferenceActive = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
		data.MechEyeCurReferenceCharge = getChargeReference(player)
		sprite:Play("Opened")
	else
		sprite:Play("Closed")
	end
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, MECHANICAL_EYE.OnFamiliarInit, MECHANICAL_EYE.FAMILIAR)


---@param familiar EntityFamiliar
function MECHANICAL_EYE:OnFamiliarUpdate(familiar)
	local player = familiar.Player
	local sprite = familiar:GetSprite()
	local isValid = MECHANICAL_EYE:HasValidActive(player)
	local data = Mod:GetData(familiar)

	if isValid and sprite:IsPlaying("Closed") then
		sprite:Play("Opening")
		Mod.sfxman:Play(SoundEffect.SOUND_MIRROR_ENTER, 0.6, 2, false, 1.8)
	elseif not isValid and sprite:IsPlaying("Opened") then
		MECHANICAL_EYE:UpdateActiveGraphic(familiar, "")
		sprite:Play("Closing")
		Mod.sfxman:Play(SoundEffect.SOUND_MIRROR_EXIT, 0.6, 2, false, 1.8)
	end

	if sprite:IsFinished("Opening")
		or (
			sprite:IsPlaying("Opened")
			and player:IsExtraAnimationFinished()
			and ((data.MechEyeCurReferenceActive or 0) ~= player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
				or (data.MechEyeCurReferenceCharge or 0) ~= getChargeReference(player))
		)
	then
		MECHANICAL_EYE:GenerateActiveCopy(familiar)
	end

	if sprite:IsFinished("Closing") then
		sprite:Play("Closed")
	elseif sprite:IsFinished("Opening") then
		sprite:Play("Opened")
	end

	familiar.Velocity = familiar:GetOrbitPosition(player.Position) - familiar.Position
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, MECHANICAL_EYE.OnFamiliarUpdate, MECHANICAL_EYE.FAMILIAR)

--#endregion

--#region Use Active

---@param itemId CollectibleType
---@param removed boolean
---@param player EntityPlayer
---@param slot ActiveSlot
function MECHANICAL_EYE:PostDischarge(itemId, removed, player, slot)
	if slot ~= ActiveSlot.SLOT_PRIMARY then return end
	Mod.Foreach.Familiar(function(familiar, index)
		local familiar_run_save = Mod.SaveManager.GetRunSave(familiar)
		local generatedItem = familiar_run_save.MechanicalActive

		player:UseActiveItem(generatedItem, UseFlag.USE_NOANIM, -1)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
			player:UseActiveItem(generatedItem, UseFlag.USE_NOANIM | UseFlag.USE_CARBATTERY, -1)
		end

		local poof = Mod.Spawn.Effect(MECHANICAL_EYE.EFFECT_VAR, MECHANICAL_EYE.EFFECT_SUB, familiar.Position, nil, familiar)
		poof.SpriteScale = familiar.SpriteScale
		poof:FollowParent(familiar)
		local name = Mod.ItemConfig:GetCollectible(generatedItem).Name
		local localizedStr = Isaac.GetString(StringTableCategory.ITEMS, name)
		if localizedStr and localizedStr ~= "StringTable::InvalidKey" then
			name = localizedStr
		end
		Mod.Game:GetHUD():ShowItemText(name)
		Mod.sfxman:Play(SoundEffect.SOUND_LASERRING, 0.8)
		MECHANICAL_EYE:GenerateActiveCopy(familiar)
	end, MECHANICAL_EYE.FAMILIAR)
end

Mod:AddCallback(ModCallbacks.MC_POST_DISCHARGE_ACTIVE_ITEM, MECHANICAL_EYE.PostDischarge)

--#endregion

--#region Reroll on new room/greed wave

function MECHANICAL_EYE:RerollActives()
	Mod.Foreach.Familiar(function(familiar, index)
		if familiar:GetSprite():IsPlaying("Opened") then
			MECHANICAL_EYE:GenerateActiveCopy(familiar)
		end
	end, MECHANICAL_EYE.FAMILIAR)
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	if Mod.Room():IsFirstVisit() then
		MECHANICAL_EYE:RerollActives()
	end
end, PlayerVariant.PLAYER)
Mod:AddCallback(ModCallbacks.MC_POST_START_GREED_WAVE, MECHANICAL_EYE.RerollActives)

--#endregion

--#region Update graphic with Curse of the Blind

---@param familiar EntityFamiliar
function MECHANICAL_EYE:UpdateFamiliarGraphic(familiar)
	local data = Mod:GetData(familiar)
	local blinded = Mod:HasBitFlags(Mod.Level():GetCurses(), LevelCurse.CURSE_OF_BLIND)
	if not data.MechEyeLevelBlinded then
		data.MechEyeLevelBlinded = blinded
	end
	if data.MechEyeLevelBlinded ~= blinded and familiar:GetSprite():IsPlaying("Opened") then
		local familiar_run_save = Mod.SaveManager.GetRunSave(familiar)
		local itemId = familiar_run_save.MechanicalActive or CollectibleType.COLLECTIBLE_POOP
		local itemConfig = Mod.ItemConfig:GetCollectible(itemId)
		MECHANICAL_EYE:UpdateActiveGraphic(familiar, itemConfig.GfxFileName)
		data.MechEyeLevelBlinded = blinded
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_FAMILIAR_RENDER, CallbackPriority.LATE, MECHANICAL_EYE.UpdateFamiliarGraphic, MECHANICAL_EYE.FAMILIAR)

--#endregion

--#region Familiar cache

---@param player EntityPlayer
function MECHANICAL_EYE:HandleCache(player)
	local num = player:GetCollectibleNum(MECHANICAL_EYE.ID) +
		player:GetEffects():GetCollectibleEffectNum(MECHANICAL_EYE.ID)
	local rng = player:GetCollectibleRNG(MECHANICAL_EYE.ID)
	rng:Next()

	player:CheckFamiliar(MECHANICAL_EYE.FAMILIAR, num, rng, Mod.ItemConfig:GetCollectible(MECHANICAL_EYE.ID))
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, MECHANICAL_EYE.HandleCache, CacheFlag.CACHE_FAMILIARS)

--#endregion
