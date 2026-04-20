local Mod = ArachnaMod

return function(modifiers)
	return {
		[EntityType.ENTITY_PICKUP] = {
			[PickupVariant.PICKUP_HEART] = {
				[Mod.Pickup.WEB_HEART.ID] = {
					Name = "거미줄 하트 {{WebHeart}}",
					Description = {
						"{{WebHeart}} 거미줄 하트 +1칸",
						"#{{AracBlueSpider}} 거미줄 하트 한 칸은 하트 반 칸의 체력으로 취급되며 소모 시 아군 파랑 거미 2-6마리가 생성됩니다.",
					}
				},
				[Mod.Pickup.WEB_HEART.ID_DOUBLE] = {
					Name = "더블 거미줄 하트 {{WebHeart}}",
					Description = {
						"{{WebHeart}} 거미줄 하트 +2칸",
						"#{{AracBlueSpider}} 거미줄 하트 한 칸은 하트 반 칸의 체력으로 취급되며 소모 시 아군 파랑 거미 2-6마리가 생성됩니다.",
					}
				},
			},
		},
		[EntityType.ENTITY_SLOT] = {
			[Mod.Slot.SPIDER_BEGGAR.ID] = {
				[0] = {
					Name = "거미 거지",
					Description = {
						"{{Coin}} 적선 시 다음 중 하나의 보상을 얻을 수도 있습니다:",
						"{{WebHeart}} 거미줄 하트 하나",
						"#{{Charm}} 무작위의 아군 거미 한 마리",
						"#{{ItemPoolSpiderBeggar}} 전용 배열의 받침대 아이템 하나",
						"받침대 아이템으로 보상하고 나면 그 자리를 떠나버립니다."
					}
				}
			},
		},
	}
end
