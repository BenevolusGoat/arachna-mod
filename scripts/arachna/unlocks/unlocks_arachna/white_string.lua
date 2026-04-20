local Mod = ArachnaMod

local WHITE_STRING = {}

ArachnaMod.Trinket.WHITE_STRING = WHITE_STRING

WHITE_STRING.ID = Isaac.GetTrinketIdByName("White String")

---@param player EntityPlayer
---@param postLevelInitFinished boolean
function WHITE_STRING:WebHeartOnNewFloor(player, fromPlayerUpdate, postLevelInitFinished)
	if player:HasTrinket(WHITE_STRING.ID)
		and Mod.Pickup.WEB_HEART:CanPickup(player)
		and postLevelInitFinished
	then
		Mod.Pickup.WEB_HEART:AddWebHearts(player, player:GetTrinketMultiplier(WHITE_STRING.ID))
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, WHITE_STRING.WebHeartOnNewFloor)
