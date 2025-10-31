local mod = ARACHNAMOD
local game = ARACHNAMOD.game
local sfx = ARACHNAMOD.sfx
local geptameronItem = Isaac.GetItemIdByName("Geptameron")

--render
local geptameronUI = Sprite()
geptameronUI:Load("gfx/geptameron_ui.anm2", true)
geptameronUI:LoadGraphics()
geptameronUI:SetFrame("Idle", 1)
local geptameronUIText = Font()
geptameronUIText:Load("font/pftempestasevencondensed.fnt")
local geptameronDayText = Font()
geptameronDayText:Load("font/luaminioutlined.fnt")
function mod.geptameronUIRender()
	if (SomeoneHasItem(geptameronItem)) and (not versusScreenPlaying()) then
		--icon
		local geptameronUIPos = Vector(38, 65) + (Options.HUDOffset * Vector(20, 12))
		if not geptameronUI:IsPlaying("UI") then
			geptameronUI:Play("UI", true)	
		end
		geptameronUI:Update()
		--add some corrections if someone is holding tab
		if someonePressedAction(ButtonAction.ACTION_MAP, true) then
			--put pos higher
			geptameronUIPos = Vector(38, 54) + (Options.HUDOffset * Vector(20, 12))
			--day name 
			local geptameronDayNames = {"Mighty Monday", "Terrific Tuesday", "Wise Wednesday", "Torrid Thursday", "Fleeting Friday", "Sanguineous Saturday", "Stingy Sunday"}
			geptameronDayText:DrawString(geptameronDayNames[mod.Globals.geptameronDay], geptameronUIPos.X + game.ScreenShakeOffset.X - 5, geptameronUIPos.Y + game.ScreenShakeOffset.Y + 2, KColor(1, 1, 1, 1), 0, true)	
		end
		geptameronUI:Render(geptameronUIPos + game.ScreenShakeOffset*0.1, Vector(0,0), Vector(0,0))
		--day number
		geptameronUIText:DrawString("[" .. tostring(mod.Globals.geptameronDay) .. "/7]", geptameronUIPos.X + game.ScreenShakeOffset.X + 9, geptameronUIPos.Y + game.ScreenShakeOffset.Y - 8, KColor(1, 1, 1, 1), 0, true)	
	end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.geptameronUIRender)

--increase day
local function geptameronChangeDay()
	if mod.Globals.geptameronDay == 7 then
		mod.Globals.geptameronDay = 1
	else
		mod.Globals.geptameronDay = mod.Globals.geptameronDay + 1
	end
end
--normal
function mod:geptameronDayIncrease(rng, spawnpos)
	geptameronChangeDay()
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.geptameronDayIncrease)
--greed
local curWave = 0
function mod:geptameronResetWave()
	curWave = 0
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.geptameronResetWave)
function mod:geptameronDayIncreaseGreed()
	if game:IsGreedMode() then
		local realWave = game:GetLevel().GreedModeWave
		if realWave ~= curWave then
			geptameronChangeDay()
			curWave = realWave
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.geptameronDayIncreaseGreed)

--holy marks
local spawnHolyMarks = false
local function createHolyMark(_frames, _pos)
	local mark = Isaac.Spawn(1000, 2007, 0, _pos, Vector(0,0), nil):ToEffect()
	mark:AddEntityFlags(EntityFlag.FLAG_BACKDROP_DETAIL)
	mark.DepthOffset = -250
	mark:GetSprite():Play("Blink", true)
	mark:Update()
	mark:GetData().deathFrame = _frames
end
--target
function mod:holyShotTarget(eff)
	local data = eff:GetData()
	if data.deathFrame then
		if eff.FrameCount+15 == data.deathFrame then
			local skyCrack = Isaac.Spawn(1000, 19, 0, eff.Position, Vector(0,0), Isaac.GetPlayer(0)):ToEffect()
			skyCrack.CollisionDamage = 3.25 + game:GetLevel():GetStage()*0.25
		end
		if eff.FrameCount == data.deathFrame then
			eff:Remove()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.holyShotTarget, 2007)
--spawnem
function mod:holyMarksAppear()
	if spawnHolyMarks == true then
		if game:GetFrameCount() % 10 == 0 then
			createHolyMark(30, Isaac.GetFreeNearPosition(Isaac.GetRandomPosition(), 50))
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.holyMarksAppear)
--
local tempWispItem = {}
local tempWispPlayer = {}
--clear 
local function clearGeptameronUses()
	--clear lemegeton wisps
	local j = 1
	while j <= #tempWispItem do
		local clearHappened = false
		for _, ent in pairs(Isaac.FindByType(3, 237, tempWispItem[j], false, false)) do
			if ent:ToFamiliar().Player.Index == tempWispPlayer[j] then
				ent:TakeDamage(ent.HitPoints+1, 0, EntityRef(Isaac.GetPlayer(tempWispPlayer[j])), 0)
				clearHappened = true
			end
		end
		if not clearHappened then
			j = j + 1
		end
	end
	tempWispItem = {}
	tempWispPlayer = {}
	--clear stats
	for i=0, game:GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(i)
		local data = mod:GetData(player)
		data.geptameronUses = 0
		data.geptameronSpeed = 0
		data.geptameronShotSpeed = 0
		data.geptameronTearDelay = 0
		data.geptameronDamage = 0
		data.geptameronRange = 0
		player:AddCacheFlags(CacheFlag.CACHE_ALL)
		player:EvaluateItems()
	end
	--clear holy marks spawn
	spawnHolyMarks = false
