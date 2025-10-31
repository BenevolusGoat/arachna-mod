local mod = ARACHNAMOD
local game = ARACHNAMOD.game
local sfx = ARACHNAMOD.sfx
local floatDir = {[Direction.NO_DIRECTION] = "FloatDown", [Direction.UP] = "FloatUp", [Direction.DOWN] = "FloatDown", [Direction.LEFT] = "FloatSide2", [Direction.RIGHT] = "FloatSide"}
local shootDir = {[Direction.NO_DIRECTION] = "FloatShootDown", [Direction.UP] = "FloatShootUp", [Direction.DOWN] = "FloatShootDown", [Direction.LEFT] = "FloatShootSide2", [Direction.RIGHT] = "FloatShootSide"}
local vecDir = {[Direction.NO_DIRECTION] = Vector(0, 0), [Direction.UP] = Vector(0, -1), [Direction.DOWN] = Vector(0, 1), [Direction.LEFT] = Vector(-1, 0),[Direction.RIGHT] = Vector(1, 0)}

local bffItem = CollectibleType.COLLECTIBLE_BFFS
local kingBaby = CollectibleType.COLLECTIBLE_KING_BABY
local babyBender = TrinketType.TRINKET_BABY_BENDER
local sirenLullaby = TrinketType.TRINKET_FORGOTTEN_LULLABY
local altarItem = CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR

local babyLilArachna = Isaac.GetEntityVariantByName("Lil Arachna")
local itemLilArachna = Isaac.GetItemIdByName("Lil Arachna")

--add familiar
function mod:lilArachnaCache(player, cacheFlag)
    if (cacheFlag == CacheFlag.CACHE_FAMILIARS) and (player:GetCollectibleNum(itemLilArachna) >= 0) then
		local arachnaAmount = 0
		if player:GetCollectibleNum(itemLilArachna) > 0 then
			arachnaAmount = player:GetCollectibleNum(itemLilArachna) * (player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS) + 1)
		end
		player:CheckFamiliar(babyLilArachna, arachnaAmount, RNG())
	end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.lilArachnaCache)

--init
function mod:lilArachnaInit(baby)
	baby.IsFollower = true
	baby:AddToFollowers()
	baby:GetSprite():Play("IdleDown")
	baby.FireCooldown = 4
	baby:GetData().MaxFireCooldown = 24
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.lilArachnaInit, babyLilArachna)

--behaviour
function mod:lilArachnaUpd(baby)
	local sprite = baby:GetSprite()
	local data = baby:GetData() 
	local player = baby.Player
	local fireDir = player:GetFireDirection()
	--siren lullaby synergy
	if player:HasTrinket(sirenLullaby) then 
		data.MaxFireCooldown = 8
	else
		data.MaxFireCooldown = 16
	end
	--animations
	if fireDir ~= Direction.NO_DIRECTION then
		--shoot
		if baby.FireCooldown <= 0 then
			--normal tear direction
			data.animDir = fireDir
			local tearTrajectory = vecDir[fireDir]
			--king baby tear direction and shoot animation
			local tearTarget = GetNearestEnemy(baby.Position)
			local inheritVelocity = true
			if (player:HasCollectible(kingBaby, true)) and (not tearTarget:ToPlayer()) then
				tearTrajectory = (tearTarget.Position - baby.Position):Normalized()
				data.animDir = vecToDir(tearTrajectory)
				inheritVelocity = false
			end
			--shoot tear
			local tear = 0
			if inheritVelocity then
				--normal tear velocity
				tear = baby:FireProjectile(tearTrajectory):ToTear()
			else
				--tear velocity if player has king baby
				tear = Isaac.Spawn(2, 0, 0, baby.Position, Vector(0,0), baby):ToTear()
				tear.Velocity = tearTrajectory*9
			end
			tear:AddTearFlags(TearFlags.TEAR_SLOW | TearFlags.TEAR_QUADSPLIT) 
			local rng = player:GetCollectibleRNG(itemLilArachna)
			if (rng:RandomInt(4)+1 == 1) then
				tear:GetData().spiderBiteOnHit = true
			end
			tear.Color = Color(2, 2, 2, 1, 0.196, 0.196, 0.196) 
			--tear stats with bffs
			if player:HasCollectible(bffItem) then
				tear.Scale = 0.9
				tear.CollisionDamage = 7
			else
			--normal tear stats
				tear.Scale = 0.7
				tear.CollisionDamage = 3.5
			end
			--baby bender synergy
			if player:HasTrinket(babyBender) then
				tear:AddTearFlags(TearFlags.TEAR_HOMING)
				tear.Color = Color(0.4, 0.15, 0.38, 1, 0.27843, 0, 0.4549) 
			end
			--
			sprite:Play(shootDir[data.animDir], false)
			baby.FireCooldown = data.MaxFireCooldown
		--after shooting, go back to idle animation
		elseif (baby.FireCooldown > 0) and (baby.FireCooldown <= data.MaxFireCooldown - data.MaxFireCooldown/2) and (data.animDir ~= nil) and (not sprite:IsPlaying(floatDir[data.animDir])) then
			sprite:Play(floatDir[data.animDir], false)
		end
	else
		--float
		sprite:Play(floatDir[fireDir], false)
	end	
	baby.FireCooldown = baby.FireCooldown - 1
	--follow player
	baby:FollowParent()
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.lilArachnaUpd, babyLilArachna)

--sacrificial altar
function mod:sacrificeLilArachna(item, rng, player, useFlags, activeSlot)
	local lilArachnaCount = player:GetCollectibleNum(itemLilArachna)
	for i=1, lilArachnaCount do
		player:RemoveCollectible(itemLilArachna)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.sacrificeLilArachna, altarItem)

--special tear effect on hit
function mod:snowballDamage(ent, amount, flags, src, countdown)
	if (src.Entity) and (src.Entity:ToTear()) then
		local tear = src.Entity:ToTear()
		if (tear:GetData().spiderBiteOnHit) then
			if (ent) and (not ent:IsBoss()) and (ent:IsVulnerableEnemy()) and (ent.Type ~= EntityType.ENTITY_FIREPLACE) then
				local player = Isaac.GetPlayer(0)
				local swirlEffect = Isaac.Spawn(1000, 2002, 1, Vector(ent.Position.X, ent.Position.Y-10), Vector(0,0), player):ToEffect()
				swirlEffect.DepthOffset = 250
				swirlEffect:Update()
				doSpiderBite(ent, 200, player, false)
				return nil
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.snowballDamage)