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

DeadSeaScrollsMenu.AddChangelog(
	"Arachna",
	"Version 2",
	WrapPatchNotes([[MM/DD/YYYY

#2.0.2 (05/01/2026)
- Removed shaders
- Replaced The Testament room shader with room darkness

#2.0.1 (05/01/2026)
- Fixed Mechanical Eye causing an error when using an active item that it shouldn't generate a valid active item with
- Implemented the patented "shader crash fix"
- Fixed Infested Penny not being able to spawn Web Hearts
- Fixed the screen going berserk if Arachna was launched without REPENTOGON on Repentance+ or failed to fully load

#2.0.0 (04/29/2026)

## Major Mod Rewrite

The mod has been entirely rewritten from the ground up by benevolusgoat/Benny! The mod now requires REPENTOGON on Repentance+ to function, a large quantity of bugs have been fixed, some new content has been added, and balancing adjustments have been made across the entire mod.

## GENERAL ADJUSTMENTS
- Added a Dead Sea Scrolls menu where you can check settings, achievements, current and past changelogs, and credits
- Added new mod settings. Available in the DSS menu
- Arachna's console commands now have autofill thanks to REPENTOGON
- Added multiple new debug commands
- Changed Tainted Arachna's multishot to use REPENTOGON instead of an item wisp. Among other things, this allows their multishot to be utilized in the Mines chase sequence
- Removed GiantBookAPI utility in favor of REPENTOGON implementation
- Changed how Lil Arachna functions to be a more naturally integrated shooter familiar. They now obey all shooter familiar interactions (Lilith birthrights, shooter priority, etc.)
- Added Hive Mind synergy to Lil Arachna, giving BFFS! benefits
- Added "spider" tag to Lil Arachna, contributing to the Spider Baby transformation
- Changed how Web Hearts, Spider Beggars, and Golden Shopkeepers randomly replace entities. Web Hearts are now better integrated into the "pickup pool" to have spawn rules that better match the vanilla game. Spider Beggars and Golden Shopkeepers only replace their respective replacements when part of a newly entered room
- Changed Soul of Arachna and Merged Card announcer sfx to respect user's announcer settings instead of playing 100% of the time
- Added slight delays to when the aforementioned announcer sfx plays
- Changed Mechanical Eye to no longer look at your secondary held active for displaying an active item to use
- Added BFFS! synergy to Mechanical Eye
- Changed how the mod's orbitals are added to the player. They will have differing speeds/distances compared to before, but now occupy the same layers as other orbitals
- Removed the small delay The Yarn had dropping its Web Heart
- Improved melee handling of Dad's Newspaper
- A multitude of items are now available to Tainted Lost, Lemegeton, and Modeling Clay

## BUG FIXES
- Fixed Testament crashing the game
- Fixed the item shadow from Testament pedestals not disappearing when items were taken off them
- Fixed mod incompatibility with Golden Shopkeeper's rarely dropped golden trinket
- Fixed mod incompatibility with Mechanical Eye's blacklist
- Fixed mod incompatibility with Arachnid's Grip effect of instakilling fly enemies
- Fixed sparkles from Arachna's Golden Spiders not being removed properly, causing increasing amounts of lag over time until you left the room
- Fixed the Spider Egg orbital from Arachnid's Grip not having a variant assigned, which had self-assigned itself a variant of 0
- Fixed Web Hearts replacing specific heart types if any Arachna players were present, even if other co-op players weren't Arachna
- Fixed Web Hearts turning into blue spiders if any Keeper players were present, even if other co-op players weren't a Keeper
- Fixed Spider Egg pickups from Arachnid's Grip persisting if you left the room

## GAMEPLAY CHANGES
The newly available "Legacy Gameplay" option allows certain changes to be reverted to how they acted before this update.
Changes that will be reverted with the setting set to Off are marked with a *.

New Content:
- Added 5 new items after unlocking Web Hearts: Spider Donut, Old Shoebox, Candy Floss, Gummy Spiders, and Arachnology 101
- Added a new special item: Spider Cake. It only appears for Arachna and Tainted Arachna when starting a run on the day of the mod's release date
- Added Reversed Merged Card (suggestion by cadetpirx!). It's unlocked alongside the normal Merged Card

Arachna:
* Decreased chance for colored spiders from 50% to 35%
* Birthright adjusted. Instead of +1 to spawned spiders, +15% chance for spider eggs spawning colored spiders

Tainted Arachna:
* Removed inherent +1 guaranteed spider spawn from Spider Eggs
* All spider eggs are smaller
* Can no longer get random spider colors from spider spawns
* Can no longer get big spiders from eggs spawned by regular enemies
* Removed timer mechanic on spider eggs
* Spider eggs can now spawn as a specific color. Upon breaking, all spiders spawned from it are of the same color
* Divine Cloth has been moved to a double-tap action and now deals damage
* New Pocket Active: Egg Toss. Grab and throw your eggs, which come with benefits when thrown and moreso when they hit enemies
* Increased starting damage to 2.00 (from 1.00)
* Increased starting speed to 1.00 (from 0.75)

Web Hearts:
- Bone and Eternal Hearts are allowed to be gained again through items or other means. Their pickup equivalent are still converted into Web Hearts
- Arachna and Tainted Arachna's Web Hearts are sorted before soul hearts, similarly to heart containers
- One Web Heart can tank any amount of damage, similarly to Bone Hearts
- Web Hearts only affect devil deal chance/Perfection on Arachna and Tainted Arachna instead of all characters
- Inherent poison tears now work on all weapon types
- Added interaction with Potato Peeler to have Web Hearts act as a valid substitute for Red Heart Containers on Arachna only

Arachna's Spool/Divine Cloth:
* Doubled hitsphere size of Arachna's Spool tear
* Arachna's Spool's web reduces knockback to enemies, making it easier to keep them Webbed
* Arachna's Spool's web no longer affects enemies that are above pits
* If Arachna's Spool's tear kills an enemy, it counts as them being Webbed and will spawn a Spider Egg
* Increased recharge time of Arachna's Spool and Divine Cloth to 6 seconds (from 3 seconds)
* Removed stage multiplier and Web Heart interaction on how many spiders spawned from Spider Eggs
* Bosses are no longer immune to the slowing effect by the Webbed status, but aren't slowed as much as a regular slowing effect
* Increased Divine Cloth's radius to match Tainted Arachna's old birthright radius
* Divine Cloth's swirl follows Isaac, which helps with affecting enemies Isaac is moving towards
* Dealing damage to bosses with Webbed or Spider Bite will charge a meter above their head. When the meter is filled, it resets and spawns friendly spiders or a spider egg, depending on which status they have. Friendly spiders do not contribute to the meter
* Spider Eggs now hatch on challenge/boss rush wave clears
* Enemies that previously did not drop spider eggs on death now drop a single friendly spider
* Webbed Bosses can now drop a Spider Egg on death. 50% of the spawned spiders will be big spiders
* Updated chance logic for spawning special and big spiders. Instead of one massive weighted table, there will be a static chance for spiders to become colored, which when pulls from a weighted table of colors, and a static chance for them to become big
* Rainbow Spiders take off 1/10th of a boss' health (1/8th as a big spider), down from 1/8th (1/4th as a big spider)

Other:
- Removed item blacklist for Arachna and Tainted Arachna. They can now find Glass Cannon, Yuck Heart, Magic Skin, Genesis, and Brittle Bones again
- Poison tears from Arachnid's Grip now work on all weapon types
- Tainted Arachna's completion mark unlocks no longer require being on Hard Mode
- Breaking Web Hearts on other characters no longer enact penalties, such as devil deal chance
- Reworked Best Bud Ball. 8 charges, only has a chance to capture bosses that scales with its HP and luck, isn't removed when capturing a boss, only one Best Bud Ball capture at a time. Can no longer capture major story bosses
- Reworked Geptameron. Still retains its shifting 7 day effects, but all days have been given new effects or had their effects tweaked. No longer grants flight or stats
- Arachna and Tainted Arachna's base stats and item stats now respect damage and firerate multipliers
- 3D Glasses now works for all weapon types
- 3D Glasses now copies the champion color of the enemy for its 3D copies
- Infested Penny's chance to spawn a Web Heart now scales with both the value of the coin and trinket multipliers
- Reduced collision size of Mechanical Eye, The Yarn, and Arachnid Grip's Spider Egg orbitals
- Changed what actives Mechanical Eye can display and what actives it can copy a charge off of. This is vague for the sake of not making a long list, but aims to be more versatile
- Added D4 and D100 to Mechanical Eye's blacklist
- The Yarn no longer inherits the player's tear effects
- The Yarn is now categorized as a defensive familiar, being closer to the player in the follower line
- The Yarn and Geptameron's per-room effects now trigger for challenge and boss rush waves
- Spider Beggar no longer drops pickups upon death, instead spawning 2 blue spiders
- Spider Beggar now follows the same rules and chances to reward the player as a regular beggar
- Added the curse mist effect to The Testament's special floor
- The Testament can now be found and used in Greed Mode
- The Testament can no longer be used in runs that do not allow achievements, instead spawning Eden's Blessing
- The Testament pedestals for the next run no longer spawn in runs that do not allow achievements
- Added support for multiple uses of The Testament, which will spawn all subsequently chosen items in the next valid run. The same item cannot be chosen again and an empty pedestal will appear in its place. A maximum of 2 items are allowed on the next run before The Testament instead spawns Eden's Blessing
- The chosen item for The Testament now removes that item from the player's inventory
- The Testament can no longer bring starting items or quest items to its special floor
- Merged Card's Wheel of Fortune effect now uses Portable Slot instead of its own custom logic
- Mutagen's ability to turn blue spiders from select items into colored spiders now affects all non-spider egg blue spider spawns
- Updated item pools
- Web Heart Clots now have a 25% chance to shoot slowing tears
- Using Yarn Heart with coin health characters (e.g. Keeper) spawns 2 blue spiders
- Lil Arachna, Soul of Arachna, and Spindle inflict Webbed instead of Ensnared

## VISUAL CHANGES
- All new achievement page sprites by damagaz
- Divine Cloth's "Spider Bite" status (now renamed to Ensnared) has a new icon to differenciate it from the Webbed status from Arachna's Spool
- Size and sprite of the spider web on Webbed enemies now scale with the enemy's size
- Rainbow and Golden Spiders now change the color of their glow to match their own color
- Arachna and Tainted Arachna's portraits no longer shake in the boss vs. and stage transition screens
- Changed the floor web from Arachna's Spool to render below grid entities, similarly to creep
- Arachna and Tainted Arachna have the same laser color as the Spider Bite item
- Moved Geptameron's day of the week counter to the active item sprite with a new look

## EID CHANGES
- Created all new English descriptions from scratch, which have been translated into Polish, Korean, Ukrainian, Russian, and Chinese. You can go to the GitHub repository and make a fork in order to submit a PR if you wish to contribute more languages.
- Fixed White String's description incorrectly mentioning it increased Web Heart chances. Spindle now correctly mentions this effect
- Added mod icon
- Moved Merged Card's description into a unique "TAB description", where you can expand the list of effects separated by pages
- Arachna and Tainted Arachna are recognized as soul heart-only characters, updating descriptions mentioning health ups or healing red hearts

## MOD COMPATIBILITY
- Fixed Tarnished Keeper from Epiphany not being able to pick up the orbitals from Arachnid's Grip
- Added compatibility for the following mods: MinimapAPI, Ugh for Bad Items, Unique Minisaacs, Specialist Dance, The Future, Birthcake: Rebaked
- Updated compatibility for the following mods: Time Machine PLUS, Library Expanded
- Tarnished Keeper from Epiphany is now accounted for as a Keeper character to turn Web Hearts into blue spiders
- Added compatibility for Throwing Bag from Epiphany. Many of Arachna's items can be bagged for specific types of bags

## INTERNAL CHANGES
Important changes for modders to be aware of for updating compatibility with Arachna
- Arachna's mod global has been changed from ARACHNAMOD to ArachnaMod. This is so that patches from other mods wont break in unforseen ways and will only function if support is updated.
- Arachna now requires REPENTOGON on Repentance+ to function. REPENTOGON on regular Repentance will not work
- The entire mod's code was rewritten from the ground up. Nearly everything on the mod is now properly attached to the "ArachnaMod" global
- Save data is now handled through the Isaac Save Manager library. Previous save data on completion marks should have automatically transferred to REPENTOGON's own save data for completion marks and achievements
- The utility of throwing Arachna's Spool now utilizes ThrowableItemLib for general improvements and cross-MOD compatibility
- Web Hearts now utilize CustomHealthAPI for immense improvements and cross-MOD compatibility
- Status effects now utilize StatusEffectLibrary for general improvements and cross-MOD compatibility
- Golden Shopkeeper is now an actual shopkeeper (type 17) instead of an effect (type 1000)
- Web Heart's pickup variant is now a heart (variant 10) rather than their own unique variant
- Best Bud Ball's effect variant is now a unique number instead of being a subtype of Friendly Ball
- The pool of items for Spider Beggar to pay out with is now an actual item pool thanks to REPENTOGON, named "spiderBeggar"
- Filenames for sprites with multiple words changed to use underscores instead of dashes
- "Spiderboi (beggar)" renamed to "Spider Beggar"
- "Testament" renamed to "The Testament"
- "Sprindle" renamed to "Spindle"]])
)

DeadSeaScrollsMenu.AddChangelog(
	"Arachna",
	"Version 1",
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
