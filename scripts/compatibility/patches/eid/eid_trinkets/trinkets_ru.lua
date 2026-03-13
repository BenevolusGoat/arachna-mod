local Mod = ARACHNAMOD
local Trinket = Mod.Trinket

return function(modifiers)
	return {
		[Trinket.INFESTED_PENNY.ID] = {
			Name = "Заражённый Пенни",
			Description = {
				"{{AracBlueSpider}} При подборе монеты создаёт синего паука",
				"#{{WebHeart}} Дополнительный 5% шанс получить Паутинное Сердце",
				"#Шанс больше при подборе пятаков и червонцев"
			},
		},
		[Trinket.SPINDLE.ID] = {
			Name = "Веретено",
			Description = {
				"{{StatusSpiderBite}} При касании опутывает врагов, замедляя их и превращая в Паучьи Яйца при смерти",
				"#{{Timer}} Паучьи Яйца создают {{ColorRainbow}}особых{{CR}} дружественных пауков при зачистке комнаты",
				"#{{WebHeart}} Увеличивает шанс получения Паутинных Сердец на 10%"
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
