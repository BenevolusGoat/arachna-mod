--#region Variables

local Mod = ARACHNAMOD

local DADS_NEWSPAPER = {}

ARACHNAMOD.Item.DADS_NEWSPAPER = DADS_NEWSPAPER

DADS_NEWSPAPER.ID = Isaac.GetItemIdByName("Dad's Newspaper")
DADS_NEWSPAPER.EFFECT = Isaac.GetEntityVariantByName("Newspaper (swing)")

DADS_NEWSPAPER.SWING_COOLDOWN = 120
DADS_NEWSPAPER.RADIUS = 36
DADS_NEWSPAPER.TAP_FRAME_WINDOW = 20

DADS_NEWSPAPER.CONFUSION_DURATION = 30 * 3
DADS_NEWSPAPER.MIN_DAMAGE = 4
DADS_NEWSPAPER.MAX_DAMAGE = 24

--#endregion

--#region Helpers

---@param player EntityPlayer
---@return EntityEffect?
function DADS_NEWSPAPER:TryGetNewspaperEffect(player)
	local data = Mod:GetData(player)
	if data.DadsNewspaper
		and data.DadsNewspaper.Ref
		and data.DadsNewspaper.Ref:Exists()
	then
		return data.DadsNewspaper.Ref:ToEffect()
	end
end

---@param player EntityPlayer
function DADS_NEWSPAPER:HasDoubleTapped(player)
	local ctrlIndex = player.ControllerIndex
	local firedLeft, firedUp, firedRight, firedDown = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, ctrlIndex),
		Input.IsActionTriggered(ButtonAction.ACTION_SHOOTUP, ctrlIndex),
		Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, ctrlIndex),
		Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN, ctrlIndex)
	local data = Mod:GetData(player)
	local fireDir
	if firedLeft then
		fireDir = Direction.LEFT
	elseif firedUp then
		fireDir = Direction.UP
	elseif firedRight then
		fireDir = Direction.RIGHT
	elseif firedDown then
		fireDir = Direction.DOWN
	end

	if (firedLeft or firedRight or firedUp or firedDown) then
		if not data.NewspaperTapWindow or (data.NewspaperLastDirection ~= fireDir) then
			data.NewspaperLastDirection = fireDir
			data.NewspaperTapWindow = DADS_NEWSPAPER.TAP_FRAME_WINDOW
		elseif data.NewspaperTapWindow then
			data.NewspaperTapWindow = nil
			return true
		end
	elseif data.NewspaperTapWindow and data.NewspaperTapWindow > 0 then
		data.NewspaperTapWindow = data.NewspaperTapWindow - 1
	else
		data.NewspaperTapWindow = nil
		data.NewspaperLastDirection = nil
	end
end

---@param effectParent EntityEffect
function DADS_NEWSPAPER:SpawnHitbox(effectParent)
	local player = effectParent.SpawnerEntity and effectParent.SpawnerEntity:ToPlayer()
	if not player then return end
	local sprite = effectParent:GetSprite()
	local hitbox = Mod.Spawn.Effect(DADS_NEWSPAPER.EFFECT, KnifeSubType.CLUB_HITBOX, effectParent.Position, nil, player)
	hitbox.Parent = effectParent
	hitbox:FollowParent(effectParent)
	hitbox:GetSprite():Play(sprite:GetAnimation(), true)
	hitbox.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
	hitbox.CollisionDamage = DADS_NEWSPAPER:GetDamageValue(player)
	effectParent:SetTimeout(DADS_NEWSPAPER.SWING_COOLDOWN)
end

---@param effect EntityEffect
function DADS_NEWSPAPER:Shoot(effect)
	local sprite = effect:GetSprite()
	if sprite:IsFinished("Idle") or sprite:IsFinished("Swing2") then
		sprite:Play("Swing", true)
		Mod.sfxman:Play(SoundEffect.SOUND_SHELLGAME)
	elseif sprite:IsFinished("Swing") then
		sprite:Play("Swing2", true)
		Mod.sfxman:Play(SoundEffect.SOUND_SHELLGAME)
	end
	DADS_NEWSPAPER:SpawnHitbox(effect)
end

---@param player EntityPlayer
function DADS_NEWSPAPER:GetDamageValue(player)
	return Mod:Clamp(player.Damage * (2 + player:GetCollectibleNum(player:GetCollectibleNum(DADS_NEWSPAPER.ID))), DADS_NEWSPAPER.MIN_DAMAGE, DADS_NEWSPAPER.MAX_DAMAGE)
end

--#endregion

--#region Spawning Newspaper

---@param effect EntityEffect
function DADS_NEWSPAPER:OnInit(effect)
	if effect.SubType == 0 then
		effect.SpriteOffset = Vector(0, -5)
		effect:GetSprite():GetLayer("whoosh"):SetVisible(false)
	elseif effect.SubType == KnifeSubType.CLUB_HITBOX then
		effect:GetSprite():GetLayer("main"):SetVisible(false)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, DADS_NEWSPAPER.OnInit, DADS_NEWSPAPER.EFFECT)

---@param player EntityPlayer
function DADS_NEWSPAPER:ManageSpawn(player)
	local hasItem = player:HasCollectible(DADS_NEWSPAPER.ID)
	local newspaperEffect = DADS_NEWSPAPER:TryGetNewspaperEffect(player)
	if hasItem and not newspaperEffect then
		local data = Mod:GetData(player)
		local effect = Mod.Spawn.Effect(DADS_NEWSPAPER.EFFECT, 0, player.Position, nil, player)
		if not data.DadsNewspaper then
			data.DadsNewspaper = EntityPtr(effect)
		else
			data.DadsNewspaper:SetReference(effect)
		end
		Mod:DebugLog("Spawned Dad's Newspaper")
	elseif not hasItem and newspaperEffect then
		newspaperEffect:Remove()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, DADS_NEWSPAPER.ManageSpawn)

