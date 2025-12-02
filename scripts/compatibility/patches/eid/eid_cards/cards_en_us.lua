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
				"2 random effects:",
				"#{{Card" .. Card.CARD_FOOL .. "}} Uses {{Collectible" .. CollectibleType.COLLECTIBLE_D7 .. "}} D7",
				"#{{Card" .. Card.CARD_MAGICIAN .. "}} {{Slow}} Slow all enemies",
				"#{{Card" .. Card.CARD_HIGH_PRIESTESS .. "}} {{MomBossSmall}} stomps Isaac",
				"#{{Card" ..
				Card.CARD_EMPRESS .. "}} Uses {{Collectible" .. CollectibleType.COLLECTIBLE_THE_NAIL .. "}} The Nail",
				"#{{Card" .. Card.CARD_EMPEROR .. "}} Reveals {{BossRoom}}",
				"#{{Card" .. Card.CARD_HIEROPHANT .. "}} Spawns 2 {{HalfSoulHeart}}",
				"#{{Card" .. Card.CARD_LOVERS .. "}} Spawns 2 {{HalfHeart}}",
				"#{{Card" ..
				Card.CARD_CHARIOT .. "}} Uses {{Collectible" .. CollectibleType.COLLECTIBLE_UNICORN_STUMP ..
				"}} Unicorn Stump",
				"#{{Card" .. Card.CARD_JUSTICE .. "}} Spawns 2 pickups",
				"#{{Card" ..
				Card.CARD_HERMIT .. "}} Uses {{Collectible" .. CollectibleType.COLLECTIBLE_KEEPERS_BOX .. "}} Keeper's Box",
				"#{{Card" .. Card.CARD_WHEEL_OF_FORTUNE .. "}} Uses {{Slotmachine}} 3 times",
				"#{{Card" .. Card.CARD_STRENGTH .. "}} {{Room}}: Stats up",
				"#{{Card" .. Card.CARD_HANGED_MAN .. "}} Destroys rocks, fills pits",
				"#{{Card" .. Card.CARD_DEATH .. "}} Deals 20{{DamageSmall}} to enemies",
				"#{{Card" .. Card.CARD_TEMPERANCE .. "}} Spawns a {{DemonBeggar}}",
				"#{{Card" .. Card.CARD_DEVIL .. "}} {{Room}}: +1 {{DamageSmall}}",
				"#{{Card" .. Card.CARD_TOWER .. "}} Spawns 3 Troll Bombs",
				"#{{Card" .. Card.CARD_STARS .. "}} Spawns {{GoldenChest}}",
				"#{{Card" .. Card.CARD_MOON .. "}} Reveals {{SecretRoom}}{{SuperSecretRoom}}{{UltraSecretRoom}}",
				"#{{Card" ..
				Card.CARD_SUN ..
				"}} Reveals {{TreasureRoom}}{{Planetarium}}, heals 1 {{Heart}}, deals 5{{DamageSmall}} to enemies",
				"#{{Card" .. Card.CARD_JUDGEMENT .. "}} Spawns a shopkeeper",
				"#{{Card" .. Card.CARD_WORLD .. "}} Reveals {{TreasureRoom}}{{Planetarium}}",
			}
		},
		[Mod.Card.MERGED_CARD_REVERSED.ID] = {
			Name = "Merged Card?",
			Description = {
				"2 random effects:",
				"#{{Card" .. Card.CARD_REVERSE_FOOL .. "}} Drops all {{Coin}}, {{Bomb}}, or {{Key}}",
				"#{{Card" .. Card.CARD_REVERSE_MAGICIAN .. "}} Uses {{Collectible" .. CollectibleType.COLLECTIBLE_TELEKINESIS .. "}} Telekinesis x2",
				"#{{Card" .. Card.CARD_REVERSE_HIGH_PRIESTESS .. "}} {{Timer}}: {{MomBossSmall}} stomps Isaac",
				"#{{Card" ..
				Card.CARD_REVERSE_EMPRESS .. "}} {{Room}}: +1 {{Heart}}, +0.75 {{TearsSmall}}, -0.05 {{SpeedSmall}}",
				"#{{Card" .. Card.CARD_REVERSE_EMPEROR .. "}} Spawns a {{ColorRainbow}}rainbow{{CR}} champion",
				"#{{Card" .. Card.CARD_REVERSE_HIEROPHANT .. "}} Spawns 1 {{EmptyBoneHeart}}",
				"#{{Card" .. Card.CARD_REVERSE_LOVERS .. "}} +1 {{BrokenHeart}}, +0.25 {{Damage}}",
				"#{{Card" ..
				Card.CARD_REVERSE_CHARIOT .. "}} {{Timer}}: x0.5 {{SpeedSmall}}, x2 {{TearsSmall}}",
				"#{{Card" .. Card.CARD_REVERSE_JUSTICE .. "}} Spawns 1-2 {{GoldenChest}}",
				"#{{Card" ..
				Card.CARD_REVERSE_HERMIT ..
				"}} Spawns 1-5 random {{Coin}}s",
				"#{{Card" .. Card.CARD_REVERSE_WHEEL_OF_FORTUNE .. "}} Uses {{Collectible" .. CollectibleType.COLLECTIBLE_D8 .. "}}, {{Collectible" .. CollectibleType.COLLECTIBLE_D10 .. "}}, or {{Collectible" .. CollectibleType.COLLECTIBLE_D12 .. "}}",
				"#{{Card" .. Card.CARD_REVERSE_STRENGTH .. "}} {{Timer}}: Half of enemies {{Weakness}} weak",
				"#{{Card" .. Card.CARD_REVERSE_HANGED_MAN .. "}} {{Timer}}: +1 {{Collectible" .. CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER .. "}}, x1.5 {{DamageSmall}}",
				"#{{Card" .. Card.CARD_REVERSE_DEATH .. "}} {{Friendly}} Friendly bone enemy",
				"#{{Card" .. Card.CARD_REVERSE_TEMPERANCE .. "}} Uses a random {{Pill}}",
				"#{{Card" .. Card.CARD_REVERSE_DEVIL .. "}} {{Room}}: {{Seraphim}} Flight",
				"#{{Card" .. Card.CARD_REVERSE_TOWER .. "}} Spawns rock cluster",
				"#{{Card" .. Card.CARD_REVERSE_STARS .. "}} Remove oldest item, spawn new item",
				"#{{Card" .. Card.CARD_REVERSE_MOON .. "}} Spawns {{Card" .. Card.CARD_CRACKED_KEY .. "}}, Reveals {{UltraSecretRoom}}",
				"#{{Card" ..
				Card.CARD_REVERSE_SUN ..
				"}} {{Room}}: +1 {{Collectible" .. CollectibleType.COLLECTIBLE_SPIRIT_OF_THE_NIGHT .. "}}, dark room, +1.5 {{DamageSmall}}",
				"#{{Card" .. Card.CARD_REVERSE_JUDGEMENT .. "}} Uses {{Collectible" .. CollectibleType.COLLECTIBLE_D6 .. "}} D6 and {{Collectible" .. CollectibleType.COLLECTIBLE_D20 .. "}} D20",
				"#{{Card" .. Card.CARD_REVERSE_WORLD .. "}} Uses {{Collectible" .. CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER .. "}} We Need To Go Deeper!",
			}
		},
	}
end
