local Mod = ARACHNAMOD
local loader = Mod.PatchesLoader

local function uniqueMinisaacsPatch()
	UniqueMinisaacs.CharacterData[Mod.PlayerType.ARACHNA] = {
		Filename = "arachna",
		AppendSkinColor = false
	}
	UniqueMinisaacs.CharacterData[Mod.PlayerType.ARACHNA_B] = {
		Filename = "arachna_b",
		AppendSkinColor = false
	}
end

loader:RegisterPatch("UniqueMinisaacs", uniqueMinisaacsPatch)