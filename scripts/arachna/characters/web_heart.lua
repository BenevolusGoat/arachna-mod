--#region Variables

local Mod = ARACHNAMOD

local WEB_HEART = {}

ARACHNAMOD.Pickup.WEB_HEART = WEB_HEART

WEB_HEART.ID = Isaac.GetEntitySubTypeByName("Web Heart")
WEB_HEART.ID_DOUBLE = Isaac.GetEntitySubTypeByName("Web Heart (Double)")
WEB_HEART.CLOT_FAMILIAR = Isaac.GetEntitySubTypeByName("Web Heart Baby")
WEB_HEART.PICKUP_SFX = SoundEffect.SOUND_SPIDER_SPIT_ROAR
WEB_HEART.KEY = "WEB_HEART"

WEB_HEART.HeartsToReplace = Mod:Set({
	HeartSubType.HEART_ETERNAL,
	HeartSubType.HEART_BONE,
	HeartSubType.HEART_ROTTEN
})

--For modded characters
WEB_HEART.KeeperCharacters = {}

local webHeartUI = Sprite()
webHeartUI:Load("gfx/web_heart_ui.anm2", true)

---@param player EntityPlayer
---@param amount integer
function WEB_HEART:AddWebHearts(player, amount)
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
	return CustomHealthAPI.Library.GetHPOfKey(player, WEB_HEART.KEY, nil, nil, true)
end

