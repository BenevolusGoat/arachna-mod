local Mod = ARACHNAMOD

local YARN_HEART = {}

ARACHNAMOD.Item.YARN_HEART = YARN_HEART

YARN_HEART.ID = Isaac.GetItemIdByName("Yarn Heart")

---@param player EntityPlayer
function YARN_HEART:WebHeartOnUse(itemID, rng, player)
	if Mod.Pickup.WEB_HEART:CanPickup(player) then
		Mod.Pickup.WEB_HEART:AddWebHearts(player, 1)
	end
	Mod.Item.DIVINE_CLOTH:SpawnSwirl(player.Position, player)
	Mod.sfxman:Play(SoundEffect.SOUND_SPIDER_SPIT_ROAR, 0.8)
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, YARN_HEART.WebHeartOnUse, YARN_HEART.ID)