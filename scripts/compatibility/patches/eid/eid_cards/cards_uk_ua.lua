local Mod = ArachnaMod

return function(modifiers)
	return {
		[Mod.Card.SOUL_OF_ARACHNA.ID] = {
			Name = "Душа Арахни",
			Description = {
				"{{StatusWebbed}} Накладає ефект павутини Арахни на всіх ворогів в кімнаті на 10 секунд",
				"#{{StatusWebbed}} Такі монстри {{Slow}} сповільнюються, слабше відкидуються сльозами гравця та залишають Павучий Кокон після смерті",
				"#{{AracBlueSpider}} Павучі Кокони вилупляються після проходження кімнати, створюючи кілька синіх павуків",
			}
		},
		[Mod.Card.MERGED_CARD.ID] = {
			Name = "Карта-Амальгама",
			Description = {
				function(descObj)
					return modifiers[Mod.Card.MERGED_CARD.ID]._modifier(descObj,
					"Виконує 2 випадкових ефекти, що засновані на ефектах карт таро"
					.. "#(Утримуйте {{ButtonSelect}} щоб побачити усі ефекти)",
					"{{Blank}} {{ButtonX}} Список ефектів %s/%s {{ButtonB}}",
					{
						"#{{Card" .. Card.CARD_FOOL .. "}} Використовує {{Collectible" .. CollectibleType.COLLECTIBLE_D7 .. "}} Д7"
						.. "#{{Card" .. Card.CARD_MAGICIAN .. "}} {{Slow}} Сповільнює усіх ворогів в кімнаті"
						.. "#{{Card" .. Card.CARD_HIGH_PRIESTESS .. "}} {{MomBossSmall}} Нога Мами топче гравця"
						.. "#{{Card" ..
						Card.CARD_EMPRESS .. "}} Використовує {{Collectible" .. CollectibleType.COLLECTIBLE_THE_NAIL .. "}} Цвях"
						.. "#{{Card" .. Card.CARD_EMPEROR .. "}} Показує {{BossRoom}} Кімнату Боса"
						.. "#{{Card" .. Card.CARD_HIEROPHANT .. "}} Створює 2 {{HalfSoulHeart}} Половинки Серця Душі",

						"#{{Card" .. Card.CARD_LOVERS .. "}} Створює 2 {{HalfHeart}} Половинки серця"
						.. "#{{Card" ..
						Card.CARD_CHARIOT .. "}} Використовує {{Collectible" .. CollectibleType.COLLECTIBLE_UNICORN_STUMP ..
						"}} Копито Єдинорога"
						.. "#{{Card" .. Card.CARD_JUSTICE .. "}} Обирає 2 пікапи зі списку і створює їх: {{Coin}} Монетка, {{Key}} Ключ, {{Bomb}} Бомба, або {{Heart}} Сердце"
						.. "#{{Card" ..
						Card.CARD_HERMIT .. "}} Використовує {{Collectible" .. CollectibleType.COLLECTIBLE_KEEPERS_BOX .. "}} Коробку Хранителя"
						.. "#{{Card" .. Card.CARD_WHEEL_OF_FORTUNE .. "}} Використовує {{Collectible" .. CollectibleType.COLLECTIBLE_PORTABLE_SLOT .. "}} Портативну Слот-машину 5 разів",

						"#{{Card" .. Card.CARD_STRENGTH .. "}} {{Timer}} На 1 кімнату гравець отримує {{Collectible" .. CollectibleType.COLLECTIBLE_ODD_MUSHROOM_LARGE .. "}} Дивний Гриб"
						.. "#{{Card" .. Card.CARD_HANGED_MAN .. "}} Знищує усе каміння та ями в кімнаті"
						.. "#{{Card" .. Card.CARD_DEATH .. "}} Усі монстри в кімнаті отримують 20 одиниць урону"
						.. "#{{Card" .. Card.CARD_TEMPERANCE .. "}} Створює {{DemonBeggar}} Демонічного Жебрака"
						.. "#{{Card" .. Card.CARD_DEVIL .. "}} {{Timer}} {{Damage}} +1 одиниця урону на 1 кімнату"
						.. "#{{Card" .. Card.CARD_TOWER .. "}} Створює 3 Троль-Бомби",

						"#{{Card" .. Card.CARD_STARS .. "}} Створює {{GoldenChest}} Золоту Скриню"
						.. "#{{Card" .. Card.CARD_MOON .. "}} Показує УСІ {{SecretRoom}}{{SuperSecretRoom}}{{UltraSecretRoom}} секретні кімнати"
						.. "#{{Card" ..
						Card.CARD_SUN ..
						"}} Показує {{TreasureRoom}} Кімнати Скарбів та {{Planetarium}} Планетарій, {{HealingRed}} відновлює 1 серце здоров'я, ранить усіх ворогів у кімнаті на 5 одиниць здоров'я"
						.. "#{{Card" .. Card.CARD_JUDGEMENT .. "}} Призиває Крамаря"
						.. "#{{Card" .. Card.CARD_WORLD .. "}} Показує {{TreasureRoom}} Кімнати Скарбів та {{Planetarium}} Планетарій"
					}
				)
				end
			}
		},
		[Mod.Card.MERGED_CARD_REVERSED.ID] = {
			Name = "Карта-Амальгама?",
			Description = {
				function(descObj)
					return modifiers[Mod.Card.MERGED_CARD.ID]._modifier(descObj,
					"Виконує 2 випадкових ефекти, що засновані на ефектах обернених карт таро"
					.. "#(Утримуйте {{ButtonSelect}} щоб побачити усі ефекти)",
					"{{Blank}} {{ButtonX}} Список ефектів %s/%s {{ButtonB}}",
					{
						"#{{Card" .. Card.CARD_REVERSE_FOOL .. "}} Викидає усі {{Coin}} Монети, {{Bomb}} Бомби, або {{Key}} Ключі гравця на підлогу"
						.. "#{{Card" .. Card.CARD_REVERSE_MAGICIAN .. "}} Використовує {{Collectible" .. CollectibleType.COLLECTIBLE_TELEKINESIS .. "}} Телекінез 2 рази"
						.. "#{{Card" .. Card.CARD_REVERSE_HIGH_PRIESTESS .. "}} {{Timer}} {{MomBossSmall}} Мамина Нога намагається розчавити гравця протягом 15 секунд"
						.. "#{{Card" ..
						Card.CARD_REVERSE_EMPRESS .. "}} {{Timer}} Дає на 1 кімнату: +1 {{Heart}} до Здоров'я, {{Tears}} +0.75 до Швидкості сліз, {{Speed}} -0.05 до Швидкості гравця",

						"#{{Card" .. Card.CARD_REVERSE_EMPEROR .. "}} Викликає {{ColorRainbow}}веселкову{{CR}} чемпіонську версію одного з монстрів, якого можна зустріти на поточному поверсі"
						.. "#{{Card" .. Card.CARD_REVERSE_HIEROPHANT .. "}} Створює 1 {{EmptyBoneHeart}} Костяне сердце"
						.. "#{{Card" .. Card.CARD_REVERSE_LOVERS .. "}} {{BrokenHeart}} +1 Зламане Серце, {{Damage}} +0.25 одиниць урону"
						.. "#{{Card" ..
						Card.CARD_REVERSE_CHARIOT .. "}} {{Timer}} На десять секунд вдвічі зменшує {{Speed}} Швидкість гравца, та вдвічі збідьшує {{Tears}} Швидкість сліз"
						.. "#{{Card" .. Card.CARD_REVERSE_JUSTICE .. "}} Створює 1-2 {{GoldenChest}} золоті скрині"
						.. "#{{Card" ..
						Card.CARD_REVERSE_HERMIT ..
						"}} Створює 1-5 випадкових {{Coin}} монеток",

						"#{{Card" .. Card.CARD_REVERSE_WHEEL_OF_FORTUNE .. "}} Використовує {{Collectible" .. CollectibleType.COLLECTIBLE_D8 .. "}} Д8, {{Collectible" .. CollectibleType.COLLECTIBLE_D10 .. "}} Д10, або {{Collectible" .. CollectibleType.COLLECTIBLE_D12 .. "}} Д12"
						.. "#{{Card" .. Card.CARD_REVERSE_STRENGTH .. "}} {{Weakness}} Послаблює половину монстрів в кімнаті на {{Timer}} 30 секунд"
						.. "#{{Card" .. Card.CARD_REVERSE_HANGED_MAN .. "}} {{Timer}} На 30 секунд дає ефект {{Collectible" .. CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER .. "}} Голови Хранителя та збільшує {{Damage}} урон в 1.5 рази"
						.. "#{{Card" .. Card.CARD_REVERSE_DEATH .. "}} {{Friendly}} Викликає дружнього костяного ворога"
						.. "#{{Card" .. Card.CARD_REVERSE_TEMPERANCE .. "}} Використовує випадкову {{Pill}} таблетку"
						.. "#{{Card" .. Card.CARD_REVERSE_DEVIL .. "}} Дає можливість літати на 1 кімнату",

						"#{{Card" .. Card.CARD_REVERSE_TOWER .. "}} Створює поруч з гравцем кластер випадкового каміння"
						.. "#{{Card" .. Card.CARD_REVERSE_STARS .. "}} Видаляє найстаріший предмет в інвентарі гравця і створює випадковий предмет з пулу поточної кімнати"
						.. "#{{Card" .. Card.CARD_REVERSE_MOON .. "}} Створює {{Card" .. Card.CARD_CRACKED_KEY .. "}} Зламаний Ключ та показує {{UltraSecretRoom}} Ультра Секретну Кімнату",

						"#{{Card" ..
						Card.CARD_REVERSE_SUN ..
						"}} {{Timer}} На 1 кімнату дає гравцю ефект {{Collectible" .. CollectibleType.COLLECTIBLE_SPIRIT_OF_THE_NIGHT .. "}} Примари Ночі, {{Damage}} +1.5 одиниць урону та, затемнює кімнату"
						.. "#{{Card" .. Card.CARD_REVERSE_JUDGEMENT .. "}} Використовує {{Collectible" .. CollectibleType.COLLECTIBLE_D6 .. "}} Д6 та {{Collectible" .. CollectibleType.COLLECTIBLE_D20 .. "}} Д20"
						.. "#{{Card" .. Card.CARD_REVERSE_WORLD .. "}} Використовує {{Collectible" .. CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER .. "}} Копни Глибше!"
					}
				)
				end
			}
		},
	}
end
