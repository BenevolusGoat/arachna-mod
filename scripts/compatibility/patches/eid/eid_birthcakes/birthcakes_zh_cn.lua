local Mod = ArachnaMod

return function(modifiers)
	return {
        [Mod.PlayerType.ARACHNA] = {
            Name = "阿拉克娜的",
            PickupQuote = "大量寄生!",
            AccurateBlurb = "蛛卵和头目会生成蜘蛛",
            EIDDesc = {
				function(descObj)
					return modifiers[Mod.PlayerType.ARACHNA]._modifier(descObj,
					"蜘蛛卵每2秒会生成 %s "
					.. "#蛛网缠身的敌人每秒会生成 %s ",
					"1个友好蜘蛛", "1个友好蜘蛛", "%s 个友好蜘蛛", "%s 个友好蜘蛛")
				end
			}
        },
        [Mod.PlayerType.ARACHNA_B]={
            Title = "卑劣者的",
            Name = "堕化阿拉克娜的",
            PickupQuote = "网捕攻击性上升!",
            AccurateBlurb = "双击攻击更快并额外发射泪弹",
            EIDDesc = {
				function(descObj)
					return modifiers[Mod.PlayerType.ARACHNA_B]._modifier(descObj,
						"双击攻击 %s",
						"加快"
				)
				end,
				"# 双击攻击键会额外发射一圈泪弹, 有概率发射{{Collectible" .. CollectibleType.COLLECTIBLE_PARASITOID .. "}} 蛛卵",
				"#{{Luck}} 幸运5: 50%"
			}
        }
	}
end