CustomHealthAPI.Library.RegisterSoulHealth(
    WEB_HEART.KEY,
    {
        AnimationFilename = "gfx/web_heart_ui.anm2",
        AnimationName = {"UI"},
        SortOrder = 100,
        AddPriority = 125,
        HealFlashRO = 240/255,
        HealFlashGO = 240/255,
        HealFlashBO = 240/255,
        MaxHP = 1,
        PrioritizeHealing = false,
        PickupEntities = {
            {ID = EntityType.ENTITY_PICKUP, Var = PickupVariant.PICKUP_HEART, Sub = WEB_HEART.ID},
            {ID = EntityType.ENTITY_PICKUP, Var = PickupVariant.PICKUP_HEART, Sub = WEB_HEART.ID_DOUBLE}
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
)

--#endregion

--#region CustomHealthAPI

CustomHealthAPI.Library.AddCallback(ARACHNAMOD.CHAPI_ID, CustomHealthAPI.Enums.Callbacks.PRE_RENDER_HEART, 0, function (player,index,health)
    if health.Key == WEB_HEART.KEY then
        if CustomHealthAPI.Helper.GetGoldenRenderMask(player)[index+1] then
            return {AnimationFilename = "gfx/web_heart_ui.anm2", AnimationName = "UI_Gold"}
        end
    end
end)

CustomHealthAPI.Library.AddCallback(ARACHNAMOD.CHAPI_ID, CustomHealthAPI.Enums.Callbacks.PRE_HEALTH_DAMAGED, CustomHealthAPI.Enums.CallbackPriorities.LATE,
	function (player, flags, _, _, key, hp, hpToRemove)
		if key == WEB_HEART.KEY and hpToRemove >= hp then
			local numGoldens = CustomHealthAPI.Library.GetHPOfKey(player, "GOLDEN_HEART", nil, nil, true)
			local data = Mod:GetData(player)
			if numGoldens > 0 and not data.GoldenHeartsPreDamage then
				data.GoldenHeartsPreDamage = Mod.math.min(numGoldens, WEB_HEART:GetWebHearts(player))
				Isaac.CreateTimer(function() Mod:GetData(player).GoldenHeartsPreDamage = nil end, 1, 1, true)
			end
		end
	end
)

CustomHealthAPI.Library.AddCallback(ARACHNAMOD.CHAPI_ID, CustomHealthAPI.Enums.Callbacks.POST_HEALTH_DAMAGED, 0,
	---@param player EntityPlayer
	function(player, flags, key, hpDamaged, wasDepleted, wasLastDamaged)
		if key == WEB_HEART.KEY and wasDepleted then
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
				Mod.Entities.COLORED_SPIDERS:ThrowColoredSpider(player, spiderType, player.Position)
			end
			--visual/sound effects
			local poof02 = Mod.Spawn.Poof02(0, player.Position, player)
			poof02:GetSprite().Color = Color(0, 1, 1, 0.5, 1, 1, 1)
			poof02.DepthOffset = 250
			poof02:Update()
			local splat = Mod.Spawn.Effect(EffectVariant.BLOOD_EXPLOSION, 0, player.Position, nil, player)
			splat:GetSprite().Color = Color(0, 1, 1, 0.5, 1, 1, 1)
			splat.DepthOffset = 250
			splat:Update()
			Mod.Game:SpawnParticles(player.Position, 5, Mod:RandomNum(5, 10), 4, Color(1, 1, 1, 1, 1, 1, 1))
			Mod.Game:ShakeScreen(16)
			Mod.sfxman:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.8, 0, false, 1.25)
			Mod.sfxman:Play(SoundEffect.SOUND_BOIL_HATCH)
			--fake damage
			Mod.Level():SetStateFlag(LevelStateFlag.STATE_DAMAGED, true) --for perfection
			player:SetMinDamageCooldown(60)
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
			Mod.Entities.COLORED_SPIDERS:ThrowColoredSpider(player, 0, pickup.Position)
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

	if ARACHNAMOD:PricedPickup(player, pickup) then
		Mod.sfxman:Play(WEB_HEART.PICKUP_SFX)
		local heartWorth = pickup.SubType == WEB_HEART.ID_DOUBLE and 4 or 2
		WEB_HEART:AddWebHearts(player, heartWorth)
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, WEB_HEART.CollectWebHeart, PickupVariant.PICKUP_HEART)

--#endregion

--#region Replace Hearts

local function everyoneIsKeeper()
	local foundKeeper = false
	local noKeeper = Mod.Foreach.Player(function (player, index)
		if player:GetHealthType() == HealthType.COIN or WEB_HEART.KeeperCharacters[player:GetPlayerType()] then
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

local function everyoneIsArachna()
	local foundArachna = false
	local noArachna = Mod.Foreach.Player(function (player, index)
		if Mod.Character.ARACHNA:IsAnyArachna(player) then
			foundArachna = true
		elseif not player.Parent then
			return true
		end
	end)
	if noArachna then
		return false
	else
		return foundArachna
	end
end

---@param pickup EntityPickup
function WEB_HEART:ForceReplaceHearts(pickup)
	if WEB_HEART.HeartsToReplace[pickup.SubType] and everyoneIsArachna() then
		local rng = pickup:GetDropRNG()
		Mod:DebugLog("Replaced heart subtype", pickup.SubType, "with Web Heart")
		if rng:RandomFloat() < 0.05 then
			pickup:Morph(pickup.Type, pickup.Variant, WEB_HEART.ID_DOUBLE, true, true)
		else
			pickup:Morph(pickup.Type, pickup.Variant, WEB_HEART.ID, true, true)
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_INIT, CallbackPriority.IMPORTANT, WEB_HEART.ForceReplaceHearts, PickupVariant.PICKUP_HEART)

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
	if numWebHearts > 0 then
		player:AddBlackHearts(numWebHearts * 2)
		WEB_HEART:AddWebHearts(player, -numWebHearts)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, WEB_HEART.Abaddon, CollectibleType.COLLECTIBLE_ABADDON)

--#endregion

--#region Guppy's Paw

---@param player EntityPlayer
function WEB_HEART:ArachnaGuppysPaw(itemID, rng, player, flags, slot, customVar)
	local playerType = player:GetPlayerType()
	if WEB_HEART:GetWebHearts(player) > 0
		and (playerType == Mod.PlayerType.ARACHNA or playerType == Mod.PlayerType.ARACHNA_B)
	then
		player:AddSoulHearts(6)
		WEB_HEART:AddWebHearts(player, -1)
		Mod.sfxman:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0, false, 0.8)
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, WEB_HEART.ArachnaGuppysPaw, CollectibleType.COLLECTIBLE_GUPPYS_PAW)

--#endregion