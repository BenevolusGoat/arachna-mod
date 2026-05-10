--luacheck: no max line length
local Mod = ArachnaMod
local SettingsHelper = ArachnaMod.SettingsHelper

local frameOptions = {}
for i = 5, 20 do
	Mod.Insert(frameOptions, tostring(i))
end

local opacityOptions = {}
for i = 1, 10 do
	Mod.Insert(opacityOptions, tostring(i * 10) .. "%")
end

SettingsHelper.AddChoiceSetting(Mod.Setting.DoubletapFrameWindow,
	"Adjust the double tap window for actions such as Dad's Newspaper", frameOptions, 8) --Index 8 is 12 frames

SettingsHelper.AddBooleanSetting(Mod.Setting.GeptameronGiantbook, "Have the giantbook for Geptameron appear on use?",
	true)

SettingsHelper.AddBooleanSetting(Mod.Setting.LegacyGameplay,
	"Change Arachna and Tainted Arachna gameplay to before the v2.0 update? (Requires run restart)", false)

SettingsHelper.AddBooleanSetting(Mod.Setting.SpiderFacts, "..?", false)

SettingsHelper.AddChoiceSetting(Mod.Setting.SpiderOpacity, "Opacity of all spider familiars for Arachna and Tainted Arachna", opacityOptions, 10)

SettingsHelper.AddChoiceSetting(Mod.Setting.EggTossIndicator, "Change the indicator for the closest spider egg in range with Egg Toss",
	{
		"Nothing",
		"Border"
	},
	1
)