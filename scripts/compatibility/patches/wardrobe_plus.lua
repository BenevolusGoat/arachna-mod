local Mod = ArachnaMod
local loader = Mod.PatchesLoader

local function wardrobePlusPatch()
	OWRP.AddNewCostume("arachnaHair", "Arachna", "gfx/characters/character_arachna_head.anm2", false, true)
	OWRP.AddNewCostume("arachnaBHair", "The Wretched", "gfx/characters/character_arachna_b_head.anm2", false, true)
end

loader:RegisterPatch("WardrobePlus", wardrobePlusPatch)
