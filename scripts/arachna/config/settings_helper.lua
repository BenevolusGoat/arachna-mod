local allSettings = {}
local SettingsHelper = {}
ARACHNAMOD.SettingsHelper = SettingsHelper

ARACHNAMOD.SettingTypes = {
	Choice = 0,
	Keybind = 1,
	Boolean = 2,
}

--- Saves the value for a setting. Verifies that the setting exists before saving it.
---@param settingKey string
---@param value any
---@function
function ARACHNAMOD.SaveSetting(settingKey, value)
	local game_save = ARACHNAMOD.SaveManager.GetSettingsSave()
	---@cast game_save table

	if not game_save.ArachnaSettings then
		game_save.ArachnaSettings = {}
	end

	if SettingsHelper.GetSettingInfo(settingKey) then
		game_save.ArachnaSettings[settingKey] = value
	end

	ARACHNAMOD.SaveManager.Save()
end

---Gets the value for a setting. Settings have default values, so unless the setting doesn't exist, this doesn't return nil.
---@return any?
---@function
function ARACHNAMOD.GetSetting(settingKey)
	local game_save = ARACHNAMOD.SaveManager.GetSettingsSave()
	---@cast game_save table

	if not game_save.ArachnaSettings then
		game_save.ArachnaSettings = {}
	end

	local setting = game_save.ArachnaSettings[settingKey]

	if setting == nil then
		local info = SettingsHelper.GetSettingInfo(settingKey)
		if info then
			setting = info.Default
		else
			return
		end
	end

	return setting
end

---Returns the string value of current setting. Works only for choice settings.
function ARACHNAMOD.GetSettingStr(settingKey)
	local settingValue = ARACHNAMOD.GetSetting(settingKey)

	local settingInfo = SettingsHelper.GetSettingInfo(settingKey)

	if not settingInfo.Choices then
		error("Setting " .. settingKey .. " is not a choice setting")
	end
	return settingInfo.Choices[settingValue]
end

-- Gets all settings. This is used by the settings menu.
---@return table
---@function
function SettingsHelper.GetAllSettings()
	return allSettings
end

---@function
function SettingsHelper.GetSettingInfo(name)
	for _, setting in pairs(allSettings) do
		if setting.Name == name then
			return setting
		end
	end
end

---@function
function SettingsHelper.GetDefault(settingKey)
	return SettingsHelper.GetSettingInfo(settingKey).Default
end

-- Creates a new multiple-choice setting.
---@param settingName string @The name of the setting. This is what will be displayed in the settings menu and how you'll get it with ARACHNAMOD.GetSetting()
---@param settingDescription any @The description of the setting. This is what will be displayed in the settings menu.
---@param possibleValues string[] @Array of possible values
---@param defaultValue number? @The index of the possibleValues array that is the default value. If this is nil, the first value in the array will be used.
---@param condition function? @A function that returns a boolean. If this function returns false, the setting will not be displayed.
---@function
function SettingsHelper.AddChoiceSetting(settingName, settingDescription, possibleValues, defaultValue, condition)
	defaultValue = defaultValue or 1

	table.insert(allSettings, {
		Name = settingName,
		Description = settingDescription,
		Default = defaultValue,
		Choices = possibleValues,
		Condition = condition,
		Type = ARACHNAMOD.SettingTypes.Choice,
	})
end

---@param settingName string @The name of the setting. This is what will be displayed in the settings menu and how you'll get it with ARACHNAMOD.GetSetting()
---@param settingDescription any @The description of the setting. This is what will be displayed in the settings menu.
---@param defaultValue boolean
---@param condition function? @A function that returns a boolean. If this function returns false, the setting will not be displayed.
---@function
function SettingsHelper.AddBooleanSetting(settingName, settingDescription, defaultValue, condition)
	table.insert(allSettings, {
		Name = settingName,
		Description = settingDescription,
		Default = defaultValue,
		Condition = condition,
		Type = ARACHNAMOD.SettingTypes.Boolean,
	})
end

-- Creates a new keybind setting.
---@param settingName string @The name of the setting. This is what will be displayed in the settings menu and how you'll get it with ARACHNAMOD.GetSetting()
---@param settingDescription any @The description of the setting. This is what will be displayed in the settings menu.
---@param defaultKey Keyboard @The default key for the setting.
---@param condition function? @A function that returns a boolean. If this function returns false, the setting will not be displayed.
---@function
function SettingsHelper.AddKeybindSetting(settingName, settingDescription, defaultKey, condition)
	table.insert(allSettings, {
		Name = settingName,
		Description = settingDescription,
		Default = defaultKey,
		Condition = condition,
		Type = ARACHNAMOD.SettingTypes.Keybind,
	})
end
