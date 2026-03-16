local Mod = ARACHNAMOD
local Trinket = Mod.Trinket
local ARC_EID = Mod.EID_Support
local DD = ARC_EID.DynamicDescriptions

local modifiers = {}

local descriptions = {
	en_us = Mod.Include("scripts.compatibility.patches.eid.eid_trinkets.trinkets_en_us")(modifiers),
	pl = Mod.Include("scripts.compatibility.patches.eid.eid_trinkets.trinkets_pl")(modifiers),
	ru = Mod.Include("scripts.compatibility.patches.eid.eid_trinkets.trinkets_ru")(modifiers),
	zh_cn = Mod.Include("scripts.compatibility.patches.eid.eid_trinkets.trinkets_zh_cn")(modifiers),
}

EID:addGoldenTrinketTable(Trinket.WHITE_STRING.ID, {t = {1}})
EID:addGoldenTrinketTable(Trinket.INFESTED_PENNY.ID, {t = {20}, mults = {1.9, 2.8}})

local allDescData = {}
for lang, desc in pairs(descriptions) do
	for trinketID, data in pairs(desc) do
		allDescData[trinketID] = allDescData[trinketID] or {}
		if modifiers[trinketID] then
			Mod:AddToDictionary(allDescData[trinketID], modifiers[trinketID])
		end
		allDescData[trinketID][lang] = data
	end
end

for id, trinketDescData in pairs(allDescData) do
	for language, descData in pairs(trinketDescData) do
		if language:match('^_') then goto continue end -- skip helper private fields

		local name = descData.Name
		local description = descData.Description

		if not DD:IsValidDescription(description) then
			Mod:Log("Invalid trinket description for " .. name .. " (" .. id .. ")", "Language: " .. language)
			goto continue
		end

		local minimized = DD:MakeMinimizedDescription(description)

		if not DD:ContainsFunction(minimized) and not trinketDescData._AppendToEnd then
			EID:addTrinket(id, table.concat(minimized, ""), name, language)
		else
			-- don't add descriptions for vanilla trinkets that already have one
			if not EID.descriptions[language].trinkets[id] then
				EID:addTrinket(id, "", name, language) -- description only contains name/language, the actual description is generated at runtime
			end

			DD:SetCallback(DD:CreateCallback(minimized, trinketDescData._AppendToEnd), EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_TRINKET, id, language)
		end

		::continue::
	end
end

