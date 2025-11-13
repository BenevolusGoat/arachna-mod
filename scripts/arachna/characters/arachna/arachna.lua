local Mod = ARACHNAMOD

local ARACHNA = {}

ARACHNAMOD.Character.ARACHNA = ARACHNA

Mod.Include("scripts.arachna.characters.arachna.arachnas_spool")

ARACHNA.POISON_CHANCE = 0.25

---@param player EntityPlayer
function ARACHNA:IsArachna(player)
	return player:GetPlayerType() == Mod.PlayerType.ARACHNA
end

---@param player EntityPlayer
function ARACHNA:ArachnaHasBirthright(player)
	return ARACHNA:IsArachna(player) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
end

CustomHealthAPI.PersistentData.CharactersThatConvertMaxHealth[Mod.PlayerType.ARACHNA] = Mod.Pickup.WEB_HEART.KEY_ARACHNA
CustomHealthAPI.PersistentData.CharactersThatCantHaveRedHealth[Mod.PlayerType.ARACHNA] = true

ARACHNA.TearVariantSpritesheetPath = "gfx/projectiles/"
ARACHNA.TearVariantToSpritesheet = {
	[TearVariant.BLUE] = "tear_arachna_normal",
	[TearVariant.BLOOD] = "tear_arachna_normal",
	[TearVariant.CUPID_BLUE] = "tear_arachna_cupid",
	[TearVariant.CUPID_BLOOD] = "tear_arachna_cupid",
	[TearVariant.PUPULA] = "tear_arachna_pupula",
	[TearVariant.PUPULA_BLOOD] = "tear_arachna_pupula",
	[TearVariant.HUNGRY] = "tear_arachna_hungry",
	[TearVariant.LOST_CONTACT] = "tear_arachna_lostcontact",
}

---@param tear EntityTear
function ARACHNA:SetArachnaTearSprite(tear)
	local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
	if player
		and Mod:IsAnyArachna(player)
		and tear.CanTriggerStreakEnd
	then
		local sprite = tear:GetSprite()
		local spritesheet = ARACHNA.TearVariantToSpritesheet[tear.Variant]
		if spritesheet then
			sprite:ReplaceSpritesheet(0, ARACHNA.TearVariantSpritesheetPath .. spritesheet .. ".png", true)
			tear:GetData().spiderTear = true
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, ARACHNA.SetArachnaTearSprite)

--Poison Tears

---@param player EntityPlayer
---@param tearParams TearParams
function ARACHNA:PosionTears(player, tearParams, weaponType, damageScale, tearDisplacement, source)
	if Mod:IsAnyArachna(player)
		and player:GetCollectibleRNG(Mod.Item.ARACHNIDS_GRIP.ID):RandomFloat() < ARACHNA.POISON_CHANCE
	then
		tearParams.TearFlags = Mod:AddBitFlags(tearParams.TearFlags, TearFlags.TEAR_POISON)
		tearParams.TearColor = ARACHNAMOD:IsLaserWeaponType(weaponType) and Color.LaserPoison or Color.TearCommonCold
		return tearParams
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, ARACHNA.PosionTears)

---Tear splash on grid collision
---@param tear EntityTear
function ARACHNA:TearTouchGrid(tear)
	local data = tear:GetData()
	if (tear:IsDead()) and (data.spiderTear) then
		tear.Color = Color(0, 0, 0, 1, 1, 1, 1)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, ARACHNA.TearTouchGrid)

---Tear splash on enemy collision
---@param tear EntityTear
---@param collider Entity
function ARACHNA:TearTouchEnemy(tear, collider)
	local data = tear:GetData()
	if data.spiderTear and tear:IsDead() then
		tear.Color = Color(0, 0, 0, 1, 1, 1, 1)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_COLLISION, ARACHNA.TearTouchEnemy)

---@param ent Entity
---@param source EntityRef
function ARACHNA:IgnoreCobwebSlow(statusID, ent, source, duration)
	local player = ent:ToPlayer()
	if player
		and Mod:IsAnyArachna(player)
		and source.Type == 0 --If it came from nothing, best we can assume is cobweb. Otherwise...oh well!
	then
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_STATUS_EFFECT_APPLY, ARACHNA.IgnoreCobwebSlow, StatusEffect.SLOWING)
