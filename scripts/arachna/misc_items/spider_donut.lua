local Mod = ARACHNAMOD

local SPIDER_DONUT = {}

ARACHNAMOD.Item.SPIDER_DONUT = SPIDER_DONUT

SPIDER_DONUT.ID = Isaac.GetItemIdByName("Old Shoebox")

---@param player EntityPlayer
---@param itemId CollectibleType
---@param firstTime boolean
function SPIDER_DONUT:OnCollectibleAdd(itemId, charge, firstTime, slot, varData, player)
	local rng = player:GetCollectibleRNG(itemId)
	Mod.Pickup.WEB_HEART:AddWebHearts(player, 1)

	for _ = 1, Mod:RandomNum(2, 3, rng) do
		Mod.Entities.COLORED_SPIDERS:ThrowColoredSpider(player, Mod.Entities.COLORED_SPIDERS.SpiderSubtype.BIG_FLAG, player.Position)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, SPIDER_DONUT.OnCollectibleAdd, SPIDER_DONUT.ID)