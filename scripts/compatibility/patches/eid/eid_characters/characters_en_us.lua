local Mod = ARACHNAMOD

return function(modifiers)
	return {
		[Mod.PlayerType.ARACHNA] = {
			Name = "Tainted Arachna",
			Description = {
				"Can't have Red Hearts",
				"#{{WebHeart}} Health ups grant Web Hearts",
				"Spiders hatched from Spider Eggs can be {{ColorRainbow}}special{{CR}}, having unique effects"
			}
		},
		[Mod.PlayerType.ARACHNA_B] = {
			Name = "Tainted Arachna",
			Description = {
				"Can't have Red Hearts",
				"#{{WebHeart}} Health ups grant Web Hearts",
				"Spiders hatched from Spider Eggs can be {{ColorRainbow}}special{{CR}} and/or larger, having unique effects",
				"#↑ {{AracBlueSpider}} Increased chance of Spider Eggs hatching larger spiders"
			}
		},
	}
end
