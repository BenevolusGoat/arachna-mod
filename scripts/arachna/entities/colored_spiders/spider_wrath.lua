local Mod = ARACHNAMOD
local COLORED_SPIDERS = Mod.Entities.COLORED_SPIDERS

local DAMAGE = 60
local DAMAGE_BIG = 100
local RADIUS_MULT = 0.3
local RADIUS_MULT_BIG = 0.5

---@param _ any
---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param spider EntityFamiliar
---@param countdown integer
local function postEnemyTakeDmgFromSpider(_, ent, amount, flags, spider, countdown)
	local player = spider.Player
	local tearParams = player:GetTearHitParams(WeaponType.WEAPON_BOMBS, 1, 1, spider)
	local isBig = COLORED_SPIDERS:IsBigSpider(spider)
	local damage = isBig and DAMAGE_BIG or DAMAGE
	local radius = isBig and RADIUS_MULT_BIG or RADIUS_MULT
	local color = Mod.Entities.SPIDER_EGG:GetEggColor(spider.SubType)
	Mod.Game:BombExplosionEffects(ent.Position, damage, tearParams.TearFlags, color, player, radius)
end

Mod:AddCallback(Mod.ModCallbacks.POST_ENEMY_TAKE_DMG_FROM_SPIDER, postEnemyTakeDmgFromSpider, COLORED_SPIDERS.SpiderSubtype.WRATH)
