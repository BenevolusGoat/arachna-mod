local Mod = ArachnaMod
local loader = Mod.PatchesLoader

local modifiers = {
	[Mod.PlayerType.ARACHNA] = {
		_modifier = function(descObj, str, noMultStr, multStr)
			local player = Mod.EID_Support:ClosestPlayerTo(descObj.Entity)
			local mult = Mod.EID_Support:TrinketMulti(player, descObj.ObjSubType)
			if mult > 1 then
				mult = "{{ColorGold}}" .. mult .. "{{CR}}"
				str = string.format(str, multStr, multStr)
				str = string.format(str, mult, mult)
			else
				str = string.format(str, noMultStr, noMultStr)
			end
			return str
		end,
		_sprite = "gfx/items/trinkets/birthcake_arachna.png"
	},
	[Mod.PlayerType.ARACHNA_B] = {
		_modifier = function(descObj, str, faster)
			local player = Mod.EID_Support:ClosestPlayerTo(descObj.Entity)
			local mult = Mod.EID_Support:TrinketMulti(player, descObj.ObjSubType)
			local chance = math.floor((0.33 + (0.15 * (mult - 1))) * 100)
			if mult > 1 then
				str = string.format(str, "{{ColorGold}}" .. chance .. "{{CR}}")
			else
				str = string.format(str, chance)
			end
			return str .. "% " .. faster
		end,
		_sprite = "gfx/items/trinkets/birthcake_arachna_b.png"
	},
}

local descriptions = {
	en_us = Mod.Include("scripts.compatibility.patches.eid.eid_birthcakes.birthcakes_en_us")(modifiers),
	zh_cn = Mod.Include("scripts.compatibility.patches.eid.eid_birthcakes.birthcakes_zh_cn")(modifiers),
}

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
end

loader:RegisterPatch("BirthcakeRebaked", birthcakePatch)
