--Full credit to Epiphany for this easy and flexible EID system
local Mod = ARACHNAMOD
local ARC_EID = {}

ARACHNAMOD.EID_Support = ARC_EID

if not EID then
	return
end

local Item = Mod.Item

---@param entity Entity
---@return EntityPlayer
function ARC_EID:ClosestPlayerTo(entity) --This seems to error for some people sooo yeah
	if not entity then return EID.player end

	if EID.ClosestPlayerTo then
		return EID:ClosestPlayerTo(entity)
	else
		return EID.player
	end
end

--#region Data tables

EID.PocketActivePlayerIDs[Mod.PlayerType.ARACHNA] = Mod.Item.ARACHNAS_SPOOL.ID
EID.PocketActivePlayerIDs[Mod.PlayerType.ARACHNA_B] = Mod.Item.GRAB.ID

EID.CharacterToHeartType[Mod.PlayerType.ARACHNA] = "Web"
EID.CharacterToHeartType[Mod.PlayerType.ARACHNA_B] = "Web"

EID.SpecialHeartPlayers["Web"] = {Mod.PlayerType.ARACHNA, Mod.PlayerType.ARACHNA_B}

EID.HealthTypesWithoutHealing["Web"] = true

Mod:AddToDictionary(EID.CarBatteryNoSynergy, {
	Mod.Item.ARACHNAS_SPOOL.ID,
	Mod.Item.DIVINE_CLOTH.ID,
	Mod.Item.BEST_BUD_BALL.ID,
	Mod.Item.TESTAMENT.ID
})

EID.SingleUseCollectibles[Item.TESTAMENT.ID] = true

EID.TaintedToRegularID[Mod.PlayerType.ARACHNA_B] = Mod.PlayerType.ARACHNA

--#endregion

--#region Icons

local player_icons = Sprite("gfx/ui/eid_arc_players_icon.anm2", true)

local offsetX, offsetY = 2, 1

EID:addIcon("Arachna", "Arachna", 0, 18, 12, offsetX, offsetY, player_icons)
EID:addIcon("ArachnaB", "ArachnaB", 0, 18, 12, offsetX, offsetY, player_icons)

-- Assign Player Icons for Birthright
EID.InlineIcons["Player" .. Mod.PlayerType.ARACHNA] = EID.InlineIcons["Arachna"]
EID.InlineIcons["Player" .. Mod.PlayerType.ARACHNA_B] = EID.InlineIcons["ArachnaB"]

local cardFronts = Sprite("gfx/ui/eid_arc_cardfronts.anm2", true)

-- Assign card icons
for _, card in pairs(Mod.Card) do
	if card.ID then
		local name = Mod.ItemConfig:GetCard(card.ID).HudAnim
		local metadata = { 8, 8, 0, 1 }
		EID:addIcon("Card" .. card.ID, name, 0, metadata[1], metadata[2], metadata[3], metadata[4], cardFronts)
	end
end

local eid_icons = Sprite("gfx/ui/eid_arc_icons.anm2", true)

EID:addIcon("WebHeart", "Web Heart", 0, 10, 9, 1, 1, eid_icons)
EID:addIcon("AracBlueSpider", "Blue Spider", 0, 7, 6, 0, 1, eid_icons)
EID:addIcon("StatusWebbed", "StatusWebbed", 0, 8, 8, 1, 2, eid_icons)
EID:addIcon("StatusSpiderBite", "StatusBitten", 0, 10, 10, 2, 1, eid_icons)
EID:addIcon("ItemPoolSpiderBeggar", "ItemPoolSpiderBeggar", 0, 11, 11, 0, 0, eid_icons)
EID:addIcon("SpiderBeggar", "Spider Beggar", 0, 11, 11, 0, 0, eid_icons)

--#endregion

--#region Helper functions

---@param strTable table
function ARC_EID:GetTranslatedString(strTable)
	local lang = EID.getLanguage() or "en_us"
	local desc = strTable[lang] or strTable["en_us"] -- default to english description if there's no translation

	if desc == '' then                            --Default to english if the corresponding translation doesn't exist and is blank
		desc = strTable["en_us"];
	end

	return desc
end

---@param player EntityPlayer
---@param trinketId TrinketType
function ARC_EID:TrinketMulti(player, trinketId)
	local multi = 1
	if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
		multi = multi + 1
	end
	if Mod:HasBitFlags(trinketId, TrinketType.TRINKET_GOLDEN_FLAG) then
		multi = multi + 1
	end

	return multi
end

---@param multiplier integer
---@param ... string
function ARC_EID:TrinketMultiStr(multiplier, ...)
	return ({ ... })[multiplier] or ""
