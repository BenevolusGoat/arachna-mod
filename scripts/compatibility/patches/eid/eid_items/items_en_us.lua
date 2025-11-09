local Mod = ARACHNAMOD
local ARC_EID = Mod.EID_Support
local Item = Mod.Item

return function(modifiers)
	return {
		[Item.ARACHNAS_SPOOL.ID] = {
			Name = "Arachna's Spool",
			Description = {""
			}
		},
	}
end
