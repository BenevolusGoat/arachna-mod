local Mod = ARACHNAMOD

local SPINDLE = {}

ARACHNAMOD.Trinket.SPINDLE = SPINDLE

SPINDLE.ID = Isaac.GetTrinketIdByName("Spindle")

---@param ent Entity
---@param damage integer
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function SPINDLE:OnTakeDamage(ent, damage, flags, source, countdown)
	local player = ent:ToPlayer()
	local sourceEnt = source and source.Entity
	if sourceEnt and player and player:HasTrinket(SPINDLE.ID) then
		local npc = sourceEnt:ToNPC()
		if npc then --Status effect automatically does the rest of the checks for if the effect can be applied
			Mod.Item.DIVINE_CLOTH:ApplyBitten(npc, EntityRef(ent:ToPlayer()))
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, SPINDLE.OnTakeDamage, EntityType.ENTITY_PLAYER)
