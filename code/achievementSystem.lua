local mod = ARACHNAMOD
local arachnaChar = Isaac.GetPlayerTypeByName("Arachna", false)
local arachnaChar_b = Isaac.GetPlayerTypeByName("Arachna", true)
local blueBabyIsDead = false
local lambIsDead = false
-- == VARIABLES == 
mod.SavedData = {}
mod.SavedData.arachnaMarks = {}
mod.SavedData.arachnaMarksAlt = {}
local json = require("json")

local arachnaMarks = {}
local arachnaMarksAlt = {}
local markNames = { "Mom's Heart", "Isaac", "Satan", "Hush", "Greed", "Witness", "Mega Satan", "Boss Rush", "Chest", "Dark Room", "Delirium", "Beast", "All", "Two Paths", "Hush + BR", "Tainted" } -- 0 - none, 1 - normal, 2 - hard

-- == ACHIEVEMENT/MARKS RELATED FUNCTIONS ==
local function loadArachnaMarkData()
	mod.SavedData = json.decode(Isaac.LoadModData(mod))
	for i=1, #markNames do	
		if not mod.SavedData.arachnaMarks[markNames[i]] then mod.SavedData.arachnaMarks[markNames[i]] = 0 end
		if not mod.SavedData.arachnaMarks[markNames[i]] then mod.SavedData.arachnaMarks[markNames[i]] = 0 end
		arachnaMarks[markNames[i]] = mod.SavedData.arachnaMarks[markNames[i]]
		arachnaMarksAlt[markNames[i]] = mod.SavedData.arachnaMarksAlt[markNames[i]]
	end	
end

local function saveArachnaMarkData()
	for i=1, #markNames do
		if not arachnaMarks[markNames[i]] then arachnaMarks[markNames[i]] = 0 end
		if not arachnaMarksAlt[markNames[i]] then arachnaMarksAlt[markNames[i]] = 0 end
		mod.SavedData.arachnaMarks[markNames[i]] = arachnaMarks[markNames[i]]
		mod.SavedData.arachnaMarksAlt[markNames[i]] = arachnaMarksAlt[markNames[i]]
	end	
	mod.SaveData(mod, json.encode(mod.SavedData))
end

local function setAllArachnaMarkData(_num)
	for i=1, #markNames do
		arachnaMarks[markNames[i]] = _num
		arachnaMarksAlt[markNames[i]] = _num
	end
	saveArachnaMarkData()
end

local function arachnaUnlockAchievement(_markname, _tainted, _hard)
	local setVal = 1
	if _hard then 
		setVal = 2
	end
	if _tainted then
		arachnaMarksAlt[_markname] = setVal
	else
		arachnaMarks[_markname] = setVal
	end
	saveArachnaMarkData()
end

local function arachnaVisualUnlock(_unlockname, _paper)
	if GiantBookAPI then
		GiantBookAPI.ShowAchievement(_paper)
	else
		local hud = game:GetHUD()
		hud:ShowItemText(_unlockname, "HAS APPEARED IN THE BASEMENT")
	end
end

function arachnaIsUnlocked(_markname, _tainted, _hard)
	local val = 0
	local targetVal = 0
	if _tainted then
		if arachnaMarksAlt[_markname] then
			val = arachnaMarksAlt[_markname]
		end
	else
		if arachnaMarks[_markname] then
			val = arachnaMarks[_markname]
		end
	end
	if _hard then
		targetVal = 2
	else
		targetVal = 1
	end
	if val >= targetVal then
		return true
	else
		return false
	end
end

function isHardMode()
	local difficulty = game.Difficulty
	if (difficulty == Difficulty.DIFFICULTY_NORMAL) or (difficulty == Difficulty.DIFFICULTY_GREED) then
		return false
	else
		return true
	end
end

