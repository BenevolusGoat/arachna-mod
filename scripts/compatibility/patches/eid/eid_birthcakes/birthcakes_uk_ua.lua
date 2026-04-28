local Mod = ArachnaMod

return function(modifiers)
	return {
		[Mod.PlayerType.ARACHNA] = {
			Name =  "Арахнин",
			PickupQuote = "Зараза!",
			AccurateBlurb = "Павучі Кокони та Боси випускають дружніх павуків",
			EIDDesc = {
				function(descObj)
					return modifiers[Mod.PlayerType.ARACHNA]._modifier(descObj,
						"Павучі Кокони створюють %s кожні 2 секунди"
						.. "#Спіймані в павутиння боси - %s кожну секунду",
					"дружній павук", "%s дружніх павуків")
				end
			},
		},
		[Mod.PlayerType.ARACHNA_B] = {
			Title = "Нещастин",
			Name = "Альт Арахнин",
			PickupQuote = "Агресія зростає!",
			AccurateBlurb = "Зменшено час відновлення особливої атаки + вона вистрілює додатковими сльозами",
			EIDDesc = {
				function(descObj)
					return modifiers[Mod.PlayerType.ARACHNA_B]._modifier(descObj,
						"Додаткова атака тепер %s",
						"швидше"
					)
				end,
				"# Атака від подвійного натискання кнопки вистрілює додатковими сльозами навколо гравця, які інколи можуть мати ефект предмету {{Collectible" .. CollectibleType.COLLECTIBLE_PARASITOID .. "}}",
				"#{{Luck}} 50% шанс із 5 одиницями удачі"
			},
		}
	}
end