local Mod = ArachnaMod
local loader = {
	Patches = {},
	AppliedPatches = false,
}

ArachnaMod.PatchesLoader = loader

-- Registers a Mod patch
-- Mod:string           Name of Mod global
-- patchFunc:function   Function that takes 0 arguments and applies the patch
---@param mod string|fun():boolean
---@param patchFunc fun()
---@param modName? string
---@param priority? CallbackPriority
function loader:RegisterPatch(mod, patchFunc, modName, priority)
	table.insert(loader.Patches, { Mod = mod, ModName = modName or tostring(mod), PatchFunc = patchFunc, Loaded = false, Priority = priority or CallbackPriority.DEFAULT})
end

function loader:ApplyPatches(priority)
	priority = priority or CallbackPriority.DEFAULT
	for _, patch in pairs(loader.Patches) do
		if patch.Priority ~= priority then goto skipMod end
		-- check if Mod reference is valid by getting it by name from the table of globals
		-- we cannot directly pass the Mod reference to RegisterPatch
		-- and then check for it because that Mod reference will be nil
		-- if that Mod is loaded after ours
		local modExists
		if type(patch.Mod) == "function" then
			modExists = patch.Mod()
		else
			modExists = _G[patch.Mod]
		end

		if modExists and not patch.Loaded then
			patch.PatchFunc()
			patch.Loaded = true
			Mod:DebugLog(table.concat({ "Loaded", patch.ModName, "patch" }, " "))
		end
		::skipMod::
	end

	loader.AppliedPatches = true
end

local patches = {
	"pogforgooditems",
	"ughforbaditems",
	"unique_minisaacs",
	"minimapapi",
	"epiphany",
	"stageapi",
	"fiend_folio",
	"future",
	"no_costumes",
	"specialist_fix",
	"specialist_dance",
	"wardrobe_plus",
	"time_machine_plus",
	"library_expanded"
}

for _, fileName in ipairs(patches) do
	include("scripts/compatibility/patches/" .. fileName)
end

Mod:AddPriorityCallback(ModCallbacks.MC_POST_MODS_LOADED, CallbackPriority.EARLY, function() loader:ApplyPatches(CallbackPriority.EARLY) end)
Mod:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, loader.ApplyPatches)
Mod:AddPriorityCallback(ModCallbacks.MC_POST_MODS_LOADED, CallbackPriority.LATE, function() loader:ApplyPatches(CallbackPriority.LATE) end)

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	if not loader.AppliedPatches then
		loader:ApplyPatches()
	end
end)
