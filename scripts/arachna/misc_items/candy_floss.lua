local Mod = ARACHNAMOD

local CANDY_FLOSS = {}

ARACHNAMOD.Item.CANDY_FLOSS = CANDY_FLOSS

CANDY_FLOSS.ID = Isaac.GetItemIdByName("Candy Floss")

CANDY_FLOSS.MIN_WEB_HEARTS = 3

CANDY_FLOSS.MODIFIER = Mod.TearModifier.New({
	Name = "CandyFloss",
	Items = {CANDY_FLOSS.ID},
	MinLuck = 0,
	MaxLuck = 20,
	MinChance = 0.05,
	MaxChance = 1,
	ShouldAffectBombs = true,
	Color = Color(2, 2, 2, 1, 0.196, 0.196, 0.196),
	LaserColor = Color.LaserSoy,
	DisableApplyLogic = true
})

local knifeLaserWeaponTypes = Mod:Set({
	WeaponType.WEAPON_BRIMSTONE,
	WeaponType.WEAPON_KNIFE,
	WeaponType.WEAPON_SPIRIT_SWORD,
	WeaponType.WEAPON_BONE,
	WeaponType.WEAPON_NOTCHED_AXE,
	WeaponType.WEAPON_TECH_X,
	WeaponType.WEAPON_LASER,
	WeaponType.WEAPON_LUDOVICO_TECHNIQUE
})

---@param player EntityPlayer
function CANDY_FLOSS:LaserColorCache(player)
	if player:HasCollectible(CANDY_FLOSS.ID) then
		player:SetLaserColor(CANDY_FLOSS.MODIFIER.LaserColor)
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, CANDY_FLOSS.LaserColorCache, CacheFlag.CACHE_TEARCOLOR)

---@param player EntityPlayer
---@param params TearParams
---@param weaponType WeaponType
---@param scale number
---@param displacement integer
---@param source Entity
function CANDY_FLOSS:ApplyTearHitParams(player, params, weaponType, scale, displacement, source)
	if not player:HasCollectible(CANDY_FLOSS.ID) then
		return
	end

	if knifeLaserWeaponTypes[weaponType] and CANDY_FLOSS.MODIFIER:CheckKnifeLaserAffected(player, nil, false)
		or not knifeLaserWeaponTypes[weaponType] and CANDY_FLOSS.MODIFIER:CheckTearAffected(player, false)
	then
		local color = CANDY_FLOSS.MODIFIER.Color
		---@cast color Color
		params.TearColor = color
		params.TearFlags = Mod:AddBitFlags(params.TearFlags, TearFlags.TEAR_QUADSPLIT | TearFlags.TEAR_SLOW)
		return params
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, CANDY_FLOSS.ApplyTearHitParams)

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