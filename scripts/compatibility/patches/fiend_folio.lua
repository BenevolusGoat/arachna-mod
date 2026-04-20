local Mod = ArachnaMod
local loader = Mod.PatchesLoader
local Item = Mod.Item

local function ffPatch()
	local ff = FiendFolio
	Mod:AppendTable(ff.ReferenceItems.Actives, {
		{ ID = Item.BEST_BUD_BALL.ID, Reference = "Pokemon", Partial = false },
	})
	Mod:AppendTable(ff.ReferenceItems.Passives, {
		{ ID = Item.SPIDER_DONUT.ID,   Reference = "Undertale",  Partial = false },
		{ ID = Item.ARACHNIDS_GRIP.ID, Reference = "Homestuck",  Partial = true },
	})
	ff:AddStackableItems({
		Item.ARACHNIDS_GRIP.ID,
		Item.LIL_ARACHNA.ID,
		Item.MECHANICAL_EYE.ID,
		Item.MUTAGEN.ID,
		Item.YARN.ID,
		Item.DADS_NEWSPAPER.ID,
		Item.SPIDER_CAKE.ID,
		Item.SPIDER_DONUT.ID,
		Item.CANDY_FLOSS.ID,
		Item.OLD_SHOEBOX.ID,
		Item.GUMMY_SPIDERS.ID
	})
	ff.AddItemsToPennyTrinketPool({
		Mod.Trinket.INFESTED_PENNY.ID
	})
	ff.AddItemsToTortureCookieTrinketPool({
		--On-hit trinkets
		Mod.Trinket.SPINDLE.ID
	})
	--Electrum + Mystery Gift
	ff.AddItemsToTechnologyPool({
		Mod.Item.MECHANICAL_EYE.ID
	})
end

loader:RegisterPatch("FiendFolio", ffPatch)
