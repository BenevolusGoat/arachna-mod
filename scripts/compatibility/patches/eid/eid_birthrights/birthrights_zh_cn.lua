local Mod = ARACHNAMOD
local Item = Mod.Item

return function(modifiers)
	return {
		[Mod.PlayerType.ARACHNA] = {
			Name = "Arachna",
			Description = {
				"{{Collectible" .. Item.ARACHNAS_SPOOL.ID .. "}} Can have up to 2 webs active at a time",
				"#↑ Increased chance of spider eggs spawning {{ColorRainbow}}special{{CR}} friendly spiders",
				"#{{WebHeart}} 5% chance for spider eggs to drop a Web Heart upon hatching"
			}
		},
		[Mod.PlayerType.ARACHNA_B] = {
			Name = "Tainted Arachna",
			Description = {
				"{{StatusWebbed}} Thrown eggs drop small spider webs",
				"#Can have up to 3 webs active at a time",
				"#Spider webs have {{ColorRainbow}}special{{CR}} effects corresponding with the egg's color",
				"#{{StatusWebbed}} Enemies on the web are {{Slow}} slowed, receive less knockback, and drop a spider egg on death",
				"#!!! These new spider eggs will not have special colors"
			}
		},
	}
end
