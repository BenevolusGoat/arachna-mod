local Mod = ARACHNAMOD
local loader = Mod.PatchesLoader

local function futurePatch()
	--TODO: temporary dialogue, lol
	TheFuture.ModdedCharacterDialogue["Arachna"] = {
		"ack, a spider!",
	}
	TheFuture.ModdedTaintedCharacterDialogue["Arachna"] = {
		"ack, another spider!",
	}
end

loader:RegisterPatch("TheFuture", futurePatch)