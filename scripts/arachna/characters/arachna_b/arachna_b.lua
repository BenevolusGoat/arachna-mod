local Mod = ARACHNAMOD

local ARACHNA_B = {}

ARACHNAMOD.Character.ARACHNA_B = ARACHNA_B

Mod.Include("scripts.arachna.characters.arachna_b.divine_cloth")

CustomHealthAPI.PersistentData.CharactersThatConvertMaxHealth[Mod.PlayerType.ARACHNA_B] = Mod.Pickup.WEB_HEART.KEY

---@param player EntityPlayer
function ARACHNA_B:IsArachnaB(player)
	return player:GetPlayerType() == Mod.PlayerType.ARACHNA_B
end

---@param player EntityPlayer
function ARACHNA_B:ArachnaHasBirthright(player)
	return ARACHNA_B:IsArachnaB(player) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
end

--Spread angle amount based on in-game observations with regular multishot items
local SPREAD_ANGLE_MULT = 2.167
local NUM_ADDED_TEARS = 3

---@param player EntityPlayer
---@param multiShotParams MultiShotParams
---@param weaponType WeaponType
function ARACHNA_B:BaseMultishot(player, multiShotParams, weaponType)
	multiShotParams:SetSpreadAngle(weaponType, multiShotParams:GetSpreadAngle(weaponType) + SPREAD_ANGLE_MULT * NUM_ADDED_TEARS)
	multiShotParams:SetNumTears(multiShotParams:GetNumTears() + NUM_ADDED_TEARS)
	local expectedAmount = multiShotParams:GetNumTears() / multiShotParams:GetNumEyesActive()
	multiShotParams:SetNumLanesPerEye(expectedAmount)
	return multiShotParams
end

Mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_MULTI_SHOT_PARAMS, CallbackPriority.IMPORTANT, ARACHNA_B.BaseMultishot, Mod.PlayerType.ARACHNA_B)

