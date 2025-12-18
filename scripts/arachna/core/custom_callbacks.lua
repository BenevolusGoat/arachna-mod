local Mod = ARACHNAMOD

ARACHNAMOD.ModCallbacks = {
	---(EntityBomb Bomb) - Called when a bomb explodes
	POST_BOMB_EXPLODE = "ARACHNA_POST_BOMB_EXPLODE",

	---(EntityEffect Rocket) - Called when an Epic Fetus rocket explodes
	POST_ROCKET_EXPLODE = "ARACHNA_POST_ROCKET_EXPLODE",

	--(Entity Entity, number DamageAmount, Flags DamageFlags, EntityFamiliar Spider, integer CountdownFrames): See ENTITY_TAKE_DMG, Optional Arg: ColoredSpiderSubtype - Called before an enemy takes damage from a colored spider. Has the same return values as MC_ENTITY_TAKE_DMG.
	PRE_ENEMY_TAKE_DMG_FROM_SPIDER = "ARACHNA_PRE_ENEMY_TAKE_DMG_FROM_SPIDER",

	--(Entity Entity, number DamageAmount, Flags DamageFlags, EntityFamiliar Spider, integer CountdownFrames), Optional Arg: ColoredSpiderSubtype - Called after an enemy takes damage from a colored spider.
	POST_ENEMY_TAKE_DMG_FROM_SPIDER = "ARACHNA_POST_ENEMY_TAKE_DMG_FROM_SPIDER",

	--(EntityFamiliar Spider): Optional Arg: ColoredSpiderSubtype - Called on MC_FAMILIAR_UPDATE for colored spiders.
	COLORED_SPIDER_UPDATE = "ARACHNA_COLORED_SPIDER_UPDATE"
}

local function postBombExplode(_, bomb)
	if bomb:GetSprite():IsPlaying("Explode") then
		Isaac.RunCallback(Mod.ModCallbacks.POST_BOMB_EXPLODE, bomb)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, postBombExplode)

---@param effect EntityEffect
local function bombExplosionBestFriend(_, effect)
	if effect.SpawnerEntity and effect.SpawnerType == EntityType.ENTITY_BOMB and effect.SpawnerVariant == BombVariant.BOMB_DECOY then
		Isaac.RunCallback(Mod.ModCallbacks.POST_BOMB_EXPLODE, effect.SpawnerEntity)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, bombExplosionBestFriend, EffectVariant.BOMB_EXPLOSION)

local function postEpicFetusExplode(_, effect)
	if effect.Variant == EffectVariant.ROCKET and effect.PositionOffset.Y == 0 then
		Isaac.RunCallback(Mod.ModCallbacks.POST_ROCKET_EXPLODE, effect:ToEffect())
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, postEpicFetusExplode, EntityType.ENTITY_EFFECT)
