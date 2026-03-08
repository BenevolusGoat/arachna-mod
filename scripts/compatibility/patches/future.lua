local Mod = ARACHNAMOD
local loader = Mod.PatchesLoader

local function futurePatch()
	--TODO: temporary dialogue, lol
	TheFuture.ModdedCharacterDialogue["Arachna"] = {
		"ack, a spider!",
		"...oh, you're friendly? that's good.",
		"sorry, spiders give me the creeps.",
		"you think there are still spiders in the future?"
	}
	TheFuture.ModdedTaintedCharacterDialogue["Arachna"] = {
		"ack, another spider!",
	}
end

loader:RegisterPatch("TheFuture", futurePatch)