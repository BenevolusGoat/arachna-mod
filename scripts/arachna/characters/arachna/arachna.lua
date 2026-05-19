--#region Variables

local Mod = ArachnaMod
local WEB_HEART = Mod.Pickup.WEB_HEART

local ARACHNA = {}

ArachnaMod.Character.ARACHNA = ARACHNA

Mod.Include("scripts.arachna.characters.arachna.arachnas_spool")

ARACHNA.POISON_CHANCE = 0.25

ARACHNA.SFX_HURT = Isaac.GetSoundIdByName("Arachna Hurt")
ARACHNA.SFX_DEATH = Isaac.GetSoundIdByName("Arachna Death")
ARACHNA.SFX_HURT_RARE = Isaac.GetSoundIdByName("Arachna Hurt (Rare)")
ARACHNA.SFX_DEATH_RARE = Isaac.GetSoundIdByName("Arachna Death (Rare)")
ARACHNA.RARE_SFX_CHANCE = 0.05
ARACHNA.RARE_DEATH_SFX_CHANCE = 0.15

CustomHealthAPI.PersistentData.CharactersThatConvertMaxHealth[Mod.PlayerType.ARACHNA] = WEB_HEART.KEY
CustomHealthAPI.PersistentData.CharactersThatCantHaveRedHealth[Mod.PlayerType.ARACHNA] = true

ARACHNA.TearVariantSpritesheetPath = "gfx/projectiles/"
ARACHNA.TearVariantToSpritesheet = {
	[TearVariant.BLUE] = "tear_arachna_normal",
	[TearVariant.BLOOD] = "tear_arachna_normal",
	[TearVariant.CUPID_BLUE] = "tear_arachna_cupid",
	[TearVariant.CUPID_BLOOD] = "tear_arachna_cupid",
	[TearVariant.PUPULA] = "tear_arachna_pupula",
	[TearVariant.PUPULA_BLOOD] = "tear_arachna_pupula",
	[TearVariant.HUNGRY] = "tear_arachna_hungry",
	[TearVariant.LOST_CONTACT] = "tear_arachna_lostcontact",
}

--#endregion

--#region Helpers

---@param player EntityPlayer
function ARACHNA:IsArachna(player)
	return player:GetPlayerType() == Mod.PlayerType.ARACHNA
end

---@param player EntityPlayer
function ARACHNA:ArachnaHasBirthright(player)
	return ARACHNA:IsArachna(player) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
end

--#endregion

--#region Web Hearts

---@param player EntityPlayer
function ARACHNA:StartingWebHearts(player)
	local playerType = player:GetPlayerType()
	if playerType == Mod.PlayerType.ARACHNA then
		WEB_HEART:AddWebHearts(player, 2)
	elseif playerType == Mod.PlayerType.ARACHNA_B then
		WEB_HEART:AddWebHearts(player, 3)
	end
end

Mod:AddCallback(ModCallbacks.MC_PLAYER_INIT_POST_LEVEL_INIT_STATS, ARACHNA.StartingWebHearts)

---@param player EntityPlayer
CustomHealthAPI.Library.AddCallback(Mod.CHAPI_ID, CustomHealthAPI.Enums.Callbacks.POST_PLAYER_GENESIS, 0, function (player)
	if Mod:IsAnyArachna(player) then
		local playerType = player:GetPlayerType()
		if playerType == Mod.PlayerType.ARACHNA then
			player:AddSoulHearts(-4)
			WEB_HEART:AddWebHearts(player, 2)
		elseif playerType == Mod.PlayerType.ARACHNA_B then
			player:AddSoulHearts(-6)
			WEB_HEART:AddWebHearts(player, 3)
		end
	end
end)

--#endregion

--#region Tear sprite

---@param tear EntityTear
function ARACHNA:SetArachnaTearSprite(tear)
	local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
	if player
		and Mod:IsAnyArachna(player)
		and tear.CanTriggerStreakEnd
	then
		local sprite = tear:GetSprite()
		local spritesheet = ARACHNA.TearVariantToSpritesheet[tear.Variant]
		if spritesheet then
			sprite:ReplaceSpritesheet(0, ARACHNA.TearVariantSpritesheetPath .. spritesheet .. ".png", true)
			Mod:GetData(tear).SpiderTear = true
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, ARACHNA.SetArachnaTearSprite)

