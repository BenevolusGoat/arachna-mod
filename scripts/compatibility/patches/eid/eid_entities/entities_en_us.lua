local Mod = ARACHNAMOD

return function(modifiers)
	return {
		[EntityType.ENTITY_PICKUP] = {
			[PickupVariant.PICKUP_HEART] = {
				[Mod.Pickup.WEB_HEART.ID] = {
					Name = "Web Heart {{WebHeart}}",
					Description = {""
					}
				},
			},
		},
		[EntityType.ENTITY_SLOT] = {
			[Mod.Slot.SPIDER_BEGGAR.ID] = {
				[0] = {
					Name = "Spider Beggar",
					Description = {""
					}
				}
			},
		},
	}
end
