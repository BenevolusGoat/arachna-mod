local Mod = ARACHNAMOD

return function()
	return {
		[Mod.PlayerType.ARACHNA] = {
			Name = "Arachna",
			Description = {
				"Can't have Red Hearts",
				"#{{WebHeart}} Health ups grant Web Hearts, which can substitute for heart containers",
				"#Not affected by cobwebs",
				"#{{Poison}} 25% chance to shoot poison tears",
				"#Spiders hatched from spider eggs can be {{ColorRainbow}}special{{CR}}, having unique effects",
			}
		},
		[Mod.PlayerType.ARACHNA_B] = {
			Name = "Tainted Arachna",
			Description = {
				"Can't have Red Hearts",
				"#{{WebHeart}} Health ups grant Web Hearts, which can substitute for heart containers",
				"#Not affected by cobwebs",
				"#{{Poison}} 25% chance to shoot poison tears",
				"#↓ Smaller spider eggs",
				"#{{Collectible" .. Mod.Item.DIVINE_CLOTH.ID .. "}} Double-tapping a fire key {{StatusWebbed}} webs enemies and deals 0.5x damage",
				"#{{StatusSpiderBite}} Eggs can be {{ColorRainbow}}special{{CR}}, dropping special spiders",
			}
		},
	}
end
