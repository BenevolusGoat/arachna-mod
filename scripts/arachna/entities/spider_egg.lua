--#region Variables

local Mod = ARACHNAMOD
local ceil = Mod.math.ceil
local floor = Mod.math.floor

local SPIDER_EGG = {}

ARACHNAMOD.Entities.SPIDER_EGG = SPIDER_EGG

SPIDER_EGG.ID = Isaac.GetEntityVariantByName("Spider Egg")

SPIDER_EGG.BIRTHRIGHT_WEB_HEART_CHANCE = 0.05

SPIDER_EGG.MAX_EGG_TIMEOUT = 500

---@enum SpiderEggSubtype
SPIDER_EGG.EggSubtype = {
	NORMAL = Isaac.GetEntitySubTypeByName("Spider Egg"),
	SMALL = Isaac.GetEntitySubTypeByName("Spider Egg (Small)"),
	BOSS = Isaac.GetEntitySubTypeByName("Spider Egg (Boss)"),
}

--#endregion

--#region Helpers

---@param npc Entity
function SPIDER_EGG:ShouldNotSpawnEgg(npc)
	local legacy = Mod:IsLegacyGameplayEnabled()
	--For enemies that turn frozen and dont trigger MC_POST_NPC_DEATH, thus their "new MaxHitPoints" being 10, its saved before they freeze
	local hitPoints = Mod:GetData(npc).WebbedOverrideHitPoints or npc.MaxHitPoints
	return hitPoints < 10
		or npc.SpawnerType ~= EntityType.ENTITY_NULL
		or (legacy and npc:IsBoss())
end

---Enemies spawned by other enemies will have a 50/50 chance to not spawn a Spider Egg, and in such case this function will return nothing
---@param pos Vector
---@param npc? Entity
---@param player? EntityPlayer
---@param eggSubtype? SpiderEggSubtype
function SPIDER_EGG:TrySpawnEgg(pos, npc, player, eggSubtype)
	if npc and SPIDER_EGG:ShouldNotSpawnEgg(npc) then
		if not Mod:IsLegacyGameplayEnabled() and player then
			Mod.Entities.COLORED_SPIDERS:ThrowFriendlySpider(player, Mod.Entities.COLORED_SPIDERS:GetRandomSpiderSubtype(), pos)
			if Mod.Character.ARACHNA:ArachnaHasBirthright(player) and player:GetCollectibleRNG(Mod.Item.ARACHNAS_SPOOL.ID):RandomFloat() < 0.5 then
				Mod.Entities.COLORED_SPIDERS:ThrowFriendlySpider(player, Mod.Entities.COLORED_SPIDERS:GetRandomSpiderSubtype(), pos)
			end
		end
		Mod:DebugLog(Mod:TypeVarSubToString(npc), "spawning regular spider instead of egg")
		return
	end
	local subtype = eggSubtype or 0
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
	local eggName = egg.SubType == SPIDER_EGG.EggSubtype.SMALL and "spider_egg_small" or "spider_egg"

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
local function rewardLegacy(egg)
	local player = egg.SpawnerEntity and egg.SpawnerEntity:ToPlayer()
	if not player then player = Isaac.GetPlayer() end
	local stageNum = Mod.Game:GetLevel():GetStage()
	local spiderCount = 0
	local rng = egg:GetDropRNG()
	local webHearts = Mod.Pickup.WEB_HEART:GetWebHearts(player)
	local stageModifier = ceil((stageNum + 1) / 2) * 0.5
	local minSpiders, maxSpiders = 2, 4
	local shouldIncreaseSpider = Mod.Character.ARACHNA:ArachnaHasBirthright(player) or Mod.Character.ARACHNA_B:IsArachnaB(player)
	local COLORED_SPIDERS = Mod.Entities.COLORED_SPIDERS

	if shouldIncreaseSpider then
		minSpiders = minSpiders + 1
		maxSpiders = maxSpiders + 1
	end

	if shouldIncreaseSpider then
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
		end
		COLORED_SPIDERS:ThrowFriendlySpider(player, spiderSubtype, egg.Position)
	end

	if Mod.Character.ARACHNA:ArachnaHasBirthright(player) and rng:RandomFloat() < SPIDER_EGG.BIRTHRIGHT_WEB_HEART_CHANCE then
		Mod.Spawn.Pickup(Mod.Pickup.WEB_HEART.ID, 0, egg.Position, nil, egg)
	end
