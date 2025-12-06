--#region Variables

local Mod = ARACHNAMOD
local ceil = Mod.math.ceil
local floor = Mod.math.floor
local COLORED_SPIDERS = Mod.Entities.COLORED_SPIDERS

local SPIDER_EGG = {}

ARACHNAMOD.Entities.SPIDER_EGG = SPIDER_EGG

SPIDER_EGG.ID = Isaac.GetEntityVariantByName("Spider Egg")
SPIDER_EGG.ID_SMALL = Isaac.GetEntityVariantByName("Spider Egg (Small)")

SPIDER_EGG.BIRTHRIGHT_WEB_HEART_CHANCE = 0.05
SPIDER_EGG.RARE_SPRITE_CHANCE = 0.001

SPIDER_EGG.MAX_EGG_TIMEOUT = 500

---@enum SpiderEggFlag
SPIDER_EGG.EggFlag = {
	SMALL = 1 << 0, --Produce less spiders
	BOSS = 1 << 1, --+50% chance to spawn big spiders
	THROWN = 1 << 2, --Was an egg that was thrown directly at enemies. Negates T. Arachna big spider bonus, 50% less spiders
}

SPIDER_EGG.EggColors = {
	[COLORED_SPIDERS.SpiderSubtype.WRATH] = Color(1, 1, 1, 1, 0, 0, 0, 1, 0.1, 0, 1),
	[COLORED_SPIDERS.SpiderSubtype.PESTILENCE] = Color(1, 1, 1, 1, 0, 0, 0, 0.2, 0.75, 0.2, 1),
	[COLORED_SPIDERS.SpiderSubtype.FAMINE] = Color(1, 1, 1, 1, 0, 0, 0, 0.5, 0.5, 0, 1),
	[COLORED_SPIDERS.SpiderSubtype.DEATH] = Color(1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0.9),
	[COLORED_SPIDERS.SpiderSubtype.CONQUEST] = Color(1, 1, 1, 1, 0.5, 0.5, 0.5),
	[COLORED_SPIDERS.SpiderSubtype.RAINBOW] = Color(0.4, 0.4, 0.4, 1),
	[COLORED_SPIDERS.SpiderSubtype.GOLDEN] = Color(0.5, 0.5, 0.5, 1, 0.9, 0.6, 0, 1, 0.8, 0, 1),
	[COLORED_SPIDERS.SpiderSubtype.LOVE] = Color(1, 1, 1, 1, 0, 0, 0, 0.75, 0.3, 0.75, 1),
	[COLORED_SPIDERS.SpiderSubtype.ICE] = Color(1, 1, 1, 1, 0, 0.3, 0.49, 0.5, 0.5, 0.5, 1.5),
}

--#endregion

--#region Helpers

---@param spiderColor ColoredSpiderSubtype
---@return Color?
function SPIDER_EGG:GetEggColor(spiderColor)
	spiderColor = spiderColor % 10
	return SPIDER_EGG.EggColors[spiderColor]
end

---@param player EntityPlayer
---@param eggFlags? SpiderEggFlag
function SPIDER_EGG:GetSpiderCountRange(player, eggFlags)
	local arachnaBirthright = Mod.Character.ARACHNA:ArachnaHasBirthright(player)
	local webHearts = Mod.Pickup.WEB_HEART:GetWebHearts(player)
	local minSpiders, maxSpiders = 2, 4
	if arachnaBirthright then
		minSpiders = minSpiders + 1
		maxSpiders = maxSpiders + 1
	end

	if eggFlags and Mod:HasBitFlags(eggFlags, SPIDER_EGG.EggFlag.SMALL) then
		minSpiders = minSpiders - 1
		maxSpiders = maxSpiders - 2
	end

	if eggFlags and Mod:HasBitFlags(eggFlags, SPIDER_EGG.EggFlag.THROWN) then
		minSpiders = Mod.math.max(1, Mod.math.floor(minSpiders / 2))
		maxSpiders = Mod.math.max(1, Mod.math.floor(maxSpiders / 2))
	end
	return minSpiders, maxSpiders + webHearts
end

---@param player EntityPlayer
---@param eggFlags? SpiderEggFlag
function SPIDER_EGG:GetSpiderBonusChances(player, eggFlags)
	local arachnaBirthright = Mod.Character.ARACHNA:ArachnaHasBirthright(player)
	local bonusColorChance = 0
	local bigChance = 0
	if arachnaBirthright then
		bonusColorChance = bonusColorChance + 0.15
	end
	if eggFlags and Mod:HasBitFlags(eggFlags, SPIDER_EGG.EggFlag.BOSS) then
		bigChance = bigChance + 0.5
	end
	if Mod.Character.ARACHNA_B:IsArachnaB(player) and not (eggFlags and Mod:HasBitFlags(eggFlags, SPIDER_EGG.EggFlag.THROWN)) then
		bigChance = bigChance + 0.25
	end
	return bonusColorChance, bigChance