---Tear splash on grid collision
---@param tear EntityTear
function ARACHNA:TearTouchGrid(tear)
	local data = Mod:GetData(tear)
	if (tear:IsDead()) and (data.SpiderTear) then
		local tC = tear:GetSprite().Color
		if not Mod:AreColorsDifferent(tC, Color.Default) then
			tear.Color = Color(0, 0, 0, 1, 1, 1, 1)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, ARACHNA.TearTouchGrid)

---Tear splash on enemy collision
---@param tear EntityTear
---@param collider Entity
function ARACHNA:TearTouchEnemy(tear, collider)
	local data = Mod:GetData(tear)
	if data.SpiderTear and tear:IsDead() then
		local tC = tear:GetSprite().Color
		if not Mod:AreColorsDifferent(tC, Color.Default) then
			tear.Color = Color(0, 0, 0, 1, 1, 1, 1)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_COLLISION, ARACHNA.TearTouchEnemy)

--#endregion

--#region Poison Tears

---@param player EntityPlayer
---@param tearParams TearParams
function ARACHNA:PosionTears(player, tearParams, weaponType, damageScale, tearDisplacement, source)
	if Mod:IsAnyArachna(player)
		and player:GetCollectibleRNG(Mod.Item.ARACHNIDS_GRIP.ID):RandomFloat() < ARACHNA.POISON_CHANCE
	then
		tearParams.TearFlags = Mod:AddBitFlags(tearParams.TearFlags, TearFlags.TEAR_POISON)
		--tearParams.TearColor = ArachnaMod:IsLaserWeaponType(weaponType) and Color.LaserPoison or Color.TearCommonCold
		return tearParams
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, ARACHNA.PosionTears)

--#endregion

--#region White lasers

---@param player EntityPlayer
function ARACHNA:LaserColorCache(player)
	if Mod:IsAnyArachna(player) then
		player:SetLaserColor(Color(1, 1, 1, 1, 0, 0, 0, 5.2, 5.2, 5, 1))
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ARACHNA.LaserColorCache, CacheFlag.CACHE_TEARCOLOR)

--#endregion

--#region Ignore Cobweb slow

---@param ent Entity
---@param source EntityRef
function ARACHNA:IgnoreCobwebSlow(statusID, ent, source, duration)
	local player = ent:ToPlayer()
	if player
		and Mod:IsAnyArachna(player)
		and not Mod:IsLegacyGameplayEnabled()
		and source.Type == 0 --If it came from nothing, best we can assume is cobweb. Otherwise...oh well!
	then
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_STATUS_EFFECT_APPLY, ARACHNA.IgnoreCobwebSlow, StatusEffect.SLOWING)

--#endregion

--#region Rare Sounds

function ARACHNA:RareSoundAlt(id, volume, delay, loop, pitch, pan)
	local chance = id == ARACHNA.SFX_HURT and ARACHNA.RARE_SFX_CHANCE or ARACHNA.RARE_DEATH_SFX_CHANCE
	if Mod:RandomNum() < chance then
		local newId = id == ARACHNA.SFX_HURT and ARACHNA.SFX_HURT_RARE or ARACHNA.SFX_DEATH_RARE
		return { newId, volume, delay, loop, pitch, pan }
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY, ARACHNA.RareSoundAlt, ARACHNA.SFX_HURT)
Mod:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY, ARACHNA.RareSoundAlt, ARACHNA.SFX_DEATH)

--#endregion

--#region Abaddon

---@param player EntityPlayer
function WEB_HEART:Abaddon(itemID, charge, firstTime, slot, varData, player)
	local numWebHearts = WEB_HEART:GetWebHearts(player)
	if numWebHearts > 0
	--and Mod:IsLegacyGameplayEnabled()
	then
		player:AddBlackHearts(numWebHearts * 2)
		WEB_HEART:AddWebHearts(player, -numWebHearts)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, WEB_HEART.Abaddon, CollectibleType.COLLECTIBLE_ABADDON)

