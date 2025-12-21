local Mod = ARACHNAMOD
local ARC_EID = Mod.EID_Support
local Item = Mod.Item

return function(modifiers)
	return {
		[Item.SPIDER_CAKE.ID] = {
			Name = "Spider Cake",
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
				"#{{AracBlueSpider}} Grants 2-3 big purple spiders"
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
		},
		[Item.ARACHNAS_SPOOL.ID] = {
			Name = "Arachna's Spool",
			Description = {
				"{{Throwable}} Throws a spool projectile that leaves a large spider web",
				"#{{StatusWebbed}} Enemies on the web are {{Slow}} slowed, receive less knockback, and drop a spider egg on death",
				"#{{AracBlueSpider}} Spider Eggs break on room clear, spawning several friendly spiders",
				"#{{BossRoom}} Damaging Webbed bosses charges a meter. When filled, spawns several friendly spiders"
			},
			BookOfBelial = {
				"Spool projectile and spider web inflict {{Burning}} Burn on enemies"
			}
		},
		[Item.DIVINE_CLOTH.ID] = {
			Name = "Divine Cloth",
			Description = {
				"{{StatusSpiderBite}} Inflicts Spider Bite, {{StatusWebbed}} Webbed, and deals 0.5x Isaac's damage to surrounding enemies. Enemies are {{Slow}} slowed, receive less knockback, and drop a colored spider egg on death",
				"#{{AracBlueSpider}} Spider Eggs break on room clear, spawning several friendly spiders",
				"#{{BossRoom}} Damaging Spider Bitten bosses charges a meter. When filled, spawns a spider egg"
			},
			BookOfBelial = {
				"Inflicts {{Burning}} Burn on nearby enemies"
			}
		},
		[Item.GRAB.ID] = {
			Name = "Grab (placeholder!)",
			Description = {
				"{{Throwable}} Grab and throw spider eggs",
				"#{{AracBlueSpider}} Hatches spiders as normal and triggers {{ColorRainbow}}special{{CR}} color-specific effects when the egg hits an obstacle, the floor, or an enemy",
				"↑ Hitting an enemy with an egg may spawn more and larger spiders",
			}
		},
		[Item.YARN.ID] = {
			Name = "The Yarn",
			Description = {
				"Blocks projectiles",
				"#Zaps nearby enemies with electricity",
				"#{{WebHeart}} Spawns 1 Web Heart every 4 rooms"
			}
		},
		[Item.ARACHNIDS_GRIP.ID] = {
			Name = "Arachnid's Grip",
			Description = {
				ARC_EID.GetFallbackDescription,
				function(descObj)
					return modifiers[Item.ARACHNIDS_GRIP.ID]._modifier(descObj,
						"#{{Collectible" ..
						Item.MUTAGEN.ID .. "}} Spiders can be {{ColorRainbow}}special{{CR}} and/or larger"
					)
				end
			},
			FallbackDescription = {
				"{{Poison}} 25% chance to shoot poison tears",
				"#Enemies may drop a spider egg pickup on death that grant a fragile orbital on pickup",
				"#Orbital may break when blocking projectiles or dealing damage, spawning a {{AracBlueSpider}} Blue Spider",
			}
		},
		[Item.YARN_HEART.ID] = {
			Name = "Yarn Heart",
			Description = {
				"{{WebHeart}} +1 Web Heart"
			}
		},
		[Item.MECHANICAL_EYE.ID] = {
			Name = "Mechanical Eye",
			Description = {
				"Orbital",
				"#Displays a random active item with the same amount of charges as Isaac's current active item",
				"#Using an active item will also use the displayed item",
				"#Displayed item rerolls when entering a new room or using an active item"
			}
		},
		[Item.GEPTAMERON.ID] = {
			Name = "Getameron",
			Description = {
				"Triggers an effect based on the indicator on the item:",
				"#{{1}} Reveals {{SecretRoom}}{{SuperSecretRoom}} and uses {{Collectible" .. CollectibleType.COLLECTIBLE_DADS_KEY .. "}}",
				"#{{2}} Spawns temporary friendly companions that chase enemies. May leave 1 {{RottenHeart}} on death",
				"#{{3}} 50% chance to {{Charm}} charm all enemies or have them spawn 3 {{Trinket" .. TrinketType.TRINKET_LOCUST_OF_WRATH .. "}} locusts on death",
				"#{{4}} Gain 2 {{Collectible" .. CollectibleType.COLLECTIBLE_GUARDIAN_ANGEL .. "}} and a {{HolyMantle}} mantle shield for the room",
				"#{{5}} All enemies in the room will drop {{Coin}} disappearing coins on death",
				"#{{6}} Missiles rain down in random locations for 10 seconds",
				"#{{7}} 1-3 enemies marked to drop a random disappearing pickup on death, which passes the mark to another enemy"
			}
		},
		[Item.GLASSES_3D.ID] = {
			Name = "3D Glasses",
			Description = {
				"5% chance to shoot \"3D\" tears, which split an enemy into 2 friendly versions of itself on hit",
				"#{{Luck}} 25% chance at 20 luck",
				"#These friendly enemies take no damage, but disappear on room clear",
			}
		},
		[Item.MUTAGEN.ID] = {
			Name = "Mutagen",
			Description = {
				"↑ {{Damage}} +1 Damage",
				"#{{AracBlueSpider}} 20% chance to spawn 3-5 {{ColorRainbow}}special{{CR}} friendly spiders when entering a new room",
				"#{{AracBlueSpider}} All spiders spawned outside of spider eggs have a chance to be {{ColorRainbow}}special{{CR}}"
			}
		},
		[Item.TESTAMENT.ID] = {
			Name = "The Testament",
			Description = {
				"Teleports Isaac to a floor that contains all his current items",
				"#Choosing an item from this floor teleports Isaac back to the room he came from",
				"#The chosen item will appear at the start of the next run",
				"#Having no items will spawn {{Collectible" ..
				CollectibleType.COLLECTIBLE_EDENS_BLESSING .. "}} Eden's Blessing instead"
			}
		},
		[Item.LIL_ARACHNA.ID] = {
			Name = "Lil Arachna",
			Description = {
				"{{Slow}} Shoots slowing and quad-split tears",
				"#Deals 3.5 damage per tear",
				"#{{StatusSpiderBite}} 25% chance for tears to inflict Spider Bite, having enemies drop Spider Eggs on death",
				"#{{Timer}} Spider Eggs drop nothing after 16 seconds or {{ColorRainbow}}special{{CR}} friendly spiders on room clear"
			}
		},
		[Item.DADS_NEWSPAPER.ID] = {
			Name = "Dad's Newspaper",
			Description = {
				"Isaac holds a newspaper in front of him",
				"#Double-tap shoot to swing",
				"#{{Confusion}} Deals moderate damage and inflicts confusion on hit",
				"#Instantly kills fly enemies"
			}
		},
		[Item.BEST_BUD_BALL.ID] = {
			Name = "Best Bud Ball",
			Description = {
				"{{Throwable}} Can be thrown at bosses in an attempt to capture them",
				"#{{Luck}} Chances of catching scales with boss' health and Isaac's luck",
				"#{{Friendly}} Using the item after successfully capturing a boss spawns the capture as a friendly companion",
				"#Walking over the ball after a capture instantly recharges the item",
				"#!!! Only one boss can be active at a time"
			}
		},
	}
end
