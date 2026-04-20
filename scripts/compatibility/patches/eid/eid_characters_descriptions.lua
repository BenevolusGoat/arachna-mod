local Mod = ArachnaMod
local ARC_EID = Mod.EID_Support
local DD = ARC_EID.DynamicDescriptions

local modifiers = {}

local descriptions = {
	en_us = Mod.Include("scripts.compatibility.patches.eid.eid_characters.characters_en_us")(modifiers),
	pl = Mod.Include("scripts.compatibility.patches.eid.eid_characters.characters_pl")(modifiers),
	ru = Mod.Include("scripts.compatibility.patches.eid.eid_characters.characters_ru")(modifiers),
	zh_cn = Mod.Include("scripts.compatibility.patches.eid.eid_characters.characters_zh_cn")(modifiers),
	ko_kr = Mod.Include("scripts.compatibility.patches.eid.eid_characters.characters_ko_kr")(modifiers),
}

local allDescData = {}
for lang, desc in pairs(descriptions) do
	for playerType, data in pairs(desc) do
		allDescData[playerType] = allDescData[playerType] or {}
		if modifiers[playerType] then
			Mod:AddToDictionary(allDescData[playerType], modifiers[playerType])
		end
		allDescData[playerType][lang] = data
	end
end

for playerId, charDescData in pairs(allDescData) do
	for lang, descData in pairs(charDescData) do
		if not DD:IsValidDescription(descData.Description) or DD:ContainsFunction(descData.Description) then
			Mod:Log("Invalid character description for " .. descData.Name, "Language: " .. lang)
		else
			EID:addCharacterInfo(playerId, table.concat(descData.Description, ""), descData.Name, lang)
		end
	end
end
