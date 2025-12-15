local Mod = ARACHNAMOD

return function(modifiers)
	return {
		[Mod.PlayerType.ARACHNA] = {
			Name = "Arachna",
			Description = {
				"Can't have Red Hearts",
				"#{{WebHeart}} Health ups grant Web Hearts, which can substitute for heart containers",
				"#Not affected by cowbebs",
				"#{{Poison}} 25% to shoot poison tears",
				"#Spiders hatched from spider eggs can be {{ColorRainbow}}special{{CR}}, having unique effects",
			}
		},
		[Mod.PlayerType.ARACHNA_B] = {
			Name = "Tainted Arachna",
			Description = {
				"Can't have Red Hearts",
				"#{{WebHeart}} Health ups grant Web Hearts, which can substitute for heart containers",
				"#Not affected by cowbebs",
				"#{{Poison}} 25% to shoot poison tears",
				"#↓ Less spiders from spider eggs",
				"#{{Collectible" .. Mod.Item.DIVINE_CLOTH.ID .. "}} Double-tapping a fire key inflicts {{StatusSpiderBite}} Spider Bite, {{StatusWebbed}} Webbed, and deals 0.5x damage",
				"#{{StatusSpiderBite}} Spider Bite causes spider eggs to only drop spiders of its own color",
			}
		},
	}
end
