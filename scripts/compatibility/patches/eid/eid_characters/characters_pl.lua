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
				"#{{WebHeart}} Killing a Webbed boss will replace its heart drop with a Web Heart",
			}
		},
		[Mod.PlayerType.ARACHNA_B] = {
			Name = "Tainted Arachna",
			Description = {
				"Can't have Red Hearts",
				"#Not affected by cowbebs",
				"#{{WebHeart}} Health ups grant Web Hearts",
				"Spiders hatched from spider eggs can be {{ColorRainbow}}special{{CR}} and/or larger, having unique effects",
				"#↑ {{AracBlueSpider}} Increased chance of Spider Eggs hatching larger spiders",
				"#{{WebHeart}} Killing a Webbed Boss will replace its heart drop with a Web Heart",
			}
		},
	}
end
