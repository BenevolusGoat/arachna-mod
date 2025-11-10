local Mod = ARACHNAMOD
local ARC_EID = Mod.EID_Support
local DD = ARC_EID.DynamicDescriptions
local Item = Mod.Item

---@type {[CollectibleType]: {_modifier: fun(descObj: EID_DescObj, ...: any): any}}
local modifiers = {
	[Item.SPIDER_CAKE.ID] = {
		_modifier = function ()
			local yearDiff = Item.SPIDER_CAKE:GetYearDifference()
			local stats = {
				Damage = 1,
				Tears = 0.33,
				Speed = 0.12,
				Range = 1, --(technically 40)
				ShotSpeed = 0.12,
				Luck = 1
			}
			for statName, statNum in pairs(stats) do
				statNum = statNum * yearDiff
				statNum = Mod.math.floor(statNum * 100) / 100
				local floored = Mod.math.floor(statNum)
				if statNum - floored < 0.001 then
					statNum = floored
				end
				stats[statName] = statNum
			end
			return stats
		end
	},
	[Item.ARACHNIDS_GRIP.ID] = {
		_modifier = function (descObj, desc)
			local player = ARC_EID:ClosestPlayerTo(descObj.Entity)
			if player:HasCollectible(Item.MUTAGEN.ID) then
				return desc
			end
		end
	}
}
local descriptions = {
	en_us = Mod.Include("scripts.compatibility.patches.eid.eid_items.items_en_us")(modifiers),
}

local allDescData = {}
for lang, desc in pairs(descriptions) do
	for itemID, data in pairs(desc) do
		allDescData[itemID] = allDescData[itemID] or {}
		if modifiers[itemID] then
			Mod:AddToDictionary(allDescData[itemID], modifiers[itemID])
		end
		allDescData[itemID][lang] = data
	end
end

for id, collectibleDescData in pairs(allDescData) do
	for language, descData in pairs(collectibleDescData) do
		if language:match('^_') then goto continue end -- skip helper private fields

		local name = descData.Name
		local description = descData.Description
		local fallbackDesc = descData.FallbackDescription

		if not DD:IsValidDescription(description) then
			Mod:Log("Invalid collectible description for " .. name .. " (" .. id .. ")", "Language: " .. language)
			goto continue
		end

		if fallbackDesc and not DD:IsValidDescription(fallbackDesc) then
			Mod:Log("Invalid collectible fallback description for " .. name .. " (" .. id .. ")",
				"Language: " .. language)
			fallbackDesc = nil
		end

		local minimized = DD:MakeMinimizedDescription(description)
		local minimizedFallback = fallbackDesc and DD:MakeMinimizedDescription(fallbackDesc)

		if not DD:ContainsFunction(minimized) and not collectibleDescData._AppendToEnd then
			EID:addCollectible(id, table.concat(minimized, ""), name, language)
		else
			-- don't add descriptions for vanilla items that already have one
			if not EID.descriptions[language].collectibles[id] then
				local desc = minimizedFallback and table.concat(minimizedFallback, "") or ""
				EID:addCollectible(id, desc, name, language) -- description only contains name/language, the actual description is generated at runtime
			end

			DD:SetCallback(DD:CreateCallback(minimized, collectibleDescData._AppendToEnd, fallbackDesc ~= nil),
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_COLLECTIBLE, id, language)
		end

		::continue::
	end
end
