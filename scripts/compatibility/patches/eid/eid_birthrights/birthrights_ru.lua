local Mod = ARACHNAMOD
local Item = Mod.Item

return function(modifiers)
	return {
		[Mod.PlayerType.ARACHNA] = {
			Name = "Arachna",
			Description = {
				"{{Collectible" .. Item.ARACHNAS_SPOOL.ID .. "}} Can have up to 2 webs active at a time",
				"#↑ Increased chance of spider eggs spawning {{ColorRainbow}}special{{CR}} friendly spiders",
				"#{{WebHeart}} 5% chance for spider eggs to drop a Web Heart upon breaking"
			}
		},
		[Mod.PlayerType.ARACHNA_B] = {
			Name = "Tainted Arachna",
			Description = {
				"N/A for now"
			}
		},
	}
end
