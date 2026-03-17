--#region Variables

local Mod = ARACHNAMOD

local SPIDER_BEGGAR = {}

ARACHNAMOD.Slot.SPIDER_BEGGAR = SPIDER_BEGGAR

SPIDER_BEGGAR.ID = Isaac.GetEntityVariantByName("Spider Beggar")
SPIDER_BEGGAR.POOL = Isaac.GetPoolIdByName("spiderBeggar")

SPIDER_BEGGAR.REPLACEMENT_CHANCE = 0.2

--Type, Variant
SPIDER_BEGGAR.SPIDERS = {
	{EntityType.ENTITY_BLISTER, 0},
	{EntityType.ENTITY_BIGSPIDER, 0},
	{EntityType.ENTITY_SPIDER_L2, 0},
	{EntityType.ENTITY_TICKING_SPIDER, 0},
	{EntityType.ENTITY_CRAZY_LONG_LEGS, 1}
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
	end),
	SPIDER_BEGGAR.PayoutEvent("Friendly Spiders", 0.32, function (beggar, rng)
		local randomSpider = rng:RandomInt(#SPIDER_BEGGAR.SPIDERS) + 1
		local spiderType = SPIDER_BEGGAR.SPIDERS[randomSpider]
		local spider = Mod.Game:Spawn(spiderType[1], spiderType[2], Isaac.GetFreeNearPosition(beggar.Position, 40), Vector.Zero, beggar, 0, rng:Next())
		spider:AddCharmed(EntityRef(beggar), -1)
	end),
	SPIDER_BEGGAR.PayoutEvent("Collectible", 0.29, function (beggar, rng)
		local itemId = Mod.Game:GetItemPool():GetCollectible(SPIDER_BEGGAR.POOL, true, rng:Next())
		local pos = Mod.Room():FindFreePickupSpawnPosition(beggar.Position, 0, true)
		Mod.Spawn.Collectible(itemId, pos, beggar, rng:Next())
		beggar:GetSprite():Play("Teleport", true)
		beggar:SetState(SlotState.PAYOUT)
		Mod.Level():SetStateFlag(LevelStateFlag.STATE_BUM_LEFT, true)
	end),
}

local WOP = WeightedOutcomePicker()
for i, payoutEvent in ipairs(SPIDER_BEGGAR.PAYOUT_EVENTS) do
	WOP:AddOutcomeFloat(i, payoutEvent.Weight)
end
SPIDER_BEGGAR.PAYOUT_WOP = WOP

--#endregion

--#region Should Payout

---Credit to Guantol for the exact details on beggar payouts!
---@param beggar EntitySlot
---@param player EntityPlayer
function SPIDER_BEGGAR:TryPayout(beggar, player)
	local donationValue = beggar:GetDonationValue() + 1
	local rng = beggar:GetDropRNG()
	local sprite = beggar:GetSprite()

	local successValue = 0
	successValue = rng:RandomInt(4) + rng:RandomInt(4) + rng:RandomInt(2)
	if Mod.Game.Difficulty == Difficulty.DIFFICULTY_HARD then
		successValue = math.max(successValue, 5)
	end

	if donationValue > successValue then
		donationValue = rng:RandomInt(2) + 2
		if player:HasCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT) then
			donationValue = donationValue + 1
		end

		beggar:SetState(SlotState.REWARD)
		sprite:Play("PayPrize", true)
	else
		sprite:Play("PayNothing", true)
	end

	beggar:SetDonationValue(donationValue)
end

--#endregion

--#region Animations/Give Prize

---Just a feature of vanilla beggars I guess?
---@param slot EntitySlot
function SPIDER_BEGGAR:OnInit(slot)
	slot.PositionOffset = Vector(0, 8)
end

Mod:AddCallback(ModCallbacks.MC_POST_SLOT_INIT, SPIDER_BEGGAR.OnInit, SPIDER_BEGGAR.ID)

---@param beggar EntitySlot
function SPIDER_BEGGAR:SpawnPrize(beggar)
	local rng = beggar:GetDropRNG()
	local eventKey = WOP:PickOutcome(rng)
	local event = SPIDER_BEGGAR.PAYOUT_EVENTS[eventKey].Func
	event(beggar, rng)
	Mod.sfxman:Play(SoundEffect.SOUND_SLOTSPAWN)
end

---@param beggar EntitySlot
function SPIDER_BEGGAR:OnSlotUpdate(beggar)
	local sprite = beggar:GetSprite()

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

--Specificiations of what a beggar uses to allow paying it according to decomp
---@param beggar EntitySlot
---@param player EntityPlayer
function SPIDER_BEGGAR:ShouldTakeMoney(beggar, player)
	local sprite = beggar:GetSprite()
	return player:GetNumCoins() > 0
		and beggar:GetState() == SlotState.IDLE
		and (sprite:IsFinished() or sprite:GetCurrentAnimationData():IsLoopingAnimation())
		and beggar:GetTimeout() <= 0
end

---@param beggar EntitySlot
---@param ent Entity
function SPIDER_BEGGAR:OnBeggarCollision(beggar, ent)
	local player = ent:ToPlayer()
	if player and SPIDER_BEGGAR:ShouldTakeMoney(beggar, player) then
		player:AddCoins(-1)
		SPIDER_BEGGAR:TryPayout(beggar, player)
		if EID then
			--Disables description after donating
			beggar.SubType = 10
		end
		Mod.sfxman:Play(SoundEffect.SOUND_ANIMAL_SQUISH)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_SLOT_COLLISION, SPIDER_BEGGAR.OnBeggarCollision, SPIDER_BEGGAR.ID)

--#endregion

--#region Death

---@param beggar EntitySlot
function SPIDER_BEGGAR:BeggarDrops(beggar)
	if beggar:GetState() == SlotState.DESTROYED then
		Mod.sfxman:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.8)
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