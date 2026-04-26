local Mod = ArachnaMod
local loader = Mod.PatchesLoader

local ARACHNA = {
	Name = {
		en_us = "Arachna's"
	},
	PickupQuote = {
		en_us = "Infested!"
	},
	AccurateBlurb = {
		en_us = "Eggs and bosses spawn spiders"
	},
	EIDDesc = {
		en_us = "Spider Eggs will occasionally spit out friendly spiders"
		.. "#Webbed bosses will occasionally spit out friendly spiders depending on their web charge. More charge = higher spawnrate"
	},
	SpriteName = "gfx/items/trinket/birthcake_arachna.png"
}

local ARACHNA_B = {
	Title = {
		en_us = "The Wretched's"
	},
	Name = {
		en_us = "Tainted Arachna's"
	},
	PickupQuote = {
		en_us = "Ensnare Aggression UP!"
	},
	AccurateBlurb = {
		en_us = "Double-tap is faster and shoots tears"
	},
	EIDDesc = {
		en_us = "Double-tap"
	},
	SpriteName = "gfx/items/trinkets/birthcake_arachna_b.png"
}

local function birthcakePatch()
	local api = BirthcakeRebaked.API
	api:AddBirthcakePickupText(Mod.PlayerType.ARACHNA, ARACHNA.PickupQuote, ARACHNA.Name)
	api:AddAccurateBlurbcake(Mod.PlayerType.ARACHNA, ARACHNA.AccurateBlurb)
	api:AddBirthcakeSprite(Mod.PlayerType.ARACHNA, { SpritePath = ARACHNA.SpriteName })
	api:AddEIDDescription(Mod.PlayerType.ARACHNA, ARACHNA.EIDDesc)

	api:AddTaintedBirthcakePickupText(Mod.PlayerType.ARACHNA_B, ARACHNA_B.PickupQuote, Mod.PlayerType.ARACHNA,
		ARACHNA_B.Name, ARACHNA_B.Title)
	api:AddAccurateBlurbcake(Mod.PlayerType.ARACHNA_B, ARACHNA_B.AccurateBlurb)
	api:AddBirthcakeSprite(Mod.PlayerType.ARACHNA_B, { SpritePath = ARACHNA_B.SpriteName })
	api:AddEIDDescription(Mod.PlayerType.ARACHNA_B, ARACHNA_B.EIDDesc)
end

loader:RegisterPatch("BirthcakeRebaked", birthcakePatch)
