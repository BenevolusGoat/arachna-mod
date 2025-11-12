---@diagnostic disable: undefined-global
local Mod = ARACHNAMOD
local loader = Mod.PatchesLoader

local function noCostumesPatch()
	addCostumeToIgnoreList("gfx/characters/character_arachna_head.anm2")
	addCostumeToIgnoreList("gfx/characters/character_arachna_b_head.anm2")
end

loader:RegisterPatch("NoCostumes", noCostumesPatch)