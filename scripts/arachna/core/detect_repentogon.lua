-- Detects if REPENTOGON+ isn't enabled to show a one-time warning
local Mod = ARACHNAMOD

local showedWarning = false
local killWarning = false
local killWarningTimer = 60 * 30 --60fps * 30 = 30 seconds

local title = "IMPORTANT!"
local message = {
	"Arachna is now a REPENTOGON-dependent mod.",
	"Please download the latest stable version of",
	"REPENTOGON from https://repentogon.com/.",
	"",
	"The original non-REPENTOGON version",
	"is available as a separate workshop upload!"
}

local arachna = Isaac.GetPlayerTypeByName("Arachna", false)
local arachnab = Isaac.GetPlayerTypeByName("Arachna", true)

local function startedAsArachna()
	local player = Isaac.GetPlayer()
	local playerType = player:GetPlayerType()
	return playerType == arachna or playerType == arachnab
end

local function detectNicalisSkillIssue()
	if Mod.FLAGS.Debug or (REPENTOGON and REPENTANCE_PLUS) or not startedAsArachna() or killWarning then return end
	showedWarning = true
	local centerX, centerY = Isaac.GetScreenWidth() / 2, Isaac.GetScreenHeight() / 2
	local titlePos = Vector(centerX - 30, centerY - 80)
	local messagePos = Vector(centerX - 120, titlePos.Y + 10)

	if killWarningTimer > 0 then
		killWarningTimer = killWarningTimer - 1
	else
		killWarning = true
	end

	Isaac.RenderText(title, titlePos.X, titlePos.Y, 1, 0.2, 0.2, 1)
	for i, str in ipairs(message) do
		Isaac.RenderText(str, messagePos.X, messagePos.Y + 15 * i, 1, 1, 1, 1)
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_RENDER, detectNicalisSkillIssue)

local function stopWarning()
	if showedWarning and not killWarning and Game():GetFrameCount() > 0 then
		killWarning = true
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, stopWarning)
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, stopWarning)
