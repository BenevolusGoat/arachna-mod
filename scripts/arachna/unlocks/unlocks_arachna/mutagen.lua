local Mod = ARACHNAMOD

local MUTAGEN = {}

ARACHNAMOD.Item.MUTAGEN = MUTAGEN

MUTAGEN.ID = Isaac.GetItemIdByName("Mutagen")

MUTAGEN.SPAWN_CHANCE = 0.2

function MUTAGEN:SpawnColoredSpiders()
	Mod.Foreach.Player(function(player, index)
		if player:HasCollectible(MUTAGEN.ID) then
			local rng = player:GetCollectibleRNG(MUTAGEN.ID)
			if rng:RandomFloat() < MUTAGEN.SPAWN_CHANCE * player:GetCollectibleNum(MUTAGEN.ID) then
				for i = 1, Mod:RandomNum(3, 5, rng) do
					Mod.Entities.COLORED_SPIDERS:ThrowFriendlySpider(player,
						Mod.Entities.COLORED_SPIDERS:GetRandomSpiderSubtype(true), player.Position)
				end
				Mod.sfxman:Play(SoundEffect.SOUND_SPIDER_SPIT_ROAR, 0.8)
			end
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	if Mod.Room():IsFirstVisit() then
		MUTAGEN:SpawnColoredSpiders()
	end
end)
Mod:AddCallback(ModCallbacks.MC_POST_START_GREED_WAVE, MUTAGEN.SpawnColoredSpiders)

---@param spider EntityFamiliar
function MUTAGEN:TrySpawnColoredSpider(spider)
	local player = spider.Player
	if player:HasCollectible(MUTAGEN.ID)
		and spider.SubType == 0
		and not Mod:GetData(player).IgnoreMutagen
	then
		local familiar_run_save = Mod.SaveManager.GetRunSave(spider)
		if familiar_run_save.RolledMutagen then
			return
		end
		familiar_run_save.RolledMutagen = true
		spider.SubType = Mod.Entities.COLORED_SPIDERS:GetRandomSpiderSubtype()
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_FAMILIAR_INIT, CallbackPriority.EARLY, MUTAGEN.TrySpawnColoredSpider, FamiliarVariant.BLUE_SPIDER)