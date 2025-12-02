--#region Variables

local Mod = ARACHNAMOD

local GEPTAMERON = {}

ARACHNAMOD.Item.GEPTAMERON = GEPTAMERON

GEPTAMERON.ID = Isaac.GetItemIdByName("Geptameron")
GEPTAMERON.OVERLAY = Isaac.GetGiantBookIdByName("Geptameron")

GEPTAMERON.TUESDAY_NULL_ITEM = Isaac.GetNullItemIdByName("geptameron tuesday")
GEPTAMERON.SATURDAY_NULL_ITEM = Isaac.GetNullItemIdByName("geptameron saturday")

GEPTAMERON.EPIC_FETUS_FREQUENCY = 30

GEPTAMERON.GAPER_FREQUENCY = 30
GEPTAMERON.GAPER_ROTTEN_HEART_CHANCE = 0.1

GEPTAMERON.CHARM_DURATION = 30 * 10 --10 seconds
GEPTAMERON.LOCUST_DROP_CHANCE = 0.5
GEPTAMERON.LOCUST_SPAWN_NUM = 3

---@enum GeptameronWeek
GEPTAMERON.WeekEffect = {
	MONDAY = 0,  		--Reveal Secret, Super Secret, Dad's Key
	TUESDAY = 1,		--Spawns temporary Dead Isaac-looking friendly gapers. Die+may drop rotten heart on room clear
	WEDNESDAY = 2,		--50/50 for long charm or locust on death
	THURSDAY = 3,		--2 Guardian Angels + 1-room mantle
	FRIDAY = 4,			--All enemies currently in the room will gain a status that have them drop coins on death, similarly to T. Keeper
	SATURDAY = 5,		--Missiles fall from random locations for 10 seconds
	SUNDAY = 6,			--1-3 enemies will gain an effect that has them drop a sack on death. Works like Death's List, moving to another enemy when one with effect dies
	NUM_EFFECTS = 7
}

GEPTAMERON.WeekName = {
	[GEPTAMERON.WeekEffect.MONDAY] = "Mighty Monday",
	[GEPTAMERON.WeekEffect.TUESDAY] = "Terrific Tuesday",
	[GEPTAMERON.WeekEffect.WEDNESDAY] = "Wise Wednesday",
	[GEPTAMERON.WeekEffect.THURSDAY] = "Torrid Thursday",
	[GEPTAMERON.WeekEffect.FRIDAY] = "Fleeting Friday",
	[GEPTAMERON.WeekEffect.SATURDAY] = "Sanguineous Saturday",
	[GEPTAMERON.WeekEffect.SUNDAY] = "Stingy Sunday"
}

local weekCircle = Sprite("gfx/ui/hud_geptameron.anm2", true)
weekCircle:SetFrame("Idle", 0)

local coinIcon = Sprite("gfx/geptameron_ui.anm2", false)
coinIcon:Play("Coin")
local coinIdentifier = "ARACHNA_TEMPCOINS"
GEPTAMERON.STATUS_COIN_CONFIG = StatusEffectLibrary.RegisterStatusEffect(coinIdentifier, coinIcon, nil, nil, true)
GEPTAMERON.STATUS_COIN = StatusEffectLibrary.StatusFlag[coinIdentifier]

local sackIcon = Sprite("gfx/geptameron_ui.anm2", false)
sackIcon:Play("Sack")
local sackIdentifier = "ARACHNA_SACKS"
GEPTAMERON.STATUS_SACK_CONFIG = StatusEffectLibrary.RegisterStatusEffect(sackIdentifier, sackIcon, nil, nil, true)
GEPTAMERON.STATUS_SACK = StatusEffectLibrary.StatusFlag[sackIdentifier]

local WOP = WeightedOutcomePicker()
WOP:AddOutcomeFloat(PickupVariant.PICKUP_KEY, 0.35)
WOP:AddOutcomeFloat(PickupVariant.PICKUP_COIN, 0.27)
WOP:AddOutcomeFloat(PickupVariant.PICKUP_BOMB, 0.26)
WOP:AddOutcomeFloat(PickupVariant.PICKUP_TAROTCARD, 0.07)
WOP:AddOutcomeFloat(PickupVariant.PICKUP_LIL_BATTERY, 0.06)
GEPTAMERON.SACK_WOP = WOP

local locustIcon = Sprite("gfx/geptameron_ui.anm2", false)
locustIcon:Play("Locust")
local locustIdentifier = "ARACHNA_LOCUSTS"
GEPTAMERON.STATUS_LOCUST_CONFIG = StatusEffectLibrary.RegisterStatusEffect(locustIdentifier, locustIcon, nil, nil, true)
GEPTAMERON.STATUS_LOCUST = StatusEffectLibrary.StatusFlag[locustIdentifier]

