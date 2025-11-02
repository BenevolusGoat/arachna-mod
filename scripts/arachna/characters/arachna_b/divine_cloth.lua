local Mod = ARACHNAMOD

local DIVINE_CLOTH = {}

ARACHNAMOD.Item.DIVINE_CLOTH = DIVINE_CLOTH

DIVINE_CLOTH.ID = Isaac.GetItemIdByName("Divine Cloth")

local identifier = "ARACHNA_BITTEN"
local sprite = Sprite("gfx/indicator_arachna_b.anm2", true)
sprite:Play("Idle")
DIVINE_CLOTH.STATUS_BITTEN_CONFIG = StatusEffectLibrary.RegisterStatusEffect(identifier, sprite, StatusEffectLibrary.StatusColor.SLOW, EntityFlag.FLAG_SLOW)
DIVINE_CLOTH.STATUS_BITTEN = StatusEffectLibrary.StatusFlag[identifier]