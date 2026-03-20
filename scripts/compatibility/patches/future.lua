local Mod = ARACHNAMOD
local loader = Mod.PatchesLoader

local function futurePatch()
	TheFuture.ModdedCharacterDialogue["Arachna"] = {
		"ack, a spider!",
		"...oh, you're friendly? that's good.",
		"sorry, spiders give me the creeps.",
		"you think there are still spiders in the future?"
	}
	--thank you TheHGamerette and ZRMicro for the suggestion
	TheFuture.ModdedTaintedCharacterDialogue["Arachna"] = {
		"eek, a tarantula!",
		"look, youre venomous. i cant let you in!",
		"ill die if i eat you!",
		". . .",
		"wait, thats poisonous."
	}
end

loader:RegisterPatch("TheFuture", futurePatch)