end

---@param npc Entity
function SPIDER_EGG:ShouldNotSpawnEgg(npc)
	--For enemies that turn frozen and dont trigger MC_POST_NPC_DEATH, thus their "new MaxHitPoints" being 10, its saved before they freeze
	local hitPoints = Mod:GetData(npc).WebbedOverrideHitPoints or npc.MaxHitPoints
	if Mod:IsLegacyGameplayEnabled() then
		return hitPoints < 10
			or npc:IsBoss()
			or npc.SpawnerEntity ~= EntityType.ENTITY_NULL
	end
	return hitPoints < 10
		or (npc.SpawnerType ~= EntityType.ENTITY_NULL and (not npc.SpawnerEntity or not npc.SpawnerEntity:IsBoss()))
end

---@param player EntityPlayer
---@param pos Vector
---@param numSpiders integer
---@param dist? number @default: `80`
---@param eggFlags? SpiderEggFlag @default: `nil`.
---@param obscureInEgg? boolean @default: `false`. If set to `true`, will hide the spider behind a rendered Parasitoid Egg tear until it lands on the ground.
---@param forceColor? ColoredSpiderSubtype @default: `nil`. If set with a specific spider subtype, the burst will spawn all spiders of the provided color. Spiders still go through the random chance of being a big spider.
function SPIDER_EGG:SpawnSpiderBurst(player, pos, numSpiders, dist, eggFlags, obscureInEgg, forceColor)
	local bonusColorChance, bigChance = SPIDER_EGG:GetSpiderBonusChances(player, eggFlags)
	for _ = 1, numSpiders do
		local spiderSubtype = COLORED_SPIDERS.SpiderSubtype.NORMAL
		if forceColor then
			spiderSubtype = forceColor
			if bigChance > 0 and Isaac.GetPlayer():GetCollectibleRNG(Mod.Item.MUTAGEN.ID):RandomFloat() < bigChance then
				spiderSubtype = spiderSubtype + COLORED_SPIDERS.SpiderSubtype.BIG_FLAG
			end
		elseif (Mod:IsLegacyGameplayEnabled() and Mod:IsAnyArachna(player) or Mod.Character.ARACHNA:IsArachna(player)) or player:HasCollectible(Mod.Item.MUTAGEN.ID) then
			spiderSubtype = COLORED_SPIDERS:GetRandomSpiderSubtype(false, bonusColorChance, bigChance)
		end
		local spider = COLORED_SPIDERS:ThrowFriendlySpider(player, spiderSubtype, pos, dist)
		Mod:GetData(spider).EggCoveredSpider = obscureInEgg
	end
end

---Enemies spawned by other enemies will have a 50/50 chance to not spawn a Spider Egg, and in such case this function will return nothing.
---@param pos Vector
---@param npc Entity
---@param player EntityPlayer
---@param eggFlags? SpiderEggFlag
---@param eggSubtype? ColoredSpiderSubtype @default: `0`. Spawns an egg that will only spawn the appropriate color of spiders. A SubType of `0` will have normal behaviour of spawning any spider color at random.
function SPIDER_EGG:TrySpawnEgg(pos, npc, player, eggFlags, eggSubtype)
	local isLegacy = Mod:IsLegacyGameplayEnabled()
	if SPIDER_EGG:ShouldNotSpawnEgg(npc) then
		if not isLegacy then
			local count = 1
			if Mod.Character.ARACHNA:ArachnaHasBirthright(player) and player:GetCollectibleRNG(Mod.Item.ARACHNAS_SPOOL.ID):RandomFloat() < 0.5 then
				count = 2
			end
			local dist = npc.Size + 40
			SPIDER_EGG:SpawnSpiderBurst(player, pos, count, dist, nil, true)
			Mod:DebugLog(Mod:TypeVarSubToString(npc), "spawning regular spider instead of egg")
		end
		return
	end
	if eggFlags and Mod:HasBitFlags(eggFlags, SPIDER_EGG.EggFlag.SMALL) and isLegacy then
		return
	end
	local spiderColor = eggSubtype and eggSubtype % 10 or 0
	local egg = Mod.Spawn.Effect(SPIDER_EGG.ID, spiderColor, pos, nil, player)
	Mod:GetData(egg).EggFlags = eggFlags
	if Mod.Character.ARACHNA_B:IsArachnaB(player) and isLegacy then
		egg:SetTimeout(SPIDER_EGG.MAX_EGG_TIMEOUT)
	end
