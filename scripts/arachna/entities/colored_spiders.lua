--#region Variables

local Mod = ARACHNAMOD

local COLORED_SPIDERS = {}

ARACHNAMOD.Entities.COLORED_SPIDERS = COLORED_SPIDERS

local function getSub(str)
	return Isaac.GetEntitySubTypeByName("Arachna Spider (" .. str .. ")")
end

---@enum ColoredSpiderSubtype
COLORED_SPIDERS.SpiderSubtype = {
	NORMAL = 0,
	WRATH = getSub("Wrath"),
	PESTILENCE = getSub("Pestilence"),
	FAMINE = getSub("Famine"),
	DEATH = getSub("Death"),
	CONQUEST = getSub("Conquest"),
	RAINBOW = getSub("Rainbow"),
	GOLDEN = getSub("Golden"),
	LOVE = getSub("Love"),
	ICE = getSub("Ice"),
	BIG_FLAG = 10,
	LAST_SPIDER_SUBTYPE = 19
}

COLORED_SPIDERS.SpiderColors = {
	[COLORED_SPIDERS.SpiderSubtype.WRATH] = Color(1, 1, 0, 1, 0.49, 0, 0),
	[COLORED_SPIDERS.SpiderSubtype.PESTILENCE] = Color(1, 1, 0, 1, 0, 0.31, 0),
	[COLORED_SPIDERS.SpiderSubtype.FAMINE] = Color(0.8, 0.8, 0, 1, 0.31, 0.22, 0),
	[COLORED_SPIDERS.SpiderSubtype.DEATH] = Color(0, 0, 0, 1, 0, 0, 0),
	[COLORED_SPIDERS.SpiderSubtype.CONQUEST] = Color(1, 1, 1, 1, 0.78, 0.78, 0.78),
	[COLORED_SPIDERS.SpiderSubtype.RAINBOW] = Color.Default,
	[COLORED_SPIDERS.SpiderSubtype.GOLDEN] = Color(1, 1, 0, 1, 0.6, 0.4, 0.1),
	[COLORED_SPIDERS.SpiderSubtype.LOVE] = Color(1, 1, 0, 1, 0.35, 0.1, 0.35),
	[COLORED_SPIDERS.SpiderSubtype.ICE] = Color(0, 1, 1, 1, 0, 0.3, 0.49),
}

COLORED_SPIDERS.ShinySubtypes = Mod:Set({
	COLORED_SPIDERS.SpiderSubtype.RAINBOW,
	COLORED_SPIDERS.SpiderSubtype.GOLDEN,
})

COLORED_SPIDERS.COLORED_SPIDER_CHANCE = 0.35

local WOP = WeightedOutcomePicker()
WOP:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.WRATH, 2)
WOP:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.PESTILENCE, 5)
WOP:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.FAMINE, 5)
WOP:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.DEATH, 4)
WOP:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.CONQUEST, 5)
WOP:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.RAINBOW, 1)
WOP:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.GOLDEN, 3)
WOP:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.LOVE, 4)
WOP:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.ICE, 3)

--For legacy gameplay
local WOP_LEGACY = WeightedOutcomePicker()
WOP_LEGACY:AddOutcomeWeight(0, 25)
WOP_LEGACY:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.WRATH, 4)
WOP_LEGACY:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.PESTILENCE, 5)
WOP_LEGACY:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.FAMINE, 5)
WOP_LEGACY:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.DEATH, 5)
WOP_LEGACY:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.CONQUEST, 5)
WOP_LEGACY:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.RAINBOW, 4)
WOP_LEGACY:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.GOLDEN, 2)
WOP_LEGACY:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.LOVE, 4)
WOP_LEGACY:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.ICE, 2)
COLORED_SPIDERS.WOP = WOP_LEGACY

local WOP_BIG_LEGACY = WeightedOutcomePicker()
for _, wopOutcome in ipairs(WOP_LEGACY:GetOutcomes()) do
	if wopOutcome.Value ~= COLORED_SPIDERS.SpiderSubtype.BIG_FLAG then
		WOP_BIG_LEGACY:AddOutcomeWeight(wopOutcome.Value, wopOutcome.Weight)
	end
