--#region Variables

local Mod = ARACHNAMOD
local ceil = Mod.math.ceil

local SPIDER_EGG = {}

ARACHNAMOD.Entities.SPIDER_EGG = SPIDER_EGG

SPIDER_EGG.ID = Isaac.GetEntityVariantByName("Spider Egg")

SPIDER_EGG.BIRTHRIGHT_WEB_HEART_CHANCE = 0.05

--#endregion

--#region Helpers

---@param pos Vector
---@param spawner? Entity
function SPIDER_EGG:SpawnEgg(pos, spawner)
	return Mod.Spawn.Effect(SPIDER_EGG.ID, 0, pos, nil, spawner)
end

--#endregion

--#region Egg Init

---@param egg EntityEffect
function SPIDER_EGG:OnInit(egg)
	local rng = egg:GetDropRNG()
	local sprite = egg:GetSprite()

	if rng:RandomFloat() < 0.001 then
		sprite:ReplaceSpritesheet(0, "gfx/familiars/spider_egg_snowman.png") --rare
	else
		sprite:ReplaceSpritesheet(0, "gfx/familiars/spider_egg_" .. tostring(rng:RandomInt(4) + 1) .. ".png")
	end
	sprite:LoadGraphics()
	sprite:Play("Appear", true)
end

--#endregion

--#region Explode Egg

---@param egg EntityEffect
function SPIDER_EGG:Explode(egg)
	local player = egg.SpawnerEntity and egg.SpawnerEntity:ToPlayer()
	if not player then player = Isaac.GetPlayer() end
	local stageNum = Mod.Game:GetLevel():GetStage()
	local spiderCount = 0
	local rng = egg:GetDropRNG()
	local webHearts = Mod.Pickup.WEB_HEART:GetWebHearts(player)
	local stageModifier = ceil((stageNum+1)/2)*0.5

	if Mod.Character.ARACHNA:ArachnaHasBirthright(player) or Mod.Character.ARACHNA_B:IsArachnaB(player) then
		spiderCount = ceil(stageModifier * (Mod:RandomNum(3, 5, rng) + webHearts))
	else
		spiderCount = ceil(stageModifier * Mod:RandomNum(2, 4 + webHearts, rng))
	end

	for _ = 1, spiderCount do
		local randomX, randomY = Mod:RandomNum(-100, 100), Mod:RandomNum(-100, 100)
		local nearPos = Isaac.GetFreeNearPosition(egg.Position + Vector(randomX, randomY), 50)
		local spiderSubtype = 0
		if Mod.Character.ARACHNA:IsArachna(player)
			and rng:RandomInt(2) == 1
		then
			spiderSubtype = Mod.Entities.COLORED_SPIDERS:GetRandomSpiderSubtype()
		elseif Mod.Character.ARACHNA_B:IsArachnaB(player)
			and rng:RandomInt(3) == 1
		then
			spiderSubtype = Mod.Entities.COLORED_SPIDERS:GetRandomSpiderSubtype(true)
		end
		Mod.Entities.COLORED_SPIDERS:ThrowColoredSpider(player, spiderSubtype, egg.Position, nearPos)
	end

	Mod.Game:SpawnParticles(egg.Position, EffectVariant.BLOOD_PARTICLE, Mod:RandomNum(7, 14), 4, Color(1, 1, 1, 1, 1, 1, 1))
	Mod.sfxman:Play(SoundEffect.SOUND_MEATY_DEATHS , 0.8, 0, false, 1.25)

	if Mod.Character.ARACHNA:ArachnaHasBirthright(player) and rng:RandomFloat() < SPIDER_EGG.BIRTHRIGHT_WEB_HEART_CHANCE then
		Mod.Spawn.Pickup(Mod.Pickup.WEB_HEART.ID, 0, egg.Position, nil, egg)
	end
	egg:Remove()
end

--#endregion

--#region Effect Update

---@param egg EntityEffect
function SPIDER_EGG:OnUpdate(egg)
	local sprite = egg:GetSprite()
	if sprite:IsFinished("Appear") then
		sprite:Play("Idle")
	end
	if (Mod.Room():IsClear()) and (sprite:IsPlaying("Idle")) then
		sprite:Play("Explode")
	end
	if sprite:IsFinished("Explode") then
		SPIDER_EGG:Explode(egg)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, SPIDER_EGG.OnUpdate, SPIDER_EGG.ID)

--#endregion

--#region Greed Mode

function SPIDER_EGG:ExplodeOnGreedWave()
	Mod.Foreach.Effect(function (effect, index)
		if effect.Timeout ~= 0 then
			SPIDER_EGG:Explode(effect)
		end
	end, SPIDER_EGG.ID)
end

Mod:AddCallback(ModCallbacks.MC_POST_START_GREED_WAVE, SPIDER_EGG.ExplodeOnGreedWave)

--#endregion