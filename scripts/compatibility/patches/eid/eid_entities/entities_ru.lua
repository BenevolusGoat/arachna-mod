local Mod = ARACHNAMOD

return function(modifiers)
	return {
		[EntityType.ENTITY_PICKUP] = {
			[PickupVariant.PICKUP_HEART] = {
				[Mod.Pickup.WEB_HEART.ID] = {
					Name = "Паутинное Сердце {{WebHeart}}",
					Description = {
						"{{WebHeart}} +1 Паутинное Сердце",
						"#{{AracBlueSpider}} Паутинные Сердца ломаются при получении урона, создавая 2-6 синих пауков",
					}
				},
				[Mod.Pickup.WEB_HEART.ID_DOUBLE] = {
					Name = "Двойное Паутинное Сердце {{WebHeart}}",
					Description = {
						"{{WebHeart}} +2 Паутинных Сердца",
						"#{{AracBlueSpider}} Паутинные Сердца ломаются при получении урона, создавая 2-6 синих пауков"
					}
				},
			},
		},
		[EntityType.ENTITY_SLOT] = {
			[Mod.Slot.SPIDER_BEGGAR.ID] = {
				[0] = {
					Name = "Попрошайка-Паук",
					Description = {
						"{{Coin}} За монеты попрошайка может дать следующие награды:",
						"#{{WebHeart}} 1 Паутинное Сердце",
						"#{{Charm}} Случайного дружественного паука-компаньона",
						"#{{ItemPoolSpiderBeggar}} Случайный артефакт из пула Попрошайки-Паука",
						"#После получения артефакта попрошайка исчезнет"
					}
				}
			},
		},
	}
end
