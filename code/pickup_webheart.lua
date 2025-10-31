local mod = ARACHNAMOD
local arachnaChar = Isaac.GetPlayerTypeByName("Arachna", false)
local arachnaChar_b = Isaac.GetPlayerTypeByName("Arachna", true)
local game = ARACHNAMOD.game
local sfx = ARACHNAMOD.sfx
local webHeartUI = Sprite()
webHeartUI:Load("gfx/web_heart_ui.anm2",true)

--constant check
function mod:webHeartsApply(player)
	local data = mod:GetData(player)
	if data.webHearts then
		--Isaac.ConsoleOutput(tostring(mod:GetData(player).webHearts) .. "\n")
		--for arachna, turn red, eternal, rotten and bone health into web health
		if (player:GetPlayerType() == arachnaChar) or (player:GetPlayerType() == arachnaChar_b) then
			if getRedContainers(player) > 0 then
				player:AddMaxHearts(-2)
				addWebHearts(1, player)
			end
			if player:GetBoneHearts() > 0 then
				addWebHearts(1, player)
				player:AddBoneHearts(-1)
			end
			if player:GetEternalHearts() > 0 then
				addWebHearts(1, player)
				player:AddEternalHearts(-1)
			end
			--[[if player:GetRottenHearts() > 0 then
				player:AddRottenHearts(-1)
			end]]
		end
		player = player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN and player:GetSubPlayer() or player
		--foe keepers and alt maggy
		if (data.webHearts > 0) and (player:GetPlayerType() == PlayerType.PLAYER_KEEPER or player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B or player:GetPlayerType() == PlayerType.PLAYER_MAGDALENE_B) then
			for i=1, 2 do
				local nearPos = Isaac.GetFreeNearPosition(player.Position + Vector(mod:GetRandomNumber(-100, 100, mod.Globals.garbageRNG), mod:GetRandomNumber(-100, 100, mod.Globals.garbageRNG)), 50)
				player:ThrowBlueSpider(player.Position, nearPos)
			end			
			addWebHearts(-1, player)
		end
		--for everyone
		if (data.webHearts > 0) and (not canPickWebHearts(player)) and (not isMaxHP(player))then
			addWebHearts(-1, player)
		end
		local ExtraHearts = math.ceil((player:GetSoulHearts() - mod.ImmortalHearts(player)) / 2) + player:GetBoneHearts()
		local soulToMove = 0
		local bones = 0
		for i = ExtraHearts - data.webHearts, ExtraHearts do
			if player:IsBoneHeart(i) then
				bones = bones + 1
			else
				soulToMove = soulToMove + 1
			end
		end
		if bones > 0 and soulToMove > 0 then
			player:AddSoulHearts(-soulToMove * 2)
			player:AddSoulHearts(soulToMove * 2)
		end
		if data.webHearts > math.ceil((player:GetSoulHearts() - mod.ImmortalHearts(player)) / 2) then
			data.webHearts = math.ceil((player:GetSoulHearts() - mod.ImmortalHearts(player)) / 2)
		end
		--if below 0
		if (data.webHearts < 0) then
			data.webHearts = 0
		end
	end
	--for alt jacob
	local webHeartPause = mod:GetData(player).webHeartPause
	if (webHeartPause ~= nil) and (webHeartPause > 0) then
		webHeartPause = webHeartPause - 1
	end
end
--mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, mod.webHeartsApply)

--on touch with dark esau
function mod:webHeartsOnJacob(npc, collider, npc_hit_first, entityType)
    local player = collider:ToPlayer()
	if player then
        if (player:GetPlayerType() == PlayerType.PLAYER_JACOB or player:GetPlayerType() == PlayerType.PLAYER_JACOB_B) and (npc.Type == 866) then
			mod:GetData(player).webHeartPause = 2
        end
    end
end
--mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, mod.webHeartsOnJacob)

