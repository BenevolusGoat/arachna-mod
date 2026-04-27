local Mod = ArachnaMod
local ARC_EID = Mod.EID_Support
local DD = ARC_EID.DynamicDescriptions

---@type {[EntityType]: {[integer]: {[integer]:{_modifier: fun(descObj: EID_DescObj, ...: any): any}}}}
local modifiers = {
}

local descriptions = {
	en_us = Mod.Include("scripts.compatibility.patches.eid.eid_entities.entities_en_us")(modifiers),
	--pl = Mod.Include("scripts.compatibility.patches.eid.eid_entities.entities_pl")(modifiers),
	ru = Mod.Include("scripts.compatibility.patches.eid.eid_entities.entities_ru")(modifiers),
	zh_cn = Mod.Include("scripts.compatibility.patches.eid.eid_entities.entities_zh_cn")(modifiers),
	ko_kr = Mod.Include("scripts.compatibility.patches.eid.eid_entities.entities_ko_kr")(modifiers),
}

local allDescData = {}
for lang, desc in pairs(descriptions) do
	for entType, typeTable in pairs(desc) do
		allDescData[entType] = allDescData[entType] or {}
		local dataEntType = allDescData[entType]
		for entVar, varTable in pairs(typeTable) do
			dataEntType[entVar] = dataEntType[entVar] or {}
			local dataVar = dataEntType[entVar]
			for entSub, data in pairs(varTable) do
				dataVar[entSub] = dataVar[entSub] or {}
				local dataFull = dataVar[entSub]
				if modifiers[entType] and modifiers[entType][entVar] and modifiers[entType][entVar][entSub] then
					Mod:AddToDictionary(dataFull, modifiers[entType][entVar][entSub])
				end
				dataFull[lang] = data
			end
		end
	end
end

for id, variantDescData in pairs(allDescData) do
	for variant, subtypeDescData in pairs(variantDescData) do
		for subtype, entityDescData in pairs(subtypeDescData) do
			for language, descData in pairs(entityDescData) do
				if language:match('^_') then goto continue end -- skip helper private fields

				local name = descData.Name
				local description = descData.Description

				if not DD:IsValidDescription(description) then
					Mod:Log("Invalid entity description for " .. name .. " (" .. subtype .. ")", "Language: " .. language)
					goto continue
				end

				local minimized = DD:MakeMinimizedDescription(description)

				if not DD:ContainsFunction(minimized) and not entityDescData._AppendToEnd then
					EID:addEntity(id, variant, subtype, name, table.concat(minimized, ""), language)
				else
					EID:addEntity(id, variant, subtype, name, "", language) -- description only contains name/language, the actual description is generated at runtime
					DD:SetCallback(DD:CreateCallback(minimized, entityDescData._AppendToEnd), id, variant, subtype,
						language)
				end

				::continue::
			end
		end
	end
end
