v3.1.2

Objective fix, objectives should now work properly again.

v3.1.1

Include new files in toc file

v3.1

Fixed some localization issues, fixed some error messages.
Added more positioning options

v3.0.4

Testmode now respects when something is disabled when enabled testmode

v3.0.3

player count fix

v3.0.2

Filtering fix,
Fixed objective debuffs

v3.0.1

Fixed missing localization

v3.0

New Features:

Added support for allies and 40 man BGs
Added selection highlight for player bars
Added more Options for aura display
Added multiselect for range update frames,
Added debufftype filter
Added level test
Added container colors for buffs/debuffs/DRs
Added an option to set the objectives left to the target counter
Fixed bug with re-applying debuffs
Improvements:
The addon should now correctly display debuffs when they got refreshed

Improved the detection of Adaptation for stealth players BugFixes:
Hide the border or DR icons if the user switched from frame to text mode

v2.6.3
Fixed the error i intended to fix in 2.6.2 but i didn't upload the new file LOL. This time its fixed for real

v2.6.2
Fixed an error message that was related to the code rewrite of debuffs in v 2.6
When the display type of DR Tracking is changed it now properly hides the border of new DR Icons

v2.6.1
-Deleted unnecessary message when an enemy got interrupted
-Fixed an error with battleground specific debuffs
-Disabled sliders for trinket and racial width when the main-toggle is disabled

v2.6

New features:
- Added interrupts on the Aura Display on Spec Icon
- Added settings for Racial and Trinket width
- Grab a new ally target unitID for an enemy if the current active unitID was an ally

Other improvements:
- Rewrote functions for debuff handling
- Added an additional check for the faction in a BG, this is espacially useful for the new brawl since the previous used method wasn't working well because a function returned a incorrect value (GetBattlefieldArenaFaction()). This means the addon should no longer show your team as the enemies in the new brawl (Shadow-Pan Showdown)

v2.5.1
Bugfix: The settings for the new CC icons on specicon apply now when a button is created.
Changed the way the buttons are anchored, the new way is way more performant, thanks @MunkDev@wowinterface

v.2.5
New Feature: Added CC icons on specicon, like its known from Gladius, sArena, BigDebuffs
BugFix: Fixed an bug with target counter (frame had the wrong parent)

v2.4.8
retag of v2.4.7 (Also updated changelog to trigger the packager)

v2.4.7
Included the new version of LibRaces (The previous release caused an error Thanks @zibra for reporting )

v2.4.6
Added Simplified Chinese localization, thanks to supercclolz
Fixed respawn timer in RBG (let me know if there is still something wrong with it)
Rewrote some code for option panel

v2.4.5
New Features:
- Toggle Animation in testmode
- Position setting for Objective icon (Objective can now be displayed right to racials/pvp-talents)
- Textmode for DR Tracking (color the text instead of the borders, works only if you don't have an addon installed that modifies the countdown texts, such as OmniCC)

v2.4
New feature: Added settings for cooldown text for pvp-talent, racials, DR tracking, Debuffs and respawn timer. This setting is especially useful for users that don't use addons like OmniCC.

v2.3.5
New features: Added filtering for DR categorys and racials
Bugfix: Fixed a bug with role icons having wrong strata

v2.3.1
Added option for range indicator, you can now choose which stuff should be transparent

v2.3
7.3 Toc-Update, PlaySound changes, Fixed copy and paste mistake that affected target and focus border

v2.2.5
New Feature: Added filtering for own debuffs.

v2.2.0
Added profile support
Added custom mouse binding macros
Fixed a bug with gender dependent spec names, this bug affected users of the following locales: esES, esMX and ruRU
Thanks to stalker19921 for reporting this error and helping my fixing it.
