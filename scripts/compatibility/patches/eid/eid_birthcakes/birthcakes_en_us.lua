local Mod = ArachnaMod

return function(modifiers)
	return {
		[Mod.PlayerType.ARACHNA] = {
			Name =  "Arachna's",
			PickupQuote = "Infested!",
			AccurateBlurb = "Eggs and bosses spawn spiders",
			EIDDesc = {
				function(descObj)
					return modifiers[Mod.PlayerType.ARACHNA]._modifier(descObj,
						"Spider Eggs spawn %s every 2 seconds"
						.. "#Webbed bosses spawn %s every second",
					"a friendly spider", "%s friendly spiders")
				end
			},
		},
		[Mod.PlayerType.ARACHNA_B] = {
			Title = "The Wretched's",
			Name = "Tainted Arachna's",
			PickupQuote = "Ensnare Aggression UP!",
			AccurateBlurb = "Double-tap is faster and shoots tears",
			EIDDesc = {
				function(descObj)
					return modifiers[Mod.PlayerType.ARACHNA_B]._modifier(descObj,
						"Double-tap attack is %s",
						"faster"
					)
				end,
				"# Double-tap attack shoots extra tears around you that can sometimes be {{Collectible" .. CollectibleType.COLLECTIBLE_PARASITOID .. "}} egg sacks",
				"#{{Luck}} 50% chance at 5 luck"
			},
		}
	}
end