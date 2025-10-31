local mod = ARACHNAMOD
local game = ARACHNAMOD.game
local sfx = ARACHNAMOD.sfx
local actionAngle = {[ButtonAction.ACTION_SHOOTUP] = 180, [ButtonAction.ACTION_SHOOTDOWN] = 0, [ButtonAction.ACTION_SHOOTLEFT] = 90, [ButtonAction.ACTION_SHOOTRIGHT] = 270}
local dirAngle = {[Direction.NO_DIRECTION] = 0, [Direction.UP] = 180, [Direction.DOWN] = 0, [Direction.LEFT] = 90, [Direction.RIGHT] = 270}
local newsPaperItem = Isaac.GetItemIdByName("Dad's Newspaper")

-- so originally this thing was a knife entity instead of effect, but I ran into some problems that made me use effect later on instead
-- for example the thing kept destroying poops and tnt all the time and to make proper damage implication I had to fuck with like 3 callbacks
-- so yeah even though it's kinda weird to not use knife like base game melee stuff does, this is how I've done it so it would look and act as close to the real thing as possible

--on game start
function mod:newsPaperVariableInit(player)
	local data = mod:GetData(player)
	data.paperSwingCoolDown = 0 
	data.doubleClickAction = -1
	data.doubleClickTimeout = 0
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.newsPaperVariableInit)

--always
function mod:paperSwingSpawnTest(player)
	--get player's knife
	local myNewsPaper = nil
	local papers = Isaac.FindByType(1000, 2003, 0, false, false)
	if #papers > 0 then
		for i=1, #papers do
			local effPar = papers[i].SpawnerEntity
			if (effPar) and (GetPtrHash(effPar) == GetPtrHash(player)) then
				myNewsPaper = papers[i]
			end
		end
	end
	--if player has item
	if player:HasCollectible(newsPaperItem) then
		local data = mod:GetData(player)
		--if player doesn't have a knife, spawn it
		if myNewsPaper == nil then
			myNewsPaper = Isaac.Spawn(1000, 2003, 0, player.Position, Vector(0,0), player):ToEffect()
			myNewsPaper:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
			myNewsPaper.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			myNewsPaper.Size = 36
			myNewsPaper:GetSprite():Play("Idle", true)
			myNewsPaper:GetData().moveAngle = 0
			myNewsPaper:GetData().rotCoolDown = 0
		end
		--if shooting button was triggered
		local newsPaperSprite = myNewsPaper:GetSprite()
		local newsPaperData = myNewsPaper:GetData()
		local triggeredButton = triggeredShootButton(player)
		if (triggeredButton) then
			--on double click
			if (data.doubleClickAction == triggeredButton) and (data.doubleClickTimeout > 0) and (data.paperSwingCoolDown <= 0) and (newsPaperSprite:IsPlaying("Idle") or newsPaperSprite:IsPlaying("Blink") or newsPaperSprite:IsPlaying("Idle2") or newsPaperSprite:IsPlaying("Blink2")) then	
				--effect
				newsPaperData.rotCoolDown = 0
				if (newsPaperSprite:IsPlaying("Idle") or newsPaperSprite:IsPlaying("Blink")) then
					newsPaperSprite:Play("Swing")
				elseif (newsPaperSprite:IsPlaying("Idle2") or newsPaperSprite:IsPlaying("Blink2")) then
					newsPaperSprite:Play("Swing2")
				end
				newsPaperSprite.Rotation = actionAngle[triggeredButton]
				newsPaperData.moveAngle = newsPaperSprite.Rotation
				--additional small stuff
				sfx:Play(SoundEffect.SOUND_SHELLGAME, 1, 0, false, 1) 
				game:ShakeScreen(4)
				player.Velocity = player.Velocity + Vector.FromAngle(actionAngle[triggeredButton]+90)*1.5
				--reset
				data.doubleClickAction = -1
				data.doubleClickTimeout = 0
				--hit cooldown
				myNewsPaper:GetData().blinkPlayed = false
				data.paperSwingCoolDown = 120
			else
				data.doubleClickAction = triggeredButton
				data.doubleClickTimeout = 12
			end
		end
		--cooldowns
		if (data.doubleClickTimeout) and (data.doubleClickTimeout > 0) then
			data.doubleClickTimeout = data.doubleClickTimeout - 1
		end
		if (data.paperSwingCoolDown) and (data.paperSwingCoolDown > 0) then
			data.paperSwingCoolDown = data.paperSwingCoolDown - 1
		end
	else
		--if player has the knife, but doesn't have an item, remove it
		if myNewsPaper ~= nil then
			myNewsPaper:Remove()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, mod.paperSwingSpawnTest)

