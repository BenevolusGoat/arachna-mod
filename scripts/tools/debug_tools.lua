---Credit to Epiphany

-- Prints a group of given strings/numbers to both console and log.txt.
-- If luadebug is on, the output is prefixed by name of current file
-- and function that called Log, as well as line Log was called from.
---@function
function ArachnaMod:Log(...)
	local str = ""
	if debug then               -- only passes if luadebug is on
		local info = debug.getinfo(2) -- get info on the function that called ArachnaMod:Log
		if info.func == ArachnaMod.DebugLog then
			info = debug.getinfo(3)
		end
		local file = info.short_src
		file = file:match("^.+/(.+)$") -- get full path to the file and trim it to just the filename.lua
		if file then             -- file may be nil after match if ArachnaMod:Log was called from console
			local funcName = info.name
			funcName = (funcName or tostring(info.func):gsub("^function: ", "f:")) .. ":" .. info.currentline
			str = string.format("[%s:%s] ", file, info.currentline)
		end
	else
		str = str .. "[ArachnaMOD] "
	end
	local args = { ... }
	for i = 1, #args do
		args[i] = tostring(args[i])
	end
	str = str .. table.concat(args, " ")
	print(str)
	Isaac.DebugString(str)
end

---Equivalent to ArachnaMod:Log, but only prints if Mod.FLAGS.Debug is set to true.
function ArachnaMod:DebugLog(...)
	if ArachnaMod.FLAGS.Debug then
		ArachnaMod:Log(...)
	end
end

function ArachnaMod:Crash()
	Isaac.GetPlayer(0):AddNullCostume(-1) -- Crashes the game
end

ArachnaMod.ShouldRenderID = false

function ArachnaMod:RenderTypeVarSub()
	if not ArachnaMod.ShouldRenderID then return end
	for _, ent in ipairs(Isaac.GetRoomEntities()) do
		local renderPos = Isaac.WorldToScreen(ent.Position)
		Isaac.RenderText(ent.Type .. ", " .. ent.Variant .. ", " .. ent.SubType, renderPos.X, renderPos.Y - 30, 1, 1, 1, 1)
	end
end

ArachnaMod:AddCallback(ModCallbacks.MC_POST_RENDER, ArachnaMod.RenderTypeVarSub)
