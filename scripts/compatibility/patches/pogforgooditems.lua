local Mod = ArachnaMod
local loader = Mod.PatchesLoader

local function pogPatch()
	local pogCostume = Isaac.GetCostumeIdByPath("gfx/characters/arachna_pog.anm2")
	Poglite:AddPogCostume("ArachnaPog", Mod.PlayerType.ARACHNA, pogCostume)

	local pogCostume_B = Isaac.GetCostumeIdByPath("gfx/characters/arachna_pog_b.anm2")
	Poglite:AddPogCostume("ArachnaBPog", Mod.PlayerType.ARACHNA_B, pogCostume_B)
end

loader:RegisterPatch("Poglite", pogPatch, "POG For Good Items")
