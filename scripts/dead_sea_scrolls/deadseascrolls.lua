local Mod = ARACHNAMOD
local DSSModName = "Dead Sea Scrolls (Arachna)"
local DSSCoreVersion = 7

-- auto split tooltips into multiple lines optimally
---@param str string
---@param title? string
local function GenerateTooltip(str, title)
	local endTable = {}
	local currentString = ""
	for w in str:gmatch("%S+") do
		local newString = currentString .. w .. " "
		if newString:len() >= 15 then
			table.insert(endTable, currentString)
			currentString = ""
		end

		currentString = currentString .. w .. " "
	end

	table.insert(endTable, currentString)
	if title then
		table.insert(endTable, 1, "")
		table.insert(endTable, 1, title)
	end
	return { strset = endTable }
end

local DSSInitializerFunction = require("scripts.dead_sea_scrolls.vendor.dssmenucore")
local dssmod = DSSInitializerFunction(DSSModName, DSSCoreVersion, Mod.SaveManager.MenuProvider)
local BREAK_LINE = { str = "", fsize = 1, nosel = true }

local arachnaDssDirectory = {
	DSSMOD = dssmod,
	main = {
		title = 'andromeda',

		buttons = {
			{str = 'resume game', action = 'resume'},
			{str = 'unlocks', dest = 'unlocks', GenerateTooltip("browse and inspect unlockables")},
			{str = 'settings', dest = 'settings', tooltip = GenerateTooltip("edit various settings")},
			{str = 'credits', dest = 'credits', tooltip = GenerateTooltip("view the credits")},
		},

		tooltip = dssmod.menuOpenToolTip
	},
	settings = {
		title = "settings",
		buttons = {},
		generate = function(menu)
			menu.buttons = {}

			for _, info in ipairs(ARACHNAMOD.SettingsHelper.GetAllSettings()) do
				local button = {}
				button.strset = GenerateTooltip(info.Name:lower()).strset
				button.tooltip = GenerateTooltip(info.Description:lower())

				button.variable = info.Name

				if info.Type == ARACHNAMOD.SettingTypes.Boolean then
					button.load = function()
						return ARACHNAMOD.GetSetting(info.Name) == true and 1 or 2
					end

					button.choices = { "on", "off" }
					button.setting = button.load()

					button.changefunc = function()
						ARACHNAMOD.SaveSetting(info.Name, button.setting == 1)
					end

					button.store = function()
						ARACHNAMOD.SaveSetting(info.Name, button.setting == 1)
					end
				elseif info.Type == ARACHNAMOD.SettingTypes.Choice then
					button.load = function()
						return ARACHNAMOD.GetSetting(info.Name)
					end

					button.choices = info.Choices
					button.setting = button.load()

					for i, choice in ipairs(info.Choices) do
						info.Choices[i] = choice:lower()
					end
					button.changefunc = function()
						ARACHNAMOD.SaveSetting(info.Name, button.setting)
					end

					button.store = function()
						ARACHNAMOD.SaveSetting(info.Name, button.setting)
					end
				elseif info.Type == ARACHNAMOD.SettingTypes.Keybind then
					button.load = function()
						return ARACHNAMOD.GetSetting(info.Name)
					end

					button.setting = button.load()
					button.keybind = true

					button.changefunc = function()
						ARACHNAMOD.SaveSetting(info.Name, button.setting)
					end

					button.store = function()
						ARACHNAMOD.SaveSetting(info.Name, button.setting)
					end
				end

				table.insert(menu.buttons, button)
				table.insert(menu.buttons, BREAK_LINE)
			end
		end,
	},
	unlocks = {
		title = "unlocks",
		buttons = {
			{ str = "achievements", dest = "achievementviewer", tooltip = GenerateTooltip("view your achievements.") },
		},
	},
	credits = {
		title = "arachna credits",
		buttons = {
			{str = "unknownthehero", fsize = 2, tooltip = GenerateTooltip("major playtesting")},
			{str = "quartz", fsize = 2, tooltip = GenerateTooltip("amazing portrait sprites")},
			{str = "brakedude", fsize = 2, tooltip = GenerateTooltip("coded in proper web heart rendering pre-rewrite")},
			{str = "shapatsmith", fsize = 2, tooltip = GenerateTooltip("voiceover for pocket items")},
			{str = "wons", fsize = 2, tooltip = GenerateTooltip("playtesting, sprites for several costumes")},
			{str = "steamjek", fsize = 2, tooltip = GenerateTooltip("mod thumbnail art as a commission")},
			{str = "benevolusgoat", fsize = 2, tooltip = GenerateTooltip("mod code rewrite for repentogon+")}
		},
	},
}

ARACHNAMOD.DSS_DIRECTORY = arachnaDssDirectory
ARACHNAMOD.DSS_MOD = dssmod

local DSSUnlockManager = include("scripts.dead_sea_scrolls.dss_unlock_manager")
local unlock_catalog = include("scripts.dead_sea_scrolls.arachna_unlock_catalog")
local achievement_viewer = include("scripts.dead_sea_scrolls.dss_achievement_viewer")
local catalog = unlock_catalog(DSSUnlockManager)
DSSUnlockManager:GenerateDSSMenu(catalog)
achievement_viewer(DSSUnlockManager, arachnaDssDirectory, catalog)

local exampledirectorykey = {
	Item = arachnaDssDirectory.main, -- This is the initial item of the menu, generally you want to set it to your main item
	Main = 'main', -- The main item of the menu is the item that gets opened first when opening your mod's menu.

	-- These are default state variables for the menu; they're important to have in here, but you don't need to change them at all.
	Idle = false,
	MaskAlpha = 1,
	Settings = {},
	SettingsChanged = false,
	Path = {},
}

DeadSeaScrollsMenu.AddMenu("Arachna", {
	DSSMOD = dssmod,

	-- The Run, Close, and Open functions define the core loop of your menu
	-- Once your menu is opened, all the work is shifted off to your mod running these functions, so each mod can have its own independently functioning menu.
	-- The DSSInitializerFunction returns a table with defaults defined for each function, as "runMenu", "openMenu", and "closeMenu"
	-- Using these defaults will get you the same menu you see in Bertran and most other mods that use DSS
	-- But, if you did want a completely custom menu, this would be the way to do it!

	-- This function runs every render frame while your menu is open, it handles everything! Drawing, inputs, etc.
	Run = dssmod.runMenu,
	-- This function runs when the menu is opened, and generally initializes the menu.
	Open = dssmod.openMenu,
	-- This function runs when the menu is closed, and generally handles storing of save data / general shut down.
	Close = dssmod.closeMenu,

	Directory = arachnaDssDirectory,
	DirectoryKey = exampledirectorykey
})