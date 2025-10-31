local mod = ARACHNAMOD
local game = ARACHNAMOD.game
local sfx = ARACHNAMOD.sfx

local function CanOnlyHaveSoulHearts(player)
	if player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY
	or player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY_B or player:GetPlayerType() == PlayerType.PLAYER_BLACKJUDAS
	or player:GetPlayerType() == PlayerType.PLAYER_JUDAS_B or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B
	or player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B or player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B then
		return true
	end
	return false
end

function mod.ImmortalHearts(_player)
	if _player:GetData().ImmortalHeart then
		if _player:GetData().ImmortalHeart.ComplianceImmortalHeart > 0 then
			return 2
		end
	end
	return 0
end

function addWebHearts(_num, _player)
	CustomHealthAPI.Library.AddHealth(_player,"HEART_WEB",_num*2)
end

function getWebHearts(_player)
	return CustomHealthAPI.Library.GetHPOfKey(_player,"HEART_WEB")
end

function getRedContainers(_player)
	return CanOnlyHaveSoulHearts(_player) and _player:GetBoneHearts() * 2 or _player:GetEffectiveMaxHearts()
end

function canPickWebHearts(_player)
	return CustomHealthAPI.Library.CanPickKey(_player,"HEART_WEB")
end

function isMaxHP(_player)
	local maxHP = _player:GetHeartLimit()
	--[[if playerType == PlayerType.PLAYER_MAGDALENA and _player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		maxHP = 18
	end]]
	local webHeartAmount = getWebHearts(_player)
	local healthAmount = maxHP
	if webHeartAmount then
		healthAmount = _player:GetSoulHearts() + getRedContainers(_player)
	end
	if healthAmount == maxHP then 
		return true
	end
	return false
end

function someoneIsArachna()
	local arachnaChar = Isaac.GetPlayerTypeByName("Arachna", false)
	local arachnaChar_b = Isaac.GetPlayerTypeByName("Arachna", true)
	for i=0, game:GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(i)
		if (player:GetPlayerType() == arachnaChar) or (player:GetPlayerType() == arachnaChar_b) then
			return true
		end
	end
	return false
end

function someonePressedAction(_button, _hold)
	for i=0, game:GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(i)
		if not game:IsPaused() then
			if _hold then
				if Input.IsActionPressed(_button, player.ControllerIndex) then 
					return true
				end
			else
				if Input.IsActionTriggered(_button, player.ControllerIndex) then 
					return true
				end
			end
		end
	end
	return false
end

function hasOnlyWebHP(_player)
	local healthAmount = _player:GetSoulHearts() + getRedContainers(_player)
	if (healthAmount <= 0) and (getWebHearts(_player) > 0) then 
		return true
	end
	return false
end

function myMaxWebPrice(_player)
	local webhearts = getWebHearts(_player)/2
	if not webhearts then webhearts = 0 end
	if webhearts >= 2 then 
		return 2
	elseif webhearts == 1 then
		if math.ceil((_player:GetSoulHearts()-getWebHearts(_player))/2) >= 2 then
			return 1.5
		else
			return 1
		end
	else
		return 0
	end
end

function maxWebPrice()
	local maxprice = 0
	local price = 0
	for i=0, game:GetNumPlayers()-1 do
		maxprice = math.max(maxprice, myMaxWebPrice(Isaac.GetPlayer(i)))
	end
	return maxprice
end

function arachnaHoldsSoul()
	local arachnaChar = Isaac.GetPlayerTypeByName("Arachna", false)
	local arachnaChar_b = Isaac.GetPlayerTypeByName("Arachna", true)
	for i=0, game:GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(i)
		if ((player:GetPlayerType() == arachnaChar) or (player:GetPlayerType() == arachnaChar_b)) and (player:HasTrinket(TrinketType.TRINKET_YOUR_SOUL)) then
			return true
		end
	end
	return false
end

function SomeoneHasItem(itemid)
	for i=0, game:GetNumPlayers()-1 do
		if Isaac.GetPlayer(i):HasCollectible(itemid) then
			return true
		end
	end
	return false
end

function SomeoneHasTrinket(trinketid)
	for i=0, game:GetNumPlayers()-1 do
		if Isaac.GetPlayer(i):HasTrinket(trinketid) then
			return true
		end
	end
	return false
end

function isBlackListed(_item)
	local arachnaBlackList = {  } --update the list
	for i=1, #arachnaBlackList do
		if _item == arachnaBlackList[i] then
			return true
		end
	end
	return false
