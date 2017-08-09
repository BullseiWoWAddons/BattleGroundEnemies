local addonName, Data = ...
Data.CyrillicToRomanian = { -- source Wikipedia: https://en.wikipedia.org/wiki/Romanization_of_Russian
	["а"] = "a",
	["Б"] = "b",
	["б"] = "b",
	["В"] = "v",
	["в"] = "v",
	["Г"] = "g",
	["г"] = "g",
	["Д"] = "d",
	["д"] = "d",
	["Е"] = "e",
	["е"] = "e",
	["Ё"] = "e",
	["ё"] = "e",
	["Ж"] = "zh",
	["ж"] = "zh",
	["З"] = "z",
	["з"] = "z",
	["И"] = "i",
	["и"] = "i",
	["Й"] = "i",
	["й"] = "i",
	["К"] = "k",
	["к"] = "k",
	["Л"] = "l",
	["л"] = "l",
	["М"] = "m",
	["м"] = "m",
	["Н"] = "n",
	["н"] = "n",
	["О"] = "o",
	["о"] = "o",
	["П"] = "p",
	["п"] = "p",
	["Р"] = "r",
	["р"] = "r",
	["С"] = "s",
	["с"] = "s",
	["Т"] = "t",
	["т"] = "t",
	["У"] = "u",
	["у"] = "u",
	["Ф"] = "f",
	["ф"] = "f",
	["Х"] = "kh",
	["х"] = "kh",
	["Ц"] = "ts",
	["ц"] = "ts",
	["Ч"] = "ch",
	["ч"] = "ch",
	["Ш"] = "sh",
	["ш"] = "sh",
	["Щ"] = "shch",
	["щ"] = "shch",
	["Ъ"] = "ie",
	["ъ"] = "ie",
	["Ы"] = "y",
	["ы"] = "y",
	["Ь"] = "",
	["ь"] = "",
	["Э"] = "e",
	["э"] = "e",
	["Ю"] = "iu",
	["ю"] = "iu",
	["Я"] = "ia",
	["я"] = "ia"   
}





-- BattleGroundEnemies.Interruptdurations = {
    -- [6552] = 4,   -- [Warrior] Pummel
    -- [96231] = 4,  -- [Paladin] Rebuke
    -- [231665] = 3, -- [Paladin] Avengers Shield
    -- [147362] = 3, -- [Hunter] Countershot
    -- [187707] = 3, -- [Hunter] Muzzle
    -- [1766] = 5,   -- [Rogue] Kick
    -- [183752] = 3, -- [DH] Consume Magic
    -- [47528] = 3,  -- [DK] Mind Freeze
    -- [91802] = 2,  -- [DK] Shambling Rush
    -- [57994] = 3,  -- [Shaman] Wind Shear
    -- [115781] = 6, -- [Warlock] Optical Blast
    -- [19647] = 6,  -- [Warlock] Spell Lock
    -- [212619] = 6, -- [Warlock] Call Felhunter
    -- [132409] = 6, -- [Warlock] Spell Lock
    -- [171138] = 6, -- [Warlock] Shadow Lock
    -- [2139] = 6,   -- [Mage] Counterspell
    -- [116705] = 4, -- [Monk] Spear Hand Strike
    -- [106839] = 4, -- [Feral] Skull Bash
	-- [93985] = 4,  -- [Feral] Skull Bash
-- }
		
