local mod = ARACHNAMOD

 
local spiderEnemyType = {303, 94, 215, 250, 207}
local spiderEnemyVar = {0, 0, 0, 0, 1}

function getSpiderItem() 
	local spiderItemPool = {288, 171, 170, 248, 234, 266, 217, 153, 89, 211, 377, 367, 461, 575, Isaac.GetTrinketIdByName("Yarn Heart"), Isaac.GetTrinketIdByName("Arachnid's Grip")}
	return spiderItemPool[math.random(1, #spiderItemPool)]
end

--update
function mod:spiderBeggarUpdate()
	local spiderbois = Isaac.FindByType(EntityType.ENTITY_SLOT, 2000)
	for _, bum in pairs(spiderbois) do
		local sprite = bum:GetSprite()
		local data = bum:GetData()
		--init
		if not data.init then
			sprite:Play("Idle")
			data.init = true
		end
		--give reward
		if sprite:IsEventTriggered("Prize") then
			local rewardType = math.random(66, 100)
			if rewardType >= 66 and rewardType <= 78 then
				dropvelocity = Vector.FromAngle(math.random(0,360))*(-1)*math.random(3,5)
				local webHeart = Isaac.Spawn(5, 2000, 0, bum.Position, dropvelocity, nil)
				
			elseif rewardType > 77 and rewardType <= 89 then
				local itemPos = getNearPos(bum.Position)
				local spiderType = math.random(1, #spiderEnemyType)
				local spiderBro = Isaac.Spawn(spiderEnemyType[spiderType], spiderEnemyVar[spiderType], 0, Isaac.GetFreeNearPosition(bum.Position, 40), Vector(0,0), nil):ToNPC()
				spiderBro:AddEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM | EntityFlag.FLAG_PERSISTENT)
				
			elseif rewardType > 90 and rewardType <= 100 then
				local room = game:GetRoom()
				local itemPos = room:FindFreePickupSpawnPosition(room:GetGridPosition(room:GetGridIndex(bum.Position) + room:GetGridWidth()))
				local item = Isaac.Spawn(5, 100, getSpiderItem(), itemPos, Vector(0,0), nil)
				local poof = Isaac.Spawn(1000, 15, 0, item.Position, Vector(0,0), nil)
				sprite:Play("Teleport", true)
			end
			sfx:Play(SoundEffect.SOUND_SLOTSPAWN, 1.0, 0, false, 1.0)
		end
		--back 2 idle or straight up removing
		if sprite:IsFinished("PayNothing") or sprite:IsFinished("PayPrize") then 
			sprite:Play("Idle")	
		end
		if sprite:IsFinished("Teleport") then
			bum:Remove()
		end
		--on explosion
		local explosions = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION)
		for _, boom in pairs(explosions) do
			if bum.Position:Distance(boom.Position) < (75*boom.SpriteScale.X) then
				--[[
				for i=1, math.random(3,5) do
					local nearPos = Isaac.GetFreeNearPosition(bum.Position + Vector(math.random(-100, 100), math.random(-100, 100)), 50)
					Isaac.GetPlayer(0):ThrowBlueSpider(bum.Position, nearPos)
				end
				]]
				sfx:Play(SoundEffect.SOUND_MEATY_DEATHS , 0.8, 0, false, 1.25)
				bum:Remove()
				game:GetLevel():SetStateFlag(LevelStateFlag.STATE_BUM_KILLED, true)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.spiderBeggarUpdate)

--gimme the cash
function mod:spiderBeggarDonate(player, beggar, low)
	if beggar.Type == EntityType.ENTITY_SLOT and beggar.Variant == 2000 then
		if beggar:GetSprite():IsPlaying("Idle") and player:GetNumCoins() > 0 then
			player:AddCoins(-1)
			if math.random(1,100) > 65 then -- 35% to get a reward
				beggar:GetSprite():Play("PayPrize")
			else
				beggar:GetSprite():Play("PayNothing")
			end
			SFXManager():Play(SoundEffect.SOUND_SCAMPER, 1.0, 0, false, 1.0)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, mod.spiderBeggarDonate)

--I'd like to remove pickups spawned upon death by the game, but I can't do it ;-;

-- friendly enemies on new room and floor
function friends2PlayerPos()
	local playerPos = Isaac.GetPlayer(0).Position
	local enemies = Isaac.FindInRadius(playerPos, 999, EntityPartition.ENEMY)
	for i=1, #enemies do
		local ent = enemies[i]
		if ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM | EntityFlag.FLAG_PERSISTENT) then
			ent.Position = playerPos
		end
	end	
end

function mod:monsterBudsNewRoom()
	friends2PlayerPos()
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.monsterBudsNewRoom)

function mod:monsterBudsNewLevel()
	friends2PlayerPos()
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.monsterBudsNewLevel)