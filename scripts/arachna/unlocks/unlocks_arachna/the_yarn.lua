local Mod = ARACHNAMOD

local YARN = {}

ARACHNAMOD.Item.YARN = YARN

YARN.ID = Isaac.GetItemIdByName("The Yarn")
YARN.FAMILIAR = Isaac.GetEntityVariantByName("The Yarn (follower)")

YARN.ROOM_CLEAR_THRESHOLD = 4

YARN.FIRE_DISTANCE = 80

YARN.WEB_HEART_CHANCE = 0.25
YARN.WEB_HEART_CHANCE_BFFS = 0.3

YARN.FIRE_COOLDOWN = 48
YARN.FIRE_COOLDOWN_LULLABY = 32

YARN.LASER_DAMAGE = 5.2
YARN.LASER_DAMAGE_BFFS = 8.1

---@param familiar EntityFamiliar
function YARN:OnFamiliarInit(familiar)
	local sprite = familiar:GetSprite()
	sprite:Play("Idle")
	sprite:PlayOverlay("elecOverlay")
	familiar:AddToFollowers()
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, YARN.OnFamiliarInit, YARN.FAMILIAR)

---@param familiar EntityFamiliar
function YARN:FireLaser(familiar)
	local player = familiar.Player
	familiar:PickEnemyTarget(YARN.FIRE_DISTANCE)
	if familiar.Target then
		familiar.TargetPosition = familiar.Target.Position
		local offset = Vector(0, -25* familiar.SpriteScale.Y)
		local angle = (familiar.TargetPosition - familiar.Position):GetAngleDegrees()
		local laser = EntityLaser.ShootAngle(LaserVariant.THIN_RED, familiar.Position, angle, 3, offset, familiar)
		laser.CollisionDamage = YARN.LASER_DAMAGE
		laser.DisableFollowParent = true
		laser:SetMaxDistance(familiar.Position:Distance(familiar.TargetPosition))
		laser.Color = Color(1, 1, 1, 1, 1, 1, 0)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
			laser.CollisionDamage = YARN.LASER_DAMAGE_BFFS
		end
		local fireCooldown = YARN.FIRE_COOLDOWN
		if player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) then
			fireCooldown = YARN.FIRE_COOLDOWN_LULLABY
		end
		familiar.FireCooldown = fireCooldown
	end
end

---@param familiar EntityFamiliar
function YARN:OnFamiliarUpdate(familiar)
	local player = familiar.Player
	if familiar.FireCooldown > 0 then
		familiar.FireCooldown = familiar.FireCooldown - 1
	end
	if player:GetFireDirection() ~= Direction.NO_DIRECTION and familiar.FireCooldown == 0 then
		YARN:FireLaser(familiar)
	end
	familiar:FollowParent()
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, YARN.OnFamiliarUpdate, YARN.FAMILIAR)

---@param player EntityPlayer
function YARN:OnRoomClear(player)
	local heartChance = YARN.WEB_HEART_CHANCE
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
		heartChance = YARN.WEB_HEART_CHANCE_BFFS
	end
	Mod.Foreach.Familiar(function (familiar, index)
		if (familiar.RoomClearCount + 1) % YARN.ROOM_CLEAR_THRESHOLD == 0
			and GetPtrHash(player) == GetPtrHash(familiar.Player)
		then
			local rng = player:GetCollectibleRNG(YARN.ID)
			if rng:RandomFloat() < heartChance then
				local pos = Mod.Room():FindFreePickupSpawnPosition(familiar.Position)
				Mod.Spawn.Pickup(PickupVariant.PICKUP_HEART, Mod.Pickup.WEB_HEART.ID, pos, nil, familiar, rng:Next())
			end
		end
	end, YARN.FAMILIAR)
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_ROOM_CLEAR, YARN.OnRoomClear)

---@param player EntityPlayer
function YARN:HandleCache(player)
	local num = player:GetCollectibleNum(YARN.ID) +
		player:GetEffects():GetCollectibleEffectNum(YARN.ID)
	local rng = player:GetCollectibleRNG(YARN.ID)
	rng:Next()

	player:CheckFamiliar(YARN.FAMILIAR, num, rng, Mod.ItemConfig:GetCollectible(YARN.ID))
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, YARN.HandleCache, CacheFlag.CACHE_FAMILIARS)

Mod:AddCallback(ModCallbacks.MC_GET_FOLLOWER_PRIORITY, function(_, familiar)
	return FollowerPriority.DEFENSIVE
end, YARN.FAMILIAR)