end

---@param egg EntityEffect
---@param rewards? boolean
function SPIDER_EGG:Explode(egg, rewards)
	Mod.Game:SpawnParticles(egg.Position, EffectVariant.BLOOD_PARTICLE, Mod:RandomNum(7, 14), 4,
	Color(1, 1, 1, 1, 1, 1, 1))
	Mod.sfxman:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.8, 2, false, 1.25)
	egg:Remove()
	if not rewards then
		return
	end
	if Mod:IsLegacyGameplayEnabled() then
		rewardLegacy(egg)
		return
	end
	local player = egg.SpawnerEntity and egg.SpawnerEntity:ToPlayer()
	if not player then player = Isaac.GetPlayer() end
	local stageNum = Mod.Game:GetLevel():GetStage()
	local spiderCount = 0
	local rng = egg:GetDropRNG()
	local webHearts = Mod.math.max(0, floor(Mod.Pickup.WEB_HEART:GetWebHearts(player) / 1.5))
	local stageModifier = Mod.math.max(1, ceil((stageNum + 1) / 2) * 0.5)
	local minSpiders, maxSpiders = 2, 3
	local COLORED_SPIDERS = Mod.Entities.COLORED_SPIDERS
	local arachnaBirthright = Mod.Character.ARACHNA:ArachnaHasBirthright(player)
	local allowBig = false
	local bonusColorChance = 0
	local bonusBigChance = 0
	if arachnaBirthright then
		bonusColorChance = bonusColorChance + 0.15
	end
	if egg.SubType == SPIDER_EGG.EggSubtype.BOSS then
		bonusBigChance = bonusBigChance + 0.5
		allowBig = true
	end
	if Mod.Character.ARACHNA_B:IsArachnaB(player) then
		bonusBigChance = bonusBigChance + 0.25
		allowBig = true
	end

	if arachnaBirthright then
		minSpiders = minSpiders + 1
		maxSpiders = maxSpiders + 1
	end

	if egg.SubType == SPIDER_EGG.EggSubtype.SMALL then
		minSpiders = minSpiders - 1
		maxSpiders = maxSpiders - 1
	end

	spiderCount = floor(ceil(stageModifier * Mod:RandomNum(minSpiders, maxSpiders + webHearts, rng)))
	Mod:DebugLog("Spawning", spiderCount, "spiders from a random count of", stageModifier, "*", "RandomNum(" .. minSpiders .. ", (" .. maxSpiders, "+", webHearts .. "))")

	for _ = 1, spiderCount do
		local spiderSubtype = COLORED_SPIDERS:GetRandomSpiderSubtype(allowBig, false, bonusColorChance, bonusBigChance)
		COLORED_SPIDERS:ThrowFriendlySpider(player, spiderSubtype, egg.Position)
	end

	if arachnaBirthright and rng:RandomFloat() < SPIDER_EGG.BIRTHRIGHT_WEB_HEART_CHANCE then
		Mod.Spawn.Pickup(Mod.Pickup.WEB_HEART.ID, 0, egg.Position, nil, egg)
	end
end

--#endregion

--#region Effect Update

---@param egg EntityEffect
function SPIDER_EGG:OnUpdate(egg)
	local sprite = egg:GetSprite()
	if sprite:IsFinished("Appear") then
		sprite:Play("Idle")
	end

	if (Mod.Room():IsClear() or egg.SubType == SPIDER_EGG.EggSubtype.SMALL) and (sprite:IsPlaying("Idle")) then
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
		local frameNum = floor(effect.Timeout / SPIDER_EGG.MAX_EGG_TIMEOUT * 100) - 1
		eggTimerSprite:SetFrame("Charging", frameNum)
		eggTimerSprite:Render(renderPos)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, SPIDER_EGG.RenderTimer, SPIDER_EGG.ID)

--#endregion
