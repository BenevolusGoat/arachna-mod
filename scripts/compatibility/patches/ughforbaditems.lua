local Mod = ARACHNAMOD
local loader = Mod.PatchesLoader

local function pogPatch()
	local ughCostume = Isaac.GetCostumeIdByPath("gfx/characters/arachna_ugh.anm2")
	Ughlite:AddUghCostume("ArachnaUgh", Mod.PlayerType.ARACHNA, ughCostume)

	--[[ local ughCostume_B = Isaac.GetCostumeIdByPath("gfx/characters/arachna_ugh_b.anm2")
	Ughlite:AddUghCostume("ArachnaBUgh", Mod.PlayerType.ARACHNA_B, ughCostume_B) ]]
end

loader:RegisterPatch("Ughlite", pogPatch, "UGH For Bad Items")