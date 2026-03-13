local Mod = ARACHNAMOD
local Trinket = Mod.Trinket

return function(modifiers)
	return {
		[Trinket.INFESTED_PENNY.ID] = {
			Name = "Infested Penny",
			Description = {
				"{{AracBlueSpider}} Picking up a coin spawns a blue spider",
				"#{{WebHeart}} Additional 5% chance to spawn a Web Heart",
				"#Higher chance from nickels and dimes"
			},
		},
		[Trinket.SPINDLE.ID] = {
			Name = "Spindle",
			Description = {
				"{{StatusSpiderBite}} Touching enemies ensnares them, {{slow}} slowing them and spawning Spider Eggs on death",
				"#Spider Eggs drop {{ColorRainbow}}special{{CR}} friendly spiders on room clear",
				"#{{WebHeart}} Increases spawn chance of Web Hearts by +10%"
			}
		},
		[Trinket.WHITE_STRING.ID] = {
			Name = "White String",
			Description = {
				"{{WebHeart}} Entering a new floor grants +1 Web Heart"
			}
		},
	}
end
