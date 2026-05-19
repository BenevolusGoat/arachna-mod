local Mod = ArachnaMod
local persistGameData = Isaac.GetPersistentGameData()

local GOLDEN_SHOPKEEPER = {}

ArachnaMod.Entities.GOLDEN_SHOPKEEPER = GOLDEN_SHOPKEEPER

GOLDEN_SHOPKEEPER.ID = Isaac.GetEntityVariantByName("Golden Shopkeeper")

GOLDEN_SHOPKEEPER.SPRITES_NUM = 16
GOLDEN_SHOPKEEPER.MIN_BOMBS = 2
GOLDEN_SHOPKEEPER.MAX_BOMBS = 4
GOLDEN_SHOPKEEPER.REPLACEMENT_CHANCE = 0.075

GOLDEN_SHOPKEEPER.RewardType = {
	GOLDEN_TRINKET = 1,
	COUNTERFEIT_PENNY = 2,
	GOLDEN_SPIDERS = 3,
	MIDAS_TOUCH = 4
}
local WOP = WeightedOutcomePicker()
WOP:AddOutcomeFloat(GOLDEN_SHOPKEEPER.RewardType.GOLDEN_TRINKET, 0.1) --10%
WOP:AddOutcomeFloat(GOLDEN_SHOPKEEPER.RewardType.COUNTERFEIT_PENNY, 0.56) --56%
WOP:AddOutcomeFloat(GOLDEN_SHOPKEEPER.RewardType.GOLDEN_SPIDERS, 0.33) --33%
WOP:AddOutcomeFloat(GOLDEN_SHOPKEEPER.RewardType.MIDAS_TOUCH, 0.01) --1%

---@param npc EntityNPC
function GOLDEN_SHOPKEEPER:KeeperInit(npc)
	if npc.Variant == GOLDEN_SHOPKEEPER.ID then
		local sprite = npc:GetSprite()
		local rng = npc:GetDropRNG()
		if npc.SubType == 0 then
			npc.SubType = rng:RandomInt(GOLDEN_SHOPKEEPER.SPRITES_NUM) + 1
		end
		sprite:ReplaceSpritesheet(1, "gfx/effects/goldenshopkeepers/shopkeeper-" .. tostring(npc.SubType) .. ".png", true)
		local bombcrater = Mod.Spawn.Effect(EffectVariant.BOMB_CRATER, 0, npc.Position, nil, npc)
		bombcrater.Color = Color(0.9, 0.8, 0, 1, 0.8, 0.7, 0)
		bombcrater:Update()
		local run_save = Mod.SaveManager.GetRunSave(npc)
		if not run_save.GoldenKeeperMaxHits then
			run_save.GoldenKeeperMaxHits = Mod:RandomNum(GOLDEN_SHOPKEEPER.MIN_BOMBS, GOLDEN_SHOPKEEPER.MAX_BOMBS, npc:GetDropRNG())
			run_save.GoldenKeeperHits = run_save.GoldenKeeperMaxHits
			Mod:DebugLog("Golden Shopkeeper hits initialized. Needs", run_save.GoldenKeeperMaxHits, "hits to destroy")
		end
		npc:AddEntityFlags(EntityFlag.FLAG_NO_FLASH_ON_DAMAGE)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, GOLDEN_SHOPKEEPER.KeeperInit, EntityType.ENTITY_SHOPKEEPER)

---@param npc EntityNPC
function GOLDEN_SHOPKEEPER:UpdateAnimation(npc)
	local sprite = npc:GetSprite()
	if sprite:IsFinished("Bomb") then
		sprite:Play("Idle")
	elseif sprite:IsFinished("Break") then
		npc:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
	end
end

Mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, GOLDEN_SHOPKEEPER.UpdateAnimation, EntityType.ENTITY_SHOPKEEPER)

---@param npc EntityNPC
function GOLDEN_SHOPKEEPER:OnDamageEffect(npc)
	local rng = npc:GetDropRNG()
	local coinAmount = Mod:RandomNum(1, 2, rng)
	for _ = 1, coinAmount do
		Mod.Spawn.Coin(CoinSubType.COIN_PENNY, npc.Position, EntityPickup.GetRandomPickupVelocity(npc.Position, rng), npc)
	end
	npc:GetSprite():Play("Bomb", true)
	Mod.Game:SpawnParticles(npc.Position, EffectVariant.COIN_PARTICLE, Mod:RandomNum(7, 14), 4)
	Mod.sfxman:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.8)
end

