local mod = ARACHNAMOD
local arachnaChar = Isaac.GetPlayerTypeByName("Arachna", false)
local arachnaChar_b = Isaac.GetPlayerTypeByName("Arachna", true)
local webHeartUI = Sprite()
webHeartUI:Load("gfx/web_heart_ui.anm2",true)
--applying hearts
mod.SavedData.playerWebHealth = {}
mod.SavedData.hasAbaddon = {}
mod.SavedData.hasDeadCat = {}
mod.SavedData.usedStrength = {}
local json = require("json")
local screenHelper = require("code.screenhelper")
--applying hearts
function mod:webHeartsGameStart(isContinued) 
	if isContinued then
		--get data from save
		if mod:HasData() then
			mod.SavedData = json.decode(Isaac.LoadModData(mod))
			for i=0, game:GetNumPlayers()-1 do
				local player = Isaac.GetPlayer(i)
				local data = mod:GetData(player)
				if mod.SavedData.playerWebHealth[tostring(i)] == nil then mod.SavedData.playerWebHealth[tostring(i)] = 0 end
				data.webHearts = mod.SavedData.playerWebHealth[tostring(i)]
				data.hasAbaddon = mod.SavedData.hasAbaddon[tostring(i)]
				data.hasDeadCat = mod.SavedData.hasDeadCat[tostring(i)] 
				data.usedStrength = mod.SavedData.usedStrength[tostring(i)]
			end
			--Isaac.ConsoleOutput("GOT DATA FROM SAVE! \n")
		end
	else
		--set values to default
		for i=0, game:GetNumPlayers()-1 do
			local player = Isaac.GetPlayer(i)
			local data = mod:GetData(Isaac.GetPlayer(i))
			--[[if player:GetPlayerType() == arachnaChar then
				data.webHearts = 2
			elseif player:GetPlayerType() == arachnaChar_b then
				data.webHearts = 3
			else]]
			if (not data.webHearts) then
				data.webHearts = 0
			end
			--end
			data.hasAbaddon = 0
			data.hasDeadCat = 0
			data.usedStrength = 0
			--Isaac.ConsoleOutput("VALUES SET TO DEFAULT! \n")
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.webHeartsGameStart)
function mod:webHeartsGameExit(shouldSave) 
	--clear strength effect
	for i=0, game:GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(i)
		arachnaClearStrength(player)
	end
	--save data
	if shouldSave then
		for i=0, game:GetNumPlayers()-1 do
			local player = Isaac.GetPlayer(i)
			local data = mod:GetData(Isaac.GetPlayer(i))
			mod.SavedData.playerWebHealth[tostring(i)] = data.webHearts
			mod.SavedData.hasAbaddon[tostring(i)] = data.hasAbaddon
			mod.SavedData.hasDeadCat[tostring(i)] = data.hasDeadCat
			mod.SavedData.usedStrength[tostring(i)] = data.usedStrength
		end
		mod.SaveData(mod, json.encode(mod.SavedData))
		--Isaac.ConsoleOutput("DATA SAVED! \n")
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.webHeartsGameExit)
function mod:webHeartsNewLvl()
	local level = game:GetLevel()
	if (level:GetStage() ~= 1) and (not level:IsAltStage()) and (not level:IsAscent()) then
		--save data
		for i=0, game:GetNumPlayers()-1 do
			local player = Isaac.GetPlayer(i)
			local data = mod:GetData(Isaac.GetPlayer(i))
			mod.SavedData.playerWebHealth[tostring(i)] = data.webHearts
			mod.SavedData.hasAbaddon[tostring(i)] = data.hasAbaddon
			mod.SavedData.hasDeadCat[tostring(i)] = data.hasDeadCat
			mod.SavedData.usedStrength[tostring(i)] = data.usedStrength
		end
		mod.SaveData(mod, json.encode(mod.SavedData))
		--Isaac.ConsoleOutput("DATA SAVED! \n")
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.webHeartsNewLvl)
function mod:webHeartsGameEnd(isGameOver) 
	--clear data
	mod.SavedData.playerWebHealth = {}
	mod.SavedData.hasAbaddon = {}
	mod.SavedData.hasDeadCat = {}
	mod.SavedData.usedStrength = {}
	mod.SaveData(mod, json.encode(mod.SavedData))
	--Isaac.ConsoleOutput("DATA CLEARED! \n")
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_END, mod.webHeartsGameEnd)
--co-op players
function mod:webHeartInitPlayerTwo(player)
	if (player.Index~=0) and (not mod:GetData(player).webHearts) then
		mod:GetData(player).webHearts = 0
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.webHeartInitPlayerTwo)
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
				local nearPos = Isaac.GetFreeNearPosition(player.Position + Vector(math.random(-100, 100), math.random(-100, 100)), 50)
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
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, mod.webHeartsApply)