--#endregion

--#region Patches for items that look for heart containers

local ACTIVE_FORCE_USE = Mod:Set({
	CollectibleType.COLLECTIBLE_GUPPYS_PAW,
	CollectibleType.COLLECTIBLE_POTATO_PEELER,
})

---@param player EntityPlayer
local function canForceActiveItem(player)
	return WEB_HEART:GetWebHearts(player) > 0
		and Mod:IsAnyArachna(player)
end

---@param player EntityPlayer
function WEB_HEART:ForceGuppysPaw(player)
	if canForceActiveItem(player)
		and player.ControlsEnabled
		and player.ControlsCooldown == 0
	then
		if Input.IsActionTriggered(ButtonAction.ACTION_ITEM, player.ControllerIndex)
			and ACTIVE_FORCE_USE[player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)]
		then
			player:UseActiveItem(player:GetActiveItem(ActiveSlot.SLOT_PRIMARY), UseFlag.USE_OWNED, ActiveSlot.SLOT_PRIMARY)
		end
		if Input.IsActionTriggered(ButtonAction.ACTION_PILLCARD, player.ControllerIndex) then
			local pocketItem = player:GetPocketItem(PillCardSlot.PRIMARY)
			local activeSlot = pocketItem:GetSlot() - 1
			if pocketItem:GetType() == PocketItemType.ACTIVE_ITEM
				and ACTIVE_FORCE_USE[player:GetActiveItem(activeSlot)]
			then
				player:UseActiveItem(player:GetActiveItem(activeSlot), UseFlag.USE_OWNED, activeSlot)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, WEB_HEART.ForceGuppysPaw, PlayerVariant.PLAYER)

---@param player EntityPlayer
function WEB_HEART:ArachnaGuppysPaw(itemID, rng, player, flags, slot, customVar)
	if canForceActiveItem(player) then
		player:AddSoulHearts(6)
		WEB_HEART:AddWebHearts(player, -1)
		Mod.sfxman:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0, false, 0.8)
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, WEB_HEART.ArachnaGuppysPaw, CollectibleType.COLLECTIBLE_GUPPYS_PAW)

---@param player EntityPlayer
function WEB_HEART:PotatoPeelerUse(itemID, rng, player, flags, slot, customVar)
	if canForceActiveItem(player) then
		WEB_HEART:AddWebHearts(player, -1)
		Mod.sfxman:Play(SoundEffect.SOUND_MEATY_DEATHS)
		player:SetPotatoPeelerUses(player:GetPotatoPeelerUses() + 1)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FAMILIARS, true)
		player:TakeDamage(1, DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 0)
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, WEB_HEART.PotatoPeelerUse, CollectibleType.COLLECTIBLE_POTATO_PEELER)

---@param player EntityPlayer
---@param postLevelInitFinished boolean
function WEB_HEART:EmptyHeartNewFloor(player, _, postLevelInitFinished)
	if Mod:IsAnyArachna(player)
		and postLevelInitFinished
		and WEB_HEART:GetWebHearts(player) == 0
		and player:HasCollectible(CollectibleType.COLLECTIBLE_EMPTY_HEART)
	then
		WEB_HEART:AddWebHearts(player, 1)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, WEB_HEART.EmptyHeartNewFloor)

--#endregion

--#region Devil Deals

local WEB_HEART_PRICES = Mod:Set({
	PickupPrice.PRICE_ONE_HEART,
	PickupPrice.PRICE_ONE_HEART_AND_ONE_SOUL_HEART,
	PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS,
	PickupPrice.PRICE_TWO_HEARTS
})

