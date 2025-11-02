local mod = ARACHNAMOD
local arachnaSpool = Isaac.GetItemIdByName("Arachna's Spool")
local arachnaChar = Isaac.GetPlayerTypeByName("Arachna", false)
--web floor
local function spawnWeb(_pos, _par)
	local web = Isaac.Spawn(1000, 2000, 0, _pos, Vector(0,0), _par):ToEffect()
	web:AddEntityFlags(EntityFlag.FLAG_BACKDROP_DETAIL)
	web.DepthOffset = -250
	web:GetSprite():Play("Appear", true)
	web:Update()
end
function mod:webFloorUpdate(eff)
	local sprite = eff:GetSprite()
	local data = eff:GetData()
	if not data.init then
		sprite:ReplaceSpritesheet(0, "gfx/backdrop/web_" .. tostring(math.random(1,4)) .. ".png")
		sprite:LoadGraphics()
		data.init = true
	end
	if sprite:IsFinished("Appear") then
		sprite:Play("Idle")
	end
	if sprite:IsFinished("Remove") then
		eff:Remove()
	end
	--slowdown
	local enemies = Isaac.FindInRadius(eff.Position, 60, EntityPartition.ENEMY)
	for i=1, #enemies do
		local ent = enemies[i]
		if (not isBitten(ent)) then --no double slowdown if enemy got spiderbitten
			if (not ent:IsBoss()) then
				ent:AddSlowing(EntityRef(Isaac.GetPlayer(0)), 1, 0.5, Color(1, 1, 1, 1, 0.2, 0.2, 0.2))
				if (ent:IsDead()) and (ent.MaxHitPoints >= 10) and (ent.FrameCount % 2 == 0) and (ent.Type ~= 853) and (ent.Type ~= 24) and (ent.Type ~= 278) and (ent.Type ~= EntityType.ENTITY_FIREPLACE) and (ent.SpawnerType == 0) and (ent.ParentNPC == nil) and (not ent:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN)) then
					Isaac.Spawn(1000, 2001, 0, ent.Position, Vector(0,0), eff.SpawnerEntity)
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.webFloorUpdate, 2000)
--on use
function mod:spoolInit(player)
	mod:GetData(player).heldItem = 0
	mod:GetData(player).itemSlot = nil
	mod:GetData(player).holdCoolDown = 0
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.spoolInit)
--on use lift up/down
function mod:spoolUse(item, rng, player, useflags, slot, customvardata)
	local data = mod:GetData(player)
	if data.holdCoolDown == 0 then --added cooldown so the item could be used with accumulator
		if data.heldItem ~= arachnaSpool then
			player:AnimateCollectible(arachnaSpool, "LiftItem", "PlayerPickupSparkle")
			data.heldItem = arachnaSpool
			data.itemSlot = slot
		else
			player:AnimateCollectible(arachnaSpool, "HideItem", "PlayerPickupSparkle")
			data.heldItem = 0
		end	
		data.holdCoolDown = 2
	end	
	sfx:Play(SoundEffect.SOUND_FETUS_JUMP, 0.8, 0, false, 1)
	return  { Discharge = false, Remove = false, ShowAnim = false }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.spoolUse, arachnaSpool)
--lift down when damaged
function mod:spoolOnDamage(player, amt, flgs, src, cntdwn)
	mod:GetData(player).heldItem = 0
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.spoolOnDamage, EntityType.ENTITY_PLAYER)
--keep on on new room
function mod:spoolNewRoom()
	for i=0, game:GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(i)
		local data = mod:GetData(player)
		if (data.heldItem) and (data.heldItem ~= 0) then
			player:AnimateCollectible(data.heldItem, "LiftItem", "PlayerPickupSparkle")
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.spoolNewRoom)
--throw
local vecDir = {[Direction.NO_DIRECTION] = Vector(0, 0), [Direction.UP] = Vector(0, -1), [Direction.DOWN] = Vector(0, 1), [Direction.LEFT] = Vector(-1, 0),[Direction.RIGHT] = Vector(1, 0)}
function mod:spoolUpdate(player)
	local data = mod:GetData(player)
	if (data.heldItem) and (data.heldItem == arachnaSpool) then
		local dir = player:GetFireDirection()
		if dir ~= Direction.NO_DIRECTION then
			--shoot tear (I'm spawning it instead of firing it so shit like trisagon and fire mind won't fuck up the tear) 
			local spoolTear = Isaac.Spawn(2, 2000, 0, player.Position, vecDir[dir]*12*clamp(player.TearRange/260, 1, 9999), player):ToTear()
			spoolTear.Parent = player
			spoolTear:GetData().spiderTear = false
			spoolTear.CollisionDamage = 4.2
			spoolTear.FallingSpeed = -5.5
			spoolTear.FallingAcceleration = 0.5
			--TODO: GIVE PLAYER'S RANGE STAT
			--inherit some of the tear flags
			local flagsToGet = {0, 2, 38, 42, 52, 71}
			for i=1, #flagsToGet do
				if playerHasTearFlag(player, flagsToGet[i]) then
					spoolTear:AddTearFlags(flagsToGet[i])
				end
			end
			--
			player:DischargeActiveItem(data.itemSlot)
			data.heldItem = 0
			sfx:Play(SoundEffect.SOUND_FETUS_JUMP, 0.8, 0, false, 1)
			player:AnimateCollectible(arachnaSpool, "HideItem", "PlayerPickupSparkle")
		end
	end
	--cooldown
	if data.holdCoolDown and data.holdCoolDown > 0 then
		data.holdCoolDown = data.holdCoolDown - 1
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.spoolUpdate)

