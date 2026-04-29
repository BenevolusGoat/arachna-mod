local Mod = ArachnaMod
local ARC_EID = Mod.EID_Support
local Item = Mod.Item

return function(modifiers)
	return {
		[Item.SPIDER_CAKE.ID] = {
			Name = "蜘蛛蛋糕",
			Description = {
				"{{WebHeart}} 生成1个网心",
				"#获得 {{Collectible" .. CollectibleType.COLLECTIBLE_MYSTERY_GIFT .. "}} 神秘礼物",
				function(descObj)
					local years = Item.SPIDER_CAKE:GetYearDifference()
					return string.format("#模组已发布 %s 年", years)
				end,
				function(descObj)
					local stats = modifiers[Item.SPIDER_CAKE.ID]._modifier(descObj)
					return "#↑ {{Speed}} +" .. stats.Speed .. " 移速"
						.. "#↑ {{Tears}} +" .. stats.Tears .. " 射速"
						.. "#↑ {{Damage}} +" .. stats.Damage .. " 伤害"
						.. "#↑ {{Range}} +" .. stats.Range .. " 射程"
						.. "#↑ {{Shotspeed}} +" .. stats.ShotSpeed .. " 弹速"
						.. "#↑ {{Luck}} +" .. stats.Luck .. " 幸运"
				end
			},
			FallbackDescription = {
				"{{WebHeart}} 生成1个网心",
				"#获得 {{Collectible" .. CollectibleType.COLLECTIBLE_MYSTERY_GIFT .. "}} 神秘礼物",
				"#↑ 基于距离模组发布经过的年数提供全属性上升"
			}
		},
		[Item.SPIDER_DONUT.ID] = {
			Name = "蜘蛛甜甜圈",
			Description = {
				"{{WebHeart}} 获得1网心",
				"#↑ {{Damage}} +0.69 伤害",
				"#{{AracBlueSpider}} 生成2-3个大型紫蜘蛛"
			}
		},
		[Item.OLD_SHOEBOX.ID] = {
			Name = "老旧鞋盒",
			Description = {
				"{{WebHeart}} 生成1个网心",
				"#↑ {{Speed}} +0.15 移速",
				"#↑ {{Tears}} +0.33 射速",
				"#{{AracBlueSpider}} 生成7-14个蓝蜘蛛"
			}
		},
		[Item.GUMMY_SPIDERS.ID] = {
			Name = "蜘蛛软糖",
			Description = {
				"{{WebHeart}} 获得2网心",
				"#↑ {{Tears}} +0.61 射速",
				"#{{AracBlueSpider}} 生成数个{{ColorRainbow}}特殊{{CR}}友好蜘蛛"
			}
		},
		[Item.CANDY_FLOSS.ID] = {
			Name = "绞丝糖",
			Description = {
				"{{WebHeart}} 排空角色的红心, 并生成网心, 至少生成3个",
				"#{{Slow}} 5%概率发射命中后一分为四的减速泪弹",
				"#{{Luck}} 幸运20: 100%"
			}
		},
		[Item.ARACHNAS_SPOOL.ID] = {
			Name = "阿拉克娜的线轴",
			Description = {
				"{{Throwable}} 投掷一个线轴弹, 留下大片蛛网",
				"#{{StatusWebbed}} 被蛛网缠身的敌人会被{{Slow}}减速, 受到更少的击退, 死亡后生成一个蜘蛛卵",
				"#{{AracBlueSpider}} 蜘蛛卵会在清理房间后孵化, 生成数个蓝蜘蛛",
				"#{{BossRoom}} 伤害蛛网缠身的头目会积攒一个充能条, 蓄满后生成数个蓝蜘蛛"
			},
			BookOfBelial = {
				"线轴弹和蛛网会对敌人施加{{Burning}}灼烧"
			}
		},
		[Item.DIVINE_CLOTH.ID] = {
			Name = "神圣织网",
			Description = {
				"{{StatusSpiderBite}} 网捕附近的敌人, 对其造成50%角色伤害. 敌人将被{{Slow}}减速, 受到更少的击退, 死亡后生成蜘蛛卵",
				"#{{AracBlueSpider}} 蜘蛛卵会在清理房间后孵化, 生成数个友好蜘蛛",
				"#{{StatusSpiderBite}} 蜘蛛卵可以变为{{ColorRainbow}}特殊蛛卵{{CR}}, 并孵化对应颜色的特殊蜘蛛",
				"#{{BossRoom}} 伤害被网捕的头目会积攒一个充能条, 蓄满后生成蜘蛛卵"
			},
			BookOfBelial = {
				"对附近的敌人施加{{Burning}}灼烧"
			}
		},
		[Item.EGG_TOSS.ID] = {
			Name = "投卵",
			Description = {
				"{{Throwable}} 抓取并投掷蜘蛛卵",
				"#{{AracBlueSpider}} 其会正常孵出蜘蛛, 在蜘蛛卵命中某些东西后还会触发{{ColorRainbow}}特殊{{CR}}的颜色效果",
				"#↑ 蜘蛛卵命中敌人可生成更多更大的蜘蛛",
			}
		},
		[Item.YARN.ID] = {
			Name = "纱线",
			Description = {
				"阻挡敌弹",
				"#电击附近的敌人",
				"#{{WebHeart}} 每4个房间生成1网心"
			}
		},
		[Item.ARACHNIDS_GRIP.ID] = {
			Name = "阿拉克娜之握",
			Description = {
				"{{Poison}} 25%概率发射毒性泪弹",
				"#敌人死亡后可能掉落蜘蛛卵, 拾取后获得一个脆弱的环绕物",
				"#该环绕物会在抵挡敌弹或造成伤害后破裂, 生成一个{{AracBlueSpider}} 蓝蜘蛛",
			}
		},
		[Item.YARN_HEART.ID] = {
			Name = "纺织的心",
			Description = {
				"{{WebHeart}} 获得1网心"
			}
		},
		[Item.MECHANICAL_EYE.ID] = {
			Name = "机器眼",
			Description = {
				"环绕物",
				"#阻挡敌弹",
				"#展示一个随机的主动道具, 其拥有与角色当前持有的主动道具相同的最大充能",
				"#使用主动道具时同时触发展示的道具",
				"#使用主动道具/进入未探索的房间后, 改变展示的道具"
			},
			BFFS = {
				"展示的道具会触发两次, 类似{{Collectible" ..
				CollectibleType.COLLECTIBLE_CAR_BATTERY .. "}} 车载电池"
			}
		},
		[Item.GEPTAMERON.ID] = {
			Name = "七室谈",
			Description = {
				"基于计数器触发效果:",
				"#{{1}} 揭示{{SecretRoom}}{{SuperSecretRoom}} 并使用{{Collectible" ..
				CollectibleType.COLLECTIBLE_DADS_KEY .. "}}",
				"#{{2}} 生成临时的友好僵尸以撒. 它们可能会在死亡后留下1{{RottenHeart}}",
				"#{{3}} 所有敌人被{{Charm}} 魅惑或会在死亡后生成3个{{Trinket" ..
				TrinketType.TRINKET_LOCUST_OF_WRATH .. "}} 蝗虫",
				"#{{4}} {{Timer}} 在当前房间内: 获得2个{{Collectible" ..
				CollectibleType.COLLECTIBLE_GUARDIAN_ANGEL .. "}} 和一层{{HolyMantleSmall}}神圣屏障",
				"#{{5}} 所有敌人死亡后会掉落{{Coin}}快速消失的硬币",
				"#{{6}} 10秒内在随机位置发射导弹",
				"#{{7}} 1-3个敌人会在死亡后掉落快速消失的随机掉落物, 并将该状态转移至另一个敌人"
			}
		},
		[Item.GLASSES_3D.ID] = {
			Name = "3D眼镜",
			Description = {
				"5%概率发射\"3D\"泪弹, 将命中的敌人分裂为两个友好的版本",
				"#{{Luck}} 幸运20: 25%",
				"#这些友好的敌人不会受到伤害, 在清理房间后消失",
			}
		},
		[Item.MUTAGEN.ID] = {
			Name = "诱变剂",
			Description = {
				"↑ {{Damage}} +1伤害",
				"#{{AracBlueSpider}} 进入新房间后, 20%概率生成3-5个{{ColorRainbow}}特殊{{CR}}友好蜘蛛",
				"#{{AracBlueSpider}} 任何不由蜘蛛卵生成的蜘蛛有概率变为{{ColorRainbow}}特殊蜘蛛{{CR}}"
			}
		},
		[Item.TESTAMENT.ID] = {
			Name = "圣约",
			Description = {
				"将角色传送至一个包含其拥有的所有道具的楼层",
				"#从中选择一个道具后将角色送回原本的房间",
				"#选定的道具会被移出角色的物品栏, 并出现在下一局开始",
				"#未拥有道具时则改为生成{{Collectible" ..
				CollectibleType.COLLECTIBLE_EDENS_BLESSING .. "}} 伊甸的灵魂"
			}
		},
		[Item.LIL_ARACHNA.ID] = {
			Name = "阿拉克娜宝宝",
			Description = {
				"{{Slow}} 发射命中后一分为四的减速泪弹",
				"#每发泪弹伤害为3.5",
				"#{{AracBlueSpider}} 其泪弹有概率对敌人施加蛛网缠身",
				"#{{StatusWebbed}} 被蛛网缠身的敌人会被{{Slow}}减速, 受到更少的击退, 死亡后生成一个蜘蛛卵",
				"#{{AracBlueSpider}} 蜘蛛卵会在清理房间后孵化, 生成数个蓝蜘蛛"
			},
		},
		[Item.DADS_NEWSPAPER.ID] = {
			Name = "爸爸的报纸",
			Description = {
				"角色举起报纸",
				"#双击攻击键挥舞",
				"#{{Confusion}} 造成中等伤害, 并施加混乱",
				"#可以秒杀苍蝇和蜘蛛类敌人"
			}
		},
		[Item.BEST_BUD_BALL.ID] = {
			Name = "至交球",
			Description = {
				"{{Throwable}} 可以投向头目并尝试捕捉它们",
				"#{{LuckSmall}} 捕捉的概率取决于其HP和角色的幸运",
				"#{{Friendly}} 在成功捕捉一个头目后使用可以生成友好的头目协同作战",
				"#成功捕捉后移动至至交球以立即恢复充能",
				"#!!! 一次只能召唤一个头目"
			}
		},
		[Item.ARACHNOLOGY_101.ID] = {
			Name = "蛛学网101",
			Description = {
				"获得下述之一:",
				"#一个蜘蛛相关的小知识",
				"#{{WebHeart}} 1个网心",
				"#{{AracBlueSpider}} 数个蓝蜘蛛"
			}
		}
	}
end
