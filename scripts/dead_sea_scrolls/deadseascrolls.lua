local Mod = ArachnaMod
local DSSModName = "Dead Sea Scrolls (Arachna)"
local DSSCoreVersion = 7

local BREAK_LINE = { str = "", fsize = 1, nosel = true }

-- auto split tooltips into multiple lines optimally
---@param str string
---@param title? string
---@param len? integer
local function GenerateTooltip(str, title, len)
	local endTable = {}
	local currentString = ""
	for w in str:gmatch("%S+") do
		local newString = currentString .. w .. " "
		if newString:len() >= (len or 15) then
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

---Returns a buttons table that converts any strings into strset tables that fit within the primary paper view
---@param ... string|table
local function GenerateDescription(...)
	local strList = table.pack(...)
	local tableList = {}
	for _, strOrTable in ipairs(strList) do
		local desc
		if type(strOrTable) == "string" then
			desc = GenerateTooltip(strOrTable, nil, 35)
			desc.fsize = 1
		else
			desc = strOrTable
		end
		tableList[#tableList+1] = desc
	end
	return {table.unpack(tableList)}
end

---Returns a buttons table that converts any strings into strset tables that fit within the primary paper view. Strings will not be able to be selected
---@param ... string|table
local function GenerateNoSelDescription(...)
	local strList = table.pack(...)
	local tableList = {}
	for _, strOrTable in ipairs(strList) do
		local desc
		if type(strOrTable) == "string" then
			desc = GenerateTooltip(strOrTable, nil, 35)
			desc.fsize = 1
			desc.nosel = true
		else
			desc = strOrTable
		end
		tableList[#tableList+1] = desc
	end
	return {table.unpack(tableList)}
end

local DSSInitializerFunction = require("scripts.dead_sea_scrolls.vendor.dssmenucore")
local dssmod = DSSInitializerFunction(DSSModName, DSSCoreVersion, Mod.SaveManager.MenuProvider)
local areYouSureText = ""
local areYouSureAction = function() end

local arachnaDssDirectory = {
	DSSMOD = dssmod,
	main = {
		title = 'arachna',

		buttons = {
			{str = 'resume game', action = 'resume'},
			{str = 'unlocks', dest = 'unlocks', tooltip = GenerateTooltip("view and manage unlocks")},
			dssmod.changelogsButton,
			{str = 'settings', dest = 'arachnaSettings', tooltip = GenerateTooltip("edit various settings"), displayif = function()
				return DeadSeaScrollsMenu.CanOpenGlobalMenu()
			end},
			{str = 'settings', dest = 'settings', tooltip = GenerateTooltip("edit various settings"), displayif = function()
				return not DeadSeaScrollsMenu.CanOpenGlobalMenu()
			end,},
			{str = 'credits', dest = 'credits', tooltip = GenerateTooltip("view the credits")},
		},

		tooltip = dssmod.menuOpenToolTip
	},
	unlocks = {
		title = 'unlocks',
		buttons = {
			{str = 'achievements', dest = 'achievementviewer', tooltip = GenerateTooltip("view your achievements. also available in the main menu!")},
			{str = 'unlock manager', dest = 'unlockmanager', tooltip = GenerateTooltip("manage your unlocks")}
		}
	},
	unlockmanager = {
		title = 'unlock manager',
		buttons = {
			{
				str = 'unlock tainted',
				dest = 'areyousure',
				tooltip = GenerateTooltip("unlock tainted arachna"),
				func = function()
					areYouSureText = "this will immediately unlock tainted arachna. are you sure you want to do that?"
					areYouSureAction = function()
						Isaac.ExecuteCommand("arachnaMod unlocktainted")
					end
				end
			},
			{
				str = 'wipe save',
				dest = 'areyousure',
				tooltip = GenerateTooltip("clear completion marks and achievements"),
				func = function()
					areYouSureText = "this will remove all arachna marks and achievements. are you sure you want to do that?"
					areYouSureAction = Mod.WipeSave
				end
			},
		}
	},
	settings = {
		title = "settings",
		buttons = {
			{str = "menu settings", dest = "menuSettings", tooltip = GenerateTooltip("edit menu settings")},
			{str = "arachna settings", dest = "arachnaSettings", tooltip = GenerateTooltip("edit arachna settings")},
		},
	},
	menuSettings = {
		title = "menu settings",
		buttons = {
			dssmod.gamepadToggleButton,
			dssmod.menuKeybindButton,
			dssmod.paletteButton,
			dssmod.menuHintButton,
			dssmod.menuBuzzerButton,
		},
	},
	arachnaSettings = {
		title = "settings",
		buttons = {},
		generate = function(menu)
			menu.buttons = {}

			for _, info in ipairs(ArachnaMod.SettingsHelper.GetAllSettings()) do
				local button = {}
				button.strset = GenerateTooltip(info.Name:lower()).strset
				button.tooltip = GenerateTooltip(info.Description:lower())

				button.variable = info.Name

				if info.Type == ArachnaMod.SettingTypes.Boolean then
					button.load = function()
						return ArachnaMod.GetSetting(info.Name) == true and 1 or 2
					end

					button.choices = { "on", "off" }
					button.setting = button.load()

					button.changefunc = function()
						ArachnaMod.SaveSetting(info.Name, button.setting == 1)
					end

					button.store = function()
						ArachnaMod.SaveSetting(info.Name, button.setting == 1)
					end
				elseif info.Type == ArachnaMod.SettingTypes.Choice then
					button.load = function()
						return ArachnaMod.GetSetting(info.Name)
					end

					button.choices = info.Choices
					button.setting = button.load()

					for i, choice in ipairs(info.Choices) do
						info.Choices[i] = choice:lower()
					end
					button.changefunc = function()
						ArachnaMod.SaveSetting(info.Name, button.setting)
					end

					button.store = function()
						ArachnaMod.SaveSetting(info.Name, button.setting)
					end
				elseif info.Type == ArachnaMod.SettingTypes.Keybind then
					button.load = function()
						return ArachnaMod.GetSetting(info.Name)
					end

					button.setting = button.load()
					button.keybind = true

					button.changefunc = function()
						ArachnaMod.SaveSetting(info.Name, button.setting)
					end

					button.store = function()
						ArachnaMod.SaveSetting(info.Name, button.setting)
					end
				end

				table.insert(menu.buttons, button)
				table.insert(menu.buttons, BREAK_LINE)

				if info.Name == Mod.Setting.LegacyGameplay then
					table.insert(menu.buttons, {str= "legacy info", dest= "legacyinfo", fsize = 1, tooltip = GenerateTooltip("more information on legacy gameplay")})
					table.insert(menu.buttons, BREAK_LINE)
				end
			end
		end,
	},
	credits = {
		title = "arachna credits",
		buttons = {
			{str = "developers", fsize = 3, tooltip = GenerateTooltip("directly involved with development on the mod")},
			{str = "rvsty", fsize = 2, tooltip = GenerateTooltip("v1.0 coder, majority of sprites, designer")},
			{str = "benevolusgoat", fsize = 2, tooltip = GenerateTooltip("v2.0 coder")},
			BREAK_LINE,
			BREAK_LINE,
			{str = "translators", fsize = 3, tooltip = GenerateTooltip("translations created for external item descriptions")},
			{str = "rvsty", fsize = 2, tooltip = GenerateTooltip("v1.0 russian translations")},
			{str = "oucalgarlin", fsize = 2, tooltip = GenerateTooltip("v2.0 chinese translations")},
			{str = "Saurtya", fsize = 2, tooltip = GenerateTooltip("v1.0 chinese translations")},
			{str = "wons", fsize = 2, tooltip = GenerateTooltip("v1.0 polish translations")},
			{str = "jaro7126", fsize = 2, tooltip = GenerateTooltip("v2.0 russian translations")},
			{str = "Nebuka", fsize = 2, tooltip = GenerateTooltip("korean translations")},
			BREAK_LINE,
			BREAK_LINE,
			{str = "contributors", fsize = 3, tooltip = GenerateTooltip("contributed some amount to the mod")},
			{str = "unknownthehero", fsize = 2, tooltip = GenerateTooltip("major playtesting")},
			{str = "quartz", fsize = 2, tooltip = GenerateTooltip("amazing portrait sprites")},
			{str = "brakedude", fsize = 2, tooltip = GenerateTooltip("coded in proper web heart rendering for v1.0")},
			{str = "shapatsmith", fsize = 2, tooltip = GenerateTooltip("voiceover for pocket items")},
			{str = "wons", fsize = 2, tooltip = GenerateTooltip("playtesting, sprites for several costumes")},
			{str = "steamjek", fsize = 2, tooltip = GenerateTooltip("commissioned for v1.0 mod thumbnail art")},
			{str = "picsel", fsize = 2, tooltip = GenerateTooltip("commissioned for v2.0 mod thumbnail art")},
			{str = "damagaz", fsize = 2, tooltip = GenerateTooltip("v2.0 achievement papers")},
			{str = "ferpe", fsize = 2, tooltip = GenerateTooltip("commissioned for various sprites")},
			{str = "zvetaji6", fsize = 2, tooltip = GenerateTooltip("arachna and t. arachna 3d models")},
			{str = "connor (+ his wife)", fsize = 2, tooltip = GenerateTooltip("assistance with specialist dance compat")},
			{str = "cadetpirx", fsize = 2, tooltip = GenerateTooltip("reverse merged card idea suggestion")},
			{str = "benny's barn playtesters", fsize = 2, tooltip = GenerateTooltip("playtested during v2.0 development")},
		},
	},
	areyousure = {
		title = "are you sure?",
		tooltip = { strset = {""} },
		buttons = {
			BREAK_LINE,
			BREAK_LINE,
			{
				str = "no",
				action = "back",
				glowcolor = 2,
				generate = function(button)
					button.tooltip = GenerateTooltip(areYouSureText)
				end,
			},
			BREAK_LINE,
			{
				str = "yes",
				action = "back",
				generate = function(button)
					button.tooltip = GenerateTooltip(areYouSureText)
					button.func = areYouSureAction
				end,
			},
		},
	},
	arachnapopup = {
		title = "arachna",
		tooltip = GenerateTooltip("this update was brought to you by benny!"),
		fsize = 1,
		buttons = {
			{str = "welcome to arachna 2.0!", fsize = 2, nosel = true},
			{str = "the mod's code has been rewritten", nosel = true},
			{str = "and many changes have been made.", nosel = true},
			{str = "main features include:", nosel = true},
			BREAK_LINE,
			{str = "- character gameplay rework", nosel = true},
			{str = "- deadseascrolls menu", nosel = true},
			{str = "- 5 new items and 1 new card", nosel = true},
			{str = "- quality of life improvements", nosel = true},
			{str = "- unquantifiable amount of bug fixes", nosel = true},
			BREAK_LINE,
			{str = "see dss changelog for full list!", nosel = true},
			{
				str = "ok",
				action = "resume",
				fsize = 3,
				glowcolor = 3
			}
		},
	},
	rgonpopup = {
		title = "arachna",
		fsize = 1,
		buttons = GenerateNoSelDescription(
            {str = "repentogon+ required", nosel = true, fsize = 2},
            BREAK_LINE,
			"the arachna mod has updated to v2.0 and now requires repentogon on repentance+ to function!",
			BREAK_LINE,
			"ensure you have the official repentance+ dlc installed and enabled and the latest version of repentogon from repentogon.com",
			BREAK_LINE,
			"if you wish to downgrade, please check the workshop description for more information",
			BREAK_LINE,
			{
				str = "i understand",
				action = "resume",
				fsize = 3,
				glowcolor = 3,
			}
		),
	},
	legacyinfo = {
		title = "legacy gameplay",
		tooltip = GenerateTooltip("changes that are enabled with legacy gameplay"),
		buttons = GenerateDescription(
			{str = "info", fsize = 2},
			"legacy gameplay returns arachna, tainted arachna, and some features of their pocket actives to before the v2.0 update. this setting exists for those who prefer the older gameplay, as many changes have been made for a more balanced gameplay experience. eid support and tutorial sprites will not be updated to reflect legacy gameplay. the list of the exact changes can be found below:",
			BREAK_LINE,
			{str = "arachna", fsize = 2},
			"- 50% chance for spiders to be a random color, up from 35%",
			"- arachna's birthright has +1 to spawned spiders instead of increased chance for spider eggs spawning colored spiders",
			"- can get slowed by cobwebs on the ground",
			BREAK_LINE,
			{str = "tainted arachna", fsize = 2},
			"- +1 guaranteed spider spawn from spider eggs",
			"- 33% chance for random colored spiders from spider eggs",
			"- can obtain random colored spiders from spider eggs",
			"- spider eggs break after 16 seconds, yeilding no rewards",
			"- removes the divine cloth double-tap action and sets it as her pocket active",
			"- 1.00 damage",
			"- 0.75 speed",
			"- can get slowed by cobwebs on the ground",
			BREAK_LINE,
			{str = "arachna's spool", fsize = 2},
			{str = "and divine cloth", fsize = 2, nosel = true},
			"- adjusts weights for what colored spiders are chosen",
			"- decreases arachna's spool tear's collission radius by half",
			"- arachna's spool's web no longer reduces knockback to enemies",
			"- arachna's spool's web affects enemies that are above pits",
			"- if arachna's spool's tear kills an enemy, it will not count as them being webbed to spawn a spider egg",
			"- decreases recharge time of both items to 3 seconds",
			"- how many spiders spawn from spider eggs are influenced by the current stage and number of web hearts",
			"- bosses, enemies with a max hp below 10, or enemies spawned by other enemies no longer drop spider eggs or spiders",
			"- bosses are immune to the webbed and ensnared status effects",
			"- decreases divine cloth's radius by -25%",
			"- spider eggs no longer explode on challenge/boss rush wave clears",
			"- divine cloth's swirl that ensnares enemies no longer follows the player",
			"- spider eggs are regular sized",
			"- spider eggs cannot be special colors",
			"- rainbow spiders take off more of a boss' health"
		)
	}
}

ArachnaMod.DSS_DIRECTORY = arachnaDssDirectory
ArachnaMod.DSS_MOD = dssmod

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

include("scripts.dead_sea_scrolls.changelogs")