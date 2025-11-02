local mod = ARACHNAMOD
local divineCloth = Isaac.GetItemIdByName("Divine Cloth")
local arachnaHair_b = 'gfx/characters/costumes/arachna-head-b-2.png'
local arachnaChar_b = Isaac.GetPlayerTypeByName("Arachna", true)
--on game continue
function mod:arachnaBPocketItem(isContinued) 
	if isContinued then
		--clear wisps from prev run
		local itemWisps = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ITEM_WISP, CollectibleType.COLLECTIBLE_MUTANT_SPIDER)
		if #itemWisps > 0 then
			for i = 1, #itemWisps do
				local wisp = itemWisps[i]:ToFamiliar()
				if (wisp.Visible) and (wisp.Player:GetPlayerType() == arachnaChar_b) then
					wisp:TakeDamage(wisp.HitPoints+1, 0, EntityRef(Isaac.GetPlayer(0)), 0)
				end
			end
		end
		--fix hair
		for i=0, game:GetNumPlayers()-1 do
			local player = Isaac.GetPlayer(i)
			if (player:GetPlayerType() == arachnaChar_b) then
				player:ReplaceCostumeSprite(Isaac.GetItemConfig():GetNullItem(7), arachnaHair_b, 0)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.arachnaBPocketItem)
--on game start (coop)
function mod:arachnaBInit(player)
	if (player:GetPlayerType() == arachnaChar_b) then
		--hearts
		addWebHearts(3, player)
		player:AddSoulHearts(-2*mod:GetData(player).webHearts)
		--divine cloth
		if (player:GetActiveItem(ActiveSlot.SLOT_POCKET) ~= divineCloth) then
			player:SetPocketActiveItem(divineCloth)
		end
		--quad shot
		if not hasInnateItem(player, CollectibleType.COLLECTIBLE_MUTANT_SPIDER) then
			addInnateItem(player, CollectibleType.COLLECTIBLE_MUTANT_SPIDER)
			player:RemoveCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_MUTANT_SPIDER))
		end
		--hair
		player:ReplaceCostumeSprite(Isaac.GetItemConfig():GetNullItem(7), arachnaHair_b, 0)
		--pog
		if Poglite then
			local pogCostume = Isaac.GetCostumeIdByPath("gfx/characters/arachna_pog_b.anm2")
			Poglite:AddPogCostume("ArachnaBPog", arachnaChar_b, pogCostume)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.arachnaBInit)
--arachna stats
function mod:arachnaBStats(player, cacheFlag)
    if player:GetPlayerType() == arachnaChar_b then
		--stats
        if cacheFlag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed - 0.25 
        end
        if cacheFlag == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck + 0.8
        end
		if cacheFlag == CacheFlag.CACHE_FIREDELAY then
	        player.MaxFireDelay = player.MaxFireDelay + 0.4
		end
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
	        player.Damage = player.Damage - 2.5
		end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.arachnaBStats)

--hair fix
local usedGlowingHourglass = false
function mod:arachnaBActiveCostumeFix(item, rng, player)
	if (player:GetPlayerType() == arachnaChar_b) then
		if (item == CollectibleType.COLLECTIBLE_D4) or (item == CollectibleType.COLLECTIBLE_D100) then
			player:ReplaceCostumeSprite(Isaac.GetItemConfig():GetNullItem(7), arachnaHair_b, 0)
		elseif (item == CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS) then
			usedGlowingHourglass = true
		end
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.arachnaBActiveCostumeFix)

--give all arachnas their hair and innate items after using glowing hourglass
function mod:arachnaBHourglassHair() 
	if (usedGlowingHourglass) then
		for i=0, game:GetNumPlayers()-1 do
			local player = Isaac.GetPlayer(i)
			if (player:GetPlayerType() == arachnaChar_b) then
				--hair
				player:ReplaceCostumeSprite(Isaac.GetItemConfig():GetNullItem(7), arachnaHair_b, 0)
				--quad shot spawn
				if not hasInnateItem(player, CollectibleType.COLLECTIBLE_MUTANT_SPIDER) then
					addInnateItem(player, CollectibleType.COLLECTIBLE_MUTANT_SPIDER)
					player:RemoveCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_MUTANT_SPIDER))
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.arachnaBHourglassHair)

--slaughter all visible fires after using glowing hourglass
function mod:arachnaBFirePurge() 
	if (usedGlowingHourglass) then
		local itemWisps = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ITEM_WISP, CollectibleType.COLLECTIBLE_MUTANT_SPIDER)
		if #itemWisps > 0 then
			for i = 1, #itemWisps do
				local wisp = itemWisps[i]:ToFamiliar()
				if (wisp.Visible) and (wisp.Player:GetPlayerType() == arachnaChar_b) then
					wisp:TakeDamage(wisp.HitPoints+1, 0, EntityRef(Isaac.GetPlayer(0)), 0)
				end
			end
		end	
		usedGlowingHourglass = false
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.arachnaBFirePurge)