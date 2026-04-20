local Mod = ArachnaMod

return function(modifiers)
	return {
		[EntityType.ENTITY_PICKUP] = {
			[PickupVariant.PICKUP_HEART] = {
				[Mod.Pickup.WEB_HEART.ID] = {
					Name = "Web Heart {{WebHeart}}",
					Description = {
						"{{WebHeart}} +1 Web Heart",
						"#{{AracBlueSpider}} Web Hearts deplete in one hit, spawning 2-6 blue spiders",
					}
				},
				[Mod.Pickup.WEB_HEART.ID_DOUBLE] = {
					Name = "Double Web Heart {{WebHeart}}",
					Description = {
						"{{WebHeart}} +2 Web Hearts",
						"#{{AracBlueSpider}} Web Hearts deplete in one hit, spawning 2-6 blue spiders"
					}
				},
			},
		},
		[EntityType.ENTITY_SLOT] = {
			[Mod.Slot.SPIDER_BEGGAR.ID] = {
				[0] = {
					Name = "Spider Beggar",
					Description = {
						"{{Coin}} Donating coins to the beggar may reward one of the following:",
						"#{{WebHeart}} 1 Web Heart",
						"#{{Charm}} A random friendly spider companion",
						"#{{ItemPoolSpiderBeggar}} A random collectible from the Spider Beggar item pool",
						"#Beggar will disappear after paying out with a collectible"
					}
				}
			},
		},
	}
end
