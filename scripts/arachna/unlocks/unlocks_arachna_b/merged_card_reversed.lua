--#region Variables

local Mod = ArachnaMod

local MERGED_CARD_REVERSED = {}

ArachnaMod.Card.MERGED_CARD_REVERSED = MERGED_CARD_REVERSED

MERGED_CARD_REVERSED.ID = Isaac.GetCardIdByName("Merged Card?")
MERGED_CARD_REVERSED.SFX = Isaac.GetSoundIdByName("Merged Card?")

MERGED_CARD_REVERSED.NUM_EFFECTS = 2

MERGED_CARD_REVERSED.REVERSE_EMPRESS_NULL_ITEM = Isaac.GetNullItemIdByName("reversed merged card empress")
MERGED_CARD_REVERSED.REVERSE_LOVERS_NULL_ITEM = Isaac.GetNullItemIdByName("reversed merged card lovers")
MERGED_CARD_REVERSED.REVERSE_CHARIOT_NULL_ITEM = Isaac.GetNullItemIdByName("reversed merged card chariot")
MERGED_CARD_REVERSED.REVERSE_HANGED_MAN_NULL_ITEM = Isaac.GetNullItemIdByName("reversed merged card hanged man")
MERGED_CARD_REVERSED.REVERSE_SUN_NULL_ITEM = Isaac.GetNullItemIdByName("reversed merged card sun")

MERGED_CARD_REVERSED.REVERSE_FORTUNE_DICE = {
	CollectibleType.COLLECTIBLE_D8,
	CollectibleType.COLLECTIBLE_D10,
	CollectibleType.COLLECTIBLE_D12,
}

MERGED_CARD_REVERSED.REVERSE_DEATH_ENEMIES = {
	{ EntityType.ENTITY_BONY,     0, 0 },
	{ EntityType.ENTITY_BOOMFLY,  4, 0 },
	{ EntityType.ENTITY_REVENANT, 0, 0 }
}

local DEATH_WOP = WeightedOutcomePicker()
DEATH_WOP:AddOutcomeWeight(1, 60)
DEATH_WOP:AddOutcomeWeight(2, 35)
DEATH_WOP:AddOutcomeWeight(3, 5)
MERGED_CARD_REVERSED.REVERSE_DEATH_WOP = DEATH_WOP

--#endregion

--#region Helpers

---No active items, no trinkets, no starting items
---@param historyItem HistoryItem
function MERGED_CARD_REVERSED:IsValidPassive(historyItem)
	return historyItem:GetTime() > 1
		and not historyItem:IsTrinket()
		and Mod.ItemConfig:GetCollectible(historyItem:GetItemID()).Type ~= ItemType.ITEM_ACTIVE
end

---@param card Card
---@param player? EntityPlayer
---@param rng? RNG
function MERGED_CARD_REVERSED:TriggerEffect(card, player, rng)
	if MERGED_CARD_REVERSED.CARD_EFFECTS[card] then
		player = player or Isaac.GetPlayer()
		rng = rng or player:GetCardRNG(MERGED_CARD_REVERSED.ID)
		MERGED_CARD_REVERSED.CARD_EFFECTS[card](player, rng)
	end
end

--#endregion

--#region Effects

