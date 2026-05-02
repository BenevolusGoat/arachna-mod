--#region Variables

local Mod = ArachnaMod

local WEB_HEART = {}

ArachnaMod.Pickup.WEB_HEART = WEB_HEART

WEB_HEART.ID = Isaac.GetEntitySubTypeByName("Web Heart")
WEB_HEART.ID_DOUBLE = Isaac.GetEntitySubTypeByName("Web Heart (Double)")
WEB_HEART.CLOT_FAMILIAR = Isaac.GetEntitySubTypeByName("Web Heart Baby")
WEB_HEART.PICKUP_SFX = SoundEffect.SOUND_SPIDER_SPIT_ROAR
WEB_HEART.KEY = "WEB_HEART"

WEB_HEART.REPLACEMENT_CHANCE = 0.2
WEB_HEART.DOUBLE_REPLACEMENT_CHANCE = 0.05

WEB_HEART.HeartsToReplace = Mod:Set({
	HeartSubType.HEART_ETERNAL,
	HeartSubType.HEART_BONE,
	HeartSubType.HEART_ROTTEN
})

local webHeartUI = Sprite()
webHeartUI:Load("gfx/web_heart_ui.anm2", true)

CustomHealthAPI.Library.RegisterSoulHealth(WEB_HEART.KEY, {
	SortOrder = 90,
	AddPriority = 125,
	AnimationFilename = "gfx/web_heart_ui.anm2",
	AnimationName = { "UI" },
	HealFlashRO = 240 / 255,
	HealFlashGO = 240 / 255,
	HealFlashBO = 240 / 255,
	MaxHP = 1,
	PrioritizeHealing = false,
	PickupEntities = {
		{ ID = EntityType.ENTITY_PICKUP, Var = PickupVariant.PICKUP_HEART, Sub = WEB_HEART.ID },
		{ ID = EntityType.ENTITY_PICKUP, Var = PickupVariant.PICKUP_HEART, Sub = WEB_HEART.ID_DOUBLE }
	},
	SumptoriumSubType = WEB_HEART.CLOT_FAMILIAR,
	SumptoriumSplatColor = Color(1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00),
	SumptoriumTrailColor = Color(1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00),
	SumptoriumCollectSoundSettings = {
		ID = SoundEffect.SOUND_MEAT_IMPACTS,
		Volume = 1.0,
		FrameDelay = 0,
		Loop = false,
		Pitch = 1.0,
		Pan = 0
	}
})

local NO_PENTALTY_FLAGS = DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_NO_PENALTIES

--#endregion

--#region Helpers

---@param player EntityPlayer
---@param amount integer
function WEB_HEART:AddWebHearts(player, amount)
	amount = Mod.math.floor(amount * 2)
	CustomHealthAPI.Library.AddHealth(player, WEB_HEART.KEY, amount, false, false)
end

---@param player EntityPlayer
---@return boolean
function WEB_HEART:CanPickup(player)
	return CustomHealthAPI.Library.CanPickKey(player, WEB_HEART.KEY)
end

---@param player EntityPlayer
---@return integer
function WEB_HEART:GetWebHearts(player)
	local key = WEB_HEART.KEY
	local amount = CustomHealthAPI.Library.GetHPOfKey(player, key, nil, nil, true)
	amount = Mod.math.ceil(amount / 2)
	return amount
end

---@param count? integer @Specify how many Web Hearts an Arachna needs to have
---@return EntityPlayer?
function WEB_HEART:AnyArachanaHasWebHearts(count)
	return Mod.Foreach.Player(function(player)
		if Mod:IsAnyArachna(player) and WEB_HEART:GetWebHearts(player) >= (count or 1) then
			return player
		end
	end)
end

--#endregion

--#region Overrides

local CHAPIGetEffectiveHearts = CustomHealthAPI.Helper.HookFunctions.GetEffectiveMaxHearts
---@param player EntityPlayer
function CustomHealthAPI.Helper.HookFunctions.GetEffectiveMaxHearts(player)
	if Mod:IsAnyArachna(player) and not CustomHealthAPI.Helper.PlayerIsIgnored(player) then
		return WEB_HEART:GetWebHearts(player) * 2
	end
	return CHAPIGetEffectiveHearts(player)
end

--#endregion

--#region CustomHealthAPI

CustomHealthAPI.Library.AddCallback(Mod.CHAPI_ID, CustomHealthAPI.Enums.Callbacks.PRE_ADD_HEALTH, 0, function (player, key, hp)
	if Mod:IsAnyArachna(player) and key == "EMPTY_HEART" then
		return WEB_HEART.KEY, hp
	end
end)