end
--wisps remove themselves on death
function mod:geptameronWispDeath(ent, amount, flags, src, countdown)
	if (ent:ToFamiliar()) and (ent.Variant == 237) then
		if (ent.HitPoints <= amount) then
			local j = 1
			while j <= #tempWispItem do
				local clearHappened = false
				if (ent.SubType == tempWispItem[j]) and (ent:ToFamiliar().Player.Index == tempWispPlayer[j]) then
					table.remove(tempWispItem, j)
					table.remove(tempWispPlayer, j)
					break
				end
				j = j + 1
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.geptameronWispDeath)

function mod:geptameronClearOnNewRoom()
	clearGeptameronUses()
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.geptameronClearOnNewRoom)

function mod:geptameronClearGameExit(shouldSave) 
	clearGeptameronUses()
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.geptameronClearGameExit)
--cache
function mod:geptameronCache(player, cacheFlag)
	local data = mod:GetData(player)
	if cacheFlag == CacheFlag.CACHE_SPEED and data.geptameronSpeed then
		player.MoveSpeed = player.MoveSpeed + data.geptameronSpeed
	end
	if cacheFlag == CacheFlag.CACHE_SHOTSPEED and data.geptameronShotSpeed then
		player.ShotSpeed = player.ShotSpeed + data.geptameronShotSpeed
	end
	if cacheFlag == CacheFlag.CACHE_FIREDELAY and data.geptameronTearDelay then
		player.MaxFireDelay = player.MaxFireDelay - data.geptameronTearDelay
	end
	if cacheFlag == CacheFlag.CACHE_DAMAGE and data.geptameronDamage then
		player.Damage = player.Damage + data.geptameronDamage
	end
	if cacheFlag == CacheFlag.CACHE_RANGE and data.geptameronRange then
		player.TearRange = player.TearRange + data.geptameronRange
	end
end	
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.geptameronCache)

