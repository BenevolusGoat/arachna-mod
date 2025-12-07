local Mod = ARACHNAMOD

local ARACHNA_B = {}

ARACHNAMOD.Character.ARACHNA_B = ARACHNA_B

Mod.Include("scripts.arachna.characters.arachna_b.divine_cloth")
Mod.Include("scripts.arachna.characters.arachna_b.grab")

CustomHealthAPI.PersistentData.CharactersThatConvertMaxHealth[Mod.PlayerType.ARACHNA_B] = Mod.Pickup.WEB_HEART.KEY_ARACHNA
CustomHealthAPI.PersistentData.CharactersThatCantHaveRedHealth[Mod.PlayerType.ARACHNA_B] = true

ARACHNA_B.DIVINE_CLOTH_COOLDOWN = 60 * 6 --6 seconds

---@param player EntityPlayer
function ARACHNA_B:IsArachnaB(player)
	return player:GetPlayerType() == Mod.PlayerType.ARACHNA_B
end

---@param player EntityPlayer
function ARACHNA_B:ArachnaBHasBirthright(player)
	return ARACHNA_B:IsArachnaB(player) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
end

--Spread angle amount based on in-game observations with regular multishot items
local SPREAD_ANGLE_MULT = 2.167
local NUM_ADDED_TEARS = 3

---@param player EntityPlayer
---@param multiShotParams MultiShotParams
---@param weaponType WeaponType
function ARACHNA_B:BaseMultishot(player, multiShotParams, weaponType)
	local tearsToAdd = NUM_ADDED_TEARS
	if player:HasCollectible(CollectibleType.COLLECTIBLE_20_20) then
		tearsToAdd = tearsToAdd - 1
	end
	pcall(multiShotParams.SetSpreadAngle, multiShotParams:GetSpreadAngle(weaponType) + SPREAD_ANGLE_MULT * tearsToAdd)
	multiShotParams:SetNumTears(multiShotParams:GetNumTears() + tearsToAdd)
	local expectedAmount = multiShotParams:GetNumTears() / multiShotParams:GetNumEyesActive()
	multiShotParams:SetNumLanesPerEye(expectedAmount)
	return multiShotParams
end

Mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_MULTI_SHOT_PARAMS, CallbackPriority.IMPORTANT, ARACHNA_B.BaseMultishot, Mod.PlayerType.ARACHNA_B)

--For character base stat negative tears modifiers specifically, they are multiplied by this number to dampen their effect
local NEGATIVE_FIRERATE_MULT = 0.686655
local ARACHNA_FIRERATE_MODIFIER = -2.3 * NEGATIVE_FIRERATE_MULT

---@param player EntityPlayer
---@param stage EvaluateStatStage
---@param value number
function ARACHNA_B:NegateFirerateWithGlasses(player, stage, value)
	if ARACHNA_B:IsArachnaB(player) and player:HasCollectible(CollectibleType.COLLECTIBLE_20_20) then
		return value + math.abs(ARACHNA_FIRERATE_MODIFIER)
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_STAT, CallbackPriority.IMPORTANT, ARACHNA_B.NegateFirerateWithGlasses, EvaluateStatStage.TEARS_UP)

---@param player EntityPlayer
function ARACHNA_B:RestoreDivineCloth(player)
	if Mod:IsLegacyGameplayEnabled() then
		player:SetPocketActiveItem(Mod.Item.DIVINE_CLOTH.ID, ActiveSlot.SLOT_POCKET, false)
	end
end

Mod:AddCallback(ModCallbacks.MC_PLAYER_INIT_POST_LEVEL_INIT_STATS, ARACHNA_B.RestoreDivineCloth, Mod.PlayerType.ARACHNA_B)

---@param player EntityPlayer
function ARACHNA_B:DoubleTapCloth(player)
	if not ARACHNA_B:IsArachnaB(player) then return end
	local data = Mod:GetData(player)
	if data.TArachnaClothCooldown then
		data.TArachnaClothCooldown = data.TArachnaClothCooldown - 1
		if data.TArachnaClothCooldown <= 0 then
			Mod.sfxman:Play(SoundEffect.SOUND_BEEP)
			player:SetColor(StatusEffectLibrary.StatusColor.SLOW, 15, 100, true, false)
			data.TArachnaClothCooldown = nil
		end
		return
	end
	if Mod:HasDoubleTapped(player) then
		player:UseActiveItem(Mod.Item.DIVINE_CLOTH.ID, UseFlag.USE_NOANIM, -1)
		data.TArachnaClothCooldown = ARACHNA_B.DIVINE_CLOTH_COOLDOWN
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, ARACHNA_B.DoubleTapCloth)