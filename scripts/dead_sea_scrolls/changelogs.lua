local function iterLines(s) -- stack overflow continuing to make my life easier :) https://stackoverflow.com/a/19329565
	if s:sub(-1) ~= "\n" then
		s = s .. "\n"
	end
	return s:gmatch("(.-)\n")
end

local function WrapPatchNotes(str)
	local finalStr = ""
	for line in iterLines(str) do
		local size = 40
		if line:sub(1, 2) == "##" then
			line = "{FSIZE2}" .. line:sub(3)
			size = 30
		elseif line:sub(1, 1) == "#" then
			line = "{FSIZE3}" .. line:sub(2)
			size = 15
		end

		local words = {}
		for word in line:gmatch("%S+") do
			table.insert(words, word)
		end

		local currentLine = ""
		for _, word in ipairs(words) do
			if currentLine:len() + word:len() + 1 > size then
				finalStr = finalStr .. currentLine .. "\n"
				currentLine = word
			else
				currentLine = currentLine .. " " .. word
			end
		end

		finalStr = finalStr .. currentLine .. "\n"
	end

	finalStr = finalStr:gsub(";", ":")
	finalStr = finalStr:gsub("`", '"')
	finalStr = finalStr:gsub("*", "--")
	finalStr = finalStr:gsub("~", "---")

	return finalStr
end
--luacheck: push no max line length
--[[ Template here.
--= GENERAL ADJUSTMENTS/BUG FIXES =--
--= GAMEPLAY CHANGES =--
--= VISUAL CHANGES =--
--= MOD COMPATIBILITY =--
--= EID FIXES + COMMUNITY =--
--= CUSTOM HEALTH API ENHANCEMENTS =--
--= ARACHNA API CHANGES =--]]

