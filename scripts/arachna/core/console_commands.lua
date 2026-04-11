local Mod = ARACHNAMOD

--#region Achievement commands

local nameToMark = {
	MomsHeart = CompletionType.MOMS_HEART,
	Isaac = CompletionType.ISAAC,
	Satan = CompletionType.SATAN,
	BossRush = CompletionType.BOSS_RUSH,
	BlueBaby = CompletionType.BLUE_BABY,
	Lamb = CompletionType.LAMB,
	MegaSatan = CompletionType.MEGA_SATAN,
	UltraGreed = CompletionType.ULTRA_GREED,
	Hush = CompletionType.HUSH,
	Delirium = CompletionType.DELIRIUM,
	Mother = CompletionType.MOTHER,
	Beast = CompletionType.BEAST,
}

local function manageAchievements(shouldUnlock)
	local startAch = Mod.Pickup.WEB_HEART.ACHIEVEMENT
	local endAch = Mod.Item.BEST_BUD_BALL.ACHIEVEMENT
	local persistGameData = Isaac.GetPersistentGameData()

	for i = startAch, endAch do
		if shouldUnlock then
			persistGameData:TryUnlock(i, true)
		else
			Isaac.ExecuteCommand("lockachievement " .. i)
		end
	end
end

---@param playerType PlayerType
---@param args string
local function setMarkCommand(playerType, args)
	local strStartAll, strEndAll = string.find(args, "All")
	if strStartAll and strEndAll then
		local value = tonumber(string.sub(args, strEndAll + 2))
		if value and value >= 0 and value <= 2 then
			local marks = Isaac.GetCompletionMarks(playerType)
			for name, _ in pairs(marks) do
				if name ~= "PlayerType" then
					if name == "UltraGreedier" and value == 1 then
						marks[name] = 0
					else
						marks[name] = value
					end
				end
			end
			Isaac.SetCompletionMarks(marks)
		end
		return true
	end
	for name, completionType in pairs(nameToMark) do
		local strStart, strEnd = string.find(args, name)
		if strStart and strEnd then
			local value = tonumber(string.sub(args, strEnd + 2))
			if value and value >= 0 and value <= 2 then
				Isaac.SetCompletionMark(playerType, completionType, value)
				return true
			end
		end
	end
	return false
end

--#endregion

--#region Misc commands

local function setEggTimeout(args)
	local timeout = tonumber(args)
	if timeout then
		Mod.Entities.SPIDER_EGG.EGG_TIMEOUT = Mod.math.floor(timeout * 30)
		return true
	else
		return false
	end
end

--#endregion

--#region Command setup

local rootCommand = "arachnaMod"

---@type {[1]: string, [2]: string}[]
local commands = {
	{ "unlocktainted",  "Unlocks Tainted Arachna" },
	{ "unlockall",      "Unlocks all mod achievements" },
	{ "lockall",        "Locks all mod achievements" },
	{ "setmark",        "Args: <string completiontype> <int value>. Updates a completion mark for Arachna" },
	{ "setmarktainted", "Args: <string completiontype> <int value>. Updates a completion mark for Tainted Arachna" },
	{ "seteggtimeout",  "Args: <float timeout>. Sets how long spider eggs last before bursting without any spiders" },
	{ "stopegghatch",   "Stop spider eggs from auto-hatching" },
}

local helpText = {
	["setmark"] =
		"<completiontype>: [All|MomsHeart|Isaac|Satan|BossRush|BlueBaby|Lamb|MegaSatan|UltraGreed|Hush|Delirium|Mother|Beast]\n"
		.. "<value>: [0: Locked|1: Normal|2: Hard]\n"
		.. "Examples:\n"
		.. "(arachnaMod setmark MomsHeart 0) will set the Mom's Heart/It Lives completion mark to Locked.\n"
		.. "(arachnaMod setmark Beast 1) will set the Beast completion mark to Normal Mode.\n"
		.. "(arachnaMod setmark UltraGreed 2) will set the Greed Mode completion mark to Hard/Greedier Mode."
	,
	["setmarktainted"] = "Arguments are identical to setmark's arguments.",
	["seteggtimeout"] =
		"<timeout>: The number in seconds the timeout should be set to.\n"
		.. "Examples:\n"
		.. "(arachnaMod seteggtimeout 5) will have eggs explode after 5 seconds.\n"
		.. "(arachnaMod seteggtimeout 7.5) will have eggs explode after 7.5 seconds.\n"
		.. "(arachnaMod seteggtimeout 0) will stop the timer mechanic.\n"
	,
}

---@type {[string]: fun(args: string): string|boolean}
local commandFuncs = {
	["unlocktainted"] = function()
		Isaac.GetPersistentGameData():TryUnlock(Mod.Character.ARACHNA_B.ACHIEVEMENT)
		return "Unlocked Tainted Arachna"
	end,
	["unlockall"] = function()
		manageAchievements(true)
		return "All Arachna achievements unlocked"
	end,
	["lockall"] = function()
		manageAchievements(false)
		return "All Arachna achievements locked"
	end,
	["setmark"] = function(args)
		return setMarkCommand(Mod.PlayerType.ARACHNA, args)
	end,
	["setmarktainted"] = function(args)
		return setMarkCommand(Mod.PlayerType.ARACHNA_B, args)
	end,
	["seteggtimeout"] = setEggTimeout,
	["stopegghatch"] = function()
		Mod.Entities.SPIDER_EGG.NoAutoHatch = not Mod.Entities.SPIDER_EGG.NoAutoHatch
		return "AutoHatch set to " .. tostring(not Mod.Entities.SPIDER_EGG.NoAutoHatch)
	end,
}

local description = "The following commands can be accessed by typing \"arachnaMod <command name>\""
for _, commandTable in ipairs(commands) do
	description = description .. "\n  - " .. commandTable[1] .. " - " .. commandTable[2]
	if helpText[commandTable[1]] then
		description = description .. ".\n" .. helpText[commandTable[1]]
	end
end

Console.RegisterCommand(
	rootCommand,
	"Debug commands for the Arachna MOD",
	description,
	true,
	AutocompleteType.CUSTOM
)

Mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, function(_, cmd, params)
	if cmd ~= rootCommand then
		return
	end
	for _, commandTable in ipairs(commands) do
		local strStart, strEnd = string.find(params, commandTable[1])
		if strStart and strEnd then
			local args = string.len(commandTable[1]) < string.len(params) and
				string.gsub(params, commandTable[1] .. " ", "") or ""
			local returnPrint = commandFuncs[commandTable[1]](args)
			if type(returnPrint) == "string" then
				Mod:Log(returnPrint)
				return
			elseif returnPrint == true then
				Mod:Log("Ran command successfully!")
				return
			else
				Mod:Log("Failed to run command!")
			end
		end
	end
end)

Mod:AddCallback(ModCallbacks.MC_CONSOLE_AUTOCOMPLETE, function(command, params)
	return commands
end, rootCommand)

--#endregion

--#region Wipe save

function ARACHNAMOD:WipeSave()
	Isaac.ClearCompletionMarks(Mod.PlayerType.ARACHNA)
	Isaac.ClearCompletionMarks(Mod.PlayerType.ARACHNA_B)
	manageAchievements(false)
end

Mod:AddCallback(Mod.SaveManager.SaveCallbacks.POST_DATA_DELETE, ARACHNAMOD.WipeSave)

--#endregion
