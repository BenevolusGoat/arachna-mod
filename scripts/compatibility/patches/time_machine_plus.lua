local Mod = ARACHNAMOD
local loader = Mod.PatchesLoader

local function tmPlusPatch()
	--Manually update TM Plus' own Arachna compatibility--
	local function TMplusCompatibility()
		TMplus.ArachnaTMPSlotIndex = {
			[Mod.Slot.SPIDER_BEGGAR.ID] = {"Spider Beggar", true}
		}
		TMplus:AddCompatibility("Arachna", 2.0, TMplus.ArachnaTMPSlotIndex)
	end
	Mod:AddCallback("TM+_REQUEST_COMPATIBILITY_DATA", TMplusCompatibility)
end


loader:RegisterPatch("TMplus", tmPlusPatch, "Time Machine PLUS")