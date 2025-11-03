local Mod = ARACHNAMOD

local GOLDEN_SHOPKEEPER = {}

ARACHNAMOD.Entities.GOLDEN_SHOPKEEPER = GOLDEN_SHOPKEEPER

GOLDEN_SHOPKEEPER.ID = Isaac.GetEntityVariantByName("Golden Shopkeeper")

GOLDEN_SHOPKEEPER.SPRITES_NUM = 16
GOLDEN_SHOPKEEPER.MIN_BOMBS = 3
GOLDEN_SHOPKEEPER.MAX_BOMBS = 5

---@param npc EntityNPC
function GOLDEN_SHOPKEEPER:KeeperInit(npc)
	if npc.Variant == GOLDEN_SHOPKEEPER.ID then
		local sprite = npc:GetSprite()
		local rng = npc:GetDropRNG()
		if npc.SubType == 0 then
			npc.SubType = rng:RandomInt(GOLDEN_SHOPKEEPER.SPRITES_NUM) + 1
		end
		sprite:ReplaceSpritesheet(1, "gfx/effects/goldenshopkeepers/shopkeeper-" .. tostring(npc.SubType) .. ".png", true)
		local run_save = Mod.SaveManager.GetRunSave(npc)
		if not run_save.GoldenKeeperMaxHits then
			run_save.GoldenKeeperMaxHits = Mod:RandomNum(GOLDEN_SHOPKEEPER.MIN_BOMBS, GOLDEN_SHOPKEEPER.MAX_BOMBS, npc:GetDropRNG())
			run_save.GoldenKeeperHits = run_save.GoldenKeeperMaxHits
			Mod:DebugLog("Golden Shopkeeper hits initialized. Needs", run_save.GoldenKeeperMaxHits, "hits to destroy")
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, GOLDEN_SHOPKEEPER.KeeperInit, EntityType.ENTITY_SHOPKEEPER)

---@param npc EntityNPC
function GOLDEN_SHOPKEEPER:UpdateAnimation(npc)
	local sprite = npc:GetSprite()
	if sprite:IsFinished("Bomb") then
		sprite:Play("Idle")
	elseif sprite:IsFinished("Break") then
		npc:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
	end
end

Mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, GOLDEN_SHOPKEEPER.UpdateAnimation, EntityType.ENTITY_SHOPKEEPER)

---@param npc EntityNPC
function GOLDEN_SHOPKEEPER:OnDamageEffect(npc)
	Mod.Spawn.Coin(CoinSubType.COIN_PENNY, npc.Position, EntityPickup.GetRandomPickupVelocity(npc.Position, npc:GetDropRNG(), 0))
	npc:GetSprite():Play("Bomb", true)
	Mod.Game:SpawnParticles(npc.Position, EffectVariant.COIN_PARTICLE, Mod:RandomNum(7, 14), 4)
	Mod.sfxman:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.8, 0, false, 1)
end

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function GOLDEN_SHOPKEEPER:ShopkeeperTakeDamage(ent, amount, flags, source, countdown)
	if ent.Variant == GOLDEN_SHOPKEEPER.ID then
		local npc = ent:ToNPC() ---@cast npc EntityNPC
		local run_save = Mod.SaveManager.GetRunSave(npc)
		if not Mod:HasBitFlags(flags, DamageFlag.DAMAGE_EXPLOSION) or npc:GetDamageCountdown() > 0 then
			return false
		end
		if run_save.GoldenKeeperHits and run_save.GoldenKeeperHits > 1 then
			run_save.GoldenKeeperHits = run_save.GoldenKeeperHits - 1
			GOLDEN_SHOPKEEPER:OnDamageEffect(npc)
			Mod:DebugLog(run_save.GoldenKeeperHits, "hit(s) remaining")
			return {Damage = 0, DamageFlags = flags | DamageFlag.DAMAGE_COUNTDOWN, DamageCountdown = 20}
		else
			local rng = npc:GetDropRNG()
			npc:GetSprite():Play("Break")
			if rng:RandomFloat() < 0.05 then
				Mod.Spawn.Trinket(Mod.Game:GetItemPool():GetTrinket() + TrinketType.TRINKET_GOLDEN_FLAG, npc.Position, EntityPickup.GetRandomPickupVelocity(npc.Position, rng), npc, rng:Next())
			else
				local coinAmount = Mod:RandomNum(3, 5, rng)
				for _ = 1, coinAmount do
					Mod.Spawn.Coin(CoinSubType.COIN_PENNY, npc.Position, EntityPickup.GetRandomPickupVelocity(npc.Position, rng))
				end
			end
			npc:GetSprite():Play("Break")
			Mod.sfxman:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY, 0.8, 0, false, 1)
			Mod.sfxman:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.8, 0, false, 1)
			Mod.Game:SpawnParticles(npc.Position, EffectVariant.COIN_PARTICLE, Mod:RandomNum(7, 14), 4)
			Mod.Game:ShakeScreen(8)
			Mod.Game:GetLevel():SetStateFlag(LevelStateFlag.STATE_SHOPKEEPER_KILLED_LVL, true)
			return false
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, GOLDEN_SHOPKEEPER.ShopkeeperTakeDamage, EntityType.ENTITY_SHOPKEEPER)

---@param npc EntityNPC
function GOLDEN_SHOPKEEPER:StopDeathEffect(npc)
	if npc.Variant == GOLDEN_SHOPKEEPER.ID and npc:IsDead() then
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, GOLDEN_SHOPKEEPER.StopDeathEffect, EntityType.ENTITY_SHOPKEEPER)