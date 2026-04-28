local Mod = ArachnaMod
local ARC_EID = Mod.EID_Support

--RedToX is not supported for some languages, hence russian and polish missing
local path = "scripts.compatibility.patches.eid.eid_extras.extras_"
local languages = {
	"en_us",
	"zh_cn",
}
local descriptions = {}
for _, language in ipairs(languages) do
	descriptions[language] = Mod.Include(path .. language)
end

for lang, desc in pairs(descriptions) do
	for dataKey, data in pairs(desc) do
		if EID.descriptions[lang][dataKey] then
			Mod:AddToDictionary(EID.descriptions[lang][dataKey], data)
		end
	end
end
