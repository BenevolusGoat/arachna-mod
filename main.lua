--InputHelper = include("scripts/helpers/vendor/inputhelper")

---@class ModReference
_G.ArachnaMod = RegisterMod("Arachna Mod", 1)

ArachnaMod.Version = "2.1.2"

local Mod = ArachnaMod

ArachnaMod.SaveManager = include("scripts.tools.save_manager")
ArachnaMod.SaveManager.Init(Mod)

ArachnaMod.sfxman = SFXManager()
ArachnaMod.Game = Game()
ArachnaMod.Room = function() return Mod.Game:GetRoom() end
ArachnaMod.Level = function() return Mod.Game:GetLevel() end
ArachnaMod.ItemConfig = Isaac.GetItemConfig()

ArachnaMod.GENERIC_RNG = RNG()

ArachnaMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
	local seed = ArachnaMod.Game:GetSeeds():GetStartSeed()
	ArachnaMod.GENERIC_RNG:SetSeed(seed, 35)
	if Mod.ShowNewPopup then
		if REPENTOGON and REPENTANCE_PLUS then
			DeadSeaScrollsMenu.QueueMenuOpen("Arachna", "arachnapopup", 0, true)
		else
			DeadSeaScrollsMenu.QueueMenuOpen("Arachna", "rgonpopup", 0, true)
		end
		Mod.ShowNewPopup = nil
	end
end)

include("scripts.arachna.core.save_upgrade")
include("scripts.dead_sea_scrolls.deadseascrolls")
include("scripts.arachna.core.customhealthapi.core")
Mod.SaveManager.InitCHAPI(CustomHealthAPI)

if not REPENTOGON or not REPENTANCE_PLUS then
	local msg =
	"[Arachna] Mod dependencies not detected! Please ensure you're playing on the official Repentance+ DLC on Steam and have the latest version of REPENTOGON, which can be found on repentogon.com"
	print(msg)
	Isaac.DebugString(msg)
	Mod.ShowNewPopup = true

	return
end

ArachnaMod.RANGE_BASE_MULT = 40

---A little optimization for storing the variables locally as opposed to calling upon them each time
ArachnaMod.math = {
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

ArachnaMod.PlayerType = {
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
function ArachnaMod:GetData(ent)
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
function ArachnaMod:TryGetData(ent)
	local ptrHash = GetPtrHash(ent)
	return getData[ptrHash]
end

ArachnaMod:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, CallbackPriority.LATE, function(_, ent)
	if not ent:ToNPC() then
		getData[GetPtrHash(ent)] = nil
	end
end)

ArachnaMod:AddPriorityCallback(ModCallbacks.MC_POST_NPC_DEATH, CallbackPriority.LATE, function(_, ent)
	getData[GetPtrHash(ent)] = nil
end)

ArachnaMod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.LATE, function(_, ent)
	for ptrHash, entityData in pairs(getData) do
		local entityPointer = (entityData and entityData.Pointer)
		if not (entityPointer and entityPointer.Ref) then
			getData[ptrHash] = nil
		end
	end
end)

local legacyEnabled = false

---@param player EntityPlayer
function ArachnaMod:IsAnyArachna(player)
	local playerType = player:GetPlayerType()
	return playerType == Mod.PlayerType.ARACHNA or playerType == Mod.PlayerType.ARACHNA_B
end

function ArachnaMod:IsLegacyGameplayEnabled()
	return legacyEnabled
end

function ArachnaMod:EveryoneIsArachna()
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

function ArachnaMod:AnyoneIsArachna()
	return PlayerManager.AnyoneIsPlayerType(Mod.PlayerType.ARACHNA) or
		PlayerManager.AnyoneIsPlayerType(Mod.PlayerType.ARACHNA_B)
end

function ArachnaMod:UpdateLegacyGameplay()
	local run_save = Mod.SaveManager.GetRunSave()
	if Mod.Game:GetFrameCount() <= 0 then
		run_save.ArachnaLegacyGameplay = Mod.GetSetting(Mod.Setting.LegacyGameplay)
	end
	legacyEnabled = run_save.ArachnaLegacyGameplay