end

--debuff
function doSpiderBite(_npc, _frames, _playerWhoBit, _addNotSet)
	local data = _npc:GetData()
	if (not _npc:IsBoss()) and (_npc:IsVulnerableEnemy()) and (_npc.Type ~= EntityType.ENTITY_FIREPLACE) and (not _npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
		if not data.spiderBiteTime then
			data.spiderBiteTime = 0
			data.maxBiteTime = 0
		end
		if _addNotSet then
			data.spiderBiteTime = data.spiderBiteTime + _frames
			data.maxBiteTime = data.maxBiteTime + _frames
		else
			data.spiderBiteTime = _frames
			data.maxBiteTime = _frames
		end
		data.bitePar = _playerWhoBit
	end
end

function isBitten(_npc)
	local biteTime = _npc:GetData().spiderBiteTime
	if (biteTime) and (biteTime > 0) then
		return true
	end
	return false
end

function arachnaClearStrength(_player)
	local arachnaChar = Isaac.GetPlayerTypeByName("Arachna", false)
	local arachnaChar_b = Isaac.GetPlayerTypeByName("Arachna", true)
	local data = mod:GetData(_player)
	if ((_player:GetPlayerType() == arachnaChar) or (_player:GetPlayerType() == arachnaChar_b)) and (data.usedStrength ~= nil) then
		while data.usedStrength > 0 do
			if not (hasOnlyWebHP(_player) and getWebHearts(_player) == 1) then
				addWebHearts(-1, _player)
			end			
			data.usedStrength = data.usedStrength - 1
		end
	end
end

function everyoneIsKeeper()
	for i=0, game:GetNumPlayers()-1 do
		local playerType = Isaac.GetPlayer(i):GetPlayerType()
		if (playerType ~= PlayerType.PLAYER_KEEPER and playerType ~= PlayerType.PLAYER_KEEPER_B) then
			return false
		end
	end
	return true
end

function getNearPos(_pos)
	local rng = RNG()
	rng:SetSeed((_pos.X+_pos.Y)*35, 35)
	return Isaac.GetFreeNearPosition(_pos + Vector(mod:GetRandomNumber(-50, 50, rng), mod:GetRandomNumber(-50, 50, rng)), 50)
end

function displayRoomType(_roomtype) --modified version of agent cucco's function
	local level = game:GetLevel()
	for i = 0, 169 do
		local room = level:GetRoomByIdx(i)
		if room.Data
		and room.Data.Type == _roomtype
		then
			if room.DisplayFlags & 1 << 2 == 0 then
				room.DisplayFlags = room.DisplayFlags | 1 << 2 -- Show Icon
				level:UpdateVisibility()
			end
			return
		end
	end
end

function damageAllEnemies(_val, _entityref, _noeffect)
	local enemies = Isaac.GetRoomEntities()
	for i=1, #enemies do
		local enemy = enemies[i]
		if enemy:IsVulnerableEnemy() and not enemy:IsBoss() then
			enemy:TakeDamage(_val, 0, EntityRef(_entityref), 0)
		end
	end
	if #enemies > 0 and not _noeffect then
		game:ShakeScreen(16)
		sfx:Play(SoundEffect.SOUND_MEATY_DEATHS , 0.8, 0, false, 1.25)
	end
end

function doExplosionWithEffects(_plr, _pos, _damage, _vfx, _scale, _notHurtPlayer) 
	local effBomb = _plr:FireBomb(_pos, Vector(0,0), _plr):ToBomb()
	effBomb:SetColor(Color(1, 1, 1, 0, 1, 1, 1), 0, 0, false, false)
	effBomb.ExplosionDamage = _damage
	effBomb:SetExplosionCountdown(0)
	effBomb:GetData().notHurtPlayer = _notHurtPlayer
	if _vfx then
		local boom = Isaac.Spawn(1000, 1, 0, _pos, Vector(0,0), _plr):ToEffect()
		boom.SpriteScale = boom.SpriteScale*_scale
	end
end
function mod:playerOnExplosion(ent, amount, flag, source, num)
	local player = ent:ToPlayer()
	if player and flag == DamageFlag.DAMAGE_EXPLOSION then
		--bombs
		if (source.Type == 4) and (source.Entity:GetData().notHurtPlayer) then
			return false
		end
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.playerOnExplosion);

