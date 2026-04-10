local Mod = ARACHNAMOD

local FLOOR_TEXT = {}

ARACHNAMOD.Misc.FLOOR_TEXT = FLOOR_TEXT

FLOOR_TEXT.ID = Isaac.GetEntityVariantByName("Floor Letter (Arachna)")
FLOOR_TEXT.FORCE_FACT = -1
FLOOR_TEXT.FORCE_NUMERICAL = false

--hi, rusty here. in case any TSC devs are reading this: for arachna I reverted minisplash code back to morrigan's showcase version (29th Aug, 2022)
--then it was a little altered. i don't know who was the one enhancing minisplash code, but I'm having hard time reading it now.
--additionally, FOR WHATEVER REASON it was split into like three separate files, making it a pain in the ass to edit. like, WHY ????
--plus some of it's functionality wasn't even needed here (like different player characters support for example) so yeah, older version it is

-- SPLASH TEXTS
local protipSplashes = Mod.Include("scripts.arachna.misc.spider_facts")

-- LETTER FUNCTIONS
local floorTextLetter = {
	name = {},
	framenum = {},
	width = {},
	miniwidth = {}
}

---@param _name string
local function getLetterIdByName(_name)
	for i = 1, #floorTextLetter.name do
		if floorTextLetter.name[i] == _name then
			return i
		end
	end
	return nil
end

local function addLetter(_letter, _framenum, _width, _miniwidth)
	local id = #floorTextLetter.name + 1
	floorTextLetter.name[id] = _letter
	floorTextLetter.framenum[id] = _framenum
	floorTextLetter.width[id] = _width
	floorTextLetter.miniwidth[id] = _miniwidth
end

