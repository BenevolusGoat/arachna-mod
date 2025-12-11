--Full credit to Epiphany
local Mod = ARACHNAMOD
local min = Mod.math.min

---@param pickup EntityPickup
function ARACHNAMOD:IsDevilDealItem(pickup)
	return pickup.Price < 0 and pickup.Price ~= PickupPrice.PRICE_FREE and pickup.Price ~= PickupPrice.PRICE_SPIKES
end

-- Removes given pedestal and tries to start an ambush.
function ARACHNAMOD:KillPedestal(pedestal)
	pedestal:TriggerTheresOptionsPickup()
	Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pedestal.Position, Vector.Zero, nil)
	pedestal:Remove()
	Ambush.StartChallenge()
end

---Checks the pickup and simulates pickup interaction
---@param player EntityPlayer
---@param pickup EntityPickup
---@return boolean @Returns `false` if you can't pick up the pickup, `true` if you consumed it.
function ARACHNAMOD:PricedPickup(player, pickup)
	if Mod:CanPlayerBuyShopItem(player, pickup) then
		if pickup.Price > 0 and player:GetNumCoins() < pickup.Price then
			return false
		end -- we return if the price is in money and the player doesn't have enough
		if pickup.Price == 0 then
			Mod:PickupKill(pickup)
			return true
		end

		Mod:PayPickupPrice(player, pickup)
		Mod:PickupShopKill(player, pickup)
		return true
	end
	return false
end

---Kills a shop pickup and plays the correct pickup animation
---@param player EntityPlayer
---@param pickup EntityPickup
---@param sound SoundEffect?
function ARACHNAMOD:PickupShopKill(player, pickup, sound)
	local sprite = pickup:GetSprite()
	if not sound then
		pickup:PlayPickupSound()
	else
		Mod.sfxman:Play(sound, 1, 0, false, 1.0)
	end
	player:AnimatePickup(sprite, true, "Pickup")
	pickup.EntityCollisionClass = 0
	local game = Mod.Game
	local room = game:GetRoom()

	if player:HasCollectible(CollectibleType.COLLECTIBLE_RESTOCK) and (room:GetType() == RoomType.ROOM_SHOP or room:GetType() == RoomType.ROOM_BLACK_MARKET)
		or game:IsGreedMode() and room:GetType() == RoomType.ROOM_SHOP
	then
		CustomHealthAPI.Library.TriggerRestock(pickup)
	end
	pickup:Remove()
end

---Kills a pickup and simulaters vanilla behaviour
---@param pickup EntityPickup
---@param playSound? boolean
function ARACHNAMOD:PickupKill(pickup, playSound)
	if playSound then
		pickup:PlayPickupSound()
	end
	pickup.Velocity = Vector.Zero
	pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	pickup:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	pickup:GetSprite():Play("Collect", true)
	pickup:TriggerTheresOptionsPickup()
	pickup:Die()
end

---Makes a custom coin play the pickup animation
function ARACHNAMOD:CollectCustomCoin(pickup, SoundID)
	pickup = pickup:ToPickup()
	pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	pickup.Touched = true
	pickup:TriggerTheresOptionsPickup()

	local sprite = pickup:GetSprite()
	sprite:RemoveOverlay()
	sprite:Play("Collect", true)
	pickup:Die()

	if SoundID then
		Mod.sfxman:Play(SoundID, 1, 0, false, 1.0)
	end
end

