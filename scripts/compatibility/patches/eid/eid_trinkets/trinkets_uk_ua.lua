local Mod = ArachnaMod
local Trinket = Mod.Trinket

return function(modifiers)
	return {
		[Trinket.INFESTED_PENNY.ID] = {
			Name = "Отруйна копійка",
			Description = {
				"{{AracBlueSpider}} Створює синього павука коли гравець отримує монетку",
				"#{{WebHeart}} Шанс в 20% додатково створити Шовкове Серце",
				"#Чим дорожча монетка - тим більше шанс створення серця"
			},
		},
		[Trinket.SPINDLE.ID] = {
			Name = "Веретено",
			Description = {
				"{{StatusWebbed}} Дотик до ворогів накладає на них ефект павутини Арахни на 5 секунд",
				"#{{StatusWebbed}} Такі монстри {{Slow}} сповільнюються, слабше відкидуються сльозами гравця та залишають Павучий Кокон після смерті",
				"#{{AracBlueSpider}} Павучі Кокони вилупляються після проходження кімнати, створюючи кілька синіх павуків",
				"#{{WebHeart}} Збільшує шанс появи Шовкових Серцець на 10%",
				function(descObj)
					return modifiers[Trinket.SPINDLE.ID]._modifier(descObj,
						"#{{Collectible" .. CollectibleType.COLLECTIBLE_MIDAS_TOUCH .. "}} Павучі Кокони стають {{ColorGold}}золотими{{CR}} та створюють золотих павуків"
					)
				end
			}
		},
		[Trinket.WHITE_STRING.ID] = {
			Name = "Біла нитка",
			Description = {
				"{{WebHeart}} +1 Шовкове Серце після переходу на новий рівень"
			},
		},
	}
end
