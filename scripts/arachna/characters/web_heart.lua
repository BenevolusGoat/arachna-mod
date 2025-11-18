--#region Variables

local Mod = ARACHNAMOD

local WEB_HEART = {}

ARACHNAMOD.Pickup.WEB_HEART = WEB_HEART

WEB_HEART.ID = Isaac.GetEntitySubTypeByName("Web Heart")
WEB_HEART.ID_DOUBLE = Isaac.GetEntitySubTypeByName("Web Heart (Double)")
WEB_HEART.CLOT_FAMILIAR = Isaac.GetEntitySubTypeByName("Web Heart Baby")
WEB_HEART.PICKUP_SFX = SoundEffect.SOUND_SPIDER_SPIT_ROAR
WEB_HEART.KEY = "WEB_HEART"
WEB_HEART.KEY_ARACHNA = "WEB_HEART_ARACHNA"

WEB_HEART.HeartsToReplace = Mod:Set({
	HeartSubType.HEART_ETERNAL,
	HeartSubType.HEART_BONE,
	HeartSubType.HEART_ROTTEN
})
WEB_HEART.BLOCK_KEYS = Mod:Set({
	"BONE_HEART",
	"ETERNAL_HEART"
})

--For modded characters
WEB_HEART.KeeperCharacters = {}

local webHeartUI = Sprite()
webHeartUI:Load("gfx/web_heart_ui.anm2", true)

local SORT_ORDER_BONE = 50
local SORT_ORDER_SOUL = 100

local WEB_HEART_BASE = {
	AnimationFilename = "gfx/web_heart_ui.anm2",
	AnimationName = "UI",
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
}

local WEB_HEART_BONE = Mod:CopyTable(WEB_HEART_BASE)
WEB_HEART_BONE.SortOrder = SORT_ORDER_BONE
WEB_HEART_BONE.AddPriority = 0
WEB_HEART_BONE.RemovePriority = 110
WEB_HEART_BONE.ProtectsDealChance = false
WEB_HEART_BONE.CanHaveHalfCapacity = false
CustomHealthAPI.Library.RegisterHealthContainer(WEB_HEART.KEY_ARACHNA, WEB_HEART_BONE)

local WEB_HEART_SOUL = Mod:CopyTable(WEB_HEART_BASE)
WEB_HEART_SOUL.SortOrder = SORT_ORDER_SOUL
WEB_HEART_SOUL.AddPriority = 125
WEB_HEART_SOUL.AnimationName = { WEB_HEART_SOUL.AnimationName }
CustomHealthAPI.Library.RegisterSoulHealth(WEB_HEART.KEY, WEB_HEART_SOUL)

local NO_PENTALTY_FLAGS = DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_NO_PENALTIES

--#endregion

--#region Helpers

---@param key string
function WEB_HEART:IsWebHeart(key)
	return key == WEB_HEART.KEY or key == WEB_HEART.KEY_ARACHNA
end

---@param player EntityPlayer
function WEB_HEART:GetKey(player)
	local key = WEB_HEART.KEY
	if Mod:IsAnyArachna(player) and not Mod:IsLegacyGameplayEnabled() then
		key = WEB_HEART.KEY_ARACHNA
	end
	return key
end

---@param player EntityPlayer
---@param amount integer
function WEB_HEART:AddWebHearts(player, amount)
	local key = WEB_HEART:GetKey(player)
	if key == WEB_HEART.KEY then
		amount = Mod.math.floor(amount * 2)
	end
	CustomHealthAPI.Library.AddHealth(player, key, amount, false, false)
end

---@param player EntityPlayer
---@return boolean
function WEB_HEART:CanPickup(player)
	return CustomHealthAPI.Library.CanPickKey(player, WEB_HEART:GetKey(player))
end

---@param player EntityPlayer
---@return integer
function WEB_HEART:GetWebHearts(player)
	local key = WEB_HEART:GetKey(player)
	local amount = CustomHealthAPI.Library.GetHPOfKey(player, key, nil, nil, true)
	if key == WEB_HEART.KEY then
		amount = Mod.math.ceil(amount / 2)
	end
	return amount
end

--#endregion

--#region CustomHealthAPI