---@param rng RNG
function GOLDEN_SHOPKEEPER:GetExtraReward(rng)
	local reward = WOP:PickOutcome(rng)
	if reward == GOLDEN_SHOPKEEPER.RewardType.GOLDEN_TRINKET
		and persistGameData:Unlocked(Achievement.GOLDEN_TRINKET)
	then
		return {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, Mod.Game:GetItemPool():GetTrinket() | TrinketType.TRINKET_GOLDEN_FLAG}
	elseif reward == GOLDEN_SHOPKEEPER.RewardType.COUNTERFEIT_PENNY
		and persistGameData:Unlocked(Achievement.COUNTERFEIT_PENNY)
	then
		local run_save = Mod.SaveManager.GetRunSave()
		if not run_save.SpawnedCounterfeitPenny then
			run_save.SpawnedCounterfeitPenny = true
			return {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_COUNTERFEIT_PENNY}
		end
	elseif reward == GOLDEN_SHOPKEEPER.RewardType.GOLDEN_SPIDERS then
		return {EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_SPIDER, Mod.Entities.COLORED_SPIDERS.SpiderSubtype.GOLDEN}
	elseif reward == GOLDEN_SHOPKEEPER.RewardType.MIDAS_TOUCH then
		return {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_MIDAS_TOUCH}
	end
	return {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0}
end

---@param npc EntityNPC
function GOLDEN_SHOPKEEPER:OnDeath(npc)
	local rng = npc:GetDropRNG()
	npc:GetSprite():Play("Break")
	local coinAmount = Mod:RandomNum(3, 5, rng)
	for _ = 1, coinAmount do
		Mod.Spawn.Coin(0, npc.Position, EntityPickup.GetRandomPickupVelocity(npc.Position, rng), npc)
	end
	local extraReward = GOLDEN_SHOPKEEPER:GetExtraReward(rng)
	if extraReward[1] == EntityType.ENTITY_FAMILIAR then
		for i = 1, 2 do
			Mod.Entities.COLORED_SPIDERS:ThrowFriendlySpider(Isaac.GetPlayer(), extraReward[3], npc.Position)
		end
	else
		local pos = Mod.Room():FindFreePickupSpawnPosition(npc.Position)
		local vel = extraReward[2] == PickupVariant.PICKUP_COIN and EntityPickup.GetRandomPickupVelocity(npc.Position, rng) or Vector.Zero
		Mod.Game:Spawn(extraReward[1], extraReward[2], pos, vel, npc, extraReward[3], rng:Next())
	end
	npc:GetSprite():Play("Break")
	Mod.sfxman:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY, 0.8)
	Mod.sfxman:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.8)
	Mod.Game:SpawnParticles(npc.Position, EffectVariant.COIN_PARTICLE, Mod:RandomNum(7, 14), 4)
	Mod.Game:ShakeScreen(8)
	Mod.Game:GetLevel():SetStateFlag(LevelStateFlag.STATE_SHOPKEEPER_KILLED_LVL, true)
end

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function GOLDEN_SHOPKEEPER:ShopkeeperTakeDamage(ent, amount, flags, source, countdown)
	if ent.Variant == GOLDEN_SHOPKEEPER.ID then
		local npc = ent:ToNPC() ---@cast npc EntityNPC
		local run_save = Mod.SaveManager.GetRunSave(npc)
		if not Mod:HasAnyBitFlags(flags, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_CRUSH) or npc:GetDamageCountdown() > 0 then
			return false
		end
		if run_save.GoldenKeeperHits and run_save.GoldenKeeperHits > 1 then
			run_save.GoldenKeeperHits = run_save.GoldenKeeperHits - 1
			GOLDEN_SHOPKEEPER:OnDamageEffect(npc)
			Mod:DebugLog(run_save.GoldenKeeperHits, "hit(s) remaining")
			local dmgCountdown = 20
			if Mod:HasBitFlags(flags, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_CRUSH) then
				dmgCountdown = 0
			end
			return { Damage = 0, DamageFlags = flags | DamageFlag.DAMAGE_COUNTDOWN, DamageCountdown = dmgCountdown }
		elseif not ent:GetSprite():IsPlaying("Break") then
			GOLDEN_SHOPKEEPER:OnDeath(npc)
			return false
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, GOLDEN_SHOPKEEPER.ShopkeeperTakeDamage, EntityType.ENTITY_SHOPKEEPER)

---@param npc EntityNPC
function GOLDEN_SHOPKEEPER:StopDeathEffect(npc)
	if npc.Variant == GOLDEN_SHOPKEEPER.ID and npc:IsDead() then
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, GOLDEN_SHOPKEEPER.StopDeathEffect, EntityType.ENTITY_SHOPKEEPER)
