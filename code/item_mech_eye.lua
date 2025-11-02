local mod = ARACHNAMOD

local mechEyeItem = Isaac.GetItemIdByName("Mechanical Eye")
local mechEyeOrbital = Isaac.GetEntityVariantByName("Mechanical Eye (orbital)")

mod.SavedData.mechEyeItem = {}
local json = require("json")

--applying hearts
function mod:mechEyeDataGameStart(isContinued) 
	if isContinued then
		--get data from save
		if mod:HasData() then
			mod.SavedData = json.decode(Isaac.LoadModData(mod))
			for i=0, game:GetNumPlayers()-1 do
				local player = Isaac.GetPlayer(i)
				local data = mod:GetData(player)
				data.mechEyeItem = mod.SavedData.mechEyeItem[tostring(i)]
			end
			--Isaac.ConsoleOutput("GOT DATA FROM SAVE! \n")
		end
	else
		--set values to default
		for i=0, game:GetNumPlayers()-1 do
			local player = Isaac.GetPlayer(i)
			local data = mod:GetData(Isaac.GetPlayer(i))
			rerollMechEyeActive(player)
			--Isaac.ConsoleOutput("VALUES SET TO DEFAULT! \n")
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.mechEyeDataGameStart)
function mod:mechEyeDataGameExit(shouldSave) 
	--save data
	if shouldSave then
		for i=0, game:GetNumPlayers()-1 do
			local player = Isaac.GetPlayer(i)
			local data = mod:GetData(Isaac.GetPlayer(i))
			mod.SavedData.mechEyeItem[tostring(i)] = data.mechEyeItem
		end
		mod.SaveData(mod, json.encode(mod.SavedData))
		--Isaac.ConsoleOutput("DATA SAVED! \n")
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.mechEyeDataGameExit)
function mod:mechEyeDataNewLvl()
	local level = game:GetLevel()
	if (level:GetStage() ~= 1) and (not level:IsAltStage()) and (not level:IsAscent()) then
		--save data
		for i=0, game:GetNumPlayers()-1 do
			local player = Isaac.GetPlayer(i)
			local data = mod:GetData(Isaac.GetPlayer(i))
			local level = game:GetLevel()
			--if player doesn't have a trinket reroll item before saving
			if (not player:HasCollectible(mechEyeItem)) then
				rerollMechEyeActive(player)
			end
			--save
			mod.SavedData.mechEyeItem[tostring(i)] = data.mechEyeItem
		end
		mod.SaveData(mod, json.encode(mod.SavedData))
		--Isaac.ConsoleOutput("DATA SAVED! \n")
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.mechEyeDataNewLvl)
function mod:mechEyeDataGameEnd(isGameOver) 
	--clear data
	mod.SavedData.mechEyeItem = {}
	--Isaac.ConsoleOutput("DATA CLEARED! \n")
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_END, mod.mechEyeDataGameEnd)

--actual effect
--update
function mod:mechEyeItemPause(player)
	local data = mod:GetData(player)
	--no nil
	if not data.mechEyeItem then
		rerollMechEyeActive(player)
	end
	--cooldown
	if (data.activeItemPause ~= nil) and (data.activeItemPause > 0) then --this is triggered AFTER usage of active, so I'm puttin reroll thingy here, so you could use item twice a room with 2 actives
		data.activeItemPause = data.activeItemPause - 1
		rerollMechEyeActive(player)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.mechEyeItemPause)
--on active use
function mod:mechEyeUseActive(item, rng, player)
	local data = mod:GetData(player)
	if (item == player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)) and (player:HasCollectible(mechEyeItem)) and (data.activeItemPause == nil or data.activeItemPause <= 0) and (not eyeAndHandAreMismatched(player)) and (not isInfUseActive(item)) then
		local randNum = math.random(1, 100)
		--use item
		data.activeItemPause = 1
		player:UseActiveItem(data.mechEyeItem, false, false, true, true, -1)
		--visual
		local hud = game:GetHUD()
		local activeName = Isaac.GetItemConfig():GetCollectible(data.mechEyeItem).Name
		activeName = activeName:gsub("#", "")
		activeName = activeName:gsub("_NAME", "")
		activeName = activeName:gsub("_", " ")
		hud:ShowItemText(activeName)
		for _, baby in pairs(Isaac.FindByType(3, mechEyeOrbital, -1, false, false)) do
			if (GetPtrHash(baby:ToFamiliar().Player) == (GetPtrHash(player))) then
				local eff = Isaac.Spawn(1000, 2002, 2, baby.Position, Vector(0,0), baby):ToEffect()
				eff.SpriteScale = baby.SpriteScale
				eff:FollowParent(baby)
			end
		end
		sfx:Play(SoundEffect.SOUND_LASERRING, 0.8, 0, false, 1)		
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.mechEyeUseActive) 

