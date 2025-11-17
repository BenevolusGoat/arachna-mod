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

---@param npc Entity
function SPIDER_EGG:ShouldNotSpawnEgg(npc)
	local isSmallHP
	local isLegacy = Mod:IsLegacyGameplayEnabled()
	if isLegacy then
		isSmallHP = npc.MaxHitPoints < 10
	else
		--[[ local stage = Mod.Level():GetAbsoluteStage() - 1
		--Reaches 20 HP by Stage 6 for small eggs
		isSmallHP = npc.MaxHitPoints <= 10 + (10 * (Mod.math.min(stage, 5) / 5)) ]]
		isSmallHP = npc.MaxHitPoints < 10
	end
	return isSmallHP
		or npc.SpawnerType ~= EntityType.ENTITY_NULL
		or (isLegacy and npc:IsBoss())
end

---@param npc Entity
function SPIDER_EGG:ShouldSpawnSmallEgg(npc)
	return npc:IsBoss() and Mod.Room():GetType() == RoomType.ROOM_BOSS
end

---Enemies spawned by other enemies will have a 50/50 chance to not spawn a Spider Egg, and in such case this function will return nothing
---@param pos Vector
---@param npc? Entity
---@param player? EntityPlayer
function SPIDER_EGG:TrySpawnEgg(pos, npc, player)
	if npc and SPIDER_EGG:ShouldNotSpawnEgg(npc) then
		Mod:DebugLog("Blocked egg spawn")
		return
	end
	local smallEgg = npc and SPIDER_EGG:ShouldSpawnSmallEgg(npc) or false
	Mod:DebugLog("Small Egg?", smallEgg)
	local subtype = smallEgg and 1 or 0
	if npc and npc.SpawnerType ~= EntityType.ENTITY_NULL and npc:GetDropRNG():RandomFloat() < 0.5 then
		return
	end
	return Mod.Spawn.Effect(SPIDER_EGG.ID, subtype, pos, nil, player)
end

--#endregion

--#region Egg Init

---@param egg EntityEffect
function SPIDER_EGG:OnInit(egg)
	local rng = egg:GetDropRNG()
	local sprite = egg:GetSprite()
	local eggName = egg.SubType == 1 and "spider_egg_small" or "spider_egg"

	if rng:RandomFloat() < 0.001 then
		sprite:ReplaceSpritesheet(0, "gfx/familiars/" .. eggName .. "_rare.png")
	else
		sprite:ReplaceSpritesheet(0, "gfx/familiars/" .. eggName .. "_" .. tostring(rng:RandomInt(4) + 1) .. ".png")
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
		local isLegacy = ARACHNAMOD:IsLegacyGameplayEnabled()
		local stageNum = Mod.Game:GetLevel():GetStage()
		local spiderCount = 0
		local rng = egg:GetDropRNG()
		local webHearts = Mod.Pickup.WEB_HEART:GetWebHearts(player)
		if not isLegacy then
			webHearts = Mod.math.floor(webHearts / 2)
		end
		local stageModifier = ceil((stageNum + 1) / 2) * 0.5
		local minSpiders, maxSpiders = 2, 4
		local shouldIncreaseSpider = Mod.Character.ARACHNA:ArachnaHasBirthright(player)
			or isLegacy and Mod.Character.ARACHNA_B:IsArachnaB(player)
		local COLORED_SPIDERS = Mod.Entities.COLORED_SPIDERS

		if shouldIncreaseSpider then
			minSpiders = minSpiders + 1
			maxSpiders = maxSpiders + 1
		end
		if egg.SubType == 1 then
			minSpiders = minSpiders - 1
			maxSpiders = maxSpiders - 2
		end

		if shouldIncreaseSpider and isLegacy then
			spiderCount = ceil(stageModifier * Mod:RandomNum(minSpiders, maxSpiders, rng) + webHearts)
		else
			spiderCount = ceil(stageModifier * Mod:RandomNum(minSpiders, maxSpiders + webHearts, rng))
		end
		for _ = 1, spiderCount do
			local spiderSubtype = 0
			if Mod.Character.ARACHNA:IsArachna(player)
				and rng:RandomInt(2) == 1
			then
				spiderSubtype = COLORED_SPIDERS:GetRandomSpiderSubtype()
			elseif Mod.Character.ARACHNA_B:IsArachnaB(player)
				and rng:RandomInt(3) == 1
			then
				spiderSubtype = COLORED_SPIDERS:GetRandomSpiderSubtype(true)
				if rng:RandomFloat() < 0.1 and spiderSubtype < COLORED_SPIDERS.SpiderSubtype.BIG_FLAG then
				spiderSubtype = spiderSubtype + COLORED_SPIDERS.SpiderSubtype.BIG_FLAG
				end
			end
			COLORED_SPIDERS:ThrowColoredSpider(player, spiderSubtype, egg.Position)
		end

		if Mod.Character.ARACHNA:ArachnaHasBirthright(player) and rng:RandomFloat() < SPIDER_EGG.BIRTHRIGHT_WEB_HEART_CHANCE then
			Mod.Spawn.Pickup(Mod.Pickup.WEB_HEART.ID, 0, egg.Position, nil, egg)
		end
	end
	Mod.Game:SpawnParticles(egg.Position, EffectVariant.BLOOD_PARTICLE, Mod:RandomNum(7, 14), 4,
		Color(1, 1, 1, 1, 1, 1, 1))
	Mod.sfxman:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.8, 2, false, 1.25)
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

	if (Mod.Room():IsClear() or egg.SubType == 1) and (sprite:IsPlaying("Idle")) then
		sprite:Play("Explode")
	end

	if sprite:IsFinished("Explode") or sprite:IsFinished("ExplodeEmpty") then
		SPIDER_EGG:Explode(egg, sprite:IsFinished("Explode"))
	end

	if egg.Timeout == 0 then
		sprite:Play("ExplodeEmpty")
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, SPIDER_EGG.OnUpdate, SPIDER_EGG.ID)

--#endregion

--#region Greed Mode

function SPIDER_EGG:ExplodeEggOnClearTrigger()
	Mod.Foreach.Effect(function(effect, index)
		local sprite = effect:GetSprite()
		if not sprite:IsPlaying("ExplodeEmpty") then
			sprite:Play("Explode")
		end
	end, SPIDER_EGG.ID)
end

local function explodeEggCheck(legacyMethod)
	legacyMethod = type(legacyMethod) == "boolean"
	if legacyMethod and Mod:IsLegacyGameplayEnabled()
		or not legacyMethod and not Mod:IsLegacyGameplayEnabled()
	then
		SPIDER_EGG:ExplodeEggOnClearTrigger()
	end
end


Mod:AddCallback(ModCallbacks.MC_POST_START_GREED_WAVE, function()
	explodeEggCheck(true)
end)
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_ROOM_CLEAR, explodeEggCheck)

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
