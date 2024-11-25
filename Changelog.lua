---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)


Data.changelog = {
	{
		Version = "11.0.5.9",
		General = "This version fixes errors and bugs",
		Sections = {
			{
				Header = "Bugfix",
				Entries = {
					"Fixed bug leading to allies not being updated correctly after teammates changed, mostly noticable in solo shuffle.",
					"Fixed error/bug when using test or editmode in arena.",
					"Fixed respawn timer not resetting."
				}
			},
		}
	},
	{
		Version = "11.0.5.8",
		General = "This version mostly is just a minor update after release of 11.0.5.1. Please read its changelog to know more about that major update.",
		Sections = {
			{
				Header = "New features:",
				Entries = {
					"Added debug logging capability to the options panel.",
					"Edit and testmode can now be used inside arena or battlegrounds while not in combat"
				}
			},
			{
				Header = "Bugfix",
				Entries = {
					"Resetting a custom player count profile to default will no longer overwrite the player count",
					"Fixed enemies not loading on classic/cataclysm. Thanks to shmagey73 and b1ghead3d from curseforge for the help",
				}
			},
			{
				Header = "Changes",
				Entries = {
					"Increased respawm time in solo rated battlegrounds by 1 second to 16 seconds",
					"Increased repawm time in solo rated battleground Deephaul Ravine to 26 seconds",
					"When custom player count profiles are enabled, they will still be shown but be disabled, this is to avoid confusion since they still can be used to copy settings from",
					"Improved editmode by making it more static and less jumpy",
				}
			}
		}
	},
	{
		Version = "11.0.5.7",
		General = "This version mostly is just a minor update after release of 11.0.5.1. Please read its changelog to know more about that major update.",
		Sections = {
			{
				Header = "New features:",
				Entries = {
					"Added support for CUSTOM_CLASS_COLORS to be used by healthbars and the target indicator symbols."
				}
			},
			{
				Header = "Bugfix",
				Entries = {
					"Fixed wrong labling for targeting next or previous ally in the keybindng section",
				}
			},
			{
				Header = "Changes",
				Entries = {
					"Added Evoker Quell to list of interrupts",
				}
			}
		}
	},
	{
		Version = "11.0.5.6",
		General = "This version mostly is just a minor update after release of 11.0.5.1. Please read its changelog to know more about that major update.",
		Sections = {
			{
				Header = "Bugfix",
				Entries = {
					"Fixed an issue with the stack text not showing up for allies on the objective."
				}
			}
		}
	},
	{
		Version = "11.0.5.5",
		General = "This version mostly is just a minor update after release of 11.0.5.1. Please read its changelog to know more about that major update.",
		Sections = {
			{
				Header = "New features:",
				Entries = {
					"Added an option to hide the highest priority aura on priority buffs and debuffs modules."
				}
			},
			{
				Header = "Changes:",
				Entries = {
					"Mouse wheel scrolling through frames is now disabled by default. You can enable it in the general settings. I am sorry for the problems this may have caused due to the interference with mouseover keybindings. Thanks to MartyrTV1 for the feedback.",
					"Moved custom DR category icons selection into its own settings group for cleaner look"
				}
			},
			{
				Header = "Bugfix",
				Entries = {
					"Fixed error message when players changed in combat"
				}
			}
		}
	},
	{
		Version = "11.0.5.4",
		General = "This version mostly is just a minor bugfix and beautifying update after release of 11.0.5.1. Please read its changelog to know more about that major update.",
		Sections = {
			{
				Header = "Changes:",
				Entries = {
					"Hide tab for non existing module specfic settings. Thanks to Squimbert from GitHub for the feedback",
					"Borders for my target and focus are now shown around enemies at beginning of the testmode. Thanks to Squimbert from GitHub for the feedback",
					"Label the button to delete the custom player count profile with Delete instead of X. Thanks to Squimbert from GitHub for the feedback.",
					"Correctly label the settings for the button horizontal grow direction"
				}
			},
			{
				Header = "Bugfix",
				Entries = {
					"Auras will now be reset once no available unitID is assigned to a player",
					"Fixed bug regarding dead players in testmode",
					"Fixed typo which caused respawn timer to not show up in solo rbg",
					"Fixed bug which caused button positions not getting saved properly when not growing down and right",
					"Fixed a bug regarding the option to hide raidframes, which caused raidframes to be enabled on login. Thanks to TheCheat54 from Curseforge for the report"
				}
			}
		}
	},
	{
		Version = "11.0.5.3",
		General = "This version mostly is just a minor update after release of 11.0.5.1. Please read its changelog to know more about that major update.",
		Sections = {
			{
				Header = "Bugfix",
				Entries = {
					"removed faulty debug logging",
				}
			}
		}
	},
	{
		Version = "11.0.5.2",
		General = "This version mostly is just a minor update after release of 11.0.5.1. Please read its changelog to know more about that major update.",
		Sections = {
			{
				Header = "New Features:",
				Entries = {
					"Added a feature requested by snakefizz from curseforge: You can now enable an option to only show the power bar for healers.",
					"Added a feature requested by snakefizz from curseforge: You can now enable an option to hide the numeric target indicator number when its 0."
				}
			},
			{
				Header = "Bugfix",
				Entries = {
					"Fixed the addon not showing frames in arena prep room. Thanks at zaldun at curseforge for the report.",
				}
			}
		}
	},
	{
		Version = "11.0.5.1",
		General = "Tons of new features and changes arrived aiming to make the addon much easier to setup by trimming down the settings and by adding the new editmode. Checkout the full list below if you wanna know more :). Unfortunately due to many settings being global now it means that the settings will get reset to defaults. Since the changes are quite signifficant please let me know if you are facing any problems.",
		Sections = {
			{
				Header = "New Features:",
				Entries = {
					"Added an Editmode to the addon, it works similar to Blizzards Editmode so it enables you to drag and drop and snap frames to other frames. When you select a frame the options panel will jump to the setting of that particular module.",
					"Made most of the settings global, meaning they apply no matter if its an enemy or ally and no matter the player count.",
					"Added an option to copy over all settings from allies to enemies and vice versa, You can also choose to mirror the settings visually",
					"Added multiple keybind related features: By default you are now able to target the next or previous enemy or ally by scrolling over the ally or enemy frame. Also added 4 new keybinding settings to the blizzard keybinding section. You will now find BattleGroundEnemies there.",
					"Added Deephaul Crystal to bg buffs",
					"Added new global module settings for DR tracker, you can now specify a specific icon to show up for each dr category. You can find this new setting at General > Modules",
					"Added a feature requested by RealJig at GitHub: You can now select to automatically hide the default Blizzard raid frames in a battleground. You can find this settings at General > Miscellaneous",
					"Added the possibility to create individual subprofiles for player counts, this enables you finer control over positioning of your frames.",
					"You can now specify a player count from 1 to 40 for the testmode. This enabled you more control over the various settings depending on how many players are shown.",
					"Added combat indicator to testmode",
					"Added a new option to choose the role sorting order as requested by Hoffahoff from CurseForge",
				}
			},
			{
				Header = "Changes:",
				Entries = {
					"Reworked the way the modules for spec and class and priority aura/interrupt work. They are now merged into one module to make it compatible with the new editmode. There are now two of this new modules, this will allow you to still see the class or spec of a player even if an aura is active, second module is disabled by default.",
					"New spec class priority module now offers more modern class icons",
					"Set respawn time to 15 seconds for solo rated battlegrounds."
				}
			},
			{
				Header = "Bugfix",
				Entries = {
					"Fixed not showing up enemies in battlegrounds",
					"Fixed a bug related to the factions not being set correctly, which caused an error",
					"Fixed an error reported by Addonman on GitHub",
					"Fixed DrTracker cooldown",
					"Fixed racials and trinket in testmode",
					"Fixed error reported by xenoyearner on Curseforge"
				}
			}
		}
	},
	{
		Version = "11.0.5.0",
		General = "Fixed errors and removed message for missing localizations",
		Sections = {
			{
				Header = "Bugfix",
				Entries = {
					"Fixed error in new cataclysm patch 4.4.1",
					"Removed message for missing localizations"
				}
			}
		}
	},
	{
		Version = "11.0.2.3",
		General = "Update for The War Within",
		Sections = {
			{
				Header = "Bugfix",
				Entries = {
					"New version of LibGroupInSpecT library to get rid of error."
				}
			}
		}
	},
	{
		Version = "11.0.2.2",
		General = "Update for The War Within",
		Sections = {
			{
				Header = "Bugfix",
				Entries = {
					"Fixed error message on classic"
				}
			}
		}
	},
	{
		Version = "11.0.2.1",
		General = "Update for The War Within",
		Sections = {
			{
				Header = "Bugfix",
				Entries = {
					"Fixed the combat log scanning problem leading to problems with DR tracking and other features relying on combat log."
				}
			}
		}
	},
	{
		Version = "11.0.2.0",
		General = "Update for The War Within",
		Sections = {
			{
				Header = "Bugfix",
				Entries = {
					"Made the addon work for the patch 11.0.2"
				}
			}
		}
	},
	{
		Version = "11.0.0.0",
		General = "Update for The War Within",
		Sections = {
			{
				Header = "Bugfix",
				Entries = {
					"Fixed a typo/bug reported by zzwtest from GitHub."
				}
			}
		}
	},
	{
		Version = "10.2.7.3",
		General = "Minor update",
		Sections = {
			{
				Header = "New Feature:",
				Entries = {
					"Added an option the trigger keybinds on key down instead of key release as requested by mowanza from curseforge."
				}
			}
		}
	},
	{
		Version = "10.2.7.2",
		General = "Change regarding res time in Rated Battlegrounds in Cataclysm Classic.",
		Sections = {
			{
				Header = "Classic",
				Entries = {
					"Changed the res timer to be 45 seconds in rated battlegrounds in Cataclysm Classic. Thanks to verstapen from Curseforge for the hint."
				}
			}
		}
	},
	{
		Version = "10.2.7.1",
		General = "Bugfix and new cooldown settings",
		Sections = {
			{
				Header = "New Feature:",
				Entries = {
					"Added a settings to enable/disable the cooldown swipe texture as requested by JordanK295 from GitHub."
				}
			},
			{
				Header = "Bugfixes:",
				Entries = {
					"Fixed the imported profile settings not surviving a interface reload or a logout after being imported from a string. Thanks to Zendara from Curseforge for the report.",
				}
			},
		}
	},
	{
		Version = "10.2.7.0",
		General = "Update for Cataclysm Classic",
		Sections = {
			{
				Header = "Changes:",
				Entries = {
					"Trinket cooldown reduced to 90 seocnds for healers, thanks to hazzal from GitHub for the report."
				}
			},
			{
				Header = "Bugfixes:",
				Entries = {
					"Fixed errors on Cataclysm classic",
				}
			},
		}
	},
	{
		Version = "10.2.0.3",
		General = "Bugfix an error.",
		Sections = {
			{
				Header = "Bugfixes:",
				Entries = {
					"Fixed an error regarding LibGroupInSpecT on Classic. Thanks to timber_hall@CurseForge for the report.",
				}
			},
		}
	},
	{
		Version = "10.2.0.2",
		General = "Some minor changes and bugfixes",
		Sections = {
			{
				Header = "Bugfixes:",
				Entries = {
					"Fixed the reverse operation of the Disable arena frames in arena setting. Thanks to synthetized@CurseForge for reporting.",
				}
			},
		}
	},
	{
		Version = "10.2.0.1",
		General = "Some minor changes and bugfixes",
		Sections = {
			{
				Header = "Changes:",
				Entries = {
					"Custom keybinding now also works in arenas. Thanks to ItsMeATaco at CurseForge for reporting"
				}
			},
			{
				Header = "Bugfixes:",
				Entries = {
					"The addon now also hides the new square arena frames introduced some months ago when the option is set. Thanks to Kennahz from GitHub for the report",
				}
			},
		}
	},
	{
		Version = "10.2.0.0",
		General = "This version mostly contains bugfixes and minor tweaks being reported during the last months. I Tried to catch them all. If you still face some issues please let me know on Curseforge or GitHub.",
		Sections = {
			{
				Header = "Changes:",
				Entries = {
					"The Addon now uses LibRangeCheck-3.0 to check for the distance to other players. This also fixes the error message due to blizzards new combat restrictions on retail. You might need to change your range indicator range setting",
					"The Addon now resets all auras if a different player has been assigned to a button.",
					"Aura icons are now cropped a little bit for cleaner looks.",
					"The addon is now disabled if more than 40 people are in a raid. (For example in Epic Battlegrounds)",
					"Player frames now have a global name assigned."
				}
			},
			{
				Header = "Bugfixes:",
				Entries = {
					"Fix the hiding of the arena frames in battlegrounds and arena.",
					"Includes new version of LibChangelog which fixes an error message on wotlk/classic.",
					"Fixed an error in the icon selector for the combat indicator.",
					"Fixed an bug with the spec not showing when testing solo.",
					"Fixed some problems with debuff type filtering."
				}
			},
			{
				Header = "New Features:",
				Entries = {
					"Added support for blizzards mouseover casting on ally frames. This feature is enabled by default",
				}
			},
		}
	},
	{
		Version = "10.0.2.7",
		Sections = {
			{
				Header = "Changes:",
				Entries = {
					"The addon will not set the pvp trinket CD to 2 minutes if the expansion is retail or the player is level 70 or higher. Otherwise it will be 5 minutes. Thanks to henrygeorgebush at curseforge.",
					"Human racial now has 120 seconds CD in classic. Thanks to henrygeorgebush at curseforge."
				}
			},
			{
				Header = "Bugfixes:",
				Entries = {
					"Fixed testmode auras. Thanks to henrygeorgebush at curseforge.",
					"Fixed debuff type filtering. Buffs can now be filtered by type magic, and debuffs by type magic, curse, poision and Disease. Thanks to henrygeorgebush at curseforge."
				}
			},
		}
	},
	{
		Version = "10.0.2.6",
		Sections = {
			{
				Header = "Changes:",
				Entries = {
					"The addon now removes all auras (buffs and debuffs) for enemies that have no longer a unitID assigned. This prevents the addon from showing outdated auras.",
				}
			},
		}
	},
	{
		Version = "10.0.2.5",
		Sections = {
			{
				Header = "Changes:",
				Entries = {
					"Non Priority buffs and debuffs are now disabled for bg size 15 players since it leads to too much clutter.",
				}
			},
		}
	},
	{
		Version = "10.0.2.4",
		Sections = {
			{
				Header = "Bugfixes:",
				Entries = {
					"Fixed the flickering health bar.",
				}
			},
			{
				Header = "Changes:",
				Entries = {
					"The addon will now check for up to 15 arena unitIDs, this is helpful in the Arena Brawl Packed House.",
				}
			},
		}
	},
	{
		Version = "10.0.2.3",
		Sections = {
			{
				Header = "Bugfixes:",
				Entries = {
					"Fix for the brawl Packed House.",
				}
			},
			{
				Header = "Changes:",
				Entries = {
					"Reworked the way the addon handles player updates from diferent player sources. The addon now stores data from all that sources and combines them to create player bars. This also fixes the addon in the brawl Packed House."
				}
			},
		}
	},
	{
		Version = "10.0.2.2",
		Sections = {
			{
				Header = "Bugfixes:",
				Entries = {
					"Removed leftover message from development, thanks to Doyansu233 and Clarkis2001 aat Curseforge for the report.",
					"Fixed an error that prevented targeting of enemy players in arena after they changed name, in arena the addon will now always target by unitID instad of playername, this is helpful for stealth players expecially since the addon can't update in combat due to Blizzards restrictions."
				}
			}
		}
	},
	{
		Version = "10.0.2.1",
		General = "This version fixes some problems i found during solo shuffle arenas and adds some features. It adds some allied races and improved auras.",
		Sections = {
			{
				Header = "New Features:",
				Entries = {
					"Added racials Bag of Tricks, Fireblood, Light's Judgment, Bull Rush, Haymaker and Arcane Pulse",
					"The addon will now also show auras without a duration in the highest priority module.",
					"The addon will now use the scoreboard info to show the player names in the prep room before the first round starts when in a solo shuffle"
				}
			},
			{
				Header = "Changes:",
				Entries = {
					"The addon will now show non priority buffs and debuffs that are applied by the player by or are dispellable by default.",
					"The enemy players are now always sorted by arena id when in arena, by default arena1 is the top player"
				}
			},
			{
				Header = "Bugfixes:",
				Entries = {
					"When the duration filter is enabled for auras it will only show the aura if it actually has a duration.",
					"Update LibSpellIconSelector library to avoid taint. Thanks to zaphon at GitHub for the report.",
					"Improved the handling of update in combat. This mostly affected name changes of stealth units at the beginning of an arena while in combat.",
					"Fixed error reported by Thenetbug at Curseforge that happened in rated Battlegrounds when the combat log scanning was getting switched off."
				}
			}
		}
	},
	{
		Version = "10.0.2.0",
		General = "This version fixes a error message and hopefully makes RBGs fully working. Please read the notes from version 9.2.7.2 below if you haven't been using a version 9.2.7.X before",
		Sections = {
			{
				Header = "New Features:",
				Entries = {
					"Added a option to change the thickness of the borders used for your target and focus.",
					"Added a new icon selector that is used for the combat indicator."
				}
			},
			{
				Header = "Bugfixes:",
				Entries = {
					"Fixed a error that occured when going from a BG into a arena reported by dankNstein_ at curseforge.",
					"Fixed a issue when the lost health option was selected for the health text."
				}
			},
			{
				Header = "Changes:",
				Entries = {
					"This release should now fully workes in RBGs, thanks at l3uGsY at GitHub for testing things out and providing data :)",
					"Non priority auras will now show if they are dispellable or cast by you.",
					"Added back the aura scanning for enemies that are only targeted by group members and don't have any other unit IDs assigned."
				}
			}
		}
	},
	{
		Version = "10.0.0.3",
		General = "This version fixed a code loop.. Please read the notes from version 9.2.7.2 below if you haven't been using a version 9.2.7.X before",
		Sections = {
			{
				Header = "Bugfixes:",
				Entries = {
					"Fixed a code loop which potentially can result in a game freeze. Thanks to everyone contributing and reporting :)",
				}
			}
		}
	},
	{
		Version = "10.0.0.2",
		General = "This version brings a new features and fixes reported errors and issues. Please read the notes from version 9.2.7.2 below if you haven't been using a version 9.2.7.X before",
		Sections = {
			{
				Header = "New Features:",
				Entries = {
					"Added support for combat log scanning to detect enemy players in Rated Battlegrounds on Dragonflight. Please note that this means its no longer possible to get the spec of a player. Thanks at l3uGsY at Github for doing some tests.",
				}
			},
			{
				Header = "Bugfixes:",
				Entries = {
					"Fixed a Lua error reported by creepshow11483 at curseforge.",
					"Fixed a Lua error reported by GeT_LeNiN at curseforge.",
					"Reduced the amount of aura scans for enemies targeted by Allies, this hopefully fixes the problem with the game being unresponsive",
					"Fixed a bug regarding custom aura filtering of non priority auras reported by Seadu at curseforge",
					"Fixed a issue where the powerbar was chaning color when a player had a alternative ressource update like a rogue gaining a combo point"
				}
			},
			{
				Header = "Changes:",
				Entries = {
					"Player names are now truncated if they dont fit into the frame and dont wrap into two lines anymore.",
					"Updated the default settings for arena to avoid overlapping modules.",
					"Health text is now abbreviated if too long. (Same as its done on Default Blizzard frames)",
				}
			}
		}
	},
	{
		Version = "10.0.0.1",
		General = "Another bugfix update with other smaller changes. Please read the notes from version 9.2.7.2 below if you haven't been using a version 9.2.7.X before",
		Sections = {
			{
				Header = "Bugfixes:",
				Entries = {
					"Fixed a typo that affected the target indicator symbols not to show up",
					"Fixed a typo that let to an error for aura updates",
					"Fixed a issue with incorrectly assigned to enemy players which let to stuff depending on it showing infos for different players like buffs, castbar, etc",
					"Fixed a issue were running the testmode before entering a BG let to battleground specifig buffs show up when a player was shown in a arena frame",
				}
			},
			{
				Header = "Changes:",
				Entries = {
					"There are now 2 settings to disable arena frames, one to hide them battlegrounds and one for arenas"
				}
			}
		}
	},
	{
		Version = "10.0.0.0",
		General = "Just a small bugfix update. Please read the notes below if you haven't been using a version 9.2.7.X before",
		Sections = {
			{
				Header = "New Features:",
				Entries = {
					"Added a new module 'Combat Indicator'. This module shows an icon depending on the state of the player. It can show an icon when the player is in combat or out of combat, it will show no icon if the status is unknown. (This can be the case for enemies that dont have a unitID assigned.) This module is not 100% finished yet and disabled by default. I will add a icon selector in the future, and its missing the testmode implementation. Feedback on this new feature is appreciated :)",
				}
			},
			{
				Header = "Changes:",
				Entries = {
					"Toc update for 10.0.0"
				}
			},
			{
				Header = "Bugfixes:",
				Entries = {
					"Auras gathered by the new UNIT_AURA 2nd argument get a priority applied"
				}
			}
		}
	},
	{
		Version = "9.2.7.2",
		General = "This is the long awaited update with many changes and new features. It is recommended to reset the settings of the addon in the profile tab, especially when you didnt use the default settings. This is due to the fact that the saved variables format changed. So please take a few minutes and check out the testmode :)",
		Sections = {
			{
				Header = "New Features:",
				Entries = {
					"Added seperate modules for important buffs and debuffs",
					"Unified code for the containers used by the DR Tracking and Buffs, Debuffs.",
					"Added a seperate module for class icons, the spec icon is stacked ontop of the class icon by default. This enables you to show the two icons side by side if wanted.",
					"Added the ability to add health numbers (percentage, lost health and current health)",
					"Added an option to disable target icons.",
					"Added the option to export and import profiles to and from a string.",
					"Added the option to reset modules individually to the default setting.",
					"Added an option to use the priority of Auras and Interrupts from BigDebuffs",
					"Pretty much all of the stuff is now individually movable and sizable",
				}
			},
			{
				Header = "Changes:",
				Entries = {
					"Reworked the aura system once again. it now should update the auras of enemies more often if an unit ID is available.",
					"Only send infos about a missing localization entry once.",
					"Toc updates for Classic, TBCC, Wrath and Retail"
				}
			}
		}
	},
	{
		Version = "9.2.0.11",
		Sections = {
			{
				Header = "Bugfixes:",
				Entries = {
					"Fixed a mistake in version string comparison which resulted in spam about a new available version. Thanks coyote_ii@curseforge for the report."
				}
			}
		}
	},
	{
		Version = "9.2.0.10",
		Sections = {
			{
				Header = "Bugfixes:",
				Entries = {
					"The addon frames should no longer be able to be placed outside the screen."
				}
			}
		}
	},
	{
		Version = "9.2.0.9",
		Sections = {
			{
				Header = "Bugfixes:",
				Entries = {
					"Fixed a error message that happened in TBC or Classic. It was probably caused by some data not yet being available. Thanks to Maas1337@Github for reporting."
				}
			}
		}
	},
	{
		Version = "9.2.0.8",
		Sections = {
			{
				Header = "Bugfixes:",
				Entries = {
					"Fixed a error message. Thanks to Soundsstream@curseforge for reporting"
				}
			}
		}
	},
	{
		Version = "9.2.0.7",
		Sections = {
			{
				Header = "Bugfixes:",
				Entries = {
					"Fixed an error that appeared in battlegrounds wich was caused by another addon or probably by disabling the default arena UI addon. Thank to Sharki519@curseforge for reporting."
				}
			}
		}
	},
	{
		Version = "9.2.0.6",
		Sections = {
			{
				Header = "New Features:",
				Entries = {
					"Added absorbs to the healthbar, same functionality as the default Blizzard frames. This can be disabled in the healthbar settings."
				}
			},
			{
				Header = "Changes:",
				Entries = {
					"The addon now works in the Comp Stomp brawl. "
				}
			},
			{
				Header = "Bugfixes:",
				Entries = {
					"Fixed a issue with the Respawn timer icon staying on screen after the player is alive again.",
					"Fixed a bug where the Spec icon was overlayed by CC icons when you entered a new BG. Thanks for reporting that issue"
				}
			}
		}
	},
	{
		Version = "9.2.0.5",
		Sections = {
			{
				Header = "New Features:",
				Entries = {
					"Added support for Classic",
					"Added a Castbar module which is enabled in Arenas by default."
				}
			},
			{
				Header = "Changes:",
				Entries = {
					"Added a comma between the name list in the /bgev text",
					"print the newest available version when out of date",
					"The addon now uses the same package/zip for Classic, TBC and Retail",
				}
			},
			{
				Header = "Bugfixes:",
				Entries = {
					"Gladiator's resolve has no Cooldown."
				}
			}
		}
	},
	{
		Version = "9.2.0.4",
		Sections = {
			{
				Header = "Bugfixes:",
				Entries = {
					"Fixed two Lua errors after login"
				}
			}
		}
	},
	{
		Version = "9.2.0.3",
		Sections = {
			{
				Header = "Bugfixes:",
				Entries = {
					"Fixed the target indicators, which i broke accidentally in 9.2.0.0",
					"Fixed an issue that made allies disappear and reappear shortly after joining the group or after a reload"
				}
			}
		}
	},
	{
		Version = "9.2.0.0",
		Sections = {
			{
				Header = "New Features:",
				Entries = {
					"Added support for arenas. Feedback appreciated",
					"Added support for the new pvp trinket Gladiator's Fastidious Resolve"
				}
			},
			{
				Header = "Bugfixes:",
				Entries = {
					"Fixed a bug reported by mltco78dhs@curseforge that happened in rated battlegrounds.",
					"Fixed a bug reported by zooloogorbonos and Air10000 that happened in open world"
				}
			},
			{
				Header = "Changes:",
				Entries = {
					"Toc update for 9.2"
				}
			}
		}
	},
	{
		Version = "9.1.0.0",
		Sections = {
			{
				Header = "New Features:",
				Entries = {
					"Added support for arenas. It might still be a bit buggy and the default settings aren't really updated yet. Testmode is working. Feedback appreciated",
				}	
			},
			{
				Header = "Changes:",
				Entries = {
					"Toc update for 9.1"
				}
			}
		}
	},
	{
		Version = "9.0.5.6",
		Sections = {
			{
				Header = "New Features:",
				Entries = {
					"Added a new window that shows changes made in new releases"
				}
			}
		}
	},
	{
		Version = "9.0.5.5",
		Sections = {
			{
				Header = "New Features",
				Entries = {
					"Added first version of target calling, feedback appreciated. Check out the Rated Battleground section in the options. Read about how it works in the FAQ at https://github.com/BullseiWoWAddons/BattleGroundEnemies/wiki/FAQ"
				}
			}
		}
	}
}
