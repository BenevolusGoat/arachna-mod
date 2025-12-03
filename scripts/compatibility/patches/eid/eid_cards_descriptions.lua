local Mod = ARACHNAMOD
local ARC_EID = Mod.EID_Support
local DD = ARC_EID.DynamicDescriptions

local currentList = 1

local modifiers = {
	[Mod.Card.SOUL_OF_ARACHNA.ID] = {
		_metadata = { 6, true }
	},
	[Mod.Card.MERGED_CARD.ID] = {
		_metadata = { 6, false },
		_modifier = function(descObj, noTabDesc, tabDesc, descriptions)
			if not EID.holdTabPlayer then
				return noTabDesc
			end
			local maxNum = #descriptions
			if Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, EID.holdTabPlayer.ControllerIndex) then
				currentList = currentList - 1
			elseif Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, EID.holdTabPlayer.ControllerIndex) then
				currentList = currentList + 1
			end
			if currentList < 1 then
				currentList = maxNum
			elseif currentList > maxNum then
				currentList = 1
			end

			tabDesc = tabDesc:format(currentList, maxNum)
			return tabDesc .. "#" .. descriptions[currentList]
		end
	},
	[Mod.Card.MERGED_CARD_REVERSED.ID] = {
		_metadata = { 6, false },
	},
}

local descriptions = {
	en_us = Mod.Include("scripts.compatibility.patches.eid.eid_cards.cards_en_us")(modifiers),
	pl = Mod.Include("scripts.compatibility.patches.eid.eid_cards.cards_pl")(modifiers),
	ru = Mod.Include("scripts.compatibility.patches.eid.eid_cards.cards_ru")(modifiers),
	zh_cn = Mod.Include("scripts.compatibility.patches.eid.eid_cards.cards_zh_cn")(modifiers),
}

local allDescData = {}
for lang, desc in pairs(descriptions) do
	for cardID, data in pairs(desc) do
		allDescData[cardID] = allDescData[cardID] or {}
		if modifiers[cardID] then
			Mod:AddToDictionary(allDescData[cardID], modifiers[cardID])
		end
		allDescData[cardID][lang] = data
	end
end

for id, cardDescData in pairs(allDescData) do
	for language, descData in pairs(cardDescData) do
		if language:match('^_') then goto continue end -- skip helper private fields

		local name = descData.Name
		local description = descData.Description
		local metadata = cardDescData._metadata

		if not DD:IsValidDescription(description) then
			Mod:Log("Invalid card description for " .. name .. " (" .. id .. ")", "Language: " .. language)
			goto continue
		end

		local minimized = DD:MakeMinimizedDescription(description)

		if not DD:ContainsFunction(minimized) and not cardDescData._AppendToEnd then
			EID:addCard(id, table.concat(minimized, ""), name, language)
		else
			-- don't add descriptions for vanilla cards that already have one
			if not EID.descriptions[language].cards[id] then
				EID:addCard(id, "", name, language) -- description only contains name/language, the actual description is generated at runtime
			end

			DD:SetCallback(DD:CreateCallback(minimized, cardDescData._AppendToEnd), EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_TAROTCARD, id, language)
		end

		if metadata then
			EID:addCardMetadata(id, metadata[1], metadata[2])
		end

		::continue::
	end
end

EID:addDescriptionModifier(
	"Arachna Merged Card",
	-- condition
	---@param descObj EID_DescObj
	function(descObj)
		if descObj.ObjVariant == PickupVariant.PICKUP_TAROTCARD
			and (
				descObj.ObjSubType == Mod.Card.MERGED_CARD.ID
			or descObj.ObjSubType == Mod.Card.MERGED_CARD_REVERSED.ID
		) and EID.holdTabCounter >= 30 then
			EID.TabDescThisFrame = true
			return true
		end
	end,
	-- modifier
	function(descObj)
		--Description modifier is handled within the cards_en_us.lua file
		return descObj
	end
)