--on touch with dark esau
function mod:webHeartsOnJacob(npc, collider, npc_hit_first, entityType)
    local player = collider:ToPlayer()
	if player then
        if (player:GetPlayerType() == PlayerType.PLAYER_JACOB or player:GetPlayerType() == PlayerType.PLAYER_JACOB_B) and (npc.Type == 866) then
			mod:GetData(player).webHeartPause = 2
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, mod.webHeartsOnJacob)

--on damage
function mod:webHeartsDamage(ent, amount, flags, source, countdown)
	local player = ent:ToPlayer()
	if (flags & DamageFlag.DAMAGE_FAKE == DamageFlag.DAMAGE_FAKE) then
		return true
	end
	if (player) then
		--Isaac.ConsoleOutput(tostring(flags) .. " " .. tostring(source) .. " " .. tostring(countdown))
		local data = mod:GetData(player)
		local hasImmortalHeart = false
		if ComplianceImmortal then
			hasImmortalHeart = ComplianceImmortal.GetImmortalHearts(player) > 0 and true or false
		end
		--if (data.webHearts > 0) and (flags ~= DamageFlag.DAMAGE_FAKE) 
		player = player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B and player:GetOtherTwin() or player
		if data.webHearts and data.webHearts > 0 and flags & DamageFlag.DAMAGE_FAKE ~= DamageFlag.DAMAGE_FAKE and not (( 
		flags & DamageFlag.DAMAGE_RED_HEARTS == DamageFlag.DAMAGE_RED_HEARTS or player:HasTrinket(TrinketType.TRINKET_CROW_HEART)) and player:GetHearts() > 0) and
		not (player:GetEffects():HasCollectibleEffect(NullItemID.ID_HOLY_CARD) or player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)) 
		and (player:GetPlayerType() ~= PlayerType.PLAYER_THELOST and player:GetPlayerType() ~= PlayerType.PLAYER_THELOST_B
		and player:GetPlayerType() ~= PlayerType.PLAYER_JACOB2_B and player:GetPlayerType() ~= PlayerType.PLAYER_THEFORGOTTEN)
		and (data.webHeartPause == nil or data.webHeartPause <= 0)
		and not hasImmortalHeart and not data.WebDamage then
			--actual heart effect
			--addWebHearts(-1, player)
			local spiderType = 0
			if player:GetGoldenHearts() > 0 then
				spiderType = 7
			end
			for i=1, math.random(2,6) do
				local nearPos = Isaac.GetFreeNearPosition(player.Position + Vector(math.random(-100, 100), math.random(-100, 100)), 50)
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
			game:SpawnParticles(player.Position, 5, math.random(5, 10), 4, Color(1, 1, 1, 1, 1, 1, 1))
			game:ShakeScreen(16)
			sfx:Play(SoundEffect.SOUND_MEATY_DEATHS , 0.8, 0, false, 1.25)
			sfx:Play(SoundEffect.SOUND_BOIL_HATCH, 1, 0, false, 1)
			--blood bombds
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BLOOD_BOMBS) then
				if flags == DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_ISSAC_HEART | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_IV_BAG then
					player:FireBomb(player.Position, Vector(0,0), player)
				end
			end
			--perfection
			if player:HasTrinket(TrinketType.TRINKET_PERFECTION) then
				player:TryRemoveTrinket(TrinketType.TRINKET_PERFECTION)
				sfx:Play(SoundEffect.SOUND_THUMBS_DOWN, 0.8, 0, false, 1)
			end
			--t eden
			if player:GetPlayerType() == PlayerType.PLAYER_EDEN_B then
				player:UseActiveItem(CollectibleType.COLLECTIBLE_D4, false, false, true, false, -1)
			end
			--fake damage
			game:GetLevel():SetStateFlag(LevelStateFlag.STATE_DAMAGED, true) --for perfection
			data.WebDamage = true
			data.webHearts = data.webHearts - 1
			local NumSoulHearts = player:GetSoulHearts() - (1 - player:GetSoulHearts() % 2)
			player:RemoveBlackHeart(NumSoulHearts)
			player:TakeDamage(2, flags | DamageFlag.DAMAGE_NO_PENALTIES, source, countdown)
			player:SetMinDamageCooldown(60)
			--player:GetSprite():Play("Hit")
			return false
		end
		if data.WebDamage then
			data.WebDamage = nil
		end
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.webHeartsDamage)

