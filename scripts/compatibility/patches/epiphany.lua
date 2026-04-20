local Mod = ArachnaMod
local loader = Mod.PatchesLoader
local Item = Mod.Item

local function epiphanyPatch()
	local api = Epiphany.API

	api:AddItemsToEdenBlackList(
		Item.SPIDER_CAKE.ID,
		Item.SPIDER_DONUT.ID,
		Item.CANDY_FLOSS.ID,
		Item.OLD_SHOEBOX.ID,
		Item.GUMMY_SPIDERS.ID
	)

	Mod:AddToDictionary(Epiphany.Character.KEEPER.DisallowedPickUpVariants, {
		[Item.ARACHNIDS_GRIP.PICKUP] = 0
	})

	Mod:AddToDictionary(Epiphany.Character.KEEPER.PickupVariants[PickupVariant.PICKUP_HEART], {
		[Mod.Pickup.WEB_HEART.ID] = 0,
		[Mod.Pickup.WEB_HEART.ID] = 0,
	})
	Mod:AddToDictionary(Epiphany.Character.KEEPER.HeartToFliesTable[PickupVariant.PICKUP_HEART], {
		[Mod.Pickup.WEB_HEART.ID] = 0,
		[Mod.Pickup.WEB_HEART.ID] = 0,
	})
	ArachnaMod.KeeperPlayers[Epiphany.PlayerType.KEEPER] = true
	local THROWING_BAG = Epiphany.Item.THROWING_BAG

	local cainSynergies = {
		book_bagged = {
			Item.GEPTAMERON.ID
		},
		gamer_bagged = {
			Item.BEST_BUD_BALL.ID
		},
		meal_bagged = {
			Item.GUMMY_SPIDERS.ID,
			Item.SPIDER_DONUT.ID,
			Item.SPIDER_CAKE.ID
		},
		punching_bagged = {
			Item.DADS_NEWSPAPER.ID
		},
		spider_bagged = {
			Item.YARN_HEART.ID,
			Item.LIL_ARACHNA.ID,
			Item.ARACHNIDS_GRIP.ID,
			Item.SPIDER_DONUT.ID,
			Item.CANDY_FLOSS.ID,
			Item.GUMMY_SPIDERS.ID
		},
		tool_bagged = {
			Item.OLD_SHOEBOX.ID
		},
		poison_bagged = {
			Item.ARACHNIDS_GRIP.ID
		},
	}

	for generic_group, items_list in pairs(cainSynergies) do
		api:AddCollectibleToCainBagSynergy(generic_group, items_list)
	end

	Epiphany.API:AddCainBagSynergy("arachna_webbed_bagged", {
		flags = Epiphany.Item.THROWING_BAG.SynergyFlags.BAGGED,
		id_list = { Item.ARACHNAS_SPOOL.ID, Item.LIL_ARACHNA.ID },
		color = StatusEffectLibrary.StatusColor.SLOW,

		callback_post_hit = function(_, count, entity, bagData)
			if entity:IsActiveEnemy() then
				local player = bagData.PlayerOwner

				if THROWING_BAG:HasBirthrightBuff(player) then
					count = count * 2
				end

				local luck = player.Luck * math.sqrt(count)
				local rng = player:GetCollectibleRNG(Item.ARACHNAS_SPOOL.ID)
				if Epiphany:BagLuckCheck(luck, bagData, rng, 0.5, 1, 0, 15) then
					Mod.Item.ARACHNAS_SPOOL:ApplyWebbed(entity, EntityRef(player), 30 + 30 * count)
				end
			end
		end,

		callback_swing_post_hit = function(_, count, entity, player, bagData)
			if entity:IsVulnerableEnemy() then
				if THROWING_BAG:HasBirthrightBuff(player) then
					count = count * 2
				end

				local luck = player.Luck * math.sqrt(count)
				local rng = player:GetCollectibleRNG(Item.ARACHNAS_SPOOL.ID)

				if Epiphany:BagLuckCheck(luck, bagData, rng, 0.1, 1, 0, 27) then
					Mod.Item.ARACHNAS_SPOOL:ApplyWebbed(entity, EntityRef(player), 30 + 30 * count)
				end
			end
		end,
	})
	Epiphany.API:AddCainBagSynergy("arachna_ensnare_bagged", {
		flags = Epiphany.Item.THROWING_BAG.SynergyFlags.BAGGED,
		id_list = { Item.DIVINE_CLOTH.ID },
		color = StatusEffectLibrary.StatusColor.SLOW,

		callback_post_hit = function(_, count, entity, bagData)
			if entity:IsActiveEnemy() then
				local player = bagData.PlayerOwner

				if THROWING_BAG:HasBirthrightBuff(player) then
					count = count * 2
				end

				local luck = player.Luck * math.sqrt(count)
				local rng = player:GetCollectibleRNG(Item.ARACHNAS_SPOOL.ID)
				if Epiphany:BagLuckCheck(luck, bagData, rng, 0.5, 1, 0, 15) then
					Mod.Item.DIVINE_CLOTH:ApplyBitten(entity, EntityRef(player), 30 + 30 * count)
				end
			end
		end,

		callback_swing_post_hit = function(_, count, entity, player, bagData)
			if entity:IsVulnerableEnemy() then
				if THROWING_BAG:HasBirthrightBuff(player) then
					count = count * 2
				end

				local luck = player.Luck * math.sqrt(count)
				local rng = player:GetCollectibleRNG(Item.ARACHNAS_SPOOL.ID)

				if Epiphany:BagLuckCheck(luck, bagData, rng, 0.1, 1, 0, 27) then
					Mod.Item.DIVINE_CLOTH:ApplyBitten(entity, EntityRef(player), 30 + 30 * count)
				end
			end
		end,
	})
end

loader:RegisterPatch("Epiphany", epiphanyPatch)