Data.cCduration = {	-- this is basically data from DRData-1 with durations
	--[[ INCAPACITATES ]]--
	incapacitate = {
		-- Druid
		[    99] = 3, -- Incapacitating Roar (talent)
		[236025] = 6, -- Main (Honor talent)
		[236026] = 6, -- Main (Honor talent)
		-- Hunter
		[213691] = 4, -- Scatter Shot
		-- Mage
		[   118] = 8, -- Polymorph
		[ 28272] = 8, -- Polymorph (pig)
		[ 28271] = 8, -- Polymorph (turtle)
		[ 61305] = 8, -- Polymorph (black cat)
		[ 61721] = 8, -- Polymorph (rabbit)
		[ 61780] = 8, -- Polymorph (turkey)
		[126819] = 8, -- Polymorph (procupine)
		[161353] = 8, -- Polymorph (bear cub)
		[161354] = 8, -- Polymorph (monkey)
		[161355] = 8, -- Polymorph (penguin)
		[161372] = 8, -- Polymorph (peacock)
		[ 82691] = 8, -- Ring of Frost
		-- Monk
		[115078] = 4, -- Paralysis
		-- Paladin
		[ 20066] = 8, -- Repentance
		-- Priest
		[ 64044] = 4, -- Psychic Horror (Horror effect)
		-- Rogue
		[  1776] = 4, -- Gouge
		[  6770] = 8, -- Sap
		-- Shaman
		[ 51514] = 8, -- Hex
		[211004] = 8, -- Hex (spider)
		[210873] = 8, -- Hex (raptor)
		[211015] = 8, -- Hex (cockroach)
		[211010] = 8, -- Hex (snake)
		-- Warlock
		[  6789] = 3, -- Mortal Coil
		-- Pandaren
		[107079] = 4 -- Quaking Palm
	},

	--[[ SILENCES ]]--
	silence = {
		-- Death Knight
		[ 47476] = 5, -- Strangulate
		-- Hunter
		[202933] = 4, -- Spider Sting (pvp talent)
		-- Mage
		-- Paladin
		[ 31935] = 3, -- Avenger's Shield
		-- Priest
		[ 15487] = 5, -- Silence
		-- Rogue
		[  1330] = 3, -- Garrote
		-- Blood Elf
		[ 25046] = 2, -- Arcane Torrent (Energy version)
		[ 28730] = 2, -- Arcane Torrent (Priest/Mage/Lock version)
		[ 50613] = 2, -- Arcane Torrent (Runic power version)
		[ 69179] = 2, -- Arcane Torrent (Rage version)
		[ 80483] = 2, -- Arcane Torrent (Focus version)
		[129597] = 2, -- Arcane Torrent (Monk version)
		[155145] = 2, -- Arcane Torrent (Paladin version)
		[202719] = 2  -- Arcane Torrent (DH version)
	},

	--[[ DISORIENTS ]]--
	disorient = {
		-- Druid
		[ 33786] = 6, -- Cyclone
		[209753] = 6, -- Cyclone (Balance)
		-- Hunter
		[186387] = 4, -- Bursting Shot
		-- Mage
		[ 31661] = 3, -- Dragon's Breath
		-- Paladin
		[105421] = 6, -- Blinding Light -- FIXME: is this the right category? Its missing from blizzard's list
		-- Priest
		[  8122] = 6, -- Psychic Scream
		-- Rogue
		[  2094] = 8, -- Blind
		-- Warlock
		[  5782] = 6, -- Fear -- probably unused
		[118699] = 6, -- Fear -- new debuff ID since MoP
		-- Warrior
		[  5246] = 5 -- Intimidating Shout (main target)
	},

	--[[ STUNS ]]--
	stun = {
		-- Death Knight
		[108194] = 5, -- Asphyxiate (talent for unholy)
		[221562] = 5, -- Asphyxiate (baseline for blood)
		[207171] = 4, -- Winter is Coming (Remorseless winter stun)
		-- Demon Hunter
		[179057] = 5, -- Chaos Nova
		[200166] = 3, -- Metamorphosis
		[205630] = 6, -- Illidan's Grasp, primary effect
		[211881] = 2, -- Fel Eruption
		-- Druid
		[  5211] = 5, -- Mighty Bash
		[163505] = 4, -- Rake (Stun from Prowl)
		-- Monk
		[120086] = 4, -- Fists of Fury (with Heavy-Handed Strikes, pvp talent)
		[232055] = 3, -- Fists of Fury (new ID in 7.1)
		[119381] = 5, -- Leg Sweep
		-- Paladin
		[   853] = 6, -- Hammer of Justice
		-- Priest
		[200200] = 5, -- Holy word: Chastise
		[226943] = 2, -- Mind Bomb
		-- Rogue
		[  1833] = 4, -- Cheap Shot
	--	[   408] = true, -- Kidney Shot, variable duration
	  --[199804] = true, -- Between the Eyes, variable duration
		-- Shaman
		[118345] = 4, -- Pulverize (Primal Earth Elemental)
		[118905] = 5, -- Static Charge (Capacitor Totem)
		[204399] = 2, -- Earthfury (pvp talent)
		-- Warlock
		[ 89766] = 4, -- Axe Toss (Felguard)
		[ 30283] = 4, -- Shadowfury
		-- Warrior
		[132168] = 3, -- Shockwave
		[132169] = 4, -- Storm Bolt
		-- Tauren
		[ 20549] = 2 -- War Stomp
	},

	--[[ ROOTS ]]--
	root = {
		-- Death Knight
		[ 96294] = 4, -- Chains of Ice (Chilblains Root)
		[204085] = 4, -- Deathchill (pvp talent)
		-- Druid
		[   339] = 8, -- Entangling Roots
		[102359] = 8, -- Mass Entanglement (talent)
		[ 45334] = 4, -- Immobilized (wild charge, bear form)
		-- Hunter
		[200108] = 3, -- Ranger's Net
		[212638] = 6, -- tracker's net
		[201158] = 4, -- Super Sticky Tar (Expert Trapper, Hunter talent, Tar Trap effect)
		-- Mage
		[   122] = 8, -- Frost Nova
		[ 33395] = 8, -- Freeze (Water Elemental)
		[228600] = 4, -- Glacial spike (talent)
		-- Shaman
		[ 64695] = 8 -- Earthgrab Totem
	}
}		
		

