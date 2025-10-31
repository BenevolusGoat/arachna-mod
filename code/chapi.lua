local mod = ARACHNAMOD
local arachnaChar = Isaac.GetPlayerTypeByName("Arachna", false)
local arachnaChar_b = Isaac.GetPlayerTypeByName("Arachna", true)
mod.CustomHealthAPISave = {}
if CustomHealthAPI and CustomHealthAPI.Library and CustomHealthAPI.Library.UnregisterCallbacks then
    CustomHealthAPI.Library.UnregisterCallbacks("ArachnaMOD")
end

CustomHealthAPI.Library.RegisterSoulHealth(
    "HEART_WEB",
    {
        AnimationFilename = "gfx/web_heart_ui.anm2",
        AnimationName = {"UI"},
        SortOrder = 100,
        AddPriority = 125,
        HealFlashRO = 240/255, 
        HealFlashGO = 240/255,
        HealFlashBO = 240/255,
        MaxHP = 2,
        PrioritizeHealing = false,
        PickupEntities = {
            {ID = EntityType.ENTITY_PICKUP, Var = PickupVariant.PICKUP_HEART, Sub = 2000},
            {ID = EntityType.ENTITY_PICKUP, Var = PickupVariant.PICKUP_HEART, Sub = 2002}
        },
        SumptoriumSubType = 2000,  -- web heart clot
        SumptoriumSplatColor = Color(1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00),
        SumptoriumTrailColor = Color(1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00),
        SumptoriumCollectSoundSettings = {
            ID = SoundEffect.SOUND_MEAT_IMPACTS,
            Volume = 1.0,
            FrameDelay = 0,
            Loop = false,
            Pitch = 1.0,
            Pan = 0
        }
    }
)

CustomHealthAPI.Library.RegisterHealthOverlay("GOLDEN_HEART_WEB", 
                                      {AnimationFilename = "gfx/web_heart_ui.anm2",
                                       AnimationName = "UI_Gold", 
                                       IgnoreBleeding = true})

CustomHealthAPI.Library.RegisterCharacterAsRedHealthless(arachnaChar)
CustomHealthAPI.Library.RegisterCharacterAsRedHealthless(arachnaChar_b)
CustomHealthAPI.Library.RegisterCharacterAsConvertingMaxHealth(arachnaChar,"HEART_WEB")
CustomHealthAPI.Library.RegisterCharacterAsConvertingMaxHealth(arachnaChar_b,"HEART_WEB")

CustomHealthAPI.Library.AddCallback("ArachnaMOD", CustomHealthAPI.Enums.Callbacks.PRE_RENDER_HEART, 0, function (player,index,health)
    if health.Key == "HEART_WEB" then
        if CustomHealthAPI.Helper.GetGoldenRenderMask(player)[index+1] then
            return {AnimationFilename = "gfx/web_heart_ui.anm2", AnimationName = "UI_Gold"}
        end
    end 
end)

CustomHealthAPI.Library.AddCallback("ArachnaMOD", CustomHealthAPI.Enums.Callbacks.PRE_HEALTH_DAMAGED, 0, function(player, flags, key, hpDamaged, otherKey, otherHPDamaged, amountToRemove)
	if otherKey == "HEART_WEB" then
		return 2
	end
end)

CustomHealthAPI.Library.AddCallback("ArachnaMOD",CustomHealthAPI.Enums.Callbacks.ON_SAVE,0,function (savedata,isPreGameExit)
    mod.CustomHealthAPISave = savedata
end)

CustomHealthAPI.Library.AddCallback("ArachnaMOD", CustomHealthAPI.Enums.Callbacks.ON_LOAD, 0, function()
	return mod.CustomHealthAPISave
end)