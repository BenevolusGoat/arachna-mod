local Mod = ARACHNAMOD
local COLORED_SPIDERS = Mod.Entities.COLORED_SPIDERS

local DURATION = 120
local DURATION_BIG = 180

---@param _ any
---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param spider EntityFamiliar
---@param countdown integer
local function preEnemyTakeDmgFromSpider(_, ent, amount, flags, spider, countdown)
	local player = spider.Player
	if not ent:IsBoss() then
		ent:AddEntityFlags(EntityFlag.FLAG_ICE)
		return {Damage = ent.HitPoints + 1}
	else
		local isBig = COLORED_SPIDERS:IsBigSpider(spider)
		local duration = isBig and DURATION_BIG or DURATION
		ent:AddSlowing(EntityRef(player), duration, 0.5, StatusEffectLibrary.StatusColor.SLOW)
	end
end

Mod:AddCallback(Mod.ModCallbacks.PRE_ENEMY_TAKE_DMG_FROM_SPIDER, preEnemyTakeDmgFromSpider, COLORED_SPIDERS.SpiderSubtype.ICE)
