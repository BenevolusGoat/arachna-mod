local Mod = ARACHNAMOD

local function achievement(str)
	return Isaac.GetAchievementIdByName(str)
end

---@alias CompletionTable {[CompletionType|ArachnaCompletionType]: Achievement}

---@type {[string]: CompletionTable}
ARACHNAMOD.CompletionMarkToAchievement = {}

---@type {[PlayerType]: CompletionTable}
ARACHNAMOD.PlayerTypeToCompletionTable = {}

---@enum ArachnaCompletionType
ARACHNAMOD.CompletionType = {
	TAINTED = 15,
	ALL = 16
}

--#region Arachna

ARACHNAMOD.Pickup.WEB_HEART.ACHIEVEMENT = achievement("Web Hearts")
ARACHNAMOD.Item.ARACHNAS_SPOOL.ACHIEVEMENT = achievement("Arachna's Spool")
ARACHNAMOD.Item.YARN.ACHIEVEMENT = achievement("The Yarn")
ARACHNAMOD.Item.GEPTAMERON.ACHIEVEMENT = achievement("Geptameron")
ARACHNAMOD.Trinket.WHITE_STRING.ACHIEVEMENT = achievement("White String")
ARACHNAMOD.Item.GLASSES_3D.ACHIEVEMENT = achievement("3D Glasses")
ARACHNAMOD.Item.MECHANICAL_EYE.ACHIEVEMENT = achievement("Mechanical Eye")
ARACHNAMOD.Trinket.INFESTED_PENNY.ACHIEVEMENT = achievement("Infested Penny")
ARACHNAMOD.Item.ARACHNIDS_GRIP.ACHIEVEMENT = achievement("Arachnid's Grip")
ARACHNAMOD.Entities.GOLDEN_SHOPKEEPER.ACHIEVEMENT = achievement("Golden Shopkeepers")
ARACHNAMOD.Item.MUTAGEN.ACHIEVEMENT = achievement("Mutagen")
ARACHNAMOD.Item.YARN_HEART.ACHIEVEMENT = achievement("Yarn Heart")
ARACHNAMOD.Item.TESTAMENT.ACHIEVEMENT = achievement("The Testament")
ARACHNAMOD.Item.LIL_ARACHNA.ACHIEVEMENT = achievement("Lil Arachna")
ARACHNAMOD.Character.ARACHNA_B.ACHIEVEMENT = achievement("The Wretched")

ARACHNAMOD.CompletionMarkToAchievement.ARACHNA = {
	[CompletionType.MOMS_HEART] = Mod.Pickup.WEB_HEART.ACHIEVEMENT,
	[CompletionType.ISAAC] = Mod.Item.ARACHNAS_SPOOL.ACHIEVEMENT,
	[CompletionType.SATAN] = Mod.Item.YARN.ACHIEVEMENT,
	[CompletionType.BOSS_RUSH] = Mod.Item.GEPTAMERON.ACHIEVEMENT,
	[CompletionType.BLUE_BABY] = Mod.Trinket.WHITE_STRING.ACHIEVEMENT,
	[CompletionType.LAMB] = Mod.Item.GLASSES_3D.ACHIEVEMENT,
	[CompletionType.MEGA_SATAN] = Mod.Item.MECHANICAL_EYE.ACHIEVEMENT,
	[CompletionType.ULTRA_GREED] = Mod.Trinket.INFESTED_PENNY.ACHIEVEMENT,
	[CompletionType.HUSH] = Mod.Item.ARACHNIDS_GRIP.ACHIEVEMENT,
	[CompletionType.ULTRA_GREEDIER] = Mod.Entities.GOLDEN_SHOPKEEPER.ACHIEVEMENT,
	[CompletionType.DELIRIUM] = Mod.Item.MUTAGEN.ACHIEVEMENT,
	[CompletionType.MOTHER] = Mod.Item.YARN_HEART.ACHIEVEMENT,
	[CompletionType.BEAST] = Mod.Item.TESTAMENT.ACHIEVEMENT,
	[Mod.CompletionType.TAINTED] = Mod.Character.ARACHNA_B.ACHIEVEMENT,
	[Mod.CompletionType.ALL] = Mod.Item.LIL_ARACHNA.ACHIEVEMENT
}
ARACHNAMOD.PlayerTypeToCompletionTable[Mod.PlayerType.ARACHNA] = Mod.CompletionMarkToAchievement.ARACHNA

--#endregion

--#region Tainted Arachna

ARACHNAMOD.Card.SOUL_OF_ARACHNA.ACHIEVEMENT = achievement("Soul of Arachna")
ARACHNAMOD.Trinket.SPINDLE.ACHIEVEMENT = achievement("Spindle")
ARACHNAMOD.Slot.SPIDER_BEGGAR.ACHIEVEMENT = achievement("Spider Beggar")
ARACHNAMOD.Card.MERGED_CARD.ACHIEVEMENT = achievement("Merged Card")
ARACHNAMOD.Item.DIVINE_CLOTH.ACHIEVEMENT = achievement("Divine Cloth")
ARACHNAMOD.Item.DADS_NEWSPAPER.ACHIEVEMENT = achievement("Dad's Newspaper")
ARACHNAMOD.Item.BEST_BUD_BALL.ACHIEVEMENT = achievement("Best Bud Ball")

