local Mod = ArachnaMod
local Item = Mod.Item

return function(modifiers)
	return {
		[Mod.PlayerType.ARACHNA] = {
			Name = "Арахна",
			Description = {
				"{{Collectible" .. Item.ARACHNAS_SPOOL.ID .. "}} 2 паутины могут быть активны одновременно",
				"#↑ Увеличение шанса получить {{ColorRainbow}}особых{{CR}} дружественных пауков из Паучьих Коконов",
				"#{{WebHeart}} 5% шанс получить Паутинное Сердце из Паучьих Коконов"
			}
		},
		[Mod.PlayerType.ARACHNA_B] = {
			Name = "Порченая Арахна",
			Description = {
				"{{StatusWebbed}} Брошенные яйца создают маленькие паутинки",
				"#3 паутины могут быть активны одновременно",
				"#Паутины имеют {{ColorRainbow}}особые{{CR}} эффекты, соответствующие цвету коконов",
				"#{{StatusWebbed}} Враги в паутине {{Slow}} замедлены, получают меньше отбрасывания и создают Паучий Кокон при смерти",
				"#!!! У этих новых Паучьих Коконов не будет особых цветов"
			}
		},
	}
end
