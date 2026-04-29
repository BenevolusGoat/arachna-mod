local Mod = ArachnaMod

return function()
	return {
		[Mod.PlayerType.ARACHNA] = {
			Name = "阿拉克娜",
			Description = {
				"无法拾取红心",
				"#{{WebHeart}} 生命上升的效果会提供{{ColorObjName}}网心{{CR}}, 网心会被视作她的心之容器",
				"#免疫蛛网",
				"#{{Poison}} 25%概率发射毒性泪弹",
				"#蜘蛛卵生成的蜘蛛可能会变为效果各异的{{ColorRainbow}}特殊蜘蛛{{CR}}",
			}
		},
		[Mod.PlayerType.ARACHNA_B] = {
			Name = "堕化阿拉克娜",
			Description = {
				"无法拾取红心",
				"#{{WebHeart}} 生命上升的效果会提供{{ColorObjName}}网心{{CR}}, 网心会被视作她的心之容器",
				"#免疫蛛网",
				"#{{Poison}} 25%概率发射毒性泪弹",
				"#{{Collectible" .. Mod.Item.DIVINE_CLOTH.ID .. "}} 双击攻击键{{StatusSpiderBite}}网捕一定范围内的敌人并造成50%伤害",
				"#{{StatusSpiderBite}} 网捕状态与{{StatusWebbed}}蛛网缠身状态类似",
				"#↓ 更小的蜘蛛卵",
				"#{{StatusSpiderBite}} 蜘蛛卵可以变为生成特殊蜘蛛的{{ColorRainbow}}特殊蛛卵{{CR}}",
			}
		},
	}
end
