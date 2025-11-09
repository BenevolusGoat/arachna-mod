local Mod = ARACHNAMOD
local loader = Mod.PatchesLoader

local function minimapAPIPatch()
	Mod.SaveManager.InitMinimapAPI(MinimapAPI, MinimapAPI.BranchVersion)

	local sprite = Sprite("gfx/ui/arachna_minimap_icons.anm2", true)

	MinimapAPI:AddIcon("WebHeart", sprite, "WebHeart", 0)
	MinimapAPI:AddPickup("WebHeart", "WebHeart", EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART,
	Mod.Pickup.WEB_HEART.ID, MinimapAPI.PickupNotCollected, "hearts", 15300)

	MinimapAPI:AddIcon("WebHeartDouble", sprite, "WebHeartDouble", 0)
	MinimapAPI:AddPickup("WebHeartDouble", "WebHeartDouble", EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART,
		Mod.Pickup.WEB_HEART.ID_DOUBLE, MinimapAPI.PickupNotCollected, "hearts", 15400)

	MinimapAPI:AddIcon("SpiderBeggar", sprite, "SpiderBeggar", 0)
	MinimapAPI:AddPickup("SpiderBeggar", "SpiderBeggar", EntityType.ENTITY_SLOT, Mod.Slot.SPIDER_BEGGAR.ID, 0,
		MinimapAPI.PickupSlotMachineNotBroken, "beggars")

	MinimapAPI:AddIcon("SoulOfArachna", sprite, "SoulOfArachna", 0)
	MinimapAPI:AddPickup("SoulOfArachna", "SoulOfArachna", EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD,
		Mod.Card.SOUL_OF_ARACHNA.ID, MinimapAPI.PickupNotCollected, "runes", 11100)

	MinimapAPI:AddIcon("MergedCard", sprite, "MergedCard", 0)
	MinimapAPI:AddPickup("MergedCard", "MergedCard", EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD,
		Mod.Card.MERGED_CARD.ID, MinimapAPI.PickupNotCollected, "cards", 10100)
end

loader:RegisterPatch("MinimapAPI", minimapAPIPatch)