Data.BattlegroundspezificBuffs = { --key = mapID, value = table with key = faction(0 for hode, 1 for alliance) value spellID of the flag, minecart
	[443] = {						-- Warsong Gulch
		[0] = 156621, 					-- Alliance Flag
		[1] = 156618 					-- Horde Flag	
	}, 
	[482] = {						-- Eye of the Storm
		[0] = 34976,  					-- Netherstorm Flag
		[1] = 34976						-- Netherstorm Flag
	},	
	[813] = {						-- Eye of the Storm (mapID RBG only? Not sure why there are two map IDs for Eye of the Storm)
		[0] = 34976,  					-- Netherstorm Flag
		[1] = 34976						-- Netherstorm Flag
	},
	[626] = {						-- Twin Peaks
		[0] = 156621, 					-- Alliance Flag
		[1] = 156618 					-- Horde Flag
	}, 
	[935] = {						-- Deepwind Gorge
		[0] = 140876,					-- Alliance Mine Cart
		[1] = 141210					-- Horde Mine Cart
	}
}

local SpellidToSpellname = {
	[156618] = (GetSpellInfo(156618)), 			-- Horde Flag
	[156621] = (GetSpellInfo(156621)), 			-- Alliance Flag
	[34976]  = (GetSpellInfo(34976)), 			-- Netherstorm Flag
	[141210] = (GetSpellInfo(141210)), 			-- Horde Mine Cart
	[140876] = (GetSpellInfo(140876)), 			-- Alliance Mine Cart
	[46392]  = (GetSpellInfo(46392)), 			-- Focused Assault
	[46393]  = (GetSpellInfo(46393)), 			-- Brutal Assault
	[121164] = (GetSpellInfo(121164)), 			-- Orb of Power, Blue
	[121175] = (GetSpellInfo(121175)), 			-- Orb of Power, Purple
	[121177] = (GetSpellInfo(121177)), 			-- Orb of Power, Orange
	[121176] = (GetSpellInfo(121176)) 			-- Orb of Power, Green
}
		
Data.BattlegroundspezificDebuffs = { --key = mapID, value = table with key = number and value = debuff name
	[443] = {						-- Warsong Gulch
		SpellidToSpellname[46392],		-- Focused Assault
		SpellidToSpellname[46393]		-- Brutal Assault								
	},
	[482] = {						-- Eye of the Storm
		SpellidToSpellname[46392],		-- Focused Assault
		SpellidToSpellname[46393]		-- Brutal Assault							
	},
	[813] = {						-- Eye of the Storm (mapID RBG only? Not sure why there are two map IDs for Eye of the Storm)
		SpellidToSpellname[46392],		-- Focused Assault
		SpellidToSpellname[46393]		-- Brutal Assault							
	},
	[626] = {						-- Twin Peaks
		SpellidToSpellname[46392],		-- Focused Assault
		SpellidToSpellname[46393]		-- Brutal Assault					
	}, 
	[935] = {						-- Deepwind Gorge
		SpellidToSpellname[46392],		-- Focused Assault
		SpellidToSpellname[46393]		-- Brutal Assault					
	},	
	[856] = {						-- Temple of Kotmogu
		SpellidToSpellname[121164], 	-- Orb of Power, Blue
		SpellidToSpellname[121175], 	-- Orb of Power, Purple
		SpellidToSpellname[121177], 	-- Orb of Power, Orange
		SpellidToSpellname[121176] 		-- Orb of Power, Green
	} 
}
		
		

Data.TriggerSpellIDToTrinketnumber = {--key = which first row honor talent, value = fileID(used for SetTexture())
	[195710] = 1, 	-- 1: Honorable Medallion, 3. min. CD, detected by Combatlog
	[208683] = 2, 	-- 2: Gladiator's Medallion, 2 min. CD, detected by Combatlog
	[195901] = 3, 	-- 3: Adaptation, 1 min. CD, detected by Aura 195901
	[214027] = 3, 	-- 3: Adaptation, 1 min. CD, detected by Aura 195901, for the Arena_cooldownupdate
	[196029] = 4 	-- 4: Relentless, passive, no CD
}
		
	
local TrinketTriggerSpellIDtoDisplayspellID = {
	[195901] = 214027 --Adapted, should display as Adaptation
}

