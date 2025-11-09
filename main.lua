InputHelper = include("scripts/helpers/vendor/inputhelper")

---@class ModReference
_G.ARACHNAMOD = RegisterMod("Arachna Mod", 1)

ARACHNAMOD.Version = "INDEV_REWRITE"

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

if CustomHealthAPI and CustomHealthAPI.Library and CustomHealthAPI.Library.UnregisterCallbacks then
	CustomHealthAPI.Library.UnregisterCallbacks("ArachnaMOD")
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
	"spider_egg",
	"colored_spiders"
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

--!End of file

include("scripts/dead_sea_scrolls/deadseascrolls")
--include("scripts/compatibility/patches/map_api/minimap_compat")
--Mod.Include("scripts.compatibility.patches.eid.eid_support")
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

-----------------------------------
--Helper Functions (thanks piber)--
-----------------------------------
--[[
function mod:GetPlayers(functionCheck, ...)

	local args = {...}
	local players = {}

	local game = Game()

	for i=1, game:GetNumPlayers() do

		local player = Isaac.GetPlayer(i-1)

		local argsPassed = true

		if type(functionCheck) == "function" then

			for j=1, #args do

				if args[j] == "player" then
					args[j] = player
				elseif args[j] == "currentPlayer" then
					args[j] = i
				end

			end

			if not functionCheck(table.unpack(args)) then

				argsPassed = false

			end

		end

		if argsPassed then
			players[#players+1] = player
		end

	end

	return players

end

function mod:GetPlayerFromTear(tear)
	for i=1, 3 do
		local check = nil
		if i == 1 then
			check = tear.Parent
		elseif i == 2 then
			check = mod:GetSpawner(tear)
		elseif i == 3 then
			check = tear.SpawnerEntity
		end
		if check then
			if check.Type == EntityType.ENTITY_PLAYER then
				return mod:GetPtrHashEntity(check):ToPlayer()
			elseif check.Type == EntityType.ENTITY_FAMILIAR and check.Variant == FamiliarVariant.INCUBUS then
				local data = mod:GetData(tear)
				data.IsIncubusTear = true
				return check:ToFamiliar().Player:ToPlayer()
			end
		end
	end
	return nil
end

function mod:GetSpawner(entity)
	if entity and entity.GetData then
		local spawnData = mod:GetSpawnData(entity)
		if spawnData and spawnData.SpawnerEntity then
			local spawner = mod:GetPtrHashEntity(spawnData.SpawnerEntity)
			return spawner
		end
	end
	return nil
end

function mod:GetSpawnData(entity)
	if entity and entity.GetData then
		local data = mod:GetData(entity)
		return data.SpawnData
	end
	return nil
end

function mod:GetPtrHashEntity(entity)
	if entity then
		if entity.Entity then
			entity = entity.Entity
		end
		for _, matchEntity in pairs(Isaac.FindByType(entity.Type, entity.Variant, entity.SubType, false, false)) do
			if GetPtrHash(entity) == GetPtrHash(matchEntity) then
				return matchEntity
			end
		end
	end
	return nil
end

function mod:GetData(entity)
	if entity and entity.GetData then
		local data = entity:GetData()
		if not data.ARACHNAMOD then
			data.ARACHNAMOD = {}
		end
		return data.ARACHNAMOD
	end
	return nil
end

function mod:Contains(list, x)
	for _, v in pairs(list) do
		if v == x then return true end
	end
	return false
end

function mod:GetRandomNumber(numMin, numMax, rng)
	if not numMax then
		numMax = numMin
		numMin = nil
	end

	rng = rng or RNG()

	if type(rng) == "number" then
		local seed = rng
		rng = RNG()
		rng:SetSeed(seed, 1)
	end

	if numMin and numMax then
		return rng:Next() % (numMax - numMin + 1) + numMin
	elseif numMax then
		return rng:Next() % numMin
	end
	return rng:Next()
end

--ripairs stuff from revel
function ripairs_it(t,i)
	i=i-1
	local v=t[i]
	if v==nil then return v end
	return i,v
end
function ripairs(t)
	return ripairs_it, t, #t+1
end

local arachnaCode = {
	include('code.customhealthapi.core'),
	include('code.chapi'),

	include('code.unlocksystem'),
	include('code._functions'),
	include('code.save-n-achievements'),
	include('code.callback_post_get_item'),

	include('code.modcompat_eid'),

	include('code.item_simplestuff'),
	include('code.pickup_webheart'),
	include('code.familiar_web_clot'),
	include('code.pickup_devil_deal'),
	include('code.character_arachna'),
	include('code.character_arachna_b'),
	include('code.familiar_spiders_of_color'),
	include('code.item_spool'),
	include('code.item_divine_cloth'),
	include('code.item_lil_arachna'),
	include('code.eff_spider_egg'),
	include('code.eff_shopkeeper_gold'),
	include('code.beggar_spiderboi'),
	include('code.item_bbb'),
	include('code.item_the_yarn'),
	include('code.item_arachnid_grips'),
	include('code.item_mech_eye'),
	include('code.item_dads_newspaper'),
	include('code.item_lastwill'),
	include('code.item_geptameron'),
	include('code.item_3dglasses'),
	include('code.item_spidercake'),
}
 ]]