---@type {[Card]: fun(player: EntityPlayer, rng?: RNG)}
MERGED_CARD_REVERSED.CARD_EFFECTS = {
	[Card.CARD_REVERSE_FOOL] = function(player, rng)
		local pickupType = rng:RandomInt(3) --0, 1, 2
		MERGED_CARD_REVERSED:HandleReverseFool(player, pickupType)
	end,
	[Card.CARD_REVERSE_MAGICIAN] = function(player, rng)
		player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_TELEKINESIS, true, 200, true)
	end,
	[Card.CARD_REVERSE_HIGH_PRIESTESS] = function(player, rng)
		--15 seconds
		player:AddNullItemEffect(NullItemID.ID_REVERSE_HIGH_PRIESTESS, false, 30 * 15)
	end,
	[Card.CARD_REVERSE_EMPRESS] = function(player, rng)
		player:UseCard(Card.CARD_STRENGTH, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
		player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM, -1)
		player:AddNullItemEffect(MERGED_CARD_REVERSED.REVERSE_EMPRESS_NULL_ITEM, true)
	end,
	[Card.CARD_REVERSE_EMPEROR] = function(player, rng)
		MERGED_CARD_REVERSED:HandleReverseEmperor(rng)
	end,
	[Card.CARD_REVERSE_HIEROPHANT] = function(player, rng)
		local pos = Mod.Room():FindFreePickupSpawnPosition(player.Position, 40)
		Mod.Spawn.Heart(HeartSubType.HEART_BONE, pos, nil, player, rng:Next())
	end,
	[Card.CARD_REVERSE_LOVERS] = function(player, rng)
		if player:GetBrokenHearts() < 11 then
			player:AddNullItemEffect(MERGED_CARD_REVERSED.REVERSE_LOVERS_NULL_ITEM)
			player:AddBrokenHearts(1)
		end
	end,
	[Card.CARD_REVERSE_CHARIOT] = function(player, rng)
		player:AddNullItemEffect(MERGED_CARD_REVERSED.REVERSE_CHARIOT_NULL_ITEM)
	end,
	[Card.CARD_REVERSE_JUSTICE] = function(player, rng)
		for _ = 1, rng:RandomInt(2) + 1 do
			local pos = Mod.Room():FindFreePickupSpawnPosition(player.Position, 40)
			Mod.Spawn.Chest(PickupVariant.PICKUP_LOCKEDCHEST, pos, nil, player, rng:Next())
		end
	end,
	[Card.CARD_REVERSE_HERMIT] = function(player, rng)
		for _ = 1, rng:RandomInt(5) + 1 do
			local pos = Mod.Room():FindFreePickupSpawnPosition(player.Position, 40)
			Mod.Spawn.Pickup(PickupVariant.PICKUP_COIN, 0, pos, nil, player, rng:Next())
		end
	end,
	[Card.CARD_REVERSE_WHEEL_OF_FORTUNE] = function(player, rng)
		local itemId = MERGED_CARD_REVERSED.REVERSE_FORTUNE_DICE
			[rng:RandomInt(#MERGED_CARD_REVERSED.REVERSE_FORTUNE_DICE) + 1]
		player:UseActiveItem(itemId, UseFlag.USE_NOANIM, -1)
	end,
	[Card.CARD_REVERSE_STRENGTH] = function(player, rng)
		---@type Entity[]
		local enemies = {}
		for _, ent in ipairs(Isaac.GetRoomEntities()) do
			if StatusEffectLibrary:IsValidTarget(ent) then
				Mod.Insert(enemies, ent)
			end
		end
		enemies = Mod:ShuffleTable(enemies, rng)
		local count = Mod.math.ceil(#enemies / 2)
		local source = EntityRef(player)
		for i = 1, count do
			local enemy = enemies[i]
			enemy:AddWeakness(source, 30 * 30)
		end
	end,
	[Card.CARD_REVERSE_HANGED_MAN] = function(player, rng)
		player:AddNullItemEffect(MERGED_CARD_REVERSED.REVERSE_HANGED_MAN_NULL_ITEM)
	end,
	[Card.CARD_REVERSE_DEATH] = function(player, rng)
		local enemyKey = DEATH_WOP:PickOutcome(rng)
		local enemy = MERGED_CARD_REVERSED.REVERSE_DEATH_ENEMIES[enemyKey]
		local entType, variant, subtype = enemy[1], enemy[2], enemy[3]
		local pos = Mod.Room():FindFreeTilePosition(player.Position, 40)
		local ent = Mod.Game:Spawn(entType, variant, pos, Vector.Zero, player, subtype, rng:Next())
		ent:AddCharmed(EntityRef(player), -1)
	end,
	[Card.CARD_REVERSE_TEMPERANCE] = function(player, rng)
		local itemPool = Mod.Game:GetItemPool()
		local pillColor = itemPool:GetPill(rng:Next())
		player:UsePill(itemPool:GetPillEffect(pillColor, player), pillColor, UseFlag.USE_NOANIM)
	end,
	[Card.CARD_REVERSE_DEVIL] = function(player, rng)
		player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BIBLE, true)
	end,
	[Card.CARD_REVERSE_TOWER] = function(player, rng)
		for i = 1, 2 do
			MERGED_CARD_REVERSED:SpawnReverseExplosion(player, rng, 40)
		end
	end,
	[Card.CARD_REVERSE_STARS] = function(player, rng)
		local history = player:GetHistory():GetCollectiblesHistory()
		local historyIndex
		for i = #history, 1, -1 do
			local historyItem = history[i]
			if MERGED_CARD_REVERSED:IsValidPassive(historyItem) then
				historyIndex = i
			end
		end
		if historyIndex then
			player:GetHistory():RemoveHistoryItemByIndex(historyIndex - 1)
			local pos = Mod.Room():FindFreePickupSpawnPosition(player.Position, 40)
			Mod.Spawn.Collectible(0, pos, player, rng:Next())
		end
	end,
	[Card.CARD_REVERSE_MOON] = function(player, rng)
		Mod.Card.MERGED_CARD:DisplayRoomType(RoomType.ROOM_ULTRASECRET)
		local pos = Mod.Room():FindFreePickupSpawnPosition(player.Position, 40)
		Mod.Spawn.Pickup(PickupVariant.PICKUP_TAROTCARD, Card.CARD_CRACKED_KEY, pos, nil, player, rng:Next())
	end,
	[Card.CARD_REVERSE_SUN] = function(player, rng)
		player:AddNullItemEffect(MERGED_CARD_REVERSED.REVERSE_SUN_NULL_ITEM)
	end,
	[Card.CARD_REVERSE_JUDGEMENT] = function(player, rng)
		player:UseActiveItem(CollectibleType.COLLECTIBLE_D6, UseFlag.USE_NOANIM, -1)
		player:UseActiveItem(CollectibleType.COLLECTIBLE_D20, UseFlag.USE_NOANIM, -1)
	end,
	[Card.CARD_REVERSE_WORLD] = function(player, rng)
		player:UseActiveItem(CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER, UseFlag.USE_NOANIM, -1)
	end
}

--#endregion

--#region Reverse Fool

---@param player EntityPlayer
---@param pickupType integer
---|0 @Coins
---|1 @Bombs
---|2 @Keys
function MERGED_CARD_REVERSED:HandleReverseFool(player, pickupType)
	local rng = player:GetCardRNG(MERGED_CARD_REVERSED.ID)
	local room = Mod.Room()
	if pickupType == 0 then
		local coins = player:GetNumCoins()
		while coins >= 25 do
			local pos = room:FindFreePickupSpawnPosition(player.Position, 40)
			coins = coins - 25
			Mod.Spawn.Collectible(CollectibleType.COLLECTIBLE_QUARTER, pos, player, rng:Next())
		end
		while coins >= 10 do
			local pos = room:FindFreePickupSpawnPosition(player.Position, 40)
			coins = coins - 10
			Mod.Spawn.Coin(CoinSubType.COIN_DIME, pos, nil, player, rng:Next())
		end
		while coins >= 5 do
			local pos = room:FindFreePickupSpawnPosition(player.Position, 40)
			coins = coins - 5
			Mod.Spawn.Coin(CoinSubType.COIN_NICKEL, pos, nil, player, rng:Next())
		end
		while coins >= 2 do
			local pos = room:FindFreePickupSpawnPosition(player.Position, 40)
			coins = coins - 2
			Mod.Spawn.Coin(CoinSubType.COIN_DOUBLEPACK, pos, nil, player, rng:Next())
		end
		while coins >= 1 do
			local pos = room:FindFreePickupSpawnPosition(player.Position, 40)
			coins = coins - 1
			Mod.Spawn.Coin(CoinSubType.COIN_PENNY, pos, nil, player, rng:Next())
		end
		player:AddCoins(-player:GetNumCoins())
	elseif pickupType == 1 then
		local goldenBomb = player:HasGoldenBomb()
		if goldenBomb then
			local pos = room:FindFreePickupSpawnPosition(player.Position, 40)
			Mod.Spawn.Bomb(BombSubType.BOMB_GOLDEN, pos, nil, player, rng:Next())
			player:RemoveGoldenBomb()
		end
		local bombs = player:GetNumBombs()
		local gigaBombs = player:GetNumGigaBombs()
		for _ = 1, gigaBombs do
			local pos = room:FindFreePickupSpawnPosition(player.Position, 40)
			Mod.Spawn.Bomb(BombSubType.BOMB_GIGA, pos, nil, player, rng:Next())
			bombs = bombs - 1
		end
		while bombs >= 99 do
			local pos = room:FindFreePickupSpawnPosition(player.Position, 40)
			bombs = bombs - 99
			Mod.Spawn.Collectible(CollectibleType.COLLECTIBLE_PYRO, pos, player, rng:Next())
		end
		while bombs >= 10 do
			local pos = room:FindFreePickupSpawnPosition(player.Position, 40)
			bombs = bombs - 10
			Mod.Spawn.Collectible(CollectibleType.COLLECTIBLE_BOOM, pos, player, rng:Next())
		end
		while bombs >= 2 do
			local pos = room:FindFreePickupSpawnPosition(player.Position, 40)
			bombs = bombs - 2
			Mod.Spawn.Bomb(BombSubType.BOMB_DOUBLEPACK, pos, nil, player, rng:Next())
		end
		while bombs >= 1 do
			local pos = room:FindFreePickupSpawnPosition(player.Position, 40)
			bombs = bombs - 1
			Mod.Spawn.Bomb(BombSubType.BOMB_NORMAL, pos, nil, player, rng:Next())
		end
		player:AddBombs(-player:GetNumBombs())
	elseif pickupType == 2 then
		local goldenKey = player:HasGoldenKey()
		if goldenKey then
			local pos = room:FindFreePickupSpawnPosition(player.Position, 40)
			Mod.Spawn.Key(KeySubType.KEY_GOLDEN, pos, nil, player, rng:Next())
			player:RemoveGoldenKey()
		end
		local keys = player:GetNumKeys()
		while keys >= 99 do
			local pos = room:FindFreePickupSpawnPosition(player.Position, 40)
			Mod.Spawn.Collectible(CollectibleType.COLLECTIBLE_SKELETON_KEY, pos, player, rng:Next())
			keys = keys - 99
		end
		while keys >= 2 do
			local pos = room:FindFreePickupSpawnPosition(player.Position, 40)
			keys = keys - 2
			Mod.Spawn.Key(KeySubType.KEY_DOUBLEPACK, pos, nil, player, rng:Next())
		end
		while keys >= 1 do
			local pos = room:FindFreePickupSpawnPosition(player.Position, 40)
			keys = keys - 1
			Mod.Spawn.Key(KeySubType.KEY_NORMAL, pos, nil, player, rng:Next())
		end
		player:AddKeys(-player:GetNumKeys())
	end
end

--#endregion

--#region Reverse Emperor

---@param roomConfigEntry RoomConfig_Entry
local function getValidEntry(roomConfigEntry)
	local entType, variant, subtype = roomConfigEntry.Type, roomConfigEntry.Variant, roomConfigEntry.Subtype
	if entType >= 1000 then
		return
	end
	local entityConfigEntity = EntityConfig.GetEntity(entType, variant, subtype)
	if entityConfigEntity and entityConfigEntity:CanBeChampion() and not entityConfigEntity:IsBoss() then
		return entType, variant, subtype
	end
end

---Grabs random default rooms from the current stage's STB and checks all spawn entries.
---
---If there's an enemy entry that meets the appropriate conditions, it will be spawned as a Rainbow Champion.
---
---If none are found after 50 attempts, spawns a Rainbow Squirt.
---@param rng RNG
function MERGED_CARD_REVERSED:HandleReverseEmperor(rng)
	local npc
	local attempts = 0
	local room = Mod.Room()
	local level = Mod.Level()
	repeat
		local roomType = Mod.Game:IsGreedMode() and RoomType.ROOM_CHALLENGE or RoomType.ROOM_DEFAULT
		local roomConfig = RoomConfig.GetRandomRoom(rng:Next(), false, Isaac.GetCurrentStageConfigId(), roomType)
		local spawns = roomConfig.Spawns
		for i = 0, #spawns - 1 do
			local roomConfigSpawn = spawns:Get(i)
			local entries = roomConfigSpawn.Entries
			for j = 0, #entries - 1 do
				local roomConfigEntry = entries:Get(j)
				local entType, variant, subtype = getValidEntry(roomConfigEntry)
				if entType and variant and subtype then
					local pos
					for doorSlot = DoorSlot.NO_DOOR_SLOT + 1, DoorSlot.NUM_DOOR_SLOTS - 1 do
						if doorSlot ~= level.EnterDoor and Mod:HasBitFlags(roomConfig.Doors, 1 << doorSlot) then
							pos = room:FindFreeTilePosition(room:GetDoorSlotPosition(doorSlot), 40)
						end
					end
					if not pos then
						pos = room:FindFreeTilePosition(room:GetCenterPos(), 40)
					end
					local ent = Mod.Game:Spawn(entType, variant, pos, Vector.Zero, nil, subtype, rng:Next())
					npc = ent:ToNPC()
					---@cast npc EntityNPC
					npc:MakeChampion(rng:Next(), ChampionColor.RAINBOW, true)
					break
				end
			end
			if npc then break end
		end
		attempts = attempts + 1
	until npc or attempts == 50
	if not npc then
		local roomConfig = level:GetCurrentRoomDesc().Data
		local pos
		for doorSlot = DoorSlot.NO_DOOR_SLOT + 1, DoorSlot.NUM_DOOR_SLOTS - 1 do
			if doorSlot ~= level.EnterDoor and Mod:HasBitFlags(roomConfig.Doors, 1 << doorSlot) then
				pos = room:FindFreeTilePosition(room:GetDoorSlotPosition(doorSlot), 40)
			end
		end
		if not pos then
			pos = room:FindFreeTilePosition(room:GetCenterPos(), 40)
		end
		local ent = Mod.Game:Spawn(EntityType.ENTITY_SQUIRT, 0, pos, Vector.Zero, nil, 0, rng:Next())
		npc = ent:ToNPC()
		---@cast npc EntityNPC
		npc:MakeChampion(rng:Next(), ChampionColor.RAINBOW, true)
	end
end

--#endregion

--#region Reverse Chariot

---@param player EntityPlayer
---@param cacheFlag CacheFlag
function MERGED_CARD_REVERSED:ReverseChariotStats(player, cacheFlag)
	if player:GetEffects():HasNullEffect(MERGED_CARD_REVERSED.REVERSE_CHARIOT_NULL_ITEM) then
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed / 2
		elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay / 2
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, MERGED_CARD_REVERSED.ReverseChariotStats, CacheFlag.CACHE_SPEED)
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, MERGED_CARD_REVERSED.ReverseChariotStats, CacheFlag.CACHE_FIREDELAY)