end

Mod:AddCallback(Mod.SaveManager.SaveCallbacks.POST_GLOBAL_DATA_LOAD, ArachnaMod.UpdateLegacyGameplay)

ArachnaMod.FileLoadError = false
ArachnaMod.InvalidPathError = false

---Mimics include() but with a pcall safety wrapper and appropriate error codes if any are found
---
---VSCode users: Go to Settings > Lua > Runtime:Special and link ArachnaMod.Include to require, just like you would regular include!
---@return unknown
function ArachnaMod.Include(path)
	Isaac.DebugString("[ArachnaMOD] Loading " .. path)
	local wasLoaded, result = pcall(include, path)
	local errMsg = ""
	local foundError = false
	if not wasLoaded then
		ArachnaMod.FileLoadError = true
		foundError = true
		errMsg = 'Error in path "' .. path .. '":\n' .. result .. '\n'
	elseif result and type(result) == "string" and string.find(result, "no file '") then
		foundError = true
		ArachnaMod.InvalidPathError = true
		errMsg = 'Unable to locate file in path "' .. path .. '"\n'
	end
	if foundError then
		ArachnaMod:Log(errMsg)
	end
	return result
end

function ArachnaMod.LoopInclude(tab, path)
	for _, fileName in pairs(tab) do
		ArachnaMod.Include(path .. "." .. fileName)
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
	"entity_replacements",
	"custom_callbacks",
	"console_commands"
}

local config = {
	"settings_enum",
	"settings_helper",
	"settings_setup",
	"mcm_setup",
}

ArachnaMod.Spawn = include("scripts.helpers.spawn")
ArachnaMod.Foreach = include("scripts.helpers.for_each")

Mod.LoopInclude(tools, "scripts.tools")
Mod.LoopInclude(helpers, "scripts.helpers")
Mod.LoopInclude(core, "scripts.arachna.core")
Mod.LoopInclude(config, "scripts.arachna.config")

ArachnaMod.CHAPI_ID = "ArachnaMOD"
if CustomHealthAPI and CustomHealthAPI.Library and CustomHealthAPI.Library.UnregisterCallbacks then
	CustomHealthAPI.Library.UnregisterCallbacks(ArachnaMod.CHAPI_ID)
end

ArachnaMod.TearModifier = include("scripts/arachna/core/tear_modifier")

ArachnaMod.Character = {}
ArachnaMod.Item = {}
ArachnaMod.Pickup = {}
ArachnaMod.Card = {}
ArachnaMod.Trinket = {}
ArachnaMod.Slot = {}
ArachnaMod.Entities = {}
ArachnaMod.Misc = {}
include("flags")

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
Mod.Include("scripts.arachna.misc.floor_text")

---@param player EntityPlayer
function ArachnaMod:HasDoubleTapped(player)
	return Mod:GetData(player).DoubleTapped or false
end

---@param player EntityPlayer
function ArachnaMod:HandleDoubleTap(player)
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

Mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CallbackPriority.IMPORTANT, Mod.HandleDoubleTap)


--!End of file

local DSSUnlockManager = include("scripts.dead_sea_scrolls.dss_unlock_manager")
local unlock_catalog = include("scripts.dead_sea_scrolls.arachna_unlock_catalog")
local achievement_viewer = include("scripts.dead_sea_scrolls.dss_achievement_viewer")
local catalog = unlock_catalog(DSSUnlockManager)
DSSUnlockManager:GenerateDSSMenu(catalog)
achievement_viewer(DSSUnlockManager, Mod.DSS_DIRECTORY, catalog)

Mod.Include("scripts.compatibility.patches.eid.eid_support")
Mod.Include("scripts.compatibility.patches_loader")

if Mod.FileLoadError then
	Mod:Log("Mod failed to load!")
elseif Mod.InvalidPathError then
	Mod:Log("One or more files were unable to be loaded.")
else
	Mod:Log("v" .. Mod.Version .. " successfully loaded!")
end

ArachnaMod.Include = nil
ArachnaMod.LoopInclude = nil
