--#region Variables

local Mod = ARACHNAMOD

local ARACHNIDS_GRIP = {}

ARACHNAMOD.Item.ARACHNIDS_GRIP = ARACHNIDS_GRIP

ARACHNIDS_GRIP.ID = Isaac.GetItemIdByName("Arachnid's Grip")
ARACHNIDS_GRIP.FAMILIAR = Isaac.GetEntityVariantByName("Spider Egg (orbital)")
ARACHNIDS_GRIP.NULL_ITEM = Isaac.GetNullItemIdByName("arachnids grip orbitals")
ARACHNIDS_GRIP.PICKUP = Isaac.GetEntityVariantByName("Spider Egg (pickup)")

ARACHNIDS_GRIP.POISON_CHANCE = 0.25
ARACHNIDS_GRIP.ORBITAL_KILL_CHANCE = 0.20
ARACHNIDS_GRIP.DEFAULT_ORBITAL_CAP = 4
ARACHNIDS_GRIP.FLY_HEAL_CHANCE = 0.08

--#endregion

--#region Helpers

---@param player EntityPlayer
function ARACHNIDS_GRIP:GetOrbitalCap(player)
	return ARACHNIDS_GRIP.DEFAULT_ORBITAL_CAP + (player:GetCollectibleNum(ARACHNIDS_GRIP.ID) - 1)
end

---@param player EntityPlayer
function ARACHNIDS_GRIP:GetNumOrbitals(player)
	return player:GetEffects():GetNullEffectNum(ARACHNIDS_GRIP.NULL_ITEM)
end

---@param player EntityPlayer
---@param amount integer
function ARACHNIDS_GRIP:AddSpiderEggOrbital(player, amount)
	local effects = player:GetEffects()
	if amount > 0 then
		effects:AddNullEffect(ARACHNIDS_GRIP.NULL_ITEM, false, amount)
	elseif amount < 0 and effects:GetNullEffectNum(ARACHNIDS_GRIP.NULL_ITEM) > 0 then
		effects:RemoveNullEffect(ARACHNIDS_GRIP.NULL_ITEM, -amount)
	end
end

---@param familiar EntityFamiliar
function ARACHNIDS_GRIP:TryKillSpiderEgg(familiar)
	local rng = familiar:GetDropRNG()
	if rng:RandomFloat() < ARACHNIDS_GRIP.ORBITAL_KILL_CHANCE then
		local player = familiar.Player
		local spiderSubtype = 0
		if player:HasCollectible(Mod.Item.MUTAGEN.ID) then
			spiderSubtype = Mod.Entities.COLORED_SPIDERS:GetRandomSpiderSubtype(true)
		end
		Mod.Entities.COLORED_SPIDERS:ThrowColoredSpider(player, spiderSubtype, familiar.Position)
		local swirl = Mod.Item.DIVINE_CLOTH:SpawnSwirl(familiar.Position, familiar)
		swirl.PositionOffset = Vector(0, -25* familiar.SpriteScale.Y)
		Mod.Game:SpawnParticles(familiar.Position, EffectVariant.BLOOD_PARTICLE, Mod:RandomNum(3, 4), 4, Color(1, 1, 1, 1, 1, 1, 1))
		Mod.sfxman:Play(SoundEffect.SOUND_BOIL_HATCH)
		familiar:Die()
		ARACHNIDS_GRIP:AddSpiderEggOrbital(player, -1)
	end
end

--#endregion

--#region Pickup

---@param pickup EntityPickup
function ARACHNIDS_GRIP:OnPickupInit(pickup)
	local sprite = pickup:GetSprite()
	local rng = RNG(pickup.InitSeed)
	sprite:ReplaceSpritesheet(0, "gfx/familiars/egg_orbital_" .. tostring(rng:RandomInt(4)+1) .. ".png", true)
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, ARACHNIDS_GRIP.OnPickupInit, ARACHNIDS_GRIP.PICKUP)

---@param pickup EntityPickup
---@param collider Entity
function ARACHNIDS_GRIP:OnPickupCollision(pickup, collider)
	local player = collider:ToPlayer()
	if player and ARACHNIDS_GRIP:GetNumOrbitals(player) < ARACHNIDS_GRIP:GetOrbitalCap(player) then
		pickup:Die()
		pickup:GetSprite():Play("Collect", true)
		pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		pickup:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		Mod.sfxman:Play(SoundEffect.SOUND_SUMMON_POOF)
		ARACHNIDS_GRIP:AddSpiderEggOrbital(player, 1)
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, ARACHNIDS_GRIP.OnPickupCollision, ARACHNIDS_GRIP.PICKUP)

