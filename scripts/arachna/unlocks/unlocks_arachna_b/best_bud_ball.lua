local Mod = ARACHNAMOD

local BEST_BUD_BALL = {}

ARACHNAMOD.Item.BEST_BUD_BALL = BEST_BUD_BALL

BEST_BUD_BALL.ID = Isaac.GetItemIdByName("Best Bud Ball")
BEST_BUD_BALL.EFFECT = Isaac.GetEntityVariantByName("Best Bud Ball")

BEST_BUD_BALL.SFX = {
	RAISE = Isaac.GetSoundIdByName("Best Bud Ball (Raise)"),
	THROW = Isaac.GetSoundIdByName("Best Bud Ball (Throw)"),
	LAND = Isaac.GetSoundIdByName("Best Bud Ball (Land)"),
	PICKUP = Isaac.GetSoundIdByName("Best Bud Ball (Pickup)"),
	CAPTURE = Isaac.GetSoundIdByName("Best Bud Ball (Capture)"),
	RELEASE = Isaac.GetSoundIdByName("Best Bud Ball (Release)")
}

BEST_BUD_BALL.BLACKLISTED_BOSSES = Mod:Set({
	EntityType.ENTITY_MOM,
	EntityType.ENTITY_MOMS_HEART,
	EntityType.ENTITY_ISAAC, --+Blue Baby
	EntityType.ENTITY_SATAN,
	EntityType.ENTITY_THE_LAMB,
	EntityType.ENTITY_DELIRIUM,
	EntityType.ENTITY_ULTRA_GREED, --+Ultra Greedier
	EntityType.ENTITY_MOTHER,
	EntityType.ENTITY_DOGMA,
	EntityType.ENTITY_BEAST, --+Ultra Horsemen
})

ThrowableItemLib:RegisterThrowableItem({
	Type = ThrowableItemLib.Type.ACTIVE,
	ID = BEST_BUD_BALL.ID,
	Identifier = "Best Bud Ball",
	ThrowFn = function(player, vect, slot, mimic)
		BEST_BUD_BALL:FireBall(player.Position, Mod:AddTearVelocity(vect, 15, player), player)
		Mod.sfxman:Play(BEST_BUD_BALL.SFX.THROW, 1, 2, false, 0.8)
	end,
	LiftFn = function (player, continued, slot, mimic)
		Mod.sfxman:Play(BEST_BUD_BALL.SFX.RAISE, 1, 2, false, 0.8)
	end
})

---@param pos Vector
---@param vel Vector
---@param spawner Entity
function BEST_BUD_BALL:FireBall(pos, vel, spawner)
	local ball = Mod.Spawn.Effect(BEST_BUD_BALL.EFFECT, 0, pos, vel, spawner)
	ball.PositionOffset = Vector(0, -60)
	ball.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
	ball.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
end

---@param ent Entity
function BEST_BUD_BALL:CanCaptureEnemy(ent)
	return ent:IsBoss()
		and not BEST_BUD_BALL.BLACKLISTED_BOSSES[ent.Type]
end

---@param npc EntityNPC
---@param player EntityPlayer
function BEST_BUD_BALL:TryCaptureEnemy(npc, player)
	local maxHpChance = Mod.math.max(0, (1.25 - (npc.MaxHitPoints / 600)) * 0.5) --+46% chance at 200 max HP, +29% at 400 max hp, and +12.5% at 600 max hp
	local hpChance = (1 - (npc.HitPoints / npc.MaxHitPoints)) * 0.50 --Up to +50% capture chance based on health %
	local luck = Mod.math.min(0.5, Mod.math.max(0, player.Luck) * 0.025) --+2.5% per luck, up to 50%
	local roll = player:GetCollectibleRNG(BEST_BUD_BALL.ID):RandomFloat()
	local chance = 0.01 + maxHpChance + hpChance + luck

	return roll < chance
end

---@param ball EntityEffect
function BEST_BUD_BALL:OnBallUpdate(ball)
	local sprite = ball:GetSprite()
	local data = Mod:GetData(ball)

	if ball.PositionOffset.Y < 0 then
		ball.PositionOffset = ball.PositionOffset + Vector(0, 1.1^ball.FrameCount)
		ball.Velocity = ball.Velocity - ball.Velocity:Resized(0.075 * 1.1^ball.FrameCount)
	elseif not data.BallStationary then
		sprite:SetFrame(4)
		sprite:Stop()
		ball.PositionOffset = Vector.Zero
		ball.Velocity = Vector.Zero
		Mod.sfxman:Play(BEST_BUD_BALL.SFX.LAND, 1, 2, false, 0.8)
		ball:SetTimeout(30)
		data.BallStationary = true
	elseif ball.SpawnerType == EntityType.ENTITY_PLAYER and ball.SpawnerEntity then
		local spawner = ball.SpawnerEntity
		Mod.Foreach.PlayerInRadius(ball.Position, ball.Size, function (player, index)
			if spawner and Mod:IsSameEntity(spawner, player) then
				for i = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do
					local itemId = player:GetActiveItem(i)
					if itemId == BEST_BUD_BALL.ID then
						player:AddActiveCharge(player:GetActiveMaxCharge(i), i)
						Mod.sfxman:Play(BEST_BUD_BALL.SFX.PICKUP, 1, 2, false, 0.8)
						ball:Remove()
						return
					end
				end
			end
		end)
	end

	if ball.Timeout == 0 then
		ball:Remove()
	end

	if data.BallStationary then return end

	if (ball.FrameCount % 2 == 0) then
		local trail = Mod.Spawn.Effect(EffectVariant.HAEMO_TRAIL, 0, ball.Position + ball.PositionOffset, nil, ball)
		local oldColor = trail:GetSprite().Color
		local newColor = Color(oldColor.R, oldColor.G, oldColor.B, oldColor.A, 0.70, 0.18, 0.69, 1, 1, 1, 1)
		trail:GetSprite().Color = newColor
		trail.DepthOffset = -10
	end

	Mod.Foreach.NPCInRadius(ball.Position, ball.Size, function (npc, index)
		if BEST_BUD_BALL:CanCaptureEnemy(npc) then

		end
	end, nil, nil, {UseEnemySearchParams = true})
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, BEST_BUD_BALL.OnBallUpdate, BEST_BUD_BALL.EFFECT)