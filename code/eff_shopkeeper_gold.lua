local mod = ARACHNAMOD

local goldenDudeRoom = {}
local goldenDudeSubType = {} 
local goldenDudePosX = {}
local goldenDudePosY = {}
local goldenDudeBombedTimes = {}
local goldenDudeBombedMax = {}

mod.SavedData.goldenDudeRoom = {}
mod.SavedData.goldenDudeSubType = {}
mod.SavedData.goldenDudePosX = {}
mod.SavedData.goldenDudePosY = {}
mod.SavedData.goldenDudeBombedTimes = {}
mod.SavedData.goldenDudeBombedMax = {}
local json = require("json")

--save-related functions
local function loadGoldenDudeData()
	mod.SavedData = json.decode(Isaac.LoadModData(mod))
	for i=1, #goldenDudeRoom do	
		if mod.SavedData.goldenDudeRoom[i] ~= nil then
			goldenDudeRoom[i] = mod.SavedData.goldenDudeRoom[i]
			goldenDudeSubType[i] = mod.SavedData.goldenDudeSubType[i]
			goldenDudePosX[i] = mod.SavedData.goldenDudePosX[i]
			goldenDudePosY[i] = mod.SavedData.goldenDudePosY[i]
			goldenDudeBombedTimes[i] = mod.SavedData.goldenDudeBombedTimes[i]
			goldenDudeBombedMax[i] = mod.SavedData.goldenDudeBombedMax[i]
		end
	end
end

local function saveGoldenDudeData()
	for i=1, #goldenDudeRoom do	
		if goldenDudeRoom[i] ~= nil then
			mod.SavedData.goldenDudeRoom[i] = goldenDudeRoom[i]
			mod.SavedData.goldenDudeSubType[i] = goldenDudeSubType[i]
			mod.SavedData.goldenDudePosX[i] = goldenDudePosX[i]
			mod.SavedData.goldenDudePosY[i] = goldenDudePosY[i]
			mod.SavedData.goldenDudeBombedTimes[i] = goldenDudeBombedTimes[i]
			mod.SavedData.goldenDudeBombedMax[i] = goldenDudeBombedMax[i]
		end
	end
	mod.SaveData(mod, json.encode(mod.SavedData))
end

local function clearAllGoldenDudeData()
	goldenDudeRoom = {}
	goldenDudeSubType = {} 
	goldenDudePosX = {}
	goldenDudePosY = {}
	goldenDudeBombedTimes = {}
	goldenDudeBombedMax = {}
end

local function addGoldenDudeData(_dude)
	local place = #goldenDudeRoom+1
	goldenDudeRoom[place] = tostring(game:GetLevel():GetCurrentRoomDesc().SafeGridIndex)
	goldenDudeSubType[place] = _dude.SubType
	goldenDudePosX[place] = _dude.Position.X
	goldenDudePosY[place] = _dude.Position.Y
	goldenDudeBombedTimes[place] = _dude:GetData().bombedTimes
	goldenDudeBombedMax[place] = _dude:GetData().bombedMax
end

local function removeGoldenDudeData(_dude)
	local i = 1
	while i <= #goldenDudeRoom do
		local roomidx = tostring(game:GetLevel():GetCurrentRoomDesc().SafeGridIndex)
		if (roomidx == goldenDudeRoom[i]) and (_dude.Position.X == goldenDudePosX[i]) and (_dude.Position.Y == goldenDudePosY[i]) then
			table.remove(goldenDudeRoom, i)
			table.remove(goldenDudeSubType, i)
			table.remove(goldenDudePosX, i)
			table.remove(goldenDudePosY, i)
			table.remove(goldenDudeBombedTimes, i)
			table.remove(goldenDudeBombedMax, i)
			break
		else
			i = i + 1
		end
	end
end

local function dudeExistsInTable(_dude)
	local data = _dude:GetData()
	local roomidx = tostring(game:GetLevel():GetCurrentRoomDesc().SafeGridIndex)
    for i=1, #goldenDudeRoom do	
        if (roomidx == goldenDudeRoom[i]) and (_dude.Position.X == goldenDudePosX[i]) and (_dude.Position.Y == goldenDudePosY[i]) then
			return true
		end
    end
	return false
end

local function dudeUpdateBombData(_dude)
	local roomidx = tostring(game:GetLevel():GetCurrentRoomDesc().SafeGridIndex)
	for i=1, #goldenDudeRoom do	
		if (roomidx == goldenDudeRoom[i]) and (_dude.Position.X == goldenDudePosX[i]) and (_dude.Position.Y == goldenDudePosY[i]) then
			goldenDudeBombedTimes[i] = _dude:GetData().bombedTimes
		end
	end
end

--saving
function mod:goldenDudeGameStart(isContinued) 
	if isContinued then
		if mod:HasData() then
			loadGoldenDudeData()
		end
	else
		clearAllGoldenDudeData()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.goldenDudeGameStart)

function mod:goldenDudeGameExit(shouldSave) 
	if shouldSave then
		saveGoldenDudeData()
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.goldenDudeGameExit)

function mod:goldenDudeNewLvl()
	local level = game:GetLevel()
	if (level:GetStage() ~= 1) and (not level:IsAltStage()) and (not level:IsAscent()) then
		clearAllGoldenDudeData()
		saveGoldenDudeData()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.goldenDudeNewLvl)

function mod:goldenDudeGameEnd(isGameOver) 
	clearAllGoldenDudeData()
	saveGoldenDudeData()
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_END, mod.goldenDudeGameEnd)

