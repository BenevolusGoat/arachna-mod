local Mod = ARACHNAMOD

local OLD_SHOEBOX = {}

ARACHNAMOD.Item.OLD_SHOEBOX = OLD_SHOEBOX

OLD_SHOEBOX.ID = Isaac.GetItemIdByName("Old Shoebox")

---@param player EntityPlayer
---@param itemId CollectibleType
---@param firstTime boolean
function OLD_SHOEBOX:OnCollectibleAdd(itemId, charge, firstTime, slot, varData, player)
	local rng = player:GetCollectibleRNG(itemId)
	local nearPos = Mod.Room():FindFreePickupSpawnPosition(player.Position, 40)
	Mod.Spawn.Heart(Mod.Pickup.WEB_HEART.ID, nearPos, nil, player, rng:Next())

	for _ = 1, Mod:RandomNum(7, 14, rng) do
		Mod.Entities.COLORED_SPIDERS:ThrowColoredSpider(player, 0, player.Position)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, OLD_SHOEBOX.OnCollectibleAdd, OLD_SHOEBOX.ID)