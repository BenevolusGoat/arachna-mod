local Mod = ARACHNAMOD

return function(modifiers)
	return {
		[Mod.Card.SOUL_OF_ARACHNA.ID] = {
			Name = "阿拉克娜的魂石",
			Description = {
				"{{StatusWebbed}} 对所有敌人施加蛛网缠身, 持续10秒",
				"#{{StatusWebbed}} 被蛛网缠身的敌人会被{{Slow}}减速, 受到更少的击退, 死亡后生成一个蜘蛛卵",
				"#{{AracBlueSpider}} 蜘蛛卵会在清理房间后孵化, 生成数个蓝蜘蛛"
			}
		},
		[Mod.Card.MERGED_CARD.ID] = {
			Name = "融合卡",
			Description = {
				function(descObj)
					return modifiers[Mod.Card.MERGED_CARD.ID]._modifier(descObj,
					"触发2个随机的基于塔罗牌的效果"
					.. "#(长按{{ButtonSelect}}查看效果)",
					"{{Blank}} {{ButtonX}} 效果一览 %s/%s {{ButtonB}}",
					{
						"#{{Card" .. Card.CARD_FOOL .. "}} 使用{{Collectible" .. CollectibleType.COLLECTIBLE_D7 .. "}} 七面骰"
						.. "#{{Card" .. Card.CARD_MAGICIAN .. "}} {{Slow}} 减速房间内的所有敌人"
						.. "#{{Card" .. Card.CARD_HIGH_PRIESTESS .. "}} {{MomBossSmall}} 妈妈的腿践踏角色"
						.. "#{{Card" ..
						Card.CARD_EMPRESS .. "}} 使用{{Collectible" .. CollectibleType.COLLECTIBLE_THE_NAIL .. "}} 钉子"
						.. "#{{Card" .. Card.CARD_EMPEROR .. "}} 揭示{{BossRoom}} 头目房"
						.. "#{{Card" .. Card.CARD_HIEROPHANT .. "}} 生成2个{{HalfSoulHeart}} 半魂心",

						"#{{Card" .. Card.CARD_LOVERS .. "}} 生成2个{{HalfHeart}} 半红心"
						.. "#{{Card" ..
						Card.CARD_CHARIOT .. "}} 使用{{Collectible" .. CollectibleType.COLLECTIBLE_UNICORN_STUMP ..
						"}} 独角兽的残角"
						.. "#{{Card" .. Card.CARD_JUSTICE .. "}} 生成下列掉落物中的两种: {{Coin}} 硬币, {{Key}} 钥匙, {{Bomb}} 炸弹或{{Heart}} 心"
						.. "#{{Card" ..
						Card.CARD_HERMIT .. "}} 使用{{Collectible" .. CollectibleType.COLLECTIBLE_KEEPERS_BOX .. "}} 店主的盒子"
						.. "#{{Card" .. Card.CARD_WHEEL_OF_FORTUNE .. "}} 使用5次{{Collectible" .. CollectibleType.COLLECTIBLE_PORTABLE_SLOT .. "}} 便携式老虎机",

						"#{{Card" .. Card.CARD_STRENGTH .. "}} {{Timer}} 在当前房间内获得: {{Collectible" .. CollectibleType.COLLECTIBLE_ODD_MUSHROOM_LARGE .. "}} 怪异蘑菇"
						.. "#{{Card" .. Card.CARD_HANGED_MAN .. "}} 摧毁房间内的所有石头, 填补所有沟壑"
						.. "#{{Card" .. Card.CARD_DEATH .. "}} 对房间内的所有敌人造成20伤害"
						.. "#{{Card" .. Card.CARD_TEMPERANCE .. "}} 生成一个{{DemonBeggar}}恶魔乞丐"
						.. "#{{Card" .. Card.CARD_DEVIL .. "}} {{Timer}} 在当前房间内获得: {{Damage}} +1伤害"
						.. "#{{Card" .. Card.CARD_TOWER .. "}} 生成3个即爆炸弹",

						"#{{Card" .. Card.CARD_STARS .. "}} 生成一个{{GoldenChest}} 金箱子"
						.. "#{{Card" .. Card.CARD_MOON .. "}} 揭示所有{{SecretRoom}}{{SuperSecretRoom}}{{UltraSecretRoom}} 隐藏房"
						.. "#{{Card" ..
						Card.CARD_SUN ..
						"}} 揭示{{TreasureRoom}} 宝箱房和{{Planetarium}} 星象房, {{HealingRed}} 治疗1红心, 对房间内的所有敌人造成5伤害"
						.. "#{{Card" .. Card.CARD_JUDGEMENT .. "}} 生成一个店主"
						.. "#{{Card" .. Card.CARD_WORLD .. "}} 揭示{{TreasureRoom}} 宝箱房和{{Planetarium}} 星象房"
					}
				)
				end
			}
		},
		[Mod.Card.MERGED_CARD_REVERSED.ID] = {
			Name = "融合卡?",
			Description = {
				function(descObj)
					return modifiers[Mod.Card.MERGED_CARD.ID]._modifier(descObj,
					"触发2个随机的基于逆位塔罗牌的效果"
					.. "#(长按{{ButtonSelect}}查看效果)",
					"{{Blank}} {{ButtonX}} 效果一览 %s/%s {{ButtonB}}",
					{
						"#{{Card" .. Card.CARD_REVERSE_FOOL .. "}} 将角色的所有{{Coin}} 硬币, {{Bomb}} 炸弹或{{Key}} 钥匙丢在地上"
						.. "#{{Card" .. Card.CARD_REVERSE_MAGICIAN .. "}} 连续触发两次{{Collectible" .. CollectibleType.COLLECTIBLE_TELEKINESIS .. "}} 念力"
						.. "#{{Card" .. Card.CARD_REVERSE_HIGH_PRIESTESS .. "}} {{Timer}} {{MomBossSmall}} 妈妈的腿会尝试在15秒内践踏角色"
						.. "#{{Card" ..
						Card.CARD_REVERSE_EMPRESS .. "}} {{Timer}} 在当前房间内: +1 {{Heart}} 心之容器, {{Tears}} +0.75射速, {{Speed}} -0.05移速",

						"#{{Card" .. Card.CARD_REVERSE_EMPEROR .. "}} 生成一个来自本层的{{ColorRainbow}}彩色{{CR}}变种的随机敌人"
						.. "#{{Card" .. Card.CARD_REVERSE_HIEROPHANT .. "}} 生成1个{{EmptyBoneHeart}} 骨心"
						.. "#{{Card" .. Card.CARD_REVERSE_LOVERS .. "}} {{BrokenHeart}} 获得1碎心, {{Damage}} +0.25伤害"
						.. "#{{Card" ..
						Card.CARD_REVERSE_CHARIOT .. "}} {{Timer}} 在10秒内: {{Speed}} x0.5移速倍率, {{Tears}} x2 射速倍率"
						.. "#{{Card" .. Card.CARD_REVERSE_JUSTICE .. "}} 生成1-2个{{GoldenChest}} 金箱子"
						.. "#{{Card" ..
						Card.CARD_REVERSE_HERMIT ..
						"}} 生成1-5个随机{{Coin}} 硬币",

						"#{{Card" .. Card.CARD_REVERSE_WHEEL_OF_FORTUNE .. "}} 触发{{Collectible" .. CollectibleType.COLLECTIBLE_D8 .. "}} 八面骰, {{Collectible" .. CollectibleType.COLLECTIBLE_D10 .. "}} 十面骰或 {{Collectible" .. CollectibleType.COLLECTIBLE_D12 .. "}} 十二面骰"
						.. "#{{Card" .. Card.CARD_REVERSE_STRENGTH .. "}} {{Timer}} 在30秒内: 半数的敌人被施加{{Weakness}}虚弱"
						.. "#{{Card" .. Card.CARD_REVERSE_HANGED_MAN .. "}} {{Timer}} 在30秒内获得: {{Collectible" .. CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER .. "}} 店主的头, {{Damage}} x1.5伤害倍率"
						.. "#{{Card" .. Card.CARD_REVERSE_DEATH .. "}} {{Friendly}} 生成一个随机的骷髅类敌人"
						.. "#{{Card" .. Card.CARD_REVERSE_TEMPERANCE .. "}} 触发一个随机的{{Pill}} 药丸"
						.. "#{{Card" .. Card.CARD_REVERSE_DEVIL .. "}} 在当前房间内获得飞行",

						"#{{Card" .. Card.CARD_REVERSE_TOWER .. "}} 生成一组随机石头和障碍物"
						.. "#{{Card" .. Card.CARD_REVERSE_STARS .. "}} 失去角色最早持有的一个道具(初始道具不算入)并生成当前房间道具池的一个随机道具"
						.. "#{{Card" .. Card.CARD_REVERSE_MOON .. "}} 生成{{Card" .. Card.CARD_CRACKED_KEY .. "}} 红钥匙碎片, 揭示{{UltraSecretRoom}} 究极隐藏房",

						"#{{Card" ..
						Card.CARD_REVERSE_SUN ..
						"}} {{Timer}} 在当前房间内获得: {{Collectible" .. CollectibleType.COLLECTIBLE_SPIRIT_OF_THE_NIGHT .. "}} 子夜幽魂, {{Damage}} +1.5伤害, 房间变暗"
						.. "#{{Card" .. Card.CARD_REVERSE_JUDGEMENT .. "}} 触发{{Collectible" .. CollectibleType.COLLECTIBLE_D6 .. "}} 六面骰和{{Collectible" .. CollectibleType.COLLECTIBLE_D20 .. "}} 20面骰"
						.. "#{{Card" .. Card.CARD_REVERSE_WORLD .. "}} 触发{{Collectible" .. CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER .. "}} 我们需要深入挖掘!"
					}
				)
				end
			}
		},
	}
end
