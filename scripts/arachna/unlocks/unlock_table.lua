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
ARACHNAMOD.Item.TESTAMENT.ACHIEVEMENT = achievement("Testament")
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
ARACHNAMOD.Trinket.SPRINDLE.ACHIEVEMENT = achievement("Sprindle")
ARACHNAMOD.Slot.SPIDER_BEGGAR.ACHIEVEMENT = achievement("Spider Beggar")
ARACHNAMOD.Card.MERGED_CARD.ACHIEVEMENT = achievement("Merged Card")
ARACHNAMOD.Item.DIVINE_CLOTH.ACHIEVEMENT = achievement("Divine Cloth")
ARACHNAMOD.Item.DADS_NEWSPAPER.ACHIEVEMENT = achievement("Dad's Newspaper")
ARACHNAMOD.Item.BEST_BUD_BALL.ACHIEVEMENT = achievement("Best Bud Ball")

ARACHNAMOD.CompletionMarkToAchievement.ARACHNA_B = {
	[TaintedMarksGroup.SOULSTONE] = Mod.Card.SOUL_OF_ARACHNA.ACHIEVEMENT,
	[TaintedMarksGroup.POLAROID_NEGATIVE] = Mod.Trinket.SPRINDLE.ACHIEVEMENT,
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
	OldType = {EntityType.ENTITY_SLOT},
	OldVariant = {SlotVariant.BEGGAR, SlotVariant.KEY_MASTER},
	NewType = EntityType.ENTITY_SLOT,
	NewVariant = Mod.Slot.SPIDER_BEGGAR.ID,
	ReplacementChance = 0.2,
	Achievement = Mod.Slot.SPIDER_BEGGAR.ACHIEVEMENT
})

Mod:RegisterReplacementEntity({
	OldType = {EntityType.ENTITY_SHOPKEEPER},
	OldVariant = {1, 2, 3, 4}, --Normal/Hanging Keepers and their Special variants
	NewType = EntityType.ENTITY_SHOPKEEPER,
	NewVariant = Mod.Entities.GOLDEN_SHOPKEEPER.ID,
	ReplacementChance = 0.2,
	Achievement = Mod.Entities.GOLDEN_SHOPKEEPER.ACHIEVEMENT
})

Mod:RegisterReplacementPickup({
	OldVariant = {PickupVariant.PICKUP_HEART},
	OldSubtype = {HeartSubType.HEART_BLACK, HeartSubType.HEART_BLENDED, HeartSubType.HEART_BONE, HeartSubType.HEART_ROTTEN},
	NewVariant = PickupVariant.PICKUP_HEART,
	NewSubtype = function (rng, subtype)
		if rng:RandomFloat() < 0.05 then
			return Mod.Pickup.WEB_HEART.ID_DOUBLE
		else
			return Mod.Pickup.WEB_HEART.ID
		end
	end,
	ReplacementChance = function ()
		if PlayerManager.AnyoneHasTrinket(Mod.Trinket.SPRINDLE.ID) then
			return 0.3
		else
			return 0.2
		end
	end,
	Achievement = Mod.Pickup.WEB_HEART.ACHIEVEMENT
})

--#endregion

--#region Achievement commands

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

local rootCommand = "arachnaMod"

local commands = {
	{"unlocktainted", "Unlocks Tainted Arachna", function() Mod.PersistGameData:TryUnlock(Mod.Character.ARACHNA_B.ACHIEVEMENT) end},
	{"unlockall", "Unlocks all mod achievements", function() manageAchievements(true) end},
	{"lockall", "Locks all mod achievements", function() manageAchievements(false) end},
}

Console.RegisterCommand(
	rootCommand,
	"Debug commands for the Arachna MOD",
	"Serves as a hub for all commands under the Arachna mod",
	true,
	AutocompleteType.CUSTOM
)

Mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, function(_, cmd, params)
	if cmd ~= rootCommand then
		return
	end
	for _, commandTable in ipairs(commands) do
		if params == commandTable[1] then
			commandTable[3]()
		end
	end
end)

Mod:AddCallback(ModCallbacks.MC_CONSOLE_AUTOCOMPLETE, function (command, params)
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