--spawning shopkeepers
function mod:spawnGoldenDudes()
    local roomidx = tostring(game:GetLevel():GetCurrentRoomDesc().SafeGridIndex)
    for i=1, #goldenDudeRoom do	
        if goldenDudeRoom[i] == roomidx then
			local goldShopKeeper = Isaac.Spawn(1000, 2004, goldenDudeSubType[i], Vector(goldenDudePosX[i], goldenDudePosY[i]), Vector(0,0), nil):ToEffect()
			local data = goldShopKeeper:GetData()
			data.bombedTimes = goldenDudeBombedTimes[i]
			data.bombedMax = goldenDudeBombedMax[i]
			goldShopKeeper:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.spawnGoldenDudes)

--actual shopkeeper
function mod:goldenShopKeeperUpd(eff)
	local data = eff:GetData()
	local sprite = eff:GetSprite()
	--init
	if not data.init then
		--very first init
		if eff.SubType == 0 then
			--change subtype
			Isaac.Spawn(1000, 2004, math.random(1,16), eff.Position, Vector(0,0), eff):ClearEntityFlags(EntityFlag.FLAG_APPEAR) 
			eff:Remove()
		--after subtype changing is done
		else
			--change sprite
			sprite:ReplaceSpritesheet(1, "gfx/effects/goldenshopkeepers/shopkeeper-" .. tostring(eff.SubType) .. ".png")
			sprite:LoadGraphics()
			sprite:Play("Idle", true)
			data.bombCoolDown = 0
			--spawn crater
			local bombcrater = Isaac.Spawn(1000, EffectVariant.BOMB_CRATER, 0, eff.Position, Vector(0,0), eff):ToEffect()
			bombcrater.Color = Color(0.9, 0.8, 0, 1, 0.8, 0.7, 0)
			bombcrater:Update()
			--if wasn' spawned from table
			if not dudeExistsInTable(eff) then
				data.bombedTimes = 0
				data.bombedMax = math.random(3, 5)
				addGoldenDudeData(eff)
			end
		end
		data.init = true
	end
	--emit particles
	--[[
	if (sprite:IsPlaying("Idle")) and (eff.FrameCount % 32 == 0) then
		for i = 1, math.random(1, 3) do
			local centerPos = Vector(eff.Position.X, eff.Position.Y - 20)
			local shinePos = centerPos
			shinePos = shinePos + Vector.FromAngle(math.random(0,360)):Resized(math.random(15, 25))
			local goldenShine = Isaac.Spawn(1000, 2002, 3, shinePos, Vector(0,0), eff):ToEffect()
			goldenShine.DepthOffset = 250
			goldenShine.SpriteScale = goldenShine.SpriteScale*(math.random(5, 12)/10)
			goldenShine:GetSprite().PlaybackSpeed = math.random(5, 12)/10
		end
	end]]
	--on bomb
	for _, boom in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, -1, -1, false, false)) do
		if (boom.Variant == EffectVariant.BOMB_EXPLOSION) or (boom.Variant == 29) or (boom.Variant == 28) or (boom.Variant == 62) then
			if (sprite:IsPlaying("Idle")) and (eff.Position:Distance(boom.Position) < boom.SpriteScale.X*50 + 10) and (data.bombCoolDown) and (data.bombCoolDown == 0) then
				if not data.bombedTimes then data.bombedTimes = 0 end
				data.bombedTimes = data.bombedTimes + 1
				dudeUpdateBombData(eff)
				--if bombed normally
				if data.bombedTimes < data.bombedMax then
					--award (spawn coin)
					local dropvelocity = Vector.FromAngle(math.random(0, 360))*math.random(3,5)
					Isaac.Spawn(5, 20, 1, eff.Position, dropvelocity, eff)
					--visual
					sprite:Play("Bomb")
					game:SpawnParticles(eff.Position, 98, math.random(7, 14), 4)
					sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.8, 0, false, 1)
					--cooldown
					data.bombCoolDown = 20
				--on last bomb
				else
					--remove itself from table
					removeGoldenDudeData(eff)
					--award
					if math.random(1, 20) == 1 then
						--spawn golden trinket
						Isaac.Spawn(5, 350, math.random(1, TrinketType.NUM_TRINKETS-1)+ TrinketType.TRINKET_GOLDEN_FLAG, eff.Position, Vector(0,0), eff)
					else
						--spawn coins
						local baseAngle = math.random(0, 360)
						local coinAmount = math.random(3,5)
						for i=1, coinAmount do
							local dropvelocity = Vector.FromAngle(baseAngle + (i*360/coinAmount))*math.random(3,5)
							Isaac.Spawn(5, 20, 1, eff.Position, dropvelocity, eff)
						end
					end
					--visual
					sprite:Play("Break")
					sfx:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY, 0.8, 0, false, 1)
					sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.8, 0, false, 1)	
					game:SpawnParticles(eff.Position, 98, math.random(7, 14), 4)
					game:ShakeScreen(8)
					--flag
					game:GetLevel():SetStateFlag(LevelStateFlag.STATE_SHOPKEEPER_KILLED_LVL, true)
				end
			end
		end
	end
	--bomb cooldown
	if (data.bombCoolDown) and (data.bombCoolDown > 0) then
		data.bombCoolDown = data.bombCoolDown - 1
	end
	--back to idle
	if sprite:IsFinished("Bomb") then
		sprite:Play("Idle")
	end
	--die
	if sprite:IsFinished("Break") then
		eff:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.goldenShopKeeperUpd, 2004) 