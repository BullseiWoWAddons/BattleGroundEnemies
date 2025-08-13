---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)
local L = Data.L
local LSM = LibStub("LibSharedMedia-3.0")
local DRList = LibStub("DRList-1.0")

local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local LibChangelog = LibStub("LibChangelog")

--upvalues
local _G = _G
local math_random = math.random
local math_min = math.min
local pairs = pairs
local print = print
local table_insert = table.insert
local table_remove = table.remove
local time = time
local type = type
local unpack = unpack

local C_PvP = C_PvP
local C_Spell = C_Spell
local C_UnitAuras = C_UnitAuras
local CreateFrame = CreateFrame
local CTimerNewTicker = C_Timer.NewTicker
local GetArenaOpponentSpec = GetArenaOpponentSpec
local GetBattlefieldArenaFaction = GetBattlefieldArenaFaction
local GetBattlefieldScore = GetBattlefieldScore
local GetBattlefieldTeamInfo = GetBattlefieldTeamInfo
local GetBestMapForUnit = C_Map.GetBestMapForUnit
local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetNumGroupMembers = GetNumGroupMembers
local GetNumSpellTabs = C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines or GetNumSpellTabs
local GetRaidRosterInfo = GetRaidRosterInfo
local GetSpecializationInfoByID = GetSpecializationInfoByID
local GetSpellBookItemName = C_SpellBook and C_SpellBook.GetSpellBookItemName or GetSpellBookItemName
local GetSpellName = C_Spell and C_Spell.GetSpellName or GetSpellName
local GetSpellTabInfo = GetSpellTabInfo
local GetSpellTexture = C_Spell and C_Spell.GetSpellTexture or GetSpellTexture
local C_SpellBook = C_SpellBook
local GetTime = GetTime
local GetUnitName = GetUnitName
local InCombatLockdown = InCombatLockdown
local IsInBrawl = C_PvP.IsInBrawl
local IsInInstance = IsInInstance
local IsInRaid = IsInRaid
local RequestBattlefieldScoreData = RequestBattlefieldScoreData
local RequestCrowdControlSpell = C_PvP.RequestCrowdControlSpell
local SetBattlefieldScoreFaction = SetBattlefieldScoreFaction
local UnitExists = UnitExists
local UnitFactionGroup = UnitFactionGroup
local UnitGUID = UnitGUID
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsGhost = UnitIsGhost
local UnitName = UnitName
local UnitRace = UnitRace
local UnitRealmRelationship = UnitRealmRelationship

local IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local IsTBCC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local IsWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC

local HasSpeccs = not not GetSpecialization  -- Mists of Pandaria

local MaxLevel = GetMaxPlayerLevel()

local LGIST
if HasSpeccs then
	LGIST = LibStub:GetLibrary("LibGroupInSpecT-1.1")
end

-- binding definitions
--BINDING_HEADER_BATTLEGROUNDENEMIES = "BattleGroundEnemies"
_G["BINDING_NAME_CLICK BGEAllies:Button4"] = L.TargetPreviousAlly
_G["BINDING_NAME_CLICK BGEAllies:Button5"] = L.TargetNextAlly
_G["BINDING_NAME_CLICK BGEEnemies:Button4"] = L.TargetPreviousEnemy
_G["BINDING_NAME_CLICK BGEEnemies:Button5"] = L.TargetNextEnemy


if not GetUnitName then
	GetUnitName = function(unit, showServerName)
		local name, server = UnitName(unit);

		if (server and server ~= "") then
			if (showServerName) then
				return name .. "-" .. server;
			else
				local relationship = UnitRealmRelationship(unit);
				if (relationship == LE_REALM_RELATION_VIRTUAL) then
					return name;
				else
					return name .. FOREIGN_SERVER_LABEL;
				end
			end
		else
			return name;
		end
	end
end


LSM:Register("font", "PT Sans Narrow Bold", [[Interface\AddOns\BattleGroundEnemies\Fonts\PT Sans Narrow Bold.ttf]])
LSM:Register("statusbar", "UI-StatusBar", "Interface\\TargetingFrame\\UI-StatusBar")

---@class BattleGroundEnemies: frame
BattleGroundEnemies = CreateFrame("Frame", "BattleGroundEnemies", UIParent)
BattleGroundEnemies.Counter = {}

--todo: add castbars and combat indicator to testmode
--move unitID update for allies

-- for Clique Support
ClickCastFrames = ClickCastFrames or {}


--[[
Ally frames use Scoreboard, FakePlayers, GroupMembers,
Enemy frames use Scoreboard, FakePlayers, ArenaPlayers, CombatLog
]]

BattleGroundEnemies.consts = {}
BattleGroundEnemies.consts.PlayerSources = {
	Scoreboard = "Scoreboard",
	GroupMembers = "GroupMembers",
	ArenaPlayers = "ArenaPlayers",
	FakePlayers = "FakePlayers",
	CombatLog = "CombatLog"
}
BattleGroundEnemies.consts.PlayerTypes = {
	Allies = "Allies",
	Enemies = "Enemies"
}

local previousCvarRaidOptionIsShown

--variables used in multiple functions, if a variable is only used by one function its declared above that function
BattleGroundEnemies.currentTarget = false
BattleGroundEnemies.currentFocus = false

