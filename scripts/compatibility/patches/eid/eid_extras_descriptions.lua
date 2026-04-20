local Mod = ArachnaMod
local ARC_EID = Mod.EID_Support

--RedToX is not supported for some languages, hence russian and polish missing
local descriptions = {
	en_us = Mod.Include("scripts.compatibility.patches.eid.eid_extras.extras_en_us"),
	zh_cn = Mod.Include("scripts.compatibility.patches.eid.eid_extras.extras_en_us"),
}

for lang, desc in pairs(descriptions) do
	for dataKey, data in pairs(desc) do
		if EID.descriptions[lang][dataKey] then
			Mod:AddToDictionary(EID.descriptions[lang][dataKey], data)
		end
	end
end
