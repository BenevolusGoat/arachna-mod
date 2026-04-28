local Mod = ArachnaMod

return function(modifiers)
	return {
		[Mod.PlayerType.ARACHNA] = {
			Name =  "Arachna's",
			PickupQuote = "Zainfekowany!",
			AccurateBlurb = "Jaja i bossowie tworzą pająki",
			EIDDesc = {
				function(descObj)
					return modifiers[Mod.PlayerType.ARACHNA]._modifier(descObj,
						"Pajęcze jaja pojawią %s every 2 seconds"
						.. "#Bossowie w sieci pojawią %s co sekundę",
					"przyjaznego pająka", "%s przyjazne pająki")
				end
			},
		},
		[Mod.PlayerType.ARACHNA_B] = {
			Title = "Ohydnej",
			Name = "Tainted Arachna's",
			PickupQuote = "Agresywniejsze Uplątanie!",
			AccurateBlurb = "Podwójne kliknięcie jest szybsze i strzela łzami",
			EIDDesc = {
				function(descObj)
					return modifiers[Mod.PlayerType.ARACHNA_B]._modifier(descObj,
						"Attak podwójnego kliknięcia jest %s Szybszy"
					)
				end,
				"# Podwójne wciśnięcie przycisku ataku wystrzeli dodatkowe łzy wokół ciebie które mogą czasami być {{Collectible" .. CollectibleType.COLLECTIBLE_PARASITOID .. "}} pajęczymi jajkami",
				"#{{Luck}} 50% szans przy 5 szczęścia"
			},
		}
	}
end
