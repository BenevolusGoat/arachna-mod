local Mod = ArachnaMod
local Trinket = Mod.Trinket

return function(modifiers)
	return {
		[Trinket.INFESTED_PENNY.ID] = {
			Name = "Infested Penny",
			Description = {
				"{{AracBlueSpider}} Picking up a coin spawns a blue spider",
				"#{{WebHeart}} Additional 20% chance to spawn a Web Heart",
				"#Higher chance from nickels and dimes"
			},
		},
		[Trinket.SPINDLE.ID] = {
			Name = "Spindle",
			Description = {
				"{{StatusWebbed}} Touching enemies inflicts Webbed on them for 5 seconds",
				"#{{StatusWebbed}} Enemies are {{Slow}} slowed, receive less knockback, and drop a Spider Egg on death",
				"#{{AracBlueSpider}} Spider Eggs hatch on room clear, spawning several blue spiders",
				"#{{WebHeart}} Increases spawn chance of Web Hearts by 10%",
				function(descObj)
					return modifiers[Trinket.SPINDLE.ID]._modifier(descObj,
						"#{{Collectible" .. CollectibleType.COLLECTIBLE_MIDAS_TOUCH .. "}} Spider Eggs are {{ColorGold}}golden{{CR}} and hatch into golden spiders"
					)
				end
			}
		},
		[Trinket.WHITE_STRING.ID] = {
			Name = "White String",
			Description = {
				"{{WebHeart}} Entering a new floor grants +1 Web Heart"
			},
		},
	}
end
