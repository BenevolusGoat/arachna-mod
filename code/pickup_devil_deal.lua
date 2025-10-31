local mod = ARACHNAMOD

local arachnaChar = Isaac.GetPlayerTypeByName("Arachna", false)
local arachnaChar_b = Isaac.GetPlayerTypeByName("Arachna", true)

local webHeartPrice = {
	PRICE_ONE_WEB_HEART = -2001, 
	PRICE_WEB_AND_SOUL = -2002, 
	PRICE_TWO_WEB_HEARTS = -2003, 
	PRICE_SOUL_HEARTS = -2004, 
	PRICE_YOUR_SOUL = -2005, 
}

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
		return webHeartPrice.PRICE_YOUR_SOUL
	elseif maxWebPrice() == 0 then
		return webHeartPrice.PRICE_SOUL_HEARTS
	else
		if price == 1 then
			return webHeartPrice.PRICE_ONE_WEB_HEART
		elseif price == 2 then
			if maxWebPrice() == 1.5 then
				return webHeartPrice.PRICE_WEB_AND_SOUL
			elseif maxWebPrice() == 2 then
				--judas tongue synergy
				if SomeoneHasTrinket(TrinketType.TRINKET_JUDAS_TONGUE) then
					return webHeartPrice.PRICE_ONE_WEB_HEART
				else
					return webHeartPrice.PRICE_TWO_WEB_HEARTS
				end
			end
		end
	end
end

--spawn
function mod.arachnaDevilDealSpawn(_, pickup)
	if (someoneIsArachna()) and (pickup.Price < 0) then
		local newPrice = calculateArachnaDevilPrice(pickup.SubType)
		if pickup.Price ~= newPrice then
			pickup.Price = newPrice
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.arachnaDevilDealSpawn, 100)

--render price
local webPrice = Sprite()
webPrice:Load("gfx/price_web.anm2")
webPrice:LoadGraphics()
function mod:webHeartsDevilPedestal(pickup)
	if pickup.Price <= webHeartPrice.PRICE_ONE_WEB_HEART then
		--choose frame
		local renderFrame = 0
		if pickup.Price == webHeartPrice.PRICE_ONE_WEB_HEART then
			renderFrame = 5
		elseif pickup.Price == webHeartPrice.PRICE_WEB_AND_SOUL then 
			renderFrame = 6
		elseif pickup.Price == webHeartPrice.PRICE_TWO_WEB_HEARTS then 
			renderFrame = 7
		elseif pickup.Price == webHeartPrice.PRICE_SOUL_HEARTS then 
			renderFrame = 3
		elseif pickup.Price == webHeartPrice.PRICE_YOUR_SOUL then 
			renderFrame = 8
		end
		--render
		webPrice:SetFrame("Hearts", renderFrame)
		webPrice:RenderLayer(0, Isaac.WorldToRenderPosition(pickup.Position, true) + Game():GetRoom():GetRenderScrollOffset())
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, mod.webHeartsDevilPedestal, 100)

--picking item up
function mod:arachnaDevilCollide(pickup,collider)
	local player = collider:ToPlayer()
	if (pickup.Price <= webHeartPrice.PRICE_ONE_WEB_HEART) and (player) and ((player:GetPlayerType() == arachnaChar) or (player:GetPlayerType() == arachnaChar_b)) then
		local data = pickup:GetData()
		if pickup.Price == webHeartPrice.PRICE_ONE_WEB_HEART then
			addWebHearts(-1, player)
		elseif pickup.Price == webHeartPrice.PRICE_WEB_AND_SOUL then 
			addWebHearts(-1, player)
			player:AddSoulHearts(-4)
		elseif pickup.Price == webHeartPrice.PRICE_TWO_WEB_HEARTS then 
			addWebHearts(-2, player)
		elseif pickup.Price == webHeartPrice.PRICE_SOUL_HEARTS then 
			player:AddSoulHearts(-6)
		elseif pickup.Price == webHeartPrice.PRICE_YOUR_SOUL then 
			lose1Soul()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.arachnaDevilCollide, 100)