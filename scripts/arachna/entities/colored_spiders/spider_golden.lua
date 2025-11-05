local Mod = ARACHNAMOD
local COLORED_SPIDERS = Mod.Entities.COLORED_SPIDERS

local PARTICLE_SPEED = 4
local MIDAS_DURATION = 120
local MIDAS_DURATION_BIG = 180

---@param _ any
---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param spider EntityFamiliar
---@param countdown integer
local function postEnemyTakeDmgFromSpider(_, ent, amount, flags, spider, countdown)
	local player = spider.Player
	local isBig = COLORED_SPIDERS:IsBigSpider(spider)
	local duration = isBig and MIDAS_DURATION_BIG or MIDAS_DURATION
	ent:AddMidasFreeze(EntityRef(player), duration)
	Mod.Game:SpawnParticles(ent.Position, EffectVariant.COIN_PARTICLE, Mod:RandomNum(4, 7), PARTICLE_SPEED)
	Mod.sfxman:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.6)
end

Mod:AddCallback(Mod.ModCallbacks.POST_ENEMY_TAKE_DMG_FROM_SPIDER, postEnemyTakeDmgFromSpider, COLORED_SPIDERS.SpiderSubtype.GOLDEN)

COLORED_SPIDERS.SHINE_VARIANT = Isaac.GetEntityVariantByName("Golden Spider shine")
COLORED_SPIDERS.SHINE_SUBTYPE = Isaac.GetEntitySubTypeByName("Golden Spider shine")

---@param spider EntityFamiliar
local function spiderUpdate(_, spider)
	if spider.FrameCount % 4 == 0 then
		for i = 1, Mod:RandomNum(1, 3) do
			local centerPos = Vector(spider.Position.X, spider.Position.Y - 5)
			local shinePos = centerPos
			shinePos = shinePos + Vector.FromAngle(Mod:RandomNum(360)):Resized(Mod:RandomNum(5, 10))
			local goldenShine = Mod.Spawn.Effect(COLORED_SPIDERS.SHINE_VARIANT, COLORED_SPIDERS.SHINE_SUBTYPE, shinePos, nil, spider)
			goldenShine.DepthOffset = 250
			goldenShine.SpriteScale = goldenShine.SpriteScale * (Mod:RandomNum(4, 8) / 10)
			goldenShine:GetSprite().PlaybackSpeed = 1.2
			goldenShine:SetTimeout(12)
			local glow = Mod.Spawn.Effect(EffectVariant.LIGHT, 0, goldenShine.Position, nil, spider)
			glow.SpriteScale = glow.SpriteScale / 4
			glow:SetTimeout(12)
		end
	end
end

Mod:AddCallback(Mod.ModCallbacks.COLORED_SPIDER_UPDATE, spiderUpdate, COLORED_SPIDERS.SpiderSubtype.GOLDEN)

---@param effect EntityEffect
local function shineUpdate(_, effect)
	if effect.SubType == COLORED_SPIDERS.SHINE_SUBTYPE and effect.Timeout == 0 then
		effect:Remove()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, shineUpdate, COLORED_SPIDERS.SHINE_VARIANT)