function isColorSpider(_ent, _isBig)
	if _isBig == nil then
		if _ent.Type == 3 and _ent.Variant == 73 and _ent.SubType >= 1 and _ent.SubType <= 19 and _ent.SubType ~= 10 then
			return true
		end
	elseif _isBig == true then
		if _ent.Type == 3 and _ent.Variant == 73 and _ent.SubType >= 11 and _ent.SubType <= 19 then
			return true
		end
	elseif _isBig == false then
		if _ent.Type == 3 and _ent.Variant == 73 and _ent.SubType >= 1 and _ent.SubType <= 9 then
			return true
		end
	end
	return false
end

--player:ThrowBlueSpider() function but remade for custom subtype support
function throwSpecialSpider(_player, _subtype, _pos, _target)
	local speed = _pos:Distance(_target)/20 -- the number 20 doesn't mean anything specific, I just chose something that felt good in game
	local vel = Vector.FromAngle((_target - _pos):GetAngleDegrees()):Normalized()*speed
	local spider = Isaac.Spawn(3, 73, _subtype, _pos, vel, _player):ToFamiliar()
	spider:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	spider.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	spider.GridCollisionClass = GridCollisionClass.COLLISION_WALL 
	spider:GetData().wasThrown = true
end
function mod:mySpiderFlying(baby)
	if (baby.Type == 3 and baby.Variant == 73) then
		local sprite = baby:GetSprite()
		local data = baby:GetData()
		if data.wasThrown then
			if sprite:IsPlaying("Appear") then
				--variables
				local cappedHeight = -24
				local startFrame = 6 --frame at which height stops to increase and reaches the cap
				local endFrame = 16 - startFrame -- 16 is the length of appear animation
				local curFrame = sprite:GetFrame()
				local spriteHeight = 0
				--height correction
				if (curFrame <= startFrame) then
					spriteHeight = math.sin( curFrame/(startFrame*2/3.1415926535898) ) * cappedHeight
				elseif (curFrame >= endFrame) then
					spriteHeight = math.sin( curFrame/((endFrame-startFrame/2)*2/3.1415926535898) ) * cappedHeight
				else
					spriteHeight = cappedHeight
				end
				baby.SpriteOffset = Vector(0, spriteHeight)
				--set stuff back to normal when animation is over
			else 
				if not data.appearFinished then
					baby.SpriteOffset = Vector(0, 0)
					baby.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES 
					baby.GridCollisionClass = GridCollisionClass.COLLISION_SOLID 
					data.appearFinished = true
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.mySpiderFlying)
--DEBUG
--[[
function mod:mouseShootSpider(player)
	local player = Isaac.GetPlayer(0)
	local mousePos = Input.GetMousePosition()
	if (Input.IsMouseBtnPressed(Mouse.MOUSE_BUTTON_LEFT)) then
		throwSpecialSpider(player, 10, player.Position, mousePos)
	end
	if (Input.IsMouseBtnPressed(Mouse.MOUSE_BUTTON_RIGHT)) then
		player:ThrowBlueSpider(player.Position, mousePos)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.mouseShootSpider)
]]

local function returnElementWithChance(_stuff, _chances, _chance)
	--get max chance value
	local maxVal = 0
	for i = 1, #_stuff do
		maxVal = maxVal + _chances[i]
	end
	--if it's equal to max value, return last element
	if _chance == maxVal then
		return _stuff[#_stuff] 
	end
	--return the right element
	local curMin = 0
	for i = 1, #_stuff do
		for j = curMin, curMin+_chances[i]-1 do
			if j == _chance then
				return _stuff[i]
			end
		end
		curMin = curMin + _chances[i]
	end
	--in case something goes wrong return nil so I could see it in debug console
	--Isaac.ConsoleOutput("[ERR]: CHANCE OUT OF BOUNDS!\n")
	return nil
end

function returnRandomSpiderSubType(_bigColorful, _onlyColor)
	local spiderTypes = {}
	local spiderChances = {}
	if _bigColorful then
		spiderTypes = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19}
		spiderChances = {25, 4, 5, 5, 5, 5, 4, 2, 4, 2, 4, 2, 3, 3, 3, 3, 3, 2, 3, 2}
	else
		spiderTypes = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
		spiderChances = {25, 4, 5, 5, 5, 5, 4, 2, 4, 2, 4}
	end
	local maxVal = 0
	for i = 1, #spiderChances do
		maxVal = maxVal + spiderChances[i]
	end
	local rng = Isaac.GetPlayer(0):GetCollectibleRNG(Isaac.GetItemIdByName("Mutagen"))
	local chance = mod:GetRandomNumber(0, maxVal, rng)
	if _onlyColor then
		chance = mod:GetRandomNumber(spiderChances[1]+1, maxVal, rng) -- big blue spider doesn't count as non-colored btw
	end
	return returnElementWithChance(spiderTypes, spiderChances, chance)
