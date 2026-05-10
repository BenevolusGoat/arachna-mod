local Mod = ArachnaMod

local function achievement(str)
	return Isaac.GetAchievementIdByName(str)
end

---@alias CompletionTable {[CompletionType|ArachnaCompletionType]: Achievement}

---@type {[string]: CompletionTable}
ArachnaMod.CompletionMarkToAchievement = {}

---@type {[PlayerType]: CompletionTable}
ArachnaMod.PlayerTypeToCompletionTable = {}

---@enum ArachnaCompletionType
ArachnaMod.CompletionType = {
	ALL = 18
}

--#region Arachna

ArachnaMod.Pickup.WEB_HEART.ACHIEVEMENT = achievement("Web Hearts")
ArachnaMod.Item.ARACHNAS_SPOOL.ACHIEVEMENT = achievement("Arachna's Spool")
ArachnaMod.Item.YARN.ACHIEVEMENT = achievement("The Yarn")
ArachnaMod.Item.GEPTAMERON.ACHIEVEMENT = achievement("Geptameron")
ArachnaMod.Trinket.WHITE_STRING.ACHIEVEMENT = achievement("White String")
ArachnaMod.Item.GLASSES_3D.ACHIEVEMENT = achievement("3D Glasses")
ArachnaMod.Item.MECHANICAL_EYE.ACHIEVEMENT = achievement("Mechanical Eye")
ArachnaMod.Trinket.INFESTED_PENNY.ACHIEVEMENT = achievement("Infested Penny")
ArachnaMod.Item.ARACHNIDS_GRIP.ACHIEVEMENT = achievement("Arachnid's Grip")
ArachnaMod.Entities.GOLDEN_SHOPKEEPER.ACHIEVEMENT = achievement("Golden Shopkeepers")
ArachnaMod.Item.MUTAGEN.ACHIEVEMENT = achievement("Mutagen")
ArachnaMod.Item.YARN_HEART.ACHIEVEMENT = achievement("Yarn Heart")
ArachnaMod.Item.TESTAMENT.ACHIEVEMENT = achievement("The Testament")
ArachnaMod.Item.LIL_ARACHNA.ACHIEVEMENT = achievement("Lil Arachna")
ArachnaMod.Character.ARACHNA_B.ACHIEVEMENT = achievement("The Wretched")

ArachnaMod.CompletionMarkToAchievement.ARACHNA = {
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
	[CompletionType.TAINTED] = Mod.Character.ARACHNA_B.ACHIEVEMENT,
	[Mod.CompletionType.ALL] = Mod.Item.LIL_ARACHNA.ACHIEVEMENT
}
ArachnaMod.PlayerTypeToCompletionTable[Mod.PlayerType.ARACHNA] = Mod.CompletionMarkToAchievement.ARACHNA

--#endregion

--#region Tainted Arachna

ArachnaMod.Card.SOUL_OF_ARACHNA.ACHIEVEMENT = achievement("Soul of Arachna")
ArachnaMod.Trinket.SPINDLE.ACHIEVEMENT = achievement("Spindle")
ArachnaMod.Slot.SPIDER_BEGGAR.ACHIEVEMENT = achievement("Spider Beggar")
ArachnaMod.Card.MERGED_CARD.ACHIEVEMENT = achievement("Merged Card")
ArachnaMod.Item.DIVINE_CLOTH.ACHIEVEMENT = achievement("Divine Cloth")
ArachnaMod.Item.DADS_NEWSPAPER.ACHIEVEMENT = achievement("Dad's Newspaper")
ArachnaMod.Item.BEST_BUD_BALL.ACHIEVEMENT = achievement("Best Bud Ball")

ArachnaMod.CompletionMarkToAchievement.ARACHNA_B = {
	[CompletionType.MEGA_SATAN] = Mod.Slot.SPIDER_BEGGAR.ACHIEVEMENT,
	[CompletionType.ULTRA_GREEDIER] = Mod.Card.MERGED_CARD.ACHIEVEMENT,
	[CompletionType.DELIRIUM] = Mod.Item.DIVINE_CLOTH.ACHIEVEMENT,
	[CompletionType.MOTHER] = Mod.Item.DADS_NEWSPAPER.ACHIEVEMENT,
	[CompletionType.BEAST] = Mod.Item.BEST_BUD_BALL.ACHIEVEMENT,
	[CompletionType.TAINTED_GROUP1] = Mod.Card.SOUL_OF_ARACHNA.ACHIEVEMENT,
	[CompletionType.TAINTED_GROUP2] = Mod.Trinket.SPINDLE.ACHIEVEMENT,
}
ArachnaMod.PlayerTypeToCompletionTable[Mod.PlayerType.ARACHNA_B] = Mod.CompletionMarkToAchievement.ARACHNA_B

--#endregion

--#region Entity replacements

Mod:RegisterReplacementEntity({
	OldType = { EntityType.ENTITY_SLOT },
	OldVariant = { SlotVariant.BEGGAR, SlotVariant.KEY_MASTER },
	NewType = EntityType.ENTITY_SLOT,
	NewVariant = Mod.Slot.SPIDER_BEGGAR.ID,
	ReplacementChance = Mod.Slot.SPIDER_BEGGAR.REPLACEMENT_CHANCE,
	Achievement = Mod.Slot.SPIDER_BEGGAR.ACHIEVEMENT
})

Mod:RegisterReplacementEntity({
	OldType = { EntityType.ENTITY_SHOPKEEPER },
	OldVariant = { 0, 1, 3, 4 }, --Normal/Hanging Keepers and their Special variants
	NewType = EntityType.ENTITY_SHOPKEEPER,
	NewVariant = Mod.Entities.GOLDEN_SHOPKEEPER.ID,
	ReplacementChance = Mod.Entities.GOLDEN_SHOPKEEPER.REPLACEMENT_CHANCE,
	Achievement = Mod.Entities.GOLDEN_SHOPKEEPER.ACHIEVEMENT
})

Mod:RegisterReplacementPickup({
	OldVariant = { PickupVariant.PICKUP_HEART },
	OldSubtype = { HeartSubType.HEART_BLACK, HeartSubType.HEART_BLENDED, HeartSubType.HEART_BONE, HeartSubType.HEART_ROTTEN },
	NewVariant = PickupVariant.PICKUP_HEART,
	NewSubtype = function(rng, subtype)
		if rng:RandomFloat() < Mod.Pickup.WEB_HEART.DOUBLE_REPLACEMENT_CHANCE then
			return Mod.Pickup.WEB_HEART.ID_DOUBLE
		else
			return Mod.Pickup.WEB_HEART.ID
		end
	end,
	ReplacementChance = function()
		local chance = Mod.Pickup.WEB_HEART.REPLACEMENT_CHANCE
		chance = chance + Mod.Trinket.SPINDLE.WEB_HEART_REPLACEMENT_BONUS * PlayerManager.GetTotalTrinketMultiplier(Mod.Trinket.SPINDLE.ID)
		return chance
	end,
	Achievement = Mod.Pickup.WEB_HEART.ACHIEVEMENT
})

--#endregion