local function ValidShopKeeperVariant(variant)
    if variant == 0 -- Base shopkeeper
    or variant == 1 -- Hanging Shoopkeeper
    or variant == 3 -- Special Shoopkeeper (Nickle eyes)
    or variant == 4 then -- Hanging Special Shoopkeeper
        return true
    end
    return false
end
--===============================

-- == LOAD DATA ON GAME START ==
function mod:achievementsGameStart(isContinued) 
	if mod:HasData() then
		loadArachnaMarkData()
	else
		setAllArachnaMarkData(0)
	end
	--also these things
	blueBabyIsDead = false
	lambIsDead = false
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.achievementsGameStart)

-- == APPEAR ONLY IF UNLOCKED ==
--tainted character
local arachnaHair = 'gfx/characters/costumes/arachna-head-2.png'
--stuff related to should text be rendered or nah
local arachnaUnlockReminder = false
function mod:arachnaUnlockReminderRestart(isContinued) 
	arachnaUnlockReminder = false
	for i=0, game:GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(i)
		if (player:GetPlayerType() == arachnaChar_b) and (not arachnaIsUnlocked("Tainted", false, false)) then --morph player on game start
			removeInnateItem(player, CollectibleType.COLLECTIBLE_MUTANT_SPIDER)			
			player:ChangePlayerType(arachnaChar)
			addWebHearts(-1, player)
			player:AddSoulHearts(2)
			player:ReplaceCostumeSprite(Isaac.GetItemConfig():GetNullItem(7), arachnaHair, 0)
			player.ControlsEnabled = false
			arachnaUnlockReminder = true
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.arachnaUnlockReminderRestart)
function mod:arachnaSetBackText()
	if (game:GetLevel():GetCurrentRoomDesc().SafeGridIndex ~= 84) then
		arachnaUnlockReminder = false
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.arachnaSetBackText)
--render text
local arachnaUnlockText = Font()
arachnaUnlockText:Load("font/luaminioutlined.fnt")
function mod.arachnaReindRender()
	if arachnaUnlockReminder then
		textPos = Vector(38, 54) + (Options.HUDOffset * Vector(20, 12))
		arachnaUnlockText:DrawString("TAINTED ARACHNA WAS NOT UNLOCKED!", textPos.X + game.ScreenShakeOffset.X + 9, textPos.Y + game.ScreenShakeOffset.Y - 8, KColor(1, 1, 1, 1), 0, true)	
	end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.arachnaReindRender)
--morph coop players
function mod:arachnaBInit(player)
	if (player:GetPlayerType() == arachnaChar_b) and (not arachnaIsUnlocked("Tainted", false, false)) and (player.Index~=0) then
		removeInnateItem(player, CollectibleType.COLLECTIBLE_MUTANT_SPIDER)
		player:ChangePlayerType(arachnaChar)
		addWebHearts(-1, player)
		player:AddSoulHearts(2)
		player:ReplaceCostumeSprite(Isaac.GetItemConfig():GetNullItem(7), arachnaHair, 0)
		player.ControlsEnabled = false
		arachnaUnlockReminder = true
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.arachnaBInit)