Data.RacialSpellIDtoCooldown = {
	 [7744] = 120,	--Will of the Forsaken, Undead Racial, 30 sec cooldown trigger on trinket
	[20594] = 120,	--Stoneform, Dwarf Racial
	[58984] = 120,	--Shadowmeld, Night Elf Racial
	[59752] = 120,  --Every Man for Himself, Human Racial, 30 sec cooldown trigger on trinket
	[28730] = 90,	--Arcane Torrent, Blood Elf Racial, Mage and Warlock, 
	[50613] = 90,	--Arcane Torrent, Blood Elf Racial, Death Knight, 
   [202719] = 90,	--Arcane Torrent, Blood Elf Racial, Demon Hunter, 
	[80483] = 90,	--Arcane Torrent, Blood Elf Racial, Hunter,
   [129597] = 90,	--Arcane Torrent, Blood Elf Racial, Monk,
   [155145] = 90,	--Arcane Torrent, Blood Elf Racial, Paladin,
   [232633] = 90,	--Arcane Torrent, Blood Elf Racial, Priest,
	[25046] = 90,	--Arcane Torrent, Blood Elf Racial, Rogue,
	[69179] = 90,	--Arcane Torrent, Blood Elf Racial, Warrior,
	[20589] = 90, 	--Escape Artist, Gnome Racial
	[26297] = 180,	--Berserkering, Troll Racial
	[33702] = 120,	--Blood Fury, Orc Racial, Mage,  Warlock
	[20572]	= 120,	--Blood Fury, Orc Racial, Warrior, Hunter, Rogue, Death Knight
	[33697] = 120,	--Blood Fury, Orc Racial, Shaman, Monk
	[20577] = 120, 	--Cannibalize, Undead Racial
	[68992]	= 120,	--Darkflight, Worgen Racia
	[59545] = 180,	--Gift of the Naaru, Draenei Racial, Death Knight
	[59543] = 180,	--Gift of the Naaru, Draenei Racial, Hunter
	[59548] = 180,	--Gift of the Naaru, Draenei Racial, Mage
   [121093]	= 180,	--Gift of the Naaru, Draenei Racial, Monk
	[59542] = 180,	--Gift of the Naaru, Draenei Racial, Paladin
	[59544] = 180,	--Gift of the Naaru, Draenei Racial, Priest
	[59547] = 180,	--Gift of the Naaru, Draenei Racial, Shaman
	[28880] = 180,	--Gift of the Naaru, Draenei Racial, Warrior
   [107079] = 120,	--Quaking Palm, Pandaren Racial
	[69041] = 90,	--Rocket Barrage, Goblin Racial
	[69070] = 90,	--Rocket Jump, Goblin Racial
	[20549] = 90	--War Stomp, Tauren Racial 
}

Data.TriggerSpellIDToDisplayFileId = {}
for triggerSpellID in pairs(Data.TriggerSpellIDToTrinketnumber) do
	if TrinketTriggerSpellIDtoDisplayspellID[triggerSpellID] then
		Data.TriggerSpellIDToDisplayFileId[triggerSpellID] = GetSpellTexture(TrinketTriggerSpellIDtoDisplayspellID[triggerSpellID])
	else
		Data.TriggerSpellIDToDisplayFileId[triggerSpellID] = GetSpellTexture(triggerSpellID)
	end
end

for spellID in pairs(Data.RacialSpellIDtoCooldown) do
	Data.TriggerSpellIDToDisplayFileId[spellID] = GetSpellTexture(spellID) 
end

Data.TrinketTriggerSpellIDtoCooldown = {
	[195710] = 180,	-- Honorable Medallion, 3 min. CD
	[208683] = 120,	-- Gladiator's Medallion, 2 min. CD
	[195901] = 60 	-- Adaptation PvP Talent
}

Data.RacialSpellIDtoCooldownTrigger = {
	 [7744] = 30, 	--Will of the Forsaken, Undead Racial, 30 sec cooldown trigger on trinket
	[59752] = 30  	--Every Man for Himself, Human Racial, 30 sec cooldown trigger on trinket
}



Data.RangeToRange = {}
Data.ItemIDToRange = {}
Data.RangeToItemID	= {
	[5] = 37727, -- Ruby Acorn --workds
	[6] = 63427, -- Worgsaw --wors
	[8] = 34368, -- Attuned Crystal Cores
	[10] = 32321, -- Sparrowhawk Net
	[15] = 33069, -- Sturdy Rope
	[20] = 10645, -- Gnomish Death Ray
	[25] = 24268, -- Netherweave Net
	[30] = 34191, -- Handful of Snowflakes
	[35] = 18904, -- Zorbin's Ultra-Shrinker
	[40] = 28767, -- The Decapitator
	[45] = 32698, -- Wrangling Rope
	[50] = 116139, -- Haunting Memento
	[60] = 32825, -- Soul Cannon
	[70] = 41265, -- Eyesore Blaster
	[80] = 35278, -- Reinforced Net
	[100] = 33119, -- Malister's Frost Wand
}

for range, itemID in next, Data.RangeToItemID do
	Data.RangeToRange[range] = range
	Data.ItemIDToRange[itemID] = range
end 
