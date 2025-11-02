local Mod = ARACHNAMOD
local COLORED_SPIDERS = Mod.Entities.COLORED_SPIDERS

local DAMAGE_MULT = 2
local DAMAGE_MULT_BIG = 2.5

---@param _ any
---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param spider EntityFamiliar
---@param countdown integer
local function preEnemyTakeDmgFromSpider(_, ent, amount, flags, spider, countdown)
	local isBig = COLORED_SPIDERS:IsBigSpider(spider)
	local damageMult = isBig and DAMAGE_MULT_BIG or DAMAGE_MULT
	return {Damage = amount * damageMult}
end

Mod:AddCallback(Mod.ModCallbacks.PRE_ENEMY_TAKE_DMG_FROM_SPIDER, preEnemyTakeDmgFromSpider, COLORED_SPIDERS.SpiderSubtype.DEATH)
