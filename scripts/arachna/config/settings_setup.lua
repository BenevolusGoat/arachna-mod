--luacheck: no max line length
local Mod = ARACHNAMOD
local SettingsHelper = ARACHNAMOD.SettingsHelper

local frameOptions = {}
for i = 5, 20 do
	Mod.Insert(frameOptions, tostring(i))
end

SettingsHelper.AddChoiceSetting(Mod.Setting.DadsNewspaperDoubletap, "Adjust the double tap window for Dad's Newspaper", frameOptions, 8) --Index 8 is 12 frames

SettingsHelper.AddBooleanSetting(Mod.Setting.GeptameronGiantbook, "Have the giantbook for Geptameron appear on use?", true)

SettingsHelper.AddChoiceSetting(Mod.Setting.AnniversaryOverride, "Override the check for spawning Spider Cake?", {
	"Spawn on anniversary",
	"Always disabled",
	"Always enabled"
}, 1)

SettingsHelper.AddBooleanSetting(Mod.Setting.LegacyGameplay, "Change Arachna and Tainted Arachna gameplay to before the v2.0 update? (Requires run restart)", false)