local Mod = ArachnaMod

return function(modifiers)
	return {
		[Mod.Card.SOUL_OF_ARACHNA.ID] = {
			Name = "Dusza Arachny",
			Description = {
				"{{StatusWebbed}} Oplata wszystkich przeciwników na 10 seconds",
				"#{{StatusWebbed}} Przeciwnicy są {{Slow}} wolniejsi, mają mniejsze odepchnięcie, oraz upuszczują pajęcze jaja po śmierci",
				"#{{AracBlueSpider}} Jaja wyklują się po ukończeniu pokoju, zostawiając niebieskie pająki",
			}
		},
		[Mod.Card.MERGED_CARD.ID] = {
			Name = "Sklejona karta",
			Description = {
				function(descObj)
					return modifiers[Mod.Card.MERGED_CARD.ID]._modifier(descObj,
						"Aktywuje 2 efekty na podstawie kart tarota"
						.. "#(Przytrzymaj {{ButtonSelect}} by zobaczyć efekty)",
						"{{Blank}} {{ButtonX}} Lista efektów %s/%s {{ButtonB}}",
						{
							"#{{Karta" ..
							Card.CARD_FOOL ..
							"}} aktywuje efekt {{Collectible" .. CollectibleType.COLLECTIBLE_D7 .. "}} D7"
							.. "#{{Karta" ..
							Card.CARD_MAGICIAN .. "}} {{Slow}} Spowalnia wszystkich przeciwników w pokoju"
							.. "#{{Karta" .. Card.CARD_HIGH_PRIESTESS .. "}} {{MomBossSmall}} Noga Matki zdepcze isaaca"
							.. "#{{Karta" ..
							Card.CARD_EMPRESS ..
							"}} aktywuje efekt {{Collectible" .. CollectibleType.COLLECTIBLE_THE_NAIL .. "}} gwoździa"
							.. "#{{Karta" .. Card.CARD_EMPEROR .. "}} ujawnia lokacje {{BossRoom}} boss'a"
							.. "#{{Karta" ..
							Card.CARD_HIEROPHANT .. "}} tworzy dwie {{HalfSoulHeart}} połówki serca dusz",

							"#{{Karta" .. Card.CARD_LOVERS .. "}} tworzy 2 {{HalfHeart}} połówki serc"
							.. "#{{Karta" ..
							Card.CARD_CHARIOT ..
							"}} aktywuje efekt {{Collectible" .. CollectibleType.COLLECTIBLE_UNICORN_STUMP ..
							"}} kikut rogu jednorożca"
							..
							"#{{Krta" ..
							Card.CARD_JUSTICE ..
							"}} tworzy 2 z tych znajdźek: {{Coin}} moneta, {{Key}} klucz, {{Bomb}} bomba, or {{Heart}} serce"
							.. "#{{Karta" ..
							Card.CARD_HERMIT ..
							"}} aktywuje efekt {{Collectible" ..
							CollectibleType.COLLECTIBLE_KEEPERS_BOX .. "}} pudła Keepera"
							..
							"#{{Karta" ..
							Card.CARD_WHEEL_OF_FORTUNE ..
							"}} aktywuje efekt {{Collectible" ..
							CollectibleType.COLLECTIBLE_PORTABLE_SLOT .. "}} jednorękiego bandyty 3 razy",

							"#{{Karta" ..
							Card.CARD_STRENGTH ..
							"}} {{Timer}} Na jeden pokój aktywuje efekt: {{Collectible" ..
							CollectibleType.COLLECTIBLE_ODD_MUSHROOM_LARGE .. "}} dziwnego grzyba"
							.. "#{{Karta" ..
							Card.CARD_HANGED_MAN .. "}} niszczy wszystkie kamienie i wypełnia wszystkie przepaście"
							.. "#{{Karta" .. Card.CARD_DEATH .. "}} zadaje 20 obrażeń przeciwnikom w danym pokoju"
							.. "#{{Karta" .. Card.CARD_TEMPERANCE .. "}} pojawia {{DemonBeggar}} demonicznego żebraka"
							.. "#{{Karta" .. Card.CARD_DEVIL .. "}} {{Timer}} otrzymujesz: {{Damage}} +1 Obrażeń"
							.. "#{{Karta" .. Card.CARD_TOWER .. "}} przywołuje 3 bomby trolla",

							"#{{Karta" .. Card.CARD_STARS .. "}} pojawia {{GoldenChest}} złotą skrzynię"
							..
							"#{{Karta" ..
							Card.CARD_MOON ..
							"}} ujawnia lokacje {{SecretRoom}}{{SuperSecretRoom}}{{UltraSecretRoom}} sekretnych pokoi"
							.. "#{{Karta" ..
							Card.CARD_SUN ..
							"}} ujawnia lokacje {{TreasureRoom}} Pokoju ze skarbcem oraz {{Planetarium}} planetarium, {{HealingRed}} leczy 1 serce, oraz zadaje 5 obrażeń wszystkim przeciwnikom w danym pokoju"
							.. "#{{Karta" .. Card.CARD_JUDGEMENT .. "}} pojawia sklepikarza"
							..
							"#{{Karta" ..
							Card.CARD_WORLD ..
							"}} ujawnia lokacje {{TreasureRoom}} pokoju ze skarbcem oraz {{Planetarium}} planetarium"
						}
					)
				end
			}
		},
		[Mod.Card.MERGED_CARD_REVERSED.ID] = {
			Name = "Sklejona Karta?",
			Description = {
				function(descObj)
					return modifiers[Mod.Card.MERGED_CARD.ID]._modifier(descObj,
						"Aktywuje 2 efekty na podstawie odwróconych kart tarota"
						.. "#(Przytrzymaj {{ButtonSelect}} by zobaczyć efekty)",
						"{{Blank}} {{ButtonX}} Lista Efektów %s/%s {{ButtonB}}",
						{
							"#{{Karta" ..
							Card.CARD_REVERSE_FOOL ..
							"}} Izak upuszcza wszystkie swoje {{Coin}} monety, {{Bomb}} bomby, lub {{Key}} klucze na ziemi"
							..
							"#{{Karta" ..
							Card.CARD_REVERSE_MAGICIAN ..
							"}} aktywuje efekt {{Collectible" ..
							CollectibleType.COLLECTIBLE_TELEKINESIS .. "}} telekinezy 2 razy"
							..
							"#{{Karta" ..
							Card.CARD_REVERSE_HIGH_PRIESTESS ..
							"}} {{Timer}} {{MomBossSmall}} sprawia, że stopa matki depcze izaka przez 15s"
							.. "#{{Karta" ..
							Card.CARD_REVERSE_EMPRESS ..
							"}} {{Timer}} Otrzymujesz na pokój: +1 {{Heart}} serce, {{Tears}} +0.75 Łez, {{Speed}} -0.05 Prędkości",
							"#{{Karta" ..
							Card.CARD_REVERSE_EMPEROR ..
							"}} Przywołuje {{ColorRainbow}}tęczoweg{{CR}} czempiona losowego przeciwnika z tego piętra"
							.. "#{{Karta" ..
							Card.CARD_REVERSE_HIEROPHANT .. "}} Pojawia 1 {{EmptyBoneHeart}} Kościane serce"
							.. "#{{Karta" ..
							Card.CARD_REVERSE_LOVERS .. "}} {{BrokenHeart}} +1 Złamane serce, {{Damage}} +0.25 Obrażeń"
							.. "#{{Karta" ..
							Card.CARD_REVERSE_CHARIOT ..
							"}} {{Timer}} Na 10s otrzymujesz: {{Speed}} x0.5 Mnożnika prędkości, {{Tears}} x2 Mnożnika łez"
							.. "#{{Karta" .. Card.CARD_REVERSE_JUSTICE .. "}} pojawia 1-2 {{GoldenChest}} złotych skrzyń"
							.. "#{{Karta" ..
							Card.CARD_REVERSE_HERMIT ..
							"}} Pojawia 1-5 losowych {{Coin}} monet",

							"#{{Karta" ..
							Card.CARD_REVERSE_WHEEL_OF_FORTUNE ..
							"}} aktywuje efekt {{Collectible" ..
							CollectibleType.COLLECTIBLE_D8 ..
							"}} D8, {{Collectible" ..
							CollectibleType.COLLECTIBLE_D10 ..
							"}} D10, lub {{Collectible" .. CollectibleType.COLLECTIBLE_D12 .. "}} D12"
							..
							"#{{Card" ..
							Card.CARD_REVERSE_STRENGTH ..
							"}} {{Timer}} Na 30s: Połowa wszyskitch przeciwników otrzymuje {{Weakness}} osłabienie"
							..
							"#{{Card" ..
							Card.CARD_REVERSE_HANGED_MAN ..
							"}} {{Timer}} Na 30s masz efekt: {{Collectible" ..
							CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER ..
							"}} Głowy Keeper'a, {{Damage}} x1.5 Mnożnika obrażeń"
							.. "#{{Karta" ..
							Card.CARD_REVERSE_DEATH ..
							"}} {{Friendly}} Pojawia losowego, przyjaznego kościanego przeciwnika"
							.. "#{{Karta" .. Card.CARD_REVERSE_TEMPERANCE .. "}} Aktywuje losowy efekt {{Pill}} piguły"
							.. "#{{Karta" .. Card.CARD_REVERSE_DEVIL .. "}} aktywuje latanie na pokój",

							"#{{Karta" .. Card.CARD_REVERSE_TOWER .. "}} Pojawia kupe losowych kamieni i obiektów"
							..
							"#{{Karta" ..
							Card.CARD_REVERSE_STARS ..
							"}} Usuwa najstarszy przedmiot Izaaka (ignoruje przedmioty startowe) i pojawia losowy item z puli przedmiotów obecnego pokoju"
							..
							"#{{Karta" ..
							Card.CARD_REVERSE_MOON ..
							"}} pojawia {{Card" ..
							Card.CARD_CRACKED_KEY ..
							"}} Złamany klucz, ujawnia lokacje {{UltraSecretRoom}} Ultra Sekretnego Pokoju",

							"#{{Karta" ..
							Card.CARD_REVERSE_SUN ..
							"}} {{Timer}} Otrzymujesz na pokój: {{Collectible" ..
							CollectibleType.COLLECTIBLE_SPIRIT_OF_THE_NIGHT ..
							"}} Duszy nocy, {{Damage}} +1.5 Obrażeń i zaciemnia pokój"
							..
							"#{{Karta" ..
							Card.CARD_REVERSE_JUDGEMENT ..
							"}} aktywuje efekt {{Collectible" ..
							CollectibleType.COLLECTIBLE_D6 ..
							"}} D6 oraz {{Collectible" .. CollectibleType.COLLECTIBLE_D20 .. "}} D20"
							..
							"#{{Karta" ..
							Card.CARD_REVERSE_WORLD ..
							"}} aktywuje efekt {{Collectible" ..
							CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER .. "}} Musimy zejść głębiej"
						}
					)
				end
			}
		},
	}
end