--newspaper update
function mod:paperSwingUpdate(knife)
	local sprite = knife:GetSprite()
	local data = knife:GetData()
	local player = knife.SpawnerEntity:ToPlayer()
	--cooldown end indication
	if (not data.blinkPlayed) and (mod:GetData(player).paperSwingCoolDown == 0) and (sprite:IsPlaying("Idle") or sprite:IsPlaying("Idle2")) then
		if sprite:IsPlaying("Idle") then
			sprite:Play("Blink")
		elseif sprite:IsPlaying("Idle2") then
			sprite:Play("Blink2")
		end
		sfx:Play(SoundEffect.SOUND_BEEP, 1, 0, false, 1) 
		data.blinkPlayed = true
	end
	--collisions
	if (sprite:IsPlaying("Swing") or sprite:IsPlaying("Swing2")) then
		--collision class
		if knife.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_ALL then
			knife.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		end
		--damage enemies
		for _, collider in ipairs(Isaac.FindInRadius(knife.Position, knife.Size, EntityPartition.ENEMY)) do
			--extinguish fire and moveable tnts
			if (collider.Type == EntityType.ENTITY_FIREPLACE and (collider.Variant == 0 or collider.Variant == 10)) or (collider.Type == 292) then
				collider:Die()
			end
			--enemies
			if collider:IsVulnerableEnemy() then
				--kill insect enemies
				if isInsectEnemy(collider) then
					game:SpawnParticles(collider.Position, 5, mod:GetRandomNumber(6, 10, mod.Globals.garbageRNG), 7)	
					sfx:Play(SoundEffect.SOUND_PUNCH, 1, 0, false, 1)
					sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.8, 0, false, 1.25)
					collider:Die()
				end
				--for all types of enemies
				local collData = collider:GetData()
				if ((not collData.paperHitCoolDown) or (collData.paperHitCoolDown == 0)) then
					--on hit
					local damageVal = clamp(player.Damage*(2 + player:GetCollectibleNum(newsPaperItem)), 4, 24)
					collider:TakeDamage(damageVal, 0, EntityRef(player), 0)
					if not collider:IsBoss() then
						collider:AddConfusion(EntityRef(player), 90) --30 is 1 second
					end
					sfx:Play(SoundEffect.SOUND_PUNCH, 1, 0, false, 1)
					collData.paperHitCoolDown = 11
				end
			end
			--throw bombs
			if collider.Type == 4 then
				collider.Velocity = collider.Velocity + Vector.FromAngle((player.Position - collider.Position):GetAngleDegrees())*(-1)*mod:GetRandomNumber(3, 5, mod.Globals.garbageRNG)
			end
		end
		--throw pickups
		for _, pickup in ipairs(Isaac.FindInRadius(knife.Position, knife.Size, EntityPartition.PICKUP)) do
			pickup.Velocity = pickup.Velocity + Vector.FromAngle((player.Position - pickup.Position):GetAngleDegrees())*(-1)*mod:GetRandomNumber(3, 5, mod.Globals.garbageRNG)
		end
		--kill projectiles
		for _, proj in ipairs(Isaac.FindInRadius(knife.Position, knife.Size, EntityPartition.BULLET)) do
			proj:Die()
		end
		--destroy poops and TNT
		local level = game:GetLevel()
		local room = level:GetCurrentRoom()
		for gridIndex = 1, room:GetGridSize() do
			local grid = room:GetGridEntity(gridIndex)
			if (grid ~= nil) and (grid.State ~= 4 and grid.State ~= 1000) and (grid:GetType() == GridEntityType.GRID_POOP or grid:GetType() == GridEntityType.GRID_TNT) then
				if knife.Position:Distance(grid.Position) < knife.Size then
					grid:Destroy()
				end
			end
		end
	else
		if knife.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE then
			knife.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		end
	end
	--go back to idle
	if sprite:IsFinished("Swing2") or sprite:IsFinished("Blink") then
		sprite:Play("Idle")
	end
	if sprite:IsFinished("Swing") or sprite:IsFinished("Blink2") then
		sprite:Play("Idle2")
	end
	--cooldown
	if data.rotCoolDown > 0 then
		data.rotCoolDown = data.rotCoolDown - 1
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.paperSwingUpdate, 2003) 

--newspaper render (position at player)
function mod:paperSwingRender(knife)
	local sprite = knife:GetSprite()
	local data = knife:GetData()
	local player = knife.SpawnerEntity:ToPlayer()
	--rotation when not busy swinging
	if (sprite:IsPlaying("Idle") or sprite:IsPlaying("Blink") or sprite:IsPlaying("Idle2") or sprite:IsPlaying("Blink2")) then
		--set target angle
		if data.rotCoolDown <= 0 then
			if player:GetFireDirection() ~= Direction.NO_DIRECTION then
				data.moveAngle = dirAngle[player:GetFireDirection()] 
			else
				data.moveAngle = dirAngle[player:GetMovementDirection()] 
			end
			data.rotCoolDown = 4
		end
		--rotate towards that angle
		if math.abs(sprite.Rotation - data.moveAngle) > math.abs(sprite.Rotation + 360 - data.moveAngle) then
			sprite.Rotation = sprite.Rotation + 360
		elseif math.abs(sprite.Rotation - data.moveAngle) > math.abs(sprite.Rotation - 360 - data.moveAngle) then
			sprite.Rotation = sprite.Rotation - 360
		end
		sprite.Rotation = lerp(sprite.Rotation, data.moveAngle, 0.25)
	end
	--stay at player's position
	knife.Position = Vector(player.Position.X, player.Position.Y-11) + Vector.FromAngle(sprite.Rotation+90):Resized(44) --you resize to radius, and substract 1/4 of it from player Y pos
	knife.Velocity = player.Velocity
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, mod.paperSwingRender, 2003) 

--cooldown
function mod:paperHitCoolDownUpdate(npc)
	local data = npc:GetData()
	if (data.paperHitCoolDown) and (data.paperHitCoolDown > 0) then
		data.paperHitCoolDown = data.paperHitCoolDown - 1
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.paperHitCoolDownUpdate)

--on new room fix pos
function mod:newsPaperNewRoom()
	local papers = Isaac.FindByType(1000, 2003, 0, false, false)
	if #papers > 0 then
		for i=1, #papers do
			papers[i].Position = papers[i].SpawnerEntity.Position
			papers[i].Velocity = papers[i].SpawnerEntity.Velocity
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.newsPaperNewRoom)