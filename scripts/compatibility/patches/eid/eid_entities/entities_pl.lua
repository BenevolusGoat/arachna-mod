local Mod = ArachnaMod

return function(modifiers)
	return {
		[EntityType.ENTITY_PICKUP] = {
			[PickupVariant.PICKUP_HEART] = {
				[Mod.Pickup.WEB_HEART.ID] = {
					Name = "Niciane serce {{WebHeart}}",
					Description = {
						"{{WebHeart}} +1 Niciane serce",
						"#{{AracBlueSpider}} Niciane serca niszczą się przy jednym uderzeniu, pojawia 2-6 pająków",
					}
				},
				[Mod.Pickup.WEB_HEART.ID_DOUBLE] = {
					Name = "Podwójne Niciane Serce {{WebHeart}}",
					Description = {
						"{{WebHeart}} +2 Niciane serce",
						"#{{AracBlueSpider}} Niciane serca niszczą się przy jednym uderzeniu, pojawia 2-6 pająków",
					}
				},
			},
		},
		[EntityType.ENTITY_SLOT] = {
			[Mod.Slot.SPIDER_BEGGAR.ID] = {
				[0] = {
					Name = "Pajęczy Żebrak",
					Description = {
						"{{Coin}} Donacja jednej monety może dać jedną rzecz z tej listy:",
						"#{{WebHeart}} 1 niciane serce",
						"#{{Charm}} Losowego pajęczego kompana",
						"#{{ItemPoolSpiderBeggar}} Losowy przedmiot z puli pajęczego żebraka",
						"#Żebrak zniknie po oddaniu przedmiotu"
					}
				}
			},
		},
	}
end
