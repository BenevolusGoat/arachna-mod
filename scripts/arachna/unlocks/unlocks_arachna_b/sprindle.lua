local Mod = ARACHNAMOD

local SPRINDLE = {}

ARACHNAMOD.Trinket.SPRINDLE = SPRINDLE

SPRINDLE.ID = Isaac.GetTrinketIdByName("Sprindle")

---@param ent Entity
---@param damage integer
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function SPRINDLE:OnTakeDamage(ent, damage, flags, source, countdown)
	local sourceEnt = source and source.Entity
	if sourceEnt then
		local npc = sourceEnt:ToNPC()
		if npc then --Status effect automatically does the rest of the checks for if the effect can be applied
			Mod.Item.DIVINE_CLOTH:ApplyBitten(npc, EntityRef(ent:ToPlayer()))
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, SPRINDLE.OnTakeDamage, EntityType.ENTITY_PLAYER)