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
				"{{StatusSpiderBite}} 网捕接触的敌人, 使其死亡后生成蜘蛛卵",
				"#蜘蛛卵会在清理房间后生成{{ColorRainbow}}特殊{{CR}}友好蜘蛛",
				"#{{WebHeart}} 网心的生成概率+10%"
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