--#endregion

--#region Reverse Hanged Man

local REVERSE_NULL_HANGED_MAN_CONFIG = Mod.ItemConfig:GetNullItem(MERGED_CARD_REVERSED.REVERSE_HANGED_MAN_NULL_ITEM)

---@param player EntityPlayer
function MERGED_CARD_REVERSED:OnReverseHangedManAdd(player)
	player:AddInnateCollectible(CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER)
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_EFFECT, MERGED_CARD_REVERSED.OnReverseHangedManAdd, REVERSE_NULL_HANGED_MAN_CONFIG)

---@param player EntityPlayer
function MERGED_CARD_REVERSED:OnReverseHangedManRemove(player)
	player:AddInnateCollectible(CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER, -1)
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER) then
		player:RemoveCostume(Mod.ItemConfig:GetCollectible(CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER))
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_EFFECT_REMOVED, MERGED_CARD_REVERSED.OnReverseHangedManRemove, REVERSE_NULL_HANGED_MAN_CONFIG)

--#endregion

--#region Reverse Sun

local REVERSE_SUN_NULL_CONFIG = Mod.ItemConfig:GetNullItem(MERGED_CARD_REVERSED.REVERSE_SUN_NULL_ITEM)

---@param player EntityPlayer
function MERGED_CARD_REVERSED:OnReverseSunAdd(player)
	player:AddInnateCollectible(CollectibleType.COLLECTIBLE_SPIRIT_OF_THE_NIGHT)
	Mod.Game:Darken(1, 999999999)
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_EFFECT, MERGED_CARD_REVERSED.OnReverseSunAdd, REVERSE_SUN_NULL_CONFIG)

