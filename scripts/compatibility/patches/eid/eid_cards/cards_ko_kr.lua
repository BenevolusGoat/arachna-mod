local Mod = ARACHNAMOD

return function(modifiers)
	return {
		[Mod.Card.SOUL_OF_ARACHNA.ID] = {
			Name = "아라크나의 영혼",
			Description = {
				"{{StatusWebbed}} 모든 적이 거미줄에 10초간 걸려듭니다.",
				"#{{StatusWebbed}} 거미줄에 걸린 적은 {{Slow}} 둔화되고 받는 넉백이 감소하며 사망 시 거미 알집을 생성합니다.",
				"#{{AracBlueSpider}} 거미 알집은 방 클리어 시 터지며 파란 아군 거미를 여러 마리 소환합니다.",
			}
		},
		[Mod.Card.MERGED_CARD.ID] = {
			Name = "합쳐진 카드",
			Description = {
				function(descObj)
					return modifiers[Mod.Card.MERGED_CARD.ID]._modifier(descObj,
					"두 가지 타로 카드를 기반으로 하는 무작위 효과가 발동됩니다."
					.. "#({{ButtonSelect}} 버튼을 꾹 눌러 효과 목록을 확인하세요.)",
					"{{Blank}} {{ButtonX}} 효과 리스트 %s/%s {{ButtonB}}",
					{
						"#{{Card" .. Card.CARD_FOOL .. "}} {{Collectible" .. CollectibleType.COLLECTIBLE_D7 .. "}} 7면 주사위의 효과가 발동됩니다."
						.. "#{{Card" .. Card.CARD_MAGICIAN .. "}} {{Slow}} 모든 적이 잠시 둔화됩니다."
						.. "#{{Card" .. Card.CARD_HIGH_PRIESTESS .. "}} {{MomBossSmall}} 엄마의 발이 사용자를 짓밟습니다."
						.. "#{{Card" ..
						Card.CARD_EMPRESS .. "}} {{Collectible" .. CollectibleType.COLLECTIBLE_THE_NAIL .. "}} 대못 아이템의 효과가 발동됩니다."
						.. "#{{Card" .. Card.CARD_EMPEROR .. "}} {{BossRoom}} 보스 방 위치가 공개됩니다."
						.. "#{{Card" .. Card.CARD_HIEROPHANT .. "}} {{HalfSoulHeart}} 반쪽짜리 소울 하트 2개를 생성합니다.",

						"#{{Card" .. Card.CARD_LOVERS .. "}} {{HalfHeart}} 반쪽짜리 하트 2개를 생성합니다."
						.. "#{{Card" ..
						Card.CARD_CHARIOT .. "}} {{Collectible" .. CollectibleType.COLLECTIBLE_UNICORN_STUMP ..
						"}} 유니콘 뿔대의 효과가 발동됩니다."
						.. "#{{Card" .. Card.CARD_JUSTICE .. "}} {{Coin}} 동전, {{Key}} 열쇠, {{Bomb}} 폭탄, 또는 {{Heart}} 하트 중 무작위의 2가지를 하나씩 생성합니다."
						.. "#{{Card" ..
						Card.CARD_HERMIT .. "}} {{Collectible" .. CollectibleType.COLLECTIBLE_KEEPERS_BOX .. "}} 키퍼의 상자가 발동됩니다."
						.. "#{{Card" .. Card.CARD_WHEEL_OF_FORTUNE .. "}} {{Collectible" .. CollectibleType.COLLECTIBLE_PORTABLE_SLOT .. "}} 휴대용 슬롯 머신이 5회 발동됩니다.",

						"#{{Card" .. Card.CARD_STRENGTH .. "}} {{Timer}} 사용한 방에서만 {{Collectible" .. CollectibleType.COLLECTIBLE_ODD_MUSHROOM_LARGE .. "}} 납작한 수상한 버섯의 효과가 발동됩니다."
						.. "#{{Card" .. Card.CARD_HANGED_MAN .. "}} 방의 모든 바위를 파괴하고 구덩이를 전부 메웁니다."
						.. "#{{Card" .. Card.CARD_DEATH .. "}} 모든 적에게 20의 광역 피해를 입힙니다."
						.. "#{{Card" .. Card.CARD_TEMPERANCE .. "}} {{DemonBeggar}} 악마 거지 1명을 소환합니다."
						.. "#{{Card" .. Card.CARD_DEVIL .. "}} {{Timer}} 해당 방에서만 {{Damage}} +1 공격력"
						.. "#{{Card" .. Card.CARD_TOWER .. "}} 트롤 폭탄 3개를 생성합니다.",

						"#{{Card" .. Card.CARD_STARS .. "}} {{GoldenChest}} 황금 상자 하나를 생성합니다."
						.. "#{{Card" .. Card.CARD_MOON .. "}} {{SecretRoom}}{{SuperSecretRoom}}{{UltraSecretRoom}} 모든 비밀 방 계열 방의 위치가 공개됩니다."
						.. "#{{Card" ..
						Card.CARD_SUN ..
						"}} {{TreasureRoom}} 보물 방, {{Planetarium}} 천체관의 위치를 공개하고 {{HealingRed}} 하트 1개분의 체력을 회복하고, 모든 적에게 5의 광역 피해를 입힙니다."
						.. "#{{Card" .. Card.CARD_JUDGEMENT .. "}} 상점 주인 1명을 소환합니다."
						.. "#{{Card" .. Card.CARD_WORLD .. "}} {{TreasureRoom}} 보물 방, {{Planetarium}} 천체관의 위치가 공개됩니다."
					}
				)
				end
			}
		},
		[Mod.Card.MERGED_CARD_REVERSED.ID] = {
			Name = "합쳐진 카드?",
			Description = {
				function(descObj)
					return modifiers[Mod.Card.MERGED_CARD.ID]._modifier(descObj,
					"두 가지 역방향 타로 카드를 기반으로 하는 무작위 효과가 발동됩니다."
					.. "#({{ButtonSelect}} 버튼을 꾹 눌러 효과 목록을 확인하세요.)",
					"{{Blank}} {{ButtonX}} 효과 리스트 %s/%s {{ButtonB}}",
					{
						"#{{Card" .. Card.CARD_REVERSE_FOOL .. "}} 소지한 {{Coin}} 동전, {{Bomb}} 폭탄, 또는 {{Key}} 열쇠를 전부 바닥에 내려놓습니다."
						.. "#{{Card" .. Card.CARD_REVERSE_MAGICIAN .. "}} {{Collectible" .. CollectibleType.COLLECTIBLE_TELEKINESIS .. "}} 염력의 효과를 2회 발동합니다."
						.. "#{{Card" .. Card.CARD_REVERSE_HIGH_PRIESTESS .. "}} {{Timer}} {{MomBossSmall}} 15초간 엄마의 발이 사용자를 밟으려 합니다."
						.. "#{{Card" ..
						Card.CARD_REVERSE_EMPRESS .. "}} {{Timer}} 해당 방에서만 +1 {{Heart}} 체력, {{Tears}} +0.75 연사력, {{Speed}} -0.05 이동 속도",

						"#{{Card" .. Card.CARD_REVERSE_EMPEROR .. "}} 이번 층의 무작위 적의 {{ColorRainbow}}무지갯빛{{CR}} 챔피언을 소환합니다."
						.. "#{{Card" .. Card.CARD_REVERSE_HIEROPHANT .. "}} {{EmptyBoneHeart}} 뼈 하트 1개를 생성합니다."
						.. "#{{Card" .. Card.CARD_REVERSE_LOVERS .. "}} {{BrokenHeart}} 깨진 하트 +1개를 얻고 {{Damage}} 공격력이 +0.25만큼 {{ColorYellow}}영구히{{CR}} 증가합니다."
						.. "#{{Card" ..
						Card.CARD_REVERSE_CHARIOT .. "}} {{Timer}} 10초간 {{Speed}} x0.5 이동 속도 배수, {{Tears}} x2 연사력 배수 적용"
						.. "#{{Card" .. Card.CARD_REVERSE_JUSTICE .. "}} {{GoldenChest}} 황금 상자 1-2개를 생성합니다."
						.. "#{{Card" ..
						Card.CARD_REVERSE_HERMIT ..
						"}} 1-5개의 무작위의 {{Coin}} 동전을 생성합니다.",

						"#{{Card" .. Card.CARD_REVERSE_WHEEL_OF_FORTUNE .. "}} {{Collectible" .. CollectibleType.COLLECTIBLE_D8 .. "}} 8면, {{Collectible" .. CollectibleType.COLLECTIBLE_D10 .. "}} 10면, 또는 {{Collectible" .. CollectibleType.COLLECTIBLE_D12 .. "}} 12면 주사위의 효과 중 하나가 발동됩니다."
						.. "#{{Card" .. Card.CARD_REVERSE_STRENGTH .. "}} {{Timer}} 30초간 방 안의 적 중 절반이 {{Weakness}} 약화됩니다."
						.. "#{{Card" .. Card.CARD_REVERSE_HANGED_MAN .. "}} {{Timer}} 30초간 {{Collectible" .. CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER .. "}} 상점 주인의 머리통의 효과와 {{Damage}} X1.5 공격력 배수를 확득합니다."
						.. "#{{Card" .. Card.CARD_REVERSE_DEATH .. "}} {{Friendly}} 아군 해골 계열 몬스터 1마리를 생성합니다."
						.. "#{{Card" .. Card.CARD_REVERSE_TEMPERANCE .. "}} 무작위 {{Pill}} 알약 하나를 복용합니다."
						.. "#{{Card" .. Card.CARD_REVERSE_DEVIL .. "}} 이번 방 한정으로 비행 가능",

						"#{{Card" .. Card.CARD_REVERSE_TOWER .. "}} 돌덩이나 장애물이 뭉쳐진 덩어리를 하나 생성합니다."
						.. "#{{Card" .. Card.CARD_REVERSE_STARS .. "}} 가장 이른 시기에 획득했던 패시브 아이템을 파괴하고 방의 배열에 맞는 무작위 받침대 아이템을 1개 생성합니다. 시작 아이템은 제외됩니다."
						.. "#{{Card" .. Card.CARD_REVERSE_MOON .. "}} {{Card" .. Card.CARD_CRACKED_KEY .. "}} 부러진 열쇠를 하나 생성하고 {{UltraSecretRoom}} 특급 비밀 방의 위치를 공개합니다.",

						"#{{Card" ..
						Card.CARD_REVERSE_SUN ..
						"}} {{Timer}} 이번 방에서만 {{Collectible" .. CollectibleType.COLLECTIBLE_SPIRIT_OF_THE_NIGHT .. "}} 밤의 영혼, {{Damage}} +1.5 공격력을 얻고 방 전체를 어둡게 합니다."
						.. "#{{Card" .. Card.CARD_REVERSE_JUDGEMENT .. "}} {{Card" .. Card.CARD_DICE_SHARD .. "}} 주사위 조각의 효과가 발동됩니다."
						.. "#{{Card" .. Card.CARD_REVERSE_WORLD .. "}} {{Collectible" .. CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER .. "}} 다음 스테이지로 가는 다락문을 생성합니다. 장식용 타일에서 사용하면 크롤 스페이스 다락문이 대신 생성됩니다."
					}
				)
				end
			}
		},
	}
end
