local mod = ARACHNAMOD
local game = ARACHNAMOD.game
local sfx = ARACHNAMOD.sfx
-- 1-5 (11-16) have effects and colors based on locusts, 6-9 (16-19) are my own ideas. there is also 10 which doesn't have special effects, it's just normal spider but big
--set color
function mod:colorSpiderInit(baby)
	--big blue spider
	if baby.Type == 3 and baby.Variant == 73 and baby.SubType == 10 then
		--replace anm2
		local sprite = baby:GetSprite()
		sprite:Load("gfx/familiars/colorspiders/bluespider_big.anm2", true)
	end
	--spiders of color
	if isColorSpider(baby, nil) then
		local sprite = baby:GetSprite()
		--replace anm2
		if isColorSpider(baby, false) then
			sprite:Load("gfx/familiars/colorspiders/familiar_soc.anm2", true)
		elseif isColorSpider(baby, true) then
			sprite:Load("gfx/familiars/colorspiders/familiar_soc_big.anm2", true)
		end
		--create color
		local oldColor = sprite.Color 
		local newColor = Color(oldColor.R, oldColor.G, oldColor.B, oldColor.A, oldColor.RO, oldColor.GO, oldColor.BO) 
		--apply changes
		newColor:SetColorize(1, 1, 1, 1)
		if baby.SubType == 1 or baby.SubType == 11 then
			newColor:SetTint(1.0, 1.0, 0.0, 1.0)
			newColor:SetOffset(0.49, 0.0, 0.0) 
		elseif baby.SubType == 2 or baby.SubType == 12 then
			newColor:SetTint(1.0, 1.0, 0.0, 1.0)
			newColor:SetOffset(0.0, 0.31, 0.0) 
		elseif baby.SubType == 3 or baby.SubType == 13 then
			newColor:SetTint(0.8, 0.8, 0.0, 1.0)
			newColor:SetOffset(0.31, 0.22, 0.0)
		elseif baby.SubType == 4 or baby.SubType == 14 then
			newColor:SetTint(0.0, 0.0, 0.0, 1.0)
			newColor:SetOffset(0.0, 0.0, 0.0)
		elseif baby.SubType == 5 or baby.SubType == 15 then
			newColor:SetTint(1.0, 1.0, 1.0, 1.0)
			newColor:SetOffset(0.78, 0.78, 0.78) 
		elseif baby.SubType == 6 or baby.SubType == 16 then 
			local glow = Isaac.Spawn(1000, 121, 0, baby.Position, Vector(0,0), baby):ToEffect()
			glow.SpawnerEntity = baby
			if baby.SubType == 6 then
				glow.SpriteScale = glow.SpriteScale*0.5
			elseif baby.SubType == 16 then
				glow.SpriteScale = glow.SpriteScale*0.8
			end
		elseif baby.SubType == 7 or baby.SubType == 17 then
			newColor:SetTint(1.0, 1.0, 0.0, 1.0)
			newColor:SetOffset(0.6, 0.4, 0.1) 
			local glow = Isaac.Spawn(1000, 121, 0, baby.Position, Vector(0,0), baby):ToEffect()
			glow.SpawnerEntity = baby
			if baby.SubType == 7 then
				glow.SpriteScale = glow.SpriteScale*0.5
			elseif baby.SubType == 17 then
				glow.SpriteScale = glow.SpriteScale*0.8
			end
		elseif baby.SubType == 8 or baby.SubType == 18 then --pink
			newColor:SetTint(1.0, 1.0, 0.0, 1.0)
			newColor:SetOffset(0.35, 0.1, 0.35) 
		elseif baby.SubType == 9 or baby.SubType == 19 then --sky-blue
			newColor:SetTint(0.0, 1.0, 1.0, 1.0)
			newColor:SetOffset(0.0, 0.3, 0.49) 
		end
		--set color
		sprite.Color = newColor 
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.colorSpiderInit)