---The three soul hearts price is something that overrides the current price if you have no soul hearts,
---which in our case, shows up all the time if its just Arachna as they're a soul heart character,
---so we force the price manually
---@param pickup EntityPickup
function WEB_HEART:ForcePrice(pickup)
	if pickup.Price == PickupPrice.PRICE_THREE_SOULHEARTS
		and pickup.AutoUpdatePrice
		and WEB_HEART:AnyArachanaHasWebHearts()
	then
		local price = Mod.Room():GetShopItemPrice(pickup.Variant, pickup.SubType, pickup.ShopItemId)
		if WEB_HEART_PRICES[price] then
			if price == PickupPrice.PRICE_TWO_HEARTS and not WEB_HEART:AnyArachanaHasWebHearts(2) then
				price = PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS
			end
			pickup.Price = price
			pickup:GetPriceSprite():ReplaceSpritesheet(1, "gfx/items/shop/price_web.png", true)
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, CallbackPriority.EARLY, WEB_HEART.ForcePrice, PickupVariant.PICKUP_COLLECTIBLE)

---@param pickup EntityPickup
---@param player EntityPlayer
function WEB_HEART:TryPayWebHeartPrice(pickup, player)
	local webHearts = WEB_HEART:GetWebHearts(player)
	local webHeartRequirement = 1
	local soulHeartPrice = 0
	local price = pickup.Price
	if price == PickupPrice.PRICE_TWO_HEARTS then
		webHeartRequirement = 2
	end
	if webHearts < webHeartRequirement then
		return false
	end
	if price == PickupPrice.PRICE_ONE_HEART_AND_ONE_SOUL_HEART then
		soulHeartPrice = 2
	elseif price == PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS then
		soulHeartPrice = 4
	end
	pickup.Price = PickupPrice.PRICE_FREE
	WEB_HEART:AddWebHearts(player, -webHeartRequirement)
	if soulHeartPrice > 0 then
		player:AddSoulHearts(-soulHeartPrice)
	end
end

---@param pickup EntityPickup
---@param collider Entity
function WEB_HEART:OnDevilDealCollision(pickup, collider)
	local player = collider:ToPlayer()
	if player
		and Mod:IsAnyArachna(player)
		and WEB_HEART:GetWebHearts(player) > 0
		and WEB_HEART_PRICES[pickup.Price]
		and player:CanPickupItem()
		and player.ItemHoldCooldown == 0
		and player:IsExtraAnimationFinished()
		and not player:HasInstantDeathCurse()
	then
		WEB_HEART:TryPayWebHeartPrice(pickup, player)
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, WEB_HEART.OnDevilDealCollision, PickupVariant.PICKUP_COLLECTIBLE)
--[[
---@param pickup EntityPickup
function WEB_HEART:UpdateDevilSprite(pickup)
	if not pickup:IsShopItem() or pickup.Price >= 0 then return end
	local data = Mod:TryGetData(pickup)
	if data and data.UpdateWebHeartSheet or pickup.FrameCount == 0 then
		if SUPPORTED_VISUALS[pickup.Price] and WEB_HEART:AnyArachanaHasWebHearts() then
			pickup:GetPriceSprite():ReplaceSpritesheet(1, "gfx/items/shop/price_web.png", true)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_RENDER, WEB_HEART.UpdateDevilSprite, PickupVariant.PICKUP_COLLECTIBLE) ]]

--#endregion

--#region Dead Cat

---@param firstTime boolean
---@param player EntityPlayer
function ARACHNA:DeadCatCheck(_, _, firstTime, _, _, player)
	if Mod:IsAnyArachna(player) then
		Mod:GetData(player).DeadCat = true
		Mod:DelayOneFrame(function ()
			Mod:GetData(player).DeadCat = nil
		end)
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_ADD_COLLECTIBLE, CallbackPriority.LATE, ARACHNA.DeadCatCheck, CollectibleType.COLLECTIBLE_DEAD_CAT)

---@param player EntityPlayer
---@param amount integer
function ARACHNA:StopHealthRemoval(player, amount)
	local data = Mod:GetData(player)
	if Mod:IsAnyArachna(player) and data.DeadCat and not data.DeadCatBlock and amount < 0 then
		data.DeadCatBlock = true
		WEB_HEART:AddWebHearts(player, 1 - WEB_HEART:GetWebHearts(player))
		data.DeadCatBlock = nil
		data.DeadCat = nil
		return 0
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, ARACHNA.StopHealthRemoval, AddHealthType.SOUL)

--#endregion