--on damage
CustomHealthAPI.Library.AddCallback("ArachnaMOD", CustomHealthAPI.Enums.Callbacks.POST_HEALTH_DAMAGED, 0, function(player, flags, key, hpDamaged, wasDepleted, wasLastDamaged)
	if key == "HEART_WEB" then
		if wasDepleted then
			local spiderType = 0
			if player:GetGoldenHearts() > 0 then
				spiderType = 7
			end
			local rng = player:GetCollectibleRNG(Isaac.GetItemIdByName("Yarn Heart"))
			for i=1, mod:GetRandomNumber(2, 6, rng) do
				local nearPos = Isaac.GetFreeNearPosition(player.Position + Vector(mod:GetRandomNumber(-100, 100, mod.Globals.garbageRNG), mod:GetRandomNumber(-100, 100, mod.Globals.garbageRNG)), 50)
				throwSpecialSpider(player, spiderType, player.Position, nearPos)
			end
			--visual/sound effects 
			local eff = Isaac.Spawn(1000, 16, 0, player.Position, Vector(0,0), player):ToEffect()
			eff:GetSprite().Color = Color(0, 1, 1, 0.5, 1, 1, 1)
			eff.DepthOffset = 250
			eff:Update()
			local eff = Isaac.Spawn(1000, 2, 0, player.Position, Vector(0,0), player):ToEffect()
			eff:GetSprite().Color = Color(0, 1, 1, 0.5, 1, 1, 1)
			eff.DepthOffset = 250
			eff:Update()
			game:SpawnParticles(player.Position, 5, mod:GetRandomNumber(5, 10, mod.Globals.garbageRNG), 4, Color(1, 1, 1, 1, 1, 1, 1))
			game:ShakeScreen(16)
			sfx:Play(SoundEffect.SOUND_MEATY_DEATHS , 0.8, 0, false, 1.25)
			sfx:Play(SoundEffect.SOUND_BOIL_HATCH, 1, 0, false, 1)
			--blood bombds
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BLOOD_BOMBS) then
				if flags == DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_ISSAC_HEART | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_IV_BAG then
					player:FireBomb(player.Position, Vector(0,0), player)
				end
			end
			--fake damage
			game:GetLevel():SetStateFlag(LevelStateFlag.STATE_DAMAGED, true) --for perfection
			player:SetMinDamageCooldown(60)
			--player:GetSprite():Play("Hit")
		end
	end
end)

--pickup itself (and it's double version)
--on touch
function mod.webHeartPickupTouch(_, pickup, collider)
	if ((pickup.Variant == 2000) or (pickup.Variant == 2002)) and collider.Type == EntityType.ENTITY_PLAYER then
		local player = collider:ToPlayer()
		local requiredSpace = 1
		if (pickup.Variant == 2002) then
			requiredSpace = 2
		end
		player = player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B and player:GetMainTwin() or player
		if player and player:GetPlayerType() ~= PlayerType.PLAYER_THELOST and player:GetPlayerType() ~= PlayerType.PLAYER_THELOST_B and canPickWebHearts(player) and player:CanPickSoulHearts() and (getFreeContainterAmount(player) >= requiredSpace*1) then
			--if pickup is paid
			if (pickup.Price > 0) then
				--normal price (take money)
				if player:GetNumCoins() >= pickup.Price then
					player:AddCoins(-pickup.Price)
				else
					--no collision if not enough money
					return nil
				end
			elseif (pickup.Price < 0) then
				--devil price (take damage)
				player:TakeDamage(2, 268435584, EntityRef(pickup), 30)
				player:SetMinDamageCooldown(30)
			end
			--maggy's bow synergy 4 arachna
			local data = mod:GetData(player)
			local bowMul = 1
			if ((player:GetPlayerType() == arachnaChar) or (player:GetPlayerType() == arachnaChar_b)) and (player:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW)) and (getFreeContainterAmount(player) >= requiredSpace*2) then
				bowMul = 2
			end
			--apply hearts
			if (pickup.Variant == 2000) then
				addWebHearts(1*bowMul, player)
			elseif (pickup.Variant == 2002) then
				addWebHearts(2*bowMul, player)
			end
			pickup:GetSprite():Play("Collect")
			pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			pickup:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
			sfx:Play(SoundEffect.SOUND_SPIDER_SPIT_ROAR, 0.8, 0, false, 1)
		end
	end