end
WOP_BIG_LEGACY:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.BIG_FLAG, 4)
WOP_BIG_LEGACY:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.WRATH + COLORED_SPIDERS.SpiderSubtype.BIG_FLAG, 2)
WOP_BIG_LEGACY:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.PESTILENCE + COLORED_SPIDERS.SpiderSubtype.BIG_FLAG, 3)
WOP_BIG_LEGACY:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.FAMINE + COLORED_SPIDERS.SpiderSubtype.BIG_FLAG, 3)
WOP_BIG_LEGACY:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.DEATH + COLORED_SPIDERS.SpiderSubtype.BIG_FLAG, 3)
WOP_BIG_LEGACY:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.CONQUEST + COLORED_SPIDERS.SpiderSubtype.BIG_FLAG, 3)
WOP_BIG_LEGACY:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.RAINBOW + COLORED_SPIDERS.SpiderSubtype.BIG_FLAG, 3)
WOP_BIG_LEGACY:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.GOLDEN + COLORED_SPIDERS.SpiderSubtype.BIG_FLAG, 2)
WOP_BIG_LEGACY:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.LOVE + COLORED_SPIDERS.SpiderSubtype.BIG_FLAG, 3)
WOP_BIG_LEGACY:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.ICE + COLORED_SPIDERS.SpiderSubtype.BIG_FLAG, 2)
COLORED_SPIDERS.WOP_BIG = WOP_BIG_LEGACY

--#endregion

--#region Load Spiders

local spiders = {
	"spider_wrath",
	"spider_pestilence",
	"spider_famine",
	"spider_death",
	"spider_rainbow",
	"spider_golden",
	"spider_love",
	"spider_ice",
}

Mod.LoopInclude(spiders, "scripts.arachna.entities.colored_spiders")

--#endregion

--#region Helpers

---@param spider EntityFamiliar
function COLORED_SPIDERS:IsBigSpider(spider)
	return spider.SubType >= COLORED_SPIDERS.SpiderSubtype.BIG_FLAG
end

---@param spider EntityFamiliar
---@param checkBig? boolean @default: `nil`. Set to `true` to only check big spiders. Set to `false` to only check small spiders.
function COLORED_SPIDERS:IsColoredSpider(spider, checkBig)
	local isColored = spider.SubType > 0
		and spider.SubType <= COLORED_SPIDERS.SpiderSubtype.LAST_SPIDER_SUBTYPE
		and spider.SubType ~= COLORED_SPIDERS.SpiderSubtype.BIG_FLAG
	local isBig = spider.SubType > COLORED_SPIDERS.SpiderSubtype.BIG_FLAG
	if checkBig then
		return isColored and isBig
	elseif checkBig == false then
		return isColored and not isBig
	else
		return isColored
	end
end

---@param bigSpider? boolean
---@param onlyColor? boolean
local function legacyRandomSpider(bigSpider, onlyColor)
	local wop = bigSpider and WOP_BIG_LEGACY or WOP_LEGACY
	local rng = Isaac.GetPlayer():GetCollectibleRNG(Mod.Item.MUTAGEN.ID)
	local randomSpiderSubtype = 0
	if onlyColor then
		wop:RemoveOutcome(0)
		if bigSpider then
			wop:RemoveOutcome(COLORED_SPIDERS.SpiderSubtype.BIG_FLAG)
		end
		randomSpiderSubtype = wop:PickOutcome(rng)
		wop:AddOutcomeWeight(0, 25)
		if bigSpider then
			wop:AddOutcomeWeight(COLORED_SPIDERS.SpiderSubtype.BIG_FLAG, 4)
		end
	else
		randomSpiderSubtype = wop:PickOutcome(rng)
	end
	return randomSpiderSubtype
end

