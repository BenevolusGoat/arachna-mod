local Mod = ArachnaMod

return function(modifiers)
	return {
		[EntityType.ENTITY_PICKUP] = {
			[PickupVariant.PICKUP_HEART] = {
				[Mod.Pickup.WEB_HEART.ID] = {
					Name = "Шовкове Серце {{WebHeart}}",
					Description = {
						"{{WebHeart}} +1 Шовкове Серце",
						"#{{AracBlueSpider}} Шовкові Серця руйнуються від 1 удару, після чого створюють від 2 до 6 синіх павуків",
					}
				},
				[Mod.Pickup.WEB_HEART.ID_DOUBLE] = {
					Name = "Подвійне Шовкове Серце {{WebHeart}}",
					Description = {
						"{{WebHeart}} +2 Шовкових Серця",
						"#{{AracBlueSpider}} Шовкові Серця руйнуються від 1 удару, після чого створюють від 2 до 6 синіх павуків"
					}
				},
			},
		},
		[EntityType.ENTITY_SLOT] = {
			[Mod.Slot.SPIDER_BEGGAR.ID] = {
				[0] = {
					Name = "Жебрак Павукоподібний",
					Description = {
						"{{Coin}} Кожен раз, даючи йому монету, ви можете отримати одну із перелічених нижче нагород:",
						"#{{WebHeart}} 1 Шовкове Серце",
						"#{{Charm}} Дружню версію одного з монстрів-павуків",
						"#{{ItemPoolSpiderBeggar}} Випадковий предмет з унікального павучого пулу предметів",
						"#Після видачі предмету, жебрак втече геть"
					}
				}
			},
		},
	}
end