function WEB_HEART:UpdateHealthConversion()
	if Mod:IsLegacyGameplayEnabled() then
		CustomHealthAPI.PersistentData.CharactersThatConvertMaxHealth[Mod.PlayerType.ARACHNA] = Mod.Pickup.WEB_HEART.KEY
		CustomHealthAPI.PersistentData.CharactersThatConvertMaxHealth[Mod.PlayerType.ARACHNA_B] = Mod.Pickup.WEB_HEART.KEY
	else
		CustomHealthAPI.PersistentData.CharactersThatConvertMaxHealth[Mod.PlayerType.ARACHNA] = Mod.Pickup.WEB_HEART.KEY_ARACHNA
		CustomHealthAPI.PersistentData.CharactersThatConvertMaxHealth[Mod.PlayerType.ARACHNA_B] = Mod.Pickup.WEB_HEART.KEY_ARACHNA
	end
end

Mod:AddCallback(Mod.SaveManager.SaveCallbacks.POST_GLOBAL_DATA_LOAD, WEB_HEART.UpdateHealthConversion)

CustomHealthAPI.Library.AddCallback(ARACHNAMOD.CHAPI_ID, CustomHealthAPI.Enums.Callbacks.PRE_ADD_HEALTH,
	CustomHealthAPI.Enums.CallbackPriorities.EARLY,
	function(player, key, hp)
		local expectedKey = WEB_HEART:GetKey(player)
		--In case the incorrect heart is added
		if WEB_HEART:IsWebHeart(key) and key ~= expectedKey then
			if expectedKey == WEB_HEART.KEY then
				hp = Mod.math.floor(hp * 2)
			else
				hp = Mod.math.ceil(hp / 2)
			end
			return expectedKey, hp
			--Manually handle max HP so its identical to Forgor, 2:1 ratio of hearts
		elseif Mod:IsAnyArachna(player)
			and not Mod:IsLegacyGameplayEnabled()
			and CustomHealthAPI.Library.GetInfoOfKey(key, "Type") == CustomHealthAPI.Enums.HealthTypes.CONTAINER
			and CustomHealthAPI.Library.GetInfoOfKey(key, "KindContained") ~= CustomHealthAPI.Enums.HealthKinds.NONE
		then
			--Empty Heart to Web Heart conversion
			if CustomHealthAPI.Library.GetInfoOfKey(key, "MaxHP") <= 0 then
				local hpToAdd = math.ceil(hp)
				if CustomHealthAPI.PersistentData.HealthDefinitions[key].CanHaveHalfCapacity then
					hpToAdd = math.ceil(hpToAdd / 2)
				end
				return WEB_HEART.KEY_ARACHNA, hpToAdd
			elseif key == "BONE_HEART" then
				--Allow removing Bone Hearts to also remove Web Hearts
				--Also for continuing a run
				if hp < 0 or player.FrameCount == 0 then
					return expectedKey, hp
				--No bone hearts allowed otherwise
				else
					return true
				end
			end
		elseif Mod:IsAnyArachna(player) and WEB_HEART.BLOCK_KEYS[key] then
			return true
		end
	end)

CustomHealthAPI.Library.AddCallback(ARACHNAMOD.CHAPI_ID, CustomHealthAPI.Enums.Callbacks.PRE_RENDER_HEART, 0,
	function(player, index, health)
		if health.Key == WEB_HEART.KEY then
			if CustomHealthAPI.Helper.GetGoldenRenderMask(player)[index + 1] then
				return { AnimationFilename = "gfx/web_heart_ui.anm2", AnimationName = "UI_Gold" }
			end
		end
	end)

CustomHealthAPI.Library.AddCallback(ARACHNAMOD.CHAPI_ID, CustomHealthAPI.Enums.Callbacks.PRE_HEALTH_DAMAGED,
	CustomHealthAPI.Enums.CallbackPriorities.LATE,
	function(player, flags, _, _, key, hp, hpToRemove)
		if WEB_HEART:IsWebHeart(key) and hpToRemove >= hp then
			local numGoldens = CustomHealthAPI.Library.GetHPOfKey(player, "GOLDEN_HEART", nil, nil, true)
			local data = Mod:GetData(player)
			if numGoldens > 0 and not data.GoldenHeartsPreDamage then
				data.GoldenHeartsPreDamage = Mod.math.min(numGoldens, WEB_HEART:GetWebHearts(player))
				Isaac.CreateTimer(function() Mod:GetData(player).GoldenHeartsPreDamage = nil end, 1, 1, true)
			end
		end
	end)

