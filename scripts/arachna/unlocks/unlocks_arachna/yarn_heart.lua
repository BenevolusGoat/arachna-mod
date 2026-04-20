local Mod = ArachnaMod

local YARN_HEART = {}

ArachnaMod.Item.YARN_HEART = YARN_HEART

YARN_HEART.ID = Isaac.GetItemIdByName("Yarn Heart")

---@param player EntityPlayer
function YARN_HEART:WebHeartOnUse(itemID, rng, player)
	Mod.Item.DIVINE_CLOTH:SpawnSwirl(player.Position, player)
	Mod.sfxman:Play(SoundEffect.SOUND_SPIDER_SPIT_ROAR, 0.8)
	if Mod:IsAnyKeeper(player) then
		for i = 1, 2 do
			Mod.Entities.COLORED_SPIDERS:ThrowFriendlySpider(player, 0, player.Position)
		end
		return true
	end
	if Mod.Pickup.WEB_HEART:CanPickup(player) then
		Mod.Pickup.WEB_HEART:AddWebHearts(player, 1)
	end
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, YARN_HEART.WebHeartOnUse, YARN_HEART.ID)