--spool tear
local function spoolBreak(_tear)
	local data = _tear:GetData()
	if not data.wasBroken then
	    sfx:Play(SoundEffect.SOUND_WOOD_PLANK_BREAK, 1, 7, false, 3)
		sfx:Play(SoundEffect.SOUND_SUMMON_POOF, 0.8, 1, false, 1)
		game:SpawnParticles(_tear.Position, 27, math.random(5, 10), 4)
		--remove webs
		local maxWebCount = 0
		--if player has birthright then 2x time
		if (_tear.Parent:ToPlayer():GetPlayerType() == arachnaChar) and (_tear.Parent:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
			maxWebCount = 2
		else
			maxWebCount = 1
		end
		local webCount = 0
		local webs = Isaac.FindByType(1000, 2000, -1, false, false)
		local i = 1
		while i <=#webs do
			if GetPtrHash(webs[i].SpawnerEntity) ~= GetPtrHash(_tear.Parent) then
				table.remove(webs, i)
			else
				i = i + 1
			end
		end
		while (#webs >= maxWebCount) do 
			local ent = webs[1]
			ent:GetSprite():Play("Remove")
			table.remove(webs, 1)
		end
		--spawn web
		spawnWeb(_tear.Position, _tear.Parent)
		data.wasBroken = true
	end
end
--tears update
function mod:spoolUpdate(tear)
	local data = tear:GetData()
	if (tear.FrameCount%2 == 0) then
		local trail = Isaac.Spawn(1000, 111, 0, Vector(tear.Position.X, tear.Position.Y + 1.1 + tear.Height), Vector(0,0), tear):ToEffect()
		trail:GetSprite().Color = Color(1,1,1,1,1,1,1)
		trail:Update()
	end
	if (tear:IsDead()) then
		spoolBreak(tear)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mod.spoolUpdate, 2000)
--tears on collision
function mod:spoolTouchMob(tear, collider)
	local data = tear:GetData()
	--enemy
	if (collider.Type ~= 3) and (not ((collider:ToNPC()) and (collider:ToNPC():HasEntityFlags(EntityFlag.FLAG_FRIENDLY)))) then
		spoolBreak(tear)
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, mod.spoolTouchMob, 2000)

--wisp drop spider on death
function mod:spiderWispsDeath(ent, amount, flags, src, countdown)
	if (ent:ToFamiliar()) then
		if (ent.Variant == 206) and ((ent.SubType == arachnaSpool) or (ent.SubType == Isaac.GetItemIdByName("Divine Cloth"))) then
			if (ent.HitPoints <= amount) then
				--drop spider
				local player = ent:ToFamiliar().Player
				local nearPos = Isaac.GetFreeNearPosition(player.Position + Vector(math.random(-100, 100), math.random(-100, 100)), 50)
				player:ThrowBlueSpider(player.Position, nearPos)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.spiderWispsDeath)

--lift down when using vanilla throw items
function mod:heldItemDownOnItemUse(item, rng, player, useflags, slot, customvardata)
	if (item == CollectibleType.COLLECTIBLE_BOBS_ROTTEN_HEAD) or (item == CollectibleType.COLLECTIBLE_RED_CANDLE) or (item == CollectibleType.COLLECTIBLE_CANDLE) or (item == CollectibleType.COLLECTIBLE_BLACK_HOLE) or (item == CollectibleType.COLLECTIBLE_DECAP_ATTACK) or (item == CollectibleType.COLLECTIBLE_SHOOP_DA_WHOOP) or (item == CollectibleType.COLLECTIBLE_MOMS_BRACELET) or (item == CollectibleType.COLLECTIBLE_SUPLEX) or (item == CollectibleType.COLLECTIBLE_BAG_OF_CRAFTING) or (item == CollectibleType.COLLECTIBLE_ERASER) or (item == CollectibleType.COLLECTIBLE_GELLO) then
		mod:GetData(player).heldItem = 0
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.heldItemDownOnItemUse)