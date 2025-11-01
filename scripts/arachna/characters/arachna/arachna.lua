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

--[[ function ARACHNA:WebHeartsAreMaxHealth(player, amount, healthType, arg, ispre)
	if ARACHNA:IsArachna(player) or Mod.Character.ARACHNA_B:IsArachnaB(player) then
		print(ispre and "pre" or "post", "healthtype", healthType, "amount", amount)
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, function(_, player, amount, healthType, arg) ARACHNA:WebHeartsAreMaxHealth(player, amount, healthType, arg, true) end)
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_HEARTS, ARACHNA.WebHeartsAreMaxHealth) ]]

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
		and (ARACHNA:IsArachna(player) or Mod.Character.ARACHNA_B:IsArachnaB(player))
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

--tears on grid collision
function ARACHNA:tearTouchGrid(tear)
	local data = tear:GetData()
	if (tear:IsDead()) and (data.spiderTear) then
		tear.Color = Color(0, 0, 0, 1, 1, 1, 1)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, ARACHNA.tearTouchGrid)

--tears on enemy collision
function ARACHNA:tearTouchMob(tear, collider)
	local data = tear:GetData()
	if (data.spiderTear) then
		local npc = collider:ToNPC()
		if (not ((collider:ToNPC()) and (collider:ToNPC():HasEntityFlags(EntityFlag.FLAG_FRIENDLY)))) and (not (tear:HasTearFlags(TearFlags.TEAR_PIERCING) or tear:HasTearFlags(TearFlags.TEAR_PERSISTENT))) then
			tear.Color = Color(0, 0, 0, 1, 1, 1, 1)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, ARACHNA.tearTouchMob)
