local Mod = ARACHNAMOD
local loader = Mod.PatchesLoader
local Item = Mod.Item

local function epiphanyPatch()
	local api = Epiphany.API

	api:AddItemsToEdenBlackList(
		Item.SPIDER_CAKE.ID,
		Item.SPIDER_DONUT.ID,
		Item.CANDY_FLOSS.ID,
		Item.OLD_SHOEBOX.ID,
		Item.GUMMY_SPIDERS.ID
	)

	Mod:AddToDictionary(Epiphany.Character.KEEPER.DisallowedPickUpVariants, {
		[Item.ARACHNIDS_GRIP.PICKUP] = 0
	})

	Mod:AddToDictionary(Epiphany.Character.KEEPER.PickupVariants[PickupVariant.PICKUP_HEART], {
		[Mod.Pickup.WEB_HEART.ID] = 0,
		[Mod.Pickup.WEB_HEART.ID] = 0,
	})
	Mod:AddToDictionary(Epiphany.Character.KEEPER.HeartToFliesTable[PickupVariant.PICKUP_HEART], {
		[Mod.Pickup.WEB_HEART.ID] = 0,
		[Mod.Pickup.WEB_HEART.ID] = 0,
	})
	ARACHNAMOD.KeeperPlayers[Epiphany.PlayerType.KEEPER] = true
end

loader:RegisterPatch("Epiphany", epiphanyPatch)