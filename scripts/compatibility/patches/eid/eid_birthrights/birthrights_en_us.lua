local Mod = ARACHNAMOD
local Item = Mod.Item

return function(modifiers)
	return {
		[Mod.PlayerType.ARACHNA] = {
			Name = "Arachna",
			Description = {
				"{{Collectible" .. Item.ARACHNAS_SPOOL.ID .. "}} Can have up to 2 webs active at a time",
				"#↑ +1 {{AracBlueSpider}} Blue Spider from Spider Eggs",
				"#5% chance for Spider Eggs to drop a {{WebHeart}} Web Heart upon breaking"
			}
		},
		[Mod.PlayerType.ARACHNA_B] = {
			Name = "Tainted Arachna",
			Description = {
				"↑ Duration of {{StatusBitten}} Bitten status extended by +25%",
				"#↑ Radius of {{Collectible" .. Item.DIVINE_CLOTH.ID .. "}} Divine Cloth extended by +33%",
				"#{{Timer}} Using {{Collectible" .. Item.DIVINE_CLOTH.ID .. "}} Divine Cloth increases lifetime of nearby Spider Eggs by +3 seconds"
			}
		},
	}
end
