local Mod = ARACHNAMOD

return function(modifiers)
	return {
		[Mod.Card.SOUL_OF_ARACHNA.ID] = {
			Name = "Soul of Arachna",
			Description = {
				"{{StatusSpiderBite}} Inflicts all enemies with Spider Bite, spawning Spider Eggs on death",
				"#{{Timer}} Spider Eggs drop nothing after 16 seconds or {{ColorRainbow}}special{{CR}} friendly spiders on room clear",
			}
		},
		[Mod.Card.MERGED_CARD.ID] = {
			Name = "Merged Card",
			Description = {
				function(descObj)
					return modifiers[Mod.Card.MERGED_CARD.ID]._modifier(descObj,
					"Triggers 2 random effects based on tarot cards"
					.. "#(Hold {{ButtonSelect}} to show effects)",
					"{{Blank}} {{ButtonX}} Effect List %s/%s {{ButtonB}}",
					{
						"#{{Card" .. Card.CARD_FOOL .. "}} Uses {{Collectible" .. CollectibleType.COLLECTIBLE_D7 .. "}} D7"
						.. "#{{Card" .. Card.CARD_MAGICIAN .. "}} {{Slow}} Slow all enemies in the room"
						.. "#{{Card" .. Card.CARD_HIGH_PRIESTESS .. "}} {{MomBossSmall}} Mom's foot stomps Isaac"
						.. "#{{Card" ..
						Card.CARD_EMPRESS .. "}} Uses {{Collectible" .. CollectibleType.COLLECTIBLE_THE_NAIL .. "}} The Nail"
						.. "#{{Card" .. Card.CARD_EMPEROR .. "}} Reveals the {{BossRoom}} Boss Room"
						.. "#{{Card" .. Card.CARD_HIEROPHANT .. "}} Spawns 2 {{HalfSoulHeart}} Half Soul Hearts",

						"#{{Card" .. Card.CARD_LOVERS .. "}} Spawns 2 {{HalfHeart}} Half Hearts"
						.. "#{{Card" ..
						Card.CARD_CHARIOT .. "}} Uses {{Collectible" .. CollectibleType.COLLECTIBLE_UNICORN_STUMP ..
						"}} Unicorn Stump"
						.. "#{{Card" .. Card.CARD_JUSTICE .. "}} Spawns any 2 of the following pickups: A {{Coin}} coin, {{Key}} key, {{Bomb}} bomb, or {{Heart}} heart"
						.. "#{{Card" ..
						Card.CARD_HERMIT .. "}} Uses {{Collectible" .. CollectibleType.COLLECTIBLE_KEEPERS_BOX .. "}} Keeper's Box"
						.. "#{{Card" .. Card.CARD_WHEEL_OF_FORTUNE .. "}} Uses {{Collectible" .. CollectibleType.COLLECTIBLE_PORTABLE_SLOT .. "}} Portable Slot 3 times",

						"#{{Card" .. Card.CARD_STRENGTH .. "}} {{Timer}} For one room: Gain {{Collectible" .. CollectibleType.COLLECTIBLE_ODD_MUSHROOM_LARGE .. "}} Odd Mushroom"
						.. "#{{Card" .. Card.CARD_HANGED_MAN .. "}} Destroys all rocks and fills all pits in the room"
						.. "#{{Card" .. Card.CARD_DEATH .. "}} Deals 20 damage to all enemies in the room"
						.. "#{{Card" .. Card.CARD_TEMPERANCE .. "}} Spawns a {{DemonBeggar}} Demon Beggar"
						.. "#{{Card" .. Card.CARD_DEVIL .. "}} {{Timer}} For one room: {{Damage}} +1 Damage"
						.. "#{{Card" .. Card.CARD_TOWER .. "}} Spawns 3 Troll Bombs",

						"#{{Card" .. Card.CARD_STARS .. "}} Spawns a {{GoldenChest}} golden chest"
						.. "#{{Card" .. Card.CARD_MOON .. "}} Reveals all {{SecretRoom}}{{SuperSecretRoom}}{{UltraSecretRoom}} secret-type rooms"
						.. "#{{Card" ..
						Card.CARD_SUN ..
						"}} Reveals the {{TreasureRoom}} Treasure Room and {{Planetarium}} Planetarium, {{HealingRed}} heals 1 heart, deals 5 damage to all enemies in the room"
						.. "#{{Card" .. Card.CARD_JUDGEMENT .. "}} Spawns a shopkeeper"
						.. "#{{Card" .. Card.CARD_WORLD .. "}} Reveals the {{TreasureRoom}} Treasure Room and {{Planetarium}} Planetarium"
					}
				)
				end
			}
		},
		[Mod.Card.MERGED_CARD_REVERSED.ID] = {
			Name = "Merged Card?",
			Description = {
				function(descObj)
					return modifiers[Mod.Card.MERGED_CARD.ID]._modifier(descObj,
					"Triggers 2 random effects based on reverse tarot cards"
					.. "#(Hold {{ButtonSelect}} to show effects)",
					"{{Blank}} {{ButtonX}} Effect List %s/%s {{ButtonB}}",
					{
						"#{{Card" .. Card.CARD_REVERSE_FOOL .. "}} Drops all of Isaac's {{Coin}} coins, {{Bomb}} bombs, or {{Key}} keys on the floor"
						.. "#{{Card" .. Card.CARD_REVERSE_MAGICIAN .. "}} Uses {{Collectible" .. CollectibleType.COLLECTIBLE_TELEKINESIS .. "}} Telekinesis 2 times"
						.. "#{{Card" .. Card.CARD_REVERSE_HIGH_PRIESTESS .. "}} {{Timer}} {{MomBossSmall}} Mom's Foot tries to stomp Isaac for 15 seconds"
						.. "#{{Card" ..
						Card.CARD_REVERSE_EMPRESS .. "}} {{Timer}} Receive for the room: +1 {{Heart}} Health, {{Tears}} +0.75 Tears, {{Speed}} -0.05 Speed",

						"#{{Card" .. Card.CARD_REVERSE_EMPEROR .. "}} Spawns a {{ColorRainbow}}rainbow{{CR}} champion of a random enemy on the floor"
						.. "#{{Card" .. Card.CARD_REVERSE_HIEROPHANT .. "}} Spawns 1 {{EmptyBoneHeart}} Bone Heart"
						.. "#{{Card" .. Card.CARD_REVERSE_LOVERS .. "}} {{BrokenHeart}} +1 Broken Heart, {{Damage}} +0.25 Damage"
						.. "#{{Card" ..
						Card.CARD_REVERSE_CHARIOT .. "}} {{Timer}} For 10 seconds: {{Speed}} x0.5 Speed multiplier, {{Tears}} x2 Tears multiplier"
						.. "#{{Card" .. Card.CARD_REVERSE_JUSTICE .. "}} Spawns 1-2 {{GoldenChest}} golden chests"
						.. "#{{Card" ..
						Card.CARD_REVERSE_HERMIT ..
						"}} Spawns 1-5 random {{Coin}} coins",

						"#{{Card" .. Card.CARD_REVERSE_WHEEL_OF_FORTUNE .. "}} Uses {{Collectible" .. CollectibleType.COLLECTIBLE_D8 .. "}} D8, {{Collectible" .. CollectibleType.COLLECTIBLE_D10 .. "}} D10, or {{Collectible" .. CollectibleType.COLLECTIBLE_D12 .. "}} D12"
						.. "#{{Card" .. Card.CARD_REVERSE_STRENGTH .. "}} {{Timer}} For 30 seconds: Half of all enemies in the room receive {{Weakness}} weakness"
						.. "#{{Card" .. Card.CARD_REVERSE_HANGED_MAN .. "}} {{Timer}} Receive for 30 seconds: {{Collectible" .. CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER .. "}}, {{Damage}} x1.5 Damage multiplier"
						.. "#{{Card" .. Card.CARD_REVERSE_DEATH .. "}} {{Friendly}} Spawns a random friendly bone enemy"
						.. "#{{Card" .. Card.CARD_REVERSE_TEMPERANCE .. "}} Uses a random {{Pill}} pill"
						.. "#{{Card" .. Card.CARD_REVERSE_DEVIL .. "}} Flight for the room",

						"#{{Card" .. Card.CARD_REVERSE_TOWER .. "}} Spawns a cluster of random rocks and obstacles"
						.. "#{{Card" .. Card.CARD_REVERSE_STARS .. "}} Removes Isaac's oldest passive item (ignoring starting items) and spawns 1 random item from the current room's pool"
						.. "#{{Card" .. Card.CARD_REVERSE_MOON .. "}} Spawns {{Card" .. Card.CARD_CRACKED_KEY .. "}} Cracked Key, reveals the {{UltraSecretRoom}} Ultra Secret Room",

						"#{{Card" ..
						Card.CARD_REVERSE_SUN ..
						"}} {{Timer}} Receive for the room: {{Collectible" .. CollectibleType.COLLECTIBLE_SPIRIT_OF_THE_NIGHT .. "}} Spirit of the Night, {{Damage}} +1.5 Damage, darkened room"
						.. "#{{Card" .. Card.CARD_REVERSE_JUDGEMENT .. "}} Uses {{Collectible" .. CollectibleType.COLLECTIBLE_D6 .. "}} D6 and {{Collectible" .. CollectibleType.COLLECTIBLE_D20 .. "}} D20"
						.. "#{{Card" .. Card.CARD_REVERSE_WORLD .. "}} Uses {{Collectible" .. CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER .. "}} We Need To Go Deeper!"
					}
				)
				end
			}
		},
	}
end
