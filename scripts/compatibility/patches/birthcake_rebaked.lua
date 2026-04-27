local Mod = ArachnaMod
local loader = Mod.PatchesLoader

local ARACHNA
ARACHNA = {
	Name = {
		en_us = "Arachna's"
	},
	PickupQuote = {
		en_us = "Infested!"
	},
	AccurateBlurb = {
		en_us = "Eggs and bosses spawn spiders"
	},
	EIDDesc = {
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
		en_us = {
			function(descObj)
				return ARACHNA.EIDDesc._modifier(descObj,
					"Spider Eggs spawn %s every 2 seconds"
					 .. "#Webbed bosses spawn %s every second",
				"a friendly spider", "%s friendly spiders")
			end
		}
	},
	SpriteName = "gfx/items/trinkets/birthcake_arachna.png"
}

local ARACHNA_B
ARACHNA_B = {
	Title = {
		en_us = "The Wretched's"
	},
	Name = {
		en_us = "Tainted Arachna's"
	},
	PickupQuote = {
		en_us = "Ensnare Aggression UP!"
	},
	AccurateBlurb = {
		en_us = "Double-tap is faster and shoots tears"
	},
	EIDDesc = {
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
		en_us = {
			function(descObj)
				return ARACHNA_B.EIDDesc._modifier(descObj,
					"Double-tap attack is %s",
					"faster"
				)
			end,
			"# Double-tap attack shoots extra tears around you that can sometimes be {{Collectible" .. CollectibleType.COLLECTIBLE_PARASITOID .. "}} egg sacks",
			"#{{Luck}} 50% chance at 5 luck"
		}
	},
	SpriteName = "gfx/items/trinkets/birthcake_arachna_b.png"
}

local function birthcakePatch()
	local api = BirthcakeRebaked.API
	api:AddBirthcakePickupText(Mod.PlayerType.ARACHNA, ARACHNA.PickupQuote, ARACHNA.Name)
	api:AddAccurateBlurbcake(Mod.PlayerType.ARACHNA, ARACHNA.AccurateBlurb)
	api:AddBirthcakeSprite(Mod.PlayerType.ARACHNA, { SpritePath = ARACHNA.SpriteName })
	api:AddEIDDescription(Mod.PlayerType.ARACHNA, ARACHNA.EIDDesc)

	api:AddTaintedBirthcakePickupText(Mod.PlayerType.ARACHNA_B, ARACHNA_B.PickupQuote, Mod.PlayerType.ARACHNA,
		ARACHNA_B.Name, ARACHNA_B.Title)
	api:AddAccurateBlurbcake(Mod.PlayerType.ARACHNA_B, ARACHNA_B.AccurateBlurb)
	api:AddBirthcakeSprite(Mod.PlayerType.ARACHNA_B, { SpritePath = ARACHNA_B.SpriteName })
	api:AddEIDDescription(Mod.PlayerType.ARACHNA_B, ARACHNA_B.EIDDesc)
end

loader:RegisterPatch("BirthcakeRebaked", birthcakePatch)