ARACHNAMOD.CompletionMarkToAchievement.ARACHNA_B = {
	[TaintedMarksGroup.SOULSTONE] = Mod.Card.SOUL_OF_ARACHNA.ACHIEVEMENT,
	[TaintedMarksGroup.POLAROID_NEGATIVE] = Mod.Trinket.SPINDLE.ACHIEVEMENT,
	[CompletionType.MEGA_SATAN] = Mod.Slot.SPIDER_BEGGAR.ACHIEVEMENT,
	[CompletionType.ULTRA_GREEDIER] = Mod.Card.MERGED_CARD.ACHIEVEMENT,
	[CompletionType.DELIRIUM] = Mod.Item.DIVINE_CLOTH.ACHIEVEMENT,
	[CompletionType.MOTHER] = Mod.Item.DADS_NEWSPAPER.ACHIEVEMENT,
	[CompletionType.BEAST] = Mod.Item.BEST_BUD_BALL.ACHIEVEMENT
}
ARACHNAMOD.PlayerTypeToCompletionTable[Mod.PlayerType.ARACHNA_B] = Mod.CompletionMarkToAchievement.ARACHNA_B

--#endregion

--#region Entity replacements

Mod:RegisterReplacementEntity({
	OldType = { EntityType.ENTITY_SLOT },
	OldVariant = { SlotVariant.BEGGAR, SlotVariant.KEY_MASTER },
	NewType = EntityType.ENTITY_SLOT,
	NewVariant = Mod.Slot.SPIDER_BEGGAR.ID,
	ReplacementChance = 0.2,
	Achievement = Mod.Slot.SPIDER_BEGGAR.ACHIEVEMENT
})

Mod:RegisterReplacementEntity({
	OldType = { EntityType.ENTITY_SHOPKEEPER },
	OldVariant = { 1, 2, 3, 4 }, --Normal/Hanging Keepers and their Special variants
	NewType = EntityType.ENTITY_SHOPKEEPER,
	NewVariant = Mod.Entities.GOLDEN_SHOPKEEPER.ID,
	ReplacementChance = 0.2,
	Achievement = Mod.Entities.GOLDEN_SHOPKEEPER.ACHIEVEMENT
})

Mod:RegisterReplacementPickup({
	OldVariant = { PickupVariant.PICKUP_HEART },
	OldSubtype = { HeartSubType.HEART_BLACK, HeartSubType.HEART_BLENDED, HeartSubType.HEART_BONE, HeartSubType.HEART_ROTTEN },
	NewVariant = PickupVariant.PICKUP_HEART,
	NewSubtype = function(rng, subtype)
		if rng:RandomFloat() < 0.05 then
			return Mod.Pickup.WEB_HEART.ID_DOUBLE
		else
			return Mod.Pickup.WEB_HEART.ID
		end
	end,
	ReplacementChance = function()
		if PlayerManager.AnyoneHasTrinket(Mod.Trinket.SPINDLE.ID) then
			return 0.3
		else
			return 0.2
		end
	end,
	Achievement = Mod.Pickup.WEB_HEART.ACHIEVEMENT
})

--#endregion

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

	for i = startAch, endAch do
		if shouldUnlock then
			Mod.PersistGameData:TryUnlock(i, true)
		else
			Isaac.ExecuteCommand("lockachievement " .. i)
		end
	end
end

---@param playerType PlayerType
---@param args string
local function setMarkCommand(playerType, args)
	for name, completionType in pairs(nameToMark) do
		local strStart, strEnd = string.find(args, name)
		if strStart and strEnd then
			args = string.sub(args, strEnd + 2)
			local value = tonumber(args)
			if value and value >= 0 and value <= 2 then
				Isaac.SetCompletionMark(playerType, completionType, value)
				break
			end
		end
	end
end

local rootCommand = "arachnaMod"

---@type {[1]: string, [2]: string}[]
local commands = {
	{ "unlocktainted",  "Unlocks Tainted Arachna" },
	{ "unlockall",      "Unlocks all mod achievements" },
	{ "lockall",        "Locks all mod achievements" },
	{ "setmark",        "Args: <string completiontype> <int value>. Updates a completion mark for Arachna" },
	{ "setmarktainted", "Args: <string completiontype> <int value>. Updates a completion mark for Tainted Arachna" },
}

local helpText = {
	["setmark"] =
		"<completiontype>: [MomsHeart|Isaac|Satan|BossRush|BlueBaby|Lamb|MegaSatan|UltraGreed|Hush|Delirium|Mother|Beast]\n"
		.. "<value>: [0: Locked|1: Normal|2: Hard]\n"
		.. "Examples:\n"
		.. "(arachnaMod setmark MomsHeart 0) will set the Mom's Heart/It Lives completion mark to Locked.\n"
		.. "(arachnaMod setmark Beast 1) will set the Beast completion mark to Normal Mode.\n"
		.. "(arachnaMod setmark UltraGreed 2) will set the Greed Mode completion mark to Hard/Greedier Mode."
	,
	["setmarktainted"] = "Arguments are identical to setmark's arguments.",
}

---@type {[string]: fun(args: string)}
local commandFuncs = {
	["unlocktainted"] = function()
		Mod.PersistGameData:TryUnlock(Mod.Character.ARACHNA_B.ACHIEVEMENT)
	end,
	["unlockall"] = function()
		manageAchievements(true)
	end,
	["lockall"] = function()
		manageAchievements(false)
	end,
	["setmark"] = function(args)
		setMarkCommand(Mod.PlayerType.ARACHNA, args)
	end,
	["setmarktainted"] = function(args)
		setMarkCommand(Mod.PlayerType.ARACHNA_B, args)
	end
}

local description = "The following commands can be accessed by typing \"arachnaMod <command name>\""
for _, commandTable in ipairs(commands) do
	description = description .. "\n  - " .. commandTable[1] .. " - " .. commandTable[2]
	if helpText[commandTable[1]] then
		description = description .. ". " .. helpText[commandTable[1]]
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
		if string.find(params, commandTable[1]) then
			local args = string.gsub(params, commandTable[1] .. " ", "")
			commandFuncs[commandTable[1]](args)
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
