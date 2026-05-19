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
		and requestedSubtype == 0
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

--#region Reverse Fool fix

--CustomHealthAPI spawns twice the required amount for some reason. Queue to remove duplicates
function WEB_HEART:BeforeReverseFool(card, player)
	local webHearts = WEB_HEART:GetWebHearts(player)
	if webHearts > 0 then
		local numToRemove = webHearts - 1
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