end

---@param descObj EID_DescObj
---@param desc string | number
---@param multRequirement? boolean | number If a boolean is passed, will only modify text is the object is a golden trinket. If a number is passed, will check that the multiplier is above or equal to this number
---@param emptyIfFailed? boolean Will return an empty string if multiplier isn't above 1 (Or if `multRequirement` is true, it's a golden)
---@param icon? string
function ARC_EID:TrinketMultiGoldStr(descObj, desc, multRequirement, emptyIfFailed, icon)
	icon = icon or ""
	local player = ARC_EID:ClosestPlayerTo(descObj.Entity)
	local trinketID = descObj.ObjSubType
	local mult = ARC_EID:TrinketMulti(player, trinketID)
	if multRequirement and
		(type(multRequirement) == "boolean" and trinketID > TrinketType.TRINKET_GOLDEN_FLAG)
		or type(multRequirement) == "number" and mult >= multRequirement
		or not multRequirement and mult > 1
	then
		return "#" .. icon .. " {{ColorGold}}" .. desc .. "{{CR}}"
	elseif emptyIfFailed then
		return ""
	else
		return tostring(desc)
	end
end

local min = math.min
local max = math.max
local floor = math.floor

---@param player EntityPlayer
---@param modifier TearModifier
---@param chanceMult integer
function ARC_EID:GetTearModifierMaxLuckChance(player, modifier, chanceMult)
	local luck = player.Luck
	player.Luck = 0
	local minChance = modifier:GetChance(player, true, chanceMult)
	player.Luck = luck
	local maxLuck = modifier.MaxLuck
	local luckWorth = (modifier.MaxChance - modifier.MinChance) / (modifier.MaxLuck - modifier.MinLuck)
	local maxChance = minChance + (luckWorth * modifier.MaxLuck)
	if maxChance > 1 then
		local luckSavedInChance = floor((maxChance - 1) / luckWorth)
		maxLuck = max(0, maxLuck - luckSavedInChance)
	end
	return maxChance, maxLuck
end

---@param str string
---@param player EntityPlayer
---@param modifier TearModifier
---@param chanceMult integer
function ARC_EID:LuckChanceStr(str, player, modifier, chanceMult)
	local maxChance, maxLuck = ARC_EID:GetTearModifierMaxLuckChance(player, modifier, chanceMult)
	local maxChanceCapped = min(1, maxChance)
	local maxChanceStr = (tostring(floor(maxChanceCapped * 100)))
	local maxLuckStr = tostring(maxLuck)
	--So that a golden glow doesn't trigger at 100% chance
	if maxChanceCapped > modifier.MaxChance then
		maxChanceStr = "{{ColorGold}}" .. maxChanceStr .. "{{CR}}"
	end
	if maxLuck < modifier.MaxLuck then
		maxLuckStr = "{{ColorGold}}" .. maxLuckStr .. "{{CR}}"
	end
	return str:format(maxChanceStr .. "%", maxLuckStr)
end

---@param descObj EID_DescObj
function ARC_EID.GetFallbackDescription(descObj)
	return EID:getDescriptionObj(5, 100, descObj.ObjSubType, nil, false).Description
end

---{`number` hp, `integer` layer, `number` damage, `number` stageDamage, `number` damageMultiplier2, `number` shotSpeed, `number` fireDelay, `number` procChance, `boolean` canshoot, `integer` amount, `TearFlags[]` tearFlags, `TearFlags[]` tearFlags2}

---@class EID_BoV
---@field HP number
---@field Layer number
---@field Damage number
---@field StageDamage number?
---@field DamageMult number?
---@field ShotSpeed number?
---@field FireDelay number?
---@field ProcChance number?
---@field CanShoot boolean?
---@field Amount integer?
---@field TearFlags TearFlags[]?
---@field TearFlagsOnChance TearFlags[]?

local function EID_addBookOfVirtuesCondition(id, text, numberToDouble, newNumber, language)
	EID:addGenericCondition(id, "bookOfVirtuesWisps", text, numberToDouble, newNumber, language)
end

local function translateNumberString(numStr)
	local out = {}
	local length = string.len(numStr)
	local strStart = 1
	local strEnd = 1
	while strEnd <= length do
		--If a space-separation is on the next character or we're at the end of the string
		if string.sub(strEnd + 1, strEnd + 1) == " " or strEnd == length then
			local number = tonumber(string.sub(numStr, strStart, strEnd))
			if number then
				Mod.Insert(out, number)
			end
			strEnd = strEnd + 1
			strStart = strEnd
		else
			strEnd = strEnd + 1
		end
	end
	return out
end