--locking entities
function mod:replaceStuffOnSpawn(entType, variant, subType, pos, velocity, spawnerEntity, seed)
	--golden shopkeeper
	if (entType == 17) and ValidShopKeeperVariant(variant) and (subType ~= 6969) and (subType ~= 2000) and (seed ~= 4354) then --shopkeeper, but not an EID test, testament or I am error one
		if (arachnaIsUnlocked("Greed", false, true)) then
			local room = game:GetRoom()
			local roomidx = game:GetLevel():GetCurrentRoomDesc().SafeGridIndex
			--not starting room or closet
			--if (roomidx ~= 84) and ( not ((room:GetRoomShape() == 2) and (room:GetBackdropType() == 53))) then
			if (room:GetType() == RoomType.ROOM_SHOP) then
				local rng = RNG()
				rng:SetSeed(seed, 35)
				local randomNum = rng:RandomFloat()
				local replaceChance = 20
				if randomNum <= replaceChance/100 then
					return {1000, 2004, 0}
				end
			end
		end
	--spider beggar
	elseif (entType == 6) and ((variant == 4) or (variant == 7)) then --normal or key beggar
		if (arachnaIsUnlocked("Mega Satan", true, true)) then
			local rng = RNG()
			rng:SetSeed(seed, 35)
			local randomNum = rng:RandomFloat()
			local replaceChance = 20
			if randomNum <= replaceChance/100 then
				return {6, 2000, 0}
			end
		end
	--web heart
	elseif (game:GetRoom():GetType() ~= RoomType.ROOM_SUPERSECRET) and (entType == 5) and (variant == 10) and ((subType == 6) or (subType == 10) or (subType == 11) or (subType == 12)) then --black, blended, bone, rotten
		if (arachnaIsUnlocked("Mom's Heart", false, false)) then
			--replace other hearts
			local rng = RNG()
			rng:SetSeed(seed, 35)
			local randomNum = rng:RandomFloat()
			local replaceChance = 20
			--increase replace chance if someone has sprindle
			if SomeoneHasTrinket(Isaac.GetTrinketIdByName("Sprindle")) then
				replaceChance = 30
			end
			if randomNum <= replaceChance/100 then		
				--single or double
				local randomNumTwo = rng:RandomFloat()
				if randomNumTwo <= 5/100 then
					return {5, 2002, 0} --double
				else
					return {5, 2000, 0} --single
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, mod.replaceStuffOnSpawn)

--lock pickups
function mod:rerollLockedPickups(pickup) --this was based on function from andromeda mod
	--trinkets
	if pickup.Variant == 350 then
		if ((pickup.SubType == Isaac.GetTrinketIdByName("Sprindle") or pickup.SubType == Isaac.GetTrinketIdByName("Sprindle")+TrinketType.TRINKET_GOLDEN_FLAG) and (not arachnaIsUnlocked("Two Paths", true, true)))
		or ((pickup.SubType == Isaac.GetTrinketIdByName("Infested Penny") or pickup.SubType == Isaac.GetTrinketIdByName("Infested Penny")+TrinketType.TRINKET_GOLDEN_FLAG) and (not arachnaIsUnlocked("Greed", false, false)))
		or ((pickup.SubType == Isaac.GetTrinketIdByName("White String") or pickup.SubType == Isaac.GetTrinketIdByName("White String")+TrinketType.TRINKET_GOLDEN_FLAG) and (not arachnaIsUnlocked("Dark Room", false, false))) then
			pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, true, false, true)
		end
	--cards/runes
	elseif pickup.Variant == 300 then
		if ((pickup.SubType == Isaac.GetCardIdByName("Merged Card")) and (not arachnaIsUnlocked("Greed", true, true))) 
		or ((pickup.SubType == Isaac.GetCardIdByName("Soul of Arachna")) and (not arachnaIsUnlocked("Hush + BR", true, true))) then
			local rune = game:GetItemPool():GetCard(pickup.InitSeed, false, true, true)
			if pickup.SubType == Isaac.GetCardIdByName("Merged Card") then
				rune = 0
			end
			pickup:Morph(5, 300, rune, true, false, true)
		end
	--items
	elseif pickup.Variant == 100 or pickup.Variant == 150 then
		if ((pickup.SubType == Isaac.GetItemIdByName("Arachna's Spool")) and (not arachnaIsUnlocked("Isaac", false, false)))
		or ((pickup.SubType == Isaac.GetItemIdByName("The Yarn")) and (not arachnaIsUnlocked("Satan", false, false)))
		or ((pickup.SubType == Isaac.GetItemIdByName("Arachnid's Grip")) and (not arachnaIsUnlocked("Hush", false, false)))
		or ((pickup.SubType == Isaac.GetItemIdByName("Yarn Heart")) and (not arachnaIsUnlocked("Witness", false, false)))
		or ((pickup.SubType == Isaac.GetItemIdByName("Mechanical Eye")) and (not arachnaIsUnlocked("Mega Satan", false, false)))
		or ((pickup.SubType == Isaac.GetItemIdByName("Geptameron")) and (not arachnaIsUnlocked("Boss Rush", false, false)))
		or ((pickup.SubType == Isaac.GetItemIdByName("3D Glasses")) and (not arachnaIsUnlocked("Chest", false, false)))
		or ((pickup.SubType == Isaac.GetItemIdByName("Mutagen")) and (not arachnaIsUnlocked("Delirium", false, false)))
		or ((pickup.SubType == Isaac.GetItemIdByName("Testament")) and (not arachnaIsUnlocked("Beast", false, false)))
		or ((pickup.SubType == Isaac.GetItemIdByName("Lil Arachna")) and (not arachnaIsUnlocked("All", false, false)))
		or ((pickup.SubType == Isaac.GetItemIdByName("Divine Cloth")) and (not arachnaIsUnlocked("Hush", true, true)))
		or ((pickup.SubType == Isaac.GetItemIdByName("Dad's Newspaper")) and (not arachnaIsUnlocked("Witness", true, true)))
		or ((pickup.SubType == Isaac.GetItemIdByName("Best Bud Ball")) and (not arachnaIsUnlocked("Beast", true, true))) then
			local pool = game:GetItemPool():GetPoolForRoom(game:GetRoom():GetType(), game:GetSeeds():GetStartSeed())
			if pool == ItemPoolType.POOL_NULL then
				pool = ItemPoolType.POOL_TREASURE
			end
			local newItem = game:GetItemPool():GetCollectible(pool, true, pickup.InitSeed)
			pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, newItem, true, false, true)
		end	
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.rerollLockedPickups)

