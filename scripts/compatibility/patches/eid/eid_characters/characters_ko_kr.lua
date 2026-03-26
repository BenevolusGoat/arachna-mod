local Mod = ARACHNAMOD

return function()
	return {
		[Mod.PlayerType.ARACHNA] = {
			Name = "아라크나",
			Description = {
				"#{{WebHeart}} 최대 체력 변화가 거미줄 하트로 대체됩니다.",
				"#거미줄 장애물의 효과를 무시합니다.",
				"#{{Poison}} 25% 확률로 독성 눈물이 나갑니다.",
				"#거미 알집에서 부화한 아군 거미에 {{ColorRainbow}}특수한 효과{{CR}}가 탑재될 수 있습니다.",
			}
		},
		[Mod.PlayerType.ARACHNA_B] = {
			Name = "더럽혀진 아라크나",
			Description = {
				"#{{WebHeart}} 최대 체력 변화가 거미줄 하트로 대체됩니다.",
				"#거미줄 장애물의 효과를 무시합니다.",
				"#{{Poison}} 25% 확률로 독성 눈물이 나갑니다.",
				"#{{Collectible" .. Mod.Item.DIVINE_CLOTH.ID .. "}} 공격 키를 빠르게 두 번 누르면 {{StatusSpiderBite}} 범위 내의 적들을 옭아매 공격력 값의 절반의 피해를 줍니다.",
				"#{{StatusSpiderBite}} 옭아매인 적들은 {{StatusWebbed}} 거미줄에 걸려든 것과 동일한 효과를 받습니다.",
				"#↓ 거미 알집이 작아집니다.",
				"#{{StatusSpiderBite}} 알집이 {{ColorRainbow}}특수 거미{{CR}}를 생성하는 특수 알집이 될 수 있습니다.",
			}
		},
	}
end