local function renderingHearts(player,playeroffset)
	local data =mod:GetData(player)
	local ImmortalHeart = 0
	if ComplianceImmortal then
		ImmortalHeart = ComplianceImmortal.GetImmortalHearts(player) > 0 and 2 or 0
	end
	local isForgotten = player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN and 1 or 0
	local transperancy = 1
	local level = game:GetLevel()
	if player:GetPlayerType() == PlayerType.PLAYER_JACOB2_B or player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) or isForgotten == 1 then
		transperancy = 0.3
	end
	if level:GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN == 0 and data.webHearts and data.webHearts > 0 then
		player = isForgotten == 1 and player:GetSubPlayer() or player
		local hearts = getRedContainers(player) + player:GetSoulHearts()
		local offset = player:GetSoulHearts() % 2 == 1 and 6 or 0
		local goldenHearts = player:GetGoldenHearts()
		for i = 0, data.webHearts - 1 do
			local playersHeartPos = {
				[1] = Options.HUDOffset * Vector(20, 12) + Vector(((hearts-ImmortalHeart)*6-i*12)+36 + offset, 12) + Vector(0,10) * isForgotten,
				[2] = screenHelper.GetScreenTopRight(0) + Vector(((hearts-ImmortalHeart)*6-i*12)-123 + offset,12) + Options.HUDOffset * Vector(-20*1.2, 12) + Vector(0,20) * isForgotten,
				[3] = screenHelper.GetScreenBottomLeft(0) + Vector(((hearts-ImmortalHeart)*6-i*12)+46 + offset,-27) + Options.HUDOffset * Vector(20*1.1, -12*0.5) + Vector(0,20) * isForgotten,
				[4] = screenHelper.GetScreenBottomRight(0) + Vector(((hearts-ImmortalHeart)*6-i*12)-131 + offset,-27) + Options.HUDOffset * Vector(-20*0.8, -12*0.5) + Vector(0,20) * isForgotten,
				[5] = screenHelper.GetScreenBottomRight(0) + Vector(((-(hearts-ImmortalHeart))*6+i*12)-36 - offset,-27) + Options.HUDOffset * Vector(-20*0.8, -12*0.5)
			}
			local offset = playersHeartPos[playeroffset]
			local offsetCol = (playeroffset == 1 or playeroffset == 5) and 13 or 7
			offset.X = offset.X  - (math.floor((hearts - i * 2) / offsetCol)) * (playeroffset == 5 and (-72) or (playeroffset == 1 and 72 or 36))
			offset.Y = offset.Y + (math.floor((hearts - i * 2) / offsetCol)) * 10
			webHeartUI.Color = Color(1,1,1,transperancy)
			--[[local rendering = ImmortalSplash.Color.A > 0.1 or game:GetFrameCount() < 1
			if game:IsPaused() then
				pauseColorTimer = pauseColorTimer + 1
				if pauseColorTimer >= 20 and pauseColorTimer <= 30 and rendering then
					ImmortalSplash.Color = Color.Lerp(ImmortalSplash.Color,Color(1,1,1,0.1),0.1)
				end
			else
				pauseColorTimer = 0
				ImmortalSplash.Color = Color(1,1,1,transperancy)
			end]]
			local playSprite = "UI"
			if goldenHearts > 0 then
				playSprite = playSprite.."_Gold"
				goldenHearts = goldenHearts - 1
			end
			webHeartUI:Play(playSprite, true)
			webHeartUI.FlipX = playeroffset == 5
			webHeartUI:Render(Vector(offset.X, offset.Y), Vector(0,0), Vector(0,0))
		end
	end
end


