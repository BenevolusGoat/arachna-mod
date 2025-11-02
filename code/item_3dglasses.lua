local mod = ARACHNAMOD
local item3DGlasses = Isaac.GetItemIdByName("3D Glasses")

--god I feel so fucking sick rn. this shit probably gonna suck so much

--chance to shoot out tear
function mod:_3dGlassesOnTear(tear)
	local player = tear.Parent:ToPlayer()
	if (player ~= nil) then
		--replace tear
		if (player:HasCollectible(item3DGlasses)) and (math.random(100) <= (5 + player.Luck)) then
			tear:GetData().specialType = "3dtear"
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod._3dGlassesOnTear)

--tear visual
function mod:_3dGlassesTearVisual(tear)
	local data = tear:GetData()
	if (data.specialType) and (data.specialType == "3dtear") then
		local sprite = tear:GetSprite()
		--red
		local redSprite = Sprite()
		redSprite:Load(sprite:GetFilename(), true)
		redSprite.Color = Color(0.3, 0.1, 0.1, 0.4, 0.8, 0, 0)
		redSprite.Scale = sprite.Scale*tear.Scale*1.2
		redSprite:LoadGraphics()
		redSprite:SetFrame(sprite:GetAnimation(), sprite:GetFrame())
		redSprite:Render(Isaac.WorldToScreen(Vector(tear.Position.X-6, tear.Position.Y - 1.1 + tear.Height)), Vector(0,0), Vector(0,0))
		--blue
		local blueSprite = Sprite()
		blueSprite:Load(sprite:GetFilename(), true)
		blueSprite.Color = Color(0.1, 0.1, 0.3, 0.2, 0, 0, 0.8)
		blueSprite.Scale = sprite.Scale*tear.Scale*1.2
		blueSprite:LoadGraphics()
		blueSprite:SetFrame(sprite:GetAnimation(), sprite:GetFrame())
		blueSprite:Render(Isaac.WorldToScreen(Vector(tear.Position.X+6, tear.Position.Y - 1.1 + tear.Height)), Vector(0,0), Vector(0,0))
	end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_RENDER, mod._3dGlassesTearVisual)

--on enemy touch
function mod:_3dGlassesTearDamage(ent, amount, flags, src, countdown)
	--if entity is tear
	if (src.Entity) and (src.Entity:ToTear()) then
		local tear = src.Entity:ToTear()
		--if entity is 3d tear
		if (tear:GetData().specialType ~= nil) and (tear:GetData().specialType == "3dtear") then
			if (ent:IsVulnerableEnemy()) and (ent.Type ~= EntityType.ENTITY_FIREPLACE) and (not ent:IsBoss()) and (not ent:GetData()._3dSpawn) then
				ent:Remove()
				sfx:Play(SoundEffect.SOUND_SUMMON_POOF, 0.5, 0, false, 3)
				--red
				local redMob = Isaac.Spawn(ent.Type, ent.Variant, ent.SubType, Isaac.GetFreeNearPosition(Vector(ent.Position.X-30, ent.Position.Y),30), Vector(0,0), nil):ToNPC()
				redMob:GetSprite().Color = Color(0.5, 0.3, 0.3, 0.8, 0.3, 0, 0)
				redMob:GetData()._3dSpawn = true
				redMob:GetData()._3dPoofColor = "red"
				redMob:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				redMob:AddEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM)
				redMob:Update()
				local smoke = Isaac.Spawn(1000, 16, 2, Vector(redMob.Position.X, redMob.Position.Y-30), Vector(0,0), nil):ToEffect()
				smoke.Color = Color(0.5, 0.3, 0.3, 0.8, 0.3, 0, 0)
				smoke.SpriteScale = smoke.SpriteScale/1.5
				--blue
				local blueMob = Isaac.Spawn(ent.Type, ent.Variant, ent.SubType, Isaac.GetFreeNearPosition(Vector(ent.Position.X+30, ent.Position.Y), 30), Vector(0,0), nil):ToNPC()
				blueMob:GetSprite().Color = Color(0.3, 0.3, 0.5, 0.8, 0, 0, 0.3)
				blueMob:GetData()._3dSpawn = true
				blueMob:GetData()._3dPoofColor = "blue"
				blueMob:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				blueMob:AddEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM)
				blueMob:Update()
				local smoke = Isaac.Spawn(1000, 16, 2, Vector(blueMob.Position.X, blueMob.Position.Y-30), Vector(0,0), nil):ToEffect()
				smoke.Color = Color(0.3, 0.3, 0.5, 0.8, 0, 0, 0.3)
				smoke.SpriteScale = smoke.SpriteScale/1.5
			end
		end
	end
	--invulnerable 3d enemies
	if (ent:GetData()._3dSpawn) then
		return false
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod._3dGlassesTearDamage)

--on update
function mod:_3dGlassesEnemyDeath(npc)
	local data = npc:GetData()
	if (data._3dSpawn) then
		--constantly set color so enemies that change their color won't overwrite it
		if data._3dPoofColor == "red" then
			npc:GetSprite().Color = Color(0.5, 0.3, 0.3, 0.8, 0.3, 0, 0)
		elseif data._3dPoofColor == "blue" then
			npc:GetSprite().Color = Color(0.3, 0.3, 0.5, 0.8, 0, 0, 0.3)
		end
		--can't die
		npc.HitPoints = npc.MaxHitPoints 
		--on death
		if game:GetRoom():IsClear() then
			local smoke = Isaac.Spawn(1000, 16, 2, Vector(npc.Position.X, npc.Position.Y-30), Vector(0,0), nil):ToEffect()
			if data._3dPoofColor == "blue" then
				smoke.Color = Color(0.3, 0.3, 0.5, 0.8, 0, 0, 0.3)
			elseif data._3dPoofColor == "red" then
				smoke.Color = Color(0.5, 0.3, 0.3, 0.8, 0.3, 0, 0)
			end
			smoke.SpriteScale = smoke.SpriteScale/1.5
			sfx:Play(SoundEffect.SOUND_SUMMON_POOF, 0.5, 0, false, 1.5)
			sfx:Play(SoundEffect.SOUND_MEATY_DEATHS , 0.8, 0, false, 0.8)
			npc:Remove()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod._3dGlassesEnemyDeath)

--remove charm flags on pre game exit so enemies won't save and player won't be able to stack them by re-entering the game
function mod:_3dGlassMassPurge(shouldSave)
	local enemies = Isaac.GetRoomEntities()
	for i = 1, #enemies do
		local ent = enemies[i]
		if (ent:GetData()._3dSpawn) then
			--Isaac.ConsoleOutput("i")
			ent:ClearEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM)
			ent:Update()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod._3dGlassMassPurge)