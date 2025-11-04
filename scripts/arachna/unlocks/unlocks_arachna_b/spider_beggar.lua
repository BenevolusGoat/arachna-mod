--#region Variables

local Mod = ARACHNAMOD

local SPIDER_BEGGAR = {}

ARACHNAMOD.Slot.SPIDER_BEGGAR = SPIDER_BEGGAR

SPIDER_BEGGAR.ID = Isaac.GetEntityVariantByName("Spiderboi (beggar)")
SPIDER_BEGGAR.POOL = Isaac.GetPoolIdByName("spiderBeggar")

--Type, Variant
SPIDER_BEGGAR.SPIDERS = {
	{EntityType.ENTITY_BLISTER, 0},
	{EntityType.ENTITY_BIGSPIDER, 0},
	{EntityType.ENTITY_SPIDER_L2, 0},
	{EntityType.ENTITY_TICKING_SPIDER, 0},
	{EntityType.ENTITY_CRAZY_LONG_LEGS, 1}
}

local SlotState = {
	IDLE = 1,
	REWARD = 2,
	BOMBED = 3,
	PAYOUT = 4
}

---@class PayoutEvent
---@field Name string
---@field Weight number
---@field Func fun(beggar: EntitySlot, rng: RNG)

---@param name string
---@param weight number
---@param func fun(beggar: EntitySlot, rng: RNG)
---@return PayoutEvent
---@function
function SPIDER_BEGGAR.PayoutEvent(name, weight, func)
	return {
		Name = name,
		Weight = weight,
		Func = func,
	}
end

---@type PayoutEvent[]
SPIDER_BEGGAR.PAYOUT_EVENTS = {
	SPIDER_BEGGAR.PayoutEvent("Web Heart", 0.35, function (beggar, rng)
		local vel = EntityPickup.GetRandomPickupVelocity(beggar.Position, rng, 1)
		Mod.Spawn.Heart(Mod.Pickup.WEB_HEART.ID, beggar.Position, vel, beggar, rng:Next())
		Mod:DebugLog("Web Heart")
	end),
	SPIDER_BEGGAR.PayoutEvent("Friendly Spiders", 0.32, function (beggar, rng)
		local randomSpider = rng:RandomInt(#SPIDER_BEGGAR.SPIDERS) + 1
		local spiderType = SPIDER_BEGGAR.SPIDERS[randomSpider]
		local spider = Mod.Game:Spawn(spiderType[1], spiderType[2], Isaac.GetFreeNearPosition(beggar.Position, 40), Vector.Zero, beggar, 0, rng:Next())
		spider:AddCharmed(EntityRef(beggar), -1)
		Mod:DebugLog("Random spunder")
	end),
	SPIDER_BEGGAR.PayoutEvent("Collectible", 0.29, function (beggar, rng)
		local itemId = Mod.Game:GetItemPool():GetCollectible(SPIDER_BEGGAR.POOL, true, rng:Next())
		local pos = Mod.Room():FindFreePickupSpawnPosition(beggar.Position, 0, true)
		Mod.Spawn.Collectible(itemId, pos, beggar, rng:Next())
		beggar:GetSprite():Play("Teleport")
		beggar:SetState(SlotState.PAYOUT)
		Mod:DebugLog("COLLECTIBLE WOOOO no more beggar")
	end),
}

local WOP = WeightedOutcomePicker()
for i, payoutEvent in ipairs(SPIDER_BEGGAR.PAYOUT_EVENTS) do
	WOP:AddOutcomeFloat(i, payoutEvent.Weight)
end
SPIDER_BEGGAR.PAYOUT_WOP = WOP

--#endregion

--#region Should Payout

---@param donations integer
---@param payouts integer
---@param rng RNG
function SPIDER_BEGGAR:ShouldPayout(donations, payouts, rng)
	--TODO: Should be more detailed, but just recreating beggar for now.
	if Mod.Game.Difficulty == Difficulty.DIFFICULTY_HARD then
	else
	end
	return rng:RandomFloat() < 0.35
end

--#endregion

--#region Animations/Give Prize

---@param beggar EntitySlot
function SPIDER_BEGGAR:SpawnPrize(beggar)
	local rng = beggar:GetDropRNG()
	local eventKey = WOP:PickOutcome(rng)
	local event = SPIDER_BEGGAR.PAYOUT_EVENTS[eventKey].Func
	event(beggar, rng)
	Mod.sfxman:Play(SoundEffect.SOUND_SLOTSPAWN, 1.0, 0, false, 1.0)
end

---@param beggar EntitySlot
function SPIDER_BEGGAR:OnSlotUpdate(beggar)
	local sprite = beggar:GetSprite()
	local slot_save = Mod.SaveManager.GetRoomSave(beggar)

	slot_save.SpiderBeggarPayouts = slot_save.SpiderBeggarPayouts or 0

	if sprite:IsFinished("PayPrize") then
		sprite:Play("Prize")
	elseif sprite:IsEventTriggered("Disappear") then
		beggar:Remove()
	elseif sprite:IsEventTriggered("Prize") then
		SPIDER_BEGGAR:SpawnPrize(beggar)
	elseif sprite:IsFinished("Prize") or sprite:IsFinished("PayNothing") then
		sprite:Play("Idle")
		beggar:SetState(SlotState.IDLE)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, SPIDER_BEGGAR.OnSlotUpdate, SPIDER_BEGGAR.ID)

