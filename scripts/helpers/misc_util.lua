local floor = ArachnaMod.math.floor
local ceil = ArachnaMod.math.ceil

---@param ent1 Entity
---@param ent2 Entity
function ArachnaMod:IsSameEntity(ent1, ent2)
	return GetPtrHash(ent1) == GetPtrHash(ent2)
end

---@param sprite Sprite
---@param anims string[]
---@param useOverlay? boolean
---@return boolean isPlaying
function ArachnaMod:IsSpriteAnimActive(sprite, anims, useOverlay)
	for i = 1, #anims do
		if not useOverlay and sprite:GetAnimation() == anims[i]
			or useOverlay and sprite:GetOverlayAnimation() == anims[i]
		then
			return true
		end
	end
	return false
end

---@param direction Vector
---@param shotSpeed number
---@param player? EntityPlayer
function ArachnaMod:AddTearVelocity(direction, shotSpeed, player)
	local newDirection = direction:Resized(shotSpeed)

	if player then
		newDirection = newDirection + player:GetTearMovementInheritance(newDirection)
	end
	return newDirection
end

---@param tear EntityTear
---@return boolean isSplitTear
function ArachnaMod:IsSplitTear(tear)
	local isSplit = false

	for _, tears in pairs(Isaac.FindInRadius(tear.Position, 10, EntityPartition.TEAR)) do
		local mainTear = tears:ToTear()
		if mainTear == nil then return false end
		if tear.InitSeed ~= mainTear.InitSeed
			and tear.FrameCount ~= mainTear.FrameCount
			and ArachnaMod:TryGetPlayer(tear)
		then
			isSplit = true
		end
	end

	return isSplit
end

---@param c1 Color
---@param c2 Color
function ArachnaMod:AreColorsDifferent(c1, c2)
	local c1Metatable = getmetatable(c1)
	local c2Metatable = getmetatable(c2)
	local different = false
	for key, value in pairs(c1Metatable.__propget) do
		if c2Metatable.__propget[key](c2) ~= value(c1) then
			different = true
			break
		end
	end
	if not different then
		local cz1 = c1:GetColorize()
		local cz2 = c2:GetColorize()
		for key, value in pairs(cz1) do
			if cz2[key] ~= value then
				different = true
				break
			end
		end
	end
	return different
end

---@param laser EntityLaser
function ArachnaMod:IsBrimLaser(laser)
	local brimVariants = ArachnaMod:Set({
		LaserVariant.THIN_RED,
		LaserVariant.THICK_RED,
		LaserVariant.BRIM_TECH,
		LaserVariant.THICKER_RED,
		LaserVariant.THICKER_BRIM_TECH,
		LaserVariant.GIANT_RED,
		LaserVariant.GIANT_BRIM_TECH
	})
	return brimVariants[laser.Variant]
end

function ArachnaMod:GetScreenCenter()
	return Vector(floor(Isaac.GetScreenWidth() / 2), floor(Isaac.GetScreenHeight() / 2))
end

---@param sprite Sprite
---@param layerID integer
function ArachnaMod:GetCurrentFrameData(sprite, layerID)
	local animationData = sprite:GetCurrentAnimationData()
	if not animationData then return end
	local layerData = animationData:GetLayer(layerID)
	if not layerData then return end
	local frameData = layerData:GetFrame(sprite:GetFrame())
	return frameData
end

function ArachnaMod:CopySprite(sprite)
	local copySprite = Sprite()

	if not sprite:IsLoaded() then
		return copySprite
	end

	copySprite:Load(sprite:GetFilename(), true)

	local anim, frame = sprite:GetAnimation(), sprite:GetFrame()
	local overlayAnim, overlayFrame = sprite:GetOverlayAnimation(), sprite:GetOverlayFrame()

	if anim == "" and overlayAnim == "" then
		return copySprite
	end

	--Auto-assigns FlipX, Scale, etc
	local s1Metatable = getmetatable(sprite)
	for key, value in pairs(s1Metatable.__propget) do
		copySprite[key] = value(sprite)
	end
	copySprite:SetFrame(anim, frame)
	if overlayFrame ~= -1 then
		copySprite:SetOverlayFrame(overlayAnim, overlayFrame)
	end
	if REPENTOGON then
		copySprite:SetRenderFlags(sprite:GetRenderFlags())
	end
	if sprite:IsPlaying(anim) then
		copySprite:Play(anim)
	end
	if sprite:IsOverlayPlaying(overlayAnim) then
		copySprite:PlayOverlay(overlayAnim)
	end

	return copySprite
end

---@param color Color
function ArachnaMod:CopyColor(color)
	return Color(color.R, color.G, color.B, color.A, color.RO, color.GO, color.BO)
