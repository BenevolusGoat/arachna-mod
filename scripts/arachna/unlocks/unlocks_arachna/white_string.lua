local Mod = ARACHNAMOD

local WHITE_STRING = {}

ARACHNAMOD.Trinket.WHITE_STRING = WHITE_STRING

WHITE_STRING.ID = Isaac.GetTrinketIdByName("White String")

---@param player EntityPlayer
---@param postLevelInitFinished boolean
function WHITE_STRING:WebHeartOnNewFloor(player, fromPlayerUpdate, postLevelInitFinished)
	if not postLevelInitFinished then return end
	if player:HasTrinket(WHITE_STRING.ID) and Mod.Pickup.WEB_HEART:CanPickup(player) then
		Mod.Pickup.WEB_HEART:AddWebHearts(player, 1)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, WHITE_STRING.WebHeartOnNewFloor)