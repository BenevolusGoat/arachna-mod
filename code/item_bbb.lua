local mod = ARACHNAMOD
local game = ARACHNAMOD.game
local sfx = ARACHNAMOD.sfx

--item
local bestBudBall = Isaac.GetItemIdByName("Best Bud Ball")

--[[
things I'm not adding here are:
- throw-related variables on init
- lift item down when damaged
- keep holding item up on new room
- hold cooldown decrease
- lift item down on certain item use
the reason for this is that all this stuff is already written down in item_spool.lua, and this item uses the same system
]]

--check if player already spawned a ball, so the thing won't spawn them infinitely
local function playersBBBExists(_player)
	local ballz = Isaac.FindByType(1000, 81, 2000, false, false)
	for i=1, #ballz do
		local player = ballz[i].SpawnerEntity:ToPlayer()
		if player.Index == _player.Index then
			return true
		end
	end
	return false
end

--on use lift up/down
function mod:bbbUse(item, rng, player, useflags, slot, customvardata)
	local data = mod:GetData(player)
	if (data.holdCoolDown == 0) and (not playersBBBExists(player)) then
		if data.heldItem ~= bestBudBall then
			player:AnimateCollectible(bestBudBall, "LiftItem", "PlayerPickupSparkle")
			data.heldItem = bestBudBall
			data.itemSlot = slot
		else
			player:AnimateCollectible(bestBudBall, "HideItem", "PlayerPickupSparkle")
			data.heldItem = 0
		end	
		data.holdCoolDown = 2
		sfx:Play(SoundEffect.SOUND_FETUS_JUMP, 0.8, 0, false, 1)
	end	
	return  { Discharge = false, Remove = false, ShowAnim = false }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.bbbUse, bestBudBall)
--throw
local vecDir = {[Direction.NO_DIRECTION] = Vector(0, 0), [Direction.UP] = Vector(0, -1), [Direction.DOWN] = Vector(0, 1), [Direction.LEFT] = Vector(-1, 0),[Direction.RIGHT] = Vector(1, 0)}
function mod:bbbUpdate(player)
	local data = mod:GetData(player)
	if (data.heldItem) and (data.heldItem == bestBudBall) then
		local dir = player:GetFireDirection()
		if dir ~= Direction.NO_DIRECTION then
			--shoot ball
			local ball = Isaac.Spawn(1000, 81, 2000, player.Position, vecDir[dir]*12, player):ToEffect()
			if data.caughtBossType ~= -1 then
				ball:GetData().isFull = true
			end
			--
			data.heldItem = 0
			sfx:Play(SoundEffect.SOUND_FETUS_JUMP, 0.8, 0, false, 1)
			player:AnimateCollectible(bestBudBall, "HideItem", "PlayerPickupSparkle")
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.bbbUpdate)

--ball itself
--init
function mod:bbbEffectInit(eff)
	if eff.SubType == 2000 then
		eff:GetData().touchedMonster = false
		eff:GetData().hasDied = false
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.bbbEffectInit, 81)

function mod:bbbEffectUpdate(eff)
	if eff.SubType == 2000 then
		local data = eff:GetData()
		local player = eff.SpawnerEntity:ToPlayer()
		local playerData = mod:GetData(player)
		--trail
		if (eff.FrameCount % 2 == 0) then
			local trail = Isaac.Spawn(1000, 111, 0, Vector(eff.Position.X, eff.Position.Y+eff.m_Height), Vector(0,0), eff):ToEffect()
			local oldColor = trail:GetSprite().Color 
			local newColor = Color(oldColor.R, oldColor.G, oldColor.B, oldColor.A, oldColor.RO, oldColor.GO, oldColor.BO) 
			newColor:SetColorize(1, 1, 1, 1)
			newColor:SetOffset(0.70, 0.18, 0.69)
			trail:GetSprite().Color = newColor 
			trail.DepthOffset = -100
			trail:Update()
		end
		--touch
		if (data.touchedMonster == false) and (not data.isFull) then 
			local enemies = Isaac.FindInRadius(eff.Position, eff.Size+10, EntityPartition.ENEMY)
			for i=1, #enemies do
				local ent = enemies[i]:ToNPC()
				if (ent:IsBoss()) and (ent:IsVulnerableEnemy()) and (not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
					ent:Remove()
					playerData.caughtBossType = ent.Type
					playerData.caughtBossVariant = ent.Variant
					playerData.caughtBossSubType = ent.SubType
					data.touchedMonster = true
				end
			end
		end
		--death
		if (eff:IsDead()) and (data.hasDied == false) then
			if data.isFull then
				if playerData.caughtBossType == 412 then
					--delirium automatically clears charmed flag, so I'm making a special interaction with him
					game:ShowHallucination(3, 0)
					local bossTypes = {20, 43, 43, 36, 46, 46, 52, 52, 46, 50, 50, 47, 47, 48, 48, 49, 49, 51, 51, 65, 63, 64, 65, 66, 67, 67, 68, 68, 69, 69, 74, 71, 71, 79, 79, 79, 81, 81, 82, 84, 99, 100, 100, 102, 102, 237, 237, 260, 261, 261, 262, 263, 264, 265, 267, 268, 270, 269, 269, 271, 271, 272, 272, 401, 402, 403, 404, 405, 409, 413, 901, 902, 904, 905, 908, 909, 910, 913, 914, 915, 916, 917, 920}
					local bossVariants = {0, 0, 1, 0, 0, 1, 0, 1, 2, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 2, 0, 1, 0, 0, 0, 0, 1, 0, 1, 1, 2, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
					local rng = Isaac.GetPlayer(0):GetCollectibleRNG(bestBudBall)
					local bossChoice = rng:RandomInt(#bossTypes)+1
					local boss = Isaac.Spawn(bossTypes[bossChoice], bossVariants[bossChoice], 0, eff.Position, Vector(0,0), player):ToNPC()
					boss:AddEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM | EntityFlag.FLAG_PERSISTENT)
					boss:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					-- I wanted to make it also give bosses delirious sprite, but I don't know how to do it ;-; . maybe that'll be added in future update when I figure it out
				else
					--if NOT delirium
					local boss = Isaac.Spawn(playerData.caughtBossType, playerData.caughtBossVariant, playerData.caughtBossSubType, eff.Position, Vector(0,0), player):ToNPC()
					boss:AddEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM | EntityFlag.FLAG_PERSISTENT)
					boss:ClearEntityFlags(EntityFlag.FLAG_APPEAR)	
				end
				playerData.caughtBossType = -1
				playerData.caughtBossVariant = -1
				playerData.caughtBossSubType = -1			
				player:RemoveCollectible(bestBudBall)
				sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 0.8, 0, false, 1)
				--book of virtues synergy
				if (player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)) then
					player:AddWisp(bestBudBall, player.Position, false, false)
				end
			end
			local poof = Isaac.Spawn(1000, 15, 0, eff.Position, Vector(0,0), nil)
			poof:GetSprite().Color = Color(1, 1, 1, 1, 0.53, 0.05, 0.70)
			poof.SpriteScale = poof.SpriteScale*0.85
			poof:Update()
			sfx:Play(SoundEffect.SOUND_SUMMON_POOF, 2, 0, false, 1)
			data.hasDied = true
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.bbbEffectUpdate, 81)