-- == UNLOCK CHECK ==
--TAINTED UNLOCK
function arachnaInCloset()
	local room = game:GetRoom()
	--if you're arachna, you're in home and tainted version was not unlocked
	if (not arachnaIsUnlocked("Tainted", false, false)) and (game:GetLevel():GetStage() == 13) and (Isaac.GetPlayer(0):GetPlayerType() == arachnaChar) then
		--if you're entering the dark closet for the first time
		if (room:GetRoomShape() == 2) and (room:GetBackdropType() == 53) then
			return true
		end
	end
	return false
end
--on closet enter
local function spawnLayingArachna(_par)
	local isaacLay = Isaac.Spawn(6, 14, 0, _par.Position, Vector(0,0), nil)
	isaacLay:GetSprite():ReplaceSpritesheet(0, "gfx/characters/costumes/character_arachna_b.png")
	isaacLay:GetSprite():LoadGraphics()
	_par:Remove()
end
function mod:closetTaintedArachna()
	if arachnaInCloset() and (game:GetRoom():IsFirstVisit()) then
		--replace shopkeeper or a pedestal with a laying isaac
		local wasReplaced = false
		for _, ent in pairs(Isaac.FindByType(17, -1, -1, false, false)) do	
			if not wasReplaced then
				spawnLayingArachna(ent)
			end
		end
		for _, ent in pairs(Isaac.FindByType(5, 100, -1, false, false)) do	
			if not wasReplaced then
				spawnLayingArachna(ent)
			end
		end
	end 
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.closetTaintedArachna)
--laying isaac update (replace sprite, do unlock)
function mod:layingIsaacUpdate()
	if arachnaInCloset() then
		local tainteds = Isaac.FindByType(6, 14)
		for _, ent in pairs(tainteds) do
			local sprite = ent:GetSprite()
			local data = ent:GetData()
			--init
			if not data.init then
				sprite:ReplaceSpritesheet(0, "gfx/characters/costumes/character_arachna_b.png")
				sprite:LoadGraphics()
				data.init = true
			end
			--UNLOCK ON ANIMATION END
			if sprite:IsFinished ("PayPrize") then
				arachnaUnlockAchievement("Tainted", false, false)
				arachnaVisualUnlock("TAINTED ARACHNA", "arachna_normal/tainted.png")
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.layingIsaacUpdate)

