local mod = ARACHNAMOD
local arachnaChar_b = Isaac.GetPlayerTypeByName("Arachna", true)
local game = ARACHNAMOD.game
local sfx = ARACHNAMOD.sfx
--EFFECT
function mod:spiderFloorEffectUpdate(eff)
	local sprite = eff:GetSprite()
	local data = eff:GetData()
	if not data.init then
		sprite:Play("Poof", true)
		data.init = true
	end
	if sprite:IsFinished("Poof") then
		eff:Remove()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.spiderFloorEffectUpdate, 2002)

--DEBUFF
--clear
function mod:spiderbiteNewRoom()
	spiderBiteRender = {}
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.spiderbiteNewRoom)

--effect
function mod:spiderBiteInfected(npc)
	if isBitten(npc) then
		local data = npc:GetData()
		--slowing down
		--for some reason simply adding 1 didn't work, so I'm doing it this way.
		npc:AddSlowing(EntityRef(Isaac.GetPlayer(0)), 2, 0.5, Color(1, 1, 1, 1, 0.2, 0.2, 0.2))
		npc:AddSlowing(EntityRef(Isaac.GetPlayer(0)), -1, 0.5, Color(1, 1, 1, 1, 0.2, 0.2, 0.2))
		data.spiderBiteTime = data.spiderBiteTime - 1		
		--on death
		if (npc:IsDead()) and (npc.MaxHitPoints >= 10) and (npc.Type ~= 853) and (npc.Type ~= 24) and (npc.Type ~= 278) and (npc.SpawnerType == 0) and (npc.ParentNPC == nil) and (not npc:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN)) then
			local spiderEgg = Isaac.Spawn(1000, 2001, 0, npc.Position, Vector(0,0), npc:GetData().bitePar):ToEffect()
			spiderEgg:GetData().maxEggTime = 500
			spiderEgg:GetData().eggTime = 500
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.spiderBiteInfected)

--render
local spiderbiteMarkSprite = Sprite()
spiderbiteMarkSprite:Load("gfx/indicator_arachna_b.anm2",true)
spiderbiteMarkSprite:LoadGraphics()
spiderbiteMarkSprite:Play("Idle", true)
function mod.spiderMarkUpdate()
	if (game:GetFrameCount() % 2 == 0) then
		spiderbiteMarkSprite:Update()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.spiderMarkUpdate)
function mod:spiderbiteMarkRender(npc)
	if isBitten(npc) then
		spiderbiteMarkSprite:Render(Isaac.WorldToScreen(npc.Position), Vector(0,0), Vector(0,0))
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, mod.spiderbiteMarkRender)

--DIVINE CLOTH
local divineCloth = Isaac.GetItemIdByName("Divine Cloth")
local function isAltBrArachna(_player)
	if (_player:GetPlayerType() == arachnaChar_b) and (_player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
		return true
	end
	return false
end
--on use
function mod:divineClothUse(item, rng, player, useflags, slot, customvardata)
	--item effect
	--bite enemies
	local size = 1
	--if it's alt arachna with br, increase radius
	if isAltBrArachna(player) then
		size = 1.2
	end
	--## MOVED TO EFFECT ITSELF ##
	--repair eggs on birthright
	if isAltBrArachna(player) then
		local shouldPlayGood = false
		for _, eggs in ipairs(Isaac.FindByType(1000, 2001)) do
			if (eggs.Position - player.Position):Length() <= 120 then --radius
				shouldPlayGood = true
				local data = eggs:GetData()
				if (data.eggTime) then
					if (data.eggTime + 100 > data.maxEggTime) then
						data.eggTime = data.maxEggTime
					else
						data.eggTime = data.eggTime + 100
					end
				end
				--local upEffect = Isaac.Spawn(1000, 48, 2000, Vector(eggs.Position.X+3, eggs.Position.Y-25), Vector(0,0), nil):ToEffect()
				local heartEff = Isaac.Spawn(1000, 49, 0, Vector(eggs.Position.X+3, eggs.Position.Y-25), Vector(0,0), player):ToEffect()
				heartEff.DepthOffset = 250
				heartEff:Update()
			end
		end
		if shouldPlayGood then
			sfx:Play(SoundEffect.SOUND_THUMBSUP, 0.8, 0, false, 1)
		end
	end
	--visual effect
	game:ShakeScreen(8)
	local swirlEffect = Isaac.Spawn(1000, 2002, 1, Vector(player.Position.X, player.Position.Y-10), Vector(0,0), player):ToEffect()
	swirlEffect.DepthOffset = 250
	swirlEffect:Update()
	local floorWeb = Isaac.Spawn(1000, 2002, 0, player.Position, Vector(0,0), player):ToEffect()
	floorWeb.Color = Color(1, 1, 1, 0.45, 0, 0, 0)
	floorWeb.SpriteScale = floorWeb.SpriteScale*size
	floorWeb:Update()	
	--sound
	sfx:Play(SoundEffect.SOUND_SPIDER_SPIT_ROAR, 0.8, 0, false, 1)
	sfx:Play(SoundEffect.SOUND_FETUS_JUMP, 0.8, 0, false, 1)
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.divineClothUse, divineCloth)