--#endregion

--#region Player Update

---@param player EntityPlayer
function DADS_NEWSPAPER:PostPlayerUpdate(player)
	if not player:HasCollectible(DADS_NEWSPAPER.ID) then return end
	local effect = DADS_NEWSPAPER:TryGetNewspaperEffect(player)
	if not effect then return end
	local isShooting = player:GetFireDirection() ~= Direction.NO_DIRECTION
	local aimVec = player:GetAimDirection()
	local newspaperVec = Mod:GetData(effect).LastNewspaperDirection
	local doubleTapped = effect.Timeout <= 0 and DADS_NEWSPAPER:HasDoubleTapped(player) or false
	local finalVec

	if effect.Timeout > 0 and not effect:GetSprite():IsFinished() then
		--Keep newspaper still in last shot direction until swing animation ends
		finalVec = newspaperVec
	elseif isShooting then
		if effect.Timeout <= 0 and doubleTapped then
			DADS_NEWSPAPER:Shoot(effect)
		end
		Mod:GetData(effect).LastNewspaperDirection = Vector(aimVec.X, aimVec.Y)
		finalVec = aimVec
	else
		local headDir = player:GetHeadDirection()
		finalVec = Mod:DirectionToVector(headDir)
	end
	finalVec = finalVec:Rotated(270)
	local rotation = finalVec:GetAngleDegrees()
	effect.SpriteRotation = Mod:LerpAngleDegrees(effect.SpriteRotation, rotation, 0.3)
	local vec = Vector.FromAngle(effect.SpriteRotation)
	effect.Position = player.Position + vec:Rotated(-90):Resized(-15)
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, DADS_NEWSPAPER.PostPlayerUpdate, PlayerVariant.PLAYER)

--#endregion

--#region Newspaper Update

---@param effect EntityEffect
function DADS_NEWSPAPER:OnPaperUpdate(effect)
	local player = effect.SpawnerEntity and effect.SpawnerEntity:ToPlayer()
	if effect.SubType ~= 0 or not player then return end
	local expectedEffect = DADS_NEWSPAPER:TryGetNewspaperEffect(player)
	if not expectedEffect or GetPtrHash(expectedEffect) ~= GetPtrHash(effect) then
		effect:Remove()
		Mod:DebugLog("Removed old newspaper")
	end
	if effect.Timeout == 1 then
		effect:SetColor(Color(1,1,1,1,0.78,0.78,0.78), 10, 1, true, false)
		Mod.sfxman:Play(SoundEffect.SOUND_BEEP)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, DADS_NEWSPAPER.OnPaperUpdate, DADS_NEWSPAPER.EFFECT)

---@param effect EntityEffect
function DADS_NEWSPAPER:OnHitboxUpdate(effect)
	local player = effect.SpawnerEntity and effect.SpawnerEntity:ToPlayer()
	local parent = effect.Parent
	if effect.SubType ~= KnifeSubType.CLUB_HITBOX or not player or not parent then return end
	local sprite = effect:GetSprite()
	effect.SpriteRotation = parent.SpriteRotation
	if sprite:GetFrame() > 2 then
		local pos = effect.Position + Vector(0, DADS_NEWSPAPER.RADIUS):Rotated(effect.SpriteRotation)
		local data = Mod:GetData(effect)
		if not data.HitList then
			data.HitList = {}
		end
		local source = EntityRef(player)
		for _, ent in ipairs(Isaac.FindInRadius(pos, DADS_NEWSPAPER.RADIUS)) do
			if ent:IsActiveEnemy(false)
				and ent:IsVulnerableEnemy()
				and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
				and not data.HitList[ent.Index]
			then
				local tags = ent:GetEntityConfigEntity():GetEntityTags()
				if Mod:HasBitFlags(tags, EntityTag.FLY) or Mod:HasBitFlags(tags, EntityTag.SPIDER) then
					Mod.Game:SpawnParticles(ent.Position, 5, Mod:RandomNum(6, 10), 7)
					Mod.sfxman:Play(SoundEffect.SOUND_PUNCH, 1, 0, false, 1)
					Mod.sfxman:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.8, 0, false, 1.25)
					ent:Die()
				else
					ent:TakeDamage(effect.CollisionDamage, 0, source, 0)
					if not ent:IsBoss() then
						ent:AddConfusion(source, DADS_NEWSPAPER.CONFUSION_DURATION, false)
					end
					Mod.sfxman:Play(SoundEffect.SOUND_PUNCH, 1, 0, false, 1)
					data.HitList[ent.Index] = true
				end
			elseif ent.Type == EntityType.ENTITY_FIREPLACE and (ent.Variant <= 1 or ent.Variant == 10)
				or ent.Type == EntityType.ENTITY_MOVABLE_TNT
				or ent.Type == EntityType.ENTITY_POOP
			then
				ent:Die()
			elseif ent:ToPickup() then
				player:ForceCollide(ent, false)
				ent:AddVelocity((ent.Position - player.Position):Resized(3))
			elseif ent:ToProjectile() then
				ent:Die()
			end
		end
		Mod.Foreach.GridInRadius(pos, DADS_NEWSPAPER.RADIUS, function (gridEnt, gridIndex)
			if gridEnt:ToPoop() or gridEnt:ToTNT() then
				gridEnt:Destroy()
			end
		end)
	end
	if sprite:IsFinished() then
		Mod:DebugLog("Removed hitbox")
		effect:Remove()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, DADS_NEWSPAPER.OnHitboxUpdate, DADS_NEWSPAPER.EFFECT)

--#endregion