DeadSeaScrollsMenu.AddChangelog(
"Arachna",
"2.0",
WrapPatchNotes([[MM/DD/YYYY

#2.0.0 (??/??/2025)

The mod has been entirely rewritten from the ground up. There

--= GENERAL ADJUSTMENTS/BUG FIXES =--
- The amount of bugs fixed as a direct result of the switch to REPENTOGON or the rewritten code is difficult to account for, but there should generally be improvements across the whole mod!
- Added a Dead Sea Scrolls menu where you can check settings, achievements, current and past changelogs, and credits
- The mod settings are also available in Mod Config Menu
- Changed Tainted Arachna's multishot to use REPENTOGON instead of an item wisp. Among other things, this allows their multishot to be utilized in the Mines chase sequence
- Fixed sparkles from Arachna's Golden Spiders not being removed properly, causing increasing amounts of lag over time until you left the room
- Fixed the Spider Egg orbital from Arachnid's Grip not having a variant assigned, which had self-assigned itself a variant of 0
- Removed GiantBookAPI utility in favor of REPENTOGON implementation
- Changed how Lil Arachna functions to be a more naturally integrated shooter familiar. They now obey all shooter familiar interactions (Lilith birthrights, shooter priority, etc.)
- Fixed Golden Shopkeeper not using the trinket pool for its rarely dropped golden trinket, meaning it can now spawn modded golden trinkets
- Changed how Web Hearts, Spider Beggars, and Golden Shopkeepers randomly replace entities. Web Hearts are now better integrated into the "pickup pool" to have spawn rules that better match the vanilla game. Spider Beggars and Golden Shopkeepers only replace their respective replacements when part of a newly entered room
- Changed Soul of Arachna and Merged Card announcer sfx to respect user's announcer settings instead of playing 100% of the time
- Added slight delays to when the aforementioned announcer sfx plays
- Changed Mechanical Eye to no longer look at your secondary held active for displaying an active item to use
- Changed Mechanical Eye's blacklist to account for any items that use a timed or special charge instead of manually listing them, inclding modded actives
- Changed how orbitals are added to the player. They will have differing speeds/distances compared to before, but now occupy the same layers as other orbitals
- Changed Arachnid's Grip to detect the "fly" tag on enemies for having a chance to heal the player instead of a manual list, allowing it to be compatible with modded enemies
- Removed the small delay The Yarn had dropping a Web Heart upon clearing 4 rooms
- Changed the number display for Geptameron to be on the active item instead of next to the key counter
- Fixed Testament crashing the game
- Fixed the item shadow from Testament pedestals not disappearing when items were taken off them
- Improved handling of Dad's Newspaper's "club"

--= GAMEPLAY CHANGES =--
- Added 4 new items for the boss pool: Spider Donut, Old Shoebox, Candy Floss, and Gummy Spiders
- Added a new special item: Spider Cake. It only appears for Arachna and Tainted Arachna when starting a run on the day of the mod's release date
- All stat changes present for the mod's characters and items now respect damage and firerate multipliers
- Removed item blacklist for Arachna and Tainted Arachna. They can now find Glass Cannon, Yuck Heart, Magic Skin, Genesis, and Brittle Bones again
- Arachna and Tainted Arachna no longer get slowed from cobwebs on the ground
- Changed logic of Web Heart interaction with Spider Eggs on Arachna + Birthright and Tainted Arachna to match non-Arachna players, where it increases the potential maximum amount of spiders to be spawned instead of guaranteeing an additional amount of spiders to spawn
- Enemies below 10 HP or those spawned by other enemies now spawn small versions of Spider Eggs on death, which will spawn less spiders. Enemies spawned by other enemies only have a 50% chance to spawn a small egg
- Bosses are no longer immune to the slowing effect of Arachna's Spool and Divine Cloth, but aren't slowed as much as a regular slowing effect
- Shooting bosses under Arachna's Spool's or Divine Cloth's slowing effect will charge a meter above their head. When the meter is filled, it resets and the boss spawns a small spider egg that instantly breaks into friendly spiders
- Changed Web Hearts replacing specific heart types to trigger if every player is either Arachna or Tainted Arachna, not counting "Strawman" players, instead of just one character being Arachna or Tainted Arachna
- The above change is also reflected for Web Hearts turning into blue spiders for any "Keeper" characters
- 3D Glasses now works for all weapon types
- 3D Glasses now copies the champion color of the enemy for its 3D copies
- Infested Penny's chance to spawn a Web Heart now scales with both the value of the coin and trinket multipliers
- Arachna's Spool now copies the following tear effects from the player: Spectral, Homing, Wiggle Worm, Brain Worm, Lost Contact, Continuum, and Tractor Beam
- Reduced collision size of Mechanical Eye, The Yarn, and Arachnid Grip's Spider Egg orbitals
- Mechanical Eye now respects unlocks for what active items can be used
- Mechanical Eye can now be used with throwable actives, such as Bob's Rotten Head and Black Hole, and activates when the actives are discharged
- Added D4 and D100 to Mechanical Eye's blacklist
- The Yarn no longer inherits the player's tear effects
- The Yarn is now categorized as a defensive familiar, being closer to the player in the follower line
- The Yarn and Geptameron's per-room effects now trigger for challenge and boss rush waves
- Spider Beggar no longer drops pickups upon death, instead spawning 2 spiders similar to Devil Beggar
- Spider Beggar now follows the same rules and chances to reward the player as a regular beggar
- Added the curse mist effect to Testament's special room
- Testament can now be found and used in Greed Mode
- Testament can no longer be used in runs that do not allow achievements, instead spawning Eden's Blessing
- Testament pedestals for the next run no longer spawn in runs that do not allow achievements
- Added support for multiple uses of Testament, which will spawn all subsequently chosen items in the next valid run. The same item cannot be chosen again and an empty pedestal will appear in its place. A maximum of 2 items are allowed on the next run before Testament instead spawns Eden's Blessing

--= VISUAL CHANGES =--
- The "webbed" sprite from Divine Cloth has been moved to enemies webbed by Arachna's Spool. Divine Cloth's "Spider Bite" status has a new icon to compensate
- Size of web on enemies now scale with the enemy's size
- Rainbow and Golden Spiders now change the color of their glow to match their own color
- Changed poison tears from Arachnid's Grip to be colored green
- Arachna and Tainted Arachna's portraits no longer shake in the boss vs. and stage transition screens

--= MOD COMPATIBILITY =--
- Added MinimapAPI compatibility
- Updated all English EID descriptions
- Fixed White String's EID description incorrectly mentioning it increased Web Heart chances. Sprindle now correctly mentions this effect
- Added mod icon for EID

--= INTERNAL CHANGES =--
Arachna didn't really have an API before, which is where I would put this down, but these changes are important to note for any mods with mod compatibility with Arachna
- Arachna now requires REPENTOGON on Repentance+ to function. REPENTOGON on regular Repentance will not work
- The entire mod's code was rewritten from the ground up. Everything on the mod is now properly attached to the "ARACHNAMOD" global
- Save data is now handled through IsaacSaveManager. Previous save data on completion marks should be automatically transferred to REPENTOGON's own save data for completion marks and achievements
- The utility of throwing Arachna's Spool now utilizes ThrowableItemLib for general improvements and cross-MOD compatibility
- Web Hearts now utilize CustomHealthAPI for general improvements and cross-MOD compatibility
- Status effects now utilize StatusEffectLibrary for general improvements and cross-MOD compatibility
- Golden Shopkeeper is now an actual shopkeeper (type 17) instead of an effect (type 1000)
- Web Heart's variant is now PickupVariant.PICKUP_HEART rather than their own unique variant
- The pool of items for Spider Beggar to pay out with is now an actual item pool thanks to REPENTOGON, named "spiderBeggar"]])
)

