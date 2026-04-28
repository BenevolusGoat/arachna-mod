local Mod = ArachnaMod

return function(modifiers)
	return {
		[Mod.PlayerType.ARACHNA] = {
			Name =  "Арахны",
			PickupQuote = "Заражённый!",
			AccurateBlurb = "Коконы и боссы создают пауков",
			EIDDesc = {
				function(descObj)
					return modifiers[Mod.PlayerType.ARACHNA]._modifier(descObj,
						"Паучьи Коконы создают %s каждые 2 секунды"
						.. "#Опутанные паутиной боссы создают %s каждую секунду",
					"дружественного паука", "%s дружественных пауков")
				end
			},
		},
		[Mod.PlayerType.ARACHNA_B] = {
			Title = "Несщастной",
			Name = "Порченой Арахны",
			PickupQuote = "Агрессивность ловли ↑",
			AccurateBlurb = "Атака на двойной клик быстрее и выстреливает слёзами",
			EIDDesc = {
				function(descObj)
					return modifiers[Mod.PlayerType.ARACHNA_B]._modifier(descObj,
						"Атака на двойной клик %s быстрее"
					)
				end,
				"# Атака на двойной клик выстреливает дополнительными слезами вокруг игрока, которые иногда могут быть {{Collectible" .. CollectibleType.COLLECTIBLE_PARASITOID .. "}} коконами",
				"#{{Luck}} 50% шанс при 5 удачи"
			},
		}
	}
end