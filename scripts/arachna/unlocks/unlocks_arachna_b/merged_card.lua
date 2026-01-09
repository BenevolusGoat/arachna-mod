--#region Variables

local Mod = ARACHNAMOD

local MERGED_CARD = {}

ARACHNAMOD.Card.MERGED_CARD = MERGED_CARD

MERGED_CARD.ID = Isaac.GetCardIdByName("Merged Card")
MERGED_CARD.SFX = Isaac.GetSoundIdByName("Merged Card")

MERGED_CARD.NUM_EFFECTS = 2

MERGED_CARD.WHEEL_NUM_ROLLS = 5

--#endregion

--#region Helpers

---@param ... RoomType
function MERGED_CARD:DisplayRoomType(...)
	local roomTypes = Mod:Set(table.pack(...))
	local level = Mod.Level()
	local rooms = level:GetRooms()
	for i = 0, rooms.Size - 1 do
		local roomDesc = rooms:Get(i)
		if roomTypes[roomDesc.Data.Type] then
			roomDesc.DisplayFlags = RoomDisplayFlags.VISIBLE | RoomDisplayFlags.SHOW_ICON --Visible + Show Icon
		end
	end
	Mod.Level():UpdateVisibility()
end

--#endregion

--#region Effects

---@type {[Card]: fun(player: EntityPlayer, rng: RNG)}
MERGED_CARD.CARD_EFFECTS = {
	[Card.CARD_FOOL] = function (player)
		player:UseActiveItem(CollectibleType.COLLECTIBLE_D7, UseFlag.USE_NOANIM, -1)
		Mod.sfxman:Play(SoundEffect.SOUND_SUMMON_POOF, 2, 0, false, 1)
	end,
	[Card.CARD_MAGICIAN] = function (player, rng)
		local source = EntityRef(player)
		Mod.Foreach.NPC(function (npc, index)
			if not npc:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
				npc:AddEntityFlags(EntityFlag.FLAG_SLOW)
			end
			Mod.Item.DIVINE_CLOTH:SpawnSwirl(npc.Position, npc)
		end, nil, nil, nil, {UseEnemySearchParams = true})
		Mod.sfxman:Play(SoundEffect.SOUND_SUMMON_POOF, 2, 0, false, 1)
	end,
	[Card.CARD_HIGH_PRIESTESS] = function (player, rng)
		Mod.Spawn.Effect(EffectVariant.MOM_FOOT_STOMP, 0, player.Position, nil, player, rng:Next())
	end,
	[Card.CARD_EMPRESS] = function (player, rng)
		player:UseActiveItem(CollectibleType.COLLECTIBLE_THE_NAIL, UseFlag.USE_NOANIM)
		local poof = Mod.Spawn.Poof02(0, player.Position, player)
		poof.Color = Color(0.1, 0.1, 0.1, 0.8, 0, 0, 0)
		poof.SpriteScale = poof.SpriteScale*0.8
	end,
	[Card.CARD_EMPEROR] = function (player, rng)
		MERGED_CARD:DisplayRoomType(RoomType.ROOM_BOSS)
		Mod.sfxman:Play(SoundEffect.SOUND_METAL_DOOR_OPEN, 1, 0, false, 1.2)
	end,
	[Card.CARD_HIEROPHANT] = function (player, rng)
		for _ = 1, 2 do
			local pos = Mod.Room():FindFreePickupSpawnPosition(player.Position, 40)
			Mod.Spawn.Heart(HeartSubType.HEART_HALF_SOUL, pos, nil, player, rng:Next())
		end
	end,
	[Card.CARD_LOVERS] = function (player, rng)
		for _ = 1, 2 do
			local pos = Mod.Room():FindFreePickupSpawnPosition(player.Position, 40)
			Mod.Spawn.Heart(HeartSubType.HEART_HALF, pos, nil, player, rng:Next())
		end
	end,
	[Card.CARD_CHARIOT] = function (player, rng)
		player:UseActiveItem(CollectibleType.COLLECTIBLE_UNICORN_STUMP, UseFlag.USE_NOANIM, -1)
	end,
	[Card.CARD_JUSTICE] = function (player, rng)
		local pickupVariants = {PickupVariant.PICKUP_COIN, PickupVariant.PICKUP_HEART, PickupVariant.PICKUP_KEY, PickupVariant.PICKUP_BOMB}
		for _ = 1, 2 do
			local pickupChoice = rng:RandomInt(#pickupVariants)+1
			local pos = Mod.Room():FindFreePickupSpawnPosition(player.Position, 40)
			Mod.Spawn.Pickup(pickupVariants[pickupChoice], 1, pos, nil, player, rng:Next())
			table.remove(pickupVariants, pickupChoice)
		end
	end,
	[Card.CARD_HERMIT] = function (player, rng)
		player:UseActiveItem(CollectibleType.COLLECTIBLE_KEEPERS_BOX, UseFlag.USE_NOANIM, -1)
	end,
	[Card.CARD_WHEEL_OF_FORTUNE] = function (player, rng)
		local hadCoins = player:GetNumCoins() > 0
		for _ = 1, MERGED_CARD.WHEEL_NUM_ROLLS do
			if player:GetNumCoins() == 0 then
				break
			end
			player:UseActiveItem(CollectibleType.COLLECTIBLE_PORTABLE_SLOT, UseFlag.USE_NOANIM, -1)
		end
		if hadCoins then
			Mod.sfxman:Play(SoundEffect.SOUND_CASH_REGISTER, 3, 0, false, 1)
		else
			Mod.sfxman:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
		end
	end,
	[Card.CARD_STRENGTH] = function (player, rng)
		player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_ODD_MUSHROOM_LARGE)
	end,
	[Card.CARD_HANGED_MAN] = function (player, rng)
		Mod.Foreach.Grid(function (gridEnt, gridIndex)
			if gridEnt:ToRock() or gridEnt:ToLock() or gridEnt:ToPoop() then
				gridEnt:Destroy()
			elseif gridEnt:ToPit() then
				gridEnt:ToPit():MakeBridge(nil)
				gridEnt:ToPit():UpdateCollision()
			end
		end)
	end,
	[Card.CARD_DEATH] = function (player, rng)
		local source = EntityRef(player)

		Mod.Foreach.NPC(function (npc, index)
			if npc:IsActiveEnemy(false) and npc:IsVulnerableEnemy() then
				npc:TakeDamage(20, 0, source, 0)
			end
		end)

		local poof1 = Mod.Spawn.Poof02(2, player.Position, player)
		poof1.PositionOffset = Vector(0, -15)
		poof1.Color = Color(0.3, 0.3, 0.3, 0.8, 0, 0, 0)
		poof1.SpriteScale = poof1.SpriteScale*0.85

		local poof2 = Mod.Spawn.Poof02(1, player.Position, player)
		poof2.Color = Color(0.3, 0.3, 0.3, 0.8, 0, 0, 0)
		poof2.SpriteScale = poof2.SpriteScale*0.7
	end,
	[Card.CARD_TEMPERANCE] = function (player, rng)
		local pos = Isaac.GetFreeNearPosition(player.Position, 40)
		local beggar = Mod.Spawn.Slot(SlotVariant.DEVIL_BEGGAR, pos, player, rng:Next())
		Mod.Spawn.Poof01(0, beggar.Position)
		Mod.sfxman:Play(SoundEffect.SOUND_SUMMONSOUND, 0.8, 0, false, 1)
	end,
	[Card.CARD_DEVIL] = function (player, rng)
		player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_GROWTH_HORMONES)
		player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_PENTAGRAM, true)
		Mod.sfxman:Play(SoundEffect.SOUND_SATAN_BLAST)
	end,
	[Card.CARD_TOWER] = function (player, rng)
		local room = Mod.Room()
		local nearPos = Isaac.GetFreeNearPosition(room:GetRandomPosition(40), 0)
		Mod.Spawn.Bomb(BombSubType.BOMB_TROLL, nearPos, nil, player, rng:Next())
	end,
	[Card.CARD_STARS] = function (player, rng)
		local pos = Mod.Room():FindFreePickupSpawnPosition(player.Position, 40)
		local chest = Mod.Spawn.Pickup(PickupVariant.PICKUP_LOCKEDCHEST, 0, pos, nil, player, rng:Next())
		Mod.Spawn.Poof01(0, chest.Position)
		Mod.sfxman:Play(SoundEffect.SOUND_SUMMONSOUND, 0.8, 0, false, 1)
	end,
	[Card.CARD_MOON] = function (player, rng)
		MERGED_CARD:DisplayRoomType(RoomType.ROOM_SECRET, RoomType.ROOM_SUPERSECRET, RoomType.ROOM_ULTRASECRET)
		Mod.sfxman:Play(SoundEffect.SOUND_GOLDENKEY)
	end,
	[Card.CARD_SUN] = function (player, rng)
		MERGED_CARD:DisplayRoomType(RoomType.ROOM_TREASURE, RoomType.ROOM_PLANETARIUM)
		player:AddHearts(2)
		local source = EntityRef(player)
		Mod.Foreach.NPC(function (npc, index)
			if npc:IsActiveEnemy() and npc:IsVulnerableEnemy() then
				npc:TakeDamage(5, 0, source, 0)
			end
		end)
		Mod.Spawn.Notification(player.Position, 0, true)
	end,
	[Card.CARD_JUDGEMENT] = function (player, rng)
		local pos = Mod.Room():FindFreePickupSpawnPosition(player.Position, 40, true)
		local shopkeeper = Mod.Game:Spawn(EntityType.ENTITY_SHOPKEEPER, 3, pos, Vector.Zero, player, 0, rng:Next())
		Mod.Spawn.Poof01(0, shopkeeper.Position)
		Mod.sfxman:Play(SoundEffect.SOUND_SUMMONSOUND, 0.8, 0, false, 1)
	end,
	[Card.CARD_WORLD] = function (player, rng)
		MERGED_CARD:DisplayRoomType(RoomType.ROOM_TREASURE, RoomType.ROOM_PLANETARIUM)
		Mod.sfxman:Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12, 1, 0, false, 1)
	end
}

