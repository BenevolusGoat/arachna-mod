local Mod = ARACHNAMOD

local MUTAGEN = {}

ARACHNAMOD.Item.MUTAGEN = MUTAGEN

MUTAGEN.ID = Isaac.GetItemIdByName("Mutagen")

MUTAGEN.SPAWN_CHANCE = 0.2

function MUTAGEN:SpawnColoredSpiders()
	Mod.Foreach.Player(function (player, index)
		if player:HasCollectible(MUTAGEN.ID) then
			local rng = player:GetCollectibleRNG(MUTAGEN.ID)
			if rng:RandomFloat() < MUTAGEN.SPAWN_CHANCE * player:GetCollectibleNum(MUTAGEN.ID) then
				for i = 1, Mod:RandomNum(3, 5, rng) do
					Mod.Entities.COLORED_SPIDERS:ThrowColoredSpider(player, Mod.Entities.COLORED_SPIDERS:GetRandomSpiderSubtype(false, true), player.Position)
				end
				Mod.sfxman:Play(SoundEffect.SOUND_SPIDER_SPIT_ROAR, 0.8)
			end
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, MUTAGEN.SpawnColoredSpiders)
Mod:AddCallback(ModCallbacks.MC_POST_START_GREED_WAVE, MUTAGEN.SpawnColoredSpiders)