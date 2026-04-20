local Mod = ArachnaMod
local Item = Mod.Item

return function(modifiers)
	return {
		[Mod.PlayerType.ARACHNA] = {
			Name = "阿拉克娜",
			Description = {
				"{{Collectible" .. Item.ARACHNAS_SPOOL.ID .. "}} 同时可以存在两张网",
				"#↑ 提升蜘蛛卵生成{{ColorRainbow}}特殊{{CR}}友好蜘蛛的概率、",
				"#{{WebHeart}} 蜘蛛卵孵化后有5%的概率生成网心"
			}
		},
		[Mod.PlayerType.ARACHNA_B] = {
			Name = "堕化阿拉克娜",
			Description = {
				"{{StatusWebbed}} 投掷的蜘蛛卵会生成小型蛛网",
				"#同时可以存在三张网",
				"#根据蜘蛛卵的颜色, 蛛网也会具有{{ColorRainbow}}特殊{{CR}}效果",
				"#{{StatusWebbed}} 被蛛网缠身的敌人会被{{Slow}}减速, 受到更少的击退, 死亡后生成蜘蛛卵",
				"#!!! 这些新生成的蜘蛛卵不会拥有特殊颜色"
			}
		},
	}
end