--#endregion

--#region On Use

---@param card Card
---@param player? EntityPlayer
---@param rng? RNG
function MERGED_CARD:TriggerEffect(card, player, rng)
	if MERGED_CARD.CARD_EFFECTS[card] then
		player = player or Isaac.GetPlayer()
		rng = rng or player:GetCardRNG(MERGED_CARD.ID)
		MERGED_CARD.CARD_EFFECTS[card](player, rng)
	end
end

---@param card Card
---@param player EntityPlayer
---@param useFlags UseFlag
function MERGED_CARD:OnUse(card, player, useFlags)
	local numEffects = MERGED_CARD.NUM_EFFECTS
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
			Mod.sfxman:Play(MERGED_CARD.SFX)
		end, delay, 1, true)
	end
	local effect_keys = Mod:GetKeys(MERGED_CARD.CARD_EFFECTS)
	local rng = player:GetCardRNG(card)
	local hudNames = {}
	local bonusHUDNames = {}
	for _ = 1, numEffects do
		local selectedEffectKey = rng:RandomInt(#effect_keys) + 1
		MERGED_CARD:TriggerEffect(effect_keys[selectedEffectKey], player, rng)
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

Mod:AddCallback(ModCallbacks.MC_USE_CARD, MERGED_CARD.OnUse, MERGED_CARD.ID)

--#endregion