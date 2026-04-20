local Mod = ArachnaMod

local SPIDER_DONUT = {}

ArachnaMod.Item.SPIDER_DONUT = SPIDER_DONUT

SPIDER_DONUT.ID = Isaac.GetItemIdByName("Spider Donut")

---@param player EntityPlayer
---@param itemId CollectibleType
---@param firstTime boolean
function SPIDER_DONUT:OnCollectibleAdd(itemId, charge, firstTime, slot, varData, player)
	local COLORED_SPIDERS = Mod.Entities.COLORED_SPIDERS
	local rng = player:GetCollectibleRNG(itemId)
	Mod.Pickup.WEB_HEART:AddWebHearts(player, 1)

	for _ = 1, Mod:RandomNum(2, 3, rng) do
		Mod.Entities.COLORED_SPIDERS:ThrowFriendlySpider(
			player,
			COLORED_SPIDERS.SpiderSubtype.LOVE + COLORED_SPIDERS.SpiderSubtype.BIG_FLAG,
			player.Position
		)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, SPIDER_DONUT.OnCollectibleAdd, SPIDER_DONUT.ID)

---@param title string
---@param subtitle string
---@param sticky boolean
---@param curse boolean
function SPIDER_DONUT:UndertaleQuote(title, subtitle, sticky, curse)
	if title == "Spider Donut"
		and subtitle == "HP Up?"
		and not sticky
		and not curse
		and Isaac.GetPlayer():GetCollectibleRNG(SPIDER_DONUT.ID):RandomFloat() < 0.1
	then
		Game():GetHUD():ShowItemText(title, "Don't worry, Spider didn't", false, true)
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_ITEM_TEXT_DISPLAY, SPIDER_DONUT.UndertaleQuote)