CustomHealthAPI.Library.AddCallback(Mod.CHAPI_ID, CustomHealthAPI.Enums.Callbacks.PRE_RENDER_HEART, 0,
	function(player, index, health)
		if health.Key == WEB_HEART.KEY then
			if CustomHealthAPI.Helper.GetGoldenRenderMask(player)[index + 1] then
				return { AnimationFilename = "gfx/web_heart_ui.anm2", AnimationName = "UI_Gold" }
			end
		end
	end)

CustomHealthAPI.Library.AddCallback(Mod.CHAPI_ID, CustomHealthAPI.Enums.Callbacks.PRE_HEALTH_DAMAGED,
	CustomHealthAPI.Enums.CallbackPriorities.EARLY,
	---@param player EntityPlayer
	function(player, flags, _, _, key, hp, hpToRemove)
		if key == WEB_HEART.KEY and hpToRemove >= hp then
			local numGoldens = CustomHealthAPI.Library.GetHPOfKey(player, "GOLDEN_HEART", false, false, true)
			local data = Mod:GetData(player)
			if numGoldens > 0 and not data.HadGoldenWebHeart then
				data.HadGoldenWebHeart = true
				Isaac.CreateTimer(function() Mod:GetData(player).HadGoldenWebHeart = nil end, 1, 1, true)
			end
			return 1
		end
	end)

CustomHealthAPI.Library.AddCallback(Mod.CHAPI_ID, CustomHealthAPI.Enums.Callbacks.POST_HEALTH_DAMAGED, 0,
	---@param player EntityPlayer
	function(player, flags, key, hpDamaged, wasDepleted, wasLastDamaged)
		if key == WEB_HEART.KEY and wasDepleted then
			local spiderType = 0
			local data = Mod:GetData(player)
			if data.HadGoldenWebHeart then
				spiderType = Mod.Entities.COLORED_SPIDERS.SpiderSubtype.GOLDEN
			end
			local rng = player:GetCollectibleRNG(Mod.Item.YARN_HEART.ID)
			for i = 1, Mod:RandomNum(2, 6, rng) do
				Mod.Entities.COLORED_SPIDERS:ThrowFriendlySpider(player, spiderType, player.Position)
			end
			--visual/sound effects
			local poof02 = Mod.Spawn.Poof02(0, player.Position, player)
			poof02:GetSprite().Color = Color(0, 1, 1, 0.5, 1, 1, 1)
			local splat = Mod.Spawn.Effect(EffectVariant.BLOOD_EXPLOSION, 0, player.Position, nil, player)
			splat:GetSprite().Color = Color(0, 1, 1, 0.5, 1, 1, 1)
			Mod.Game:SpawnParticles(player.Position, 5, Mod:RandomNum(5, 10), 4, Color(1, 1, 1, 1, 1, 1, 1))
			Mod.Game:ShakeScreen(16)
			Mod.sfxman:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.8, 0, false, 1.25)
			Mod.sfxman:Play(SoundEffect.SOUND_BOIL_HATCH)

			if Mod:IsAnyArachna(player) and not Mod:HasAnyBitFlags(flags, NO_PENTALTY_FLAGS) then
				Mod.Room():SetRedHeartDamage()
				Mod.Level():SetRedHeartDamage()
			end
		end
	end)

--#endregion

--#region On Collect

---@param pickup EntityPickup
---@param collider Entity
function WEB_HEART:KeeperHeartCollision(pickup, collider)
	local player = collider:ToPlayer()
	if not (player and (pickup.SubType == WEB_HEART.ID or pickup.SubType == WEB_HEART.ID_DOUBLE)) then
		return
	end
	if Mod:IsAnyKeeper(player) then
		if pickup:IsShopItem() then
			return true
		end
		ArachnaMod:PickupKill(pickup)
		Mod.sfxman:Play(WEB_HEART.PICKUP_SFX)
		local amount = pickup.SubType == WEB_HEART.ID_DOUBLE and 4 or 2
		for _ = 1, amount do
			Mod.Entities.COLORED_SPIDERS:ThrowFriendlySpider(player, 0, pickup.Position)
		end
		return true
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.IMPORTANT, WEB_HEART.KeeperHeartCollision, PickupVariant.PICKUP_HEART)

---@param pickup EntityPickup
---@param collider Entity
function WEB_HEART:CollectWebHeart(pickup, collider)
	local player = collider:ToPlayer()
	if not (player and (pickup.SubType == WEB_HEART.ID or pickup.SubType == WEB_HEART.ID_DOUBLE)) then
		return
	end
	if not WEB_HEART:CanPickup(player) then
		return pickup:IsShopItem()
	end

	if ArachnaMod:PricedPickup(player, pickup) then
		Mod.sfxman:Play(WEB_HEART.PICKUP_SFX)
		local heartWorth = pickup.SubType == WEB_HEART.ID_DOUBLE and 2 or 1
		WEB_HEART:AddWebHearts(player, heartWorth)
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, WEB_HEART.CollectWebHeart, PickupVariant.PICKUP_HEART)

