local mod = ARACHNAMOD
local game = ARACHNAMOD.game
local sfx = ARACHNAMOD.sfx
--BEHAVIOUR
--shot out white slowing tears
function mod:whiteClotTears(tear)
	if (tear.SpawnerEntity) and (tear.SpawnerEntity:ToFamiliar()) then
		local data = tear:GetData()
		if not data.init then
			local baby = tear.SpawnerEntity:ToFamiliar()
			if (baby.Type == 3) and (baby.Variant == 238) and (baby.SubType == 2000) then
				tear:AddTearFlags(TearFlags.TEAR_SLOW)
				tear.Color = Color(2, 2, 2, 1, 0.196, 0.196, 0.196)
			end
			data.init = true
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mod.whiteClotTears)