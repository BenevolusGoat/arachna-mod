local Mod = ARACHNAMOD

-- Template strings used for unlock descriptions. Format them with a character or challenge name
---@enum UnlockStrings
ARACHNAMOD.UnlockStrings = {
	[CompletionType.MOMS_HEART] = "Unlocked by defeating Mom's Heart as %s.",
	[CompletionType.ISAAC] = "Unlocked by defeating Isaac as %s.",
	[CompletionType.SATAN] = "Unlocked by defeating Satan as %s.",
	[CompletionType.BOSS_RUSH] = "Unlocked by completing the Boss Rush as %s.",
	[CompletionType.BLUE_BABY] = "Unlocked by defeating ??? as %s.",
	[CompletionType.LAMB] = "Unlocked by defeating The Lamb as %s.",
	[CompletionType.MEGA_SATAN] = "Unlocked by defeating Mega Satan as %s.",
	[CompletionType.ULTRA_GREED] = "Unlocked by defeating Ultra Greed as %s.",
	[CompletionType.HUSH] = "Unlocked by defeating Hush as %s.",
	[CompletionType.ULTRA_GREEDIER] = "Unlocked by defeating Ultra Greedier as %s.",
	[CompletionType.DELIRIUM] = "Unlocked by defeating Delirium as %s.",
	[CompletionType.MOTHER] = "Unlocked by defeating Mother as %s.",
	[CompletionType.BEAST] = "Unlocked by defeating The Beast as %s.",
	[Mod.CompletionType.TAINTED] = "Use the Red Key to open the hidden closet in Home as %s.",
	[Mod.CompletionType.ALL] = "Unlocked by obtaining every other unlock for %s.",
}

ARACHNAMOD.TaintedUnlockStrings = {
	[TaintedMarksGroup.POLAROID_NEGATIVE] = "Unlocked by defeating Isaac, ???, Satan, and the Lamb as %s.",
	[TaintedMarksGroup.SOULSTONE] = "Unlocked by defeating Hush and Boss Rush as %s.",
}

local playerTypeToGroup = {
	[Mod.PlayerType.ARACHNA] = "arachna",
	[Mod.PlayerType.ARACHNA_B] = "tainted arachna"
}

return function(DSSUnlockManager)
	local catalogTable = {}
	DSSUnlockManager:RegisterGroup("arachna", nil, "group_icons/group_arachna.png")
	DSSUnlockManager:RegisterGroup("tainted arachna", nil, "group_icons/group_arachna_b.png")

	local function makeUnlockTable(groupName, completionType, achievement)
		local xmlData = XMLData.GetEntryById(XMLNode.ACHIEVEMENT, achievement)
		local achievementName = xmlData.name
		local desc
		if groupName == "arachna" and completionType == Mod.CompletionType.TAINTED then
			desc = ARACHNAMOD.UnlockStrings[completionType]:format(groupName)
			groupName = "tainted arachna"
		elseif groupName == "tainted arachna" and (completionType == TaintedMarksGroup.POLAROID_NEGATIVE or completionType == TaintedMarksGroup.SOULSTONE) then
			desc = ARACHNAMOD.TaintedUnlockStrings[completionType]:format(groupName)
		else
			desc = ARACHNAMOD.UnlockStrings[completionType]:format(groupName)
		end

		return {
			Name = achievementName:lower(),
			ForCharacter = completionType == Mod.CompletionType.TAINTED,
			Priority = completionType,
			Unlockable = {
				Group = groupName,
				Desc = desc:lower(),
				Gfx = xmlData.gfx,
				Unlocked = function()
					return Mod.PersistGameData():Unlocked(achievement)
				end,
			},
		}
	end
	for playerType, completionTable in pairs(ARACHNAMOD.PlayerTypeToCompletionTable) do
		local groupName = playerTypeToGroup[playerType]
		for completionType, achievement in pairs(completionTable) do
			Mod.Insert(catalogTable, makeUnlockTable(groupName, completionType, achievement))
		end
	end
	--[[ for _, unlockCategories in pairs(Mod.Unlock) do
		for _, unlockInfo in pairs(unlockCategories) do
			table.insert(catalogTable, makeUnlockTable(unlockInfo))
		end
	end ]]
	return catalogTable
end
