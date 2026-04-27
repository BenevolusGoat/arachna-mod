local loader = ArachnaMod.PatchesLoader

local function SpecialistFixPatch()
	---@diagnostic disable: undefined-global
	if SpecialistModdedCharFix then return end

	SpecialistModdedCharFix = RegisterMod("Specialist Fix", 1)

	SpecialistModdedCharFix.CUSTOM_MUSIC = {}

	-- Copied from the original mod so I can apply the costumes if need be.
	local function cost(name)
		return Isaac.GetCostumeIdByPath("the/specialist_" .. name .. ".anm2");
	end
	function SpecialistModdedCharFix.GetVanillaCostumes()
		SpecialistModdedCharFix.DANCE_COSTUMES = {
			[PlayerType.PLAYER_ISAAC] = cost("isaac"),
			[PlayerType.PLAYER_MAGDALENE] = cost("magdalene"),
			[PlayerType.PLAYER_CAIN] = cost("cain"),
			[PlayerType.PLAYER_JUDAS] = cost("judas"),
			[PlayerType.PLAYER_BLACKJUDAS] = cost("dark_judas"),
			[PlayerType.PLAYER_BLUEBABY] = cost("xxx"),
			[PlayerType.PLAYER_EVE] = cost("eve"),
			[PlayerType.PLAYER_SAMSON] = cost("samson"),
			[PlayerType.PLAYER_AZAZEL] = cost("azazer"),
			[PlayerType.PLAYER_LAZARUS] = cost("lazarus"),
			[PlayerType.PLAYER_LAZARUS2] = cost("lazarus2"),
			[PlayerType.PLAYER_EDEN] = cost("eden"),
			[PlayerType.PLAYER_THELOST] = cost("lost"),
			[PlayerType.PLAYER_LILITH] = cost("lilith"),
			[PlayerType.PLAYER_KEEPER] = cost("keeper"),
			[PlayerType.PLAYER_APOLLYON] = cost("apollyon"),
			[PlayerType.PLAYER_THEFORGOTTEN] = cost("forgor_bone"),
			[PlayerType.PLAYER_THESOUL] = cost("forgor_soul"),
			[PlayerType.PLAYER_BETHANY] = cost("bethany"),
			[PlayerType.PLAYER_JACOB] = cost("jacob"),
			[PlayerType.PLAYER_ESAU] = cost("esau"),

			-- Tainted --

			[PlayerType.PLAYER_ISAAC_B] = cost("isaac"),
			[PlayerType.PLAYER_MAGDALENE_B] = cost("magdalene"),
			[PlayerType.PLAYER_CAIN_B] = cost("t_cain"),
			[PlayerType.PLAYER_JUDAS_B] = cost("dark_judas"),
			[PlayerType.PLAYER_BLUEBABY_B] = cost("xxx"),
			[PlayerType.PLAYER_EVE_B] = cost("eve"),
			[PlayerType.PLAYER_SAMSON_B] = cost("samson"),
			[PlayerType.PLAYER_AZAZEL_B] = cost("azazer"),
			[PlayerType.PLAYER_LAZARUS_B] = cost("lazarus"),
			[PlayerType.PLAYER_LAZARUS2_B] = cost("lazarus2"),
			[PlayerType.PLAYER_EDEN_B] = cost("eden"),
			[PlayerType.PLAYER_THELOST_B] = cost("lost"),
			[PlayerType.PLAYER_LILITH_B] = cost("lilith"),
			[PlayerType.PLAYER_KEEPER_B] = cost("keeper"),
			[PlayerType.PLAYER_APOLLYON_B] = cost("apollyon"),
			[PlayerType.PLAYER_THEFORGOTTEN_B] = cost("forgor_bone"),
			[PlayerType.PLAYER_THESOUL_B] = cost("forgor_soul"),
			[PlayerType.PLAYER_BETHANY_B] = cost("bethany"),
			[PlayerType.PLAYER_JACOB_B] = cost("jacob"),
			[PlayerType.PLAYER_JACOB2_B] = cost("lost"),

			DEFAULT = cost("isaac")
		}
	end

	-- Specialist currently errors and doesn't play music for any modded character.
	-- Going ApiOverride on its ass to fix that.
	if SpecialistModAPI and Epic and Epic.DoCostume and not SpecialistModdedCharFix.AppliedFix then
		SpecialistModdedCharFix.GetVanillaCostumes()
		SpecialistModdedCharFix.DEFAULT_MUSIC = Isaac.GetMusicIdByName("specialist")

		-- Store the original DoCostume function
		SpecialistModdedCharFix.OriginalDoCostume = Epic.DoCostume

		-- Replace it with my own function
		Epic.DoCostume = function(_, apply)
			-- Call the original but catch the error if it occurs
			local success, output = pcall(SpecialistModdedCharFix.OriginalDoCostume, Epic, apply)

			if not apply and SpecialistModdedCharFix.PlayedMusic then
				Game():GetRoom():PlayMusic()
				for _, player in ipairs(PlayerManager.GetPlayers()) do
					if SpecialistModdedCharFix.DANCE_COSTUMES then
						local costume = SpecialistModdedCharFix.DANCE_COSTUMES[player:GetPlayerType()]
						if not costume or costume < 1 then
							costume = SpecialistModdedCharFix.DANCE_COSTUMES.DEFAULT
						end
						if costume and costume > 0 then
							player:TryRemoveNullCostume(costume)
						end
					end
				end
			end

			if not success and type(output) == "string" and string.match(output, "attempt to concatenate a nil value %(local 'typeAlias'%)") then
				-- Play the music manually if the error happens.
				local pType = Isaac.GetPlayer():GetPlayerType()
				local music = SpecialistModdedCharFix.CUSTOM_MUSIC[pType]
				if not music or music < 1 then
					music = SpecialistModdedCharFix.DEFAULT_MUSIC
				end
				if music and music > 0 and MusicManager():GetCurrentMusicID() ~= music then
					MusicManager():Play(music, Options.MusicVolume)
					SpecialistModdedCharFix.PlayedMusic = true
				end

				-- Make sure everyone is dancing!
				for _, player in ipairs(PlayerManager.GetPlayers()) do
					if SpecialistModdedCharFix.DANCE_COSTUMES then
						local costume = SpecialistModdedCharFix.DANCE_COSTUMES[player:GetPlayerType()]
						if not costume or costume < 1 then
							costume = SpecialistModdedCharFix.DANCE_COSTUMES.DEFAULT
						end
						if costume and costume > 0 then
							player:AddNullCostume(costume)
						end
					end
				end
			end

			MusicManager():UpdateVolume()
		end

		-- Highjack AddDanceCostume too since the error can cause some players to not start dancing in co-op.
		SpecialistModdedCharFix.OriginalAddDanceCostume = SpecialistModAPI.AddDanceCostume

		SpecialistModAPI.AddDanceCostume = function(_, pType, costume, override)
			if override or SpecialistModdedCharFix.DANCE_COSTUMES[pType] == nil then
				SpecialistModdedCharFix.DANCE_COSTUMES[pType] = costume
			end
			return SpecialistModdedCharFix.OriginalAddDanceCostume(SpecialistModAPI, pType, costume, override)
		end

		SpecialistModdedCharFix.AppliedFix = true
	end
end
loader:RegisterPatch("SpecialistModAPI", SpecialistFixPatch, "Specialist Dance (Mod Fix)", CallbackPriority.EARLY)
