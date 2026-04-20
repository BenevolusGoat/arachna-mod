local Mod = ArachnaMod
local COLORED_SPIDERS = Mod.Entities.COLORED_SPIDERS

local DURATION = 75
local DURATION_BIG = 150
local SLOW_VALUE = 0.5
local COLOR = StatusEffectLibrary.StatusColor.SLOW

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
	ent:AddSlowing(EntityRef(player), duration, SLOW_VALUE, COLOR)
end

Mod:AddCallback(Mod.ModCallbacks.POST_ENEMY_TAKE_DMG_FROM_SPIDER, postEnemyTakeDmgFromSpider, COLORED_SPIDERS.SpiderSubtype.FAMINE)
