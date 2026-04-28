local Mod = ArachnaMod
local ARC_EID = Mod.EID_Support
local Item = Mod.Item

return function(modifiers)
	return {
		[Item.SPIDER_CAKE.ID] = {
			Name = "Pajęcze ciasto",
			Description = {
				"{{WebHeart}} pojawia 1 niciane serce",
				"#Gwarantuje {{Collectible" .. CollectibleType.COLLECTIBLE_MYSTERY_GIFT .. "}} Prezent Niespodzianke",
				function(descObj)
					local years = Item.SPIDER_CAKE:GetYearDifference()
					return string.format("#% lat minęło od wydania moda!", years)
				end,
				function(descObj)
					local stats = modifiers[Item.SPIDER_CAKE.ID]._modifier(descObj)
					return "#↑ {{Speed}} +" .. stats.Speed .. " Prędkość"
						.. "#↑ {{Tears}} +" .. stats.Tears .. " Łzy"
						.. "#↑ {{Damage}} +" .. stats.Damage .. " Obrażenia"
						.. "#↑ {{Range}} +" .. stats.Range .. " Zasięg"
						.. "#↑ {{Shotspeed}} +" .. stats.ShotSpeed .. " Prędkość strzału"
						.. "#↑ {{Luck}} +" .. stats.Luck .. " Szczęście"
				end
			},
			FallbackDescription = {
				"{{WebHeart}} pojawia 1 niciane sercet",
				"#Gwarantuje  {{Collectible" .. CollectibleType.COLLECTIBLE_MYSTERY_GIFT .. "}}",
				"#↑ Wszystkie statystyki idą w górę, na podstawie ile lat minęło od wydania moda"
			}
		},
		[Item.SPIDER_DONUT.ID] = {
			Name = "Pajęczy pączek",
			Description = {
				"{{WebHeart}} +1 niciane serce",
				"#↑ {{Damage}} +0.69 Obrażeń",
				"#{{AracBlueSpider}} Pojawia 2-3 duże, fioletowe pająki"
			}
		},
		[Item.OLD_SHOEBOX.ID] = {
			Name = "Stare pudełko po butach",
			Description = {
				"{{WebHeart}} pojawia +1 niciane sercet",
				"#↑ {{Speed}} +0.15 Prędkość",
				"#↑ {{Tears}} +0.33 Łzy",
				"#{{AracBlueSpider}} Pojawia 7-14 niebieskich pająków"
			}
		},
		[Item.GUMMY_SPIDERS.ID] = {
			Name = "Żelki pająki",
			Description = {
				"{{WebHeart}} +2 Niciane serce",
				"#↑ {{Tears}} +0.61 Łzy",
				"#{{AracBlueSpider}} Pojawia kilka {{ColorRainbow}}specjalnych{{CR}} przyjaznych pająków"
			}
		},
		[Item.CANDY_FLOSS.ID] = {
			Name = "Wata Cukrowa",
			Description = {
				"{{WebHeart}} Zeruje czerwone serca izaaka, pojawiając za to niciane serca, 3 minimum",
				"#{{Slow}} 5% szans by wystrzelić spowalniający, rozbijające się łzy",
				"#{{Luck}} 100% szans z 20 szczęścia"
			}
		},
		[Item.ARACHNAS_SPOOL.ID] = {
			Name = "Szpula Arachny",
			Description = {
				"{{Throwable}} Rzuć szpulę która zostawia dużą pajęczyne",
				"#{{StatusWebbed}} Przeciwnicy na pajęczyni są {{Slow}} spowolnenie, są mniej odpychani, i zostawiają pajęcze jaja po śmierci",
				"#{{AracBlueSpider}} Jaja wyklują się po ukończeniu pokoju, zostawiając niebieskie pająki",
				"#{{BossRoom}} Ranienie bossów którzy stoją na pajęczynie wypełnia pasek, gdy jest pełny, pojawią się przyjazne pająki"
			},
			BookOfBelial = {
				"Szpula i pajęczyny będą się {{Burning}} palić"
			}
		},
		[Item.DIVINE_CLOTH.ID] = {
			Name = "Niebiański Jedwab",
			Description = {
				"{{StatusSpiderBite}} Uwiązuje przeciwników i zadaje 0.5x obrażeń Izaaka wokół przeciwników. Przeciwnicy są {{Slow}} spowolnieni, otrzymują mniej odpychu, oraz zostawiają pajęcze jaja po śmierci",
				"#{{AracBlueSpider}} Jaja wyklują się po ukończeniu pokoju, zostawiając niebieskie pająki",
				"#{{StatusSpiderBite}} Jaja mogą być {{ColorRainbow}}specjalne{{CR}}, z których wyklują się wyjątkowe pająki",
				"#{{BossRoom}} Ranienie uwiązanych przeciwników wypełnia pasek, gdy jest pełny, pojawia pajęcze jaja"
			},
			BookOfBelial = {
				"{{Burning}} podpala pobliskich przeciwników"
			}
		},
		[Item.EGG_TOSS.ID] = {
			Name = "Rzut jajem",
			Description = {
				"{{Throwable}} Złap i rzuć pajęcze jaja",
				"#{{AracBlueSpider}} Wykluwa pajęcze jaja normalnie i aktywuje efekty {{ColorRainbow}}specjalnych{{CR}} kolorowych jaj, gdy to jajo coś uderzy",
				"#↑ Jeśli jajo uderzy przeciwnika, może pojawić więcej oraz większe pająki",
			}
		},
		[Item.YARN.ID] = {
			Name = "Kłębek nici",
			Description = {
				"Blokuje pociski",
				"#Kopie bliskich przeciwników prądem",
				"#{{WebHeart}} Pojawia niciane serce co 4 pokoje"
			}
		},
		[Item.ARACHNIDS_GRIP.ID] = {
			Name = "Chwyt Pajęczaka",
			Description = {
				"{{Poison}} 25% szans by wystrzelić trującą łzą",
				"#Przeciwnicy mogą upuszczać pajęcze jaja po śmierci oraz gwarantować kruchego orbitala po podniesieniu",
				"#Orbital may break when blocking projectiles or dealing damage, spawning a {{AracBlueSpider}} blue spider",
			}
		},
		[Item.YARN_HEART.ID] = {
			Name = "Serce z przędzy",
			Description = {
				"{{WebHeart}} +1 Niciane serce"
			}
		},
		[Item.MECHANICAL_EYE.ID] = {
			Name = "Mechaniczne oko",
			Description = {
				"Orbital",
				"#Blokuje pociski",
				"#Wyświelta losowy item aktywny, który ma taką samą ilość ładunków co ma przedmiot aktywny Izaaka",
				"#Używanie item aktywnego także aktywuje efektu wyświetlanego przedmiotu",
				"#Wyświetlany item jest rerollowany po zmianie pokoju lub użyciu przedmiotu aktywnego"
			},
			BFFS = {
				"Aktywuje efekt 2 razy, podobnie {{Collectible" ..
				CollectibleType.COLLECTIBLE_CAR_BATTERY .. "}} Baterii samochodowej"
			}
		},
		[Item.GEPTAMERON.ID] = {
			Name = "Geptameron",
			Description = {
				"Aktywuje efekt bazowany na liczniku:",
				"#{{1}} Ujawnia lokacje {{SecretRoom}}{{SuperSecretRoom}} oraz aktywuje efekt {{Collectible" ..
				CollectibleType.COLLECTIBLE_DADS_KEY .. "}}",
				"#{{2}} Przywołuje tymczasowych, przyjaznych, martwych Izaaków. Mogą upuścić {{RottenHeart}} po śmierci",
				"#{{3}} Wszyscy przeciwnicy są {{Charm}} zauroczeni lub upuszczają 3 {{Trinket" ..
				TrinketType.TRINKET_LOCUST_OF_WRATH .. "}} szarańcze po śmierci",
				"#{{4}} {{Timer}} Na okres jednego pokoju: Otrzymasz 2 {{Collectible" ..
				CollectibleType.COLLECTIBLE_GUARDIAN_ANGEL .. "}} i {{HolyMantleSmall}} święte tarcze",
				"#{{5}} Wszyscy przeciwnicy upuszczają {{Coin}} znikające monety po śmierci",
				"#{{6}} Wystrzeli pociski w losowe miejsce na 10 sekund", --Fires missiles in random locations for 10 seconds
				"#{{7}} 1-3 przeciwników zostawiają znikające monety po śmierci , potem przekazują efekt innemu przeciwnikowi"
			}
		},
		[Item.GLASSES_3D.ID] = {
			Name = "Okulary 3D",
			Description = {
				"5% szans by wystrzelic łzę \"3D\", które po uderzeniu przeciwnika, zamienia go w 2 przyjazne jego kopie",
				"#{{Luck}} 25% szans z 20 szczęścia",
				"#Ci przyjaźni przeciwnicy nie otrzymują obrażeń, ale znikają po wyczyszczeniu pokoju",
			}
		},
		[Item.MUTAGEN.ID] = {
			Name = "Mutagen",
			Description = {
				"↑ {{Damage}} +1 Obrażeń",
				"#{{AracBlueSpider}} 20% szans by pojawić 3-5 {{ColorRainbow}}specjalne{{CR}} przyjaznego pająki po wejściu do nowego pokoju",
				"#{{AracBlueSpider}} Wszystkie pająki poza tych z pajęczych jaj mogą mieć {{ColorRainbow}}specjalne{{CR}} efekty"
			}
		},
		[Item.TESTAMENT.ID] = {
			Name = "Testament",
			Description = {
				"Teleportuje izaaka do piętra z kopiami jego przedmiotów",
				"#Po wybraniu przedmiotu z tego piętra, Izaak wróci tam, skąd przybył",
				"#Wybraniu przedmiot pojawi się na początku nastepnęgo podejścia",
				"#Nie posiadanie żadnego przedmiotu pojawi {{Collectible" ..
				CollectibleType.COLLECTIBLE_EDENS_BLESSING .. "}} Błogosłowianie Edena"
			}
		},
		[Item.LIL_ARACHNA.ID] = {
			Name = "Mała Arachna",
			Description = {
				"{{Slow}} Strzela spowalniające, rozbryzgujące się łzy",
				"#Łzy zadają 3.5 obrażeń",
				"#{{AracBlueSpider}} 25% szans na to by łzy {{StatusSpiderBite}} uwiązały przeciwników. Przeciwnicy są {{Slow}} spowolnieni, otrzymują są mniej odpychani, oraz upuszczają kolorowe pajęcze jaja po śmierci które wykluwają się w przyjazne pająki"
			},
		},
		[Item.DADS_NEWSPAPER.ID] = {
			Name = "Gazeta Taty",
			Description = {
				"Izaak trzyma przy sobie gazetę",
				"#Wciśnij przycisk ataku 2 razy by nią machnąć",
				"#{{Confusion}} Zadaje przeciętne obrażenia oraz ogłusza przeciwników",
				"#Zabija odrazu pająki i muchy"
			}
		},
		[Item.BEST_BUD_BALL.ID] = {
			Name = "Kula Krzepkiego Kumpla",
			Description = {
				"{{Throwable}} Można nią rzucić w bossów, aby spróbować ich złapać",
				"#{{LuckSmall}} Szansa na złapanie skaluje się z zdrowiem bossa, oraz szczęściem Izaaka",
				"#{{Friendly}} Użyciue przedmiotu po złapaniu bossa przywołuje jego przyjazną wersję",
				"#Nadepnięcie kuli automatycznie ją ładuje",
				"#!!! Tylko jeden boss może być aktywny naraz"
			}
		},
	}
end
