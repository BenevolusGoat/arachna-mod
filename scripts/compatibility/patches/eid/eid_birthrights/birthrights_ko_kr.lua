local Mod = ArachnaMod
local Item = Mod.Item

return function(modifiers)
	return {
		[Mod.PlayerType.ARACHNA] = {
			Name = "아라크나",
			Description = {
				"{{Collectible" .. Item.ARACHNAS_SPOOL.ID .. "}} 활성 상태로 유지할 수 있는 거미줄이 2개로 증가합니다.",
				"#↑ 거미 알집에서 {{ColorRainbow}}특수{{CR}} 아군 거미가 생성될 확률이 증가합니다.",
				"#{{WebHeart}} 5% 확률로 알집이 부화하면 거미줄 하트가 생성됩니다."
			}
		},
		[Mod.PlayerType.ARACHNA_B] = {
			Name = "더럽혀진 아라크나",
			Description = {
				"{{StatusWebbed}} 알집을 던지면 그 지점에 거미줄이 생깁니다.",
				"#최대 3개까지의 거미줄을 유지할 수 있습니다.",
				"#거미줄에는 알집의 색상에 대응하는 {{ColorRainbow}}특수한{{CR}} 효과가 탑재되어 있습니다.",
				"#{{StatusWebbed}} 거미줄에 걸린 적은 {{Slow}} 둔화되며, 받는 넉백이 감소하며, 사망 시 거미 알집을 생성합니다.",
				"#!!! (이렇게 생성된 알집에는 특수 효과가 탑재되지 않습니다.)"
			}
		},
	}
end