end

---@param func function
function ArachnaMod:DelayOneFrame(func)
	Isaac.CreateTimer(func, 1, 1, true)
end

---@param dir Direction
function ArachnaMod:DirectionToString(dir)
	local directions = {
		[Direction.NO_DIRECTION] = "Down",
		[Direction.LEFT] = "Left",
		[Direction.UP] = "Up",
		[Direction.RIGHT] = "Right",
		[Direction.DOWN] = "Down"
	}
	return directions[dir]
end

---@generic T
---@param val T | fun(...): T
---@param ... any
---@return T
function ArachnaMod:ProcessFuncOrValue(val, ...)
	if type(val) == "function" then
		return val(...)
	else
		return val
	end
end

---@param ent Entity
---@param type EntityType
---@param var integer
---@param sub integer
function ArachnaMod:CheckTypeVarSub(ent, type, var, sub)
	return ent.Type == type
		and ent.Variant == var
		and ent.SubType == sub
end

---RoomCheckLine is inaccurate and has a variance of roughly 10 pixels, alwyas off by at least 5, when returning the obstructed position.
---
---This tries to get an *exact* position by inching forward until it finds the grid entity.
---@param pos1 Vector
---@param pos2 Vector
---@param lineCheckMode LineCheckMode
---@param gridPath integer
---@param ignoreWalls boolean
---@param ignoreCrushable boolean
---@return boolean, Vector
function ArachnaMod:RoomCheckLineEx(pos1, pos2, lineCheckMode, gridPath, ignoreWalls, ignoreCrushable)
	local isClearPath, shittyPosIfObstructed = ArachnaMod.Room():CheckLine(pos1, pos2, lineCheckMode, gridPath,
		ignoreWalls,
		ignoreCrushable)

	if not isClearPath then
		local direction = (pos2 - pos1):Normalized()
		local findGridPos = shittyPosIfObstructed + direction:Resized(5)
		for _ = 1, 10 do
			local gridEnt = ArachnaMod.Room():GetGridEntityFromPos(findGridPos)
			if gridEnt then break end
			findGridPos = findGridPos + direction
		end
		local epicPosIfObstructed = Vector(ceil(findGridPos.X), ceil(findGridPos.Y))
		return false, epicPosIfObstructed
	else
		return true, pos2
	end
end

---@param pos Vector
function ArachnaMod:GetClosestGridEnt(pos)
	local shortestDistance
	local closestGridEnt
	for row = 1, 3 do
		local posFromMiddle = row - 2
		for column = 1, 3 do
			local offset = 0
			local roomShape = ArachnaMod.Room():GetRoomShape()
			local perRow = roomShape >= RoomShape.ROOMSHAPE_2x1 and 27 or 15
			if column == 1 then
				offset = -perRow
			elseif column == 3 then
				offset = perRow
			end
			if row ~= 2 or column ~= 2 then
				local room = ArachnaMod.Room()
				local playerGridIndex = room:GetGridIndex(pos)
				local gridEnt = room:GetGridEntity(playerGridIndex + offset + posFromMiddle)
				if gridEnt
					and gridEnt.CollisionClass > GridCollisionClass.COLLISION_NONE
					and gridEnt.CollisionClass < GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER
				then
					local distance = gridEnt.Position:DistanceSquared(pos)
					if not shortestDistance or distance < shortestDistance then
						shortestDistance = distance
						closestGridEnt = gridEnt
					end
				end
			end
		end
	end
	return closestGridEnt
end

local playdoughColor = {
	{ 0.9, 0,   0,   1 }, --red
	{ 0,   0.7, 0,   0.9 }, --green
	{ 0,   0,   1,   1 }, --blue
	{ 0.8, 0.8, 0,   1 }, --yellow
	{ 0,   0.5, 1,   0.9 }, --light blue
	{ 0.6, 0.4, 0,   1 }, --light brown
	{ 2,   0.1, 0.5, 1 }, --pink
	{ 1.1, 0,   1.1, 0.9 }, --purple
	{ 1,   0.1, 0,   1 } --dark orange
}

function ArachnaMod:GetRandomPlaydoughColor()
	local dC = Color.Default
	local color = playdoughColor[ArachnaMod:RandomNum(9)]
	dC:SetColorize(color[1], color[2], color[3], color[4])
	return dC
end

