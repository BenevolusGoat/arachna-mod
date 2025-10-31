ARACHNAMOD = RegisterMod("Arachna Mod", 1)
local mod = ARACHNAMOD
ARACHNAMOD.sfx = SFXManager()
ARACHNAMOD.game = Game()
ARACHNAMOD.luadebug = os
local game = ARACHNAMOD.game
local sfx = ARACHNAMOD.sfx

if not REPENTANCE then
	return
end

-----------------------------------
--Helper Functions (thanks piber)--
-----------------------------------

function mod:GetPlayers(functionCheck, ...)

	local args = {...}
	local players = {}
	
	local game = Game()
	
	for i=1, game:GetNumPlayers() do
	
		local player = Isaac.GetPlayer(i-1)
		
		local argsPassed = true
		
		if type(functionCheck) == "function" then
		
			for j=1, #args do
			
				if args[j] == "player" then
					args[j] = player
				elseif args[j] == "currentPlayer" then
					args[j] = i
				end
				
			end
			
			if not functionCheck(table.unpack(args)) then
			
				argsPassed = false
				
			end
			
		end
		
		if argsPassed then
			players[#players+1] = player
		end
		
	end
	
	return players
	
end

function mod:GetPlayerFromTear(tear)
	for i=1, 3 do
		local check = nil
		if i == 1 then
			check = tear.Parent
		elseif i == 2 then
			check = mod:GetSpawner(tear)
		elseif i == 3 then
			check = tear.SpawnerEntity
		end
		if check then
			if check.Type == EntityType.ENTITY_PLAYER then
				return mod:GetPtrHashEntity(check):ToPlayer()
			elseif check.Type == EntityType.ENTITY_FAMILIAR and check.Variant == FamiliarVariant.INCUBUS then
				local data = mod:GetData(tear)
				data.IsIncubusTear = true
				return check:ToFamiliar().Player:ToPlayer()
			end
		end
	end
	return nil
end

function mod:GetSpawner(entity)
	if entity and entity.GetData then
		local spawnData = mod:GetSpawnData(entity)
		if spawnData and spawnData.SpawnerEntity then
			local spawner = mod:GetPtrHashEntity(spawnData.SpawnerEntity)
			return spawner
		end
	end
	return nil
end

function mod:GetSpawnData(entity)
	if entity and entity.GetData then
		local data = mod:GetData(entity)
		return data.SpawnData
	end
	return nil
end

function mod:GetPtrHashEntity(entity)
	if entity then
		if entity.Entity then
			entity = entity.Entity
		end
		for _, matchEntity in pairs(Isaac.FindByType(entity.Type, entity.Variant, entity.SubType, false, false)) do
			if GetPtrHash(entity) == GetPtrHash(matchEntity) then
				return matchEntity
			end
		end
	end
	return nil
end

function mod:GetData(entity)
	if entity and entity.GetData then	
		local data = entity:GetData()
		if not data.ARACHNAMOD then
			data.ARACHNAMOD = {}
		end
		return data.ARACHNAMOD
	end
	return nil
end

function mod:Contains(list, x)
	for _, v in pairs(list) do
		if v == x then return true end
	end
	return false
end

function mod:GetRandomNumber(numMin, numMax, rng)
	if not numMax then
		numMax = numMin
		numMin = nil
	end
	
	rng = rng or RNG()

	if type(rng) == "number" then
		local seed = rng
		rng = RNG()
		rng:SetSeed(seed, 1)
	end
	
	if numMin and numMax then
		return rng:Next() % (numMax - numMin + 1) + numMin
	elseif numMax then
		return rng:Next() % numMin
	end
	return rng:Next()
end

--ripairs stuff from revel
function ripairs_it(t,i)
	i=i-1
	local v=t[i]
	if v==nil then return v end
	return i,v
end
function ripairs(t)
	return ripairs_it, t, #t+1
end

local arachnaCode = {	
	include('code.customhealthapi.core'), 
	include('code.chapi'), 

	include('code.unlocksystem'), 
	include('code._functions'), 
	include('code.save-n-achievements'), 
	include('code.callback_post_get_item'), 
	
	include('code.modcompat_eid'), 
	
	include('code.item_simplestuff'), 
	include('code.pickup_webheart'), 
	include('code.familiar_web_clot'), 
	include('code.pickup_devil_deal'), 
	include('code.character_arachna'), 
	include('code.character_arachna_b'), 
	include('code.familiar_spiders_of_color'), 
	include('code.item_spool'), 
	include('code.item_divine_cloth'), 
	include('code.item_lil_arachna'), 
	include('code.eff_spider_egg'), 
	include('code.eff_shopkeeper_gold'), 
	include('code.beggar_spiderboi'), 
	include('code.item_bbb'), 
	include('code.item_the_yarn'), 
	include('code.item_arachnid_grips'), 
	include('code.item_mech_eye'), 
	include('code.item_dads_newspaper'), 
	include('code.item_lastwill'), 
	include('code.item_geptameron'), 
	include('code.item_3dglasses'), 
	include('code.item_spidercake'),
}

--custom shader fix by agentcucco
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function()
	if #Isaac.FindByType(EntityType.ENTITY_PLAYER) == 0 then
		Isaac.ExecuteCommand("reloadshaders")
	end
end)