DeadSeaScrollsMenu.AddChangelog(
"Arachna",
"1.0",
WrapPatchNotes([[MM/DD/YYYY

#1.5.3 (08/03/2022)

- fixed certain epiphany (and potentially other mods) incompatibility regarding shopkeepers. special thanks to dpower12 for finding this

#1.5.3 (07/11/2022)

- added voiceovers to collectibles!

#1.5.2 (06/27/2022)

- fixed mech eye effect not following it and 1 nil error related to this item
- fixed game crash on game start if tainted arachna was not unlocked

#1.5.1 (06/25/2022)

fixed 2 bugs related to the mechanical eye

#1.5.0 (06/22/2022)

- fixed several nil value errors in certain places of the code
- fixed no reroll for t eden on web heart hit
- now web hearts can't replace other hearts inside of Super Secret Rooms?
- moved things around a bit in itempools
- added Chinese (by Saurtya) and Russian (by me) EID support
- fixed balding in the mines section (thanks JudeInutil!)
- changed base of the web hearts from soul hearts to black hearts
- fixed perfection still appearing with web heart damaged
- fixed shop and devil room prices for web heart pickup
- fixed certain game-crashing error related to pocket actives
- mechanical eye closes for items with infinite uses
- fixed mutant spider wisp appearing upon use of glowing hourglass
- fixed some problems related to Testament

#1.4.4 (05/10/2022)

- fixed some previously unreported errors I found during the playtesting

#1.4.3 (05/05/2022)

- fixed dead cat bug

#1.4.2 (05/05/2022)

- fixed interaction of familiars and gulped trinkets

#1.4.1 (05/05/2022)

- fixed errors regarding co-op (at least I hope so, I don't have a controller to test it)

#1.4.0 (05/04/2022)

- made golden shopkeepers spawn exclusively in shop rooms, so the certain mod conflict has less chances of occuring
- blacklisted brittle bones
- slight buff to tainted arachna stats
- t arachna birthright bug
- player now loses perfection on web heart hit (kinda)

#1.3.1a (05/03/2022)

- I forgot to remove one copy file lmao

#1.3.1 (05/03/2022)

- fixed wafer bug
- fixed blood bombs bug
- fixed certain bug with black hearts (thanks to brakedude)

#1.3.0 (05/03/2022)

- web hearts progress sacrifice room
- changed the way items are locked
- removed one nerf from tainted arachna

#1.2.1 (05/03/2022)

- fixed one bug related to devil deals

#1.2.0 (05/02/2022)

- attempt to balance tainted arachna

#1.1.2a (05/02/2022)

- attempt 2

#1.1.2 (05/02/2022)

- fixed one co-op related bug I think?

#1.1.1 (05/01/2022)

- fixed one of the reported bugs
- added mini-wiki in google documents or whatever that thing is called

#1.1.0a (05/01/2022)

- I'm stupid

#1.1.0 (05/01/2022)

- explosive spiders now not deal damage to the player
- arachna's spool doesn't break upon touching cube baby
- globins don't drop spider eggs now
- added one secret web heart interaction with a certain thing. previously this interaction was purely visual, but now it has actual effect
- fixed insta death on soul heart devil deals
- fixed nil values appearing in some parts of save system
- arachna's spool projectile now doesn't inherit tear effects of trisagon, fire mind and similar effects

#1.0.2 (04/29/2022)

- increased payout chance for spider beggar
- fixed bug with bombing golden shopkeeper
- tainted version now displays text that it was not unlocked instead of straight up crashing the game

#1.0.1 (04/29/2022)

- fixed 12-heart hp up bug reported by lopata gaming
- frozen enemies don't drop spider eggs now
- fixed bug related with requirements to pick up web hearts
balding in mines sequence and mausoleum door thingy are apparently unfixable :(

#1.0.0 (04/29/2022)

Release!]])
)

--luacheck: pop