--effect
function mod:floorWebEffectUpdate(eff)
	local sprite = eff:GetSprite()
	if eff.SubType == 0 then -- subtype 1 used by swirl effect, so we use only 0 for the web itself
		local player = eff.SpawnerEntity:ToPlayer()
		--bite enemies
		local radius = 90
		local size = 1
		local bitelength = 200
		--if it's alt arachna with br, increase radius
		if isAltBrArachna(player) then
			radius = 120
			size = 1.2
			bitelength = 250
		end
		--bite enemies
		local enemies = Isaac.FindInRadius(eff.Position, radius, EntityPartition.ENEMY)
		for i=1, #enemies do
			local ent = enemies[i]
			local data = ent:GetData()
			if (not ent:IsBoss()) and (ent:IsVulnerableEnemy()) and (ent.Type ~= EntityType.ENTITY_FIREPLACE) and (not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
				if (data.spiderBiteTime == nil) or (data.spiderBiteTime <= data.maxBiteTime - 25) then
					doSpiderBite(ent, bitelength, player, false)
					local swirlEffect = Isaac.Spawn(1000, 2002, 1, Vector(ent.Position.X, ent.Position.Y-10), Vector(0,0), ent):ToEffect()
					swirlEffect.DepthOffset = 250
					swirlEffect:Update()
					--Isaac.ConsoleOutput("\nBitten!")
				end
			end
		end
	end
	--fuckin die
	if sprite:IsFinished("Poof") then
		eff:Remove()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.floorWebEffectUpdate, 2002)
--SOUL OF ARACHNA
local arachnaSoul = Isaac.GetCardIdByName("Soul of Arachna")
function mod:useArachnaSoul(card, player)
	--effect
	local entities = Isaac.GetRoomEntities()
	for i=1, #entities do
		local npc = entities[i]
		if (npc:IsVulnerableEnemy()) and (not npc:IsBoss()) and (npc.Type ~= EntityType.ENTITY_FIREPLACE) then
			doSpiderBite(npc, 150, player, false)
			npc:TakeDamage(player.Damage*3, 0, EntityRef(player), 0)
			local swirlEffect = Isaac.Spawn(1000, 2002, 1, Vector(npc.Position.X, npc.Position.Y-10), Vector(0,0), npc):ToEffect()
			swirlEffect.DepthOffset = 250
			swirlEffect:Update()
			local rng = player:GetCardRNG(arachnaSoul)
			game:SpawnParticles(npc.Position, 5, rng:RandomInt(15)+7, 4, Color(1, 1, 1, 1, 1, 1, 1))
		end
	end
	--visual effect
	game:ShakeScreen(16)
	local swirlEffect = Isaac.Spawn(1000, 2002, 1, Vector(player.Position.X, player.Position.Y-10), Vector(0,0), player):ToEffect()
	swirlEffect.DepthOffset = 400
	swirlEffect:Update()
	--sfx
	sfx:Play(Isaac.GetSoundIdByName("snd_arachna_soul"), 3.5, 0, false, 1)
	sfx:Play(SoundEffect.SOUND_SPIDER_SPIT_ROAR, 0.8, 0, false, 1)
	--sfx:Play(SoundEffect.SOUND_MEATY_DEATHS , 0.8, 0, false, 1.25)
	--animation
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useArachnaSoul, arachnaSoul)