--item use
function mod:useGeptameron(item, rng, player) 
	local data = mod:GetData(player)
	--always effect
	if not data.geptameronUses then data.geptameronUses = 1 else data.geptameronUses = data.geptameronUses + 1 end
	--give wings + flight. this is done in a relly hacky way, but I really don't know what else could be done here.
	if data.geptameronUses == 1 then
		player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_GRAIL, true, 1)
		player:UseCard(Card.CARD_HANGED_MAN, UseFlag.USE_NOCOSTUME | UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	end
	--action
	if mod.Globals.geptameronDay == 1 then
		--stats
		data.geptameronSpeed = data.geptameronUses*0.10
		data.geptameronShotSpeed = data.geptameronUses*0.50
		data.geptameronTearDelay = data.geptameronUses*0.15
		data.geptameronDamage = data.geptameronUses*0.95
		data.geptameronRange = data.geptameronUses*0.75
		player:AddCacheFlags(CacheFlag.CACHE_ALL)
		player:EvaluateItems()
		--give wisps
		local angelItems = {162, 185, 331, 156, 173, 182, 142, 101, 333, 335, 108, 243, 387, 423, 415, 374, 400, 392, 528, 533, 634, 643, 696} 
		for i=1, 2 do
			local choice = rng:RandomInt(#angelItems)+1
			player:AddItemWisp(angelItems[choice], player.Position)
			tempWispItem[#tempWispItem+1] = angelItems[choice]
			tempWispPlayer[#tempWispPlayer+1] = player.Index
			table.remove(angelItems, choice)
		end
	elseif mod.Globals.geptameronDay == 2 then
		spawnHolyMarks = true
	elseif mod.Globals.geptameronDay == 3 then
		local enemies = Isaac.GetRoomEntities()
		for i=1, #enemies do
			local enemy = enemies[i]
			if enemy:ToNPC() and enemy.Type ~= EntityType.ENTITY_FIREPLACE then
				local skyCrack = Isaac.Spawn(1000, 19, 0, enemy.Position, Vector(0,0), player):ToEffect()
				skyCrack.CollisionDamage = clamp(player.Damage*2, 1.5, 12.5)
				enemy:AddSlowing(EntityRef(player), 300, 0.5, Color(1, 1, 1, 1, 0.2, 0.2, 0.2))
			end
		end
		for i=2, 29 do
			displayRoomType(i)
		end
		player:UseActiveItem(CollectibleType.COLLECTIBLE_DADS_KEY, false, false, true, false, -1)
	elseif mod.Globals.geptameronDay == 4 then
		local angelFamiliars = {112, 390, 363, 543}
		for i=1, 2 do
			local choice = rng:RandomInt(#angelFamiliars)+1
			player:GetEffects():AddCollectibleEffect(angelFamiliars[choice], true, 1)
			table.remove(angelFamiliars, choice)
		end
		player:UseCard(Card.CARD_HOLY, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	elseif mod.Globals.geptameronDay == 5 then
		tryAddGoldMark()
	elseif mod.Globals.geptameronDay == 6 then
		for dir = 0, 360, 45 do
			local laser = EntityLaser.ShootAngle(5, player.Position, dir, 20, Vector(0,0), player):ToLaser()
			laser.CollisionDamage = clamp(player.Damage*1.2, 1.5, 8.5)
		end
	elseif mod.Globals.geptameronDay == 7 then
		local enemies = Isaac.GetRoomEntities()
		for i=1, #enemies do
			local ent = enemies[i]
			local data = ent:GetData()
			if (ent:IsVulnerableEnemy()) and (not ent:IsBoss()) and (not data.dropRandomPickup) and (ent.MaxHitPoints >= 10) and (ent.Type ~= 853) and (ent.Type ~= EntityType.ENTITY_FIREPLACE) then
				local poof = Isaac.Spawn(1000, 16, 1, ent.Position, Vector(0,0), ent):ToEffect() 
				poof.SpriteScale = poof.SpriteScale*0.7 
				data.dropRandomPickup = true
			end
		end
	end
	--visual
	sfx:Play(SoundEffect.SOUND_SUPERHOLY, 1, 0, false, 1)
	if GiantBookAPI then
		GiantBookAPI.playGiantBook("Appear", "giantbook_geptameron.png", Color(0.8, 0.6, 0, 1, 0, 0, 0), Color(0.5, 0.28, 0.5, 1, 0, 0, 0), Color(0.8, 0.6, 0, 0.8, 0, 0, 0), SoundEffect.SOUND_BOOK_PAGE_TURN_12)
	end
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.useGeptameron, geptameronItem)

--render
local geptameronPickupmMark = Sprite()
geptameronPickupmMark:Load("gfx/icon_tempDrops.anm2",true)
geptameronPickupmMark:LoadGraphics()
function mod:geptameronPickupMarkRender(npc)
	local data = npc:GetData()
	local frameToRender = -1
	if data.shouldDropCoin and data.dropRandomPickup then
		geptameronPickupmMark:SetFrame("UI", 2)
	elseif data.shouldDropCoin then
		geptameronPickupmMark:SetFrame("UI", 0)
	elseif data.dropRandomPickup then
		geptameronPickupmMark:SetFrame("UI", 1)
	end
	if data.shouldDropCoin or data.dropRandomPickup then
		geptameronPickupmMark:Render(Isaac.WorldToScreen(npc.Position), Vector(0,0), Vector(0,0))
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, mod.geptameronPickupMarkRender)

--on death
function mod:geptameronPickupDeath(npc)
	local data = npc:GetData()
	if npc:IsDead() then
		--coin
		if data.shouldDropCoin then
			local coinAmount = clamp(math.ceil(npc.MaxHitPoints/20), 1, 4)
			local i = 1
				while i <= coinAmount do
				local dropvelocity = Vector.FromAngle(mod:GetRandomNumber(0, 360, mod.Globals.garbageRNG))*(-1)*mod:GetRandomNumber(5, 8, mod.Globals.garbageRNG)
				local pickup = Isaac.Spawn(5, 20, 1, npc.Position, dropvelocity, npc):ToPickup()
				pickup.Timeout = 45	
				i = i+1
			end
			game:SpawnParticles(npc.Position, 98, mod:GetRandomNumber(4, 7, mod.Globals.garbageRNG), 4)
			sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.6, 0, false, 1)
			tryAddGoldMark()
		end
		--random pickup
		if data.dropRandomPickup then
			local dropvelocity = Vector.FromAngle(mod:GetRandomNumber(0, 360, mod.Globals.garbageRNG))*(-1)*mod:GetRandomNumber(3, 5, mod.Globals.garbageRNG)
			local pickupVariants = {20, 30, 40, 70, 300}
			local rng = RNG()
			rng:SetSeed(npc.InitSeed, 35)
			local pickup = Isaac.Spawn(5, pickupVariants[rng:RandomInt(#pickupVariants)+1], 0, npc.Position, dropvelocity, npc):ToPickup()
			pickup.Timeout = 50			
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.geptameronPickupDeath)

--debug
--[[
function mod:geptameronDayCmd(cmd, text)
	local command = tostring(cmd)
	local amount = tonumber(text)
	if (command == "geptaday") and (amount) then
		mod.Globals.geptameronDay = clamp(amount, 1, 7)
	end
end
mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, mod.geptameronDayCmd)
]]