---@param player EntityPlayer
function MERGED_CARD_REVERSED:OnReverseSunRemove(player)
	player:AddInnateCollectible(CollectibleType.COLLECTIBLE_SPIRIT_OF_THE_NIGHT, -1)
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_OF_THE_NIGHT) then
		player:RemoveCostume(Mod.ItemConfig:GetCollectible(CollectibleType.COLLECTIBLE_SPIRIT_OF_THE_NIGHT))
	end
	Mod.Game:Darken(1, 0)
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_EFFECT_REMOVED, MERGED_CARD_REVERSED.OnReverseSunRemove, REVERSE_SUN_NULL_CONFIG)

--#endregion

--#region Reverse Tower

---@param player EntityPlayer
---@param rng RNG
---@param radius number
function MERGED_CARD_REVERSED:SpawnReverseExplosion(player, rng, radius)
	local room = Mod.Room()
	local pos = room:GetClampedPosition(Isaac.GetRandomPosition(), -40)
	local topLeftIndex = room:GetGridIndex(pos + Vector(-radius, 0))
	local topRightIndex = room:GetGridIndex(pos + Vector(radius, 0))
	local length = topRightIndex - topLeftIndex
	local width = room:GetGridWidth()
	Mod.Spawn.Effect(EffectVariant.REVERSE_EXPLOSION, 0, pos, nil, player)
	for x = topLeftIndex, topRightIndex do
		for y = 0, length do
			local gridIndex = x + (y * width)
			local grid = room:GetGridEntity(gridIndex)
			if not grid then
				Mod.Spawn.Effect(EffectVariant.REVERSE_EXPLOSION, 1, room:GetGridPosition(gridIndex), nil, player, rng:Next())
			end
		end
	end
