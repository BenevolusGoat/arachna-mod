local Mod = ARACHNAMOD

local ARACHNOLOGY_101 = {}
ARACHNAMOD.Item.ARACHNOLOGY_101 = ARACHNOLOGY_101

ARACHNOLOGY_101.ID = Isaac.GetItemIdByName("Arachnology 101")

ARACHNOLOGY_101.REWARD = {
	SPIDER_FACT = 1,
	WEB_HEART = 2,
	BLUE_SPIDERS = 3
}

local WOP = WeightedOutcomePicker()
WOP:AddOutcomeFloat(ARACHNOLOGY_101.REWARD.SPIDER_FACT, 0.7)
WOP:AddOutcomeFloat(ARACHNOLOGY_101.REWARD.WEB_HEART, 0.15)
WOP:AddOutcomeFloat(ARACHNOLOGY_101.REWARD.BLUE_SPIDERS, 0.15)
ARACHNOLOGY_101.WOP = WOP

---@param item CollectibleType
---@param rng RNG
---@param player EntityPlayer
function ARACHNOLOGY_101:OnUse(item, rng, player)
	local reward = Mod.Misc.FLOOR_TEXT.FORCE_NUMERICAL and 1 or WOP:PickOutcome(rng)
	local isJudasBirthright = Mod:IsJudasBirthrightActive(player)
	--70% chance to display random spider fact
	if reward == ARACHNOLOGY_101.REWARD.SPIDER_FACT then
		Mod.Misc.FLOOR_TEXT:ShowRandomFactOnHUD(rng)
		Mod.sfxman:Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12, 1, 0, false, 1)
	--15% chance to spawn web heart
	elseif reward == ARACHNOLOGY_101.REWARD.WEB_HEART then
		local pos = Mod.Room():FindFreePickupSpawnPosition(player.Position, 40)
		local variant = isJudasBirthright and HeartSubType.HEART_BLACK or Mod.Pickup.WEB_HEART.ID
		Mod.Spawn.Heart(variant, pos, nil, player, rng:Next())
		Mod.sfxman:Play(SoundEffect.SOUND_SHELLGAME, 1, 0, false, 1)
	--15% chance to spawn 4-8 blue spiders
	elseif reward == ARACHNOLOGY_101.REWARD.BLUE_SPIDERS then
		local spiderCount = rng:RandomInt(5)+4
		local spiderColor = isJudasBirthright and Mod.Entities.COLORED_SPIDERS.SpiderSubtype.WRATH or 0
		Mod.Entities.SPIDER_EGG:SpawnSpiderBurst(player, player.Position, spiderCount, nil, nil, nil, spiderColor)
		Mod.sfxman:Play(SoundEffect.SOUND_SPIDER_SPIT_ROAR, 1, 0, false, 1)
	end
	return true
end
Mod:AddCallback(ModCallbacks.MC_USE_ITEM, ARACHNOLOGY_101.OnUse, ARACHNOLOGY_101.ID)