--#endregion

--#region Replace Hearts

local function everyoneIsKeeper()
	local foundKeeper = false
	local noKeeper = Mod.Foreach.Player(function(player, index)
		if Mod:IsAnyKeeper(player) then
			foundKeeper = true
		elseif not player.Parent then
			return true
		end
	end)
	if noKeeper then
		return false
	else
		return foundKeeper
	end
end

---@param pickup EntityPickup
---@param variant PickupVariant
---@param subtype integer
---@param requestedVariant PickupVariant
---@param requestedSubtype integer
function WEB_HEART:ForceReplaceHearts(pickup, variant, subtype, requestedVariant, requestedSubtype)
	if variant == PickupVariant.PICKUP_HEART
		and WEB_HEART.HeartsToReplace[subtype]
		and Mod:EveryoneIsArachna()
	then
		local rng = pickup:GetDropRNG()
		Mod:DebugLog("Force-replaced heart subtype", subtype, "with Web Heart")
		if rng:RandomFloat() < WEB_HEART.DOUBLE_REPLACEMENT_CHANCE then
			return { PickupVariant.PICKUP_HEART, WEB_HEART.ID_DOUBLE, true }
		else
			return { PickupVariant.PICKUP_HEART, WEB_HEART.ID, true }
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_SELECTION, CallbackPriority.IMPORTANT, WEB_HEART.ForceReplaceHearts)

---@param pickup EntityPickup
function WEB_HEART:ReplaceWebHeartsForKeeper(pickup)
	if everyoneIsKeeper() and (pickup.SubType == WEB_HEART.ID or pickup.SubType == WEB_HEART.ID_DOUBLE) then
		Mod:DebugLog("Replaced Web Heart with blue spiders for Keeper character")
		local amount = pickup.SubType == WEB_HEART.ID_DOUBLE and 4 or 2
		for _ = 1, amount do
			local spider = Mod.Spawn.Familiar(FamiliarVariant.BLUE_SPIDER, 0, pickup.Position, nil, pickup)
			spider:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		end
		pickup:Remove()
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_INIT, CallbackPriority.IMPORTANT, WEB_HEART.ReplaceWebHeartsForKeeper, PickupVariant.PICKUP_HEART)

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

--#region Reverse Fool fix

--CustomHealthAPI spawns twice the required amount for some reason. Queue to remove duplicates
function WEB_HEART:BeforeReverseFool(card, player)
	if Mod:IsAnyArachna(player) then
		local numToRemove = WEB_HEART:GetWebHearts(player) - 1
		if numToRemove > 0 then
			Mod:GetData(player).WebHeartReverseFool = numToRemove
		end
	end
end

--IMPORTANT-1 to run before CHAPI
Mod:AddPriorityCallback(ModCallbacks.MC_USE_CARD, CallbackPriority.IMPORTANT - 1, WEB_HEART.BeforeReverseFool, Card.CARD_REVERSE_FOOL)

function WEB_HEART:OnReverseFool(card, player)
	local data = Mod:GetData(player)
	if data.WebHeartReverseFool then
		Mod.Foreach.Pickup(function(pickup)
			if pickup.FrameCount == 0 and Mod:IsSameEntity(player, pickup.SpawnerEntity) then
				pickup:Remove()
				data.WebHeartReverseFool = data.WebHeartReverseFool - 1
				if data.WebHeartReverseFool == 0 then return true end
			end
		end, PickupVariant.PICKUP_HEART, WEB_HEART.ID, { Inverse = true })
		data.WebHeartReverseFool = nil
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_USE_CARD, CallbackPriority.EARLY, WEB_HEART.OnReverseFool, Card.CARD_REVERSE_FOOL)

--#endregion

--#region Web Clot

---@param player EntityPlayer
---@param params TearParams
---@param source Entity
function WEB_HEART:WebClotFire(player, params, weaponType, scale, displacement, source)
	local familiar = source and source:ToFamiliar()
	if familiar
		and familiar.Variant == FamiliarVariant.BLOOD_BABY
		and familiar.SubType == WEB_HEART.CLOT_FAMILIAR
	then
		params.TearColor = Color(2, 2, 2, 1, 0.196, 0.196, 0.196)
		if player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SPIDER_BITE):RandomInt(4) + 1 == 1 then
			params.TearFlags = params.TearFlags | TearFlags.TEAR_SLOW
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, WEB_HEART.WebClotFire)

--#endregion