end

--#endregion

--#region On Use

---@param card Card
---@param player EntityPlayer
---@param useFlags UseFlag
function MERGED_CARD_REVERSED:OnUse(card, player, useFlags)
	local numEffects = MERGED_CARD_REVERSED.NUM_EFFECTS
	if player:HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) then
		numEffects = numEffects + 1
	end
	if not Mod:HasBitFlags(useFlags, UseFlag.USE_NOANNOUNCER)
		and (
			Options.AnnouncerVoiceMode == AnnouncerVoiceMode.ALWAYS
			or Options.AnnouncerVoiceMode == AnnouncerVoiceMode.RANDOM and Mod.GENERIC_RNG:RandomFloat() < 0.5
		)
	then
		local delay = Mod.ItemConfig:GetCard(card).AnnouncerDelay
		Isaac.CreateTimer(function()
			Mod.sfxman:Play(MERGED_CARD_REVERSED.SFX)
		end, delay, 1, true)
	end
	local effect_keys = Mod:GetKeys(MERGED_CARD_REVERSED.CARD_EFFECTS)
	local rng = player:GetCardRNG(card)
	local hudNames = {}
	local bonusHUDNames = {}
	for _ = 1, numEffects do
		local selectedEffectKey = rng:RandomInt(#effect_keys) + 1
		MERGED_CARD_REVERSED:TriggerEffect(effect_keys[selectedEffectKey], player, rng)
		local name = Isaac.GetString(StringTableCategory.POCKET_ITEMS, Mod.ItemConfig:GetCard(effect_keys[selectedEffectKey]).Name)
		if #hudNames < 2 then
			Mod.Insert(hudNames, name)
		else
			Mod.Insert(bonusHUDNames, name)
		end
		table.remove(effect_keys, selectedEffectKey)
	end
	local mainStr = table.concat(hudNames, " + ")
	local bonusStr = #bonusHUDNames > 0 and "BONUS: " .. table.concat(bonusHUDNames, ", ") or nil
	if not Mod:HasBitFlags(useFlags, UseFlag.USE_NOHUD) then
		Mod.Game:GetHUD():ShowItemText(mainStr, bonusStr)
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, MERGED_CARD_REVERSED.OnUse, MERGED_CARD_REVERSED.ID)

--#endregion
