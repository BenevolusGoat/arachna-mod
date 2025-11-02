local Mod = ARACHNAMOD

local ARACHNA = {}

ARACHNAMOD.Character.ARACHNA = ARACHNA

Mod.Include("scripts.arachna.characters.arachna.arachnas_spool")

---@param player EntityPlayer
function ARACHNA:IsArachna(player)
	return player:GetPlayerType() == Mod.PlayerType.ARACHNA
end

---@param player EntityPlayer
function ARACHNA:ArachnaHasBirthright(player)
	return ARACHNA:IsArachna(player) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
end

CustomHealthAPI.PersistentData.CharactersThatConvertMaxHealth[Mod.PlayerType.ARACHNA] = Mod.Pickup.WEB_HEART.KEY

---@param player EntityPlayer
function ARACHNA:IsAnyArachna(player)
	local playerType = player:GetPlayerType()
	return playerType == Mod.PlayerType.ARACHNA or playerType == Mod.PlayerType.ARACHNA_B
end

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
		and ARACHNA:IsAnyArachna(player)
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
		and ARACHNA:IsAnyArachna(player)
		and source.Type == 0 --If it came from nothing, best we can assume is cobweb. Otherwise...oh well!
	then
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_STATUS_EFFECT_APPLY, ARACHNA.IgnoreCobwebSlow, StatusEffect.SLOWING)