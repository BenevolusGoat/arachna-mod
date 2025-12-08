InputHelper = include("scripts/helpers/vendor/inputhelper")

---@class ModReference
_G.ARACHNAMOD = RegisterMod("Arachna Mod", 1)

ARACHNAMOD.Version = "2.0.0"

local Mod = ARACHNAMOD

ARACHNAMOD.SaveManager = include("scripts.tools.save_manager")
ARACHNAMOD.SaveManager.Init(Mod)

ARACHNAMOD.sfxman = SFXManager()
ARACHNAMOD.Game = Game()
ARACHNAMOD.PersistGameData = REPENTOGON and Isaac.GetPersistentGameData() or nil
ARACHNAMOD.Room = function() return Mod.Game:GetRoom() end
ARACHNAMOD.Level = function() return Mod.Game:GetLevel() end
ARACHNAMOD.ItemConfig = Isaac.GetItemConfig()

ARACHNAMOD.GENERIC_RNG = RNG()

ARACHNAMOD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
	local seed = ARACHNAMOD.Game:GetSeeds():GetStartSeed()
	ARACHNAMOD.GENERIC_RNG:SetSeed(seed, 35)
	if Mod.ShowNewPopup then
		DeadSeaScrollsMenu.QueueMenuOpen("Arachna", "arachnapopup", 0, true)
		Mod.ShowNewPopup = nil
	end
end)

ARACHNAMOD.RANGE_BASE_MULT = 40

---A little optimization for storing the variables locally as opposed to calling upon them each time
ARACHNAMOD.math = {
	ceil = math.ceil,
	floor = math.floor,
	max = math.max,
	min = math.min,
	abs = math.abs,
	log = math.log,
	sin = math.sin,
	sqrt = math.sqrt,
	cos = math.cos,
	rad = math.rad
}

ARACHNAMOD.PlayerType = {
	ARACHNA = Isaac.GetPlayerTypeByName("Arachna", false),
	ARACHNA_B = Isaac.GetPlayerTypeByName("Arachna", true)
}

---@type table[]
local getData = {}

---Slightly faster than calling GetData, a micromanagement at best
---
---However GetData() is wiped on POST_ENTITY_REMOVE, so this also helps retain the data until after entity removal
---@param ent Entity
---@return table
function ARACHNAMOD:GetData(ent)
	if not ent then return {} end
	local ptrHash = GetPtrHash(ent)
	if not getData[ptrHash] then
		local newData = {
			Pointer = EntityPtr(ent)
		}
		getData[ptrHash] = newData
	end
	return getData[ptrHash]
end

---@param ent Entity
---@return table?
function ARACHNAMOD:TryGetData(ent)
	local ptrHash = GetPtrHash(ent)
	return getData[ptrHash]
end

ARACHNAMOD:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, CallbackPriority.LATE, function(_, ent)
	if not ent:ToNPC() then
		getData[GetPtrHash(ent)] = nil
	end
end)

ARACHNAMOD:AddPriorityCallback(ModCallbacks.MC_POST_NPC_DEATH, CallbackPriority.LATE, function(_, ent)
	getData[GetPtrHash(ent)] = nil
end)

ARACHNAMOD:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.LATE, function(_, ent)
	for ptrHash, entityData in pairs(getData) do
		local entityPointer = (entityData and entityData.Pointer)
		if not (entityPointer and entityPointer.Ref) then
			entityData[ptrHash] = nil
		end
	end
end)

local legacyEnabled = false

---@param player EntityPlayer
function ARACHNAMOD:IsAnyArachna(player)
	local playerType = player:GetPlayerType()
	return playerType == Mod.PlayerType.ARACHNA or playerType == Mod.PlayerType.ARACHNA_B
end

function ARACHNAMOD:IsLegacyGameplayEnabled()
	return legacyEnabled
end

function ARACHNAMOD:EveryoneIsArachna()
	local foundArachna = false
	local noArachna = Mod.Foreach.Player(function(player, index)
		if Mod:IsAnyArachna(player) then
			foundArachna = true
		elseif not player.Parent then
			return true
		end
	end)
	if noArachna then
		return false
	else
		return foundArachna
	end
end

function ARACHNAMOD:SomeoneIsArachna()
	return PlayerManager.AnyoneIsPlayerType(Mod.PlayerType.ARACHNA) or PlayerManager.AnyoneIsPlayerType(Mod.PlayerType.ARACHNA_B)
end

function ARACHNAMOD:UpdateLegacyGameplay()
	local run_save = Mod.SaveManager.GetRunSave()
	if Mod.Game:GetFrameCount() <= 0 then
		run_save.ArachnaLegacyGameplay = Mod.GetSetting(Mod.Setting.LegacyGameplay)
	end
	legacyEnabled = run_save.ArachnaLegacyGameplay
end

Mod:AddCallback(Mod.SaveManager.SaveCallbacks.POST_GLOBAL_DATA_LOAD, ARACHNAMOD.UpdateLegacyGameplay)

ARACHNAMOD.FileLoadError = false
ARACHNAMOD.InvalidPathError = false

