local Mod = ARACHNAMOD

local GEPTAMERON = {}

ARACHNAMOD.Item.GEPTAMERON = GEPTAMERON

GEPTAMERON.ID = Isaac.GetItemIdByName("Geptameron")
GEPTAMERON.OVERLAY = Isaac.GetGiantBookIdByName("Geptameron")

---@param itemId CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param useFlags UseFlag
---@param slot any
---@param customVarData any
function GEPTAMERON:OnUse(itemId, rng, player, useFlags, slot, customVarData)
	ItemOverlay.Show(GEPTAMERON.OVERLAY, 3, player)
	Mod.sfxman:Play(SoundEffect.SOUND_SUPERHOLY, 1, 0, false, 1)
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, GEPTAMERON.OnUse, GEPTAMERON.ID)