end
--mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.webHeartPickupTouch)

function mod:WebPickupCollisionNew(pickup, collider)
	if pickup.Variant == 2000 or pickup.Variant == 2002 then
		if collider.Type == EntityType.ENTITY_PLAYER then
			local player = collider:ToPlayer()
			local sprite = pickup:GetSprite()
			
			if pickup:IsShopItem() and (pickup.Price > player:GetNumCoins() or not player:IsExtraAnimationFinished()) then
				return true
			elseif sprite:IsPlaying("Collect") then
				return true
			elseif pickup.Wait > 0 then
				return not sprite:IsPlaying("Idle")
			elseif sprite:WasEventTriggered("DropSound") or sprite:IsPlaying("Idle") then
				if pickup.Price == PickupPrice.PRICE_SPIKES then
					local tookDamage = player:TakeDamage(0, 268435584, EntityRef(nil), 30)
					if not tookDamage then
						return pickup:IsShopItem()
					end
				end

				if canPickWebHearts(player) then
					local bowMul = 1
					if ((player:GetPlayerType() == arachnaChar) or (player:GetPlayerType() == arachnaChar_b)) and (player:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW)) and (getFreeContainterAmount(player) >= requiredSpace*2) then
						bowMul = 2
					end
					if pickup.Variant == 2002 then
						addWebHearts(2*bowMul,player)
					else
						addWebHearts(1*bowMul,player)
					end
					sfx:Play(SoundEffect.SOUND_SPIDER_SPIT_ROAR, 0.8, 0, false, 1)
				else
					return pickup:IsShopItem()
				end

				if pickup.OptionsPickupIndex ~= 0 then
					local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)
					for _, entity in ipairs(pickups) do
						if entity:ToPickup().OptionsPickupIndex == pickup.OptionsPickupIndex and
						   (entity.Index ~= pickup.Index or entity.InitSeed ~= pickup.InitSeed)
						then
							Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
							entity:Remove()
						end
					end
				end

				if pickup:IsShopItem() then
					local pickupSprite = pickup:GetSprite()
					local holdSprite = Sprite()
					
					holdSprite:Load(pickupSprite:GetFilename(), true)
					holdSprite:Play(pickupSprite:GetAnimation(), true)
					holdSprite:SetFrame(pickupSprite:GetFrame())
					player:AnimatePickup(holdSprite)
					
					if pickup.Price > 0 then
						player:AddCoins(-1 * pickup.Price)
					end
					
					CustomHealthAPI.Library.TriggerRestock(pickup)
					CustomHealthAPI.Helper.TryRemoveStoreCredit(player)
					
					pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					pickup:Remove()
				else
					sprite:Play("Collect", true)
					pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					pickup:Die()
				end
				
				game:GetLevel():SetHeartPicked()
				game:ClearStagesWithoutHeartsPicked()
				game:SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)
				
				return true
			else
				return false
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.WebPickupCollisionNew)
--update
function mod.webHeartPickupUpdate(_, pickup)
	if (pickup.Variant == 2000) or (pickup.Variant == 2002) then
		local sprite = pickup:GetSprite()
		local data = pickup:GetData()
		--init replace
		if not data.init then
			if everyoneIsKeeper() then
				if (pickup.Variant == 2000) then
					for i=1, 2 do
						local spider = Isaac.Spawn(3, 73, 0, pickup.Position, Vector(0,0), pickup):ToFamiliar()
						spider:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					end
				elseif (pickup.Variant == 2002) then
					for i=1, 4 do
						local spider = Isaac.Spawn(3, 73, 0, pickup.Position, Vector(0,0), pickup):ToFamiliar()
						spider:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					end				
				end
				pickup:Remove()
			end
			data.init = true
		end
		--triggers
		if sprite:IsEventTriggered("DropSound") then
			sfx:Play(SoundEffect.SOUND_FETUS_JUMP, 1, 0, false, 3) 
		end
		--destroy
		if sprite:IsFinished("Collect")then
			pickup:Remove()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.webHeartPickupUpdate)

