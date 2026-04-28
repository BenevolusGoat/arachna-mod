local Mod = ArachnaMod
local loader = Mod.PatchesLoader

local modifiers = {
	[Mod.PlayerType.ARACHNA] = {
		_modifier = function(descObj, str, noMultStr, multStr)
			local player = Mod.EID_Support:ClosestPlayerTo(descObj.Entity)
			local mult = Mod.EID_Support:TrinketMulti(player, descObj.ObjSubType)
			if mult > 1 then
				local multStr = "{{ColorGold}}" .. mult .. "{{CR}}"
				str = string.format(str, multStr, multStr)
				str = string.format(str, multStr, multStr)
			else
				str = string.format(str, noMultStr, noMultStr)
			end
			return str
		end,
		_sprite = "gfx/items/trinkets/birthcake_arachna.png"
	},
	[Mod.PlayerType.ARACHNA_B] = {
		_modifier = function(descObj, str)
			local player = Mod.EID_Support:ClosestPlayerTo(descObj.Entity)
			local mult = Mod.EID_Support:TrinketMulti(player, descObj.ObjSubType)
			local chance = math.floor((0.33 + (0.15 * (mult - 1))) * 100)
			if mult > 1 then
				str = string.format(str, "{{ColorGold}}" .. chance .. "%{{CR}} ")
			else
				str = string.format(str, chance .. "%")
			end
			return str
		end,
		_sprite = "gfx/items/trinkets/birthcake_arachna_b.png"
	},
}

local path = "scripts.compatibility.patches.eid.eid_birthcakes.birthcakes_"
local languages = {
	"en_us",
	"zh_cn",
	"uk_ua"
}
local descriptions = {}
for _, language in ipairs(languages) do
	descriptions[language] = Mod.Include(path .. language)(modifiers)
end

local allDescData = {}
for lang, desc in pairs(descriptions) do
	for playerType, data in pairs(desc) do
		allDescData[playerType] = allDescData[playerType] or {}
		for key, val in pairs(data) do
			allDescData[playerType][key] = allDescData[playerType][key] or {}
			allDescData[playerType][key][lang] = allDescData[playerType][key][lang] or {}
			Mod:AddToDictionary(allDescData[playerType][key], {[lang] = val})
			if modifiers[playerType] and key == "EIDDesc" then
				Mod:AddToDictionary(allDescData[playerType][key], modifiers[playerType])
			end
		end
	end
end

local function birthcakePatch()
	local api = BirthcakeRebaked.API
	for playerType, data in pairs(allDescData) do
		if data.Title then
			api:AddTaintedBirthcakePickupText(playerType, data.PickupQuote, Mod.PlayerType.ARACHNA, data.Name, data.Title)
		else
			api:AddBirthcakePickupText(playerType, data.PickupQuote, data.Name)
		end
		api:AddAccurateBlurbcake(playerType, data.AccurateBlurb)
		api:AddBirthcakeSprite(playerType, { SpritePath = data.EIDDesc._sprite })
		api:AddEIDDescription(playerType, data.EIDDesc)
	end

	local function reverseUkrainianOrder(_, _, name)
		local lang = BirthcakeRebaked:GetLanguage()
		if lang == "uk_ua" then
			name = string.gsub(name, BirthcakeRebaked.BirthcakeOneLiners.CAKE[lang] .. " ", "")
			return name .. " " .. BirthcakeRebaked.BirthcakeOneLiners.CAKE[lang]
		end
	end

	Mod:AddCallback(BirthcakeRebaked.ModCallbacks.GET_BIRTHCAKE_ITEMTEXT_NAME, reverseUkrainianOrder, Mod.PlayerType.ARACHNA)
	Mod:AddCallback(BirthcakeRebaked.ModCallbacks.GET_BIRTHCAKE_ITEMTEXT_NAME, reverseUkrainianOrder, Mod.PlayerType.ARACHNA_B)
end

loader:RegisterPatch("BirthcakeRebaked", birthcakePatch)
