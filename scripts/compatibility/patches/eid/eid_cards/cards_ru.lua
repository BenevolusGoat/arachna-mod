local Mod = ARACHNAMOD

return function(modifiers)
	return {
		[Mod.Card.SOUL_OF_ARACHNA.ID] = {
			Name = "Душа Арахны",
			Description = {
				"{{StatusSpiderBite}} Опутывает всех врагов, замедляя их и превращая в паучьи яйца при смерти",
				"#{{StatusSpiderBite}} Яйца могут быть {{ColorRainbow}}особыми{{CR}}, создающими особых пауков",
			}
		},
		[Mod.Card.MERGED_CARD.ID] = {
			Name = "Сшитая карта",
			Description = {
				function(descObj)
					return modifiers[Mod.Card.MERGED_CARD.ID]._modifier(descObj,
					"Вызывает 2 случайных эффекта, основанных на картах таро"
					.. "#(Зажмите {{ButtonSelect}}, чтобы показать эффекты)",
					"{{Blank}} {{ButtonX}} Список Эффектов %s/%s {{ButtonB}}",
					{
						"#{{Card" .. Card.CARD_FOOL .. "}} Использует {{Collectible" .. CollectibleType.COLLECTIBLE_D7 .. "}} D7"
						.. "#{{Card" .. Card.CARD_MAGICIAN .. "}} {{Slow}} Замедляет всех врагов в комнате"
						.. "#{{Card" .. Card.CARD_HIGH_PRIESTESS .. "}} {{MomBossSmall}} Мамина Нога наступает на Исаака"
						.. "#{{Card" ..
						Card.CARD_EMPRESS .. "}} Использует {{Collectible" .. CollectibleType.COLLECTIBLE_THE_NAIL .. "}} Гвоздь"
						.. "#{{Card" .. Card.CARD_EMPEROR .. "}} Показывает {{BossRoom}} Комнату Босса на карте"
						.. "#{{Card" .. Card.CARD_HIEROPHANT .. "}} Создаёт 2 {{HalfSoulHeart}} Половинки Сердца Души",

						"#{{Card" .. Card.CARD_LOVERS .. "}} Создаёт 2 {{HalfHeart}} Половинки Сердца"
						.. "#{{Card" ..
						Card.CARD_CHARIOT .. "}} Использует {{Collectible" .. CollectibleType.COLLECTIBLE_UNICORN_STUMP ..
						"}} Копыто Единорога"
						.. "#{{Card" .. Card.CARD_JUSTICE .. "}} Создаёт 2 любых предмета из следующих: {{Coin}} монета, {{Key}} ключ, {{Bomb}} бомба или {{Heart}} сердце"
						.. "#{{Card" ..
						Card.CARD_HERMIT .. "}} Использует {{Collectible" .. CollectibleType.COLLECTIBLE_KEEPERS_BOX .. "}} Коробок Хранителя"
						.. "#{{Card" .. Card.CARD_WHEEL_OF_FORTUNE .. "}} Использует {{Collectible" .. CollectibleType.COLLECTIBLE_PORTABLE_SLOT .. "}} Переносной Автомат 3 раза",

						"#{{Card" .. Card.CARD_STRENGTH .. "}} {{Timer}} Эффект {{Collectible" .. CollectibleType.COLLECTIBLE_ODD_MUSHROOM_LARGE .. "}} Странного Гриба на комнату"
						.. "#{{Card" .. Card.CARD_HANGED_MAN .. "}} Разрушает все камни и заполняет все ямы в комнате"
						.. "#{{Card" .. Card.CARD_DEATH .. "}} Наносит 20 урона всем врагам в комнате"
						.. "#{{Card" .. Card.CARD_TEMPERANCE .. "}} Создаёт {{DemonBeggar}} Дьявольского Попрошайку"
						.. "#{{Card" .. Card.CARD_DEVIL .. "}} {{Timer}} Даёт {{Damage}} +1 Урон на комнату"
						.. "#{{Card" .. Card.CARD_TOWER .. "}} Создаёт 3 Тролль-бомбы",

						"#{{Card" .. Card.CARD_STARS .. "}} Создаёт {{GoldenChest}} золотой сундук"
						.. "#{{Card" .. Card.CARD_MOON .. "}} Показывает на карте все {{SecretRoom}}{{SuperSecretRoom}}{{UltraSecretRoom}} секретные комнаты"
						.. "#{{Card" ..
						Card.CARD_SUN ..
						"}} Показывает на карте {{TreasureRoom}} Сокровищницу и {{Planetarium}} Планетарий, {{HealingRed}} лечит 1 сердце, наносит 5 урона всем врагам в комнате"
						.. "#{{Card" .. Card.CARD_JUDGEMENT .. "}} Создаёт лавочника"
						.. "#{{Card" .. Card.CARD_WORLD .. "}} Показывает на карте {{TreasureRoom}} Сокровищницу и {{Planetarium}} Планетарий"
					}
				)
				end
			}
		},
		[Mod.Card.MERGED_CARD_REVERSED.ID] = {
			Name = "Сшитая Карта?",
			Description = {
				function(descObj)
					return modifiers[Mod.Card.MERGED_CARD.ID]._modifier(descObj,
					"Вызывает 2 случайных эффекта, основанных на перевернутых картах таро"
					.. "#(Зажмите {{ButtonSelect}}, чтобы показать эффекты)",
					"{{Blank}} {{ButtonX}} Список Эффектов %s/%s {{ButtonB}}",
					{
						"#{{Card" .. Card.CARD_REVERSE_FOOL .. "}} Выбрасывает все {{Coin}} монеты, {{Bomb}} бомбы или {{Key}} ключи Исаака на пол"
						.. "#{{Card" .. Card.CARD_REVERSE_MAGICIAN .. "}} Использует {{Collectible" .. CollectibleType.COLLECTIBLE_TELEKINESIS .. "}} Телекинез 2 раза"
						.. "#{{Card" .. Card.CARD_REVERSE_HIGH_PRIESTESS .. "}} {{Timer}} {{MomBossSmall}} Мамина Нога топает по полу 15 секунд"
						.. "#{{Card" ..
						Card.CARD_REVERSE_EMPRESS .. "}} {{Timer}} Даёт +1 {{Heart}} Здоровье, {{Tears}} +0.75 Скорострельности, {{Speed}} -0.05 Скорости на комнату",

						"#{{Card" .. Card.CARD_REVERSE_EMPEROR .. "}} Создаёт {{ColorRainbow}}радужного{{CR}} чемпиона случайного врага этажа"
						.. "#{{Card" .. Card.CARD_REVERSE_HIEROPHANT .. "}} Создаёт 1 {{EmptyBoneHeart}} Костяное Сердце"
						.. "#{{Card" .. Card.CARD_REVERSE_LOVERS .. "}} {{BrokenHeart}} +1 Разбитое Сердце, {{Damage}} +0.25 Урона"
						.. "#{{Card" ..
						Card.CARD_REVERSE_CHARIOT .. "}} {{Timer}} На 10 секунд даёт {{Speed}} x0.5 Множитель Скорости и {{Tears}} x2 Множитель Скорострельности"
						.. "#{{Card" .. Card.CARD_REVERSE_JUSTICE .. "}} Создаёт 1-2 {{GoldenChest}} золотых сундука"
						.. "#{{Card" ..
						Card.CARD_REVERSE_HERMIT ..
						"}} Создаёт 1-5 случайных {{Coin}} монет",

						"#{{Card" .. Card.CARD_REVERSE_WHEEL_OF_FORTUNE .. "}} Использует {{Collectible" .. CollectibleType.COLLECTIBLE_D8 .. "}} D8, {{Collectible" .. CollectibleType.COLLECTIBLE_D10 .. "}} D10 или {{Collectible" .. CollectibleType.COLLECTIBLE_D12 .. "}} D12"
						.. "#{{Card" .. Card.CARD_REVERSE_STRENGTH .. "}} {{Timer}} На половину врагов в комнате на 30 секунд накладывается {{Weakness}} ослабление"
						.. "#{{Card" .. Card.CARD_REVERSE_HANGED_MAN .. "}} {{Timer}} На 30 секунд даёт {{Collectible" .. CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER .. "}} Голову Хранителя и {{Damage}} x1.5 Множитель Урона"
						.. "#{{Card" .. Card.CARD_REVERSE_DEATH .. "}} {{Friendly}} Создаёт случайного дружественного врага-скелета"
						.. "#{{Card" .. Card.CARD_REVERSE_TEMPERANCE .. "}} Использует случайную {{Pill}} пилюлю"
						.. "#{{Card" .. Card.CARD_REVERSE_DEVIL .. "}} Полёт на комнату",

						"#{{Card" .. Card.CARD_REVERSE_TOWER .. "}} Создаёт несколько случайных камней и препятствий"
						.. "#{{Card" .. Card.CARD_REVERSE_STARS .. "}} Удаляет самый старый пассивный артефакт (не стартовый) и создаёт 1 случайный артефакт из пула текущей комнаты"
						.. "#{{Card" .. Card.CARD_REVERSE_MOON .. "}} Создаёт {{Card" .. Card.CARD_CRACKED_KEY .. "}} Треснувший Ключи и показывает на карте {{UltraSecretRoom}} Ультра-секретную комнату",

						"#{{Card" ..
						Card.CARD_REVERSE_SUN ..
						"}} {{Timer}} Даёт {{Collectible" .. CollectibleType.COLLECTIBLE_SPIRIT_OF_THE_NIGHT .. "}} Духа Ночи и {{Damage}} +1.5 Урона на комнату, затемняет комнату"
						.. "#{{Card" .. Card.CARD_REVERSE_JUDGEMENT .. "}} Использует {{Collectible" .. CollectibleType.COLLECTIBLE_D6 .. "}} D6 и {{Collectible" .. CollectibleType.COLLECTIBLE_D20 .. "}} D20"
						.. "#{{Card" .. Card.CARD_REVERSE_WORLD .. "}} Использует {{Collectible" .. CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER .. "}} Нам Нужно Глубже!"
					}
				)
				end
			}
		},
	}
end