--#endregion

--#region Slot Collision

---@param beggar EntitySlot
---@param ent Entity
function SPIDER_BEGGAR:OnBeggarCollision(beggar, ent)
	local sprite = beggar:GetSprite()
	local player = ent:ToPlayer()

	if not (
		player
		and player:GetNumCoins() > 0
		and beggar:GetState() == SlotState.IDLE
		and sprite:IsPlaying("Idle")
	)
	then
		return
	end
	local slot_save = Mod.SaveManager.GetRoomSave(beggar)

	player:AddCoins(-1)
	beggar:SetDonationValue(beggar:GetDonationValue() + 1)
	Mod.sfxman:Play(SoundEffect.SOUND_SCAMPER)

	if SPIDER_BEGGAR:ShouldPayout(beggar:GetDonationValue(), slot_save.SpiderBeggarPayouts, beggar:GetDropRNG()) then
		beggar:SetDonationValue(0)
		slot_save.SpiderBeggarPayouts = (slot_save.SpiderBeggarPayouts or 0) + 1
		sprite:Play("PayPrize")
		beggar:GetData().EP_ConverterBeggarPlayer = player
		beggar:SetState(SlotState.REWARD)
		Mod:DebugLog("Howway!!!!")
	else
		Mod:DebugLog("You get NOTHING. Try again.")
		sprite:Play("PayNothing")
	end

	Mod.sfxman:Play(SoundEffect.SOUND_ANIMAL_SQUISH)
end

Mod:AddCallback(ModCallbacks.MC_POST_SLOT_COLLISION, SPIDER_BEGGAR.OnBeggarCollision, SPIDER_BEGGAR.ID)

--#endregion

--#region Death

---@param beggar EntitySlot
function SPIDER_BEGGAR:BeggarDrops(beggar)
	if beggar:GetState() == SlotState.BOMBED then
		Mod.sfxman:Play(SoundEffect.SOUND_MEATY_DEATHS , 0.8, 0, false, 1.25)
		beggar:BloodExplode()
		Mod.Level():SetStateFlag(LevelStateFlag.STATE_BUM_KILLED, true)
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, beggar.Position, Vector.Zero, beggar)
		beggar:Remove()
	end
	for _ = 1, 2 do
		local targetPos = Isaac.GetFreeNearPosition(beggar.Position, 120)
		EntityNPC.ThrowSpider(beggar.Position, beggar, targetPos, false, -10)
	end
	return false
end

Mod:AddCallback(ModCallbacks.MC_PRE_SLOT_CREATE_EXPLOSION_DROPS, SPIDER_BEGGAR.BeggarDrops, SPIDER_BEGGAR.ID)

--#endregion