local DEFAULT_WISP_TABLE = {2, 2, 3, 0, 1, 1, 30, 0, true, 1, {-1}, {-1}}

---@param id CollectibleType
---@param descData {[string]: string[]}
---@param lang string
function ARC_EID:TryAddSynergyDescriptions(id, descData, lang)
	local wispData = XMLData.GetEntryById(XMLNode.WISP, id)
	if wispData then
		local hp = tonumber(wispData.hp)
		local layer = tonumber(wispData.layer)
		local damage = tonumber(wispData.damage)
		local stageDamage = 0
		local damageMultiplier2 = tonumber(wispData.damageMultiplier2) or 1
		local shotSpeed = tonumber(wispData.shotspeed) or 1
		local fireDelay = tonumber(wispData.firedelay) or 30
		local procChance = tonumber(wispData.procchance) or 0
		local canShoot = wispData.canshoot ~= "false" and fireDelay ~= -1
		local amount = tonumber(wispData.count) or 1
		local tearFlags = {-1}
		local tearFlags2 = {-1}
		if wispData.tearflags then
			tearFlags = translateNumberString(wispData.tearflags)
		end
		if wispData.tearflags2 then
			tearFlags2 = translateNumberString(wispData.tearflags2)
		end
		EID.XMLWisps[id] = {hp, layer, damage, stageDamage, damageMultiplier2, shotSpeed, fireDelay, procChance, canShoot, amount, tearFlags, tearFlags2}
	elseif Mod.ItemConfig:GetCollectible(id).Type == ItemType.ITEM_ACTIVE then
		EID.XMLWisps[id] = DEFAULT_WISP_TABLE
	end
	for name, desc in pairs(descData) do
		--print(id, name)
		local description = ARC_EID.DynamicDescriptions:MakeMinimizedDescription(desc)[1]
		---@cast description string
		if name == "TarotCloth" then
			EID:addTarotClothBuffsCondition(id, description, nil, nil, lang)
		elseif name == "CarBattery" then
			EID:addCarBatteryCondition(id, description, nil, nil, lang)
		elseif name == "Abyss" then
			EID:addAbyssSynergiesCondition(id, description, nil, nil, lang)
		elseif name == "BookOfBelial" then
			EID:addBookOfBelialBuffsCondition(id, description, nil, nil, lang)
		elseif name == "BingeEater" then
			EID:addBingeEaterBuffsCondition(id, description, nil, nil, lang)
		elseif name == "BFFS" then
			EID:addBFFSCondition(id, description, nil, nil, lang)
		elseif name == "HiveMind" then
			EID:addHiveMindCondition(id, description, nil, nil, lang)
		elseif name == "BookOfVirtues" then
			EID_addBookOfVirtuesCondition(id, description, nil, nil, lang)
		end
	end
end


--#endregion

--#region Changing mod's name and indicator for EID

EID._currentMod = "Arachna Mod"
EID:setModIndicatorName("Arachna Mod")
local modIcon = Sprite("gfx/ui/eid_arc_mod_icon.anm2", true)
EID:addIcon("Arachna ModIcon", "Main", 0, 8, 8, 6, 6, modIcon)
EID:setModIndicatorIcon("Arachna ModIcon")

--#endregion

--#region Dynamic Descriptions functions

local DynamicDescriptions = {
	[EntityType.ENTITY_PICKUP] = {
		[PickupVariant.PICKUP_COLLECTIBLE] = {},
		[PickupVariant.PICKUP_TAROTCARD] = {},
	}
}

local DD = {} ---@class DynamicDescriptions

function DD:ContainsFunction(tbl)
	for _, v in pairs(tbl) do
		if type(v) == "function" then
			return true
		end
	end
	return false
end

---@param descTab table
---@return {Func: fun(descObj: table): (string), AppendToEnd: boolean, HasFallback: boolean}
function DD:CreateCallback(descTab, appendToEnd, hasFallback)
	return {
		Func = function(descObj)
			return table.concat(
				Mod:Map(
					descTab,
					function(val)
						if type(val) == "function" then
							local ret = val(descObj)
							if type(ret) == "table" then
								return table.concat(ret, "")
							elseif type(ret) == "string" then
								return ret
							else
								return ""
							end
						end

						return val or ""
					end
				),
				""
			)
		end,
		AppendToEnd = appendToEnd or false,
		HasFallback = hasFallback or false
	}
end

