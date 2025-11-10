local Mod = ARACHNAMOD

return function(modifiers)
	return {
		[Mod.Card.SOUL_OF_ARACHNA.ID] = {
			Name = "Soul of Arachna",
			Description = {
				"{{StatusBitten}} Inflicts all enemies with Bitten, spawning Spider Eggs on death",
				"#{{Timer}} Spider Eggs drop nothing after 16 seconds or {{ColorRainbow}}special{{CR}} friendly spiders on room clear",
			}
		},
		[Mod.Card.MERGED_CARD.ID] = {
			Name = "Merged Card",
			Description = {
				"Triggers 2 random effects:",
				"#{{Card" .. Card.CARD_FOOL 			.. "}} {{Collectible" .. CollectibleType.COLLECTIBLE_D7 .. "}} D7",
				"#{{Card" .. Card.CARD_MAGICIAN 		.. "}} {{Slow}} Slow all enemies",
				"#{{Card" .. Card.CARD_HIGH_PRIESTESS 	.. "}} {{MomBossSmall}} stomps Isaac",
				"#{{Card" .. Card.CARD_EMPRESS 			.. "}} {{Collectible" .. CollectibleType.COLLECTIBLE_THE_NAIL .. "}} The Nail",
				"#{{Card" .. Card.CARD_EMPEROR 			.. "}} Reveals {{BossRoom}}",
				"#{{Card" .. Card.CARD_HIEROPHANT 		.. "}} Spawns 2 {{HalfSoulHeart}}",
				"#{{Card" .. Card.CARD_LOVERS 			.. "}} Spawns 2 {{HalfHeart}}",
				"#{{Card" .. Card.CARD_CHARIOT 			.. "}} {{Collectible".. CollectibleType.COLLECTIBLE_UNICORN_STUMP .."}} Unicorn Stump",
				"#{{Card" .. Card.CARD_JUSTICE 			.. "}} Spawns 2 pickups",
				"#{{Card" .. Card.CARD_HERMIT 			.. "}} {{Collectible".. CollectibleType.COLLECTIBLE_KEEPERS_BOX .."}} Keeper's Box",
				"#{{Card" .. Card.CARD_WHEEL_OF_FORTUNE	.. "}} Uses {{Slotmachine}} 3 times",
				"#{{Card" .. Card.CARD_STRENGTH 		.. "}} Stats up for one room",
				"#{{Card" .. Card.CARD_HANGED_MAN 		.. "}} Destroys rocks, fills pits",
				"#{{Card" .. Card.CARD_DEATH 			.. "}} Deals 20{{DamageSmall}} to enemies",
				"#{{Card" .. Card.CARD_TEMPERANCE 		.. "}} Spawns a {{DemonBeggar}}",
				"#{{Card" .. Card.CARD_DEVIL 			.. "}} {{DamageSmall}} Damage up for one room",
				"#{{Card" .. Card.CARD_TOWER 			.. "}} Spawns 3 Troll Bombs",
				"#{{Card" .. Card.CARD_STARS 			.. "}} Spawns {{GoldenChest}}",
				"#{{Card" .. Card.CARD_MOON 			.. "}} Reveals {{SecretRoom}}{{SuperSecretRoom}}{{UltraSecretRoom}}",
				"#{{Card" .. Card.CARD_SUN 				.. "}} Reveals {{TreasureRoom}}{{Planetarium}}, heals 1 {{Heart}}, deals 5{{DamageSmall}} to enemies",
				"#{{Card" .. Card.CARD_JUDGEMENT 		.. "}} Spawns a shopkeeper",
				"#{{Card" .. Card.CARD_WORLD 			.. "}} Reveals {{TreasureRoom}}{{Planetarium}}",
			}
		},
	}
end
