local Mod = ArachnaMod
local game = Mod.Game
local loader = ArachnaMod.PatchesLoader

local function SpecialistDancePatch()
	--It breaks if added immediately so MC_POST_NEW_LEVEL is used here instead...I guess?
	Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
		local costume = Isaac.GetCostumeIdByPath("gfx/characters/arachna_dance.anm2")
		SpecialistModAPI:AddDanceCostume(Mod.PlayerType.ARACHNA, costume, true)
		local costume_b = Isaac.GetCostumeIdByPath("gfx/characters/arachna_b_dance.anm2")
		SpecialistModAPI:AddDanceCostume(Mod.PlayerType.ARACHNA_B, costume_b, true)
	end)
end

loader:RegisterPatch("SpecialistModAPI", SpecialistDancePatch, "Specialist Dance")
