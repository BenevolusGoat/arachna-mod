local Mod = ARACHNAMOD
local ARC_EID = Mod.EID_Support
local Item = Mod.Item

return function(modifiers)
	return {
		[Item.SPIDER_CAKE.ID] = {
			Name = "거미 케이크",
			Description = {
				"{{WebHeart}} 거미줄 하트 하나를 생성합니다.",
				"#{{Collectible" .. CollectibleType.COLLECTIBLE_MYSTERY_GIFT .. "}} 비밀 선물 하나를 지급합니다.",
				function(descObj)
					local years = Item.SPIDER_CAKE:GetYearDifference()
					return string.format("#이 모드가 발매된 지 %s년이 지났어요!", years)
				end,
				function(descObj)
					local stats = modifiers[Item.SPIDER_CAKE.ID]._modifier(descObj)
					return "#↑ {{Speed}} +" .. stats.Speed .. " 이동 속도"
						.. "#↑ {{Tears}} +" .. stats.Tears .. " 연사력"
						.. "#↑ {{Damage}} +" .. stats.Damage .. " 공격력"
						.. "#↑ {{Range}} +" .. stats.Range .. " 사거리"
						.. "#↑ {{Shotspeed}} +" .. stats.ShotSpeed .. " 탄속"
						.. "#↑ {{Luck}} +" .. stats.Luck .. " 행운"
				end
			},
			FallbackDescription = {
				"{{WebHeart}} 거미줄 하트 하나를 생성합니다.",
				"#{{Collectible" .. CollectibleType.COLLECTIBLE_MYSTERY_GIFT .. "}} 비밀 선물 하나를 지급합니다.",
				"#↑ 이 모드가 발매된 후 지난 햇수에 비례해 모든 능력치를 증가시킵니다."
			}
		},
		[Item.SPIDER_DONUT.ID] = {
			Name = "거미 도넛", --언더테일에 나오는 그거가 안 나오면 어색하겠죠???
			Description = {
				"{{WebHeart}} 거미줄 하트 +1",
				"#↑ {{Damage}} 공격력 +0.69", --왜 하필 0.69인 것이지???
				"#{{AracBlueSpider}} 보라색 대왕 거미 2-3마리를 생성합니다."
			}
		},
		[Item.OLD_SHOEBOX.ID] = {
			Name = "낡은 신발 상자",
			Description = {
				"{{WebHeart}} 거미줄 하트 하나를 생성합니다.",
				"#↑ {{Speed}} +0.15 이동 속도",
				"#↑ {{Tears}} +0.33 연사력",
				"#{{AracBlueSpider}} 파란 아군 거미 7-14마리를 생성합니다."
			}
		},
		[Item.GUMMY_SPIDERS.ID] = {
			Name = "거미 구미 젤리",
			Description = {
				"{{WebHeart}} 거미줄 하트 2개",
				"#↑ {{Tears}} +0.61 연사력",
				"#{{AracBlueSpider}} {{ColorRainbow}}특수한{{CR}} 아군 거미 여러 마리를 생성합니다."
			}
		},
		[Item.CANDY_FLOSS.ID] = {
			Name = "솜사탕",
			Description = {
				"{{WebHeart}} 빨간 체력을 전부 소진하고 그 양만큼 거미줄 하트를 최소 3개 생성합니다.",
				"#{{Slow}} 5% 확률로 4방향 분열 둔화 눈물이 나갑니다.",
				"#({{Luck}} 행운이 20 이상일 때 100% 확률)"
			}
		},
		[Item.ARACHNAS_SPOOL.ID] = {
			Name = "아라크나의 실패",
			Description = {
				"{{Throwable}} 착탄 지점에 커다란 거미줄을 깔아놓는 실패 발사체를 하나 투척합니다.",
				"#{{StatusWebbed}} 거미줄에 걸린 적은 {{Slow}} 둔화되고 받는 넉백이 감소하며 사망 시 거미 알집을 생성합니다.",
				"#{{AracBlueSpider}} 거미 알집은 방 클리어 시 터지며 파란 아군 거미를 여러 마리 소환합니다.",
				"#{{BossRoom}} 거미줄에 걸려든 보스를 공격하면 게이지가 차오르며 완충 시 아군 파란 거미 여러 마리가 생성됩니다."
			},
			BookOfBelial = {
				"{{Burning}} 실패에 맞거나 거미줄에 걸린 적이 화상을 입습니다."
			}
		},
		[Item.DIVINE_CLOTH.ID] = {
			Name = "신성한 천",
			Description = {
				"{{StatusSpiderBite}} 범위 내의 적들을 옭아매 공격력 값의 절반의 피해를 줍니다.",
				"#{{StatusWebbed}} 옭아매인 적은 {{Slow}} 둔화되고 받는 넉백이 감소하며 사망 시 거미 알집을 생성합니다.",
				"#{{AracBlueSpider}} 거미 알집은 방 클리어 시 터지며 파란 아군 거미를 여러 마리 소환합니다.",
				"#{{BossRoom}} 거미줄에 걸려든 보스를 공격하면 게이지가 차오르며 완충 시 거미 알집이 생성됩니다.",
				"#{{StatusSpiderBite}} 생성된 알집은 {{ColorRainbow}}특수 거미{{CR}}를 생성하는 특수 알집이 될 수 있습니다.",
			},
			BookOfBelial = {
				"{{Burning}} 인접한 적들이 화상을 입습니다."
			}
		},
		[Item.EGG_TOSS.ID] = {
			Name = "알집 투척",
			Description = {
				"{{Throwable}} 거미 알집을 붙잡아 던질 수 있습니다.",
				"#{{AracBlueSpider}} 착탄 시 정상적으로 거미가 부화하며 {{ColorRainbow}}특수 알집{{CR}}의 경우 충돌 시 탑재된 효과도 같이 발동됩니다.",
				"#↑ 적을 알집으로 맞추면 거미의 수가 늘어나고 크기가 커질 수 있습니다.",
			}
		},
		[Item.YARN.ID] = {
			Name = "털실",
			Description = {
				"발사체를 막아줍니다.",
				"#인접한 적을 감전시킵니다.",
				"#{{WebHeart}} 방 4개를 클리어할 때마다 거미줄 하트 하나를 생성합니다."
			}
		},
		[Item.ARACHNIDS_GRIP.ID] = {
			Name = "거미의 손아귀", --홈스턱이었노
			Description = {
				ARC_EID.GetFallbackDescription,
				function(descObj)
					return modifiers[Item.ARACHNIDS_GRIP.ID]._modifier(descObj,
						"#{{Collectible" ..
						Item.MUTAGEN.ID .. "}} 아군 거미가 {{ColorRainbow}}특수{{CR}} 거미가 되거나 덩치가 커질 수 있습니다."
					)
				end
			},
			FallbackDescription = {
				"#{{Poison}} 25% 확률로 독성 눈물이 나갑니다.",
				"#적이 사망하면 획득 시 파괴 가능 오비탈을 하나 생성하는 거미 알집 픽업을 드롭합니다.",
				"#오비탈은 피해를 입히거나 탄환을 막을 때 {{AracBlueSpider}} 파란 거미 하나를 생성하고 파괴될 수 있습니다.",
			}
		},
		[Item.YARN_HEART.ID] = {
			Name = "털실 심장",
			Description = {
				"{{WebHeart}} 거미줄 하트 +1개"
			}
		},
		[Item.MECHANICAL_EYE.ID] = {
			Name = "기계 눈", --테라리아 ㅋㅋ
			Description = {
				"오비탈",
				"#발사체를 막아줍니다.",
				"#소지 중인 액티브 아이템과 충전량이 같은 무작위 아이템을 표시합니다.",
				"#액티브 아이템을 사용하면 해당 아이템도 같이 발동합니다.",
				"#새로운 방에 진입하거나 액티브 아이템을 사용하면 표시된 아이템도 새로고침됩니다."
			},
			BFFS = {
				"{{Collectible" ..
				CollectibleType.COLLECTIBLE_CAR_BATTERY .. "}} 자동차 배터리와 동일하게 표시된 아이템이 두 번 발동됩니다."
			}
		},
		[Item.GEPTAMERON.ID] = {
			Name = "헵타메론",
			Description = {
				"사용할 때마다 하술된 효과가 기재된 순서대로 발동됩니다:",
				"#{{1}} 지도에 {{SecretRoom}}{{SuperSecretRoom}} 비밀 방과 일급 비밀 방의 위치가 표시되고 {{Collectible" ..
				CollectibleType.COLLECTIBLE_DADS_KEY .. "}} 방 안의 모든 잠긴 문이 강제 개방됩니다.",
				"#{{2}} 임시 아군 '데드 아이작' 몬스터를 몇 마리 소환합니다. 이렇게 생성된 몬스터는 사망 시 {{RottenHeart}} 썩은 하트를 하나 드랍할 수 있습니다.",
				"#{{3}} 방 안의 모든 적이 {{Charm}} 매혹되거나 사망 시 {{Trinket" ..
				TrinketType.TRINKET_LOCUST_OF_WRATH .. "}} 전쟁의 메뚜기 3마리를 생성합니다.",
				"#{{4}} {{Timer}} 이번 방에서만 {{Collectible" ..
				CollectibleType.COLLECTIBLE_GUARDIAN_ANGEL .. "}} 수호천사와 {{HolyMantleSmall}} 성스러운 망토 방어막 하나를 얻습니다.",
				"#{{5}} 모든 적이 사망 시 {{Coin}} 소멸성 동전을 생성합니다.",
				"#{{6}} 10초간 무작위 위치를 미사일로 공격합니다.",
				"#{{7}} 1-3 마리의 적이 \"자루\"로 취급되며, 사망 시 소멸성 무작위 픽업을 드랍하고 다른 적에게 자루 취급 상태를 넘깁니다."
			}
		},
		[Item.GLASSES_3D.ID] = {
			Name = "3D 안경",
			Description = {
				"5% 확률로 착탄 시 맞춘 적을 아군 복제본 2마리로 분열시키는 \"3D\" 발사체가 나갑니다.",
				"#{{Luck}} 행운 20일 때 25% 확률로 발동됩니다.",
				"#복사본 적은 무적이지만 방을 클리어하면 없어져버립니다.",
			}
		},
		[Item.MUTAGEN.ID] = {
			Name = "돌연변이원",
			Description = {
				"↑ {{Damage}} +1 공격력",
				"#{{AracBlueSpider}} 20% 확률로 새로운 방에 진입 시 3-5마리의 {{ColorRainbow}}특수{{CR}} 아군 거미가 생성됩니다.",
				"#{{AracBlueSpider}} 거미 알집 이외의 방법으로 생성된 아군 거미가 일정 확률로 {{ColorRainbow}}특수 거미{{CR}}가 됩니다."
			}
		},
		[Item.TESTAMENT.ID] = {
			Name = "언약",
			Description = {
				"사용 시 소지한 모든 아이템이 담긴 층으로 순간이동합니다.",
				"#아이템을 고르면 사용하기 전에 있던 방으로 돌아갑니다.",
				"#이렇게 선택된 아이템은 이번 판에서 없어지고 다음 판에서 즉시 생성됩니다.",
				"#유효한 아이템이 없을 경우 {{Collectible" ..
				CollectibleType.COLLECTIBLE_EDENS_BLESSING .. "}} 에덴의 축복이 대신 지급됩니다."
			}
		},
		[Item.LIL_ARACHNA.ID] = {
			Name = "꼬마 아라크나",
			Description = {
				"{{Slow}} 둔화 4분열 눈물을 발사합니다.",
				"#탄환 하나당 3.5의 피해를 줍니다.",
				"#{{AracBlueSpider}} 25% 확률로 맞은 적을 {{StatusWebbed}} 거미줄에 걸리게 합니다.",
				"#{{StatusWebbed}} 옭아매인 적은 {{Slow}} 둔화되고 받는 넉백이 감소하며 사망 시 거미 알집을 생성합니다.",
				"#{{AracBlueSpider}} 거미 알집은 방 클리어 시 터지며 파란 아군 거미를 여러 마리 소환합니다.",
			},
		},
		[Item.DADS_NEWSPAPER.ID] = {
			Name = "아빠의 신문지",
			Description = {
				"신문지를 장착합니다.",
				"#공격 키를 두 번 연타해 신문지를 휘두를 수 있습니다.",
				"#{{Confusion}} 신문지에 맞은 적은 중간 정도의 피해를 입고 혼란에 빠집니다.",
				"#거미 및 파리 계열 몬스터는 신문지에 맞으면 즉사합니다."
			}
		},
		[Item.BEST_BUD_BALL.ID] = {
			Name = "절친 공",
			Description = {
				"{{Throwable}} 보스에게 투척해 포획을 시도할 수 있습니다.",
				"#{{LuckSmall}} 포획률은 보스의 체력과 사용자의 행운 능력치에 비례합니다.",
				"#{{Friendly}} 보스를 성공적으로 포획한 상태에서 사용하면 포획한 보스가 아군이 되어 소환됩니다.",
				"#보스를 포획하고 볼을 주우면 즉시 충전되어 재사용 가능해집니다.",
				"#!!! 아군 보스는 1마리까지만 데리고 다닐 수 있습니다."
			}
		},
	}
end