---Mimics include() but with a pcall safety wrapper and appropriate error codes if any are found
---
---VSCode users: Go to Settings > Lua > Runtime:Special and link ARACHNAMOD.Include to require, just like you would regular include!
---@return unknown
function ARACHNAMOD.Include(path)
	Isaac.DebugString("[ArachnaMOD] Loading " .. path)
	local wasLoaded, result = pcall(include, path)
	local errMsg = ""
	local foundError = false
	if not wasLoaded then
		ARACHNAMOD.FileLoadError = true
		foundError = true
		errMsg = 'Error in path "' .. path .. '":\n' .. result .. '\n'
	elseif result and type(result) == "string" and string.find(result, "no file '") then
		foundError = true
		ARACHNAMOD.InvalidPathError = true
		errMsg = 'Unable to locate file in path "' .. path .. '"\n'
	end
	if foundError then
		ARACHNAMOD:Log(errMsg)
	end
	return result
end

function ARACHNAMOD.LoopInclude(tab, path)
	for _, fileName in pairs(tab) do
		ARACHNAMOD.Include(path .. "." .. fileName)
	end
end

local helpers = {
	"table_functions",
	"bitmask_helper",
	"maths_util",
	"misc_util",
	"players_util",
}

local tools = {
	"debug_tools",
	"pickups_tools",
	"status_effect_library",
	"throwable_item_lib"
}

local core = {
	"customhealthapi.core",
	"entity_replacements",
	"custom_callbacks"
}

local config = {
	"settings_enum",
	"settings_helper",
	"settings_setup",
	"mcm_setup",
}

ARACHNAMOD.Spawn = include("scripts.helpers.spawn")
ARACHNAMOD.Foreach = include("scripts.helpers.for_each")

Mod.LoopInclude(tools, "scripts.tools")
Mod.LoopInclude(helpers, "scripts.helpers")
Mod.LoopInclude(core, "scripts.arachna.core")
Mod.LoopInclude(config, "scripts.arachna.config")
--Mod.Include("scripts.ARACHNAMOD.api")

ARACHNAMOD.CHAPI_ID = "ArachnaMOD"
if CustomHealthAPI and CustomHealthAPI.Library and CustomHealthAPI.Library.UnregisterCallbacks then
	CustomHealthAPI.Library.UnregisterCallbacks(ARACHNAMOD.CHAPI_ID)
end

ARACHNAMOD.TearModifier = include("scripts/arachna/core/tear_modifier")

ARACHNAMOD.Character = {}
ARACHNAMOD.Item = {}
ARACHNAMOD.Pickup = {}
ARACHNAMOD.Card = {}
ARACHNAMOD.Trinket = {}
ARACHNAMOD.Slot = {}
ARACHNAMOD.Entities = {}
include("flags")
include("scripts.arachna.core.detect_repentogon")
include("scripts.arachna.core.save_upgrade")
if not REPENTOGON or not REPENTANCE_PLUS then
	return
end

local entities = {
	"colored_spiders",
	"spider_egg",
}

Mod.LoopInclude(entities, "scripts.arachna.entities")

local characters = {
	"web_heart",
	"arachna.arachna",
	"arachna_b.arachna_b",
	"tainted_unlock"
}

Mod.LoopInclude(characters, "scripts.arachna.characters")

local miscItems = {
	"candy_floss",
	"gummy_spiders",
	"old_shoebox",
	"spider_cake",
	"spider_donut"
}

Mod.LoopInclude(miscItems, "scripts.arachna.misc_items")

Mod.Include("scripts.arachna.unlocks.unlock_loader")

---@param player EntityPlayer
function ARACHNAMOD:HasDoubleTapped(player)
	return Mod:GetData(player).DoubleTapped or false
end

---@param player EntityPlayer
function ARACHNAMOD:HandleDoubleTap(player)
	if not player.ControlsEnabled
		or player.ControlsCooldown > 0
	then
		return
	end
	local ctrlIndex = player.ControllerIndex
	local firedLeft, firedUp, firedRight, firedDown = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, ctrlIndex),
		Input.IsActionTriggered(ButtonAction.ACTION_SHOOTUP, ctrlIndex),
		Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, ctrlIndex),
		Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN, ctrlIndex)
	local data = Mod:GetData(player)
	local fireDir
	if firedLeft then
		fireDir = Direction.LEFT
	elseif firedUp then
		fireDir = Direction.UP
	elseif firedRight then
		fireDir = Direction.RIGHT
	elseif firedDown then
		fireDir = Direction.DOWN
	end

	if data.DoubleTapped then
		data.DoubleTapped = nil
	end

	if (firedLeft or firedRight or firedUp or firedDown) then
		if not data.DoubleTapWindow or (data.DoubleTapLastDirection ~= fireDir) then
			data.DoubleTapLastDirection = fireDir
			data.DoubleTapWindow = Mod.GetSetting(Mod.Setting.DoubletapFrameWindow) + 5
		elseif data.DoubleTapWindow then
			data.DoubleTapped = true
			data.DoubleTapWindow = nil
		end
	elseif data.DoubleTapWindow and data.DoubleTapWindow > 0 then
		data.DoubleTapWindow = data.DoubleTapWindow - 1
	else
		data.DoubleTapWindow = nil
		data.DoubleTapLastDirection = nil
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Mod.HandleDoubleTap)

--!End of file

include("scripts/dead_sea_scrolls/deadseascrolls")
Mod.Include("scripts.compatibility.patches.eid.eid_support")
Mod.Include("scripts.compatibility.patches_loader")

if Mod.FileLoadError then
	Mod:Log("Mod failed to load!")
elseif Mod.InvalidPathError then
	Mod:Log("One or more files were unable to be loaded.")
else
	Mod:Log("v" .. Mod.Version .. " successfully loaded!")
end

ARACHNAMOD.Include = nil
ARACHNAMOD.LoopInclude = nil
