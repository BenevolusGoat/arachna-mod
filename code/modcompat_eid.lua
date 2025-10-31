if EID then
	--icons
	local arachnaEIDSprites = Sprite()
	arachnaEIDSprites:Load("gfx/eid_icons_arachna.anm2", true)
	EID:addIcon("Arachna", "UI", 0, 16, 16, 0, 0, arachnaEIDSprites)
	EID:addIcon("ArachnaB", "UI", 1, 16, 16, 0, 0, arachnaEIDSprites)
	EID:addIcon("GridRock", "UI", 2, 12, 12, 0, 0, arachnaEIDSprites)
	EID:addIcon("GridPit", "UI", 3, 12, 12, 0, 0, arachnaEIDSprites)
	EID:addIcon("GridBridge", "UI", 4, 12, 12, 0, 0, arachnaEIDSprites)
	EID:addIcon("WebHeart", "UI", 5, 9, 9, 0, 0, arachnaEIDSprites)
	EID:addIcon("BlueSpider", "UI", 6, 8, 8, 0, 0, arachnaEIDSprites)
	EID:addIcon("ShopKeeper", "UI", 7, 8, 10, 0, 0, arachnaEIDSprites)
	EID:addIcon("TrollBomb", "UI", 8, 11, 14, 0, 0, arachnaEIDSprites)
	EID:addIcon("SpiderEgg", "UI", 9, 12, 14, 0, 0, arachnaEIDSprites)

	--ENGLISH (done by me)
	--birthrights
	EID:addBirthright(Isaac.GetPlayerTypeByName("Arachna", false), "Now your {{Collectible".. Isaac.GetItemIdByName("Arachna's Spool") .."}} can leave 2 webs instead of 1 #Now {{WebHeart}} guarantee +1 {{BlueSpider}} from each {{SpiderEgg}} #Now {{SpiderEgg}} can leave {{WebHeart}} on break", "Arachna")
	EID:addBirthright(Isaac.GetPlayerTypeByName("Arachna", true), "Increases length of the debuff #Increases enemy target radius #Using {{Collectible".. Isaac.GetItemIdByName("Divine Cloth") .."}} increases {{Timer}} of nearby {{SpiderEgg}}", "Tainted Arachna")
	--items
	EID:addCollectible(Isaac.GetItemIdByName("Spider Cake"), "{{WebHeart}} Spawns 1 Web Heart #{{ArrowUp}} All stats up, based on how many years passed since mod release #{{Collectible".. CollectibleType.COLLECTIBLE_MYSTERY_GIFT .."}} Turns into Mystery Gift when picked up", "Spider Cake")
	EID:addCollectible(Isaac.GetItemIdByName(" Spider Donut "), "{{WebHeart}} +1 Web Heart #{{ArrowUp}} DMG up #{{BlueSpider}} Grants several Big Blue Spiders", "Spider Donut")
	EID:addCollectible(Isaac.GetItemIdByName("Old Shoebox"), "{{WebHeart}} Spawns 1 Web Heart #{{ArrowUp}} Tears and Speed up #{{BlueSpider}} Grants several Blue Spiders", "Old Shoebox")
	EID:addCollectible(Isaac.GetItemIdByName("Gummy Spiders"), "{{WebHeart}} +2 Web Heart #{{ArrowUp}} Tears up #{{BlueSpider}} Grants several {{ColorRainbow}}special{{CR}} Friendly Spiders", "Gummy Spiders")
	EID:addCollectible(Isaac.GetItemIdByName("Candy Floss"), "{{WebHeart}} Drains all your red health and spawns several Web Hearts. If there's no health, spawns 3 Web Hearts #Your tears can cover enemies in web with some chance", "Candy Floss")
	
	EID:addCollectible(Isaac.GetItemIdByName("Divine Cloth"), "Puts {{Slow}} on nearby monsters #Enemies {{Slow}} by this item drop {{SpiderEgg}} with {{Timer}} on death #Upon clearing room/greed wave {{SpiderEgg}} breaks, leaving some {{BlueSpider}} #If {{Timer}} runs out, {{SpiderEgg}} breaks without leaving anything #Bosses, enemies with low health or spawned by other enemies don't drop anything", "Divine Cloth")
	EID:addCollectible(Isaac.GetItemIdByName("Arachna's Spool"), "Allows you to throw a spool projectile, that leaves web on the ground that puts {{Slow}} on nearby monsters #Enemies {{Slow}} by this item drop {{SpiderEgg}} on death #Upon clearing room/greed wave {{SpiderEgg}} breaks, leaving some {{BlueSpider}} #Bosses, enemies with low health or spawned by other enemies don't drop anything", "Arachna's Spool")
	EID:addCollectible(Isaac.GetItemIdByName("The Yarn"), "Familiar that follows you around, blocks shots and zaps nearby enemies with electricity. #Can give {{WebHeart}} every 4 rooms", "The Yarn")
	EID:addCollectible(Isaac.GetItemIdByName("Arachnid's Grip"), "Enemies can now drop spider egg pickups on death. #Picking them up would grant you a protective familiar that would drop {{BlueSpider}} on death", "Arachnid's Grip")
	EID:addCollectible(Isaac.GetItemIdByName("Yarn Heart"), "{{WebHeart}} Grants a Web Heart upon use", "Yarn Heart")
	EID:addCollectible(Isaac.GetItemIdByName("Mechanical Eye"), "You get an orbital that blocks shots and displays an active item #Item displayed on the orbital will be used when you use your active item #Active you're using and active gained from the eye have same amount of charges. #Item in the eye changes upon entering new unvisited room, clearing a greed wave or using your active", "Mechanical Eye")	
	EID:addCollectible(Isaac.GetItemIdByName("Geptameron"), "Gives flight for 1{{Room}} and applies effect based on value of on-screen indicator:"
	.. "#{{1}}: {{ArrowUp}}Stats, 2 {{AngelRoom}} wisps of {{Collectible".. CollectibleType.COLLECTIBLE_LEMEGETON .."}} for 1{{Room}}"
	.. "#{{2}}: Holy beams appear everywhere"
	.. "#{{3}}: Spawns holy beams on all monsters, shows map, opens doors"
	.. "#{{4}}: Get 2 {{AngelRoom}} babies for 1{{Room}}. Uses {{Card" .. 51 .. "}}"
	.. "#{{5}}: Marks 1 enemy. On death marked enemiy drops {{Coin}}s and marks someone else"
	.. "#{{6}}: Shoot holy lasers in 8 sides"
	.. "#{{7}}: Marks all enemies. On death marked enemy drop disappearing pickup", "Geptameron")
	EID:addCollectible(Isaac.GetItemIdByName("3D Glasses"), "You have a chance to shoot a special tear, that on contact with wnwmy would spawn 2 friendly copies of it. #Those copies can't take any damage, but they would die upon clearing the room", "3D Glasses")
	EID:addCollectible(Isaac.GetItemIdByName("Mutagen"), "{{ArrowUp}} DMG up #Chance to spawn several {{ColorRainbow}}special{{CR}} {{BlueSpider}} upon entering new room #Some items now have a chance to spawn {{ColorRainbow}}special{{CR}} {{BlueSpider}} instead of normal ones", "Mutagen")
	EID:addCollectible(Isaac.GetItemIdByName("Testament"), "#Allows you to take one of the items you have and make it appear on the start of the next run #If you somehow don't have any items, you'll receive {{Collectible".. CollectibleType.COLLECTIBLE_EDENS_BLESSING .."}}", "Testament")
	EID:addCollectible(Isaac.GetItemIdByName("Lil Arachna"), "Familiar. Shoots slowing splitting shots. #Can cover enemies in web with some chance. #Webbed enemies drop {{SpiderEgg}} with {{Timer}} on death", "Lil Arachna")
	EID:addCollectible(Isaac.GetItemIdByName("Dad's Newspaper"), "You get a newspaper roll in your hands that you can swing by double-clicking the fire button. #The hit deals massive damage and applies {{Confusion}} to enemies #If the enemy is an insect, newspaper swing kills it instantly", "Dad's Newspaper")
	EID:addCollectible(Isaac.GetItemIdByName("Best Bud Ball"), "Can be thrown to capture bosses #First use captures the boss, next use releases them", "Best Bud Ball")
	--trinkets
	EID:addTrinket(Isaac.GetTrinketIdByName("Sprindle"), "Enemies that damage you get covered in web #Webbed enemies drop {{SpiderEgg}} with {{Timer}} on death", "Sprindle")
	EID:addTrinket(Isaac.GetTrinketIdByName("White String"), "{{WebHeart}} Gain a Web Heart each new floor #{{WebHeart}} Chance for Web Hearts to appear is increased", "White String")
	EID:addTrinket(Isaac.GetTrinketIdByName("Infested Penny"), "{{BlueSpider}} Get a Blue Spider upon picking up a coin #{{WebHeart}} Chance to get a Web Heart upon picking up a coin", "Infested Penny")
	--consumables
	EID:addCard(Isaac.GetCardIdByName("Soul of Arachna"), "Applies {{Collectible".. Isaac.GetItemIdByName("Divine Cloth") .."}} effect to all enemies in the room", "Soul of Arachna")
	EID:addCard(Isaac.GetCardIdByName("Merged Card"), "Picks 2 effects:" 
	.. "#{{Card" .. 1 .. "}}: Uses {{Collectible".. CollectibleType.COLLECTIBLE_D7 .."}}"
	.. "#{{Card" .. 2 .. "}}: {{Slow}}all enemies"
	.. "#{{Card" .. 3 .. "}}: Spawns {{MomBossSmall}} on you"
	.. "#{{Card" .. 4 .. "}}: Uses {{Collectible".. CollectibleType.COLLECTIBLE_THE_NAIL .."}}"
	.. "#{{Card" .. 5 .. "}}: Reveals {{BossRoom}}"
	.. "#{{Card" .. 6 .. "}}: Spawns 2 {{HalfSoulHeart}}"
	.. "#{{Card" .. 7 .. "}}: Spawns 2 {{HalfHeart}}"
	.. "#{{Card" .. 8 .. "}}: Uses {{Collectible".. CollectibleType.COLLECTIBLE_UNICORN_STUMP .."}}"
	.. "#{{Card" .. 9 .. "}}: Spawns 2 pickups"
	.. "#{{Card" .. 10 .. "}}: Uses {{Collectible".. CollectibleType.COLLECTIBLE_KEEPERS_BOX .."}}"
	.. "#{{Card" .. 11 .. "}}: Uses {{Slotmachine}} 3 times"
	.. "#{{Card" .. 12 .. "}}: {{ArrowUp}}Stats for 1 {{Room}}"
	.. "#{{Card" .. 13 .. "}}: Removes{{GridRock}}, turns{{GridPit}}to{{GridBridge}}"
	.. "#{{Card" .. 14 .. "}}: 20{{DamageSmall}} to monsters"
	.. "#{{Card" .. 15 .. "}}: Spawns a {{DemonBeggar}}"
	.. "#{{Card" .. 16 .. "}}: {{ArrowUp}}DMG for 1 {{Room}}"
	.. "#{{Card" .. 17 .. "}}: Spawns 3 {{TrollBomb}}"
	.. "#{{Card" .. 18 .. "}}: Spawns {{GoldenChest}}"
	.. "#{{Card" .. 19 .. "}}: Reveals {{SecretRoom}}{{SuperSecretRoom}}{{UltraSecretRoom}}"
	.. "#{{Card" .. 20 .. "}}: Reveals {{TreasureRoom}}{{Planetarium}}, heals {{Heart}}, 5{{DamageSmall}} to monsters"
	.. "#{{Card" .. 21 .. "}}: Spawns {{ShopKeeper}}"
	.. "#{{Card" .. 22 .. "}}: Reveals {{TreasureRoom}}{{Planetarium}}", "Merged Card")
	
	--POLISH (done by wons)
	--birthrights
    EID:addBirthright(Isaac.GetPlayerTypeByName("Arachna", false), "{{Collectible".. Isaac.GetItemIdByName("Arachna's Spool") .."}} zostawia 2 kokony zamiast 1 #Każdy {{WebHeart}} gwarantuje +1 {{BlueSpider}} z każdego {{SpiderEgg}} #{{SpiderEgg}} zostawiają {{WebHeart}} po wykluciu", "Arachna", "pl")
    EID:addBirthright(Isaac.GetPlayerTypeByName("Arachna", true), "Przedłuża czas debuff'a przeciwników #Zwiększa zasięg {{Collectible".. Isaac.GetItemIdByName("Divine Cloth") .."}} #Przedłuża {{Timer}} pobliskich {{SpiderEgg}}", "Splugawiona Arachna", "pl")
    --items
	EID:addCollectible(Isaac.GetItemIdByName("Spider Cake"), "Spawnuje jednego {{WebHeart}} #{{ArrowUp}} Wszystkie statystyki w górę, ilość jest bazowana na latach od wydania moda #Zamienia się w {{Collectible".. CollectibleType.COLLECTIBLE_MYSTERY_GIFT .."}} po podniesieniu", "Pajęczy Tort")
    EID:addCollectible(Isaac.GetItemIdByName(" Spider Donut "), "+1 {{WebHeart}} #{{ArrowUp}} DMG up #Gwarantuje kilka {{BlueSpider}}", "Pajęczy donut")
    EID:addCollectible(Isaac.GetItemIdByName("Old Shoebox"), "Spawnuje jednego {{WebHeart}} #{{ArrowUp}} Tears i Speed up #Gwarantuje parę {{BlueSpider}}", "Stare pudełko po butach")
    EID:addCollectible(Isaac.GetItemIdByName("Gummy Spiders"), "+2 {{WebHeart}}#{{ArrowUp}} Tears up #Gwarantuje {{ColorRainbow}}specjalne{{CR}} {{BlueSpider}}", "Pajęczy żelek")
    EID:addCollectible(Isaac.GetItemIdByName("Candy Floss"), "Wyzerowywuje kontynery w zamian za parę{{WebHeart}}. Jeśli nie masz czerwonych serc, da ci 3 pajęcze serca #Twoje łzy mają szansę pokryć przeciwników pajęczyną", "Wata Cukrowa")
	
    EID:addCollectible(Isaac.GetItemIdByName("Divine Cloth"), "Nakłada {{Slow}} pobliskim przeciwnikom #Przeciwnicy z {{Slow}} w ten sposób item dropią {{SpiderEgg}} z {{Timer}} po śmierci #Po wyczyszczeniu pokoju/fali {{SpiderEgg}} wykluwa się i wyskakują {{BlueSpider}} #Jeśli {{Timer}} się wyzeruje, {{SpiderEgg}} pęka nic nie zostawiając #Bossowie, przeciwnicy z niskim zdrowiem, zespawnowani przez innych przeciwników nic nie pozostawiają", "Niebiańska tkanina", "pl")
    EID:addCollectible(Isaac.GetItemIdByName("Arachna's Spool"), "Pozwala ci rzucić szpulę, która zostawia pajęczynę która nakłada {{Slow}} na pobliskich przeciwników #Przeciwnicy z {{Slow}} w taki sposób zostawiają {{SpiderEgg}} po śmierci #Po wyczyszczeniu pokoju/fali {{SpiderEgg}} wykluwa się, zostawiając parę {{BlueSpider}} #Bossowie, przeciwnicy z niskim zdrowiem, zespawnowani przez innych przeciwników nic nie pozostawiają", "Szpula Arachny", "pl") 
	EID:addCollectible(Isaac.GetItemIdByName("The Yarn"), "Familiar który podąża za tobą, blokuje pociski i razi przeciwników prądem. #Może dać {{WebHeart}} co 4 pokoje", "Włóczka", "pl")
	EID:addCollectible(Isaac.GetItemIdByName("Arachnid's Grip"), "Przeciwnicy mogą zostawić pajęcze kokony po śmierci. #Podnoszenie tych kokonów, daje ci defensywnego familiara który zostawia {{BlueSpider}} po śmierci", "Chwyt pajęczaka", "pl")
	EID:addCollectible(Isaac.GetItemIdByName("Yarn Heart"), "Daje {{WebHeart}} po użyciu", "Włóczkowe serce", "pl")
	EID:addCollectible(Isaac.GetItemIdByName("Mechanical Eye"), "Otrzymujesz familiara który blokuje pociski i wyświetla item aktywny #Efekt tego itemu będzie użyty razem z twoim itemem aktywnym #Efekt itemu aktywnego z tego oka będzie miał tą samą ilość ładunków co twój przedmiot. #Item z oka się zmieni po odwiedzeniu nieodwiedzonego pokoju, wyczyszczeniu pokoju/fali lub po użyciu itemu aktywnego", "Mechanicznego oko", "pl")	
	EID:addCollectible(Isaac.GetItemIdByName("Geptameron"), "Daje ci latanie na 1{{Room}} i efekt bazujący na wskaźniku na ekranie:"
	.. "#{{1}}: {{ArrowUp}}Statystyki, 2 {{AngelRoom}} ogniki {{Collectible".. CollectibleType.COLLECTIBLE_LEMEGETON .."}} na 1{{Room}}"
	.. "#{{2}}: Anielskie promienie pojawiają się wszędzie"
	.. "#{{3}}: Anielskie promienie pojawiają się na wszystkich przeciwnikach, pokazuje mapę i otwiera drzwi"
	.. "#{{4}}: Otrzymujesz 2 dzieciaczki z {{AngelRoom}} na 1{{Room}}. Używa {{Card" .. 51 .. "}}"
	.. "#{{5}}: Oznacza 1 przeciwnika. Oznaczony przeciwnik dropi {{Coin}} i oznacza innego przeciwnika"
	.. "#{{6}}: Wystrzeliwuje promienie w 8 stron"
	.. "#{{7}}: Oznacza wszystkich przeciwników. Po śmierci oznaczony przeciwnik dropi znikającą znajdźkę", "Geptameron", "pl")
	EID:addCollectible(Isaac.GetItemIdByName("3D Glasses"), "Łza po kontakci z przeciwnikiem może pojawić 2 jego przyjazne kopie. #Te kopie nie otrzymują obrażeń, ale znikają po wyczyszczeniu pokoju", "Okulary 3D", "pl")
	EID:addCollectible(Isaac.GetItemIdByName("Mutagen"), "{{ArrowUp}} DMG w górę #Szansa na pojawienie {{ColorRainbow}} specjalne{{CR}} {{BlueSpider}} po wejściu do nowego pokoju #Niektóre itemy teraz mają szansę pojawić {{ColorRainbow}}specjalne{{CR}} {{BlueSpider}} zamiast zwyczajnych", "Mutagen", "pl")
	EID:addCollectible(Isaac.GetItemIdByName("Testament"), "#Pozwala ci wybrać jeden z twoich posiadanych itemów żeby się pojawił w następnym podejściu #Jeśli nie masz itemów, zamiast tego dostaniesz {{Collectible".. CollectibleType.COLLECTIBLE_EDENS_BLESSING .."}}", "Testament", "pl")
	EID:addCollectible(Isaac.GetItemIdByName("Lil Arachna"), "Familiar, który strzela spowalniającymi pociskami #Ma szansę pokryć przeciwnika pajęczyną. #Uwięzieni w pajęczynie przeciwnicy zostawiają {{SpiderEgg}} z {{Timer}} po śmierci", "Tyci Arachna", "pl")
	EID:addCollectible(Isaac.GetItemIdByName("Best Bud Ball"), "Można złapać w niej bossa #Po złapaniu, następnym użyciu wypuszcza bossa i item znika", "Kula Na Najlepszego Przyjaciela", "pl")
	--trinkets
	EID:addTrinket(Isaac.GetTrinketIdByName("Sprindle"), "Przeciwnicy którzy cię zranią zostaną pokryci siecią #Przeciwnicy pokryci siecią zostawiają {{SpiderEgg}} z {{Timer}} po śmierci", "Sprindle", "pl")
	EID:addTrinket(Isaac.GetTrinketIdByName("White String"), "Dostajesz {{WebHeart}} co piętro #{{WebHeart}} CSzansa na pojawienie się {{WebHeart}}", "Biała nić", "pl")
	EID:addTrinket(Isaac.GetTrinketIdByName("Infested Penny"), "Po podniesieniu monety możesz dostać {{BlueSpider}} #Lub możesz dostać{{WebHeart}}", "Zainfekowana moneta", "pl")
	--consumables
	EID:addCard(Isaac.GetCardIdByName("Soul of Arachna"), "Efekt {{Collectible".. Isaac.GetItemIdByName("Divine Cloth") .."}} na wszystkich przeciwników w pokoju", "Dusza Arachny", "pl")
	EID:addCard(Isaac.GetCardIdByName("Merged Card"), "Wybiera jeden z 2 poniżej podanych efektów:" 
	.. "#{{Card" .. 1 .. "}}: Efekt {{Collectible".. CollectibleType.COLLECTIBLE_D7 .."}}"
	.. "#{{Card" .. 2 .. "}}: {{Slow}} przeciwników"
	.. "#{{Card" .. 3 .. "}}: Spawnuje {{MomBossSmall}}"
	.. "#{{Card" .. 4 .. "}}: Efekt {{Collectible".. CollectibleType.COLLECTIBLE_THE_NAIL .."}}"
	.. "#{{Card" .. 5 .. "}}: Odkrywa {{BossRoom}}"
	.. "#{{Card" .. 6 .. "}}: Spawnuje 2 {{HalfSoulHeart}}"
	.. "#{{Card" .. 7 .. "}}: Spawnuje 2 {{HalfHeart}}"
	.. "#{{Card" .. 8 .. "}}: Efekt {{Collectible".. CollectibleType.COLLECTIBLE_UNICORN_STUMP .."}}"
	.. "#{{Card" .. 9 .. "}}: Spawnuje 2 znajdźki"
	.. "#{{Card" .. 10 .. "}}: Efekt {{Collectible".. CollectibleType.COLLECTIBLE_KEEPERS_BOX .."}}"
	.. "#{{Card" .. 11 .. "}}: Efekt {{Slotmachine}} 3 razy"
	.. "#{{Card" .. 12 .. "}}: {{ArrowUp}}Staty w góre na 1 {{Room}}"
	.. "#{{Card" .. 13 .. "}}: Usuwa{{GridRock}}, zamienia{{GridPit}}na{{GridBridge}}"
	.. "#{{Card" .. 14 .. "}}: 20{{DamageSmall}} potworm"
	.. "#{{Card" .. 15 .. "}}: Spawnuje {{DemonBeggar}}"
	.. "#{{Card" .. 16 .. "}}: {{ArrowUp}}DMG w górę na 1 {{Room}}"
	.. "#{{Card" .. 17 .. "}}: Spawnuje 3 {{TrollBomb}}"
	.. "#{{Card" .. 18 .. "}}: Spawnuje {{GoldenChest}}"
	.. "#{{Card" .. 19 .. "}}: Odkrywa {{SecretRoom}}{{SuperSecretRoom}}{{UltraSecretRoom}}"
	.. "#{{Card" .. 20 .. "}}: Odkrywa {{TreasureRoom}}{{Planetarium}}, heals {{Heart}}, 5{{DamageSmall}} potworom"
	.. "#{{Card" .. 21 .. "}}: Spawnuje {{ShopKeeper}}"
	.. "#{{Card" .. 22 .. "}}: Odkrywa {{TreasureRoom}}{{Planetarium}}", "Złaczona karta", "pl")
	
	--CHINESE (done by 汐何/Saurtya)
	--birthrights
	EID:addBirthright(Isaac.GetPlayerTypeByName("Arachna", false), "现在你的 {{Collectible".. Isaac.GetItemIdByName("Arachna's Spool") .."}} \"线轴\"能够在一个房间同时生成 2 个蜘蛛网 #你的每个 {{WebHeart}} 蜘蛛之心可以令每个 {{SpiderEgg}} 蜘蛛蛋生成的蓝蜘蛛 +1 #现在 {{SpiderEgg}} 蜘蛛蛋在破碎时有几率生成 {{WebHeart}} 蜘蛛之心", "Arachna","zh_cn")
	EID:addBirthright(Isaac.GetPlayerTypeByName("Arachna", true), "增加 {{Collectible".. Isaac.GetItemIdByName("Divine Cloth") .."}} \"非凡织布\"添加的减速debuff持续时间 #增加 {{Collectible".. Isaac.GetItemIdByName("Divine Cloth") .."}} \"非凡织布\"生效的半径 #使用 {{Collectible".. Isaac.GetItemIdByName("Divine Cloth") .."}} \"非凡织布\"时增加 {{SpiderEgg}} 蜘蛛蛋的持续时间", "Tainted Arachna","zh_cn")
	--items
	EID:addCollectible(Isaac.GetItemIdByName("Divine Cloth"), "使用后使周围的敌人添加一层减速buff #若敌人持有该减速buff死亡，则生成一个【有持续时间限制】的 {{SpiderEgg}} 蜘蛛蛋 #若在房间清理完之前 {{Timer}} 持续时间尚未结束，则 {{SpiderEgg}} 蜘蛛蛋破碎并生成 2-4 个蓝蜘蛛 #如果 {{Timer}} 持续时间已经结束，那么 {{SpiderEgg}} 蜘蛛蛋则会直接腐败并消失 #{{Warning}} Boss、低血量的敌人或由其他敌人衍生出的敌人不会掉落任何东西", "非凡织布","zh_cn")
	EID:addCollectible(Isaac.GetItemIdByName("Arachna's Spool"), "使用后扔出一个线轴，丢中敌人后生成一片蛛网，敌人在上面行走时减速 #若敌人在上面死亡，则生成一个 {{SpiderEgg}} 蜘蛛蛋 #房间清理完后蜘蛛蛋将会裂开并生成 2-4 只蓝蜘蛛 #{{Warning}} Boss、低血量的敌人或由其他敌人衍生出的敌人不会掉落任何东西", "Arachna的线轴","zh_cn")
	EID:addCollectible(Isaac.GetItemIdByName("The Yarn"), "生成一个纺纱球跟班，可阻挡弹幕，并电击靠近的敌人 #每 4 个房间生成一个 {{WebHeart}} 蜘蛛之心", "纺纱球","zh_cn")
	EID:addCollectible(Isaac.GetItemIdByName("Arachnid's Grip"), "杀死敌人后有几率掉落小蜘蛛蛋 #拾取后生成一个一次性的环绕物，被敌方弹幕击中后消失并生成蓝蜘蛛 #若房间清理结束后小蜘蛛蛋未被拾取，小蜘蛛蛋会破裂消失，不会生成蓝蜘蛛", "蜘蛛之爪","zh_cn")
	EID:addCollectible(Isaac.GetItemIdByName("Yarn Heart"), "{{WebHeart}} 使用后获得一个蜘蛛心", "纺织心","zh_cn")
	EID:addCollectible(Isaac.GetItemIdByName("Mechanical Eye"), "生成一个义眼跟班，可阻挡弹幕 #持有主动道具时将会投射另一个主动道具的全息投影，使用当前的主动道具的同时也会触发全息投影道具的效果 #若不使用道具，则每清理完一个房间更换一次投影 #若使用，则义眼暂时失去投影功能，需要清理房间充能，充能数与当前使用的主动道具充能相同", "义眼","zh_cn")	
	EID:addCollectible(Isaac.GetItemIdByName("Geptameron"), "使用后在本房间内获得飞行能力（基础效果），并在左上角生成一个指示器，每清理一个房间指示器数字+1，使用该道具时根据每个数字附加对应的额外效果，按TAB键时指示器会显示效果提示字（一周内的天数）："
	.. "#{{1}}: {{ArrowUp}} 全属性上升, 生成 2 个{{Collectible712}} 随机被动道具火焰跟班（所罗门魔典），持续 1 房间"
	.. "#{{2}}: 房间内随机生成光柱对敌人进行攻击，地上提前有黄色标识(光柱不对角色造成伤害)"
	.. "#{{3}}: 房间内所有敌人头上落下光柱，并揭露本层地图，包括红隐藏房间的位置，并打开所有门"
	.. "#{{4}}: 生成 2 个 {{AngelRoom}} 天使类型的宝宝跟班，持续 1 房间，并使用{{Card" .. 51 .. "}}神圣卡（获得一层神圣斗篷效果）"
	.. "#{{5}}: 随机给房间内的某个敌人标记{{Coin}}金钱标记，敌人死亡后掉落【2s后会消失的钱币】（类似里店长）"
	.. "#{{6}}: 发射一次八向光柱"
	.. "#{{7}}: 标记所有敌人，有标记的敌人死亡后会掉落【2s后会消失的随机掉落物】", "《魔法大全》","zh_cn")
	EID:addCollectible(Isaac.GetItemIdByName("3D Glasses"), "概率射出特殊眼泪，击中敌人后将会生成一红一蓝两个友好的敌方复制品帮助战斗 #复制品不会受伤，但房间清理完后消失", "3D眼镜","zh_cn")
	EID:addCollectible(Isaac.GetItemIdByName("Mutagen"), "{{ArrowUp}} 攻击力上升 #角色进入房间时有概率生成数只 {{ColorRainbow}}变种{{CR}}蓝蜘蛛 #原本生成蓝蜘蛛的道具也有概率生成 {{ColorRainbow}}变种{{CR}}蓝蜘蛛", "诱变剂","zh_cn")
	EID:addCollectible(Isaac.GetItemIdByName("Testament"), "{{Warning}} 一次性使用 #使用后将角色传送到一个房间，该房间有角色目前身上已有的道具，选择一个后将角色传送回原地，身上的道具不会消失，但下局游戏开始时在初始房间生成该道具 #如果你身上没有任何道具，那么你将收到 {{Collectible381}} 伊甸的祝福", "圣约之书","zh_cn")
	EID:addCollectible(Isaac.GetItemIdByName("Lil Arachna"), "生成一个发射减速眼泪的宝宝跟班 #击杀敌人时有概率使其生成【有时间限制】的 {{SpiderEgg}} 蜘蛛蛋", "Arachna宝宝","zh_cn")
	EID:addCollectible(Isaac.GetItemIdByName("Dad's Newspaper"), "获得后角色手上将会有报纸卷，双击攻击键可挥动 #击中敌人造成大量伤害且使敌人晕眩 #击中昆虫类敌人则直接秒杀", "爸爸的报纸","zh_cn")
	EID:addCollectible(Isaac.GetItemIdByName("Best Bud Ball"), "{{Warning}} 一次性使用 #能够捕捉Boss成为友方怪物，只能捕捉一只 #第一次使用时扔出进行捕捉，第二次使用后放出Boss #捕捉最终Boss时可以直接通关", "大师球","zh_cn")
	--trinkets
	EID:addTrinket(Isaac.GetTrinketIdByName("Sprindle"), "拥有该饰品时受到敌人伤害会使敌人被网缠住 #被网缠住的敌人在死亡后将会留下一个【有时间限制】的 {{SpiderEgg}} 蜘蛛蛋", "纺锤","zh_cn")
	EID:addTrinket(Isaac.GetTrinketIdByName("White String"), "{{WebHeart}} 拥有该饰品时每层获得一个蜘蛛之心 #{{WebHeart}} 提升生成蜘蛛之心的概率", "白线","zh_cn")
	EID:addTrinket(Isaac.GetTrinketIdByName("Infested Penny"), "{{BlueSpider}} 拾取硬币时生成一个蓝蜘蛛 #{{WebHeart}} 拾取硬币时概率生成一个蜘蛛之心", "蜘蛛网硬币","zh_cn")
	--consumables
	EID:addCard(Isaac.GetCardIdByName("Soul of Arachna"), "使用后使房间内的所有敌人都增添上 {{Collectible".. Isaac.GetItemIdByName("Divine Cloth") .."}} \"非凡织布\"的效果", "Arachna的魂石","zh_cn")
	EID:addCard(Isaac.GetCardIdByName("Merged Card"), "随机挑选两张塔罗牌卡牌的效果触发，卡牌的效果经过了修改：" 
	.. "#{{Card" .. 1 .. "}}: 效果为 {{Collectible437}} D7"
	.. "#{{Card" .. 2 .. "}}: {{Slow}} 减速房间内所有敌人"
	.. "#{{Card" .. 3 .. "}}: 召唤 {{MomBossSmall}} 妈腿践踏角色"
	.. "#{{Card" .. 4 .. "}}: 效果为 {{Collectible83}} 钉子"
	.. "#{{Card" .. 5 .. "}}: 揭露 {{BossRoom}} Boss房所在位置"
	.. "#{{Card" .. 6 .. "}}: 生成 2 个 {{HalfSoulHeart}} 半颗魂心"
	.. "#{{Card" .. 7 .. "}}: 生成 2 个 {{HalfHeart}} 半颗红心"
	.. "#{{Card" .. 8 .. "}}: 效果为 {{Collectible298}} 独角兽的残角"
	.. "#{{Card" .. 9 .. "}}: 生成 2 个掉落物"
	.. "#{{Card" .. 10 .. "}}: 效果为 {{Collectible719}} 店长的盒子"
	.. "#{{Card" .. 11 .. "}}: 触发 3 次 {{Slotmachine}} 赌博机效果"
	.. "#{{Card" .. 12 .. "}}: {{ArrowUp}} 全属性上升，不包括血量，效果持续 1 个房间"
	.. "#{{Card" .. 13 .. "}}: 移除房间内所有可破坏石块，将所有坑填平"
	.. "#{{Card" .. 14 .. "}}: 对所有敌人造成 20 点伤害"
	.. "#{{Card" .. 15 .. "}}: 召唤一个 {{DemonBeggar}} 恶魔乞丐"
	.. "#{{Card" .. 16 .. "}}: {{ArrowUp}} 攻击力 +1 ，效果持续 1 个房间"
	.. "#{{Card" .. 17 .. "}}: 生成 3 个 {{TrollBomb}} 即爆炸弹"
	.. "#{{Card" .. 18 .. "}}: 生成 {{GoldenChest}} 金箱子"
	.. "#{{Card" .. 19 .. "}}: 揭示所有隐藏房的位置（包括红隐藏）"
	.. "#{{Card" .. 20 .. "}}: 揭示 {{TreasureRoom}} 道具房与 {{Planetarium}} 星象房的位置，治疗 {{HalfHeart}} 半颗红心，对所有敌人造成 5 伤害"
	.. "#{{Card" .. 21 .. "}}: 生成一个 {{ShopKeeper}} 店长"
	.. "#{{Card" .. 22 .. "}}: 揭示 {{TreasureRoom}} 道具房与 {{Planetarium}} 星象房的位置", "融合卡","zh_cn")
	
	--RUSSIAN (done by me, additional help from Ink sans Bad time)
	--birthrights
	EID:addBirthright(Isaac.GetPlayerTypeByName("Arachna", false), "Ваша {{Collectible".. Isaac.GetItemIdByName("Arachna's Spool") .."}} теперь оставляет 2 паутины вместо 1 #Теперь {{WebHeart}} гарантирует +1 {{BlueSpider}} за каждого {{SpiderEgg}} #Теперь {{SpiderEgg}} могут оставить {{WebHeart}} при вылуплении", "Арахна", "ru")
	EID:addBirthright(Isaac.GetPlayerTypeByName("Arachna", true), "Увеличивает продолжительность эффекта {{Collectible".. Isaac.GetItemIdByName("Divine Cloth") .."}} #Увеличивает радиус действия {{Collectible".. Isaac.GetItemIdByName("Divine Cloth") .."}} #Использование {{Collectible".. Isaac.GetItemIdByName("Divine Cloth") .."}} откатывает {{Timer}} ближайших {{SpiderEgg}}", "Порченная Арахна", "ru")
	--items
	EID:addCollectible(Isaac.GetItemIdByName("Spider Cake"), "{{WebHeart}} Спавнит 1 Паутиновое Сердце #{{ArrowUp}} +Ко всем статам, чем больше лет прошло с релиза мода, тем выше #{{Collectible".. CollectibleType.COLLECTIBLE_MYSTERY_GIFT .."}} При подборе превращается в Загадочный Подарок", "Торт из Пауков", "ru")
	EID:addCollectible(Isaac.GetItemIdByName(" Spider Donut "), "{{WebHeart}} +1 Паутиновое Сердце #{{ArrowUp}} +Урон #{{BlueSpider}} Дает несколько Больших Синих Пауков", "Паучий Пончик", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Old Shoebox"), "{{WebHeart}} Спавнит 1 Паутиновое Сердце #{{ArrowUp}} +Скорость и Скорострельность #{{BlueSpider}} Дает несколько Синих Пауков", "Старая Коробка от Обуви", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Gummy Spiders"), "{{WebHeart}} +2 Паутиновое Сердце #{{ArrowUp}} +Скорострельность #{{BlueSpider}} Дает несколько {{ColorRainbow}}особых{{CR}} Дружелюбных Пауков", "Желейные Паучки", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Candy Floss"), "{{WebHeart}} Забирает все красные сердца и вместо них спавнит Паутиновые. Если жизней нет, спавнит 3 Паутиновых Сердца #С некоторым шансом ваша слеза может покрыть врагов паутиной", "Сладкая Вата", "ru")
	
	EID:addCollectible(Isaac.GetItemIdByName("Divine Cloth"), "Замедляет ближайших врагов #Замедленные враги дропают {{SpiderEgg}} с {{Timer}} при смерти #После зачистки комнаты/волны в гриде, из {{SpiderEgg}} вылупляются несколько {{BlueSpider}} #Если {{Timer}} закончился, {{SpiderEgg}} просто ломается #Боссы, а также враги с малым ХП или призванные другими монстрами ничего не оставляют", "Божественная Ткань", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Arachna's Spool"), "Позволяет бросить катушку, которая создает на земле паутину, замедляющую врагов #Замедленные враги дропают {{SpiderEgg}} при смерти #После зачистки комнаты/волны в гриде, из {{SpiderEgg}} вылупляются несколько {{BlueSpider}} #Боссы, а также враги с малым ХП или призванные другими монстрами ничего не оставляют", "Катушка Арахны", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("The Yarn"), "Фамильяр который следует за вами, блокирует выстрелы и стреляет в ближайших врагов. #Может дать {{WebHeart}} каждые 4 комнаты", "Клубок", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Arachnid's Grip"), "Enemies can now drop spider egg pickups on death. #Picking them up would grant you a protective familiar that would drop {{BlueSpider}} on death", "Паучья Хватка", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Yarn Heart"), "{{WebHeart}} Дает Паутиновое Сердце при использовании", "Шерстяное сердце", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Mechanical Eye"), "Орбитал, блокирующий выстрелы, который показывает активку #Предмет в глазу используется вместе с вашей основной активкой #У активки в глазу и вашей активки равное кол-во зарядов #Предмет меняется при входе в новую комнату, зачистки волны в гриде или использовании активки", "Механический Глаз", "ru")	
	EID:addCollectible(Isaac.GetItemIdByName("Geptameron"), "Дает полет на 1{{Room}} и дает эффект на основе значение индикатора на экране:"
	.. "#{{1}}: Статы{{ArrowUp}}, 2 {{AngelRoom}} виспа {{Collectible".. CollectibleType.COLLECTIBLE_LEMEGETON .."}} на 1{{Room}}"
	.. "#{{2}}: Вокруг появляются святые лучи"
	.. "#{{3}}: Спавнит святые лучи на врагах, покажет карту, откроет двери"
	.. "#{{4}}: Дает 2 {{AngelRoom}} малыша на 1{{Room}}. Юзает {{Card" .. 51 .. "}}"
	.. "#{{5}}: Метит 1 врага. При смерти он дропает {{Coin}}ы и передает метку"
	.. "#{{6}}: Выстрел святыми лазерами в 8 сторон"
	.. "#{{7}}: Метит всех врагов. При смерти они дропают пропадающий пикап", "Гептамерон", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("3D Glasses"), "Шанс выстрелить особой слезой которая при контакте с врагом спавнит 2 его дружественные копии. #Они не получают урон, но умрут при зачистке комнаты", "3D Очки", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Mutagen"), "{{ArrowUp}} +Урон #Шанс создать несколько {{ColorRainbow}}особых{{CR}} {{BlueSpider}} при входе в новую комнату #Некоторые предметы могут создать {{ColorRainbow}}особых{{CR}} {{BlueSpider}} вместо обычных", "Мутаген", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Testament"), "#Позволяет выбрать один предмет из вашего инвентаря. С этим предметом вы начнете следующий забег #Если предметов почему-то нет, вы получите {{Collectible".. CollectibleType.COLLECTIBLE_EDENS_BLESSING .."}}", "Завещание", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Lil Arachna"), "Фамильяр. Стреляет замедляющими распадающимися выстрелами. #Выстрел может покрыть врагов паутиной. #Враги в паутине дропают {{SpiderEgg}} с {{Timer}} при смерти", "Маленькая Арахна", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Dad's Newspaper"), "Вы получаете сверток газеты, которым можно нанести удар чере дабл-клик кнопки атаки. #Удар наносит много урона и дает {{Confusion}} врагам #Если враг насекомое, то он мгновенно умирает", "Папина Газета", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Best Bud Ball"), "Можно кинуть чтобы поймать босса #Второе использование выпусает его дружелюбную версию", "Мячик Лучшего Друга", "ru")
	--trinkets
	EID:addTrinket(Isaac.GetTrinketIdByName("Sprindle"), "Враги нанесшие вам урон покрываются паутиной #Враги в паутине дропают {{SpiderEgg}} с {{Timer}} при смерти", "Веретено", "ru")
	EID:addTrinket(Isaac.GetTrinketIdByName("White String"), "{{WebHeart}} Дает Паутиновое Сердце каждый новый этаж #{{WebHeart}} Шанс выпадения Паутиновых Сердец увеличен", "Белая Нить", "ru")
	EID:addTrinket(Isaac.GetTrinketIdByName("Infested Penny"), "{{BlueSpider}} Дает Синего Паука при подборе монет #{{WebHeart}} Шанс получить Паутиновое Сердце при подборе монеты", "Зараженный Пенни", "ru")
	--consumables
	EID:addCard(Isaac.GetCardIdByName("Soul of Arachna"), "Накладывает эффект {{Collectible".. Isaac.GetItemIdByName("Divine Cloth") .."}} на всех врагов в комнате", "Душа Арахны", "ru")
	EID:addCard(Isaac.GetCardIdByName("Merged Card"), "Берет 2 эффекта:" 
	.. "#{{Card" .. 1 .. "}}: Юзает {{Collectible".. CollectibleType.COLLECTIBLE_D7 .."}}"
	.. "#{{Card" .. 2 .. "}}: {{Slow}}всех врагов"
	.. "#{{Card" .. 3 .. "}}: Создаст {{MomBossSmall}} на вас"
	.. "#{{Card" .. 4 .. "}}: Юзает {{Collectible".. CollectibleType.COLLECTIBLE_THE_NAIL .."}}"
	.. "#{{Card" .. 5 .. "}}: Покажет {{BossRoom}}"
	.. "#{{Card" .. 6 .. "}}: Создаст 2 {{HalfSoulHeart}}"
	.. "#{{Card" .. 7 .. "}}: Создаст 2 {{HalfHeart}}"
	.. "#{{Card" .. 8 .. "}}: Юзает {{Collectible".. CollectibleType.COLLECTIBLE_UNICORN_STUMP .."}}"
	.. "#{{Card" .. 9 .. "}}: Создаст 2 пикапа"
	.. "#{{Card" .. 10 .. "}}: Юзает {{Collectible".. CollectibleType.COLLECTIBLE_KEEPERS_BOX .."}}"
	.. "#{{Card" .. 11 .. "}}: Юзает {{Slotmachine}} 3 раза"
	.. "#{{Card" .. 12 .. "}}: Статы{{ArrowUp}} на 1 {{Room}}"
	.. "#{{Card" .. 13 .. "}}: Удалит{{GridRock}}, смена{{GridPit}}на{{GridBridge}}"
	.. "#{{Card" .. 14 .. "}}: 20{{DamageSmall}} врагам"
	.. "#{{Card" .. 15 .. "}}: Создаст {{DemonBeggar}}"
	.. "#{{Card" .. 16 .. "}}: Урон{{ArrowUp}} на 1 {{Room}}"
	.. "#{{Card" .. 17 .. "}}: Создаст 3 {{TrollBomb}}"
	.. "#{{Card" .. 18 .. "}}: Создаст {{GoldenChest}}"
	.. "#{{Card" .. 19 .. "}}: Покажет {{SecretRoom}}{{SuperSecretRoom}}{{UltraSecretRoom}}"
	.. "#{{Card" .. 20 .. "}}: Покажет {{TreasureRoom}}{{Planetarium}}, вылечит {{Heart}}, 5{{DamageSmall}} врагам"
	.. "#{{Card" .. 21 .. "}}: Создаст {{ShopKeeper}}"
	.. "#{{Card" .. 22 .. "}}: Покажет {{TreasureRoom}}{{Planetarium}}", "Сшитая Карта", "ru")
end