BattleGroundEnemies.Testmode = {
	PlayerCountTestmode = 5,
	FakePlayerAuras = {}, --key = playerbutton, value = {}
	FakePlayerDRs = {},   --key = playerButtonTable, value = {categoryname = {state = 0, expirationTime}
	RandomRacials = false, -- key = number, value = spellId-- key = number, value = spellId
	RandomTrinkets = false, -- key = number, value = spellId-- key = number, value = spellId
}

BattleGroundEnemies.ButtonModules = {}   --contains moduleFrames, key is the module name
BattleGroundEnemies.UserFaction = UnitFactionGroup("player")
BattleGroundEnemies.UserButton = false   --the button of the Player himself
BattleGroundEnemies.specCache = {} -- key = GUID, value = specName (localized)

local playerSpells
local priorityAuras = {}
local nonPriorityAuras = {}
local auraFilters = { "HELPFUL", "HARMFUL" }

---@class bgeState
---@field WOW_PROJECT_ID number
---@field isInArena boolean
---@field isInBattleground boolean
---@field currentMapId number|boolean
---@field isRatedBG boolean
---@field isSoloRBG boolean

BattleGroundEnemies.states = {
	editmodeActive = false,
	testmodeActive = false,
	userIsAlive = not UnitIsDeadOrGhost("player"),
	---@type bgeState
	real = {
		WOW_PROJECT_ID = WOW_PROJECT_ID,
		isInArena = false,
		isInBattleground = false,
		currentMapId = false,
		isRatedBG = false,
		isSoloRBG = false,
	},
	---@type bgeState
	test = {
		WOW_PROJECT_ID = WOW_PROJECT_ID,
		isInArena = false,
		isInBattleground = false,
		currentMapId = false,
		isRatedBG = false,
		isSoloRBG = false,
	}
}

---@return bgeState
function BattleGroundEnemies:GetActiveStates()
	if self:IsTestmodeOrEditmodeActive() then
		return self.states.test
	else
		return self.states.real
	end
end

function BattleGroundEnemies:GetBattlegroundAuras()
	local states = self:GetActiveStates()
	if not states then return end
	return Data.BattlegroundspezificBuffs[states.currentMapId], Data.BattlegroundspezificDebuffs[states.currentMapId]
end






function BattleGroundEnemies:IsTestmodeOrEditmodeActive()
	return self.states.testmodeActive or self.states.editmodeActive
end



function BattleGroundEnemies:FlipButtonModuleSettingsHorizontally(moduleName, dbLocation)
	local newSettings = {}

	local moduleFrame = self.ButtonModules[moduleName]
	if not moduleFrame or moduleFrame.attachSettingsToButton then
		newSettings = CopyTable(dbLocation, false)
	else
		for k,v in pairs(dbLocation) do
			if type(v) == "table" then
				if k == "Points" then
					local newPointsData = CopyTable(v, false)
					for i = 1, #v do
						local pointsData = v[i]
						if pointsData.Point then
							newPointsData[i].Point = Data.Helpers.getOppositeHorizontalPoint(pointsData.Point) or pointsData.Point
						end
						if pointsData.RelativePoint then
							newPointsData[i].RelativePoint = Data.Helpers.getOppositeHorizontalPoint(pointsData.RelativePoint) or pointsData.RelativePoint
						end
						if pointsData.OffsetX then
							newPointsData[i].OffsetX = -pointsData.OffsetX
						end
					end
					newSettings[k] = newPointsData
				elseif k == "Container" then
					local newContainerSettings = CopyTable(v, false)
					local newHorizontalGrowDirection

					local horizontalGrowdirection = v.HorizontalGrowDirection
					if horizontalGrowdirection then
						newHorizontalGrowDirection = Data.Helpers.getOppositeDirection(horizontalGrowdirection) or horizontalGrowdirection
					end
					newContainerSettings.HorizontalGrowDirection = newHorizontalGrowDirection
					newSettings[k] = newContainerSettings
				else
					newSettings[k] = self:FlipButtonModuleSettingsHorizontally(moduleName, v)
				end
			else
				newSettings[k] = v
			end
		end
	end

	return newSettings
end

function BattleGroundEnemies:FlipSettingsHorizontallyRecursive(dblocation)
	local dbLocationFlippedHorizontally = {}
	for k,v in pairs(dblocation) do
		if type(v) == "table" then
			if k == "ButtonModules" then
				dbLocationFlippedHorizontally[k] = {}
				for moduleName, moduleSettings in pairs(v) do
					dbLocationFlippedHorizontally[k][moduleName] = self:FlipButtonModuleSettingsHorizontally(moduleName, moduleSettings)
				end
			else
				dbLocationFlippedHorizontally[k] = self:FlipSettingsHorizontallyRecursive(v)
			end
		else
			dbLocationFlippedHorizontally[k] = v
		end
	end
	return dbLocationFlippedHorizontally
end


local function selectRandomAuraFromTable(auraTable, filter, forEditmode, unitCaster, canApplyAura, castByPlayer)
	if not auraTable or (#auraTable < 1) then return end
	local whichAura = math_random(1, #auraTable)
	local auraToSend
	if type(auraTable[whichAura]) == "number" then
		auraToSend = {
			spellId = auraTable[whichAura],
			icon = GetSpellTexture(auraTable[whichAura])
		}
	else
		auraToSend = auraTable[whichAura]
	end

	local spellName = GetSpellName(auraToSend.spellId)

	if not spellName then return end

	local duration
	if forEditmode then
		duration = 60 * 60
	else
		duration = auraToSend.duration
	end

	local newAura = {
		applications = auraToSend.applications,
		name = spellName,
		auraInstanceID = nil,
		canApplyAura = canApplyAura or auraToSend.canApplyAura,
		charges = nil,
		dispelName = auraToSend.dispelName,
		duration = duration,
		expirationTime = GetTime() + duration,
		icon = auraToSend.icon,
		isBossAura = auraToSend.isBossAura,
		isFromPlayerOrPlayerPet = castByPlayer or auraToSend.isFromPlayerOrPlayerPet,
		isHarmful = filter == "HARMFUL",
		isHelpful = filter == "HELPFUL",
		isNameplateOnly = nil,
		isRaid = nil,
		isStealable = auraToSend.isStealable,
		maxCharges = nil,
		nameplateShowAll = auraToSend.nameplateShowAll,
		nameplateShowPersonal = auraToSend.nameplateShowPersonal,
		points = nil, --	array	Variable returns - Some auras return additional values that typically correspond to something shown in the tooltip, such as the remaining strength of an absorption effect.
		sourceUnit = unitCaster or auraToSend.sourceUnit,
		spellId = auraToSend.spellId,
		timeMod = auraToSend.timeMod
	}

	return newAura
end

local function CreateFakeAura(filter, forEditmode)
	local foundA = Data.FoundAuras[filter]

	local auraTable
	local addDRAura

	if forEditmode then
		return selectRandomAuraFromTable(priorityAuras[filter], filter, forEditmode), selectRandomAuraFromTable(nonPriorityAuras[filter], filter, forEditmode, "player", true, true)
	else

		if filter == "HARMFUL" then
			addDRAura = math_random(1, 5) == 1 -- 20% probability to get diminishing Aura Applied
		end

		local unitCaster, canApplyAura, castByPlayer

		if addDRAura and #foundA.foundDRAuras > 0 then
			auraTable = foundA.foundDRAuras
		else
			local addPlayerAura = math_random(1, 5) == 1 --20% probablility to add a player Aura if no DR was applied
			if addPlayerAura then
				unitCaster = "player"
				canApplyAura = true
				castByPlayer = true

				auraTable = foundA.foundPlayerAuras
			else
				auraTable = foundA.foundNonPlayerAuras
			end
		end
		return selectRandomAuraFromTable(auraTable, filter, forEditmode, unitCaster, canApplyAura, castByPlayer)
	end
end

local drCategorySpells
local function GetAllDrCategorySpells()
	local categories = DRList:GetCategories()
	if drCategorySpells then return drCategorySpells end
	local categorySpells = {}
	local order = 1
	for engCategory, localCategory in pairs(categories) do
		categorySpells[engCategory] = {}

		for spellID, category in DRList:IterateSpellsByCategory(engCategory) do
			local spellName = GetSpellName(spellID)
			if spellName then
				table.insert(categorySpells[engCategory], spellID)
			end
		end
	end
	drCategorySpells = categorySpells
	return categorySpells
end

function BattleGroundEnemies:UpdateDRsEditMode(playerButton)
	local drCatSpells = GetAllDrCategorySpells()
	for categoryName, spellIDs in pairs(drCatSpells) do
		local resetTime = DRList:GetResetTime(categoryName)
		local spellId = spellIDs[math_random(1, #spellIDs)]
		local random = math.random(1,3)
		if random == 1 then
			playerButton:AuraRemoved(spellId, GetSpellName(spellId))
		end
	end
end

function BattleGroundEnemies:UpdateFakeAurasEditmode(playerButton)
	local testmode = BattleGroundEnemies.Testmode
	local fakePlayerAuras = testmode.FakePlayerAuras
	fakePlayerAuras[playerButton] = fakePlayerAuras[playerButton] or {}

	for i = 1, #auraFilters do
		local filter = auraFilters[i]
		fakePlayerAuras[playerButton][filter] = {}

		local createNewAura = not playerButton.isDead
		if createNewAura then
			for j = 1, (4 ) do
				local newFakeAura1, newFakeAura2 = CreateFakeAura(filter, BattleGroundEnemies.states.editmodeActive)
				if newFakeAura1 then
					table_insert(fakePlayerAuras[playerButton][filter], newFakeAura1)
				end
				if newFakeAura2 then
					table_insert(fakePlayerAuras[playerButton][filter], newFakeAura2)
				end
			end
		end
	end
	playerButton:UNIT_AURA()
end

function BattleGroundEnemies:UpdateFakeAurasTestmode(playerButton)
	local currentTime = GetTime()

	local testmode = BattleGroundEnemies.Testmode
	local fakePlayerAuras = testmode.FakePlayerAuras
	local fakePlayerDRs = testmode.FakePlayerDRs
	fakePlayerAuras[playerButton] = fakePlayerAuras[playerButton] or {}

	for i = 1, #auraFilters do
		local filter = auraFilters[i]
		fakePlayerAuras[playerButton][filter] = fakePlayerAuras[playerButton][filter] or {}
		fakePlayerDRs[playerButton] = fakePlayerDRs[playerButton] or {}

		local createNewAura = not playerButton.isDead
		if createNewAura then
			local newFakeAura = CreateFakeAura(filter)
			if newFakeAura then
				local categoryNewAura = DRList:GetCategoryBySpellID(IsClassic and newFakeAura.name or newFakeAura.spellId)

				local dontAddNewAura
				for j = 1, #fakePlayerAuras[playerButton][filter] do
					local fakeAura = fakePlayerAuras[playerButton][filter][j]

					local categoryCurrentAura = DRList:GetCategoryBySpellID(IsClassic and fakeAura.name or
						fakeAura.spellId)

					if categoryCurrentAura and categoryNewAura and categoryCurrentAura == categoryNewAura then
						dontAddNewAura = true
						break
						-- if playerButton.PlayerName == "Enemy2-Realm2" then
						-- 	print("1")
						-- end

						-- end
					elseif fakePlayerDRs[playerButton][categoryNewAura] and fakePlayerDRs[playerButton][categoryNewAura].status then


					elseif newFakeAura.spellId == fakeAura.spellId then
						dontAddNewAura = true --we tried to apply the same spell twice but its not a DR, dont add it, we dont wan't to clutter it
						break
					end

					-- we already are showing this spell, check if this spell is a DR
				end

				local status = fakePlayerDRs[playerButton][categoryNewAura] and
					fakePlayerDRs[playerButton][categoryNewAura].status
				--check if the aura even can be applied, the new aura can only be applied if the expirationTime of the new aura would be later than the current one
				-- this is only the case if the aura is already 50% expired
				if status then
					if status <= 2 then
						local duration = newFakeAura.duration / (2 ^ status)
						newFakeAura.duration = duration
						newFakeAura.expirationTime = currentTime + duration
					else
						dontAddNewAura = true -- we are at full DR and we can't apply the aura for a fourth time
					end
				end

				if not dontAddNewAura then
					table_insert(fakePlayerAuras[playerButton][filter], newFakeAura)
				end
			end
		end

		-- remove all expired auras
		for j = #fakePlayerAuras[playerButton][filter], 1, -1 do
			local fakeAura = fakePlayerAuras[playerButton][filter][j]
			if fakeAura.expirationTime <= currentTime then
				-- if playerButton.PlayerName == "Enemy2-Realm2" then
				-- 	print("1")
				-- end

				--local category = DRList:GetCategoryBySpellID(IsClassic and fakeAura.name or fakeAura.spellId) classic supports spellIds now
				local category = DRList:GetCategoryBySpellID(fakeAura.spellId)
				if category then
					-- if playerButton.PlayerName == "Enemy2-Realm2" then
					-- 	print("2")
					-- end

					fakePlayerDRs[playerButton][category] = fakePlayerDRs[playerButton][category] or {}

					local resetDuration = DRList:GetResetTime(category)
					fakePlayerDRs[playerButton][category].expirationTime = fakeAura.expirationTime + resetDuration
					fakePlayerDRs[playerButton][category].status = (fakePlayerDRs[playerButton][category].status or 0) +
						1
					-- if playerButton.PlayerName == "Enemy2-Realm2" then
					-- 	print("3", FakePlayerDRs[playerButton][category].status)
					-- end
				end

				table_remove(fakePlayerAuras[playerButton][filter], j)
				playerButton:AuraRemoved(fakeAura.spellId, fakeAura.name)
			end
		end
	end



	--set all expired DRs to status 0
	for categoryname, drData in pairs(fakePlayerDRs[playerButton]) do
		if drData.expirationTime and drData.expirationTime <= currentTime then
			drData.status = 0
			drData.expirationTime = nil
		end
	end
	playerButton:UNIT_AURA()
end

function BattleGroundEnemies:GetPlayerCountsFromConfig(playerCountConfig)
	if type(playerCountConfig) ~= "table" then
		error("playerCountConfig must be a table")
	end
	local minPlayers = playerCountConfig.minPlayerCount
	local maxPlayers = playerCountConfig.maxPlayerCount
	return minPlayers, maxPlayers
end

function BattleGroundEnemies:GetPlayerCountConfigNameLocalized(playerCountConfig, isCustom)
	local minPlayers, maxPlayers = self:GetPlayerCountsFromConfig(playerCountConfig)
	return (isCustom and "*" or "") .. minPlayers.."–"..maxPlayers.. " ".. L.players
end

function BattleGroundEnemies:GetPlayerCountConfigName(playerCountConfig)
	local minPlayers, maxPlayers = self:GetPlayerCountsFromConfig(playerCountConfig)
	return minPlayers.."–"..maxPlayers.. " ".. "players"
end

-- returns true if <frame> or one of the frames that <frame> is dependent on is anchored to <otherFrame> and nil otherwise
-- dont ancher to otherframe is
function BattleGroundEnemies:IsFrameDependentOnFrame(frame, otherFrame)
	if frame == nil then
		return false
	end

	if otherFrame == nil then
		return false
	end

	if frame == otherFrame then
		return true
	end

	local points = frame:GetNumPoints()
	for i = 1, points do
		local _, relFrame = frame:GetPoint(i)
		if relFrame and self:IsFrameDependentOnFrame(relFrame, otherFrame) then
			return true
		end
	end
end


--BattleGroundEnemies.EnemyFaction
--BattleGroundEnemies.AllyFaction

--each module can heave one of the different types
--dynamicContainer == the container is only as big as the children its made of, the container sets only 1 point
--buttonHeightLengthVariable = a attachment that has the height of the button and a variable width (the module will set the width itself). when unused sets to 0.01 width
--buttonHeightSquare = a attachment that has the height of the button and the same width, when unused sets to 0.01 width
--HeightAndWidthVariable


function BattleGroundEnemies:IsModuleEnabledOnThisExpansion(moduleName)
	local moduleFrame = self.ButtonModules[moduleName]
	if moduleFrame then
		return moduleFrame.enabledInThisExpansion
	end
	return false
end

local function copySettingsWithoutOverwrite(src, dest)
	if not src or type(src) ~= "table" then return end
	if type(dest) ~= "table" then dest = {} end

	for k, v in pairs(src) do
		if type(v) == "table" then
			dest[k] = copySettingsWithoutOverwrite(v, dest[k])
		elseif type(v) ~= type(dest[k]) then -- only overwrite if the type in dest is different
			dest[k] = v
		end
	end

	return dest
end

local function copyModuleDefaultsIntoDefaults(location, moduleName, moduleDefaults)
	location.ButtonModules = location.ButtonModules or {}
	location.ButtonModules[moduleName] = location.ButtonModules[moduleName] or {}
	copySettingsWithoutOverwrite(moduleDefaults, location.ButtonModules[moduleName])
end

function BattleGroundEnemies:NewButtonModule(moduleSetupTable)
	if type(moduleSetupTable) ~= "table" then return error("Tried to register a Module but the parameter wasn't a table") end
	if not moduleSetupTable.moduleName then return error("NewButtonModule error: No moduleName specified") end
	local moduleName = moduleSetupTable.moduleName
	if not moduleSetupTable.localizedModuleName then
		return error("NewButtonModule error for module: " ..
			moduleName .. " No localizedModuleName specified")
	end
	if moduleSetupTable.enabledInThisExpansion == nil then
		return error("NewButtonModule error for module: " ..
			moduleName .. " enabledInThisExpansion is nil")
	end


	if self.ButtonModules[moduleName] then return error("module " .. moduleName .. " is already registered") end
	local moduleFrame = CreateFrame("Frame", nil, UIParent)

	moduleSetupTable.flags = moduleSetupTable.flags or {}
	Mixin(moduleFrame, moduleSetupTable)


	for k in pairs(self.consts.PlayerTypes) do
		for j = 1, #Data.defaultSettings.profile[k].playerCountConfigs do
			local playerCountConfig = Data.defaultSettings.profile[k].playerCountConfigs[j]
			copyModuleDefaultsIntoDefaults(playerCountConfig, moduleName, moduleSetupTable.defaultSettings)
		end

		local customPlayerCountConfigGeneric =  Data.defaultSettings.profile[k].customPlayerCountConfigs["**"]
		copyModuleDefaultsIntoDefaults(customPlayerCountConfigGeneric, moduleName, moduleSetupTable.defaultSettings)
	end

	if moduleSetupTable.generalDefaults then
		copyModuleDefaultsIntoDefaults(Data.defaultSettings.profile, moduleName, moduleSetupTable.generalDefaults)
	end

	self.ButtonModules[moduleName] = moduleFrame
	return moduleFrame
end

function BattleGroundEnemies:GetBigDebuffsSpellPriority(spellId)
	if not BattleGroundEnemies.db.profile.UseBigDebuffsPriority then return end
	if not BigDebuffs then return end
	local priority = BigDebuffs.GetDebuffPriority and BigDebuffs:GetDebuffPriority(spellId)
	if not priority then return end
	if priority == 0 then return end
	return priority
end

function BattleGroundEnemies:GetSpellPriority(spellId)
	return self:GetBigDebuffsSpellPriority(spellId) or Data.SpellPriorities[spellId]
end

BattleGroundEnemies:SetScript("OnEvent", function(self, event, ...)
	--self.Counter[event] = (self.Counter[event] or 0) + 1
	if self.db and self.db.profile and self.db.profile.DebugBlizzEvents then
		self:Debug("BattleGroundEnemies OnEvent", event, ...)
	end
	self[event](self, ...)
end)
BattleGroundEnemies:Hide()

function BattleGroundEnemies:ShowTooltip(owner, func)
	if self.db.profile.ShowTooltips then
		GameTooltip:SetOwner(owner, "ANCHOR_RIGHT", 0, 0)
		func()
		GameTooltip:Show()
	end
end

function BattleGroundEnemies:GetColoredName(playerButton)
	if not playerButton.PlayerDetails then return end
	local name = playerButton.PlayerDetails.PlayerName
	local tbl = playerButton.PlayerDetails.PlayerClassColor
	return ("|cFF%02x%02x%02x%s|r"):format(tbl.r * 255, tbl.g * 255, tbl.b * 255, name)
end

local function FindAuraBySpellID(unitID, spellId, filter)
	if not unitID or not spellId then return end

	for i = 1, 40 do
		if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
			local aura = C_UnitAuras.GetAuraDataByIndex(unitID, i, filter)
			if aura and aura.spellId == spellId then return i end
		else
			local name, _, amount, debuffType, duration, expirationTime, unitCaster, _, _, id, _, _, _, _, _, value2, value3, value4 = UnitAura(unitID, i, filter)
			if not id then return end -- no more auras

			if spellId == id then
				return i, name, _, amount, debuffType, duration, expirationTime, unitCaster, _, _, id, _, _, _, _, _, value2,
					value3, value4
			end
		end
	end
end

-- for classic, IsClassic
local function FindAuraBySpellName(unitID, spellName, filter)
	if not unitID or not spellName then return end

	for i = 1, 40 do
		local name, _, amount, debuffType, duration, expirationTime, unitCaster, _, _, id, _, _, _, _, _, value2, value3, value4 =
			UnitAura(unitID, i, filter)
		if not name then return end -- no more auras

		if spellName == name then
			return i, name, _, amount, debuffType, duration, expirationTime, unitCaster, _, _, id, _, _, _, _, _, value2,
				value3, value4
		end
	end
end




-- BattleGroundEnemies.Fake_ARENA_OPPONENT_UPDATE()
-- 	BattleGroundEnemies:ARENA_OPPONENT_UPDATE()
-- end

function BattleGroundEnemies:ShowAuraTooltip(playerButton, displayedAura)
	if not displayedAura then return end

	local spellId = displayedAura.spellId
	if not spellId then return end

	local unitID = playerButton:GetUnitID()
	local filter = Data.Helpers.getFilterFromAuraInfo(displayedAura)
	if unitID and filter then
		local index = FindAuraBySpellID(unitID, spellId, filter)
		if index then
			return GameTooltip:SetUnitAura(unitID, index, filter)
		else
			GameTooltip:SetSpellByID(spellId)
		end
	else
		GameTooltip:SetSpellByID(spellId)
	end
end

---@type FunctionContainer
BattleGroundEnemies.FakePlayersUpdateTicker = nil

local function stopFakePlayersTicker()
	if BattleGroundEnemies.FakePlayersUpdateTicker then
		BattleGroundEnemies.FakePlayersUpdateTicker:Cancel()
		BattleGroundEnemies.FakePlayersUpdateTicker = nil
	end
end

local function createFakePlayersTicker(seconds, callback)
	local ticker = CTimerNewTicker(seconds, callback)
	stopFakePlayersTicker()
	BattleGroundEnemies.FakePlayersUpdateTicker = ticker
	return ticker
end



Data.FoundAuras = {
	HELPFUL = {
		foundPlayerAuras = {},
		foundNonPlayerAuras = {},
	},
	HARMFUL = {
		foundPlayerAuras = {},
		foundNonPlayerAuras = {},
		foundDRAuras = {}
	}
}


function BattleGroundEnemies:SetupTestmode()

	if not self.Testmode.RandomRacials then
		self.Testmode.RandomRacials = {}
		for racialSpelliD, data in pairs(Data.RacialSpellIDtoCooldown) do
			local spellExists = GetSpellName(racialSpelliD)

			if spellExists and spellExists ~= "" then
				table.insert(self.Testmode.RandomRacials, racialSpelliD)
			end
		end
	end

	if not self.Testmode.RandomTrinkets then
		self.Testmode.RandomTrinkets = {}
		for triggerSpellID, trinketData in pairs(Data.TrinketData) do
			if type(triggerSpellID) == "string" then --support for classic, IsClassic
				table.insert(self.Testmode.RandomTrinkets, triggerSpellID)
			else
				local spellExists = GetSpellName(triggerSpellID)

				if spellExists and spellExists ~= "" then
					table.insert(self.Testmode.RandomTrinkets, triggerSpellID)
				end
			end
		end
	end

	wipe(self.Testmode.FakePlayerAuras)
	wipe(self.Testmode.FakePlayerDRs)

	local mapIDs = {}
	for mapID, data in pairs(Data.BattlegroundspezificDebuffs) do
		table.insert(mapIDs, mapID)
	end
	local mandomm = math_random(1, #mapIDs)
	local randomMapID = mapIDs[mandomm]

	BattleGroundEnemies.states.test.currentMapId = randomMapID
	BattleGroundEnemies.states.test.isInBattleground = true
	BattleGroundEnemies.states.test.isRatedBG = true

	for i = 1, #auraFilters do
		local filter = auraFilters[i]
		priorityAuras[filter] = {}
		nonPriorityAuras[filter] = {}

		for spellID, spellData in pairs(Data.PriorityAuras[filter]) do
			local spellExists = GetSpellName(spellID)
			if spellExists then
				if BattleGroundEnemies:GetSpellPriority(spellID) then
					table.insert(priorityAuras[filter], spellID)
				else
					table.insert(nonPriorityAuras[filter], spellID)
				end
			end
		end


		local auras = Data.FakeAuras[filter]
		local foundA = Data.FoundAuras[filter]
		if not playerSpells then
			playerSpells = {}
			local playerSpellbook = Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player or 0

			if C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines then
				local numSkillLines = C_SpellBook.GetNumSpellBookSkillLines()
				for j = 1, numSkillLines do
					if GetSpellTabInfo then
						local name, texture, offset, numSpells = GetSpellTabInfo(j)
						for k = 1, numSpells do
							local id = k + offset
							local spellName, _, spelliD = GetSpellBookItemName(id, playerSpellbook)
							if spelliD and IsSpellKnown(spelliD) then
								playerSpells[spelliD] = true
							end
						end
					elseif C_SpellBook and C_SpellBook.GetSpellBookSkillLineInfo then
						local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(j)
						local offset, numSlots = skillLineInfo.itemIndexOffset, skillLineInfo.numSpellBookItems
						for k = offset + 1, offset + numSlots do
							local name, subName = C_SpellBook.GetSpellBookItemName(k, playerSpellbook)
							local spellID = select(2,C_SpellBook.GetSpellBookItemType(k, playerSpellbook))
							if spellID and IsSpellKnown(spellID) then
								playerSpells[spellID] = true
							end
						end
					end
				end
			else
				local numTabs = GetNumSpellTabs()
				for j = 1, numTabs do
					if GetSpellTabInfo then
						local name, texture, offset, numSpells = GetSpellTabInfo(j)
						for k = 1, numSpells do
							local id = k + offset
							local spellName, _, spelliD = GetSpellBookItemName(id, playerSpellbook)
							if spelliD and IsSpellKnown(spelliD) then
								playerSpells[spelliD] = true
							end
						end
					elseif C_SpellBook and C_SpellBook.GetSpellBookSkillLineInfo then
						local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(j)
						local offset, numSlots = skillLineInfo.itemIndexOffset, skillLineInfo.numSpellBookItems
						for k = offset + 1, offset + numSlots do
							local name, subName = C_SpellBook.GetSpellBookItemName(k, playerSpellbook)
							local spellID = select(2,C_SpellBook.GetSpellBookItemType(k, playerSpellbook))
							if spellID and IsSpellKnown(spellID) then
								playerSpells[spellID] = true
							end
						end
					end
				end
			end
		end


		for spellId, auraDetails in pairs(auras) do

			local spellExists = GetSpellName(spellId)

			if spellExists and spellExists ~= "" then
				if filter == "HARMFUL" and DRList:GetCategoryBySpellID(IsClassic and auraDetails.name or spellId) then
					foundA.foundDRAuras[#foundA.foundDRAuras + 1] = auraDetails
				elseif playerSpells[spellId] then
					foundA.foundPlayerAuras[#foundA.foundPlayerAuras + 1] = auraDetails
					-- this buff could be applied from the player
				else
					foundA.foundNonPlayerAuras[#foundA.foundNonPlayerAuras + 1] = auraDetails
				end
			end
		end
	end



	self:CreateFakePlayers()
	self:CheckEnableState()
end

do
	local counter

	function BattleGroundEnemies:FillFakePlayerData(amount, mainFrame, role)
		for i = 1, amount do
			local name, classToken, specName

			if HasSpeccs then
				local randomSpec
				randomSpec = Data.RolesToSpec[role][math_random(1, #Data.RolesToSpec[role])]
				classToken = randomSpec.classToken
				specName = randomSpec.specName
			else
				classToken = Data.ClassList[math_random(1, #Data.ClassList)]
			end
			local nameprefix = mainFrame.PlayerType == self.consts.PlayerTypes.Enemies and "Enemy" or "Ally"
			name = L[nameprefix] .. counter .. "-Realm" .. counter

			mainFrame:AddPlayerToSource(self.consts.PlayerSources.FakePlayers, {
				name = name,
				raceName = nil,
				classToken = classToken,
				specName = specName,
				additionalData = {
					isFakePlayer = true,
					PlayerLevel = i == 1 and MaxLevel or math_random(MaxLevel - 10, MaxLevel - 1)
				}
			})
			counter = counter + 1
		end
	end

	function BattleGroundEnemies:CreateFakePlayers()
		local count = self.Testmode.PlayerCountTestmode or 5

		for number, mainFrame in pairs({ self.Allies, self.Enemies }) do
			local remaining = count
			if mainFrame == self.Allies then
				remaining = remaining - 1
			end
			mainFrame:BeforePlayerSourceUpdate(self.consts.PlayerSources.FakePlayers)

			local healerAmount = math_random(2, 3)
			healerAmount = math_min(healerAmount, remaining)
			remaining = remaining - healerAmount
			local tankAmount = math_random(1)
			tankAmount = math_min(tankAmount, remaining)
			remaining = remaining - tankAmount
			local damagerAmount = remaining

			counter = 1
			BattleGroundEnemies:FillFakePlayerData(healerAmount, mainFrame, "HEALER")
			BattleGroundEnemies:FillFakePlayerData(tankAmount, mainFrame, "TANK")
			BattleGroundEnemies:FillFakePlayerData(damagerAmount, mainFrame, "DAMAGER")

			mainFrame:AfterPlayerSourceUpdate()

			for name, playerButton in pairs(mainFrame.Players) do
				if IsRetail then
					playerButton.Covenant:UpdateCovenant(math_random(1, #Data.CovenantIcons))
				end
			end
		end
	end
end

local function fakePlayersTestmodeTicker()
	for number, mainFrame in pairs({ BattleGroundEnemies.Allies, BattleGroundEnemies.Enemies }) do
		mainFrame:OnTestmodeTick()
	end
end

local function fakePlayersEditmodeTicker()
	for number, mainFrame in pairs({ BattleGroundEnemies.Allies, BattleGroundEnemies.Enemies }) do
		mainFrame:OnEditmodeTick()
	end
end

local function setupFakePlayersEditmodeTicker()
	local lowestDrResetTime
	local drCatSpells = GetAllDrCategorySpells()
	for categoryName, spellIDs in pairs(drCatSpells) do
		local resetTime = DRList:GetResetTime(categoryName)
		if not lowestDrResetTime or resetTime < lowestDrResetTime then
			lowestDrResetTime = resetTime
		end
	end
	createFakePlayersTicker(lowestDrResetTime, fakePlayersEditmodeTicker)
end

local function setupFakePlayersTestmodeTicker()
	createFakePlayersTicker(1, fakePlayersTestmodeTicker)
end

function BattleGroundEnemies.ToggleTestmodeOnUpdate()
	local enabled = not BattleGroundEnemies.FakePlayersUpdateTicker
	if enabled then
		setupFakePlayersTestmodeTicker()
		BattleGroundEnemies:Information(L.FakeEventsEnabled)
	else
		stopFakePlayersTicker()
		BattleGroundEnemies:Information(L.FakeEventsDisabled)
	end
end

function BattleGroundEnemies:EnableTestMode()
	if InCombatLockdown() then
		return BattleGroundEnemies:Information(L.ErrorTestmodeInCombat)
	end
	self.states.testmodeActive = true
	self:SetupTestmode()

	self.Allies:OnTestmodeEnabled()
	self.Enemies:OnTestmodeEnabled()
	self:Information(L.TestmodeEnabled)
end

function BattleGroundEnemies:DisableTestMode()
	self.states.testmodeActive = false
	self:Information(L.TestmodeDisabled)
	self.Allies:OnTestmodeDisabled()
	self.Enemies:OnTestmodeDisabled()
	self:CheckEnableState()
end

function BattleGroundEnemies.ToggleTestmode()
	if BattleGroundEnemies.states.editmodeActive then
		BattleGroundEnemies:DisableEditmode()
	end
	if BattleGroundEnemies.states.testmodeActive then --disable testmode
		BattleGroundEnemies:DisableTestMode()
	else                                     --enable Testmode
		BattleGroundEnemies:EnableTestMode()
	end
end

function BattleGroundEnemies:EnableEditmode()
	if InCombatLockdown() then
		return BattleGroundEnemies:Information(L.ErrorTestmodeInCombat)
	end
	self.states.editmodeActive = true
	self:SetupTestmode()
	self:OnEditmodeEnabled()

	BattleGroundEnemies.EditMode.EditModeManager:OpenEditmode()
	self:Information(L.EditmodeEnabled)
	self:Information(L.EditModeIntroduction)
end

function BattleGroundEnemies:OnEditmodeEnabled()
	self.Allies:OnEditmodeEnabled()
	self.Enemies:OnEditmodeEnabled()
end

function BattleGroundEnemies:DisableEditmode()
	self.states.editmodeActive = false
	self:Information(L.EditmodeDisabled)
	self.Allies:OnEditmodeDisabled()
	self.Enemies:OnEditmodeDisabled()
	BattleGroundEnemies.EditMode.EditModeManager:CloseEditmode()
	self:CheckEnableState()
end

function BattleGroundEnemies.ToggleEditmode()
	if BattleGroundEnemies.states.testmodeActive then
		BattleGroundEnemies:DisableTestMode()
	end
	if BattleGroundEnemies.states.editmodeActive then --disable testmode
		BattleGroundEnemies:DisableEditmode()
	else                                     --enable Testmode
		BattleGroundEnemies:EnableEditmode()
	end
end

function BattleGroundEnemies:DisableTestOrEditmode()
	if self.states.editmodeActive then
		return self:DisableEditmode()
	end
	if self.states.testmodeActive then
		return self:DisableTestMode()
	end
end


local RequestFrame = CreateFrame("Frame", nil, BattleGroundEnemies)
RequestFrame:Hide()
do
	local TimeSinceLastOnUpdate = 0
	local UpdatePeroid = 2                   --update every second
	local function RequestTicker(self, elapsed) --OnUpdate runs if the frame RequestFrame is shown
		TimeSinceLastOnUpdate = TimeSinceLastOnUpdate + elapsed
		if TimeSinceLastOnUpdate > UpdatePeroid then
			RequestBattlefieldScoreData()
			TimeSinceLastOnUpdate = 0
		end
	end
	RequestFrame:SetScript("OnUpdate", RequestTicker)
end



function BattleGroundEnemies:GetDebugFrame()
	if not self.DebugFrame then
		local f = FCF_OpenTemporaryWindow("FILTERED")
		f:SetMaxLines(2500)
		FCF_UnDockFrame(f);
		f:ClearAllPoints();
		f:SetPoint("CENTER", "UIParent", "CENTER", 0, 0);
		FCF_SetTabPosition(f, 0);
		f:Show();
		f.Tab = _G[f:GetName() .. "Tab"]
		f.Tab.conversationIcon:Hide()
		FCF_SetWindowName(f, "BGE_DebugFrame")
		self.DebugFrame = f
	end
	return self.DebugFrame
end

---@type PlayerButton[]
BattleGroundEnemies.ArenaIDToPlayerButton = {} --key = arenaID: arenaX, value = playerButton of that unitID


BattleGroundEnemies:RegisterEvent("PLAYER_LOGIN") --Fired on reload UI and on initial loading screen

BattleGroundEnemies.GeneralEvents = {
	"LOSS_OF_CONTROL_ADDED",
	"LOSS_OF_CONTROL_UPDATE",
	"COMBAT_LOG_EVENT_UNFILTERED",
	"UPDATE_MOUSEOVER_UNIT",
	"PLAYER_TARGET_CHANGED",
	"PLAYER_FOCUS_CHANGED",
	"ARENA_OPPONENT_UPDATE",         --fires when a arena enemy appears and a frame is ready to be shown
	"ARENA_CROWD_CONTROL_SPELL_UPDATE", --fires when data requested by C_PvP.RequestCrowdControlSpell(unitID) is available
	"ARENA_COOLDOWNS_UPDATE",        --fires when a arenaX enemy used a trinket or racial to break cc, C_PvP.GetArenaCrowdControlInfo(unitID) shoudl be called afterwards to get used CCs
	"RAID_TARGET_UPDATE",
	"UNIT_TARGET",
	"UNIT_AURA",
	"UNIT_HEALTH",
	"UNIT_MAXHEALTH",
	"UNIT_POWER_FREQUENT",
	"PLAYER_REGEN_ENABLED"
}

BattleGroundEnemies.RetailEvents = {
	"UNIT_HEAL_PREDICTION",
	"UNIT_ABSORB_AMOUNT_CHANGED",
	"UNIT_HEAL_ABSORB_AMOUNT_CHANGED"
}

BattleGroundEnemies.ClassicEvents = {
	"UNIT_HEALTH_FREQUENT",
}

BattleGroundEnemies.WrathEvents = {
	"UNIT_HEALTH_FREQUENT"
}


function BattleGroundEnemies:RegisterEvents()
	local allEvents = Data.Helpers.JoinArrays(self.GeneralEvents, self.ClassicEvents, self.WrathEvents, self.RetailEvents)
	if C_EventUtils and C_EventUtils.IsEventValid then
		for i = 1, #allEvents do
			local event = allEvents[i]
			if C_EventUtils.IsEventValid(event) then
				self:RegisterEvent(event)
			end
		end
	else
		for i = 1, #self.GeneralEvents do
			self:RegisterEvent(self.GeneralEvents[i])
		end
		if IsClassic then
			for i = 1, #self.ClassicEvents do
				self:RegisterEvent(self.ClassicEvents[i])
			end
		end
		if IsWrath then
			for i = 1, #self.WrathEvents do
				self:RegisterEvent(self.WrathEvents[i])
			end
		end
		if IsRetail then
			for i = 1, #self.RetailEvents do
				self:RegisterEvent(self.RetailEvents[i])
			end
		end
	end
end

function BattleGroundEnemies:UnregisterEvents()
	local allEvents = Data.Helpers.JoinArrays(self.GeneralEvents, self.ClassicEvents, self.WrathEvents, self.RetailEvents)
	for i = 1, #allEvents do
		if self:IsEventRegistered(allEvents[i]) then
			self:UnregisterEvent(allEvents[i])
		end
	end
end

-- if lets say raid1 leaves all remaining players get shifted up, so raid2 is the new raid1, raid 3 gets raid2 etc.



local function EnableShadowColor(fontString, enableShadow, shadowColor)
	if shadowColor then fontString:SetShadowColor(unpack(shadowColor)) end
	if enableShadow then
		fontString:SetShadowOffset(1, -1)
	else
		fontString:SetShadowOffset(0, 0)
	end
end

function BattleGroundEnemies.CropImage(texture, width, height, hasTexcoords)
	local left, right, top, bottom = 0.075, 0.925, 0.075, 0.925
	local ratio = height / width
	if ratio > 1 then --crop the sides
		ratio = 1 / ratio
		texture:SetTexCoord((left) + ((1 - ratio) / 2), right - ((1 - ratio) / 2), top, bottom)
	elseif ratio == 1 then
		texture:SetTexCoord(left, right, top, bottom)
	else
		-- crop the height
		texture:SetTexCoord(left, right, top + ((1 - ratio) / 2), bottom - ((1 - ratio) / 2))
	end
end

local function ApplyFontStringSettings(fs, settings, isCooldown)
	local globals = Mixin({}, BattleGroundEnemies.db.profile.Text)
	if isCooldown then
		globals = Mixin({}, globals, BattleGroundEnemies.db.profile.Cooldown)
	end

	local configTable = Mixin({}, globals, settings)

	fs:SetFont(LSM:Fetch("font", configTable.Font), configTable.FontSize, configTable.FontOutline)


	--idk why, but without this the SetJustifyH and SetJustifyV dont seem to work sometimes even tho GetJustifyH returns the new, correct value
	fs:GetRect()
	fs:GetStringHeight()
	fs:GetStringWidth()

	if configTable.JustifyH then
		fs:SetJustifyH(configTable.JustifyH)
	end

	if configTable.JustifyV then
		fs:SetJustifyV(configTable.JustifyV)
	end

	if configTable.WordWrap ~= nil then
		fs:SetWordWrap(configTable.WordWrap)
	end

	if configTable.FontColor then
		fs:SetTextColor(unpack(configTable.FontColor))
	end

	fs:EnableShadowColor(configTable.EnableShadow, configTable.ShadowColor)
end

local function ApplyCooldownSettings(self, config, cdReverse, swipeColor)
	local configTable = Mixin({}, BattleGroundEnemies.db.profile.Cooldown, config)
	self:SetReverse(cdReverse)
	self:SetDrawSwipe(configTable.DrawSwipe)
	self:SetDrawEdge(configTable.DrawSwipe)
	if swipeColor then self:SetSwipeColor(unpack(swipeColor)) end
	self:SetHideCountdownNumbers(not configTable.ShowNumber)
	if self.Text then
		self.Text:ApplyFontStringSettings(config, true)
	end
end


---comment
---@param parent Frame
function BattleGroundEnemies.MyCreateFontString(parent)
	---@class MyFontString: fontstring
	---@field DisplayedName string
	local fontString = parent:CreateFontString(nil, "OVERLAY")
	fontString.ApplyFontStringSettings = ApplyFontStringSettings
	fontString.EnableShadowColor = EnableShadowColor
	fontString:SetDrawLayer('OVERLAY', 2)
	return fontString
end

---comment
---@param frame cooldown
---@return fontstring?
function BattleGroundEnemies.GrabFontString(frame)
	for _, region in pairs { frame:GetRegions() } do
		if region:GetObjectType() == "FontString" then
			return region
		end
	end
end

function BattleGroundEnemies.AttachCooldownSettings(cooldown)
	cooldown.ApplyCooldownSettings = ApplyCooldownSettings
	-- Find fontstring of the cooldown
	local fontstring = BattleGroundEnemies.GrabFontString(cooldown)
	if fontstring then
		---@class MyFontString
		cooldown.Text = fontstring
		cooldown.Text.ApplyFontStringSettings = ApplyFontStringSettings
		cooldown.Text.EnableShadowColor = EnableShadowColor
	end
end

function BattleGroundEnemies.MyCreateCooldown(parent)
	local cooldown = CreateFrame("Cooldown", nil, parent)
	cooldown:SetAllPoints()
	cooldown:SetSwipeTexture('Interface/Buttons/WHITE8X8')

	BattleGroundEnemies.AttachCooldownSettings(cooldown)

	return cooldown
end

function BattleGroundEnemies:Disable()
	self:Debug("BattleGroundEnemies disabled")
	self.enabled = false
	self:UnregisterEvents()
	self:Hide()
	RequestFrame:Hide()
	stopFakePlayersTicker()
	self.Allies:Disable()
	self.Enemies:Disable()
end

function BattleGroundEnemies:Enable()
	self:Debug("BattleGroundEnemies enabled")
	self.enabled = true

	self:RegisterEvents()
	if BattleGroundEnemies:IsTestmodeOrEditmodeActive() then
		if self.states.editmodeActive then
			setupFakePlayersEditmodeTicker()
		else
			setupFakePlayersTestmodeTicker()
		end
		RequestFrame:Hide()
	else
		RequestFrame:Show()
		stopFakePlayersTicker()
	end
	self:Show()
	self.Allies:CheckEnableState()
	self.Enemies:CheckEnableState()
end

function BattleGroundEnemies:CheckEnableState()
	self:Debug("CheckEnableState")
	local states = BattleGroundEnemies:GetActiveStates()
	if states.isInArena and BattleGroundEnemies.db.profile.ShowBGEInArena then
		return self:Enable()
	end
	if states.isInBattleground and BattleGroundEnemies.db.profile.ShowBGEInBattleground then
		return self:Enable()
	end
	self:Disable()
end


do
	local function PVPMatchScoreboard_OnHide()
		if PVPMatchScoreboard.selectedTab ~= 1 then
			-- user was looking at another tab than all players
			SetBattlefieldScoreFaction() -- request a UPDATE_BATTLEFIELD_SCORE
		end
	end




	--Triggered immediately before PLAYER_ENTERING_WORLD on login and UI Reload, but NOT when entering/leaving instances.
	function BattleGroundEnemies:PLAYER_LOGIN()
		self.UserDetails = {
			PlayerName = UnitName("player"),
			PlayerClass = select(2, UnitClass("player")),
			isGroupLeader = UnitIsGroupLeader("player"),
			isGroupAssistant = UnitIsGroupAssistant("player"),
			unit = "player",
			GUID = UnitGUID("player")
		}

		self.db = LibStub("AceDB-3.0"):New("BattleGroundEnemiesDB", Data.defaultSettings, true)

		self.db.RegisterCallback(self, "OnProfileChanged", "ProfileChanged")
		self.db.RegisterCallback(self, "OnProfileCopied", "ProfileChanged")
		self.db.RegisterCallback(self, "OnProfileReset", "ProfileReset")

		if self.db.profile then
			if self.db.profile.DebugToSV_ResetOnPlayerLogin then
				self.db.profile.log = nil
			end
		end

		BattleGroundEnemies:UpgradeProfiles(self.db)

		BattleGroundEnemies:ApplyAllSettings()

		LibChangelog:Register(AddonName, Data.changelog, self.db.profile, "lastReadVersion", "onlyShowWhenNewVersion")
		LibChangelog:ShowChangelog(AddonName)


		if LGIST then -- the libary doesnt work in TBCC, IsTBCC
			LGIST.RegisterCallback(BattleGroundEnemies.Allies, "GroupInSpecT_Update")

			--GroupInSpecT_Update doesnt fire when in group and nobody is requesting the spec, noticiable when solo and running testmode for example(no spec icon)
			local myCachedSpecInfo = LGIST:GetCachedInfo(self.UserDetails.GUID)
			if myCachedSpecInfo then
				self.specCache[self.UserDetails.GUID] = myCachedSpecInfo.spec_name_localized
			end
		end



		self:RegisterEvent("GROUP_ROSTER_UPDATE") --Fired whenever a group or raid is formed or disbanded, players are leaving or joining the group or raid.
		self:RegisterEvent("PLAYER_ENTERING_WORLD") -- fired on reload UI and on every loading screen (for switching zones, intances etc)
		self:RegisterEvent("PARTY_LEADER_CHANGED") --Fired when the player's leadership changed.
		self:RegisterEvent("PLAYER_ALIVE") --Fired when the player releases from death to a graveyard; or accepts a resurrect before releasing their spirit. Does not fire when the player is alive after being a ghost. PLAYER_UNGHOST is triggered in that case.
		self:RegisterEvent("PLAYER_UNGHOST") --Fired when the player is alive after being a ghost.
		self:RegisterEvent("PLAYER_DEAD") --Fired when the player has died.
		self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")



		self:SetupOptions()

		AceConfigDialog:SetDefaultSize("BattleGroundEnemies", 800, 700)

		AceConfigDialog:AddToBlizOptions("BattleGroundEnemies", "BattleGroundEnemies")

		if PVPMatchScoreboard then -- for TBCC, IsTBCC
			PVPMatchScoreboard:HookScript("OnHide", PVPMatchScoreboard_OnHide)
		end

		--DBObjectLib:ResetProfile(noChildren, noCallbacks)


		self:GROUP_ROSTER_UPDATE() --Scan again, the user could have reloaded the UI so GROUP_ROSTER_UPDATE didnt fire

		self:UnregisterEvent("PLAYER_LOGIN")
	end
end

--Notes about UnitIDs
--priority of unitIDs:
--1. Arena, detected by UNIT_HEALTH (health upate), ARENA_OPPONENT_UPDATE (this units exist, don't exist anymore), we need to check for UnitExists() since there is a small time frame after the objective isn't on that target anymore where UnitExists returns false for that unitID
--2. nameplates, detected by UNIT_HEALTH, NAME_PLATE_UNIT_ADDED, NAME_PLATE_UNIT_REMOVED
--3. player's target
--4. player's focus
--5. ally targets, UNIT_TARGET fires if the target changes, we need to check for UnitExists() since there is a small time frame after an ally lost that enemy where UnitExists returns false for that unitID



function BattleGroundEnemies:NotifyChange()
	AceConfigRegistry:NotifyChange("BattleGroundEnemies")
	self:ProfileChanged()
end

function BattleGroundEnemies:ProfileChanged()
	self:UpgradeProfile(self.db.profile, self.db:GetCurrentProfile())
	self:SetupOptions()
	self:ApplyAllSettings()
end

function BattleGroundEnemies:ProfileReset()
	self:SetCurrentDbVerion(self.db.profile)
	BattleGroundEnemies:NotifyChange()
end

local timer = nil
function BattleGroundEnemies:ApplyAllSettingsDebounce()
	if timer then timer:Cancel() end -- use a timer to apply changes after 0.2 second, this prevents the UI from getting laggy when the user uses a slider option
	timer = CTimerNewTicker(0.2, function()
		BattleGroundEnemies:ApplyAllSettings()
		timer = nil
	end, 1)
end

local playerCountChangedTimer = nil
function BattleGroundEnemies:TestModePlayerCountChanged(value)
	if playerCountChangedTimer then playerCountChangedTimer:Cancel() end -- use a timer to apply changes after 0.2 second, this prevents the UI from getting laggy when the user uses a slider option
	self.Testmode.PlayerCountTestmode = value
	playerCountChangedTimer = CTimerNewTicker(0.2, function()
		if self:IsTestmodeOrEditmodeActive() then
			self:CreateFakePlayers()
		end
		if self.states.editmodeActive then
			self:OnEditmodeEnabled()
			BattleGroundEnemies.EditMode.EditModeManager:OpenEditmode()
		end
		playerCountChangedTimer = nil
	end, 1)
end



function BattleGroundEnemies:ApplyAllSettings()
	BattleGroundEnemies:CheckEnableState()
	BattleGroundEnemies.Allies:SelectPlayerCountProfile(true)
	BattleGroundEnemies.Enemies:SelectPlayerCountProfile(true)
	BattleGroundEnemies:ToggleArenaFrames()
	BattleGroundEnemies:ToggleRaidFrames()
end

local function stringifyMultitArgs(...)
	local args = { ... }
	local text = ""

	for i = 1, #args do
		text = text .. " " .. tostring(args[i])
	end
	return text
end

local function getTimestamp()
	local timestampFormat = "[%I:%M:%S] " --timestamp format
	local stamp = BetterDate(timestampFormat, time())
	return stamp
end

local sentDebugMessages = {}
function BattleGroundEnemies:OnetimeDebug(...)
	local message = table.concat({ ... }, ", ")
	if sentDebugMessages[message] then return end
	sentDebugMessages[message] = true
	self:Debug(...)
end

function BattleGroundEnemies:Debug(...)
	if not self.db then return end
	if not self.db.profile then return end
	if not self.db.profile.Debug then return end

	self:OnetimeInformation("Debugging is enabled. Depending on the amount of messages or debug settings it can cause decrased performance. Please disable it after you are done debugging.")

	if self.db.profile.DebugToChat then
		if not self.DebugFrame then
			self.DebugFrame = self:GetDebugFrame()
		end

		local text
		if self.db.profile.DebugToChat_AddTimestamp then
			text = stringifyMultitArgs(getTimestamp(), ...)
		else
			text = stringifyMultitArgs(...)
		end

		self.DebugFrame:AddMessage(text)
	end

	if self.db.profile.DebugToSV then
		self.db.profile.log = self.db.profile.log or {}
		local t = { ... }

		table.insert(self.db.profile.log, {[getTimestamp()] = t })
	end
end

function BattleGroundEnemies:EnableDebugging()
	self.db.profile.Debug = true
	self:NotifyChange()
end

local sentMessages = {}
function BattleGroundEnemies:OnetimeInformation(...)
	local message = table.concat({ ... }, ", ")
	if sentMessages[message] then return end
	print("|cff0099ffBattleGroundEnemies:|r", message)
	sentMessages[message] = true
end

function BattleGroundEnemies:Information(...)
	print("|cff0099ffBattleGroundEnemies:|r", ...)
end



--fires when a arena enemy appears and a frame is ready to be shown
function BattleGroundEnemies:ARENA_OPPONENT_UPDATE(unitID, unitEvent)
	--unitEvent can be: "seen", "unseen", "destroyed", "cleared"
	self:Debug("ARENA_OPPONENT_UPDATE", unitID, unitEvent, UnitName(unitID))

	if unitEvent == "cleared" then --"unseen", "cleared" or "destroyed"
		local playerButton = self.ArenaIDToPlayerButton[unitID]
		if playerButton then
			self:Debug("ARENA_OPPONENT_UPDATE cleared", playerButton.DisplayedName)

			self.ArenaIDToPlayerButton[unitID] = nil
			playerButton:UpdateEnemyUnitID("Arena", false)
			playerButton:DispatchEvent("ArenaOpponentHidden")
		end
	end
	self:CheckForArenaEnemies()
end

function BattleGroundEnemies:GetPlayerbuttonByUnitID(unitID)
	local uName = GetUnitName(unitID, true)
	return self.Enemies.Players[uName] or self.Allies.Players[uName]
end

function BattleGroundEnemies:GetPlayerbuttonByName(name)
	return self.Enemies.Players[name] or self.Allies.Players[name]
end

function BattleGroundEnemies:GetPlayerbuttonByGUID(GUID)
	local guidData = self.PlayerGUIDs[GUID]
	if not guidData then return end

	return self:GetPlayerbuttonByName(guidData.name)
end

local CombatLogevents = {}
BattleGroundEnemies.CombatLogevents = CombatLogevents

--[[ function CombatLogevents.SPELL_AURA_APPLIED(self, srcName, destName, spellId, spellName, auraType, amount)
	local playerButton = self:GetPlayerbuttonByName(destName)
	if playerButton and playerButton.isShown then
		playerButton:AuraApplied(spellId, spellName, srcName, auraType, amount)
	end
end ]]

-- fires when the stack of a aura increases
--[[ function CombatLogevents.SPELL_AURA_APPLIED_DOSE(self, srcName, destName, spellId, spellName, auraType, amount)
	local playerButton = self:GetPlayerbuttonByName(destName)
	if playerButton and playerButton.isShown then
		playerButton:AuraApplied(spellId, spellName, srcName, auraType, amount)
	end
end ]]
-- fires when the stack of a aura decreases
--[[ function CombatLogevents.SPELL_AURA_REMOVED_DOSE(self, srcName, destName, spellId, spellName, auraType, amount)
	local playerButton = self:GetPlayerbuttonByName(destName)
	if playerButton and playerButton.isShown then
		playerButton:AuraApplied(spellId, spellName, srcName, auraType, amount)
	end
end ]]


function CombatLogevents.SPELL_AURA_REFRESH(self, srcGUID, srcName, destGUID, destName, spellId, spellName, auraType, amount)
	local playerButton = self:GetPlayerbuttonByGUID(destGUID)
	if playerButton then
		playerButton:AuraRemoved(spellId, spellName)
	end
end

function CombatLogevents.SPELL_AURA_REMOVED(self, srcGUID, srcName, destGUID, destName, spellId, spellName, auraType)
	local playerButton = self:GetPlayerbuttonByGUID(destGUID)
	if playerButton then
		playerButton:AuraRemoved(spellId, spellName)
	end
end

--CombatLogevents.SPELL_DISPEL = CombatLogevents.SPELL_AURA_REMOVED

function CombatLogevents.SPELL_CAST_SUCCESS(self, srcGUID, srcName, destGUID, destName, spellId)
	local playerButton
	if srcGUID then
		playerButton = self:GetPlayerbuttonByGUID(srcGUID)
	else
		if srcName then
			playerButton = self:GetPlayerbuttonByName(srcName)
		end
	end
	if playerButton and playerButton.isShown then
		playerButton:DispatchEvent("SPELL_CAST_SUCCESS", srcGUID, srcName, destGUID, destName, spellId)

		local defaultInterruptDuration = Data.Interruptdurations[spellId]
		if defaultInterruptDuration then -- check if enemy got interupted
			if playerButton.unitID then
				if UnitExists(playerButton.unitID) then
					local _, _, _, _, _, _, _, notInterruptible = UnitChannelInfo(playerButton.unitID) --This guy was channeling something and we casted a interrupt on him
					if notInterruptible == false then                                   --spell is interruptable
						playerButton:DispatchEvent("GotInterrupted", spellId, defaultInterruptDuration)
					end
				end
			end
		end
	end
end

function CombatLogevents.SPELL_INTERRUPT(self, srcGUID, srcName, destGUID, destName, spellId, _, _)
	local playerButton = self:GetPlayerbuttonByGUID(destGUID)
	if playerButton and playerButton.isShown then
		local defaultInterruptDuration = Data.Interruptdurations[spellId]
		if defaultInterruptDuration then
			playerButton:DispatchEvent("GotInterrupted", spellId, defaultInterruptDuration)
		end
	end
end

CombatLogevents.Counter = {}
function CombatLogevents.UNIT_DIED(self, srcGUID, srcName, destGUID, destName, _, _, _)
	--self:Debug("subevent", destName, "UNIT_DIED")
	local playerButton = self:GetPlayerbuttonByGUID(destGUID)
	if playerButton then
		playerButton:UpdateHealth(nil, 0, 1)
	end
end

function BattleGroundEnemies:UpdateEnemiesFromCombatlogScanning()
	self.Enemies:BeforePlayerSourceUpdate(self.consts.PlayerSources.CombatLog)
	for guid, data in pairs(self.PlayerGUIDs) do
		if data.IsEnemy then
			--check if its still a enemy, a ally might have joined and we might have gotten a combat log event before that
			if self.Allies.Players[data.name] then
				data.IsEnemy = false
			else
				local scoreInfo
				if C_PvP and C_PvP.GetScoreInfoByPlayerGuid then
					scoreInfo = C_PvP.GetScoreInfoByPlayerGuid(guid)
				end

				-- its still a enemy
				self.Enemies:AddPlayerToSource(self.consts.PlayerSources.CombatLog, {
					name = data.name,
					raceName = data.race,
					classToken = data.classToken,
					specName = scoreInfo and scoreInfo.talentSpec,
				})
			end
		end
	end

	self.Enemies:AfterPlayerSourceUpdate()
end

local UpdateEnemmiesFoundByGUIDTicker = nil
function BattleGroundEnemies:SearchGUIDForPlayers(GUID)
	if not GUID then return end
	if GUID == "" then return end
	if self.SearchedGUIDs[GUID] then return end

	self.SearchedGUIDs[GUID] = true

	if self.PlayerGUIDs[GUID] then return end



	local localizedClass, englishClass, localizedRace, englishRace, sex, name, realm = GetPlayerInfoByGUID(GUID)

	if not localizedClass then return end -- see if its a player, it GetPlayerInfoByGUID doens't return anythng its not a player

	if realm and realm ~= "" then
		name = name .. "-" .. realm
	end
	local ambiguatedName = Ambiguate(name, "none")
	local isEnemy = false

	self.PlayerGUIDs[GUID] = {
		name = ambiguatedName,
		race = localizedRace,
		classToken = englishClass,
	}

	--[[ 		
	local scoreInfo = C_PvP.GetScoreInfoByPlayerGuid(GUID)
	if scoreInfo and type(scoreInfo) =="table" then
		if scoreInfo.faction ~= myBGFaction then
			isEnemy = true
			self.PlayerGUIDs[GUID].spec = scoreInfo.talentSpec
		end
	else
		if not self.Allies[ambiguatedName] then
			isEnemy = true
		end
	end ]]
	if not self.Allies.Players[ambiguatedName] then
		self.PlayerGUIDs[GUID].IsEnemy = true
		if UpdateEnemmiesFoundByGUIDTicker then UpdateEnemmiesFoundByGUIDTicker:Cancel() end -- use a timer to apply changes after 1 second, this prevents from too many updates after each player is found

		UpdateEnemmiesFoundByGUIDTicker = CTimerNewTicker(1, function()
			BattleGroundEnemies:UpdateEnemiesFromCombatlogScanning()
			UpdateEnemmiesFoundByGUIDTicker = nil
		end, 1)
	end
end


function BattleGroundEnemies:COMBAT_LOG_EVENT_UNFILTERED()
	local timestamp, subevent, hide, srcGUID, srcName, srcF1, srcF2, destGUID, destName, destF1, destF2, spellId, spellName, spellSchool, auraType = CombatLogGetCurrentEventInfo()
	self:SearchGUIDForPlayers(srcGUID)
	self:SearchGUIDForPlayers(destGUID)

	--self:Debug(timestamp,subevent,hide,srcGUID,srcName,srcF1,srcF2,destGUID,destName,destF1,destF2,spellId,spellName,spellSchool, auraType)
	local covenantID = Data.CovenantSpells[spellId]
	if covenantID then
		local playerButton = self:GetPlayerbuttonByGUID(srcGUID)
		if playerButton then
			-- this player used a covenant ability show an icon for that
			playerButton.Covenant:UpdateCovenant(covenantID)
		end
	end
	if CombatLogevents[subevent] then
		-- IsClassic: spellId is always 0, so we have to work with the spellname :( but at least UnitAura() shows spellIDs
		--CombatLogevents.Counter[subevent] = (CombatLogevents.Counter[subevent] or 0) + 1
		return CombatLogevents[subevent](self, srcGUID, srcName, destGUID, destName, spellId, spellName, auraType)
	end
end

local function IamTargetcaller()
	if BattleGroundEnemies.UserDetails.isGroupLeader then
		return #BattleGroundEnemies.Allies.assistants == 0
	else
		return BattleGroundEnemies.UserDetails.isGroupAssistant
	end
end

function BattleGroundEnemies:HandleTargetChanged(newTarget)
	self:Debug("playerButton target", GetUnitName("target", true))
	if BattleGroundEnemies.currentTarget then

		BattleGroundEnemies.currentTarget:UpdateEnemyUnitID("Target", false)

		if self.UserButton then
			self.UserButton:IsNoLongerTarging(BattleGroundEnemies.currentTarget)
		end
		BattleGroundEnemies.currentTarget.MyTarget:Hide()
	end

	if newTarget then --i target an existing player
		if self.UserButton then

			newTarget:UpdateEnemyUnitID("Target", "target")

			self.UserButton:IsNowTargeting(newTarget)
		end
		newTarget.MyTarget:Show()
		BattleGroundEnemies.currentTarget = newTarget


		if BattleGroundEnemies.states.real.isRatedBG and self.db.profile.RBG.TargetCalling_SetMark and IamTargetcaller() then -- i am the target caller
			SetRaidTarget("target", 8)
		end
	else
		BattleGroundEnemies.currentTarget = false
	end
end

function BattleGroundEnemies:PLAYER_TARGET_CHANGED()
	self:HandleTargetChanged(self:GetPlayerbuttonByUnitID("target"))
end

function BattleGroundEnemies:HandleFocusChanged(newFocus)

	--self:Debug("playerButton focus", playerButton, GetUnitName("focus", true))
	if BattleGroundEnemies.currentFocus then

		BattleGroundEnemies.currentFocus:UpdateEnemyUnitID("Focus", false)

		BattleGroundEnemies.currentFocus.MyFocus:Hide()
	end
	if newFocus then

		newFocus:UpdateEnemyUnitID("Focus", "focus")

		newFocus.MyFocus:Show()
		BattleGroundEnemies.currentFocus = newFocus
	else
		BattleGroundEnemies.currentFocus = false
	end
end

function BattleGroundEnemies:PLAYER_FOCUS_CHANGED()
	self:HandleFocusChanged(self:GetPlayerbuttonByUnitID("focus"))
end



function BattleGroundEnemies:UPDATE_MOUSEOVER_UNIT()
	local enemyButton = self.Enemies:GetPlayerbuttonByUnitID("mouseover")
	if enemyButton then --unit is a shown enemy
		enemyButton:UpdateAll("mouseover")
	end
end

function BattleGroundEnemies:LOSS_OF_CONTROL_ADDED(unitTarget, effectIndex)
	self:Debug("LOSS_OF_CONTROL_ADDED", unitTarget, effectIndex)
	local numLossOfControlEffects = C_LossOfControl.GetActiveLossOfControlDataCountByUnit(unitTarget) or 0;
	for i = 1, numLossOfControlEffects do
		local data = C_LossOfControl.GetActiveLossOfControlDataByUnit(unitTarget, i);
		if data then
			if not self.db.profile.Debug then return end
			self.db.profile.LossOfControlData = self.db.profile.LossOfControlData or {}
			if not self.db.profile.LossOfControlData[data.spellID] then
				self.db.profile.LossOfControlData[data.spellID] = CopyTable(data)
			end
		end
	end
end

BattleGroundEnemies.LOSS_OF_CONTROL_UPDATE = BattleGroundEnemies.LOSS_OF_CONTROL_ADDED


--fires when data requested by C_PvP.RequestCrowdControlSpell(unitID) is available
function BattleGroundEnemies:ARENA_CROWD_CONTROL_SPELL_UPDATE(unitID, ...)
	local playerButton = self:GetPlayerbuttonByUnitID(unitID)
	if not playerButton then playerButton = self:GetPlayerbuttonByName(unitID) end -- the event fires before the name is set on the frame, so at this point the name is still the unitID
	if playerButton then
		local spellId, itemID = ...                                             --itemID only exists in classic, tbc, wrath isClassic, isTBCC, IsWrath
		playerButton.Trinket:DisplayTrinket(spellId, itemID)
		playerButton:UpdateCrowdControlCooldown(unitID)
	end

	--if spellId ~= 72757 then --cogwheel (30 sec cooldown trigger by racial)
	--end
end

--fires when a arenaX enemy used a trinket or racial to break cc, C_PvP.GetArenaCrowdControlInfo(unitID) shoudl be called afterwards to get used CCs
--this event is kinda stupid, it doesn't say which unit used which cooldown, it justs says that somebody used some sort of trinket
function BattleGroundEnemies:ARENA_COOLDOWNS_UPDATE(unitID)
	if unitID then
		local playerButton = self:GetPlayerbuttonByUnitID(unitID)
		if playerButton then
			playerButton:UpdateCrowdControlCooldown(unitID)
		end
	else --for backwards compability, i am not sure if unitID was always given by ARENA_COOLDOWNS_UPDATE
		for i = 1, 5 do
			unitID = "arena" .. i
			local playerButton = self:GetPlayerbuttonByUnitID(unitID)
			if playerButton then
				playerButton:UpdateCrowdControlCooldown(unitID)
			end
		end
	end
end

function BattleGroundEnemies:RAID_TARGET_UPDATE()
	for name, playerButton in pairs(self.Allies.Players) do
		playerButton:UpdateRaidTargetIcon()
	end
	for name, playerButton in pairs(self.Enemies.Players) do
		playerButton:UpdateRaidTargetIcon()
	end
end

function BattleGroundEnemies:UNIT_AURA(unitID, isFullUpdate, updatedAuraInfos)
	local playerButton = self:GetPlayerbuttonByUnitID(unitID)
	if playerButton then
		playerButton:UNIT_AURA(unitID, isFullUpdate, updatedAuraInfos)
	end
end

function BattleGroundEnemies:UNIT_HEALTH(unitID) --gets health of nameplates, player, target, focus, raid1 to raid40, partymember
	local playerButton = self:GetPlayerbuttonByUnitID(unitID)
	if playerButton then                         --unit is a shown player
		playerButton:UNIT_HEALTH(unitID)
	end
end

BattleGroundEnemies.UNIT_HEALTH_FREQUENT = BattleGroundEnemies
	.UNIT_HEALTH --used to be used only in tbc, now its only used in classic and wrath
BattleGroundEnemies.UNIT_MAXHEALTH = BattleGroundEnemies.UNIT_HEALTH
BattleGroundEnemies.UNIT_HEAL_PREDICTION = BattleGroundEnemies.UNIT_HEALTH
BattleGroundEnemies.UNIT_ABSORB_AMOUNT_CHANGED = BattleGroundEnemies.UNIT_HEALTH
BattleGroundEnemies.UNIT_HEAL_ABSORB_AMOUNT_CHANGED = BattleGroundEnemies.UNIT_HEALTH


function BattleGroundEnemies:UNIT_POWER_FREQUENT(unitID, powerToken) --gets power of nameplates, player, target, focus, raid1 to raid40, partymember
	local playerButton = self:GetPlayerbuttonByUnitID(unitID)
	if playerButton then                                             --unit is a shown enemy
		playerButton:UNIT_POWER_FREQUENT(unitID, powerToken)
	end
end

BattleGroundEnemies.PendingUpdates = {}
function BattleGroundEnemies:QueueForUpdateAfterCombat(tbl, funcName)
	--dont add the same function twice
	for i = 1, #BattleGroundEnemies.PendingUpdates do
		local pendingUpdate = BattleGroundEnemies.PendingUpdates[i]
		if pendingUpdate.tbl == tbl and pendingUpdate.funcName == funcName then return end
	end

	table.insert(self.PendingUpdates, { tbl = tbl, funcName = funcName })
end

function BattleGroundEnemies:PLAYER_REGEN_ENABLED()
	--Check if there are any outstanding updates that have been hold back due to being in combat
	for i = 1, #self.PendingUpdates do
		local tbl = self.PendingUpdates[i].tbl
		local funcName = self.PendingUpdates[i].funcName
		tbl[funcName](tbl)
	end
	wipe(self.PendingUpdates)
end

function BattleGroundEnemies:PlayerDead()
	self.states.userIsAlive = false
end

function BattleGroundEnemies:PlayerAlive()
	--recheck the targets of groupmembers
	for allyName, allyButton in pairs(self.Allies.Players) do
		allyButton:UpdateTarget()
	end
	self.states.userIsAlive = true
end

function BattleGroundEnemies:PLAYER_ALIVE()
	if UnitIsGhost("player") then --Releases his ghost to a graveyard.
		self:PlayerDead()
	else                       --alive (revived while not being a ghost)
		self:PlayerAlive()
	end
end

function BattleGroundEnemies:PLAYER_DEAD()
	self:PlayerDead()
end

function BattleGroundEnemies:UNIT_TARGET(unitID)
	local playerButton = self:GetPlayerbuttonByUnitID(unitID)


	if playerButton and playerButton ~= self.UserButton then --we use Player_target_changed for the player
		--self:Debug("UNIT_TARGET", unitID, playerButton.PlayerDetails.PlayerName)
		playerButton:UpdateTarget()
	end
end

local function changeVisibility(frame, visible)
	if visible then
		frame:SetAlpha(1)
		frame:SetScale(1)
	else
		frame:SetAlpha(0)
		frame:SetScale(0.001)
	end
end

local function disableArenaFrames()
	if ArenaEnemyFrames then
		if ArenaEnemyFrames_Disable then
			ArenaEnemyFrames_Disable(ArenaEnemyFrames)
		end
	elseif ArenaEnemyFramesContainer then
		changeVisibility(ArenaEnemyFramesContainer, false)
	end
	if CompactArenaFrame then
		changeVisibility(CompactArenaFrame, false)
	end
end

local function checkEffectiveEnableStateForArenaFrames()
	if ArenaEnemyFrames then
		if ArenaEnemyFrames_CheckEffectiveEnableState then
			ArenaEnemyFrames_CheckEffectiveEnableState(ArenaEnemyFrames)
		end
	elseif ArenaEnemyFramesContainer then
		changeVisibility(ArenaEnemyFramesContainer, true)
	end
	if CompactArenaFrame then
		changeVisibility(CompactArenaFrame, true)
	end
end

function BattleGroundEnemies:ResetCombatLogScanniningTables()
	self.SearchedGUIDs = {}
	self.PlayerGUIDs = {}
end

function BattleGroundEnemies:ToggleArenaFrames()
	if InCombatLockdown() then return self:QueueForUpdateAfterCombat(self, "ToggleArenaFrames") end
	if (BattleGroundEnemies.states.real.isInArena and self.db.profile.DisableArenaFramesInArena) or (BattleGroundEnemies.states.real.isInBattleground and self.db.profile.DisableArenaFramesInBattleground) then return disableArenaFrames() end

	checkEffectiveEnableStateForArenaFrames()
end

local function restoreShowRaidFrameCVar()
	if not previousCvarRaidOptionIsShown then return end --we didn't modify it so no need to restore it
	SetCVar("raidOptionIsShown", previousCvarRaidOptionIsShown)
end

local function disableRaidFrames()
	if previousCvarRaidOptionIsShown == nil then
		previousCvarRaidOptionIsShown =  GetCVar("raidOptionIsShown")
	end
	SetCVar("raidOptionIsShown", false)
end

function BattleGroundEnemies:ToggleRaidFrames()
	if (BattleGroundEnemies.states.real.isInArena and self.db.profile.DisableRaidFramesInArena) or (BattleGroundEnemies.states.real.isInBattleground and self.db.profile.DisableRaidFramesInBattleground) then return disableRaidFrames() end

	restoreShowRaidFrameCVar()
end



function BattleGroundEnemies:UpdateArenaPlayers()
	self:Debug("UpdateArenaPlayers")
	self.Enemies:CreateArenaEnemies()

	if #BattleGroundEnemies.Enemies.CurrentPlayerOrder > 0 or #BattleGroundEnemies.Allies.CurrentPlayerOrder > 0 then --this ensures that we checked for enemies and the flag carrier will be shown (if its an enemy)
		for i = 1, GetNumArenaOpponents() do
			local unitID = "arena" .. i
			self:Debug(unitID, UnitName(unitID))
			local playerButton = BattleGroundEnemies:GetPlayerbuttonByUnitID(unitID)
			if playerButton then
				self:Debug("Button exists for", unitID)
				playerButton:ArenaOpponentShown(unitID)
			end
		end
	else
		C_Timer.After(2, function() self:UpdateArenaPlayers() end)
	end
end


local UpdateArenaPlayersTicker

--too avoid calling UpdateArenaPlayers too many times within a second
function BattleGroundEnemies:DebounceUpdateArenaPlayers()
	self:Debug("DebounceUpdateArenaPlayers")
	if UpdateArenaPlayersTicker then UpdateArenaPlayersTicker:Cancel() end -- use a timer to apply changes after half second, this prevents from too many updates after each player is found

	if not self.states.real.isInArena and not self.states.real.isInBattleground then return end
	UpdateArenaPlayersTicker = CTimerNewTicker(0.5, function()
		BattleGroundEnemies:UpdateArenaPlayers()
		UpdateArenaPlayersTicker = nil
	end, 1)
end



function BattleGroundEnemies:CheckForArenaEnemies()
	self:Debug("CheckForArenaEnemies")

	-- returns valid data on PLAYER_ENTERING_WORLD
	self:Debug(GetNumArenaOpponents())
	if GetNumArenaOpponents() == 0 then
		C_Timer.After(2, function() self:DebounceUpdateArenaPlayers() end)
	else
		self:DebounceUpdateArenaPlayers()
	end
end

BattleGroundEnemies.PLAYER_UNGHOST = BattleGroundEnemies.PlayerAlive --player is alive again


function BattleGroundEnemies:GetBuffsAndDebuffsForMap(mapId)
	if not mapId then return end
	return Data.BattlegroundspezificBuffs[mapId], Data.BattlegroundspezificDebuffs[mapId]
end


function BattleGroundEnemies:UpdateMapID(retries)
	retries = retries or 0
	--	SetMapToCurrentZone() apparently removed in 8.0
	local mapId = GetBestMapForUnit('player')
	self:Debug("UpdateMapID")

	if mapId and mapId ~= -1 and mapId ~= 0 then -- when this values occur the map ID is not real
		self.states.real.currentMapId = mapId
	else
		self.states.real.currentMapId = false
		if retries > 5 then return end
		C_Timer.After(2, function() --Delay this check, since its happening sometimes that this data is not ready yet
			self:UpdateMapID(retries + 1)
		end)
	end
end

local function parseBattlefieldScore(index)
	BattleGroundEnemies:Debug("parseBattlefieldScore", index)
	local result
	if C_PvP and C_PvP.GetScoreInfo then
		local scoreInfo = C_PvP.GetScoreInfo(index)

		--[[
		info
			PVPScoreInfo?
			Key	Type	Description
			name	string
			guid	string
			killingBlows	number
			honorableKills	number
			deaths	number
			honorGained	number
			faction	number
			raceName	string
			className	string
			classToken	string
			damageDone	number
			healingDone	number
			rating	number
			ratingChange	number
			prematchMMR	number
			mmrChange	number
			talentSpec	string
			honorLevel	number
			roleAssigned	number
			stats	PVPStatInfo[]


			PVPStatInfo
			Key	Type	Description
			pvpStatID	number
			pvpStatValue	number
			orderIndex	number
			name	string
			tooltip	string
			iconName	string

 		]]
		if not scoreInfo then return end
		if not type(scoreInfo) == "table" then return end
		result = scoreInfo
	else
		local _, name, faction, race, classToken, specName
		if HasSpeccs then
			BattleGroundEnemies:Debug("HasSpeccs")
			--name, killingBlows, honorableKills, deaths, honorGained, faction, rank, race, class, classToken, damageDone, healingDone = GetBattlefieldScore(index)
			name, _, _, _, _, faction, race, _, classToken, _, _, _, _, _, _, specName = GetBattlefieldScore(index)
		else
			name, _, _, _, _, faction, _, race, _, classToken = GetBattlefieldScore(index)
		end
		result = {
			name = name,
			faction = faction,
			raceName = race,
			classToken = classToken,
			talentSpec = specName
		}
	end
	return result
end

function BattleGroundEnemies:SetAllyFaction(allyFaction)
	self:Debug("SetAllyFaction", allyFaction)
	self.EnemyFaction = allyFaction == 0 and 1 or 0
	self.AllyFaction = allyFaction
end



function BattleGroundEnemies:UPDATE_BATTLEFIELD_SCORE()
	self:Debug("UPDATE_BATTLEFIELD_SCORE")
	-- self:Debug(GetCurrentMapAreaID())
	-- self:Debug("UPDATE_BATTLEFIELD_SCORE")
	-- self:Debug("GetBattlefieldArenaFaction", GetBattlefieldArenaFaction())
	-- self:Debug("C_PvP.IsInBrawl", C_PvP.IsInBrawl())
	-- self:Debug("GetCurrentMapAreaID", GetCurrentMapAreaID())
	-- self:Debug("horde players:", GetBattlefieldTeamInfo(0))
	-- self:Debug("alliance players:", GetBattlefieldTeamInfo(1))

	--self:Debug("IsRatedBG", IsRatedBG)

	self:SetAllyFaction(self.AllyFaction or 0) --set fallback value

	local _, _, _, _, numEnemies = GetBattlefieldTeamInfo(self.EnemyFaction)
	local _, _, _, _, numAllies = GetBattlefieldTeamInfo(self.AllyFaction)

	self:Debug("numEnemies:", numEnemies)
	self:Debug("numAllies:", numAllies)

	if numEnemies then
		self.Enemies:SetRealPlayerCount(numEnemies)
	end

	if numAllies then
		self.Allies:SetRealPlayerCount(numAllies)
	end

	local battlefieldScores = {}
	local numScores = GetNumBattlefieldScores()
	self:Debug("numScores", numScores)
	for i = 1, numScores do
		local score = parseBattlefieldScore(i)
		if score then
			table.insert(battlefieldScores, score)
		end
	end

	self:Debug("battlefieldScores", battlefieldScores)

	--see if our faciton in BG changed
	for i = 1, #battlefieldScores do
		local score = battlefieldScores[i]
		local name = score.name
		local faction = score.faction

		if name == self.UserDetails.PlayerName and faction == self.EnemyFaction then
			self:SetAllyFaction(self.EnemyFaction)
		end
	end

	BattleGroundEnemies.Enemies:BeforePlayerSourceUpdate(self.consts.PlayerSources.Scoreboard)
	BattleGroundEnemies.Allies:BeforePlayerSourceUpdate(self.consts.PlayerSources.Scoreboard)

	for i = 1, #battlefieldScores do
		local score = battlefieldScores[i]

		local faction = score.faction
		local name = score.name
		local classToken = score.classToken

		local t
		if faction and name and classToken then
			if faction == self.EnemyFaction then
				t = BattleGroundEnemies.Enemies
			else
				t = BattleGroundEnemies.Allies
			end
			t:AddPlayerToSource(self.consts.PlayerSources.Scoreboard, score)
		end
	end
	BattleGroundEnemies.Enemies:AfterPlayerSourceUpdate()
	BattleGroundEnemies.Allies:AfterPlayerSourceUpdate()
end



function BattleGroundEnemies:GROUP_ROSTER_UPDATE()
	self.Allies:BeforePlayerSourceUpdate(self.consts.PlayerSources.GroupMembers)
	self.Allies.groupLeader = nil
	self.Allies.assistants = {}

	--IsInGroup returns true when user is in a Raid and In a 5 man group

	self:RequestEverythingFromGroupmembers()

	-- GetRaidRosterInfo also works when in a party (not raid) but i am not 100% sure how the party unitID maps to the index in GetRaidRosterInfo()

	local numGroupMembers = GetNumGroupMembers()
	self.Allies:SetRealPlayerCount(numGroupMembers)

	if IsInRaid() then
		for i = 1, numGroupMembers do -- the player itself only shows up here when he is in a raid
			local name, rank, subgroup, level, localizedClass, classToken, zone, online, isDead, role, isML, combatRole =
				GetRaidRosterInfo(i)

			if name and name ~= self.UserDetails.PlayerName and rank and classToken then
				self.Allies:AddGroupMember(name, rank == 2, rank == 1, classToken, "raid" .. i)
			end
		end
	else
		-- we are in a party, 5 man group
		for i = 1, numGroupMembers do
			local unitID = "party" .. i
			local name = GetUnitName(unitID, true)

			local classToken = select(2, UnitClass(unitID))

			if name and classToken then
				self.Allies:AddGroupMember(name, UnitIsGroupLeader(unitID), UnitIsGroupAssistant(unitID), classToken,
					unitID)
			end
		end
	end

	self.UserDetails.isGroupLeader = UnitIsGroupLeader("player")
	self.UserDetails.isGroupAssistant = UnitIsGroupAssistant("player")
	self.Allies:AddGroupMember(self.UserDetails.PlayerName, self.UserDetails.isGroupLeader,
		self.UserDetails.isGroupAssistant, self.UserDetails.PlayerClass, "player")
	self.Allies:AfterPlayerSourceUpdate()
	self.Allies:UpdateAllUnitIDs()
end

BattleGroundEnemies.PARTY_LEADER_CHANGED = BattleGroundEnemies.GROUP_ROSTER_UPDATE




--Fires when the player logs in, /reloads the UI or zones between map instances. Basically whenever the loading screen appears.
function BattleGroundEnemies:PLAYER_ENTERING_WORLD()
	self:Debug("PLAYER_ENTERING_WORLD")
	self:ResetCombatLogScanniningTables()
	self:DisableTestOrEditmode()


	self.Enemies:RemoveAllPlayersFromAllSources()
	self.Allies:RemoveAllPlayersFromSource(self.consts.PlayerSources.Scoreboard)
	local _, zone = IsInInstance()
	self:Debug("zone", zone)
	if zone == "pvp" or zone == "arena" then
		if GetBattlefieldArenaFaction then
			self:SetAllyFaction(GetBattlefieldArenaFaction()) -- returns the playered faction 0 for horde, 1 for alliance, doesnt exist in TBC)
		else
			self:SetAllyFaction(1) -- set a dummy value, we get data later from GetBattlefieldScore()
		end

		if zone == "arena" then
			BattleGroundEnemies.states.real.isInArena = true
		else
			BattleGroundEnemies.states.real.isInBattleground = true

			C_Timer.After(5,
				function()        --Delay this check, since its happening sometimes that this data is not ready yet
					if C_PvP then
						self.states.real.isRatedBG = C_PvP.IsRatedBattleground()
						self.states.real.isSoloRBG = C_PvP.IsSoloRBG()
					else
						self.states.real.isRatedBG = not not (IsRatedBattleground and IsRatedBattleground())
						self.states.real.isSoloRBG = false
					end

					self:UPDATE_BATTLEFIELD_SCORE() --trigger the function again because since 10.0.0 UPDATE_BATTLEFIELD_SCORE doesnt fire reguralry anymore and RequestBattlefieldScore doesnt trigger the event
				end)
		end
	else
		self.states.real.isInArena = false
		self.states.real.isInBattleground = false
		self.states.real.isSoloRBG = false
		self.states.real.isRatedBG = false
	end

	self:CheckEnableState()
	self:UpdateMapID()
	self:ToggleArenaFrames()
	self:ToggleRaidFrames()
end
