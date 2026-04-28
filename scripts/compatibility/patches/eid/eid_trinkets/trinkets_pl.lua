local Mod = ArachnaMod
local Trinket = Mod.Trinket

return function(modifiers)
	return {
		[Trinket.INFESTED_PENNY.ID] = {
			Name = "Skłębiona moneta",
			Description = {
				"{{AracBlueSpider}} Za każdą podniesioną monetę, pojawia się przyjazny pająk",
				"#{{WebHeart}} 5% szans na pojawieniu się nitkowych serc",
				"#Szansa jest większa jeśli podniesione są piątaki i dziesiątaki"
			},
		},
		[Trinket.SPINDLE.ID] = {
			Name = "Wrzeciono",
			Description = {
				"{{StatusSpiderBite}} Dotykanie przeciwników infekuje je pajęczym ugryzieniem, po śmierci upuszczają pajęcze jaja",
				"#{{Timer}} Pajęcze jaja nic nie zostawiają po 16 sekundach lub {{ColorRainbow}}specjalne{{CR}} przyjazne pająki po przejściu pokoju",
				"#{{WebHeart}} Zwiększa szansa na pojawienie się nitkowych serc o +10%"
			}
		},
		[Trinket.WHITE_STRING.ID] = {
			Name = "Biała nić",
			Description = {
				"{{WebHeart}} Po wejściu na nowe piętro otrzymujesz +1 Nitkowe serce"
			}
		},
	}
end