---@param onlyColor? boolean @Will return a non-default spider color
---@param bonusColorChance? number @Adds onto the existing chance for a spider to become a colored spider
---@param bigChance? number @Chance for the spider to become a big spider
---@return ColoredSpiderSubtype
function COLORED_SPIDERS:GetRandomSpiderSubtype(onlyColor, bonusColorChance, bigChance)
	if Mod:IsLegacyGameplayEnabled() then
		return legacyRandomSpider(bigChance > 0, onlyColor)
	end
	bonusColorChance = bonusColorChance or 0
	local rng = Isaac.GetPlayer():GetCollectibleRNG(Mod.Item.MUTAGEN.ID)
	local randomSpiderSubtype = 0
	---@cast randomSpiderSubtype ColoredSpiderSubtype
	if onlyColor or rng:RandomFloat() < COLORED_SPIDERS.COLORED_SPIDER_CHANCE + bonusColorChance then
		randomSpiderSubtype = WOP:PickOutcome(rng)
	end
	if bigChance and rng:RandomFloat() < bigChance then
		randomSpiderSubtype = randomSpiderSubtype + COLORED_SPIDERS.SpiderSubtype.BIG_FLAG
	end
	return randomSpiderSubtype
end

---@param player EntityPlayer
---@param subtype ColoredSpiderSubtype | integer
---@param pos Vector
---@param distOrTarget? number | Vector
function COLORED_SPIDERS:ThrowFriendlySpider(player, subtype, pos, distOrTarget)
	local targetPos
	if type(distOrTarget) == "userdata" and getmetatable(distOrTarget).__type == "Vector" then
		targetPos = distOrTarget
	else
		local dist = distOrTarget or 80
		---@cast dist number
		targetPos = Isaac.GetFreeNearPosition(pos + Vector(dist, 0):Rotated(Mod:RandomNum(360)), 0)
	end
	---@cast targetPos Vector
	Mod:GetData(player).IgnoreMutagen = true
	local spider = player:ThrowBlueSpider(pos, targetPos):ToFamiliar()
	Mod:GetData(player).IgnoreMutagen = false
	---@cast spider EntityFamiliar
	if subtype == 0 then return spider end
	spider.SubType = subtype
	COLORED_SPIDERS:OnSpiderInit(spider)
	return spider
end

---@param spider EntityFamiliar
function COLORED_SPIDERS:TrySpawnGlow(spider)
	if COLORED_SPIDERS.ShinySubtypes[spider.SubType % 10] then
		local isBig = COLORED_SPIDERS:IsBigSpider(spider)
		local glow = Mod.Spawn.Effect(EffectVariant.LIGHT, 0, spider.Position, nil, spider)
		glow:FollowParent(spider)
		Mod:GetData(spider).SpiderGlow = EntityPtr(glow)
		if isBig then
			glow.SpriteScale = glow.SpriteScale * 0.8
		else
			glow.SpriteScale = glow.SpriteScale * 0.5
		end
	end
end

--#endregion

--#region Spider Init

---@param spider EntityFamiliar
function COLORED_SPIDERS:OnSpiderInit(spider)
	if spider.SubType == 0 then return end
	local anm2 = EntityConfig.GetEntity(spider.Type, spider.Variant, spider.SubType):GetAnm2Path()
	local sprite = spider:GetSprite()
	if sprite:GetFilename() ~= anm2 then
		local anim = sprite:GetAnimation()
		sprite:Load(anm2, true)
		sprite:Play(anim)
	end
	local spiderColor = spider.SubType % 10
	local color = COLORED_SPIDERS.SpiderColors[spiderColor]
	if color then
		spider.Color = color
	end
	COLORED_SPIDERS:TrySpawnGlow(spider)
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, COLORED_SPIDERS.OnSpiderInit, FamiliarVariant.BLUE_SPIDER)

--#endregion

--#region Respawn Glow

function COLORED_SPIDERS:RespawnGlowOnNewRoom()
	Mod.Foreach.Familiar(function(spider, index)
		COLORED_SPIDERS:TrySpawnGlow(spider)
	end, FamiliarVariant.BLUE_SPIDER)
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, COLORED_SPIDERS.RespawnGlowOnNewRoom)

--#endregion