--#endregion

--#region Helpers

---@return GeptameronWeek
function GEPTAMERON:GetDayOfTheWeek()
	local run_save = Mod.SaveManager.GetRunSave()
	if not run_save.GeptameronWeek then
		run_save.GeptameronWeek = 0
	end
	return run_save.GeptameronWeek
end

--#endregion

--#region On Use

---@param source EntityRef
---@param rng RNG
---@param amount integer
function GEPTAMERON:ApplySackToRandomEnemy(source, rng, amount)
	local npcs = {}
	Mod.Foreach.NPC(function (npc, index)
		Mod.Insert(npcs, npc)
	end, nil, nil, nil, {UseEnemySearchParams = true, NoCollision = true})
	for _ = 1, amount do
		local index = rng:RandomInt(#npcs) + 1
		local npc = npcs[index]
		if not npc then
			break
		end
		StatusEffectLibrary:AddStatusEffect(npc, GEPTAMERON.STATUS_SACK, -1, source)
		table.remove(npcs, index)
	end
end

---@param player EntityPlayer
---@param week GeptameronWeek
function GEPTAMERON:ActivateEffect(player, week)
	if week == GEPTAMERON.WeekEffect.MONDAY then
		Mod.Card.MERGED_CARD:DisplayRoomType(RoomType.ROOM_SECRET, RoomType.ROOM_SUPERSECRET)
		player:UseActiveItem(CollectibleType.COLLECTIBLE_DADS_KEY)
	elseif week == GEPTAMERON.WeekEffect.TUESDAY then
		local effects = Mod.Room():GetEffects()
		effects:AddNullEffect(GEPTAMERON.TUESDAY_NULL_ITEM)
	elseif week == GEPTAMERON.WeekEffect.WEDNESDAY then
		local rng = player:GetCollectibleRNG(GEPTAMERON.ID)
		local source = EntityRef(player)
		if rng:RandomFloat() < 0.5 then
			Mod.Foreach.NPC(function (npc, index)
				npc:AddCharmed(source, GEPTAMERON.CHARM_DURATION)
			end, nil, nil, nil, {UseEnemySearchParams = true, NoCollision = true})
		else
			Mod.Foreach.NPC(function (npc, index)
				StatusEffectLibrary:AddStatusEffect(npc, GEPTAMERON.STATUS_LOCUST, -1, source)
			end, nil, nil, nil, {UseEnemySearchParams = true, NoCollision = true})
		end
	elseif week == GEPTAMERON.WeekEffect.THURSDAY then
		player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_GUARDIAN_ANGEL, true, 2)
		player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, true)
	elseif week == GEPTAMERON.WeekEffect.FRIDAY then
		local source = EntityRef(player)
		Mod.Foreach.NPC(function (npc, index)
			StatusEffectLibrary:AddStatusEffect(npc, GEPTAMERON.STATUS_COIN, -1, source)
		end, nil, nil, nil, {UseEnemySearchParams = true, NoCollision = true})
	elseif week == GEPTAMERON.WeekEffect.SATURDAY then
		local effects = Mod.Room():GetEffects()
		effects:AddNullEffect(GEPTAMERON.SATURDAY_NULL_ITEM)
	elseif week == GEPTAMERON.WeekEffect.SUNDAY then
		local source = EntityRef(player)
		local rng = player:GetCollectibleRNG(GEPTAMERON.ID)
		GEPTAMERON:ApplySackToRandomEnemy(source, rng, rng:RandomInt(3) + 1)
	end
end

---@param itemId CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param useFlags UseFlag
---@param slot ActiveSlot
---@param customVarData integer
function GEPTAMERON:OnUse(itemId, rng, player, useFlags, slot, customVarData)
	if Mod.GetSetting(Mod.Setting.GeptameronGiantbook)
		and not Mod:HasBitFlags(useFlags, UseFlag.USE_NOHUD)
		and (not Mod:HasBitFlags(useFlags, UseFlag.USE_OWNED) or player:GetEffects():GetCollectibleEffectNum(GEPTAMERON.ID) == 0)
	then
		ItemOverlay.Show(GEPTAMERON.OVERLAY, 3, player)
	end
	Mod.sfxman:Play(SoundEffect.SOUND_SUPERHOLY)
	local week = Mod:HasBitFlags(useFlags, UseFlag.USE_CUSTOMVARDATA) and customVarData or player:GetActiveItemDesc(slot).VarData
	GEPTAMERON:ActivateEffect(player, week)
	if not Mod:HasBitFlags(useFlags, UseFlag.USE_NOHUD) then
		Mod.Game:GetHUD():ShowItemText(GEPTAMERON.WeekName[week])
	end
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, GEPTAMERON.OnUse, GEPTAMERON.ID)

