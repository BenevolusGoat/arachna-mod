local DSSUnlockManager = {
	MiscSaveData = {}
}

DSSUnlockManager.AppearType = {
	DISABLED = 1,
	ALLOWED = 2,
	FORCED = 3,
	CUSTOM = 4
}

DSSUnlockManager.MiscUnlockGroup = "misc unlocks"
DSSUnlockManager.NonUnlockGroup = "non-unlocks"

local numGroups = 0

DSSUnlockManager.UnlockGroupId = {
	[DSSUnlockManager.MiscUnlockGroup] = -1,
	[DSSUnlockManager.NonUnlockGroup] = -2,
}

DSSUnlockManager.UnlockGroupGfxRoot = {}
DSSUnlockManager.UnlockGroupIcons = {}

---@class DSSUnlockGroup
---@field Name string
---@field AchievementRoot string
---@field AchievementGroupIcon string

function DSSUnlockManager:RegisterGroup(name, root, icon)
	if not DSSUnlockManager.UnlockGroupId[name] then
		DSSUnlockManager.UnlockGroupId[name] = numGroups + 1
		numGroups = numGroups + 1
	end

	root = root or "gfx/ui/achievement/"

	if not DSSUnlockManager.UnlockGroupGfxRoot[name] then
		DSSUnlockManager.UnlockGroupGfxRoot[name] = root
	end
	if icon then
		DSSUnlockManager.UnlockGroupIcons[name] = root .. icon
	end
end

function DSSUnlockManager:ConfigureCatalogData(catalog)
	for _, itemData in ipairs(catalog) do
		local unlockData = itemData.Unlockable
		if unlockData and unlockData.Group then
			local groupName = unlockData.Group
			if not DSSUnlockManager.UnlockGroupId[groupName] then
				DSSUnlockManager.UnlockGroupId[groupName] = numGroups + 1
				numGroups = numGroups + 1
			end
			itemData.CatalogID = DSSUnlockManager.UnlockGroupId[groupName] or 0
		end
		local root = unlockData and unlockData.Group and DSSUnlockManager.UnlockGroupGfxRoot[unlockData.Group]
		local longToShort = {
			AchievementGraphic = "Gfx",
			AchievementPaperBack = "GfxBack",
			AchievementGraphicLock = "GfxLock"
		}
		for longName, shortName in pairs(longToShort) do
			if not unlockData[longName] and unlockData[shortName] then
				if root then
					unlockData[longName] = root .. unlockData[shortName]
				else
					unlockData[longName] = unlockData[shortName]
				end
			end
		end
	end
end

function DSSUnlockManager:GenerateDSSMenu(catalog)
	local groups = {}

	DSSUnlockManager:ConfigureCatalogData(catalog)

	local characterCatalogs = {}

	for _, itemData in pairs(catalog) do
		if not itemData.Hidden and not itemData.HideInDss then
			if itemData.ForCharacter then
				table.insert(characterCatalogs, itemData)
			else
				local unlockData = itemData.Unlockable
				local group
				if unlockData then
					if unlockData.Group and unlockData.Group ~= "" then
						group = string.lower(unlockData.Group)
					else
						group = DSSUnlockManager.MiscUnlockGroup
					end
				else
					group = DSSUnlockManager.NonUnlockGroup
				end

				if not groups[group] then
					groups[group] = {}
				end
				table.insert(groups[group], itemData)
			end
		end
	end

	table.sort(characterCatalogs, function(a, b)
		return DSSUnlockManager.UnlockGroupId[a.Unlockable.Group] < DSSUnlockManager.UnlockGroupId[b.Unlockable.Group]
	end)

	local menu = {
		--title = string.lower(mod.Name),
		title = "items / unlocks",
		noscroll = true,
		buttons = {
			{
				str = "achievements",
				dest = "achievementviewer",
				fsize = 3,
				tooltip = { strset = { 'view', 'achievements' } }
			},
			{ str = "", fsize = 2, nosel = true },
		},
	}

	return menu
end

return DSSUnlockManager

----------------------------------------------------------------------------------------------------
