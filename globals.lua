--#region Mod identifiers

---@meta
---@diagnostic disable: lowercase-global
-- This file only exists to tell the code editor what exists outside of the mod folder to stop it complaining
ModConfigMenu = {}
ModConfigMenuPopupGfx = {}
ANDROMEDA = {}
arachnaIsUnlocked = {}
CCO = {}
RareChest = {}
CustomCollectibles = {}
RepentancePlusMod = {}
CustomPickups = {}
SpecialistModAPI = {}
TaintedCollectibles = {}
TaintedMachines = {}
Sewn_API = {}
FiendFolio = {}
RareChests = {}
StageAPI = {} -- Ew
HeavensCall = {}
TaintedTreasure = {}
RAAV = {}
ThePunished = {}
Poglite = {} -- Pog for good items
Epic = {} -- Specialist for good items
REVEL = {} -- Revelations
FilepathHelper = {}
CorruptedCharactersMod = {} -- Old mod namespace
SamaelMod = {}
CustomHealthAPI = {}
Retribution = {}
yandereWaifu = {} -- Rebekah
TheFuture = {}
UNINTRUSIVEPAUSEMENU = {}
MiniPauseMenu_Mod = {}
MiniPauseMenuPlus_Mod = {}
Encyclopedia = {}
EID = {}
LibraryExpanded = {}
UnlockAPI = {}
FFGRACE = {}
HPBars = {}
EEVEEMOD = {} --The demo
EeveeMod = {} --The full release
CustomCoopGhost = {}
Ughlite = {} --Ugh for bad items
NoCostumes = {}
GodsGambit = {}
UniqueProgressBarIcon = {}
EnlightenmentMod = {}
UniqueProgressBarIcon = {}
CustomPoopAPI = {} --From Fiend Folio
NoHealthCapModEnabled = false
NoHealthCapRedMax = 0
NoHealthCapSoulHearts = 0
NoHealthCapBoneHearts = 0
NoHealthCapBrokenHearts = 0
Sheriff = {}
CustomBombHUDIcons = {}
ComplianceImmortal = {}
ComplianceSun = {}
RestoredCollection = {}
Martha = {}
Sheriff = {}
MASTEMA = {}
BirthcakeRebaked = {}
Epiphany = {}
UniqueMinisaacs = {}

--#endregion

--#region EID