---@param pickup EntityPickup
function ARACHNIDS_GRIP:OnPickupUpdate(pickup)
	local sprite = pickup:GetSprite()

	if sprite:IsEventTriggered("DropSound") then
		Mod.sfxman:Play(SoundEffect.SOUND_FETUS_JUMP, 1, 2, false, 3)
	end

	if sprite:IsFinished("Collect") then
		pickup:Remove()
	end

	if Mod.Room():IsClear() then
		Mod.Item.DIVINE_CLOTH:SpawnSwirl(pickup.Position, pickup)
		Mod.Game:SpawnParticles(pickup.Position, EffectVariant.BLOOD_PARTICLE, Mod:RandomNum(3, 5), 4, Color(1, 1, 1, 1, 1, 1, 1))
		Mod.sfxman:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.8, 2, false, 1.25)
		pickup:Remove()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, ARACHNIDS_GRIP.OnPickupUpdate, ARACHNIDS_GRIP.PICKUP)

---@param npc EntityNPC
function ARACHNIDS_GRIP:OnEnemyKill(npc)
	if npc:IsActiveEnemy(true) and not npc:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN) and npc.SpawnerType == EntityType.ENTITY_NULL then
		local rng = npc:GetDropRNG()
		local roll = rng:RandomFloat()

		--Try to spawn a spider egg orbital
		if roll < ARACHNIDS_GRIP.ORBITAL_KILL_CHANCE then
			Mod.sfxman:Play(SoundEffect.SOUND_SPIDER_SPIT_ROAR, 0.8)
			Mod.Spawn.Pickup(ARACHNIDS_GRIP.PICKUP, 0, npc.Position, nil, npc, rng:Next())
		end

		--Killing flies can heal you
		if Mod:HasBitFlags(npc:GetEntityConfigEntity():GetEntityTags(), EntityTag.FLY)
			and rng:RandomFloat() < ARACHNIDS_GRIP.FLY_HEAL_CHANCE
		then
			Mod.Foreach.Player(function (player, index)
				if player:HasCollectible(ARACHNIDS_GRIP.ID) then
					player:AddHearts(2)
					Mod.Spawn.Notification(player.Position, 0, true)
				end
			end)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, ARACHNIDS_GRIP.OnEnemyKill)

--#endregion

--#region Orbital

---@param familiar EntityFamiliar
---@param collider Entity
function ARACHNIDS_GRIP:OnOrbitalBlockProjectile(familiar, collider)
	if collider:ToProjectile() then
		ARACHNIDS_GRIP:TryKillSpiderEgg(familiar)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_COLLISION, ARACHNIDS_GRIP.OnOrbitalBlockProjectile, ARACHNIDS_GRIP.FAMILIAR)

---@param ent Entity
---@param source EntityRef
function ARACHNIDS_GRIP:OnOrbitalDealDamage(ent, amount, flags, source, countdown)
	local familiar = source.Entity and source.Entity:ToFamiliar()
	if familiar
		and familiar.Variant == ARACHNIDS_GRIP.FAMILIAR
		and ent:ToNPC()
		and ent:IsActiveEnemy()
	then
		ARACHNIDS_GRIP:TryKillSpiderEgg(familiar)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, ARACHNIDS_GRIP.OnOrbitalDealDamage)

---@param familiar EntityFamiliar
function ARACHNIDS_GRIP:OrbitalInit(familiar)
	local rng = RNG(familiar.InitSeed)
	local sprite = familiar:GetSprite()
	familiar:AddToOrbit(7)
	sprite:ReplaceSpritesheet(0, "gfx/familiars/egg_orbital_" .. tostring(rng:RandomInt(4)+1) .. ".png", true)
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, ARACHNIDS_GRIP.OrbitalInit, ARACHNIDS_GRIP.FAMILIAR)

---@param familiar EntityFamiliar
function ARACHNIDS_GRIP:OrbitalUpdate(familiar)
	familiar.Velocity = familiar:GetOrbitPosition(familiar.Player.Position) - familiar.Position
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, ARACHNIDS_GRIP.OrbitalUpdate, ARACHNIDS_GRIP.FAMILIAR)

---@param player EntityPlayer
function ARACHNIDS_GRIP:OrbitalFamiliarCache(player)
	local num = player:GetEffects():GetNullEffectNum(ARACHNIDS_GRIP.NULL_ITEM)
	local rng = player:GetCollectibleRNG(ARACHNIDS_GRIP.ID)
	rng:Next()

	player:CheckFamiliar(ARACHNIDS_GRIP.FAMILIAR, num, rng)
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ARACHNIDS_GRIP.OrbitalFamiliarCache, CacheFlag.CACHE_FAMILIARS)

--#endregion

--#region Poison Tears

---@param player EntityPlayer
---@param tearParams TearParams
function ARACHNIDS_GRIP:PosionTears(player, tearParams, weaponType, damageScale, tearDisplacement, source)
	if player:HasCollectible(ARACHNIDS_GRIP.ID)
		and player:GetCollectibleRNG(ARACHNIDS_GRIP.ID):RandomFloat() < ARACHNIDS_GRIP.POISON_CHANCE
	then
		tearParams.TearFlags = Mod:AddBitFlags(tearParams.TearFlags, TearFlags.TEAR_POISON)
		tearParams.TearColor = Color.TearCommonCold
		return tearParams
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, ARACHNIDS_GRIP.PosionTears)

--#endregion