--local switch = false
function mod:onRender(shadername)
	if shadername ~= "Web Hearts" then return end
	
	--if versusScreenPlaying() then return end
	if Input.IsButtonTriggered(Keyboard.KEY_PAGE_UP,0) then
		notShow = not notShow
	end
	
	if mod:shouldDeHook() then return end
	local players = 0
	local isJacobFirst = false
	for i = 0, game:GetNumPlayers() - 1 do
		if players < 4 then
			local player = Isaac.GetPlayer(i)
			local data = mod:GetData(player)
			if players == 0 and player:GetPlayerType() == PlayerType.PLAYER_JACOB then
				isJacobFirst = true
			end
			if (player:GetPlayerType() == PlayerType.PLAYER_LAZARUS_B or player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B) then
				if player:GetOtherTwin() then
					if data.i and data.i == i then
						data.i = nil
					end
					if not data.i then
						local otherTData = mod:GetData(player:GetOtherTwin())
						otherTData.i = i
					end
				elseif data.i then
					data.i = nil
				end
			end
			local playeroffset
			local isIllusion = player:GetData().IllusionMod and player:GetData().IllusionMod.IsIllusion
			if  player:GetPlayerType() ~= PlayerType.PLAYER_THESOUL_B and not isIllusion and not data.i then
				if player:GetPlayerType() ~= PlayerType.PLAYER_ESAU then
					players = players + 1
					playeroffset = players
				end
				if player:GetPlayerType() == PlayerType.PLAYER_ESAU and isJacobFirst then
					renderingHearts(player,5)	
				elseif player:GetPlayerType() ~= PlayerType.PLAYER_ESAU then
					renderingHearts(player,playeroffset)
				end
			end
		end
	end

end

mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, mod.onRender)

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
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.webHeartPickupTouch)
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
			if (math.random(1, 100) <= 5) then
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

function mod:webHeartHandling(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
		player = player:GetSubPlayer()
	end
	local data = mod:GetData(player)
	player = player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN and player:GetSubPlayer() or player
	if data.webHearts and data.webHearts > 0 then
		local imHearts = 0
		if ComplianceImmortal then
			imHearts = math.ceil(ComplianceImmortal.GetImmortalHearts(player)/2)
		end
		data.webHearts = data.webHearts > (math.ceil(player:GetSoulHearts()/2) - imHearts) and (math.ceil(player:GetSoulHearts()/2) - imHearts) or data.webHearts
		local heartIndex = data.webHearts - 1
		for i=0, heartIndex - imHearts do
			local ExtraHearts = math.ceil(player:GetSoulHearts() / 2) + player:GetBoneHearts() - i
			local imHeartLastIndex = player:GetSoulHearts() - (1 - player:GetSoulHearts() % 2) - i * 2
			if (player:IsBoneHeart(ExtraHearts - 1)) or not player:IsBlackHeart(player:GetSoulHearts() - (1 - player:GetSoulHearts() % 2) - i * 2) then
				for j = imHeartLastIndex, imHeartLastIndex - (heartIndex + 1) * 2, -2 do
					player:RemoveBlackHeart(j)
				end
				player:AddSoulHearts(-data.webHearts)
				player:AddBlackHearts(data.webHearts)
			end
		end
		
		if player:GetSoulHearts() % 2 ~= 0 and imHearts == 0 then
			player:AddSoulHearts(1)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.webHeartHandling)

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
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.webHeartDeadCat)

--strength card on arachna
function mod:useStrength(card, player)
	if ((player:GetPlayerType() == arachnaChar) or (player:GetPlayerType() == arachnaChar_b)) then
		mod:GetData(player).usedStrength = mod:GetData(player).usedStrength + 1
		if hasOnlyWebHP(player) then
			player:AddSoulHearts(2)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useStrength, Card.CARD_STRENGTH)
function mod:arachnaStrengthOnNewRoom()
	for i=0, game:GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(i)
		arachnaClearStrength(player)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.arachnaStrengthOnNewRoom)

--guppy's paw on arachna
function mod:arachnaGuppyPawPressSpace(player)
	local data = mod:GetData(player)
	if (player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == CollectibleType.COLLECTIBLE_GUPPYS_PAW) and (Input.IsActionTriggered(ButtonAction.ACTION_ITEM, player.ControllerIndex)) then
		if (data.webHearts > 0) and ((player:GetPlayerType() == arachnaChar) or (player:GetPlayerType() == arachnaChar_b)) then
			player:AddSoulHearts(6)
			addWebHearts(-1, player)
			player:AnimateCollectible(CollectibleType.COLLECTIBLE_GUPPYS_PAW, "UseItem")
			sfx:Play(SoundEffect.SOUND_VAMP_GULP , 1, 0, false, 0.8)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, mod.arachnaGuppyPawPressSpace)