--#region Variables

local Mod = ARACHNAMOD

local ARACHNA = {}

ARACHNAMOD.Character.ARACHNA = ARACHNA

Mod.Include("scripts.arachna.characters.arachna.arachnas_spool")

ARACHNA.POISON_CHANCE = 0.25

ARACHNA.SFX_HURT = Isaac.GetSoundIdByName("Arachna Hurt")
ARACHNA.SFX_DEATH = Isaac.GetSoundIdByName("Arachna Death")
ARACHNA.SFX_HURT_RARE = Isaac.GetSoundIdByName("Arachna Hurt (Rare)")
ARACHNA.SFX_DEATH_RARE = Isaac.GetSoundIdByName("Arachna Death (Rare)")
ARACHNA.RARE_SFX_CHANCE = 0.05

CustomHealthAPI.PersistentData.CharactersThatConvertMaxHealth[Mod.PlayerType.ARACHNA] = Mod.Pickup.WEB_HEART.KEY
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

--#endregion

--#region Helpers

---@param player EntityPlayer
function ARACHNA:IsArachna(player)
	return player:GetPlayerType() == Mod.PlayerType.ARACHNA
end

---@param player EntityPlayer
function ARACHNA:ArachnaHasBirthright(player)
	return ARACHNA:IsArachna(player) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
end

--#endregion

--#region Tear sprite

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
			Mod:GetData(tear).SpiderTear = true
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, ARACHNA.SetArachnaTearSprite)

---Tear splash on grid collision
---@param tear EntityTear
function ARACHNA:TearTouchGrid(tear)
	local data = Mod:GetData(tear)
	if (tear:IsDead()) and (data.SpiderTear) then
		local tC = tear:GetSprite().Color
		if not Mod:AreColorsDifferent(tC, Color.Default) then
			tear.Color = Color(0, 0, 0, 1, 1, 1, 1)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, ARACHNA.TearTouchGrid)

---Tear splash on enemy collision
---@param tear EntityTear
---@param collider Entity
function ARACHNA:TearTouchEnemy(tear, collider)
	local data = Mod:GetData(tear)
	if data.SpiderTear and tear:IsDead() then
		local tC = tear:GetSprite().Color
		if not Mod:AreColorsDifferent(tC, Color.Default) then
			tear.Color = Color(0, 0, 0, 1, 1, 1, 1)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_COLLISION, ARACHNA.TearTouchEnemy)

--#endregion

--#region Poison Tears

---@param player EntityPlayer
---@param tearParams TearParams
function ARACHNA:PosionTears(player, tearParams, weaponType, damageScale, tearDisplacement, source)
	if Mod:IsAnyArachna(player)
		and player:GetCollectibleRNG(Mod.Item.ARACHNIDS_GRIP.ID):RandomFloat() < ARACHNA.POISON_CHANCE
	then
		tearParams.TearFlags = Mod:AddBitFlags(tearParams.TearFlags, TearFlags.TEAR_POISON)
		--tearParams.TearColor = ARACHNAMOD:IsLaserWeaponType(weaponType) and Color.LaserPoison or Color.TearCommonCold
		return tearParams
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, ARACHNA.PosionTears)

--#endregion

--#region White lasers

---@param player EntityPlayer
function ARACHNA:LaserColorCache(player)
	if Mod:IsAnyArachna(player) then
		player:SetLaserColor(Color(1, 1, 1, 1, 0, 0, 0, 5.2, 5.2, 5, 1))
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ARACHNA.LaserColorCache, CacheFlag.CACHE_TEARCOLOR)

--#endregion

--#region Ignore Cobweb slow

---@param ent Entity
---@param source EntityRef
function ARACHNA:IgnoreCobwebSlow(statusID, ent, source, duration)
	local player = ent:ToPlayer()
	if player
		and Mod:IsAnyArachna(player)
		and not Mod:IsLegacyGameplayEnabled()
		and source.Type == 0 --If it came from nothing, best we can assume is cobweb. Otherwise...oh well!
	then
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_STATUS_EFFECT_APPLY, ARACHNA.IgnoreCobwebSlow, StatusEffect.SLOWING)

--#endregion

--#region Rare Sounds

function ARACHNA:RareSoundAlt(id, volume, delay, loop, pitch, pan)
	if Mod.GetSetting(Mod.Setting.RareSoundAlt)
		and Mod:RandomNum() < ARACHNA.RARE_SFX_CHANCE
	then
		local newId = id == ARACHNA.SFX_HURT and ARACHNA.SFX_HURT_RARE or ARACHNA.SFX_DEATH_RARE
		return {newId, volume, delay, loop, pitch, pan}
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY, ARACHNA.RareSoundAlt, ARACHNA.SFX_HURT)
Mod:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY, ARACHNA.RareSoundAlt, ARACHNA.SFX_DEATH)

--#endregion