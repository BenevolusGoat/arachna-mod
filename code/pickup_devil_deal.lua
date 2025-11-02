local mod = ARACHNAMOD
local arachnaChar = Isaac.GetPlayerTypeByName("Arachna", false)
local arachnaChar_b = Isaac.GetPlayerTypeByName("Arachna", true)
--4 angel chance
mod.SavedData.lastWebDeal = -2
local latestWebDeal = -2
local json = require("json")
function mod:devilWebGameStart(isContinued) 
	if isContinued then
		--get data from save
		if mod:HasData() then
			mod.SavedData = json.decode(Isaac.LoadModData(mod))
			latestWebDeal = mod.SavedData.lastWebDeal
		end
	else
		--set values to default
		for i=0, game:GetNumPlayers()-1 do
			 latestWebDeal = -2
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.devilWebGameStart)
function mod:devilWebGameExit(shouldSave) 
	if shouldSave then
		--save data
		mod.SavedData.lastWebDeal = latestWebDeal
		mod.SaveData(mod, json.encode(mod.SavedData))
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.devilWebGameExit)
function mod:devilWebGameEnd(isGameOver) 
	--clear data
	mod.SavedData.lastWebDeal = 0
	mod.SaveData(mod, json.encode(mod.SavedData))
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_END, mod.devilWebGameEnd)

--render
local function calculateArachnaDevilPrice(_itemid)
	local price = Isaac.GetItemConfig():GetCollectible(_itemid).DevilPrice
	--for items with undeclared devil price
	if price == nil then
		if Isaac.GetItemConfig():GetCollectible(_itemid).Quality >= 3 then
			price = 2
		else
			price = 1
		end
	end
	if arachnaHoldsSoul() then
		return 5 --YOUR SOUL
	elseif maxWebPrice() == 0 then
		return 4 -- THREE SOUL HEARTS
	else
		if price == 1 then
			return 1 -- ONE WEB HEART
		elseif price == 2 then
			if maxWebPrice() == 1.5 then
				return 2 --WEB HEART AND 2 SOUL HEARTS
			elseif maxWebPrice() == 2 then
				--judas tongue synergy
				if SomeoneHasTrinket(TrinketType.TRINKET_JUDAS_TONGUE) then
					return 1 -- ONE WEB HEART
				else
					return 3 -- TWO WEB HEARTS
				end
			end
		end
	end
end

local webPrice = Sprite()
webPrice:Load("gfx/price_web.anm2")
function mod:webHeartsDevilPedestal(pickup)
	if pickup.Price < 0 then
		--choose frame
		local data = pickup:GetData()
		data.itemPrice = calculateArachnaDevilPrice(pickup.SubType)
		data.renderFrame = 0
		if someoneIsArachna() then -- FOR ARACHNA
			if data.itemPrice == 1 then --ONE WEB HEART
				data.renderFrame = 5
			elseif data.itemPrice == 2 then -- WEB HEART AND 2 SOUL HEARTS
				data.renderFrame = 6
			elseif data.itemPrice == 3 then -- TWO WEB HEARTS
				data.renderFrame = 7
			elseif data.itemPrice == 4 then -- THREE SOUL HEARTS
				data.renderFrame = 3
			elseif data.itemPrice == 5 then --YOUR SOUL
				data.renderFrame = 8
			end
		else -- FOR EVERYONE
			if pickup.Price == -1 then --1 RED HEART
				data.renderFrame = 0
			elseif pickup.Price == -2 then --2 RED HEARTS
				data.renderFrame = 1
			elseif pickup.Price == -3 then --3 SOUL HEARTS
				data.renderFrame = 3
			elseif pickup.Price == -4 then --1 RED AND 2 SOUL HEARTS
				data.renderFrame = 4
			elseif pickup.Price == -6 then --YOUR SOUL
				data.renderFrame = 8
			elseif pickup.Price == -7 then --1 SOUL HEART
				data.renderFrame = 2
			end
		end
		--render
		webPrice:SetFrame("Hearts", data.renderFrame)
		webPrice:RenderLayer(0, Isaac.WorldToRenderPosition(pickup.Position, true) + Game():GetRoom():GetRenderScrollOffset())
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, mod.webHeartsDevilPedestal, 100)

--picking item up
function mod:arachnaDevilCollide(pickup,collider)
	local player = collider:ToPlayer()
	if (pickup.Price < 0) and (player) and ((player:GetPlayerType() == arachnaChar) or (player:GetPlayerType() == arachnaChar_b)) and ((mod:GetData(player).webHearts) and (mod:GetData(player).webHearts > 0)) then
		local data = pickup:GetData()
		if data.itemPrice == 1 then -- ONE WEB HEART
			addWebHearts(-1, player)
		elseif data.itemPrice == 2 then --WEB HEART AND 2 SOUL HEARTS
			addWebHearts(-1, player)
			player:AddSoulHearts(-4)
		elseif data.itemPrice == 3 then -- TWO WEB HEARTS
			addWebHearts(-2, player)
		elseif data.itemPrice == 4 then -- THREE SOUL HEARTS
			player:AddSoulHearts(-6)
		elseif data.itemPrice == 5 then --YOUR SOUL
			lose1Soul()
		end
		local item = Isaac.GetItemConfig():GetCollectible(pickup.SubType)
		if item.Type == ItemType.ITEM_ACTIVE then
			--if active item
			local playerActive = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
			if playerActive ~= 0 then
				--if player already has an active, drop it down
				local oldActive = Isaac.Spawn(5, 100, playerActive, pickup.Position, Vector(0,0), player):ToPickup()
				oldActive.Charge = player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY)
				player:RemoveCollectible(playerActive)
			end
			--player:AddCollectible(pickup.SubType)
			--player:SetActiveCharge(item.MaxCharges, ActiveSlot.SLOT_PRIMARY )
		end
		--always 
		player:QueueItem(item, item.MaxCharges, true)
		player:AddCoins(item.AddCoins)
		player:AddBombs(item.AddBombs)
		player:AddKeys(item.AddKeys)
		player:AnimateCollectible(pickup.SubType, "Pickup", "PlayerPickupSparkle")
		sfx:Play(SoundEffect.SOUND_DEVILROOM_DEAL, 1, 0, false, 1)
		game:GetHUD():ShowItemText(player, item)
		if (game:GetRoom():GetType() == RoomType.ROOM_DEVIL) then
			latestWebDeal = game:GetLevel():GetStage()
		end
		pickup:Remove()		
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.arachnaDevilCollide, 100)

--no angel if deal was picked
function mod:onNewRoom()
	local level = game:GetLevel()
	if (level:GetStage() == latestWebDeal + 1) and (game:GetRoom():IsCurrentRoomLastBoss()) then
		if (not SomeoneHasItem(CollectibleType.COLLECTIBLE_DUALITY)) and (not SomeoneHasItem(CollectibleType.COLLECTIBLE_EUCHARIST)) and (not SomeoneHasItem(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION)) then
			level:InitializeDevilAngelRoom(false, true)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onNewRoom)