end

function GetNearestEnemy(_pos)
	local distance = 9999999
	local closestPos = nil
	local enemies = Isaac.GetRoomEntities()
	for i=1, #enemies do
		local enemy = enemies[i]:ToNPC()
		if (enemy) and (enemy:IsVulnerableEnemy()) and (not enemy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM)) then
			if (_pos - enemy.Position):Length() < distance then
				closestPos = enemy
				distance = (_pos - enemy.Position):Length()
			end
		end
	end
	if distance == 9999999 then
		return game:GetNearestPlayer(_pos)
	else
		return closestPos
	end
end

function vecToDir(_vec) -- this function was stol-, I mean, borrowed from commando baby mod
	local angle = _vec:GetAngleDegrees()
	if (angle < 45 and angle >= -45) then
		return Direction.RIGHT
	elseif (angle < -45 and angle >= -135) then
		return Direction.UP
	elseif (angle > 45 and angle <= 135) then
		return Direction.DOWN
	end
	return Direction.LEFT
end

function addEggOrbital(_num, _player)
	local data = mod:GetData(_player)
	if not data.eggOrbitals then data.eggOrbitals = 0 end
	data.eggOrbitals = data.eggOrbitals + _num
	_player:CheckFamiliar(Isaac.GetEntityVariantByName("Spider Egg (orbital)"), data.eggOrbitals, RNG())
end

function isFlyEnemy(_ent)
	local myType = _ent:ToNPC().Type
	if (myType) and (myType == 13 or myType == 14 or myType == 18 or myType == 25 or myType == 61 or myType == 80 or myType == 91 or myType == 214 or myType == 222 or myType == 249 or myType == 281 or myType == 808 or myType == 819 or myType == 838 or myType == 868 or myType == 908) then
		return true
	else
		return false
	end
end

function rateEyeChargeVal(_item)
	local configItem = Isaac.GetItemConfig():GetCollectible(_item)
	local chargeVal = 1
	if configItem.ChargeType ~= 0 then
		chargeVal = 1
	else
		if configItem.MaxCharges == 0 then
			chargeVal = 12
		else
			chargeVal = configItem.MaxCharges
		end
	end
	return chargeVal
end

function eyeAndHandAreMismatched(_player)
	local playerActive = _player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
	local data = mod:GetData(_player)
	if (playerActive ~= 0) and (data.mechEyeItem ~= nil) and (rateEyeChargeVal(data.mechEyeItem) > rateEyeChargeVal(playerActive)) then
		return true
	end
	return false
end

function rerollMechEyeActive(_player)
	local items = {}
	local itemBlackList = { 286, 348, 263, 130, 296, 282, 323, 135, 147, 126, 137, 338, 290, 352, 383, 396, 504, 489, 483, 515, 475, 536, 710, 703, 720, 711, 622, 555, 715, 604, 636, 714, 580, 623, 655, 635, 713, 709, 640, 653 }
	local data = mod:GetData(_player)
	local playerActive = _player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
	local playerActive2 = _player:GetActiveItem(ActiveSlot.SLOT_SECONDARY)
	--poop item is base
	if (not data.mechEyeItem) or (playerActive == 0) then data.mechEyeItem = 36 return end
	if (playerActive2 ~= 0) and (playerActive ~= 0) then --and (rateEyeChargeVal(playerActive) > rateEyeChargeVal(playerActive2)) then
		--if primary slot is discharged while secondary is not
		if (_player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) < Isaac.GetItemConfig():GetCollectible(playerActive).MaxCharges) and (_player:GetActiveCharge(ActiveSlot.SLOT_SECONDARY) >= Isaac.GetItemConfig():GetCollectible(playerActive2).MaxCharges) then
			playerActive = playerActive2
		end
	end
	--choose item
	for id=1, Isaac.GetItemConfig():GetCollectibles().Size -1 do
		local configItem = Isaac.GetItemConfig():GetCollectible(id)
		--choose active item that is not the previous one, that is not player's active and that has the same amount of charges as playerActive
		if (configItem) and (configItem.Type == 3) and (configItem.MaxCharges == rateEyeChargeVal(playerActive)) and (id ~= data.mechEyeItem) and (id ~= playerActive) then
			--check if item is not blacklisted
			local isBlackListed = false
			for i=1, #itemBlackList do
				if id == itemBlackList[i] then
					isBlackListed = true
				end
			end
			--if everything's fucking great, then add it to the valid item list
			if not isBlackListed then
				items[#items+1] = id
			end
		end
	end	
	--set it to random item from the list
	local rng = _player:GetCollectibleRNG(Isaac.GetItemIdByName("Mechanical Eye"))
	data.mechEyeItem = items[mod:GetRandomNumber(1, #items, rng)]
end

function triggeredShootButton(_player)
	if (Input.IsActionTriggered(ButtonAction.ACTION_SHOOTUP, _player.ControllerIndex)) then
		return ButtonAction.ACTION_SHOOTUP
	elseif (Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN, _player.ControllerIndex)) then
		return ButtonAction.ACTION_SHOOTDOWN
	elseif (Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, _player.ControllerIndex)) then
		return ButtonAction.ACTION_SHOOTLEFT
	elseif (Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, _player.ControllerIndex)) then
		return ButtonAction.ACTION_SHOOTRIGHT
	else
		return nil
	end
