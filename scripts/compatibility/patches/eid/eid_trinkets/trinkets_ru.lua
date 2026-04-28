local Mod = ArachnaMod
local Trinket = Mod.Trinket

return function(modifiers)
	return {
		[Trinket.INFESTED_PENNY.ID] = {
			Name = "Заражённый Пенни",
			Description = {
				"{{AracBlueSpider}} При подборе монеты создаёт синего паука",
				"#{{WebHeart}} Дополнительный 20% шанс получить Паутинное Сердце",
				"#Шанс больше при подборе пятаков и червонцев"
			},
		},
		[Trinket.SPINDLE.ID] = {
			Name = "Веретено",
			Description = {
				"{{StatusWebbed}} При касании ловит врагов в паутину на 5 секунд",
				"#{{StatusWebbed}} Враги {{Slow}} замедлены, получают меньше отбрасывания и создают Паучий Кокон при смерти",
				"#{{AracBlueSpider}} Паучьи Коконы вылупляются при зачистке комнаты, создавая несколько синих пауков",
				"#{{WebHeart}} Увеличивает шанс появления Паутинных Сердец на 10%"
			}
		},
		[Trinket.WHITE_STRING.ID] = {
			Name = "Белая Нить",
			Description = {
				"{{WebHeart}} При переходе на новый этаж даёт 1 Паутинное Сердце"
			}
		},
	}
end