--on touch
function mod:colorSpiderDamage(ent, amount, flags, src, countdown)
	--if entity is spider
	if (src.Entity) and (src.Entity:ToFamiliar()) then
		local baby = src.Entity:ToFamiliar()
		--small color spiders
		if isColorSpider(baby, false) then
			local player = baby.Player
			if baby.SubType == 1 then
				doExplosionWithEffects(player, ent.Position, 60, true, 0.3, true) 
			elseif baby.SubType == 2 then
				ent:AddPoison(EntityRef(player), 120, 2)
			elseif baby.SubType == 3 then
				ent:AddSlowing(EntityRef(player), 600, 0.5, Color(1, 1, 1, 1, 0.2, 0.2, 0.2))
			elseif baby.SubType == 4 then
				ent:TakeDamage(amount, 0, EntityRef(player), 0)
			--Subtype 5 changes nothing, just like white locust in game
			elseif baby.SubType == 6 then
				if ent:IsBoss() then
					ent:TakeDamage(ent.HitPoints/8, 0, EntityRef(player), 0)
				else
					ent:Die()
				end
				--glowing fart
				local fart = Isaac.Spawn(1000, 34, 0, baby.Position, Vector(0,0), baby):ToEffect()
				fart:GetSprite().Color = baby:GetSprite().Color
				local glow = Isaac.Spawn(1000, 121, 0, fart.Position, Vector(0,0), fart):ToEffect()
				glow:GetSprite().Color = baby:GetSprite().Color
				glow.SpriteScale = glow.SpriteScale/2
				glow:GetData().deathFrame = 18
				sfx:Play(SoundEffect.SOUND_MEATY_DEATHS , 0.8, 0, false, 1.25)
			elseif baby.SubType == 7 then
				ent:AddMidasFreeze(EntityRef(player), 120)
				game:SpawnParticles(ent.Position, 98, mod:GetRandomNumber(4, 7, mod.Globals.garbageRNG), 4)
				sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.6, 0, false, 1)
			elseif baby.SubType == 8 then
				ent:AddCharmed(EntityRef(player), 120)
			elseif baby.SubType == 9 then
				if not ent:IsBoss() then
					doUranusFreeze(ent, player)
				end
			end
		end
		--big spiders
		if isColorSpider(baby, true) or (baby.Type == 3 and baby.Variant == 73 and baby.SubType == 10) then
			local player = baby.Player
			--for everyone
			--additional damage
			ent:TakeDamage(amount/2, 0, EntityRef(player), 0)
			--spawn smoller spiders in 2 sides
			local vecRad = mod:GetRandomNumber(75, 100, mod.Globals.garbageRNG)
			local vecAngle = mod:GetRandomNumber(0, 360, mod.Globals.garbageRNG)
			throwSpecialSpider(player, baby.SubType - 10, baby.Position, Isaac.GetFreeNearPosition(baby.Position + Vector.FromAngle(vecAngle):Resized(vecRad), 50))
			throwSpecialSpider(player, baby.SubType - 10, baby.Position, Isaac.GetFreeNearPosition(baby.Position + Vector.FromAngle(vecAngle-180):Resized(vecRad), 50))
			sfx:Play(SoundEffect.SOUND_BOIL_HATCH, 0.8, 0, false, 1)
			--subtype special
			if baby.SubType == 11 then
				doExplosionWithEffects(player, ent.Position, 100, true, 0.5, true) 
			elseif baby.SubType == 12 then
				--doube damage, poison, 4 seconds, 4 damage
				ent:AddPoison(EntityRef(player), 180, 3.50)
			elseif baby.SubType == 13 then
				ent:AddSlowing(EntityRef(player), 900, 0.5, Color(1, 1, 1, 1, 0.2, 0.2, 0.2))
			elseif baby.SubType == 14 then
				ent:TakeDamage(amount*1.5, 0, EntityRef(player), 0)			
			--Subtype 15 changes nothing, just like white locust in game
			elseif baby.SubType == 16 then
				if ent:IsBoss() then
					ent:TakeDamage(ent.HitPoints/4, 0, EntityRef(player), 0)
				else
					ent:Die()
				end
				--glowing fart
				local fart = Isaac.Spawn(1000, 34, 0, baby.Position, Vector(0,0), baby):ToEffect()
				fart:GetSprite().Color = baby:GetSprite().Color
				local glow = Isaac.Spawn(1000, 121, 0, fart.Position, Vector(0,0), fart):ToEffect()
				glow:GetSprite().Color = baby:GetSprite().Color
				glow.SpriteScale = glow.SpriteScale/2
				glow:GetData().deathFrame = 18
				sfx:Play(SoundEffect.SOUND_MEATY_DEATHS , 0.8, 0, false, 1.25)
			elseif baby.SubType == 17 then
				ent:AddMidasFreeze(EntityRef(player), 180)
				game:SpawnParticles(ent.Position, 98, mod:GetRandomNumber(4, 7, mod.Globals.garbageRNG), 4)
				sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.6, 0, false, 1)
			elseif baby.SubType == 18 then
				ent:AddCharmed(EntityRef(player), 180)
			elseif baby.SubType == 19 then
				if not ent:IsBoss() then
					doUranusFreeze(ent, player)
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.colorSpiderDamage)

