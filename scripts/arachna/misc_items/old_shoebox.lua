local Mod = ArachnaMod

local OLD_SHOEBOX = {}

ArachnaMod.Item.OLD_SHOEBOX = OLD_SHOEBOX

OLD_SHOEBOX.ID = Isaac.GetItemIdByName("Old Shoebox")
OLD_SHOEBOX.SPIDER_CHANCE = 1 --Idea from dima

---@param player EntityPlayer
---@param itemId CollectibleType
---@param firstTime boolean
function OLD_SHOEBOX:OnCollectibleAdd(itemId, charge, firstTime, slot, varData, player)
	if not firstTime then return end
	local rng = player:GetCollectibleRNG(itemId)
	local nearPos = Mod.Room():FindFreePickupSpawnPosition(player.Position, 40)
	Mod.Spawn.Heart(Mod.Pickup.WEB_HEART.ID, nearPos, nil, player, rng:Next())

	if rng:RandomFloat() < OLD_SHOEBOX.SPIDER_CHANCE then
		--Delayed so that spiders spawn if a new room is entered and because AnimateSad anim doesn't play if collecting from pedestal otherwise
		Mod:DelayOneFrame(function()
			for i = 1, 15 do
				local dist = 80
				---@cast dist number
				local targetPos = Isaac.GetFreeNearPosition(player.Position + Vector(dist, 0):Rotated(Mod:RandomNum(360)), 0)
				EntityNPC.ThrowSpider(player.Position, player, targetPos, false, -15)
			end
			player:AnimateSad()
		end)
	else
		for _ = 1, Mod:RandomNum(7, 14, rng) do
			Mod.Entities.COLORED_SPIDERS:ThrowFriendlySpider(player, 0, player.Position)
		end
	end

end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, OLD_SHOEBOX.OnCollectibleAdd, OLD_SHOEBOX.ID)
