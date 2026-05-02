local Mod = ArachnaMod
local loader = Mod.PatchesLoader
local Item = Mod.Item

local function ffPatch()
	local ff = FiendFolio
	Mod:AppendTable(ff.ReferenceItems.Actives, {
		{ ID = Item.BEST_BUD_BALL.ID, Reference = "Pokemon", Partial = false },
	})
	Mod:AppendTable(ff.ReferenceItems.Passives, {
		{ ID = Item.SPIDER_DONUT.ID,   Reference = "Undertale",  Partial = false },
		{ ID = Item.ARACHNIDS_GRIP.ID, Reference = "Homestuck",  Partial = true },
	})
	ff:AddStackableItems({
		Item.ARACHNIDS_GRIP.ID,
		Item.LIL_ARACHNA.ID,
		Item.MECHANICAL_EYE.ID,
		Item.MUTAGEN.ID,
		Item.YARN.ID,
		Item.DADS_NEWSPAPER.ID,
		Item.SPIDER_CAKE.ID,
		Item.SPIDER_DONUT.ID,
		Item.CANDY_FLOSS.ID,
		Item.OLD_SHOEBOX.ID,
		Item.GUMMY_SPIDERS.ID
	})
	ff.AddItemsToPennyTrinketPool({
		Mod.Trinket.INFESTED_PENNY.ID
	})
	ff.AddItemsToTortureCookieTrinketPool({
		--On-hit trinkets
		Mod.Trinket.SPINDLE.ID
	})
	--Electrum + Mystery Gift
	ff.AddItemsToTechnologyPool({
		Mod.Item.MECHANICAL_EYE.ID
	})

	---@param player EntityPlayer
	---@param slot EntitySlot
	local function evilBeggarOnTouch(player, slot)
		if Mod:IsAnyArachna(player)
			and Mod.Pickup.WEB_HEART:GetWebHearts(player) > 0
			and slot:GetSprite():IsPlaying("Idle")
		then
			local sprite, data = slot:GetSprite(), slot:GetData()
			local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
			if not d.chanceBonus then
				d.chanceBonus = -16
			end
			data.lastCollider = player
			sprite:Play('PayRedHeart', true)
			player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR, false, false, true, false)
			Mod.sfxman:Play(SoundEffect.SOUND_SCAMPER, 1, 0, false, 1)
			d.chanceBonus = d.chanceBonus + 16
			Mod.Pickup.WEB_HEART:AddWebHearts(player, -1)
		end
	end

	--Copy of Fiend Folio's slot detection
	local function evilBeggarDetectTouch(_, p)
		local slots = Isaac.FindByType(EntityType.ENTITY_SLOT, ff.FF.EvilBeggar.Var, -1, false, false)
		for _, slot in ipairs(slots) do
			if slot:GetData().sizeMulti then
				if (math.abs(slot.Position.X-p.Position.X) ^ 2 <= (slot.Size*slot.SizeMulti.X + p.Size) ^ 2)
					and (math.abs(slot.Position.Y-p.Position.Y) ^ 2 <= (slot.Size*slot.SizeMulti.Y + p.Size) ^ 2)
				then
					---@diagnostic disable-next-line: param-type-mismatch
					evilBeggarOnTouch(p, slot:ToSlot())
				end
			else
				if slot.Position:DistanceSquared(p.Position) <= (slot.Size + p.Size) ^ 2 then
					---@diagnostic disable-next-line: param-type-mismatch
					evilBeggarOnTouch(p, slot:ToSlot())
				end
			end
		end
	end

	Mod:AddPriorityCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, CallbackPriority.EARLY, evilBeggarDetectTouch)
end

loader:RegisterPatch("FiendFolio", ffPatch)