--on update
function mod:colorSpiderUpdate(baby)
	--rainbow spider
	if (baby.SubType == 6) or (baby.SubType == 16) then
		local sprite = baby:GetSprite()
		sprite.Color = rainbowColor()
	end
	--gold spider
	if (baby.SubType == 7) or (baby.SubType == 17) then
		--shine
		if (baby.FrameCount % 4 == 0) then
			for i = 1, mod:GetRandomNumber(1, 3, mod.Globals.garbageRNG) do
				local centerPos = Vector(baby.Position.X, baby.Position.Y - 5)
				local shinePos = centerPos
				shinePos = shinePos + Vector.FromAngle(mod:GetRandomNumber(0, 360, mod.Globals.garbageRNG)):Resized(mod:GetRandomNumber(5, 10, mod.Globals.garbageRNG))
				local goldenShine = Isaac.Spawn(1000, 2002, 3, shinePos, Vector(0,0), baby):ToEffect()
				goldenShine.DepthOffset = 250
				goldenShine.SpriteScale = goldenShine.SpriteScale*(mod:GetRandomNumber(4, 8, mod.Globals.garbageRNG)/10)
				goldenShine:GetSprite().PlaybackSpeed = 1.2
				local glow = Isaac.Spawn(1000, 121, 0, goldenShine.Position, Vector(0,0), goldenShine):ToEffect()
				glow.SpriteScale = glow.SpriteScale/4
				glow:GetData().deathFrame = 12
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.colorSpiderUpdate, 73)

--glow
--fix pos on new room
function mod:glowNewRoom() --using this instead of persistant entity flag so you won't see it on old position when entering new room
	for _, baby in ipairs(Isaac.FindByType(3, 73, -1, false, false)) do
		if baby.SubType == 6 or baby.SubType == 16 or baby.SubType == 7 or baby.SubType == 17 then
			local glow = Isaac.Spawn(1000, 121, 0, baby.Position, Vector(0,0), baby):ToEffect()
			glow.SpawnerEntity = baby
			if baby.SubType == 6 or baby.SubType == 7 then
				glow.SpriteScale = glow.SpriteScale*0.5
			elseif baby.SubType == 16 or baby.SubType == 17 then
				glow.SpriteScale = glow.SpriteScale*0.8
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.glowNewRoom)

--follow parent, get color and disappear
function mod.colorSpiderGlow() --effect update callback seems to be broken so I'm using this
	for _, eff in ipairs(Isaac.FindByType(1000, 121, -1, false, false)) do
		local baby = eff.SpawnerEntity
		--if spawner is spider
		if baby and baby.Type == 3 and baby.Variant == 73 then
			if baby.SubType == 6 or baby.SubType == 16 or baby.SubType == 7 or baby.SubType == 17 then
				eff.Position = baby.Position
				eff.Velocity = baby.Velocity
				 --if parent is rainbow then it inherits color
				if baby.SubType == 6 or baby.SubType == 16 then
					local parentColor = baby:GetSprite().Color
					eff:GetSprite().Color = Color(parentColor.R, parentColor.G, parentColor.B, 0.15)
				end
				if not baby:Exists() then
					eff:Remove()
				end
			end
		end
		--death frame
		local data = eff:GetData()
		if data.deathFrame and eff.FrameCount == data.deathFrame then
			eff:Remove()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.colorSpiderGlow)