end

function lerp(_val, _target, _interval)
	return _val + (_target - _val) * _interval
end

function clamp(_val, _min, _max)
	if _val < _min then
		return _min
	elseif _val > _max then
		return _max
	else
		return _val
	end
end

function isInsectEnemy(_ent)
	local insectTypes = { 851, 13, 18, 80, 96, 222, 256, 281, 296, 808, 868, 951, 951, 819, 819, 61, 61, 61, 61, 61, 61, 61, 61, 14, 14, 14, 25, 25, 25, 25, 25, 25, 25, 29, 246, 246, 303, 88, 85, 94, 814, 818, 818, 818, 884, 91, 206, 206, 207, 207, 214, 249, 838, 215, 250, 86, 240, 240, 240, 241, 242, 304, 951 }
	local insectVars = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11, 21, 0, 1, 0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 2, 0, 1, 2, 3, 4, 5, 6, 1, 0, 1, 0, 2, 0, 0, 0, 0, 1, 2, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 3, 0, 0, 0, 23 }
	for i=1, #insectVars do
		if _ent.Type == insectTypes[i] and _ent.Variant == insectVars[i] then
			return true
		end
	end
	return false
end

function getRandomItemByTypeAndQuality(_quality, _itemtype)
	local items = {}
	for id=1, Isaac.GetItemConfig():GetCollectibles().Size -1 do
		local configItem = Isaac.GetItemConfig():GetCollectible(id)
		if (configItem) and (configItem.Quality == _quality) and (configItem.Type == _itemtype) then
			items[#items+1] = id
		end
	end
	if (#items > 0) then
		local rng = Isaac.GetPlayer(0):GetCollectibleRNG(Isaac.GetItemIdByName("Mechanical Eye"))
		return items[mod:GetRandomNumber(1, #items, rng)]
	else
		return 36 -- poopoo
	end
end

function versusScreenPlaying()
	local room = game:GetRoom()
	if (game:IsPaused()) and (room:GetFrameCount() == 0) and (room:GetType() == RoomType.ROOM_BOSS) then
		return true
	end
	return false
end

local notShow = false
function mod:shouldDeHook()
	local reqs = {
	  not game:GetHUD():IsVisible(),
	  game:GetSeeds():HasSeedEffect(SeedEffect.SEED_NO_HUD),
	  notShow
	}
	return reqs[1] or reqs[2] or notShow
end

--rainbow color
local rainbowR = 60
local rainbowG = 0
local rainbowB = 0
local rainbowFlag = 1
function mod:rainbowColorUpdate()
	if (rainbowFlag == 1) then
		rainbowB = rainbowB + 3
		if (rainbowB == 60) then
			rainbowFlag = 2
		end
	elseif (rainbowFlag == 2) then
		rainbowR = rainbowR - 3
		if (rainbowR == 0) then
			rainbowFlag = 3
		end
	elseif (rainbowFlag == 3) then
		rainbowG = rainbowG + 3
		if (rainbowG == 60) then
			rainbowFlag = 4
		end
	elseif (rainbowFlag == 4) then
		rainbowB = rainbowB - 3
		if (rainbowB == 0) then
			rainbowFlag = 5
		end
	elseif (rainbowFlag == 5) then
		rainbowR = rainbowR + 4
		if (rainbowR == 60) then
			rainbowFlag = 6
		end
	elseif (rainbowFlag == 6) then
		rainbowG = rainbowG - 3
		if (rainbowG == 0) then
			rainbowFlag = 1
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.rainbowColorUpdate)

function rainbowColor()
	return Color(rainbowR/4, rainbowG/4, rainbowB/4, 1, 0.1, 0.1, 0.1)
end

function doUranusFreeze(_npc, _player)
	_npc:AddEntityFlags(EntityFlag.FLAG_ICE)
	_npc:TakeDamage(_npc.HitPoints+1, 0, EntityRef(_player), 0)
end

function tryAddGoldMark()
	local enemies = Isaac.GetRoomEntities()
	--remove enemies that doesn't fit in
	local i = 1
	while i <= #enemies do
		local ent = enemies[i]
		if (not ent:IsVulnerableEnemy()) or (ent:IsBoss()) or (ent:GetData().shouldDropCoin) or (ent.Type == EntityType.ENTITY_FIREPLACE) then
			table.remove(enemies, i)
		else
			i = i+1
		end
	end
	--actually apply shit
	if #enemies > 0 then
		local rng = Isaac.GetPlayer(0):GetCollectibleRNG(Isaac.GetItemIdByName("Geptameron"))
		local npc = enemies[mod:GetRandomNumber(1, #enemies, rng)]
		npc:GetData().shouldDropCoin = true
		local poof = Isaac.Spawn(1000, 16, 2, Vector(npc.Position.X, npc.Position.Y-15), Vector(0,0), npc):ToEffect()
		poof.Color = Color(0.9, 0.7, 0.3, 1, 0.2, 0.3, 0) 
		poof.SpriteScale = poof.SpriteScale*0.7 
		poof:Update()
	end
end

function lose1Soul()
	for i=0, game:GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(i)
		if player:HasTrinket(TrinketType.TRINKET_YOUR_SOUL) then
			player:TryRemoveTrinket(TrinketType.TRINKET_YOUR_SOUL)
			break
		end
	end
end

function getFreeContainterAmount(_player)
	local soulHearts = _player:GetSoulHearts()
	if soulHearts%2 ~= 0 then soulHearts = soulHearts+1 end
	return (_player:GetHeartLimit() - (soulHearts + getRedContainers(_player)))/2
end

function playerHasTearFlag(_player, _flag)
	if (_player.TearFlags | _flag == _player.TearFlags) then
		return true
	else
		return false
	end
end

--innate functions by Aevilok and creator of Mastema, tweaks by me
function addInnateItem(player, collectibleID)
    local itemWisp = player:AddItemWisp(collectibleID, Vector(0,0), true):ToFamiliar()
    itemWisp:RemoveFromOrbit()
    itemWisp:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    itemWisp.Visible = false
    itemWisp.CollisionDamage = 0
	itemWisp.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	itemWisp:GetData().arachnaWisp = true
    return itemWisp
end

function hasInnateItem(player, collectibleid)
	local itemWisps = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ITEM_WISP, collectibleId)
	if #itemWisps == 0 then return false end
	for i = 1, #itemWisps do
		local wisp = itemWisps[i]:ToFamiliar()
		if (wisp:GetData().arachnaWisp) and (wisp.Player.Index == player.Index) then
            return true
        end
    end
	return false
end

function removeInnateItem(player, collectibleId)
    local itemWisps = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ITEM_WISP, collectibleId)
    if #itemWisps > 0 then
        for i = 1, #itemWisps do
			local wisp = itemWisps[i]:ToFamiliar()
			if (wisp:GetData().arachnaWisp) and (wisp:ToFamiliar().Player.Index == player.Index)then
				wisp:TakeDamage(wisp.HitPoints+1, 0, EntityRef(player), 0)
				player:EvaluateItems()
                break
            end
        end
    end
end

function isInfUseActive(item)
	local banlist = {186, 326, 294, 133, 282, 323, 135, 40, 295, 147, 177, 126, 289, 137, 338, 164, 290, 352, 434, 427, 383, 396, 396, 487, 507, 522, 484, 722, 710, 704, 705, 729, 555, 604, 623, 655, 635, 713, 709, 640, 653, 582, 512}
	for i=1, #banlist do
		if banlist[i] == item then
			return true
		end
	end
	return false
end