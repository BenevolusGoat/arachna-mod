local mod = ARACHNAMOD
local game = ARACHNAMOD.game
local sfx = ARACHNAMOD.sfx

local spiderCake = Isaac.GetItemIdByName("Spider Cake")
local cakeSpawn = false --manual toggle for debug/workshop updates

local function shouldSpawnCake()
	if ARACHNAMOD.luadebug then
		if os.date("%d.%m") == "29.04" then
			return true
		end
	end
	return cakeSpawn
end

--spawn item
function mod:spiderCakeSpawn(isContinued) 
	if (not isContinued) and (not game:IsGreedMode()) and (someoneIsArachna()) and (shouldSpawnCake()) then
		--spawn item
		local itemPos = Vector(140, 240)
		Isaac.Spawn(5, 100, spiderCake, itemPos, Vector(0,0), nil)
		Isaac.Spawn(1000, 15, 0, itemPos, Vector(0,0), nil)
		--fireworks
		for i=1, mod:GetRandomNumber(5, 8, mod.Globals.garbageRNG) do
			Isaac.Spawn(1000, 104, 0, itemPos, Vector(0,0), nil)
		end 
		--can always see the item
		game:GetLevel():RemoveCurses(LevelCurse.CURSE_OF_BLIND)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.spiderCakeSpawn)

--collision
local ends = {
	["0"] = "th", 
	["1"] = "st", 
	["2"] = "nd", 
	["3"] = "rd", 
	["4"] = "th", 
	["5"] = "th", 
	["6"] = "th", 
	["7"] = "th", 
	["8"] = "th", 
	["9"] = "th", 
}
function mod.spiderCakeTouch(_, pickup, collider)
	if (pickup.SubType == spiderCake) and (collider.Type == EntityType.ENTITY_PLAYER) then
		local player = collider:ToPlayer()
		local cakeConfig = Isaac.GetItemConfig():GetCollectible(spiderCake)
		player:QueueItem(cakeConfig, 0, false, false, 0)
		--visual
		local desc = "Happy Arachniversary!"
		if ARACHNAMOD.luadebug then
			local str = tostring(mod.Globals.yearDiff)
			desc = "Happy " .. str .. ends[string.sub(str,string.len(str))] .. " Arachniversary!"
		end
		local hud = game:GetHUD()
		hud:ShowItemText("Spider Cake", desc)

		player:AnimateCollectible(spiderCake, "Pickup", "PlayerPickupSparkle")
		game:ShakeScreen(8)
		sfx:Play(SoundEffect.SOUND_THUMBSUP, 0.8, 0, false, 1)
		pickup:Morph(5, 100, CollectibleType.COLLECTIBLE_MYSTERY_GIFT, true)
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.spiderCakeTouch, 100)

--cache
function mod:cacheSpidercake(player, cacheFlag)
    if player:HasCollectible(spiderCake) then
		local cakeNum = player:GetCollectibleNum(spiderCake)
        if cacheFlag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + (1*mod.Globals.yearDiff*cakeNum)
        end
        if cacheFlag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay - (1.2*mod.Globals.yearDiff*cakeNum)
        end
        if cacheFlag == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck + (1*mod.Globals.yearDiff*cakeNum)
        end
        if cacheFlag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed + (0.12*mod.Globals.yearDiff*cakeNum)
        end
        if cacheFlag == CacheFlag.CACHE_RANGE then
            player.TearRange = player.TearRange + (40*mod.Globals.yearDiff*cakeNum)
        end
        if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed + (0.12*mod.Globals.yearDiff*cakeNum)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.cacheSpidercake)

--on collect
local function collectingSpiderCake(player, item)
	local nearPos = Isaac.GetFreeNearPosition(player.Position, 25)
	Isaac.Spawn(5, 2000, 0, nearPos, Vector(0,0), player)
end
ARACHNAMOD:addPostItemGetFunction(collectingSpiderCake, spiderCake)