--orbital
--apply
function mod:mechEyeOrbitalCache(player, cacheFlag)
	local mechEyeAmount = 0
	if player:HasCollectible(mechEyeItem) then
		mechEyeAmount = 1
	end
	if (cacheFlag == CacheFlag.CACHE_FAMILIARS) then
		player:CheckFamiliar(mechEyeOrbital, mechEyeAmount, RNG())
	end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.mechEyeOrbitalCache)
--reroll on new room
function mod:mechEyeOrbitalNewRoom()
	--save data
	for i=0, game:GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(i)
		local room = game:GetRoom()
		--first visit in room with enemies when you have trinket ==> reroll
		if (player:HasCollectible(mechEyeItem)) and (room:IsFirstVisit()) then --and (not room:IsClear()) then
			rerollMechEyeActive(player)
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.mechEyeOrbitalNewRoom)
--greed
local curWave = 0
function mod:mechEyeOrbitalResetWave()
	curWave = 0
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.mechEyeOrbitalResetWave)
function mod:mechEyeOrbitalGreedReroll()
	if game:IsGreedMode() then
		local realWave = game:GetLevel().GreedModeWave
		if realWave ~= curWave then
			for i=0, game:GetNumPlayers()-1 do
				local player = Isaac.GetPlayer(i)
				if (player:HasCollectible(mechEyeItem)) then
					rerollMechEyeActive(player)
				end
			end
			curWave = realWave
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.mechEyeOrbitalGreedReroll)

--init
function mod:mechEyeOrbitalInit(baby)
	local player = baby.Player
	local sprite = baby:GetSprite()
	baby.CollisionDamage = 1.5
	baby:AddToOrbit(4445)
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.mechEyeOrbitalInit, mechEyeOrbital)
--behaviour
function mod:mechEyeOrbitalUpdate(baby) 
	local player = baby.Player
	local sprite = baby:GetSprite()
	local data = baby:GetData()
	local mechEyeItem = mod:GetData(player).mechEyeItem
	if not mechEyeItem then mechEyeItem = 36 end
	local mechConfigItem = Isaac.GetItemConfig():GetCollectible(mechEyeItem)
	--item hologram sprite
	if (not sprite:IsPlaying("Closing")) then
		local hologramItem = mechConfigItem.GfxFileName
		if (game:GetLevel():GetCurses() & LevelCurse.CURSE_OF_BLIND > 0) then
			hologramItem = "gfx/items/collectibles/questionmark.png"
		end
		sprite:ReplaceSpritesheet(2, hologramItem)
		sprite:LoadGraphics()
	end
	--should open or close
	local playerActive = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
	if playerActive ~= 0 then
		--if player's active is full
		if (player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) >= Isaac.GetItemConfig():GetCollectible(playerActive).MaxCharges) and (not eyeAndHandAreMismatched(player)) and (not isInfUseActive(playerActive)) then
			if sprite:IsPlaying("Closed") then
				sfx:Play(SoundEffect.SOUND_MIRROR_ENTER, 0.6, 0, false, 1.8)
				sprite:Play("Opening", true)
			end
		else
			if sprite:IsPlaying("Opened") then
				sfx:Play(SoundEffect.SOUND_MIRROR_EXIT, 0.6, 0, false, 1.8)
				sprite:Play("Closing", true)
			end			
		end
	end
	--after animation is finished
	if (sprite:IsFinished("Closing")) then
		sprite:Play("Closed")
	end
	if (sprite:IsFinished("Opening")) then
		sprite:Play("Opened")
	end
	baby.OrbitDistance = Vector(40, 40)
	baby.OrbitSpeed = 0.03
	baby.Velocity = baby:GetOrbitPosition(player.Position + player.Velocity) - baby.Position
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.mechEyeOrbitalUpdate, mechEyeOrbital)

--when hit by bullets
function mod:mechEyeOrbitalTouch(baby, ent, _) 
	if ent:ToProjectile() then
		ent:Die()
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, mod.mechEyeOrbitalTouch, mechEyeOrbital)