---@param pos Vector
---@return Vector | nil DoorSlotPos
function ArachnaMod:GetClosestDoorSlotPos(pos)
	local closestDoor
	local closestDistance

	for doorSlot = 0, DoorSlot.NUM_DOOR_SLOTS do
		local door = ArachnaMod.Room():GetDoor(doorSlot)
		if door ~= nil and door:IsOpen() then
			local doorPos = ArachnaMod.Room():GetDoorSlotPosition(doorSlot)
			local doorDistance = doorPos:DistanceSquared(pos)

			if not closestDoor or doorDistance < closestDistance then
				closestDoor = doorPos
				closestDistance = doorDistance
			end
		end
	end

	return closestDoor
end

---Capitizes the string and replaces spaces with underscores
---@param str string
function ArachnaMod:ToEnum(str)
	return string.gsub(str, " ", "_"):upper()
end

function ArachnaMod:ShouldUpdateSprite()
	return not ArachnaMod.Game:IsPaused() and Isaac.GetFrameCount() % 2 == 0
end

function ArachnaMod:TryStartAmbush()
	local room = ArachnaMod.Room():GetType()
	if room ~= RoomType.ROOM_BOSSRUSH and room ~= RoomType.ROOM_CHALLENGE then
		return
	end
	Ambush.StartChallenge()
end

local bloodTearTable = {
	[TearVariant.BLUE] = TearVariant.BLOOD,
	[TearVariant.CUPID_BLUE] = TearVariant.CUPID_BLOOD,
	[TearVariant.NAIL] = TearVariant.NAIL_BLOOD,
	[TearVariant.PUPULA] = TearVariant.PUPULA_BLOOD,
	[TearVariant.GODS_FLESH] = TearVariant.GODS_FLESH_BLOOD,
	[TearVariant.GLAUCOMA] = TearVariant.GLAUCOMA_BLOOD,
	[TearVariant.EYE] = TearVariant.EYE_BLOOD,
}

---@param tear EntityTear
function ArachnaMod:TryChangeTearToBloodVariant(tear)
	if bloodTearTable[tear.Variant] then
		tear:ChangeVariant(bloodTearTable[tear.Variant])
		return true
	end
	return false
end

local inverseTearTable = ArachnaMod:Invert(bloodTearTable)

---@param tear EntityTear
function ArachnaMod:IsBloodTear(tear)
	return inverseTearTable[tear.Variant] ~= nil
end

---@param tear EntityTear
---@param player EntityPlayer
function ArachnaMod:ShouldUpdateLudo(tear, player)
	return floor(tear.FrameCount / player.MaxFireDelay) ~= floor((tear.FrameCount - 1) / player.MaxFireDelay)
end

---@param ent Entity
function ArachnaMod:IsDeadEnemy(ent)
	return ent:IsActiveEnemy(true) and ent:ToNPC() and ent:ToNPC().CanShutDoors
end

---@return string
function ArachnaMod:GetHealthPath()
	return not CustomHealthAPI and "gfx/ui/ui_hearts.anm2" or "gfx/ui/CustomHealthAPI/hearts.anm2"
end

---@return string
function ArachnaMod:GetMinimapPath()
	return not MinimapAPI and "gfx/ui/minimap_icons.anm2" or "gfx/ui/minimapapi_icons.anm2"
end

---@param ent Entity | Vector
---@param offset Vector
---@param ignoreShake? boolean
function ArachnaMod:GetEntityRenderPosition(ent, offset, ignoreShake)
	local pos
	if getmetatable(ent).__type == "Vector" then
		---@cast ent Vector
		pos = ent
	else
		---@cast ent Entity
		pos = ent.Position + ent.PositionOffset
		if ent:ToPlayer() and ArachnaMod.Room():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT then
			---@cast ent EntityPlayer
			pos = pos + ent:GetFlyingOffset()
		end
	end
	local renderPos = Isaac.WorldToRenderPosition(pos) + offset
	if ignoreShake then
		renderPos = renderPos - ArachnaMod.Game.ScreenShakeOffset
	end
	return renderPos
end

---@param laser EntityLaser
---@return Vector?
function ArachnaMod:GetLaserEndPoint(laser)
	if laser.SubType == LaserSubType.LASER_SUBTYPE_LINEAR
		and laser:IsSampleLaser()
		and #laser:GetSamples() > 0
	then
		local samples = laser:GetSamples()
		return samples:Get(#samples - 1)
	end
end

local laserWeaponType = ArachnaMod:Set({
	WeaponType.WEAPON_BRIMSTONE,
	WeaponType.WEAPON_LASER,
	WeaponType.WEAPON_TECH_X
})

function ArachnaMod:IsLaserWeaponType(weaponType)
	return laserWeaponType[weaponType]
end

---@param ent Entity
function ArachnaMod:TypeVarSubToString(ent)
	return tostring(ent.Type) .. "." .. tostring(ent.Variant) .. "." .. tostring(ent.SubType)
end
