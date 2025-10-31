local mod = ARACHNAMOD
local game = ARACHNAMOD.game
local sfx = ARACHNAMOD.sfx
local bffItem = CollectibleType.COLLECTIBLE_BFFS
local sirenLullaby = TrinketType.TRINKET_FORGOTTEN_LULLABY

local babyTheYarn = Isaac.GetEntityVariantByName("The Yarn (follower)")
local itemTheYarn = Isaac.GetItemIdByName("The Yarn")

--add familiar
function mod:theYarnCache(player, cacheFlag)
    if (cacheFlag == CacheFlag.CACHE_FAMILIARS) and (player:GetCollectibleNum(itemTheYarn) >= 0) and (mod:GetData(player).friendboxUses ~= nil) then
		local yarnAmount = 0
		if player:GetCollectibleNum(itemTheYarn) > 0 then
			yarnAmount = player:GetCollectibleNum(itemTheYarn) * (player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS) + 1)
		end
		player:CheckFamiliar(babyTheYarn, yarnAmount, RNG())
	end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.theYarnCache)

--init
function mod:theYarnInit(baby)
	local sprite = baby:GetSprite()
	local data = baby:GetData()
	baby.IsFollower = true
	baby:AddToFollowers()
	sprite:Play("Idle")
	sprite:PlayOverlay("elecOverlay")
	--zap variables
	data.zapCooldown = 48
	data.zapDamage = 3.5
	--heart variables
	data.heartState = 0
	data.heartChance = 25
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.theYarnInit, babyTheYarn)

--behaviour
function mod:theYarnUpd(baby)
	local sprite = baby:GetSprite()
	local data = baby:GetData() 
	local player = baby.Player
	local fireDir = player:GetFireDirection()
	--siren lullaby synergy
	if player:HasTrinket(sirenLullaby) then 
		data.zapCooldown = 32
	else
		data.zapCooldown = 48
	end
	--bff synergy
	if player:HasCollectible(bffItem) then
		data.zapDamage = 8.4
		data.heartChance = 30
	else
		data.zapDamage = 5.2
		data.heartChance = 25
	end
	--zap
	if (baby.FrameCount % data.zapCooldown == 0) then
		local zapTarget = GetNearestEnemy(baby.Position)
		if not zapTarget:ToPlayer() then
			local distance = (zapTarget.Position - baby.Position):Length()
			if distance <= 80*baby.SpriteScale.Y then
				local zapStart = Vector(baby.Position.X, baby.Position.Y - (baby.SpriteScale.Y*33)+15)
				local laser = player:FireTechLaser(zapStart, -1, (zapTarget.Position - zapStart):Normalized(), false, false, nil, data.zapDamage/player.Damage):ToLaser()
				--laser damage is bugged in api, so I'll have to use this fuckery in multiplyers
				laser.Parent = baby
				laser:SetMaxDistance(distance)
				laser.LaserLength = distance
				laser.MaxDistance = distance
				laser.EndPoint = zapTarget.Position
				laser.Color = Color(1, 1, 1, 1, 1, 1, 0)
				sfx:Play(SoundEffect.SOUND_REDLIGHTNING_ZAP_WEAK, 0.8, 0, false, 1)
			end
		end
	end
	--give hearts
	
	if (data.heartState ~= nil) and (data.heartState == 4) then
		local rng = player:GetCollectibleRNG(itemTheYarn)
		if (rng:RandomInt(100)+1 <= data.heartChance) then
			if (not sprite:IsPlaying("SpawnHeart")) then
				sprite:Play("SpawnHeart", true)
				Isaac.Spawn(5, 2000, 0, Isaac.GetFreeNearPosition(baby.Position, 25), Vector(0, 0), baby)
				sfx:Play(SoundEffect.SOUND_THUMBSUP, 0.8, 0, false, 1)
			end
			data.heartState = 0
		end
	end
	if sprite:IsFinished("SpawnHeart") then
		sprite:Play("Idle", true)
	end
	--follow player
	baby:FollowParent()
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.theYarnUpd, babyTheYarn)
--increase heartstate
function mod:theYarnOnClear(rng, spawnpos)
	for _, baby in pairs(Isaac.FindByType(3, babyTheYarn, -1, false, false)) do
		local data = baby:GetData()
		if data.heartState < 4 then
			data.heartState = data.heartState + 1
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.theYarnOnClear)

--greed
local curWave = 0
function mod:theYarnResetWave()
	curWave = 0
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.theYarnResetWave)
function mod:theYarnGreedReroll()
	if game:IsGreedMode() then
		local realWave = game:GetLevel().GreedModeWave
		if realWave ~= curWave then
			for _, baby in pairs(Isaac.FindByType(3, babyTheYarn, -1, false, false)) do
				local data = baby:GetData()
				if data.heartState < 4 then
					data.heartState = data.heartState + 1
				end
			end
			curWave = realWave
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.theYarnGreedReroll)

--block bullets
function mod:yarnBabyTouch(baby, ent, _) 
	if ent:ToProjectile() then
		ent:Die()
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, mod.yarnBabyTouch, babyTheYarn)