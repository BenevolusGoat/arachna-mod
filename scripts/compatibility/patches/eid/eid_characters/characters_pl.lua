local Mod = ArachnaMod

return function()
	return {
		[Mod.PlayerType.ARACHNA] = {
			Name = "Arachna",
			Description = {
				"Nie może mieć czerwonych serc",
				"#{{WebHeart}} Zwiększanie maks. zdrowia zamiast kontynerów dają niciane serca",
				"#Nie jest spowalniana przez pajęczyny",
				"#{{Poison}} 25% szans by wystrzelić trujące łzy",
				"#Pająki wykluwane z pajęczych jaj mogą być {{ColorRainbow}}specjalne{{CR}}, z unikalnymi efektami",
			}
		},
		[Mod.PlayerType.ARACHNA_B] = {
			Name = "Skażona Arachna",
			Description = {
				"Nie może mieć czerwonych serc",
				"#{{WebHeart}} Zwiększanie maks. zdrowia zamiast kontynerów dają niciane serca",
				"#Nie jest spowalniana przez pajęczyny",
				"#{{Poison}} 25% chance to shoot poison tears",
				"#↓ Mniejsze pajęcze jaja",
				"#{{Collectible" ..
				Mod.Item.DIVINE_CLOTH.ID ..
				"}} Wciśnij przycisk ataku 2 razy {{StatusSpiderBite}} uplątuje pobliskich pzrzeciników i zadaje 0.5x obrażeń",
				"#{{StatusSpiderBite}} Uplątanie ma takei same efekty co bycie w {{StatusWebbed}} sieci",
				"#{{StatusSpiderBite}} Jaja mogą być {{ColorRainbow}}specjalne{{CR}}, które upuszczają specjalne pająki",
			}
		},
	}
end
