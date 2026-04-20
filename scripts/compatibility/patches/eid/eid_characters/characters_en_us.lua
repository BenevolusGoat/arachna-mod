local Mod = ArachnaMod

return function()
	return {
		[Mod.PlayerType.ARACHNA] = {
			Name = "Arachna",
			Description = {
				"Can't have Red Hearts",
				"#{{WebHeart}} Health ups grant Web Hearts, which can substitute for heart containers",
				"#Not affected by cobwebs",
				"#{{Poison}} 25% chance to shoot poison tears",
				"#Spiders hatched from Spider Eggs can be {{ColorRainbow}}special{{CR}}, having unique effects",
			}
		},
		[Mod.PlayerType.ARACHNA_B] = {
			Name = "Tainted Arachna",
			Description = {
				"Can't have Red Hearts",
				"#{{WebHeart}} Health ups grant Web Hearts, which can substitute for heart containers",
				"#Not affected by cobwebs",
				"#{{Poison}} 25% chance to shoot poison tears",
				"#{{Collectible" .. Mod.Item.DIVINE_CLOTH.ID .. "}} Double-tapping a fire key {{StatusSpiderBite}} ensnares enemies in a radius and deals 0.5x damage",
				"#{{StatusSpiderBite}} Ensnaring shares all the attributes of being {{StatusWebbed}} webbed",
				"#↓ Smaller Spider Eggs",
				"#{{StatusSpiderBite}} Eggs can be {{ColorRainbow}}special{{CR}}, dropping special spiders",
			}
		},
	}
end
