local Mod = ARACHNAMOD

local ARACHNIDS_GRIP = {}

ARACHNAMOD.Item.ARACHNIDS_GRIP = ARACHNIDS_GRIP

ARACHNIDS_GRIP.ID = Isaac.GetItemIdByName("Arachnid's Grip")

ARACHNIDS_GRIP.POISON_CHANCE = 0.25

---@param player EntityPlayer
---@param tearParams TearParams
function ARACHNIDS_GRIP:PosionTears(player, tearParams, weaponType, damageScale, tearDisplacement, source)
	if player:HasCollectible(ARACHNIDS_GRIP.ID)
		and player:GetCollectibleRNG(ARACHNIDS_GRIP.ID):RandomFloat() < ARACHNIDS_GRIP.POISON_CHANCE
	then
		tearParams.TearFlags = Mod:AddBitFlags(tearParams.TearFlags, TearFlags.TEAR_POISON)
		tearParams.TearColor = Color.TearCommonCold
		return tearParams
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, ARACHNIDS_GRIP.PosionTears)