CustomHealthAPI.Library.AddCallback(ARACHNAMOD.CHAPI_ID, CustomHealthAPI.Enums.Callbacks.POST_HEALTH_DAMAGED, 0,
	---@param player EntityPlayer
	function(player, flags, key, hpDamaged, wasDepleted, wasLastDamaged)
		if WEB_HEART:IsWebHeart(key) and wasDepleted then
			local spiderType = 0
			local data = Mod:GetData(player)
			if data.GoldenHeartsPreDamage then
				spiderType = Mod.Entities.COLORED_SPIDERS.SpiderSubtype.GOLDEN
				data.GoldenHeartsPreDamage = data.GoldenHeartsPreDamage - 1
				if data.GoldenHeartsPreDamage <= 0 then
					data.GoldenHeartsPreDamage = nil
				end
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
	if player:GetHealthType() == HealthType.COIN
		or WEB_HEART.KeeperCharacters[player:GetPlayerType()]
	then
		if pickup:IsShopItem() then
			return true
		end
		ARACHNAMOD:PickupKill(pickup)
		Mod.sfxman:Play(WEB_HEART.PICKUP_SFX)
		local amount = pickup.SubType == WEB_HEART.ID_DOUBLE and 4 or 2
		for _ = 1, amount do
			Mod.Entities.COLORED_SPIDERS:ThrowFriendlySpider(player, 0, pickup.Position)
		end
		return true
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.IMPORTANT, WEB_HEART.KeeperHeartCollision,
	PickupVariant.PICKUP_HEART)

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

	if ARACHNAMOD:PricedPickup(player, pickup) then
		Mod.sfxman:Play(WEB_HEART.PICKUP_SFX)
		local heartWorth = pickup.SubType == WEB_HEART.ID_DOUBLE and 2 or 1
		WEB_HEART:AddWebHearts(player, heartWorth)
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, WEB_HEART.CollectWebHeart,
	PickupVariant.PICKUP_HEART)

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
function WEB_HEART:ForceReplaceHearts(pickup)
	if WEB_HEART.HeartsToReplace[pickup.SubType] and Mod:EveryoneIsArachna() then
		local rng = pickup:GetDropRNG()
		Mod:DebugLog("Replaced heart subtype", pickup.SubType, "with Web Heart")
		if rng:RandomFloat() < 0.05 then
			pickup:Morph(pickup.Type, pickup.Variant, WEB_HEART.ID_DOUBLE, true, true)
		else
			pickup:Morph(pickup.Type, pickup.Variant, WEB_HEART.ID, true, true)
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_INIT, CallbackPriority.IMPORTANT, WEB_HEART.ForceReplaceHearts,
	PickupVariant.PICKUP_HEART)

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

Mod:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_INIT, CallbackPriority.IMPORTANT, WEB_HEART
.ReplaceWebHeartsForKeeper, PickupVariant.PICKUP_HEART)

--#endregion

--#region Abaddon (Legacy)

---@param player EntityPlayer
function WEB_HEART:Abaddon(itemID, charge, firstTime, slot, varData, player)
	local numWebHearts = WEB_HEART:GetWebHearts(player)
	if numWebHearts > 0 and Mod:IsLegacyGameplayEnabled() then
		player:AddBlackHearts(numWebHearts * 2)
		WEB_HEART:AddWebHearts(player, -numWebHearts)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, WEB_HEART.Abaddon, CollectibleType.COLLECTIBLE_ABADDON)

--#endregion

--#region Guppy's Paw (Legacy)

---@param player EntityPlayer
function WEB_HEART:ArachnaGuppysPaw(itemID, rng, player, flags, slot, customVar)
	if WEB_HEART:GetWebHearts(player) > 0
		and Mod:IsLegacyGameplayEnabled()
		and Mod:IsAnyArachna(player)
	then
		player:AddSoulHearts(6)
		WEB_HEART:AddWebHearts(player, -1)
		Mod.sfxman:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0, false, 0.8)
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, WEB_HEART.ArachnaGuppysPaw, CollectibleType.COLLECTIBLE_GUPPYS_PAW)

--#endregion

--#region Devil Deals (Purely visual)

local SUPPORTED_VISUALS = Mod:Set({
	PickupPrice.PRICE_ONE_HEART,
	PickupPrice.PRICE_ONE_HEART_AND_ONE_SOUL_HEART,
	PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS,
	PickupPrice.PRICE_TWO_HEARTS
})

---@param pickup EntityPickup
function WEB_HEART:UpdateDevilSprite(pickup)
	if not pickup:IsShopItem() or pickup.FrameCount > 0 then return end
	if SUPPORTED_VISUALS[pickup.Price] and Mod:EveryoneIsArachna() then
		pickup:GetPriceSprite():ReplaceSpritesheet(1, "gfx/items/shop/price_web.png", true)
	else
		pickup:GetPriceSprite():ReplaceSpritesheet(1, "gfx/items/shop/shop_001_bitfont.png", true)
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_RENDER, WEB_HEART.UpdateDevilSprite, PickupVariant.PICKUP_COLLECTIBLE)

--#endregion