end

--#endregion

--#region Egg Init

---@param egg EntityEffect
function SPIDER_EGG:OnInit(egg)
	local rng = egg:GetDropRNG()
	local sprite = egg:GetSprite()
	local eggName = egg.Variant == SPIDER_EGG.ID_SMALL and "spider_egg_small" or "spider_egg"

	if rng:RandomFloat() < SPIDER_EGG.RARE_SPRITE_CHANCE then
		sprite:ReplaceSpritesheet(0, "gfx/familiars/" .. eggName .. "_rare.png")
	else
		sprite:ReplaceSpritesheet(0, "gfx/familiars/" .. eggName .. "_" .. tostring(rng:RandomInt(4) + 1) .. ".png")
	end
	sprite:LoadGraphics()
	sprite:Play("Appear", true)
	--Allow it to be picked up by Isaac.FindInRadius
	egg.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY

	local color = SPIDER_EGG:GetEggColor(egg.SubType)
	if color then
		egg.Color = color
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, SPIDER_EGG.OnInit, SPIDER_EGG.ID)
Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, SPIDER_EGG.OnInit, SPIDER_EGG.ID_SMALL)

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
	local shouldIncreaseSpider = Mod.Character.ARACHNA:ArachnaHasBirthright(player) or
		Mod.Character.ARACHNA_B:IsArachnaB(player)

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
			--Even though its passing 0.2 for big chance, legacy only checks if its above 0 to do its own calculations
			spiderSubtype = COLORED_SPIDERS:GetRandomSpiderSubtype(nil, nil, Mod.Entities.COLORED_SPIDERS.BIG_SPIDER_CHANCE)
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
	local color = SPIDER_EGG:GetEggColor(egg.SubType) or Color(1,1,1,1,1,1,1)
	Mod.Game:SpawnParticles(egg.Position, EffectVariant.BLOOD_PARTICLE, Mod:RandomNum(7, 14), 4, color)
	Mod.sfxman:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.8, 2, false, 1.25)
	if not rewards then
		egg:Remove()
		return
	end
	if Mod:IsLegacyGameplayEnabled() then
		rewardLegacy(egg)
		egg:Remove()
		return
	end
	local player = egg.SpawnerEntity and egg.SpawnerEntity:ToPlayer()
	if not player then player = Isaac.GetPlayer() end
	local spiderCount = 0
	local rng = egg:GetDropRNG()
	local arachnaBirthright = Mod.Character.ARACHNA:ArachnaHasBirthright(player)
	---@type SpiderEggFlag
	local eggFlags = Mod:GetData(egg).EggFlags
	local minSpiders, maxSpiders = SPIDER_EGG:GetSpiderCountRange(player, eggFlags)
	local forcedColor = egg.SubType > 0 and egg.SubType or nil

	spiderCount = Mod:RandomNum(minSpiders, maxSpiders, rng)
	SPIDER_EGG:SpawnSpiderBurst(player, egg.Position, spiderCount, nil, eggFlags, false, forcedColor)

	if arachnaBirthright and rng:RandomFloat() < SPIDER_EGG.BIRTHRIGHT_WEB_HEART_CHANCE then
		Mod.Spawn.Pickup(Mod.Pickup.WEB_HEART.ID, 0, egg.Position, nil, egg)
	end
	egg:Remove()
end

--#endregion

--#region Effect Update

---@param egg EntityEffect
function SPIDER_EGG:OnUpdate(egg)
	local sprite = egg:GetSprite()
	if egg.SubType == COLORED_SPIDERS.SpiderSubtype.RAINBOW then
		local r, g, b = table.unpack(COLORED_SPIDERS:GetRainbowColor())
		egg:GetSprite().Color:SetColorize(r, g, b, 0.5)
	elseif egg.SubType == COLORED_SPIDERS.SpiderSubtype.GOLDEN then
		if egg.FrameCount % 2 == 0 then
			local variance = Vector(Mod:RandomNum(-egg.Size, egg.Size), -1 * Mod:RandomNum(0, egg.Size * 2))
			COLORED_SPIDERS:SpawnSparkle(egg.Position + variance)
		end
	end
	if sprite:IsFinished("Appear") then
		sprite:Play("Idle")
	end

	if (Mod.Room():IsClear() or egg.Variant == SPIDER_EGG.ID_SMALL) and (sprite:IsPlaying("Idle")) then
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
Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, SPIDER_EGG.OnUpdate, SPIDER_EGG.ID_SMALL)

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
