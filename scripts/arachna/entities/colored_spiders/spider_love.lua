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
local function postEnemyTakeDmgFromSpider(_, ent, amount, flags, spider, countdown)
	local player = spider.Player
	local isBig = COLORED_SPIDERS:IsBigSpider(spider)
	local duration = isBig and DURATION_BIG or DURATION
	ent:AddCharmed(EntityRef(player), duration)
end

Mod:AddCallback(Mod.ModCallbacks.POST_ENEMY_TAKE_DMG_FROM_SPIDER, postEnemyTakeDmgFromSpider, COLORED_SPIDERS.SpiderSubtype.LOVE)
