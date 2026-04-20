local Mod = ArachnaMod

local LIL_ARACHNA = {}

ArachnaMod.Item.LIL_ARACHNA = LIL_ARACHNA

LIL_ARACHNA.ID = Isaac.GetItemIdByName("Lil Arachna")
LIL_ARACHNA.FAMILIAR = Isaac.GetEntityVariantByName("Lil Arachna")

LIL_ARACHNA.WEB_CHANCE = 0.25
LIL_ARACHNA.WEB_DURATION = 150

---@param tear EntityTear
function LIL_ARACHNA:FireTear(tear)
	local familiar = tear.SpawnerEntity and tear.SpawnerEntity:ToFamiliar()
	if not familiar then return end
	local rng = familiar:GetDropRNG()
	local roll = rng:RandomFloat()
	local chance = LIL_ARACHNA.WEB_CHANCE

	if roll < chance then
		Mod:GetData(tear).LilArachnaBite = true
	end

	local c = tear.Color
	if c.R == 1 and c.G == 1 and c.B == 1 then
		tear.Color = Color(2, 2, 2, 1, 0.196, 0.196, 0.196)
	end
	tear:AddTearFlags(TearFlags.TEAR_SLOW | TearFlags.TEAR_QUADSPLIT)
end

Mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_FIRE_PROJECTILE, LIL_ARACHNA.FireTear, LIL_ARACHNA.FAMILIAR)

---@param familiar EntityFamiliar
function LIL_ARACHNA:OnFamiliarUpdate(familiar)
	familiar:Shoot()
	familiar:FollowParent()
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, LIL_ARACHNA.OnFamiliarUpdate, LIL_ARACHNA.FAMILIAR)

--#endregion

--#region Apply Bite on hit

function LIL_ARACHNA:ApplyBite(npc, pos, flags, source, damage)
	if Mod.TearModifier:IsValidEnemyTarget(npc) then
		local data = Mod:TryGetData(source)
		local familiar = source.SpawnerEntity and source.SpawnerEntity:ToFamiliar()
		if familiar and familiar.Player and data and data.LilArachnaBite then
			Mod.Item.ARACHNAS_SPOOL:ApplyWebbed(npc, source, LIL_ARACHNA.WEB_DURATION)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_APPLY_TEARFLAG_EFFECTS, LIL_ARACHNA.ApplyBite)

--#endregion

--#region Familiar setup

---@param familiar EntityFamiliar
function LIL_ARACHNA:MakeFollower(familiar)
	familiar:AddToFollowers()
	familiar:GetSprite():Play("FloatDown")
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, LIL_ARACHNA.MakeFollower, LIL_ARACHNA.FAMILIAR)

---@param player EntityPlayer
function LIL_ARACHNA:HandleCache(player)
	local num = player:GetCollectibleNum(LIL_ARACHNA.ID) +
		player:GetEffects():GetCollectibleEffectNum(LIL_ARACHNA.ID)
	local rng = player:GetCollectibleRNG(LIL_ARACHNA.ID)
	rng:Next()

	player:CheckFamiliar(LIL_ARACHNA.FAMILIAR, num, rng, Mod.ItemConfig:GetCollectible(LIL_ARACHNA.ID))
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, LIL_ARACHNA.HandleCache, CacheFlag.CACHE_FAMILIARS)

Mod:AddCallback(ModCallbacks.MC_GET_FOLLOWER_PRIORITY, function()
	return FollowerPriority.SHOOTER
end, LIL_ARACHNA.FAMILIAR)