function mod:marksBossDeath(npc)
	local playerType = Isaac.GetPlayer(0):GetPlayerType()
	local stageNum = game:GetLevel():GetStage()
	if ((playerType == arachnaChar) or (playerType == arachnaChar_b)) and (game:GetVictoryLap() == 0) then
		--MOM'S HEART
		if stageNum == LevelStage.STAGE4_2 then
			if (npc.Type == 78) and ((npc.Variant == 0) or (npc.Variant == 1)) then
				--normal
				if (playerType == arachnaChar) then
					--visual
					if (not arachnaIsUnlocked("Mom's Heart", false, false)) then
						arachnaVisualUnlock("WEB HEART", "arachna_normal/momsheart.png")	
					end
					--action
					if (not arachnaIsUnlocked("Mom's Heart", false, isHardMode())) then
						arachnaUnlockAchievement("Mom's Heart", false, isHardMode())
					end
				--tainted version doesn't have heart unlock, so it doesn't need it
				end
			end
		elseif stageNum == LevelStage.STAGE5 then
			--ISAAC
			if (npc.Type == 102) and (npc.Variant == 0) then
				--normal
				if (playerType == arachnaChar) then
					--visual
					if (not arachnaIsUnlocked("Isaac", false, false)) then
						arachnaVisualUnlock("ARACHNA'S SPOOL", "arachna_normal/isaac.png")	
					end
					--action
					if (not arachnaIsUnlocked("Isaac", false, isHardMode())) then
						arachnaUnlockAchievement("Isaac", false, isHardMode())
					end
				--tainted
				elseif (playerType == arachnaChar_b) then
					--action
					if (not arachnaIsUnlocked("Isaac", true, isHardMode())) then
						arachnaUnlockAchievement("Isaac", true, isHardMode())
					end
				end
			--SATAN
			elseif (npc.Type == 84) then
				--normal
				if (playerType == arachnaChar) then
					--visual
					if (not arachnaIsUnlocked("Satan", false, false)) then
						arachnaVisualUnlock("THE YARN", "arachna_normal/satan.png")	
					end
					--action
					if (not arachnaIsUnlocked("Satan", false, isHardMode())) then
						arachnaUnlockAchievement("Satan", false, isHardMode())
					end
				--tainted
				elseif (playerType == arachnaChar_b) then
					--action
					if (not arachnaIsUnlocked("Satan", true, isHardMode())) then
						arachnaUnlockAchievement("Satan", true, isHardMode())
					end
				end
			end
		elseif stageNum == LevelStage.STAGE6 then
			--CHEST (1/2)
			if (npc.Type == 102) and (npc.Variant == 1) then
				blueBabyIsDead = true
			--DARK ROOM (1/2)
			elseif (npc.Type == 273) then
				lambIsDead = true
			--MEGA SATAN
			elseif (npc.Type == 275) and (npc.Variant == 0) then
				--normal
				if (playerType == arachnaChar) then
					--visual
					if (not arachnaIsUnlocked("Mega Satan", false, false)) then
						arachnaVisualUnlock("MECHANICAL EYE", "arachna_normal/megasatan.png")	
					end
					--action
					if (not arachnaIsUnlocked("Mega Satan", false, isHardMode())) then
						arachnaUnlockAchievement("Mega Satan", false, isHardMode())
					end
				--tainted
				elseif (playerType == arachnaChar_b) then
					--visual
					if (not arachnaIsUnlocked("Mega Satan", true, true)) then
						arachnaVisualUnlock("SPIDER BEGGAR", "arachna_alt/megasatan.png")	
					end
					--action
					if (not arachnaIsUnlocked("Mega Satan", true, isHardMode())) then
						arachnaUnlockAchievement("Mega Satan", true, isHardMode())
					end
				end				
			end
		--DELIRIUM
		elseif (stageNum == LevelStage.STAGE7) then
			if (npc.Type == 412) then
				--normal
				if (playerType == arachnaChar) then
					--visual
					if (not arachnaIsUnlocked("Delirium", false, false)) then
						arachnaVisualUnlock("MUTAGEN", "arachna_normal/delirium.png")	
					end
					--action
					if (not arachnaIsUnlocked("Delirium", false, isHardMode())) then
						arachnaUnlockAchievement("Delirium", false, isHardMode())
					end
				--tainted
				elseif (playerType == arachnaChar_b) then
					--visual
					if (not arachnaIsUnlocked("Delirium", true, true)) then
						arachnaVisualUnlock("DIVINE CLOTH", "arachna_alt/delirium.png")	
					end
					--action
					if (not arachnaIsUnlocked("Delirium", true, isHardMode())) then
						arachnaUnlockAchievement("Delirium", true, isHardMode())
					end
				end					
			end
		--WITNESS
		elseif (stageNum == LevelStage.STAGE4_1 or stageNum == LevelStage.STAGE4_2) then
			if (npc.Type == 912) and (npc.Variant == 10) then
				--normal
				if (playerType == arachnaChar) then
					--visual
					if (not arachnaIsUnlocked("Witness", false, false)) then
						arachnaVisualUnlock("YARN HEART", "arachna_normal/witness.png")	
					end
					--action
					if (not arachnaIsUnlocked("Witness", false, isHardMode())) then
						arachnaUnlockAchievement("Witness", false, isHardMode())
					end
				--tainted
				elseif (playerType == arachnaChar_b) then
					--visual
					if (not arachnaIsUnlocked("Witness", true, true)) then
						arachnaVisualUnlock("DAD'S NEWSPAPER", "arachna_alt/witness.png")	
					end
					--action
					if (not arachnaIsUnlocked("Witness", true, isHardMode())) then
						arachnaUnlockAchievement("Witness", true, isHardMode())
					end
				end					
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.marksBossDeath)

