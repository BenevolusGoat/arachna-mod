local Mod = ARACHNAMOD
local Item = Mod.Item

return function(modifiers)
	return {
		[Mod.PlayerType.ARACHNA] = {
			Name = "Арахна",
			Description = {
				"{{Collectible" .. Item.ARACHNAS_SPOOL.ID .. "}} 2 паутины могут быть активны одновременно",
				"#↑ Увеличение шанса получить {{ColorRainbow}}особых{{CR}} дружественных пауков из паучьих яиц",
				"#{{WebHeart}} Из паучьих яиц с 5% шансом может появиться Паутинное Сердце"
			}
		},
		[Mod.PlayerType.ARACHNA_B] = {
			Name = "Порченная Арахна",
			Description = {
				"{{StatusWebbed}} Брошенные яйца создают маленькие паутинки",
				"#3 паутины могут быть активны одновременно",
				"#Паутины имеют {{ColorRainbow}}особые{{CR}} эффекты, соответствующие цвету яиц",
				"#{{StatusWebbed}} Враги в паутине {{Slow}} замедлены, получают меньше отбрасывания и создают паучье яйцо при смерти",
				"#!!! У этих новых паучьих яиц не будет особых цветов"
			}
		},
	}
end
