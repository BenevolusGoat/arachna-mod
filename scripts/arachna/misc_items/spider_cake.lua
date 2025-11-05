local Mod = ARACHNAMOD

local SPIDER_CAKE = {}

ARACHNAMOD.Item.SPIDER_CAKE = SPIDER_CAKE

SPIDER_CAKE.ID = Isaac.GetItemIdByName("Spider Cake")

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

function SPIDER_CAKE:ShouldSpawnCake()
	return os.date("%d.%m") == "29.04"
end

function SPIDER_CAKE:GetYearDifference()
	local diff = Mod.math.max(1, tonumber(os.date("%Y")) - 2022)
	return diff
end

---@param isContinued boolean
function SPIDER_CAKE:OnGameStart(isContinued)
	local player = Isaac.GetPlayer()
	if not isContinued
		and Mod.Character.ARACHNA:IsAnyArachna(player)
	then
		local itemPos = Mod.Room():FindFreePickupSpawnPosition(Vector(140, 240))
		Mod.Spawn.Collectible(SPIDER_CAKE.ID, itemPos, player, player:GetCollectibleRNG(SPIDER_CAKE.ID):Next())
		Mod.Spawn.Poof01(0, itemPos)
		Mod.Spawn.Effect(EffectVariant.FIREWORKS, 0, itemPos)

		Mod.Level():RemoveCurses(LevelCurse.CURSE_OF_BLIND)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, SPIDER_CAKE.OnGameStart)

function SPIDER_CAKE:UpdateDescription(title, subtitle, isSticky, isCurseDisplay)
	if title == "Spider Cake" and subtitle == "Happy Arachniversary!" then
		local yearDiff = tostring(SPIDER_CAKE:GetYearDifference())
		local desc = "Happy " .. yearDiff .. ends[string.sub(yearDiff,string.len(yearDiff))] .. " Arachniversary!"
		local hud = Mod.Game:GetHUD()
		hud:ShowItemText("Spider Cake", desc, false, true)
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_ITEM_TEXT_DISPLAY, SPIDER_CAKE.UpdateDescription)

---@param player EntityPlayer
---@param itemId CollectibleType
---@param firstTime boolean
function SPIDER_CAKE:OnCollectibleAdd(itemId, charge, firstTime, slot, varData, player)
	local rng = player:GetCollectibleRNG(itemId)
	local nearPos = Mod.Room():FindFreePickupSpawnPosition(player.Position, 40)
	Mod.Spawn.Heart(Mod.Pickup.WEB_HEART.ID, nearPos, nil, player, rng:Next())
	player:GetEffects():AddCollectibleEffect(itemId, true, SPIDER_CAKE:GetYearDifference())
	if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) ~= CollectibleType.COLLECTIBLE_NULL then
		player:DropCollectible(player:GetActiveItem(ActiveSlot.SLOT_PRIMARY))
	end
	player:AddCollectible(CollectibleType.COLLECTIBLE_MYSTERY_GIFT)
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, SPIDER_CAKE.OnCollectibleAdd, SPIDER_CAKE.ID)