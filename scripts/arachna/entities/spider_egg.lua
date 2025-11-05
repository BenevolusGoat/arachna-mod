--#region Variables

local Mod = ARACHNAMOD
local ceil = Mod.math.ceil

local SPIDER_EGG = {}

ARACHNAMOD.Entities.SPIDER_EGG = SPIDER_EGG

SPIDER_EGG.ID = Isaac.GetEntityVariantByName("Spider Egg")

SPIDER_EGG.BIRTHRIGHT_WEB_HEART_CHANCE = 0.05

SPIDER_EGG.MAX_EGG_TIMEOUT = 500

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
	--Allow it to be picked up by Isaac.FindInRadius
	egg.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, SPIDER_EGG.OnInit, SPIDER_EGG.ID)

--#endregion

--#region Explode Egg

---@param egg EntityEffect
---@param rewards? boolean
function SPIDER_EGG:Explode(egg, rewards)
	if rewards then
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
			Mod.Entities.COLORED_SPIDERS:ThrowColoredSpider(player, spiderSubtype, egg.Position)
		end


		if Mod.Character.ARACHNA:ArachnaHasBirthright(player) and rng:RandomFloat() < SPIDER_EGG.BIRTHRIGHT_WEB_HEART_CHANCE then
			Mod.Spawn.Pickup(Mod.Pickup.WEB_HEART.ID, 0, egg.Position, nil, egg)
		end
	end
	Mod.Game:SpawnParticles(egg.Position, EffectVariant.BLOOD_PARTICLE, Mod:RandomNum(7, 14), 4, Color(1, 1, 1, 1, 1, 1, 1))
	Mod.sfxman:Play(SoundEffect.SOUND_MEATY_DEATHS , 0.8, 2, false, 1.25)
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

	if sprite:IsFinished("Explode") or sprite:IsFinished("ExplodeEmpty") then
		SPIDER_EGG:Explode(egg, sprite:IsFinished("Explode"))
	end

	if egg.Timeout == 1 then
		sprite:Play("ExplodeEmpty")
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, SPIDER_EGG.OnUpdate, SPIDER_EGG.ID)

--#endregion

--#region Greed Mode

function SPIDER_EGG:ExplodeOnGreedWave()
	Mod.Foreach.Effect(function (effect, index)
		local sprite = effect:GetSprite()
		if not sprite:IsPlaying("ExplodeEmpty") then
			sprite:Play("Explode")
		end
	end, SPIDER_EGG.ID)
end

Mod:AddCallback(ModCallbacks.MC_POST_START_GREED_WAVE, SPIDER_EGG.ExplodeOnGreedWave)

--#endregion

--#region Render Timer

local eggTimerSprite = Sprite("gfx/chargebar.anm2", true)
for i = 0, 2 do
	eggTimerSprite:ReplaceSpritesheet(i, "gfx/ui/ui_arachna_eggtimer.png")
end
eggTimerSprite:LoadGraphics()

---@param effect EntityEffect
function SPIDER_EGG:RenderTimer(effect, offset)
	local renderPos = Mod:GetEntityRenderPosition(effect, offset)
	local nullFrame = effect:GetSprite():GetNullFrame("timer")
	if nullFrame and nullFrame:IsVisible() and effect.Timeout > 0 then
		renderPos = renderPos + nullFrame:GetPos()
		local frameNum = Mod.math.floor(effect.Timeout / SPIDER_EGG.MAX_EGG_TIMEOUT * 100) - 1
		eggTimerSprite:SetFrame("Charging", frameNum)
		eggTimerSprite:Render(renderPos)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, SPIDER_EGG.RenderTimer, SPIDER_EGG.ID)

--#endregion