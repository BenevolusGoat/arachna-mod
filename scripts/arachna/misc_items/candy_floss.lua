local Mod = ARACHNAMOD

local CANDY_FLOSS = {}

ARACHNAMOD.Item.CANDY_FLOSS = CANDY_FLOSS

CANDY_FLOSS.ID = Isaac.GetItemIdByName("Candy Floss")

CANDY_FLOSS.MIN_WEB_HEARTS = 3

CANDY_FLOSS.MODIFIER = Mod.TearModifier.New({
	Name = "CandyFloss",
	Items = {CANDY_FLOSS.ID},
	MinLuck = 0,
	MaxLuck = 100,
	MinChance = 0.05,
	MaxChance = 1,
	Color = Color(2, 2, 2, 1, 0.196, 0.196, 0.196)
})

function CANDY_FLOSS.MODIFIER:PostFire(object)
	object:AddTearFlags(TearFlags.TEAR_QUADSPLIT | TearFlags.TEAR_SLOW)
end

---@param player EntityPlayer
---@param itemId CollectibleType
---@param firstTime boolean
function CANDY_FLOSS:OnCollectibleAdd(itemId, charge, firstTime, slot, varData, player)
	local webHeartCount = 0
	local redHearts = player:GetHearts()
	if redHearts > 1 then
		webHeartCount = Mod.math.ceil((redHearts - 1) / 2)
		player:AddHearts(-1 * (redHearts - 1))
	end
	webHeartCount = Mod.math.max(webHeartCount, CANDY_FLOSS.MIN_WEB_HEARTS)
	local room = Mod.Room()
	local rng = player:GetCollectibleRNG(itemId)

	for _ = 1, webHeartCount do
		local nearPos = room:FindFreePickupSpawnPosition(player.Position, 25)
		Mod.Spawn.Heart(Mod.Pickup.WEB_HEART.ID, nearPos, nil, player, rng:Next())
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, CANDY_FLOSS.OnCollectibleAdd, CANDY_FLOSS.ID)