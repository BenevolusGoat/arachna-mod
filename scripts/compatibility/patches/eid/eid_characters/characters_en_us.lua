local Mod = ARACHNAMOD

return function(modifiers)
	return {
		[Mod.PlayerType.ARACHNA] = {
			Name = "Tainted Arachna",
			Description = {
				"Can't have Red Hearts, Bone Hearts, or Eternal Hearts",
				"#Not affected by cowbebs",
				"#{{WebHeart}} Health ups grant Web Hearts",
				"#Spiders hatched from spider eggs can be {{ColorRainbow}}special{{CR}}, having unique effects",
			}
		},
		[Mod.PlayerType.ARACHNA_B] = {
			Name = "Tainted Arachna",
			Description = {
				"Can't have Red Hearts",
				"#Not affected by cowbebs",
				"#{{WebHeart}} Health ups grant Web Hearts",
				"#↑ {{AracBlueSpider}} Chance of Spider Eggs hatching larger spiders, having more powerful effects and splitting into 2 smaller spiders on death",
			}
		},
	}
end
