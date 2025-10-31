local mod = ARACHNAMOD
local arachnaChar = Isaac.GetPlayerTypeByName("Arachna", false)
local arachnaChar_b = Isaac.GetPlayerTypeByName("Arachna", true)

local game = ARACHNAMOD.game
local sfx = ARACHNAMOD.sfx

--spider egg
function mod:spiderEggUpdate(eff)
	local sprite = eff:GetSprite()
	local data = eff:GetData()
	if not data.init then
		if math.random(1, 1000) == 1 then
			sprite:ReplaceSpritesheet(0, "gfx/familiars/spider_egg_snowman.png") --rare 
		else
			sprite:ReplaceSpritesheet(0, "gfx/familiars/spider_egg_" .. tostring(math.random(1,4)) .. ".png")
		end
		sprite:LoadGraphics()
		sprite:Play("Appear")
		data.init = true
	end
	if sprite:IsFinished("Appear") then
		sprite:Play("Idle")
	end
	if (game:GetRoom():IsClear()) and (sprite:IsPlaying("Idle")) then
		sprite:Play("Explode")
	end
	--timer
	if (not game:GetRoom():IsClear()) and (data.eggTime) then
		data.eggTime = data.eggTime - 1	
		if (data.eggTime == 0) and (sprite:IsPlaying("Idle")) then
			sprite:Play("ExplodeEmpty")
		end
	end
	--noreward
	if sprite:IsFinished("ExplodeEmpty") then
		game:SpawnParticles(eff.Position, 5, math.random(7, 14), 4, Color(1, 1, 1, 1, 1, 1, 1))
		sfx:Play(SoundEffect.SOUND_MEATY_DEATHS , 0.8, 0, false, 1.25)
		eff:Remove()
	end
	--reward
	if sprite:IsFinished("Explode") then
		local stagenum = game:GetLevel():GetStage()
		--spawn spiders
		--more web hearts = more spiders
		local spiderCount = 0
		local spawnerType = eff.SpawnerEntity:ToPlayer():GetPlayerType()
		local playerWebHearts = getWebHearts(eff.SpawnerEntity:ToPlayer())--mod:GetData(eff.SpawnerEntity).webHearts
		if playerWebHearts == nil then playerWebHearts = 0 end
		if ((spawnerType == arachnaChar) and (eff.SpawnerEntity:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT))) or (spawnerType == arachnaChar_b) then
			--spiderCount = math.random(3, 5) + (mod:GetData(eff.SpawnerEntity).webHearts*2)
			spiderCount = math.ceil( math.ceil((stagenum+1)/2)*0.5*(math.random(3, 5) + playerWebHearts) )
			
		else
			--spiderCount = math.random(1, 3 + (mod:GetData(eff.SpawnerEntity).webHearts*2))
			spiderCount = math.ceil( math.ceil((stagenum+1)/2)*0.5*math.random(2, 4 + playerWebHearts) )
		end
		--Isaac.ConsoleOutput(tostring(spiderCount) .. "\n")
		for i=1, spiderCount do
			local nearPos = Isaac.GetFreeNearPosition(eff.Position + Vector(math.random(-100, 100), math.random(-100, 100)), 50)
			local myVar = 0
			local player = eff.SpawnerEntity:ToPlayer()
			if player:GetPlayerType() == arachnaChar then
				if (math.random(1,2) == 1) then
					myVar = returnRandomSpiderSubType(false)
				end
			elseif player:GetPlayerType() == arachnaChar_b then
				if (math.random(1,3) == 1) then
					myVar = returnRandomSpiderSubType(true)
				end
			end
			throwSpecialSpider(player, myVar, eff.Position, nearPos)
		end
		--effects
		game:SpawnParticles(eff.Position, 5, math.random(7, 14), 4, Color(1, 1, 1, 1, 1, 1, 1))
		sfx:Play(SoundEffect.SOUND_MEATY_DEATHS , 0.8, 0, false, 1.25)
		--chance to give spider heart if player has birthright
		local heartChance = 0
		if (eff.SpawnerEntity:ToPlayer():GetPlayerType() == arachnaChar) and (eff.SpawnerEntity:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
			if math.random(1, 100) <= 5 then
				Isaac.Spawn(5, 2000, 0, eff.Position, Vector(0,0), eff)
			end
		end
		eff:Remove()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.spiderEggUpdate, 2001)
--spider eggs break on new wave in greed mode
local curWave = 0
function mod:eggNewLvl()
	curWave = 0
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.eggNewLvl)
function mod:eggOnGreedWave()
	if game:IsGreedMode() then
		local realWave = game:GetLevel().GreedModeWave
		if realWave ~= curWave then
			--Isaac.ConsoleOutput("New Wave! " .. tostring(realWave) .. "\n")
			local eggs = Isaac.FindByType(1000, 2001, -1, false, false)
			for i=1, #eggs do
				local sprite = eggs[i]:GetSprite()
				if not sprite:IsPlaying("ExplodeEmpty") then
					sprite:Play("Explode")
				end
			end
			curWave = realWave
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.eggOnGreedWave)
--render timer
local eggTimerSprite = Sprite()
eggTimerSprite:Load("gfx/spider_egg_timer.anm2",true)
function mod:eggTimerRender(eff)
	local sprite = eff:GetSprite()
	local data = eff:GetData()
	if (data.eggTime) and (not sprite:IsPlaying("Explode")) and (not sprite:IsPlaying("ExplodeEmpty")) then
		local npcPos = Vector(eff.Position.X+25, eff.Position.Y-55)
		local frameNum = 100 - math.floor(data.eggTime/data.maxEggTime*100) - 1
		eggTimerSprite:SetFrame("Idle", frameNum)
		eggTimerSprite:Render(Isaac.WorldToScreen(npcPos), Vector(0,0), Vector(0,0))
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, mod.eggTimerRender, 2001)