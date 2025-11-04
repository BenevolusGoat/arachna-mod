local Mod = ARACHNAMOD

local SOUL_OF_ARACHNA = {}

ARACHNAMOD.Card.SOUL_OF_ARACHNA = SOUL_OF_ARACHNA

SOUL_OF_ARACHNA.ID = Isaac.GetCardIdByName("Soul of Arachna")
SOUL_OF_ARACHNA.SFX = Isaac.GetSoundIdByName("Soul of Arachna")

---@param card Card
---@param player EntityPlayer
---@param useFlags UseFlag
function SOUL_OF_ARACHNA:OnUse(card, player, useFlags)
	local source = EntityRef(player)

	Mod.Foreach.NPC(function (npc, index)
		Mod.Item.DIVINE_CLOTH:ApplyBitten(npc, source, 150)
		Mod.Game:SpawnParticles(npc.Position, EffectVariant.BLOOD_PARTICLE, Mod:RandomNum(7, 14), 4, Color(1, 1, 1, 1, 1, 1, 1))
	end, nil, nil, nil, {UseEnemySearchParams = true})

	Mod.sfxman:Play(SoundEffect.SOUND_SPIDER_SPIT_ROAR, 0.8, 0, false, 1)

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