--#region Spider Damage

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function COLORED_SPIDERS:PreTakeDamageFromSpider(ent, amount, flags, source, countdown)
	local familiar = source.Entity and source.Entity:ToFamiliar()
	if familiar and familiar.Variant == FamiliarVariant.BLUE_SPIDER and familiar.SubType > 0 then
		local returnTable = {}
		if COLORED_SPIDERS:IsBigSpider(familiar) then
			amount = amount + (amount / 2)
			returnTable.Damage = amount
		end
		local spiderColor = familiar.SubType % 10
		local result = Isaac.RunCallbackWithParam(Mod.ModCallbacks.PRE_ENEMY_TAKE_DMG_FROM_SPIDER, spiderColor, ent,
			amount, flags, familiar, countdown)

		if result == false or type(result) == "table" or returnTable.Damage then
			if type(result) == "table" then
				result.Damage = (result.Damage or 0) + (returnTable.Damage or 0)
			end
			return result
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE - 1,
	COLORED_SPIDERS.PreTakeDamageFromSpider)

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function COLORED_SPIDERS:PostTakeDamageFromSpider(ent, amount, flags, source, countdown)
	local familiar = source.Entity and source.Entity:ToFamiliar()
	if familiar and familiar.Variant == FamiliarVariant.BLUE_SPIDER and familiar.SubType > 0 then
		local spiderColor = familiar.SubType % 10
		Isaac.RunCallbackWithParam(Mod.ModCallbacks.POST_ENEMY_TAKE_DMG_FROM_SPIDER, spiderColor, ent, amount, flags,
			familiar, countdown)
		if COLORED_SPIDERS:IsBigSpider(familiar) then
			local player = familiar.Player
			local vecRad = Mod:RandomNum(75, 100)
			local vecAngle = Mod:RandomNum(360)
			local pos = familiar.Position
			COLORED_SPIDERS:ThrowFriendlySpider(player, familiar.SubType - COLORED_SPIDERS.SpiderSubtype.BIG_FLAG, pos,
				Isaac.GetFreeNearPosition(pos + Vector.FromAngle(vecAngle):Resized(vecRad), 50))
			COLORED_SPIDERS:ThrowFriendlySpider(player, familiar.SubType - COLORED_SPIDERS.SpiderSubtype.BIG_FLAG, pos,
				Isaac.GetFreeNearPosition(pos + Vector.FromAngle(vecAngle - 180):Resized(vecRad), 50))
			Mod.sfxman:Play(SoundEffect.SOUND_BOIL_HATCH, 0.8)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, COLORED_SPIDERS.PostTakeDamageFromSpider)

--#endregion

--#region Spider Update

---@param spider EntityFamiliar
function COLORED_SPIDERS:ShinySpiderUpdate(spider)
	if COLORED_SPIDERS:IsColoredSpider(spider) then
		local spiderColor = spider.SubType % 10
		Isaac.RunCallbackWithParam(Mod.ModCallbacks.COLORED_SPIDER_UPDATE, spiderColor, spider)
		---@type EntityPtr?
		local glowEffect = Mod:GetData(spider).SpiderGlow
		if glowEffect and glowEffect.Ref then
			glowEffect.Ref.Color = spider:GetSprite().Color
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, COLORED_SPIDERS.ShinySpiderUpdate, FamiliarVariant.BLUE_SPIDER)

--#endregion

--#region Obsure Spider with Egg

---@param familiar EntityFamiliar
---@param offset Vector
function COLORED_SPIDERS:RenderEggOnSpider(familiar, offset)
	local data = Mod:TryGetData(familiar)
	if data and data.EggCoveredSpider then
		if not data.EggSprite then
			data.EggSprite = Sprite("gfx/002.027_egg tear.anm2", true)
			local sizeNum = familiar.SubType >= COLORED_SPIDERS.SpiderSubtype.BIG_FLAG and "4" or "3"
			data.EggSprite:Play("Stone" .. sizeNum .. "Move")
		end
		data.EggSprite:Render(Mod:GetEntityRenderPosition(familiar, offset))
		if Mod:ShouldUpdateSprite() then
			data.EggSprite:Update()
		end
		--The frame they land
		if familiar.FrameCount >= 21 then
			local poof = Mod.Spawn.Effect(EffectVariant.TEAR_POOF_A, 0, familiar.Position)
			poof.Color = Color(0.5, 0.5, 0.5, 1, 0.5, 0.5, 0.5)
			Mod.sfxman:Play(SoundEffect.SOUND_BOIL_HATCH)
			data.EggSprite = nil
			data.EggCoveredSpider = nil
		end
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_RENDER, COLORED_SPIDERS.RenderEggOnSpider, FamiliarVariant.BLUE_SPIDER)

--#endregion