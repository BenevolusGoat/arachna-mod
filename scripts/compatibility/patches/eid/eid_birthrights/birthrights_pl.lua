local Mod = ArachnaMod
local Item = Mod.Item

return function(modifiers)
	return {
		[Mod.PlayerType.ARACHNA] = {
			Name = "Arachna",
			Description = {
				"{{Collectible" .. Item.ARACHNAS_SPOOL.ID .. "}} Może mieć do 2 aktywnych pajęczyn naraz",
				"#↑ Pajęcze jaja mają większe szansy by wytworzyć {{ColorRainbow}}specjalne{{CR}} przyjazne pająki ",
				"#{{WebHeart}} mają 5% na pojawienie się z wyklutych pajęczych jaj"
			}
		},
		[Mod.PlayerType.ARACHNA_B] = {
			Name = "Skażona Arachna",
			Description = {
				"{{StatusWebbed}} Wyrzucone jaja wypuszczają małe pajęczyny",
				"#Może mieć aż do 3 aktywnych pajęczyn naraz",
				"#Pajęczyny mają {{ColorRainbow}}specjalne{{CR}} effekty według kolorów jaj",
				"#{{StatusWebbed}} Przeciwnicy w pajęczynach są {{Slow}} wolniejsi, otrzymują mniej odrzutu, oraz upuszczają pajęcze jaja po śmierci",
				"#!!! Te nowe jaja nie będą miały specjalnych efektów"
			}
		},
	}
end
