local Mod = ARACHNAMOD

local GUMMY_SPIDERS = {}

ARACHNAMOD.Item.GUMMY_SPIDERS = GUMMY_SPIDERS

GUMMY_SPIDERS.ID = Isaac.GetItemIdByName("Gummy Spiders")

---@param player EntityPlayer
---@param itemId CollectibleType
---@param firstTime boolean
function GUMMY_SPIDERS:OnCollectibleAdd(itemId, charge, firstTime, slot, varData, player)
	local rng = player:GetCollectibleRNG(itemId)
	Mod.Pickup.WEB_HEART:AddWebHearts(player, 2)
	for _ = 1, Mod:RandomNum(4, 8, rng) do
		local spiderSubtype = Mod.Entities.COLORED_SPIDERS:GetRandomSpiderSubtype(false, true)
		Mod.Entities.COLORED_SPIDERS:ThrowColoredSpider(player, spiderSubtype, player.Position)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, GUMMY_SPIDERS.OnCollectibleAdd, GUMMY_SPIDERS.ID)