---@class EID_DescObj
---@field ObjType integer
---@field ObjVariant integer
---@field ObjSubType integer
---@field fullItemString string
---@field Name string
---@field Description string
---@field Transformation string
---@field ModName string
---@field Quality integer
---@field Icon table @[see docs](https://github.com/wofsauge/External-Item-Descriptions/wiki/Description-Modifiers#description-object-attributes)
---@field Entity Entity?
---@field ShowWhenUndefined boolean

---Simple function to help with adding properly formatted sections to the reminder description
---returns false, when no further descriptions should be added
---@param icon string?
---@param title string
---@param newDesc string
function EID:ItemReminderAddTempDescriptionEntry(icon, title, newDesc) end

---@param categoryID string
---@return boolean
function EID:IsCategorySelected(categoryID) end

---returns true, if its possible for the currently evaluated view to have more descriptions added to it
---@return boolean
function EID:ItemReminderCanAddMoreToView() end

-- Adds a new icon object with the shortcut defined in the "shortcut" variable (e.g. "{{shortcut}}" = your icon)
-- Shortcuts are case Sensitive! Shortcuts can be overriden with this function to allow for full control over everything
-- Setting "animationFrame" to -1 will play the animation. The spriteObject needs to be of class Sprite() and have an .anm2 loaded
-- default values: leftOffset= -1 , topOffset = 0
function EID:addIcon(shortcut, animationName, animationFrame, width, height, leftOffset, topOffset, spriteObject)end

---@param trinketId TrinketType
---@param trinketTable {t: number[], mult: number[] | nil} @`t` is a table of numbers in the description to multiply by the trinket multiplier. `mult` is to override the default multipliers of 2 and 3
function EID:addGoldenTrinketTable(trinketId, trinketTable) end

-- Add text to a pedestal's description when you own a different item
--
-- Example usage: EID:addCondition(myDevilishItemID, EID.IsGreedMode, "{{GreedMode}} Reduces shop prices by 1 for each optional Nightmare wave completed")
---@param ID CollectibleType | string | table @ID and ownedID can be a collectible ID or a full item string (like "5.350.54"). For convenience, ID can be a table of IDs that will all get the condition applied
---@param ownedID integer | function @ownedID can also be a function rather than just an ID; if it returns true, the text will be displayed
---@param text string @The text will be added as a new line (except with `replaceText`), with the owned item's icon at the start
---@param replaceText? string @Will use `text` as a reference. If the text is found in the description, will replace it with `replaceText`
---@param language? string
---@param extraTable? table
function EID:addCondition(ID, ownedID, text, replaceText, language, extraTable) end

-- Shortcut function for when you have two items that have a synergy with each other
--
-- Example usage: EID:addSynergyCondition(myHappyLittleItemID, {CollectibleType.COLLECTIBLE_BRIMSTONE, CollectibleType.COLLECTIBLE_SULFUR}, "Turns your laser into a smiley face that charms enemies")
---@param ID1 CollectibleType[] | CollectibleType @ID1 will have text1 added to its description if you own ID2
---@param ID2 CollectibleType[] | CollectibleType @ID2 will have text2 (or text1, if text2 isn't given) added to its description if you own ID1
---@param text1 string
---@param text2? string
---@param language? string
---@param extraTable? table
function EID:addSynergyCondition(ID1, ID2, text1, text2, language, extraTable)
end

-- Function for adding text to a pedestal's description when you're playing a specific character
--
-- Example usage: EID:addPlayerCondition(myAngstyItemID, PlayerType.PLAYER_EVE, "Gives Eve extra mascara (2x Damage multiplier)")
---@param ID string | CollectibleType @string format: "`type`.`variant`.`subtype`"
---@param playerID PlayerType | PlayerType[]
---@param text string @The text will be added as a new line (except with `replaceText`), with the player's head icon at the start
---@param replaceText? string @Will use `text` as a reference. If the text is found in the description, will replace it with `replaceText`
---@param language? string
---@param extraTable? table
---@param includeTainted? boolean @default: `true`. Set to `false` to not include this description on the tainted version of the character
function EID:addPlayerCondition(ID, playerID, text, replaceText, language, extraTable, includeTainted)
end

-- Shortcut function for adding Repentance Tarot Cloth conditions
---@param ID string | CollectibleType @string format: "`type`.`variant`.`subtype`"
---@param text string
---@param numberToDouble? number[] @Dictates the number do multiply by 2
---@param newNumber? number[] @Will replace `numberToDouble` instead of multiplying
---@param language? string
function EID:addTarotClothBuffsCondition(ID, text, numberToDouble, newNumber, language)
end

-- Shortcut function for adding car battery conditions
---@param ID string | CollectibleType @string format: "`type`.`variant`.`subtype`"
---@param text string
---@param numberToDouble? number[] @Dictates the number do multiply by 2
---@param newNumber? number[] @Will replace `numberToDouble` instead of multiplying
---@param language? string
function EID:addCarBatteryCondition(ID, text, numberToDouble, newNumber, language)
end

-- Shortcut function for adding abyss synergies conditions
---@param ID string | CollectibleType @string format: "`type`.`variant`.`subtype`"
---@param text string
---@param numberToDouble? number[] @Dictates the number do multiply by 2
---@param newNumber? number[] @Will replace `numberToDouble` instead of multiplying
---@param language? string
function EID:addAbyssSynergiesCondition(ID, text, numberToDouble, newNumber, language)
end

-- Shortcut function for adding book of belial conditions
---@param ID string | CollectibleType @string format: "`type`.`variant`.`subtype`"
---@param text string
---@param numberToDouble? number[] @Dictates the number do multiply by 2
---@param newNumber? number[] @Will replace `numberToDouble` instead of multiplying
---@param language? string
function EID:addBookOfBelialBuffsCondition(ID, text, numberToDouble, newNumber, language)
end

-- Shortcut function for adding binge eater conditions
---@param ID string | CollectibleType @string format: "`type`.`variant`.`subtype`"
---@param text string
---@param numberToDouble? number[] @Dictates the number do multiply by 2
---@param newNumber? number[] @Will replace `numberToDouble` instead of multiplying
---@param language? string
function EID:addBingeEaterBuffsCondition(ID, text, numberToDouble, newNumber, language)
end

-- Shortcut function for adding BFFS conditions; this is slightly more complex since it supports trinkets
--
-- Example usage: EID:addBFFSCondition(myBasicFamiliarID, nil, 3.5)
---@param ID string | CollectibleType @string format: "`type`.`variant`.`subtype`"
---@param text string
---@param numberToDouble? number[] @Dictates the number do multiply by 2
---@param newNumber? number[] @Will replace `numberToDouble` instead of multiplying
---@param language? string
function EID:addBFFSCondition(ID, text, numberToDouble, newNumber, language)
end

-- Shortcut function for adding Hive Mind conditions; by default, it will show with BFFS too, unless you pass in allowBFFS as false
---@param ID string | CollectibleType @string format: "`type`.`variant`.`subtype`"
---@param text string
---@param numberToDouble? number[] @Dictates the number do multiply by 2
---@param newNumber? number[] @Will replace `numberToDouble` instead of multiplying
---@param language? string
---@param allowBFFS? boolean @default: `true`
function EID:addHiveMindCondition(ID, text, numberToDouble, newNumber, language, allowBFFS)
end

-- Actives that have no additional effect from Car Battery. Adds a "No effect" line
---@type {[CollectibleType]: boolean}
EID.CarBatteryNoSynergy = {}
-- Items that should show their Car Battery synergy while looking at a Car Battery pedestal
---@type {[CollectibleType]: boolean}
EID.CarBatteryPedestalWhitelist = {}
-- Familiars that have no effect from BFFS!
---@type {[CollectibleType]: boolean}
EID.BFFSNoSynergy = {}
-- Items that should show their BFFS / Hive Mind synergy while looking at a BFFS / Hive Mind pedestal
---@type {[CollectibleType]: boolean}
EID.BFFSPedestalWhitelist = {}
-- Familiars that count for Hive Mind in Repentance (although it could give them No Effect if it just increases size)
---@type {[CollectibleType]: boolean}
EID.HiveMindFamiliars = {}
-- Tainted character's respective normal version ID, for conditionals that apply to both versions of the character
-- To help with other character pairs, Esau = Jacob, Dead Tainted Lazarus = Tainted Lazarus, Tainted Soul = Tainted Forgotten
---@type {[PlayerType]: PlayerType}
EID.TaintedToRegularID = {}
---@alias HeartType "Red"|"Soul"|"Black"|"Coin"|"None"|string
-- lookup table of all characters with a given heart type
---@type {[HeartType]: PlayerType[]}
EID.SpecialHeartPlayers = {}
-- Lookup table for the type of health each player has
---@type {[PlayerType]: HeartType}
EID.CharacterToHeartType = {}
-- Characters with the listed health types remove any lines that start with {{HealingRed}} or {{HealingHalfRed}}
---@type {[HeartType]: boolean}
EID.HealthTypesWithoutHealing = {}
-- Character IDs that have a pocket active (0 = normal, 1 = timed, 2 = special). For 4.5 Volt
---@type {[PlayerType]: CollectibleType}
EID.PocketActivePlayerIDs = {}
-- Number of Health Ups you get from a Health Up item
-- (Pill ID is off by +1 because of EID one-indexed pill effects)
--
-- Usage: EID.HealthUpData["`type`.`variant`.`subtype`"] = `numberOfHearts`
--
-- Examples:
--
-- EID.HealthUpData["5.70.7"] = -1 (Health Down Pill)
--
-- EID.HealthUpData["5.100.12"] = 1 (Magic Mushroom)
---@type {[string]: integer}
EID.HealthUpData = {}
-- Items with a healing effect that can have the healing line removed for non-red HP characters. Indicated lines start with {{HealingRed}} or {{HealingHalfRed}} for the bullet point
-- (Pill ID is off by +1 because of EID one-indexed pill effects)
--
-- Usage: EID.HealingItemData["`type`.`variant`.`subtype`"] = `numberOfHearts`
--
-- Examples:
--
-- EID.HealingItemData["5.70.37"] = true (Power Pill!)
--
-- EID.HealingItemData["5.100.45"] = true (Yum Heart)
---@type {[string]: boolean}
EID.HealingItemData = {}
-- Items that are removed from Isaac after use. Adds a "! SINGLE USE !" line to the description
EID.SingleUseCollectibles = {}
-- Indicates Wisps created by items, that only last 1 room
---@type{[CollectibleType]: boolean}
EID.WispData.SingleRoom = {}
-- Indicates items, that dont create any wisps at all
---@type{[CollectibleType]: boolean}
EID.WispData.NoWisp = {}
---For displaying descriptions with Book of Virtues. Table is formatted as follows:
---
---{`number` hp, `integer` layer, `number` damage, `number` stageDamage, `number` damageMultiplier2, `number` shotSpeed, `number` fireDelay, `number` procChance, `boolean` canshoot, `integer` amount, `TearFlags[]` tearFlags, `TearFlags[]` tearFlags2}
---@type {[CollectibleType]: table}
EID.XMLWisps = {}

--#endregion

--#region MinimapAPI

---@param id string
---@param icon string @Same ID you used in MinimapAPI:AddIcon()
---@param entType EntityType
---@param variant integer
---@param subtype integer
---@param condition fun(): boolean
---@param iconGroup "hearts" | "trinkets" | "chests" | "runes" | "cards" | "pills" | "keys" | "bombs" | "poops" | "coins" | "batteries" | "beggars" | "slots" | "portals" | "other"
---@param priority? number @default: `13000`. Each type of pickup has a different base priority, going up in increments of 100 for different variants. Below is a list of base priorities for each pickup variant:
---Heart: `15000`
---
---Item: `14000`
---
---Trinket: `13000`
---
---Chests: `12000`
---
---Runes: `11000`
---
---Cards: `10000`
---
---Pills: `9000`
---
---Keys: `8000`
---
---Bombs: `7000`
---
---Poops: `6000`
---
---Coins: `5000`
---
---Batteries: `4000`
---
---Beggars: `3000`
---
---Slots: `2000`
---
---Ladder: `1000`
---
---Portal: `0`
function MinimapAPI:AddPickup(id, icon, entType, variant, subtype, condition, iconGroup, priority)
end

---@param id string
---@param sprite Sprite
---@param animationName string
---@param frame number
---@param color? Color
function MinimapAPI:AddIcon(id, sprite, animationName, frame, color)
end

MinimapAPI.PickupSlotMachineNotBroken = function() return true end
MinimapAPI.PickupChestNotCollected = function() return true end
MinimapAPI.PickupNotCollected = function() return true end

--#endregion

--#region Misc

include = require

---@type string
MOD_PATH = nil

CARDBOARD_CHEST = Isaac.GetEntityVariantByName("Cardboard Chest")
FILE_CABINET = Isaac.GetEntityVariantByName("File Cabinet")
SLOT_CHEST = Isaac.GetEntityVariantByName("Slot Chest")
TOMB_CHEST = Isaac.GetEntityVariantByName("Tomb Chest")
DEVIL_CHEST = Isaac.GetEntityVariantByName("Devil Chest")
CURSED_CHEST = Isaac.GetEntityVariantByName("Cursed Chest")
BLOOD_CHEST = Isaac.GetEntityVariantByName("Blood Chest")
PENITENT_CHEST = Isaac.GetEntityVariantByName("Penitent Chest")

_ = {} ---@type any

--#endregion