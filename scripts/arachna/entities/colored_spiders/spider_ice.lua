local Mod = ARACHNAMOD
local COLORED_SPIDERS = Mod.Entities.COLORED_SPIDERS

---@param _ any
---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param spider EntityFamiliar
---@param countdown integer
local function preEnemyTakeDmgFromSpider(_, ent, amount, flags, spider, countdown)
	local player = spider.Player
	if not ent:IsBoss() then
		ent:AddIce(EntityRef(player), -1)
		return {Damage = ent.HitPoints + 1}
	else
		ent:AddSlowing(EntityRef(player), 120, 0.5, StatusEffectLibrary.StatusColor.SLOW)
	end
end

Mod:AddCallback(Mod.ModCallbacks.PRE_ENEMY_TAKE_DMG_FROM_SPIDER, preEnemyTakeDmgFromSpider, COLORED_SPIDERS.SpiderSubtype.ICE)
