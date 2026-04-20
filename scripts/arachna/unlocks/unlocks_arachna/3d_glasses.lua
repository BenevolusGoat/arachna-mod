local Mod = ArachnaMod

local GLASSES_3D = {}

ArachnaMod.Item.GLASSES_3D = GLASSES_3D

GLASSES_3D.ID = Isaac.GetItemIdByName("3D Glasses")

GLASSES_3D.MODIFIER = ArachnaMod.TearModifier.New({
	Name = "3D Glasses",
	Items = { GLASSES_3D.ID },
	MinChance = 0.05,
	MaxChance = 0.25,
	MinLuck = 0,
	MaxLuck = 20,
	ShouldAffectBombs = true
})

function GLASSES_3D.MODIFIER:PostRender(object, renderOffset)
	local data = Mod:GetData(object)
	if data.GlassesRender then return end
	local originalColor = object.Color
	data.GlassesRender = true
	local offset = Vector(object.Size / 1.5, object.Size / 4)
	object:GetSprite().Color = Color(0.3, 0.1, 0.1, 0.4, 0.8, 0, 0)
	object:Render(renderOffset + offset * -1)
	object:GetSprite().Color = Color(0.1, 0.1, 0.3, 0.2, 0, 0, 0.8)
	object:Render(renderOffset + offset)
	object:GetSprite().Color = originalColor
	data.GlassesRender = false
end

---@param npc EntityNPC
---@param vel Vector
---@param color Color
function GLASSES_3D:SpawnEnemyCopy(npc, vel, spawner, color)
	local copy = Mod.Game:Spawn(npc.Type, npc.Variant, npc.Position, vel, spawner, npc.SubType, Mod:Random()):ToNPC()
	---@cast copy EntityNPC
	if npc:GetChampionColorIdx() ~= -1 then
		copy:MakeChampion(copy.InitSeed, npc:GetChampionColorIdx(), true)
	end
	---@cast copy EntityNPC
	copy:GetSprite().Color = color
	copy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	copy:AddEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY)
	copy:Update()
	local smoke = Mod.Spawn.Poof02(2, copy.Position + Vector(0, -30))
	smoke.Color = color
	smoke.SpriteScale = smoke.SpriteScale / 1.5
	Mod:GetData(copy).GlassesCopy = true
end

function GLASSES_3D.MODIFIER:PostNpcHit(hitter, npc)
	if not npc:IsBoss() then
		local player = Mod:TryGetPlayer(hitter, { WeaponOwner = true })
		---@cast player EntityPlayer
		Mod.sfxman:Play(SoundEffect.SOUND_SUMMON_POOF, 0.5, 2, false, 3)
		GLASSES_3D:SpawnEnemyCopy(npc, Vector(-15, 0), player, Color(0.5, 0.3, 0.3, 0.8, 0.3, 0, 0))
		GLASSES_3D:SpawnEnemyCopy(npc, Vector(15, 0), player, Color(0.3, 0.3, 0.5, 0.8, 0, 0, 0.3))
		npc:Remove()
	end
end

---@param npc EntityNPC
function GLASSES_3D:DisappearOnRoomClear(npc)
	local data = Mod:TryGetData(npc)
	if data and data.GlassesCopy and Mod.Room():IsClear() then
		local smoke = Mod.Spawn.Poof02(2, npc.Position + Vector(0, -30))
		smoke.Color = npc:GetSprite().Color
		smoke.SpriteScale = smoke.SpriteScale / 1.5
		Mod.sfxman:Play(SoundEffect.SOUND_SUMMON_POOF, 0.5, 2, false, 1.5)
		Mod.sfxman:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.8, 2, false, 0.8)
		npc:Remove()
	end
end

Mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, GLASSES_3D.DisappearOnRoomClear)

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function GLASSES_3D:StopDamageToCopy(ent, amount, flags, source, countdown)
	local data = Mod:TryGetData(ent)
	if data and data.GlassesCopy then
		return false
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.IMPORTANT, GLASSES_3D.StopDamageToCopy)

---@param ent Entity
function GLASSES_3D:StopColorChange(ent)
	local data = Mod:TryGetData(ent)
	if data and data.GlassesCopy then
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SET_COLOR, GLASSES_3D.StopColorChange)

--Remove charm from copy enemies as they persist when continuing otherwise
function GLASSES_3D:Purge3DCopiesOnGameExit(shouldSave)
	if shouldSave then
		Mod.Foreach.NPC(function(npc, index)
			local data = Mod:TryGetData(npc)
			if data and data.GlassesCopy then
				npc:ClearEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM)
				npc:Update()
			end
		end)
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, GLASSES_3D.Purge3DCopiesOnGameExit)