---Removes coins or health according to given pickup's price
---@param player EntityPlayer
---@param pickup EntityPickup
function ARACHNAMOD:PayPickupPrice(player, pickup)
	local price = pickup.Price
	if price > 0 then
		player:AddCoins(-price)
	elseif price == PickupPrice.PRICE_SOUL then
		player:TryRemoveTrinket(TrinketType.TRINKET_YOUR_SOUL)
	elseif price == PickupPrice.PRICE_SPIKES then
		if not Mod:IsAnyLost(player) then
			local ref = EntityRef(pickup)
			-- following vanilla entity refs for price spikes
			ref.Type = 0
			ref.Variant = 0
			ref.Entity = nil
			player:TakeDamage(2, DamageFlag.DAMAGE_SPIKES | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag
				.DAMAGE_NO_PENALTIES, ref, 30)
		end
	elseif Mod:IsDevilDealItem(pickup) then
		if Mod:IsAnyLost(player) then
			Mod:KillDevilPedestals(pickup)
		else
			if price == PickupPrice.PRICE_ONE_HEART then
				player:AddMaxHearts(-2)
			elseif price == PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS then
				player:AddMaxHearts(-2)
				player:AddSoulHearts(-4)
			elseif price == PickupPrice.PRICE_THREE_SOULHEARTS then
				player:AddSoulHearts(-6)
			elseif price == PickupPrice.PRICE_TWO_HEARTS then
				player:AddMaxHearts(-4)
			end
		end
	elseif price == PickupPrice.PRICE_FREE then
		if not player:TryRemoveTrinket(TrinketType.TRINKET_STORE_CREDIT) then
			for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PLAYER)) do
				local _player = ent:ToPlayer()
				if _player and _player:TryRemoveTrinket(TrinketType.TRINKET_STORE_CREDIT) then
					return
				end
			end
		end
	end
end

--- Kills all pedestals that cost hearts. For use when Lost buys a devil item
---@param ignoredPickup? EntityPickup A pointer hash to a pedestal that will be ignored. In most cases, this should be a pedestal that the player just picked up.
---@param filter? fun(Pedestal: EntityPickup): boolean
function ARACHNAMOD:KillDevilPedestals(ignoredPickup, filter)
	local ignoredHash = GetPtrHash(ignoredPickup) or -1
	local level = Mod.Level()
	local isDarkRoom = level:GetStage() == LevelStage.STAGE6 and level:GetStageType() == StageType.STAGETYPE_ORIGINAL
	local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)
	local roomIndex = level:GetCurrentRoomDesc().SafeGridIndex
	local startingRoomIndex = level:GetStartingRoomIndex()

	for i = #pickups, 1, -1 do
		local ent = pickups[i]
		local pickup = ent:ToPickup() ---@cast pickup EntityPickup
		if GetPtrHash(pickup) ~= ignoredHash
			and (Mod:IsDevilDealItem(pickup)
				or roomIndex == startingRoomIndex
				and pickup.Variant == PickupVariant.PICKUP_REDCHEST
				and isDarkRoom)
			and (not filter or filter(pickup))
		then
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil)
			pickup:Remove()
		end
	end
end

---@param itemPoolType ItemPoolType
---@param maxIterations integer
---@param filter fun(item: CollectibleType): boolean
function ARACHNAMOD:BruteForceRoll(itemPoolType, maxIterations, filter)
	local itemPool = Mod.Game:GetItemPool()
	local iter = 0

	local item
	if PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_TMTRAINER) then
		item = itemPool:GetCollectible(itemPoolType, false)
	else
		repeat
			item = itemPool:GetCollectible(itemPoolType, false)
			iter = iter + 1
		until filter(item) or iter >= maxIterations
	end

	return item
end

---@param pedestal EntityPickup
function ARACHNAMOD:MakePedestalEmpty(pedestal)
	if REPENTOGON then
		pedestal:TryRemoveCollectible()
		return
	end

	if pedestal.Price ~= 0 then
		pedestal:Remove()
	else
		pedestal.SubType = 0
		local sprite = pedestal:GetSprite()
		sprite:ReplaceSpritesheet(1, "gfx/none.png") -- replace collectible sprite with a nonexistent one
		sprite:ReplaceSpritesheet(4, "gfx/none.png") -- remove shadow
		pedestal:GetSprite():LoadGraphics()
	end
end
