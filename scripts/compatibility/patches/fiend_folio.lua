local Mod = ARACHNAMOD
local loader = Mod.PatchesLoader
local Item = Mod.Item

local function ffPatch()
	Mod:AppendTable(FiendFolio.ReferenceItems.Actives, {
		{ ID = Item.BEST_BUD_BALL.ID, 		Reference = "Pokemon" , Partial = false},
	})
	Mod:AppendTable(FiendFolio.ReferenceItems.Passives, {
		{ ID = Item.SPIDER_DONUT.ID, 		Reference = "Undertale" , Partial = false},
	})
	FiendFolio:AddStackableItems({
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
end

loader:RegisterPatch("FiendFolio", ffPatch)