--#endregion

--#region Update sprite

---@param player EntityPlayer
---@param slot ActiveSlot
---@param alpha number
---@param scale number
function GEPTAMERON:RenderCurrentDay(player, slot, offset, alpha, scale, chargebarOffset)
	local varData = player:GetActiveItemDesc(slot).VarData
	weekCircle:SetFrame(varData)
	weekCircle.Color.A = alpha
	weekCircle.Scale = Vector(scale, scale)
	weekCircle:Render(offset)
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, GEPTAMERON.RenderCurrentDay, GEPTAMERON.ID)

function GEPTAMERON:UpdateVarDataOnCollectibleAdd(itemId, charge, firstTime, slot, varData, player)
	player:SetActiveVarData(GEPTAMERON:GetDayOfTheWeek(), slot)
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, GEPTAMERON.UpdateVarDataOnCollectibleAdd)

--#endregion

--#region Update day on room clear/greed wave

function GEPTAMERON:OnRoomClear()
	if not PlayerManager.AnyoneHasCollectible(GEPTAMERON.ID) then return end
	local nextDay = GEPTAMERON:GetDayOfTheWeek() + 1
	if nextDay >= GEPTAMERON.WeekEffect.NUM_EFFECTS then
		nextDay = GEPTAMERON.WeekEffect.MONDAY
	end
	local run_save = Mod.SaveManager.GetRunSave()
	run_save.GeptameronWeek = nextDay
	Mod.Foreach.Player(function (player, index)
		local slots = Mod:GetActiveItemSlots(player, GEPTAMERON.ID)
		for _, slot in ipairs(slots) do
			player:SetActiveVarData(nextDay, slot)
		end
	end)
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, CallbackPriority.LATE, GEPTAMERON.OnRoomClear)
Mod:AddCallback(ModCallbacks.MC_POST_START_GREED_WAVE, GEPTAMERON.OnRoomClear)

--#endregion

--#region Room TempEffect effects

function GEPTAMERON:TimeBasedEffectsOnUpdate()
	local room = Mod.Room()
	local effects = room:GetEffects()
	if effects:HasNullEffect(GEPTAMERON.SATURDAY_NULL_ITEM) then
		local cooldown = effects:GetNullEffect(GEPTAMERON.SATURDAY_NULL_ITEM).Cooldown
		if cooldown % GEPTAMERON.EPIC_FETUS_FREQUENCY == 0 and cooldown > 0 then
			local pos = room:GetRandomPosition(40)
			local target = Mod.Spawn.Effect(EffectVariant.TARGET, 0, pos)
			target:SetTimeout(60)
			target.State = 1
		end
	end
	if effects:HasNullEffect(GEPTAMERON.TUESDAY_NULL_ITEM) then
		local cooldown = effects:GetNullEffect(GEPTAMERON.TUESDAY_NULL_ITEM).Cooldown
		if cooldown % GEPTAMERON.GAPER_FREQUENCY == 0 and cooldown > 0 then
			local pos = Isaac.GetFreeNearPosition(room:GetRandomPosition(40), 0)
			local gaper = Mod.Game:Spawn(EntityType.ENTITY_GAPER, 1, pos, Vector.Zero, Isaac.GetPlayer(), 0, Random())
			local sprite = gaper:GetSprite()
			sprite:Load(EntityConfig.GetEntity(EntityType.ENTITY_MOTHER, 20, 0):GetAnm2Path(), true)
			sprite:Play("Appear", true)
			gaper:AddCharmed(EntityRef(nil), -1)
			Mod:GetData(gaper).GeptameronGaper = true
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, GEPTAMERON.TimeBasedEffectsOnUpdate)

---@param npc EntityNPC
function GEPTAMERON:KillGaper(npc)
	if npc:GetDropRNG():RandomFloat() < GEPTAMERON.GAPER_ROTTEN_HEART_CHANCE then
		local pos = Mod.Room():FindFreePickupSpawnPosition(npc.Position)
		Mod.Spawn.Heart(HeartSubType.HEART_ROTTEN, pos, nil, npc, npc.DropSeed)
	end
	Mod.sfxman:Play(SoundEffect.SOUND_DEATH_BURST_SMALL)
	npc:BloodExplode()
	npc:Remove()
end

function GEPTAMERON:KillGapersOnRoomClear()
	Mod.Foreach.NPC(function (npc, index)
		local data = Mod:TryGetData(npc)
		if data and data.GeptameronGaper then
			GEPTAMERON:KillGaper(npc)
		end
	end, EntityType.ENTITY_GAPER, 1, 0, {Inverse = true})
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, CallbackPriority.LATE, GEPTAMERON.KillGapersOnRoomClear)