function mod:arachnaMarksConstantCheck()
	local playerType = Isaac.GetPlayer(0):GetPlayerType()
	if ((playerType == arachnaChar) or (playerType == arachnaChar_b)) then
		local room = game:GetRoom()
		local stage = game:GetLevel()
		if game:GetVictoryLap() == 0 then
			if stage:GetStage() == LevelStage.STAGE6 and room:GetType() == RoomType.ROOM_BOSS and room:IsClear() then
				--CHEST (2/2)
				if blueBabyIsDead then
					--normal
					if (playerType == arachnaChar) then
						--visual
						if (not arachnaIsUnlocked("Chest", false, false)) then
							arachnaVisualUnlock("3D GLASSES", "arachna_normal/chest.png")	
						end
						--action
						if (not arachnaIsUnlocked("Chest", false, isHardMode())) then
							arachnaUnlockAchievement("Chest", false, isHardMode())
						end
					--tainted
					elseif (playerType == arachnaChar_b) then
						--action
						if (not arachnaIsUnlocked("Chest", true, isHardMode())) then
							arachnaUnlockAchievement("Chest", true, isHardMode())
						end
					end						
					blueBabyIsDead = false
				--DARK ROOM (2/2)
				elseif lambIsDead then
					--normal
					if (playerType == arachnaChar) then
						--visual
						if (not arachnaIsUnlocked("Dark Room", false, false)) then
							arachnaVisualUnlock("WHITE STRING", "arachna_normal/darkroom.png")	
						end
						--action
						if (not arachnaIsUnlocked("Dark Room", false, isHardMode())) then
							arachnaUnlockAchievement("Dark Room", false, isHardMode())
						end
					--tainted
					elseif (playerType == arachnaChar_b) then
						--action
						if (not arachnaIsUnlocked("Dark Room", true, isHardMode())) then
							arachnaUnlockAchievement("Dark Room", true, isHardMode())
						end
					end	
					lambIsDead = false
				end
			end
			--BOSS RUSH
			if game:GetStateFlag(GameStateFlag.STATE_BOSSRUSH_DONE) and (stage:GetStage() == LevelStage.STAGE3_1 or stage:GetStage() == LevelStage.STAGE3_2) then
				--normal
				if (playerType == arachnaChar) then
					--visual
					if (not arachnaIsUnlocked("Boss Rush", false, false)) then
						arachnaVisualUnlock("GEPTAMERON", "arachna_normal/br.png")	
					end
					--action
					if (not arachnaIsUnlocked("Boss Rush", false, isHardMode())) then
						arachnaUnlockAchievement("Boss Rush", false, isHardMode())
					end
				--tainted
				elseif (playerType == arachnaChar_b) then
					--action
					if (not arachnaIsUnlocked("Boss Rush", true, isHardMode())) then
						arachnaUnlockAchievement("Boss Rush", true, isHardMode())
					end
				end					
			end
			--HUSH
			if game:GetStateFlag(GameStateFlag.STATE_BLUEWOMB_DONE) and stage:GetStage() == LevelStage.STAGE4_3 then
				--normal
				if (playerType == arachnaChar) then
					--visual
					if (not arachnaIsUnlocked("Hush", false, false)) then
						arachnaVisualUnlock("ARACHNID'S GRIP", "arachna_normal/hush.png")	
					end
					--action
					if (not arachnaIsUnlocked("Hush", false, isHardMode())) then
						arachnaUnlockAchievement("Hush", false, isHardMode())
					end
				--tainted
				elseif (playerType == arachnaChar_b) then
					--action
					if (not arachnaIsUnlocked("Hush", true, isHardMode())) then
						arachnaUnlockAchievement("Hush", true, isHardMode())
					end
				end					
			end		
			--GREED AND GREEDIER
			if game:IsGreedMode() and stage:GetStage() == LevelStage.STAGE7_GREED then
				if room:GetRoomShape() == RoomShape.ROOMSHAPE_1x2 and room:IsClear() then
					--normal
					if (playerType == arachnaChar) then
						--visual
						if (not arachnaIsUnlocked("Greed", false, false)) then
							arachnaVisualUnlock("INFESTED PENNY", "arachna_normal/greed.png")	
						end
						if (not arachnaIsUnlocked("Greed", false, true)) and (isHardMode()) then
							arachnaVisualUnlock("EXTRA SPECIAL SHOPKEEPERS", "arachna_normal/greedier.png")	
						end
						--action
						if (not arachnaIsUnlocked("Greed", false, isHardMode())) then
							arachnaUnlockAchievement("Greed", false, isHardMode())
						end	
					--tainted
					elseif (playerType == arachnaChar_b) then
						--visual
						if (not arachnaIsUnlocked("Greed", true, true)) then
							arachnaVisualUnlock("MERGED CARD", "arachna_alt/greedier.png")	
						end
						--action
						if (not arachnaIsUnlocked("Greed", true, isHardMode())) then
							arachnaUnlockAchievement("Greed", true, isHardMode())
						end	
					end
				end
			end
			--ALL ON HARD MODE
			if (arachnaIsUnlocked("Mom's Heart", false, true)) and (arachnaIsUnlocked("Isaac", false, true)) and (arachnaIsUnlocked("Satan", false, true)) and (arachnaIsUnlocked("Chest", false, true)) and (arachnaIsUnlocked("Dark Room", false, true)) and (arachnaIsUnlocked("Hush", false, true)) and (arachnaIsUnlocked("Boss Rush", false, true)) and (arachnaIsUnlocked("Mega Satan", false, true)) and (arachnaIsUnlocked("Greed", false, true)) and (arachnaIsUnlocked("Beast", false, true)) and (arachnaIsUnlocked("Delirium", false, true)) and (arachnaIsUnlocked("Witness", false, true)) and (not arachnaIsUnlocked("All", false, true)) then
				arachnaUnlockAchievement("All", false, true)
				arachnaVisualUnlock("LIL ARACHNA", "arachna_normal/all.png")
			end	
			--TWO PATHS
			if (arachnaIsUnlocked("Isaac", true, true)) and (arachnaIsUnlocked("Satan", true, true)) and (arachnaIsUnlocked("Chest", true, true)) and (arachnaIsUnlocked("Dark Room", true, true)) and (not arachnaIsUnlocked("Two Paths", true, true)) then
				arachnaUnlockAchievement("Two Paths", true, true)
				arachnaVisualUnlock("SPRINDLE", "arachna_alt/twopaths.png")	
			end
			--HUSH + BOSS RUSH
			if (arachnaIsUnlocked("Hush", true, true)) and (arachnaIsUnlocked("Boss Rush", true, true)) and (not arachnaIsUnlocked("Hush + BR", true, true)) then
				arachnaUnlockAchievement("Hush + BR", true, true)
				arachnaVisualUnlock("SOUL OF ARACHNA", "arachna_alt/hush+br.png")
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.arachnaMarksConstantCheck)

