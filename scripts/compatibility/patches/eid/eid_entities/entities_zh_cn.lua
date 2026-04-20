local Mod = ArachnaMod

return function(modifiers)
	return {
		[EntityType.ENTITY_PICKUP] = {
			[PickupVariant.PICKUP_HEART] = {
				[Mod.Pickup.WEB_HEART.ID] = {
					Name = "网心 {{WebHeart}}",
					Description = {
						"{{WebHeart}} 获得1网心",
						"#{{AracBlueSpider}} 网心在受到一次伤害后消耗, 生成2-6个蓝蜘蛛",
					}
				},
				[Mod.Pickup.WEB_HEART.ID_DOUBLE] = {
					Name = "双网心 {{WebHeart}}",
					Description = {
						"{{WebHeart}} 获得2网心",
						"#{{AracBlueSpider}} 网心在受到一次伤害后消耗, 生成2-6个蓝蜘蛛",
					}
				},
			},
		},
		[EntityType.ENTITY_SLOT] = {
			[Mod.Slot.SPIDER_BEGGAR.ID] = {
				[0] = {
					Name = "蜘蛛乞丐",
					Description = {
						"{{Coin}} 与其交互有可能获得如下奖励:",
						"#{{WebHeart}} 1网心",
						"#{{Charm}} 一个友好的随机蜘蛛类敌怪",
						"#{{ItemPoolSpiderBeggar}} 来自 蜘蛛乞丐道具池 的道具",
						"#奖励一个道具后离开"
					}
				}
			},
		},
	}
end
