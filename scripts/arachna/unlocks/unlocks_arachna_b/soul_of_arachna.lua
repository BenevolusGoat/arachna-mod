local Mod = ArachnaMod

local SOUL_OF_ARACHNA = {}

ArachnaMod.Card.SOUL_OF_ARACHNA = SOUL_OF_ARACHNA

SOUL_OF_ARACHNA.ID = Isaac.GetCardIdByName("Soul of Arachna")
SOUL_OF_ARACHNA.SFX = Isaac.GetSoundIdByName("Soul of Arachna")

SOUL_OF_ARACHNA.WEBBED_DURATION = 300

---@param card Card
---@param player EntityPlayer
---@param useFlags UseFlag
function SOUL_OF_ARACHNA:OnUse(card, player, useFlags)
	local source = EntityRef(player)

	Mod.Foreach.NPC(function(npc, index)
		Mod.Item.ARACHNAS_SPOOL:ApplyWebbed(npc, source, SOUL_OF_ARACHNA.WEBBED_DURATION)
		Mod.Game:SpawnParticles(npc.Position, EffectVariant.BLOOD_PARTICLE, Mod:RandomNum(7, 14), 4, Color(1, 1, 1, 1, 1, 1, 1))
	end, nil, nil, nil, { UseEnemySearchParams = true })

	Mod.sfxman:Play(SoundEffect.SOUND_SPIDER_SPIT_ROAR, 0.8)

	if not Mod:HasBitFlags(useFlags, UseFlag.USE_NOANNOUNCER)
		and (
			Options.AnnouncerVoiceMode == AnnouncerVoiceMode.ALWAYS
			or Options.AnnouncerVoiceMode == AnnouncerVoiceMode.RANDOM and Mod.GENERIC_RNG:RandomFloat() < 0.5
		)
	then
		local delay = Mod.ItemConfig:GetCard(card).AnnouncerDelay
		Isaac.CreateTimer(function()
			Mod.sfxman:Play(SOUL_OF_ARACHNA.SFX)
		end, delay, 1, true)
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, SOUL_OF_ARACHNA.OnUse, SOUL_OF_ARACHNA.ID)