--pickup morph
function mod.webHeartMorph(_, pickup)
	if someoneIsArachna() then
		if (pickup.Variant == 10 and pickup.SubType == 	4) or (pickup.Variant == 10 and pickup.SubType == 11) or (pickup.Variant == 10 and pickup.SubType == 12) then
			local rng = RNG()
			rng:SetSeed(pickup.InitSeed, 35)
			if (rng:RandomInt(100)+1 <= 5) then
				pickup:Morph(5, 2002, 0, true, true) --double
			else
				pickup:Morph(5, 2000, 0, true, true) --single
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.webHeartMorph)

--abaddon synergy
function mod:webHeartAbaddonConvert(player)
	local data = mod:GetData(player)
	if (data.hasAbaddon ~= nil) then
		if (data.hasAbaddon < player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ABADDON, true)) then
			while data.webHearts > 0 do
				player:AddBlackHearts(2)
				addWebHearts(-1, player)
			end
			data.hasAbaddon = data.hasAbaddon + 1
		elseif (data.hasAbaddon > player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ABADDON, true)) then
			data.hasAbaddon = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ABADDON, true)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.webHeartAbaddonConvert)

--dead cat on arachna
function mod:webHeartDeadCat(player)
	local data = mod:GetData(player)
	if (data.hasDeadCat ~= nil) then
		if (data.hasDeadCat < player:GetCollectibleNum(CollectibleType.COLLECTIBLE_DEAD_CAT, true)) then
			if ((player:GetPlayerType() == arachnaChar) or (player:GetPlayerType() == arachnaChar_b)) then
				addWebHearts(1, player)
				player:AddSoulHearts(-1*(player:GetSoulHearts()))
			end
			data.hasDeadCat = data.hasDeadCat + 1
		elseif (data.hasDeadCat > player:GetCollectibleNum(CollectibleType.COLLECTIBLE_DEAD_CAT, true)) then
			data.hasDeadCat = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_DEAD_CAT, true)
		end
	end
end
--mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.webHeartDeadCat)

--strength card on arachna
function mod:useStrength(card, player)
	if ((player:GetPlayerType() == arachnaChar) or (player:GetPlayerType() == arachnaChar_b)) then
		mod:GetData(player).usedStrength = mod:GetData(player).usedStrength + 1
		if hasOnlyWebHP(player) then
			player:AddSoulHearts(2)
		end
	end
end
--mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useStrength, Card.CARD_STRENGTH)
function mod:arachnaStrengthOnNewRoom()
	for i=0, game:GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(i)
		arachnaClearStrength(player)
	end
end
--mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.arachnaStrengthOnNewRoom)

--guppy's paw on arachna
function mod:arachnaGuppyPawPressSpace(player)
	if (player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == CollectibleType.COLLECTIBLE_GUPPYS_PAW) and (Input.IsActionTriggered(ButtonAction.ACTION_ITEM, player.ControllerIndex)) then
		if (getWebHearts(player) > 0) and ((player:GetPlayerType() == arachnaChar) or (player:GetPlayerType() == arachnaChar_b)) then
			player:AddSoulHearts(6)
			addWebHearts(-1, player)
			player:AnimateCollectible(CollectibleType.COLLECTIBLE_GUPPYS_PAW, "UseItem")
			sfx:Play(SoundEffect.SOUND_VAMP_GULP , 1, 0, false, 0.8)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, mod.arachnaGuppyPawPressSpace)