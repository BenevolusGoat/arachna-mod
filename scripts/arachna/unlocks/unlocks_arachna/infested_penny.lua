local Mod = ArachnaMod
local persistentGameData = Isaac.GetPersistentGameData()

local INFESTED_PENNY = {}

ArachnaMod.Trinket.INFESTED_PENNY = INFESTED_PENNY

INFESTED_PENNY.ID = Isaac.GetTrinketIdByName("Infested Penny")

---@param coinWorth number
---@param trinketMult? integer
local function getWebHeartChance(coinWorth, trinketMult)
	trinketMult = trinketMult or 1
	if coinWorth > 99 then
		coinWorth = 1
	end
	local baseChance = 0.80 - (0.18 * (trinketMult - 1))
	return 1 - (baseChance ^ coinWorth)
end

---@param coin EntityPickup
---@param collider Entity
function INFESTED_PENNY:OnCoinCollision(coin, collider)
	local player = collider:ToPlayer()
	if coin:IsDead() and player and player:HasTrinket(INFESTED_PENNY.ID) then
		Mod.Entities.COLORED_SPIDERS:ThrowFriendlySpider(player, 0, coin.Position)

		local rng = player:GetTrinketRNG(INFESTED_PENNY.ID)
		local chance = getWebHeartChance(coin:GetCoinValue(), player:GetTrinketMultiplier(INFESTED_PENNY.ID))

		if persistentGameData:Unlocked(Mod.Pickup.WEB_HEART.ACHIEVEMENT) and rng:RandomFloat() < chance then
			local pos = Mod.Room():FindFreePickupSpawnPosition(coin.Position)
			Mod.Spawn.Heart(Mod.Pickup.WEB_HEART.ID, pos, nil, player, coin.DropSeed)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, INFESTED_PENNY.OnCoinCollision, PickupVariant.PICKUP_COIN)
