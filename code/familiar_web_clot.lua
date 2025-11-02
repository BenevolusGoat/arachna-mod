local mod = ARACHNAMOD

--BEHAVIOUR
--shot out white slowing tears
function mod:whiteClotTears(tear)
	if (tear.SpawnerEntity) and (tear.SpawnerEntity:ToFamiliar()) then
		local data = tear:GetData()
		if not data.init then
			local baby = tear.SpawnerEntity:ToFamiliar()
			if (baby.Type == 3) and (baby.Variant == 238) and (baby.SubType == 2000) then
				tear:AddTearFlags(TearFlags.TEAR_SLOW)
				tear.Color = Color(2, 2, 2, 1, 0.196, 0.196, 0.196)
			end
			data.init = true
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mod.whiteClotTears)

--SPAWNING
--t eve's ability
function mod:onBlobSpawn(baby)
	local player = baby.Player
	if (player:GetPlayerType() == PlayerType.PLAYER_EVE_B) and (mod:GetData(player).webHearts > 0) and (baby.SubType ~= 2000) and (baby.SubType ~= 20) and (baby.SubType ~= 4) then --second subtype is immortal thingy
		--compensate the loss
		if baby.SubType == 0 then
			player:AddHearts(1) --0.5 red heart
		elseif baby.SubType == 1 then
			player:AddSoulHearts(1) --0.5 soul heart
		elseif baby.SubType == 2 then
			player:AddBlackHearts(1) --0.5 black heart
		elseif baby.SubType == 3 then
			player:AddEternalHearts(1) --1 eternal heart
		--elseif baby.SubType == 4 then
			--1 gold heart
			--player:AddGoldenHearts(1) 
		elseif baby.SubType == 5 then
			player:AddBoneHearts(1) --1 bone heart
		elseif baby.SubType == 6 then
			player:AddRottenHearts(1) --1 rotten heart
		end
		--spawn right clot
		local clot = Isaac.Spawn(3, 238, 2000, player.Position, Vector(0, 0), player):ToFamiliar()
		clot.HitPoints = 24
		addWebHearts(-1, player)
		--kill the motherfucker		
		baby:Remove()
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.onBlobSpawn, 238)

--t eve's pocket item
function mod:useSumptoriumAltEve(item, rng, player, flags, slot)
	local data = mod:GetData(player)
	if (player:GetPlayerType() == PlayerType.PLAYER_EVE_B) and (slot == ActiveSlot.SLOT_POCKET) then
		for _, entity in pairs(Isaac.FindByType(3, 238, 2000)) do
			addWebHearts(1, player)
			entity:Kill()
		end
		return true
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.useSumptoriumAltEve, CollectibleType.COLLECTIBLE_SUMPTORIUM)

--normal use of sumptorium
function mod:useSumptoriumEveryone(item, rng, player, flags, slot)
	local data = mod:GetData(player)
	if (slot ~= ActiveSlot.SLOT_POCKET) then
		if data.webHearts > 0 then
			sfx:Play(SoundEffect.SOUND_MEATY_DEATHS , 0.8, 0, false, 1.25)
			local clot = Isaac.Spawn(3, 238, 2000, player.Position, Vector(0, 0), player):ToFamiliar()
			clot.HitPoints = 24
			player:AnimateCollectible(CollectibleType.COLLECTIBLE_SUMPTORIUM, "UseItem")
			addWebHearts(-1, player)
			return true
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, mod.useSumptoriumEveryone, CollectibleType.COLLECTIBLE_SUMPTORIUM)

--t eve if she has only 1 web heart
function mod:altEveOnOneWebHeart(player)
	local data = mod:GetData(player)
	if data.webHearts then
		if (player:GetSoulHearts() == 2) and (mod:GetData(player).webHearts == 1) and (player:GetBoneHearts() == 0) then
			player:AddSoulHearts(-1)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, mod.altEveOnOneWebHeart)