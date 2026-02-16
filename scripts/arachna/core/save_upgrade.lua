local Mod = ARACHNAMOD

local oldSaveDataLookup = {
	MomsHeart = "Mom's Heart",
	Isaac = "Isaac",
	Satan = "Satan",
	BossRush = "Boss Rush",
	BlueBaby = "Chest",
	Lamb = "Dark Room",
	MegaSatan = "Mega Satan",
	UltraGreed = "Greed",
	Hush = "Hush",
	Delirium = "Delirium",
	Mother = "Witness",
	Beast = "Beast",
}

---Many players might attempt to launch Arachna without REPENTOGON while IsaacSaveManager is still intact.
---Wait until the conditions are met to properly transfer save data of marks to REPENTOGON
---@param saveData table
function ARACHNAMOD:TransferMarksToREPENTOGON(saveData)
	if not REPENTOGON then
		return
	end
	--Arachna
	local normalMarks = saveData.file.other.arachnaMarks
	if normalMarks then
		local completionTable = Isaac.GetCompletionMarks(Mod.PlayerType.ARACHNA)
		for name, _ in pairs(completionTable) do
			local completionMark = oldSaveDataLookup[name]
			if normalMarks[completionMark] then
				completionTable[name] = tonumber(normalMarks[completionMark])
				Mod:DebugLog("Arachna Mark", name, "set to", completionTable[name])
			end
		end
		Isaac.SetCompletionMarks(completionTable)
		if normalMarks.Tainted > 0 then
			Mod.PersistGameData():TryUnlock(Mod.Character.ARACHNA_B.ACHIEVEMENT, true)
			Mod:DebugLog("Tainted unlocked!")
		end
		for completionType, achievement in pairs(Mod.CompletionMarkToAchievement.ARACHNA) do
			if completionType == Mod.CompletionType.ALL and Isaac.AllMarksFilled(Mod.PlayerType.ARACHNA) == 2
				or completionType < Mod.CompletionType.TAINTED and Isaac.GetCompletionMark(Mod.PlayerType.ARACHNA, completionType) > 0
			then
				Mod:DebugLog("Unlocked Normal-Side Achievement", achievement)
				Isaac.GetPersistentGameData():TryUnlock(achievement, true)
			end
		end
	end

	--Tainted Arachna
	local taintedMarks = saveData.file.other.arachnaMarksAlt
	if taintedMarks then
		local completionTable = Isaac.GetCompletionMarks(Mod.PlayerType.ARACHNA_B)
		for name, _ in pairs(completionTable) do
			local completionMark = oldSaveDataLookup[name]
			if taintedMarks[completionMark] then
				completionTable[name] = tonumber(taintedMarks[completionMark])
				Mod:DebugLog("Tainted Arachna Mark", name, "set to", completionTable[name])
			end
		end
		Isaac.SetCompletionMarks(completionTable)
		for completionType, achievement in pairs(Mod.CompletionMarkToAchievement.ARACHNA_B) do
			if completionType <= TaintedMarksGroup.POLAROID_NEGATIVE and Isaac.AllTaintedCompletion(Mod.PlayerType.ARACHNA_B, completionType) > 0
				or Isaac.GetCompletionMark(Mod.PlayerType.ARACHNA_B, completionType) > 0
			then
				Mod:DebugLog("Unlocked Tainted-Side Achievement", achievement)
				Isaac.GetPersistentGameData():TryUnlock(achievement, true)
			end
		end
	end

	--Remove deprecated save data and save
	if normalMarks or taintedMarks then
		saveData.file.other.arachnaMarks = nil
		saveData.file.other.arachnaMarksAlt = nil
		Mod.SaveManager.Save()
		ARACHNAMOD.ShowNewPopup = true
	end
end

ARACHNAMOD:AddCallback(Mod.SaveManager.SaveCallbacks.POST_DATA_LOAD, ARACHNAMOD.TransferMarksToREPENTOGON)

---@param saveData table
function ARACHNAMOD:ConvertSaveData(saveData)
	if saveData.arachnaMarks then
		Mod:Log("Old save format found. Transfered completion marks to new location.")
		local newSave = Mod.SaveManager.Utility.PatchSaveFile({}, Mod.SaveManager.DEFAULT_SAVE)
		newSave.file.other.arachnaMarks = saveData.arachnaMarks
		newSave.file.other.arachnaMarksAlt = saveData.arachnaMarksAlt
		return newSave
	end
end

ARACHNAMOD:AddCallback(Mod.SaveManager.SaveCallbacks.PRE_DATA_LOAD, ARACHNAMOD.ConvertSaveData)