--BEAST
function mod:postDeath(ent)
	for i = 0, game:GetNumPlayers() - 1 do
		local playerType = Isaac.GetPlayer(0):GetPlayerType()
		if ((playerType == arachnaChar) or (playerType == arachnaChar_b)) and (game:GetVictoryLap() == 0) and (ent.Variant == 0) then
			--normal
			if (playerType == arachnaChar) then
				--visual
				if (not arachnaIsUnlocked("Beast", false, false)) then
					arachnaVisualUnlock("TESTAMENT", "arachna_normal/beast.png")	
				end
				--action
				if (not arachnaIsUnlocked("Beast", false, isHardMode())) then
					arachnaUnlockAchievement("Beast", false, isHardMode())
				end
			--tainted
			elseif (playerType == arachnaChar_b) then
				--visual
				if (not arachnaIsUnlocked("Beast", true, true)) then
					arachnaVisualUnlock("BEST BUD BALL", "arachna_alt/beast.png")	
				end
				--action
				if (not arachnaIsUnlocked("Beast", true, isHardMode())) then
					arachnaUnlockAchievement("Beast", true, isHardMode())
				end
			end				
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mod.postDeath, EntityType.ENTITY_BEAST)

-- == DEBUG COMMANDS == 
function mod:unlocksOnCmd(cmd, text)
	if cmd == "arachnaMod" then
		if text == "unlockall" then
			Isaac.ConsoleOutput("Setting all mark data to be unlocked on hard mode... \n")
			setAllArachnaMarkData(2)
			Isaac.ConsoleOutput("Done! \n")
		elseif text == "unlocktainted" then
			if (arachnaIsUnlocked("Tainted", false, false)) then
				Isaac.ConsoleOutput("You've already unlocked this character, dummy! \n")
			else
				Isaac.ConsoleOutput("Unlocking Tainted Arachna... \n")
				arachnaUnlockAchievement("Tainted", false, false)
				Isaac.ConsoleOutput("Done! \n")
			end
		elseif text == "lockall" then
			Isaac.ConsoleOutput("Setting all mark data back to the locked state... \n")
			setAllArachnaMarkData(0)
			Isaac.ConsoleOutput("Done! \n")
		else
			Isaac.ConsoleOutput("Woops, looks like you messed up some command. Try again! \n")
		end
	end
end
mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, mod.unlocksOnCmd)