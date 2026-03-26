local Mod = ARACHNAMOD
local Trinket = Mod.Trinket

return function(modifiers)
	return {
		[Trinket.INFESTED_PENNY.ID] = {
			Name = "우글거리는 동전",
			Description = {
				"{{AracBlueSpider}} 동전을 주우면 파란색 아군 거미가 생성됩니다.",
				"#{{WebHeart}} 20% 확률로 거미줄 하트도 생성됩니다.",
				"#니켈이나 다임을 주우면 거미줄 생성 확률이 올라갑니다."
			},
		},
		[Trinket.SPINDLE.ID] = {
			Name = "가락바퀴",
			Description = {
				"{{StatusWebbed}} 적과 접촉하면 5초간 해당 적을 거미줄로 옭아맵니다.",
				"#{{StatusWebbed}} 옭아매인 적은 {{Slow}} 둔화되고 받는 넉백이 감소하며 사망 시 거미 알집을 생성합니다.",
				"#{{AracBlueSpider}} 거미 알집은 방 클리어 시 터지며 파란 아군 거미를 여러 마리 소환합니다.",
				"#{{WebHeart}} 거미줄 하트 생성 확률 +10%",
				function(descObj)
					return modifiers[Trinket.SPINDLE.ID]._modifier(descObj,
						"#{{Collectible" .. CollectibleType.COLLECTIBLE_MIDAS_TOUCH .. "}} 알집이 황금 거미를 생성하는 {{ColorGold}}황금 알집{{CR}}이 됩니다."
					)
				end
			}
		},
		[Trinket.WHITE_STRING.ID] = {
			Name = "흰 실",
			Description = {
				"{{WebHeart}} 새로운 층에 진입 시 거미줄 하트 +1개"
			},
		},
	}
end
