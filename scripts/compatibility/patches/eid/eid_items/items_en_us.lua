local Mod = ARACHNAMOD
local ARC_EID = Mod.EID_Support
local Item = Mod.Item

return function(modifiers)
	return {
		[Item.SPIDER_CAKE.ID] = {
			Name = "Arachna's Spool",
			Description = {
				"{{WebHeart}} Spawns 1 Web Heart",
				"#Grants {{Collectible" .. CollectibleType.COLLECTIBLE_MYSTERY_GIFT .. "}} Mystery Gift",
				function(descObj)
					local years = Item.SPIDER_CAKE:GetYearDifference()
					return string.format("#%s years since mod release!", years)
				end,
				function(descObj)
					local stats = modifiers[Item.SPIDER_CAKE.ID]._modifier(descObj)
					return "#↑ {{Speed}} +" .. stats.Speed .. " Speed"
						.. "#↑ {{Tears}} +" .. stats.Tears .. " Tears"
						.. "#↑ {{Damage}} +" .. stats.Damage .. " Damage"
						.. "#↑ {{Range}} +" .. stats.Range .. " Range"
						.. "#↑ {{Shotspeed}} +" .. stats.ShotSpeed .. " Shot speed"
						.. "#↑ {{Luck}} +" .. stats.Luck .. " Luck"
				end
			},
			FallbackDescription = {
				"{{WebHeart}} Spawns 1 Web Heart",
				"#Grants {{Collectible" .. CollectibleType.COLLECTIBLE_MYSTERY_GIFT .. "}}",
				"#↑ All stats up, based on how many years passed since mod release"
			}
		},
		[Item.SPIDER_DONUT.ID] = {
			Name = "Spider Donut",
			Description = {
				"{{WebHeart}} +1 Web Heart",
				"#↑ {{Damage}} +0.69 Damage",
				"#{{AracBlueSpider}} Grants 2-3 big blue spiders"
			}
		},
		[Item.OLD_SHOEBOX.ID] = {
			Name = "Old Shoebox",
			Description = {
				"{{WebHeart}} Spawns 1 Web Heart",
				"#↑ {{Speed}} +0.15 Speed",
				"#↑ {{Tears}} +0.33 Tears",
				"#{{AracBlueSpider}} Grants 7-14 blue spiders"
			}
		},
		[Item.GUMMY_SPIDERS.ID] = {
			Name = "Gummy Spiders",
			Description = {
				"{{WebHeart}} +2 Web Hearts",
				"#↑ {{Tears}} +0.61 Tears",
				"#{{AracBlueSpider}} Grants several {{ColorRainbow}}special{{CR}} friendly spiders"
			}
		},
		[Item.CANDY_FLOSS.ID] = {
			Name = "Candy Floss",
			Description = {
				"{{WebHeart}} Drains all of Isaac's red health in exchange for spawning Web Hearts, spawning 3 at minimum",
				"#{{Slow}} 5% chance to shoot slowing and quad-splitting tears",
				"#{{Luck}} 100% chance at 20 luck"
			}
		}
	}
end
