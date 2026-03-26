local Mod = ARACHNAMOD
local Trinket = Mod.Trinket

return function(modifiers)
	return {
		[Trinket.INFESTED_PENNY.ID] = {
			Name = "寄生硬币",
			Description = {
				"{{AracBlueSpider}} 拾取硬币后生成蓝蜘蛛",
				"#{{WebHeart}} 同时有20%概率生成网心",
				"#面值更高的硬币概率也会更高"
			},
		},
		[Trinket.SPINDLE.ID] = {
			Name = "纺锤",
			Description = {
				"{{StatusWebbed}} 对接触的敌人施加蛛网缠身5秒",
				"#{{StatusWebbed}} 被蛛网缠身的敌人会被{{Slow}}减速, 受到更少的击退, 死亡后生成一个蜘蛛卵",
				"#{{AracBlueSpider}} 蜘蛛卵会在清理房间后孵化, 生成数个蓝蜘蛛",
				"#{{WebHeart}} 网心的生成概率10%",
				function(descObj)
					return modifiers[Trinket.SPINDLE.ID]._modifier(descObj,
						"#{{Collectible" .. CollectibleType.COLLECTIBLE_MIDAS_TOUCH .. "}}蜘蛛卵也会{{ColorGold}}变为金色{{CR}}并孵化金蜘蛛"
					)
				end
			}
		},
		[Trinket.WHITE_STRING.ID] = {
			Name = "白丝线",
			Description = {
				"{{WebHeart}} 进入新楼层后获得1网心"
			}
		},
	}
end
