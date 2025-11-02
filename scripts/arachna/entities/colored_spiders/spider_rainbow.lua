local Mod = ARACHNAMOD
local COLORED_SPIDERS = Mod.Entities.COLORED_SPIDERS

local BOSS_HEALTH_DIV = 8
local BOSS_HEALTH_DIV_BIG = 4

---@param _ any
---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param spider EntityFamiliar
---@param countdown integer
local function preEnemyTakeDmgFromSpider(_, ent, amount, flags, spider, countdown)
	local fart = Mod.Spawn.Effect(EffectVariant.FART, 0, spider.Position, nil, spider)
	fart:GetSprite().Color = spider:GetSprite().Color
	local glow = Mod.Spawn.Effect(EffectVariant.LIGHT, 0, fart.Position, nil, fart)
	glow:GetSprite().Color = spider:GetSprite().Color
	glow.SpriteScale = glow.SpriteScale / 2
	glow:SetTimeout(18)
	Mod.sfxman:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.8, 0, false, 1.25)

	local isBig = COLORED_SPIDERS:IsBigSpider(spider)
	local div = isBig and BOSS_HEALTH_DIV_BIG or BOSS_HEALTH_DIV

	if ent:IsBoss() then
		return {Damage = amount + (ent.HitPoints / div)}
	else
		ent:Die()
	end
end

Mod:AddCallback(Mod.ModCallbacks.PRE_ENEMY_TAKE_DMG_FROM_SPIDER, preEnemyTakeDmgFromSpider, COLORED_SPIDERS.SpiderSubtype.RAINBOW)

--[[
 * Credit to emmanuel
 * Converts an HSV color value to COLOR_CYCLE. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSV_color_space.
 * Assumes h, s, and v are contained in the set [0, 1] and
 * returns r, g, and b in the set [0, 255].
 *
 ]]
---@param h number	#Hue
---@param s number	#Saturation
---@param v number	#Value
local function hsvToRgb(h, s, v, a)
	local r, g, b

	local i = math.floor(h * 6);
	local f = h * 6 - i;
	local p = v * (1 - s);
	local q = v * (1 - f * s);
	local t = v * (1 - (1 - f) * s);

	i = i % 6

	if i == 0 then r, g, b = v, t, p
	elseif i == 1 then r, g, b = q, v, p
	elseif i == 2 then r, g, b = p, v, t
	elseif i == 3 then r, g, b = p, q, v
	elseif i == 4 then r, g, b = t, p, v
	elseif i == 5 then r, g, b = v, p, q
	end

	return r * 255, g * 255, b * 255, a * 255
end

--How the game makes rainbow for the Playdough lasers
function COLORED_SPIDERS:GetRainbowColor()
	local hue = (Game():GetFrameCount() % 30)/30
	local r, g, b = hsvToRgb(hue, 0.9, 1.0, 1.0)

	return {r/255*4, g/255*4, b/255*4, 1.0}
end

---@param spider EntityFamiliar
local function rainbowSpiderUpdate(_, spider)
	spider:GetSprite().Color:SetColorize(table.unpack(COLORED_SPIDERS:GetRainbowColor()))
end

Mod:AddCallback(Mod.ModCallbacks.COLORED_SPIDER_UPDATE, rainbowSpiderUpdate, COLORED_SPIDERS.SpiderSubtype.RAINBOW)