---@param rng RNG
---@param isFloor? boolean
local function getRandomSplashText(rng, isFloor)
	local spiderTable = isFloor and protipSplashes.Floor or protipSplashes.Fortune
	if FLOOR_TEXT.FORCE_NUMERICAL then
		if FLOOR_TEXT.FORCE_FACT == -1 then
			FLOOR_TEXT.FORCE_FACT = 0
		end
		FLOOR_TEXT.FORCE_FACT = FLOOR_TEXT.FORCE_FACT + 1
	end
	local textid = rng:RandomInt(#spiderTable) + 1
	if FLOOR_TEXT.FORCE_FACT ~= -1 then
		textid = FLOOR_TEXT.FORCE_FACT
	end
	Mod:DebugLog("Returned spider fact #", textid)
	return spiderTable[textid], textid
end

local function str_split(str) --stolen off internet
	local sep = '#'
	local res = {}
	local func = function(w)
		table.insert(res, w)
	end
	string.gsub(str, '[^' .. sep .. ']+', func)
	return res
end

---@param font Font
---@param str string
---@param boxWidth integer
local function str_split_font(font, str, boxWidth)
	local endTable = {}
	local currentString = ""
	for w in str:gmatch("%S+") do
		local newString = currentString .. w .. " "
		if font:GetStringWidth(newString) >= boxWidth and #endTable < 2 then
			endTable[#endTable+1] = currentString
			currentString = ""
		end

		currentString = currentString .. w .. " "
	end

	endTable[#endTable+1] = currentString
	return endTable
end

local function drawFloorLine(_line, _x, _y, _small)
	--set letter height
	local height = 0
	if _small then
		height = 8
	else
		height = 12
	end
	--split text
	local textLines = str_split(_line)
	--draw each line
	local textY = _y - math.floor((height * #textLines) / 2)
	for j = 1, #textLines do
		-- == DRAWING LINE == --
		--get length
		local textWidth = 0
		for i = 1, #textLines[j] do
			local curLetter = textLines[j]:sub(i, i)
			if _small then
				textWidth = textWidth + floorTextLetter.miniwidth[getLetterIdByName(curLetter)] + 4
			else
				textWidth = textWidth + floorTextLetter.width[getLetterIdByName(curLetter)] + 5
			end
		end
		--drawtext
		local textX = _x - math.floor(textWidth / 2)
		for i = 1, #textLines[j] do
			local curLetter = textLines[j]:sub(i, i)
			-- == DRAWING LETTER == --
			local floorText = Mod.Spawn.Effect(FLOOR_TEXT.ID, 0, Vector(textX, textY))
			local sprite = floorText:GetSprite()
			if Mod.Level():GetStageType() == StageType.STAGETYPE_AFTERBIRTH then -- if in Burning Basement
				sprite.Color = Color(0.7, 0.6, 0.6)                        --Yes the game actually does this
			end
			--render intro or letter
			if _small then
				sprite:SetFrame("Idle2", floorTextLetter.framenum[getLetterIdByName(curLetter)])
			else
				sprite:SetFrame("Idle", floorTextLetter.framenum[getLetterIdByName(curLetter)])
			end
			floorText.SortingLayer = SortingLayer.SORTING_BACKGROUND
			floorText:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
			---------------------------
			--increase x
			if _small then
				textX = textX + floorTextLetter.miniwidth[getLetterIdByName(curLetter)] + 4
			else
				textX = textX + floorTextLetter.width[getLetterIdByName(curLetter)] + 5
			end
		end
		---------------------------
		--increase y
		if _small then
			textY = textY + height + 3
		else
			textY = textY + height + 8
		end
	end
end

----------------------------------------------------------------------
--letters (height: big: 11, small: 7)
addLetter(" ", 0, 7, 5)
addLetter("A", 1, 7, 5)
addLetter("B", 2, 9, 5)
addLetter("C", 3, 7, 5)
addLetter("D", 4, 9, 5)
addLetter("E", 5, 7, 5)
addLetter("F", 6, 6, 5)
addLetter("G", 7, 8, 5)
addLetter("H", 8, 7, 5)
addLetter("I", 9, 6, 2)
addLetter("J", 10, 7, 6)
addLetter("K", 11, 8, 6)
addLetter("L", 12, 8, 5)
addLetter("M", 13, 9, 6)
addLetter("N", 14, 7, 6)
addLetter("O", 15, 8, 5)
addLetter("P", 16, 6, 5)
addLetter("Q", 17, 9, 6)
addLetter("R", 18, 7, 5)
addLetter("S", 19, 6, 5)
addLetter("T", 20, 9, 6)
addLetter("U", 21, 8, 5)
addLetter("V", 22, 6, 5)
addLetter("W", 23, 9, 8)
addLetter("X", 24, 9, 5)
addLetter("Y", 25, 7, 5)
addLetter("Z", 26, 7, 5)
addLetter("'", 27, 2, 2)
addLetter("!", 28, 5, 2)
addLetter(":", 29, 5, 2)
--specials
addLetter("'", 27, 2, 2)
addLetter("`", 27, 2, 2)
addLetter("!", 28, 2, 2)
addLetter(":", 29, 5, 2)
addLetter(",", 31, 5, 2)
addLetter(">", 33, 5, 2)
addLetter("<", 34, 5, 2)
addLetter("?", 35, 2, 2)
addLetter(".", 47, 3, 2)
addLetter("^", 48, 5, 2)
addLetter("~", 49, 5, 2)
--numbers
for i = 0, 9 do
	addLetter(tostring(i), 37 + i, 8, 5)
end
------

function FLOOR_TEXT:AddFloorTextOnNewRoom()
	local level = Mod.Level()
	--starting room
	if (level:GetCurrentRoomDesc().SafeGridIndex == Mod.Level():GetStartingRoomIndex())
		and (level:GetStage() == LevelStage.STAGE1_1)
		and (level:GetStageType() < StageType.STAGETYPE_REPENTANCE)
		and Mod:IsAnyArachna(Isaac.GetPlayer())
		and Mod.GetSetting(Mod.Setting.SpiderFacts)
	then
		local textRNG = RNG(Game():GetSeeds():GetStartSeed())
		local roomCenterPos = Mod.Room():GetCenterPos()
		local factLinePos1 = 344
		local factLinePos2 = 374
		if Mod.Game:IsGreedMode() then
			factLinePos1 = factLinePos1 + 165
			factLinePos2 = factLinePos2 + 165
		end
		drawFloorLine("FUN FACT:", roomCenterPos.X, factLinePos1, true)               --y used to be 364
		local splashText = getRandomSplashText(textRNG, true)
		drawFloorLine(splashText, roomCenterPos.X, factLinePos2) --y used to be 384
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, FLOOR_TEXT.AddFloorTextOnNewRoom)

local UPHEAVEL = Font("font/upheaval.fnt")

---@param rng RNG
function FLOOR_TEXT:ShowRandomFactOnHUD(rng)
	local text, index = getRandomSplashText(rng)
	local hud = Mod.Game:GetHUD()
	local res
	if protipSplashes.FortuneFix[index] then
		res = str_split(protipSplashes.FortuneFix[index])
	else
		res = str_split_font(UPHEAVEL, text, 270)
	end
	hud:ShowFortuneText(table.unpack(res))
end