---@param modFunc { Func: function } | fun(descObj: table): string
---@param type integer
---@param variant integer
---@param subtype integer
---@param language string
function DD:SetCallback(modFunc, type, variant, subtype, language)
	if not DynamicDescriptions[type] then
		DynamicDescriptions[type] = {}
	end

	if not DynamicDescriptions[type][variant] then
		DynamicDescriptions[type][variant] = {}
	end

	if not DynamicDescriptions[type][variant][subtype] then
		DynamicDescriptions[type][variant][subtype] = {}
	end

	if not DynamicDescriptions[type][variant][subtype][language] then
		DynamicDescriptions[type][variant][subtype][language] = modFunc
	else
		error("Description modifier already exists for " .. type .. " " .. variant .. " " .. subtype .. " " .. language,
			2)
	end
end

---@param type integer
---@param variant integer
---@param subtype integer
---@param language string
---@return {Func: fun(descObj: table): (string?), AppendToEnd: boolean, HasFallback: boolean}?
function DD:GetCallback(type, variant, subtype, language)
	if not DynamicDescriptions[type] then
		return nil
	end

	if not DynamicDescriptions[type][variant] then
		return nil
	end

	if not DynamicDescriptions[type][variant][subtype] then
		return nil
	end

	if not DynamicDescriptions[type][variant][subtype][language] then
		return DynamicDescriptions[type][variant][subtype]
			["en_us"] -- fallback to english if no translation is available
	end

	return DynamicDescriptions[type][variant][subtype][language]
end

-- concat all subsequent string elements of a dynamic description
-- into one string so we have to concat less stuff at runtime
--
-- this is very much a micro optimization but at worst it does nothing
---@param desc (string | function)[] | function
---@return (string | function)[]
function DD:MakeMinimizedDescription(desc)
	if type(desc) == "function" then
		return { desc }
	end

	local out = {}
	local builder = {}

	for _, strOrFunc in ipairs(desc) do
		if type(strOrFunc) == "string" then
			builder[#builder + 1] = strOrFunc
		elseif type(strOrFunc) == "function" then
			out[#out + 1] = table.concat(builder, "")
			builder = {}
			out[#out + 1] = strOrFunc
		end
	end

	out[#out + 1] = table.concat(builder, "")

	return out
end

---@param desc (string | function)[] | function
---@return boolean
function DD:IsValidDescription(desc)
	if type(desc) == "function" then
		return true
	elseif type(desc) == "table" then
		for _, val in ipairs(desc) do
			if type(val) ~= "string" and type(val) ~= "function" then
				return false
			end
		end
	end

	return true
end

ARC_EID.DynamicDescriptions = DD

--#endregion

local eidCategory = {
	"items",
	"trinkets",
	"cards",
	"entities",
	"characters",
	"birthrights",
	"extras"
}

for _, category in ipairs(eidCategory) do
	Mod.Include("scripts.compatibility.patches.eid.eid_" .. category .. "_descriptions")
end

EID:addDescriptionModifier(
	"Arachna Dynamic Description Manager",
	-- condition
	---@param descObj EID_DescObj
	function(descObj)
		local subtype = descObj.ObjSubType
		if descObj.ObjVariant == PickupVariant.PICKUP_TRINKET then
			subtype = Mod:RemoveBitFlags(subtype, TrinketType.TRINKET_GOLDEN_FLAG)
		elseif descObj.ObjVariant == PickupVariant.PICKUP_PILL then
			subtype = Mod.Game:GetItemPool():GetPillEffect(subtype, ARC_EID:ClosestPlayerTo(descObj.Entity))
		end

		return DD:GetCallback(descObj.ObjType, descObj.ObjVariant, subtype, EID.getLanguage() or "en_us") ~= nil
	end,
	-- modifier
	function(descObj)
		local subtype = descObj.ObjSubType
		if descObj.ObjVariant == PickupVariant.PICKUP_TRINKET then
			subtype = Mod:RemoveBitFlags(subtype, TrinketType.TRINKET_GOLDEN_FLAG)
		elseif descObj.ObjVariant == PickupVariant.PICKUP_PILL then
			subtype = Mod.Game:GetItemPool():GetPillEffect(subtype, ARC_EID:ClosestPlayerTo(descObj.Entity))
		end

		local callback = DD:GetCallback(descObj.ObjType, descObj.ObjVariant, subtype, EID.getLanguage() or "en_us")
		local descString = callback.Func(descObj) ---@diagnostic disable-line: need-check-nil

		if callback.AppendToEnd then ---@diagnostic disable-line: need-check-nil
			descObj.Description = descObj.Description .. descString
		elseif callback.HasFallback then ---@diagnostic disable-line: need-check-nil
			descObj.Description = descString
		else
			descObj.Description = descString .. descObj.Description
		end
		return descObj
	end
)

EID._currentMod = "Arachna Mod_reserved" -- to prevent other mods overriding Arachna mod items
