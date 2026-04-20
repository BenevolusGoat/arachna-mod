local Mod = ArachnaMod
local loader = Mod.PatchesLoader

local function stageApiPatch()
	if not StageAPI.Loaded then return end

	local arachnaConfig = EntityConfig.GetPlayer(Mod.PlayerType.ARACHNA)
	---@cast arachnaConfig EntityConfigPlayer
	StageAPI.AddPlayerGraphicsInfo(Mod.PlayerType.ARACHNA,
		arachnaConfig:GetPortraitPath(),
		arachnaConfig:GetNameImagePath(),
		true
	)

	local arachnaBConfig = EntityConfig.GetPlayer(Mod.PlayerType.ARACHNA_B)
	---@cast arachnaBConfig EntityConfigPlayer
	StageAPI.AddPlayerGraphicsInfo(Mod.PlayerType.ARACHNA_B,
		arachnaBConfig:GetPortraitPath(),
		arachnaBConfig:GetNameImagePath(),
		true
	)
end

loader:RegisterPatch("StageAPI", stageApiPatch)