function GEPTAMERON:RemoveGapersOnGameExit()
	Mod.Foreach.NPC(function (npc, index)
		local data = Mod:TryGetData(npc)
		if data and data.GeptameronGaper then
			npc:ClearEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY)
		end
	end, EntityType.ENTITY_GAPER, 1, 0, {Inverse = true})
end

Mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, GEPTAMERON.RemoveGapersOnGameExit)

function GEPTAMERON:StopDeathEffects(npc)
	local data = Mod:TryGetData(npc)
	if data and data.GeptameronGaper and npc:IsDead() then
		GEPTAMERON:KillGaper(npc)
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, GEPTAMERON.StopDeathEffects, EntityType.ENTITY_GAPER)

---@param npc EntityNPC
function GEPTAMERON:FixGaperHeads(npc)
	local data = Mod:TryGetData(npc)
	if data and data.GeptameronGaper then
		local sprite = npc:GetSprite()
		if not sprite:IsPlaying("Appear") and not sprite:IsOverlayPlaying() then
			sprite:PlayOverlay("Head")
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, GEPTAMERON.FixGaperHeads, EntityType.ENTITY_GAPER)

--#endregion

--#region Status effects

---@param npc EntityNPC
function GEPTAMERON:CanAddStatus(npc)
	return not npc:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN)
		and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
		and not npc:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
		and npc:IsActiveEnemy(false)
		and npc:IsVulnerableEnemy()
end

---@param ent Entity
function GEPTAMERON:PreAddStatus(ent)
	local npc = ent:ToNPC()
	if not npc or not GEPTAMERON:CanAddStatus(npc) then
		return true
	end
end

StatusEffectLibrary.Callbacks.AddCallback(StatusEffectLibrary.Callbacks.ID.PRE_ADD_ENTITY_STATUS_EFFECT, GEPTAMERON.PreAddStatus, GEPTAMERON.STATUS_SACK)
StatusEffectLibrary.Callbacks.AddCallback(StatusEffectLibrary.Callbacks.ID.PRE_ADD_ENTITY_STATUS_EFFECT, GEPTAMERON.PreAddStatus, GEPTAMERON.STATUS_COIN)

---@param ent Entity
function GEPTAMERON:OnNPCKill(ent)
	if StatusEffectLibrary:HasStatusEffect(ent, GEPTAMERON.STATUS_SACK) then
		Mod:GetData(ent).QueueSackDrop = true
	end
	if StatusEffectLibrary:HasStatusEffect(ent, GEPTAMERON.STATUS_COIN) then
		Mod:GetData(ent).QueueCoinDrop = true
	end
	if StatusEffectLibrary:HasStatusEffect(ent, GEPTAMERON.STATUS_LOCUST) then
		Mod:GetData(ent).QueueLocustDrop = true
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, GEPTAMERON.OnNPCKill)

---@param npc EntityNPC
function GEPTAMERON:OnNPCDeath(npc)
	local data = Mod:GetData(npc)
	local rng = npc:GetDropRNG()
	if data.QueueSackDrop then
		local vel = EntityPickup.GetRandomPickupVelocity(npc.Position, rng)
		local pickupVariant = WOP:PickOutcome(rng)
		local pickup = Mod.Spawn.Pickup(pickupVariant, 0, npc.Position, vel, npc, rng:Next())
		pickup.Timeout = 60
		GEPTAMERON:ApplySackToRandomEnemy(EntityRef(npc), rng, 1)
	end
	if data.QueueCoinDrop then
		if npc.SpawnerType == EntityType.ENTITY_NULL or rng:RandomFloat() < 0.5 then
			local coinAmount = rng:RandomInt(1, 4)
			local vel = EntityPickup.GetRandomPickupVelocity(npc.Position, rng)
			for i = 1, coinAmount do
				local coin = Mod.Spawn.Coin(0, npc.Position, vel, npc, rng:Next())
				coin.Timeout = 45
			end
		end
		Mod.Game:SpawnParticles(npc.Position, EffectVariant.COIN_PARTICLE, Mod:RandomNum(4, 7), 4)
		Mod.sfxman:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.6)
	end
	if data.QueueLocustDrop then
		for i = 1, GEPTAMERON.LOCUST_SPAWN_NUM do
			local locust = rng:RandomInt(1, 5)
			Mod.Game:Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, npc.Position, Vector.Zero, nil, locust, rng:Next())
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, GEPTAMERON.OnNPCDeath)

--#endregion