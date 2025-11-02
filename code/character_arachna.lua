local mod = ARACHNAMOD
local arachnaSpool = Isaac.GetItemIdByName("Arachna's Spool")
local arachnaHair = 'gfx/characters/costumes/arachna-head-2.png'
local arachnaChar = Isaac.GetPlayerTypeByName("Arachna", false)
local arachnaChar_b = Isaac.GetPlayerTypeByName("Arachna", true)
local arachnaBlackList = { CollectibleType.COLLECTIBLE_GLASS_CANNON, CollectibleType.COLLECTIBLE_YUCK_HEART, CollectibleType.COLLECTIBLE_MAGIC_SKIN, CollectibleType.COLLECTIBLE_GENESIS, CollectibleType.COLLECTIBLE_BRITTLE_BONES }
--on game start
function mod:arachnaPocketItem(isContinued) 
	if not isContinued then
		--if not continue, blacklist
		if someoneIsArachna() then
			for i=1, #arachnaBlackList do
				game:GetItemPool():RemoveCollectible(arachnaBlackList[i])
			end
		end
	else
		--on continue, fix hair
		for i=0, game:GetNumPlayers()-1 do
			local player = Isaac.GetPlayer(i)
			if (player:GetPlayerType() == arachnaChar) then
				player:ReplaceCostumeSprite(Isaac.GetItemConfig():GetNullItem(7), arachnaHair, 0)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.arachnaPocketItem)
--on game start
function mod:arachnaInit(player)
	if (player:GetPlayerType() == arachnaChar) then
		--hearts
		addWebHearts(2, player)
		player:AddSoulHearts(-2*mod:GetData(player).webHearts)
		--spool
		if (player:GetActiveItem(ActiveSlot.SLOT_POCKET) ~= arachnaSpool) then
			player:SetPocketActiveItem(arachnaSpool)
		end
		--hair
		player:ReplaceCostumeSprite(Isaac.GetItemConfig():GetNullItem(7), arachnaHair, 0)
		--pog
		if Poglite then
			local pogCostume = Isaac.GetCostumeIdByPath("gfx/characters/arachna_pog.anm2")
			Poglite:AddPogCostume("ArachnaPog", arachnaChar, pogCostume)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.arachnaInit)

--arachna stats
function mod:arachnaStats(player, cacheFlag)
    if player:GetPlayerType() == arachnaChar then
        if cacheFlag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage - 0.7
        end
        if cacheFlag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed + 0.25 
        end
        if cacheFlag == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck - 0.8
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.arachnaStats)
--tear sprites
function mod:arachnaPoison(tear)
	local player = tear.Parent:ToPlayer()
	if player then
		if (player:GetPlayerType() == arachnaChar) or (player:GetPlayerType() == arachnaChar_b) then
			--add poison tears with some chance
			if (math.random(1,4) == 1) then 
				tear:AddTearFlags(TearFlags.TEAR_POISON)
			end
			--change sprites
			if tear.Variant == TearVariant.BLUE then
				tear:GetSprite():ReplaceSpritesheet(0, "gfx/projectiles/tear_arachna_normal.png")
				tear:GetSprite():LoadGraphics()
				tear:GetData().spiderTear = true
			elseif tear.Variant == TearVariant.CUPID_BLUE then
				tear:GetSprite():ReplaceSpritesheet(0, "gfx/projectiles/tear_arachna_cupid.png")
				tear:GetSprite():LoadGraphics()
				tear:GetData().spiderTear = true
			elseif tear.Variant == TearVariant.LOST_CONTACT then
				tear:GetSprite():ReplaceSpritesheet(0, "gfx/projectiles/tear_arachna_lostcontact.png")
				tear:GetSprite():LoadGraphics()
				tear:GetData().spiderTear = true
			elseif tear.Variant == TearVariant.PUPULA then
				tear:GetSprite():ReplaceSpritesheet(0, "gfx/projectiles/tear_arachna_pupula.png")
				tear:GetSprite():LoadGraphics()
				tear:GetData().spiderTear = true
			elseif tear.Variant == TearVariant.HUNGRY then
				tear:GetSprite():ReplaceSpritesheet(0, "gfx/projectiles/tear_arachna_hungry.png")
				tear:GetSprite():LoadGraphics()
				tear:GetData().spiderTear = true
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.arachnaPoison)
--tears on grid collision
function mod:tearTouchGrid(tear)
	local data = tear:GetData()
	if (tear:IsDead()) and (data.spiderTear) then
		tear.Color = Color(0, 0, 0, 1, 1, 1, 1)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mod.tearTouchGrid)
--tears on enemy collision
function mod:tearTouchMob(tear, collider)
	local data = tear:GetData()
	if (data.spiderTear) then
		local npc = collider:ToNPC()
		if (not ((collider:ToNPC()) and (collider:ToNPC():HasEntityFlags(EntityFlag.FLAG_FRIENDLY)))) and (not (tear:HasTearFlags(TearFlags.TEAR_PIERCING) or tear:HasTearFlags(TearFlags.TEAR_PERSISTENT))) then 
			tear.Color = Color(0, 0, 0, 1, 1, 1, 1)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, mod.tearTouchMob)

--hair fix
local usedGlowingHourglass = false
function mod:arachnaActiveCostumeFix(item, rng, player)
	if (player:GetPlayerType() == arachnaChar) then
		if (item == CollectibleType.COLLECTIBLE_D4) or (item == CollectibleType.COLLECTIBLE_D100) then
			player:ReplaceCostumeSprite(Isaac.GetItemConfig():GetNullItem(7), arachnaHair, 0)
		elseif (item == CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS) then
			usedGlowingHourglass = true
		end
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.arachnaActiveCostumeFix)

function mod:arachnaHourglassHair() 
	if (usedGlowingHourglass) then
		for i=0, game:GetNumPlayers()-1 do
			local player = Isaac.GetPlayer(i)
			if (player:GetPlayerType() == arachnaChar) then
				player:ReplaceCostumeSprite(Isaac.GetItemConfig():GetNullItem(7), arachnaHair, 0)
			end
		end
		usedGlowingHourglass = false
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.arachnaHourglassHair)