---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)

---@class BattleGroundEnemies
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L

--WoW API
local pairs = pairs
local type = type

local CreateFrame = CreateFrame
local GetArenaOpponentSpec = GetArenaOpponentSpec
local GetSpecializationInfoByID = GetSpecializationInfoByID
local GetUnitName = GetUnitName
local InCombatLockdown = InCombatLockdown
local UnitGUID = UnitGUID
local UnitRace = UnitRace

--lua
local math_floor = math.floor
local math_max = math.max
local math_min = math.min
local math_random = math.random
local table_insert = table.insert
local table_remove = table.remove

local HasSpeccs = not not GetSpecialization

--Libs
local LibRaces = LibStub("LibRaces-1.0")



local IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local IsTBCC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local IsWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC


--[[  from wowpedia
1	IconSmall RaidStar.png 		Yellow 4-point Star
2	IconSmall RaidCircle.png 	Orange Circle
3	IconSmall RaidDiamond.png 	Purple Diamond
4	IconSmall RaidTriangle.png 	Green Triangle
5	IconSmall RaidMoon.png 		White Crescent Moon
6	IconSmall RaidSquare.png 	Blue Square
7	IconSmall RaidCross.png 	Red "X" Cross
8	IconSmall RaidSkull.png 	White Skull
 ]]


local testEvents = {
	---@param mainFrame MainFrame
	function(mainFrame, playerButton)
		if playerButton.isDead then return end

		-- hide old flag carrier
		local oldFlagholder = mainFrame.Testmode.holdsFlag
		if oldFlagholder then
			oldFlagholder:DispatchEvent("ArenaOpponentHidden")
		end

		playerButton:ArenaOpponentShown()

		mainFrame.Testmode.holdsFlag = playerButton
		mainFrame.Testmode.hasFlag = true
	end,
	---@param mainFrame MainFrame
	function(mainFrame, playerButton)
		if playerButton.isDead then return end
		BattleGroundEnemies.CombatLogevents.SPELL_CAST_SUCCESS(BattleGroundEnemies, nil,
			playerButton.PlayerDetails.PlayerName, nil, nil,
			BattleGroundEnemies.Testmode.RandomRacials[math_random(1, #BattleGroundEnemies.Testmode.RandomRacials)])
	end,
	---@param mainFrame MainFrame
	function(mainFrame, playerButton)
		if playerButton.isDead then return end
		BattleGroundEnemies.CombatLogevents.SPELL_CAST_SUCCESS(BattleGroundEnemies, nil,
			playerButton.PlayerDetails.PlayerName, nil, nil,
			BattleGroundEnemies.Testmode.RandomTrinkets[math_random(1, #BattleGroundEnemies.Testmode.RandomTrinkets)])
	end,
	---@param mainFrame MainFrame
	function (mainFrame, playerButton)
		playerButton:UNIT_POWER_FREQUENT()
		if playerButton.isDead then return end
	end,
	---@param mainFrame MainFrame
	function (mainFrame, playerButton)
		playerButton:UNIT_HEALTH()
	end,
	---@param mainFrame MainFrame
	function(mainFrame, playerButton)
		if playerButton.Target then
			playerButton:IsNoLongerTarging(playerButton.Target)
		end

		local oppositeMainFrame = playerButton:GetOppositeMainFrame()
		if oppositeMainFrame then --this really should never be nil
			local randomPlayer = oppositeMainFrame:GetRandomPlayer()

			if randomPlayer then
				playerButton:IsNowTargeting(randomPlayer)
			end
		end
	end,
	---@param mainFrame MainFrame
	function(mainFrame, playerButton)
		playerButton:UpdateRaidTargetIcon(math_random(1, 8))
	end,
	function (mainFrame, playerButton)
		playerButton:UpdateRange(not playerButton.wasInRange)
	end
}

---@class MainFrame : Button
---@field Players table<string, PlayerButton>
---@field CurrentPlayerOrder table<number, PlayerButton>
---@field InactivePlayerButtons table<number, PlayerButton>
---@field NewPlayersDetails table<number, table>
---@field PlayerType string
---@field PlayerSources table<string, table>
---@field NumPlayers number
---@field Counter table<string, number>
---@field PlayerCount FontString
---@field ActiveProfile FontString
---@return MainFrame
local function CreateMainFrame(playerType)

    --binding voodoo
    -- how it works:
    -- SecureHandlerEnterLeaveTemplate is necessary to add the secure onenter and onleave event handlers
    -- the handler then sets the wheeldown and wheelup binding to execute a button click using the global button names
    -- when mouswheel is scrolled up or down it triggers a button click and runs the onclick kook from SecureHandlerWrapScript gets execute, which then sets the macrotext

    ---@class MainFrame :Button
	local mainframe = CreateFrame("Button","BGE"..playerType,BattleGroundEnemies,"SecureActionButtonTemplate, SecureHandlerEnterLeaveTemplate")

	mainframe:SetAttribute("type4", "macro")
	mainframe:SetAttribute("type5", "macro")
	mainframe:RegisterForClicks(GetCVarBool("ActionButtonUseKeyDown") and "AnyDown" or "AnyUp")

	SecureHandlerWrapScript(mainframe,"OnClick",mainframe,[[

		local maxUnits = self:GetAttribute("maxUnits")
		local playerIndex = self:GetAttribute("playerIndex")
		local nextPlayerIndex

		if button == "Button4" then
			nextPlayerIndex = playerIndex -1
			if nextPlayerIndex <1 then
				nextPlayerIndex = maxUnits
			end
		else
			nextPlayerIndex = playerIndex + 1
			if nextPlayerIndex >maxUnits then
				nextPlayerIndex = 1
			end	
		end

		local nextTargetName = self:GetAttribute("playerName"..nextPlayerIndex)

		self:SetAttribute("macrotext",'/cleartarget\n' ..
				'/targetexact ' ..
				nextTargetName)
		self:SetAttribute("playerIndex", nextPlayerIndex)
	]])

	mainframe.Players = {}            --index = name, value = button(table), contains enemyButtons
	mainframe.CurrentPlayerOrder = {} --index = number, value = playerButton(table)
	mainframe.InactivePlayerButtons = {} --index = number, value = button(table)
	mainframe.NewPlayersDetails = {}  -- index = numeric, value = playerdetails, used for creation of new buttons, use (temporary) table to not create an unnecessary new button if another player left
	mainframe.PlayerType = playerType
	mainframe.PlayerSources = {}
	mainframe.NumPlayers = 0
    mainframe.Counter = {}
	mainframe.Testmode = {
		holdsFlag = false,
		hasFlag = false
	}

    mainframe.Counter = {}


    mainframe:Hide()
    mainframe:SetScript("OnEvent", function(self, event, ...)
        --self.Counter[event] = (self.Counter[event] or 0) + 1
        --self:Debug("Enemies OnEvent", event, ...)
        self[event](self, ...)
    end)


	function mainframe:InitializeAllPlayerSources()
		for sourceName in pairs(BattleGroundEnemies.consts.PlayerSources) do
			mainframe.PlayerSources[sourceName] = {}
		end
	end

	mainframe:InitializeAllPlayerSources()

	function mainframe:RemoveAllPlayersFromAllSources()
		self:InitializeAllPlayerSources()
		self:AfterPlayerSourceUpdate()
	end

	function mainframe:Debug(...)
		BattleGroundEnemies:Debug(self.PlayerType, ...)
	end

	function mainframe:RemoveAllPlayersFromSource(source)
		self:BeforePlayerSourceUpdate(source)
		self:AfterPlayerSourceUpdate()
	end

	function mainframe:BeforePlayerSourceUpdate(source)
		self.PlayerSources[source] = {}
	end

	function mainframe:AddPlayerToSource(source, playerT)
		self:Debug("AddPlayerToSource", self.PlayerType, playerT)
		if playerT.name then
			if playerT.name == "" then return end
		else
			--only allow no name if its a arena prep enemy
			if not playerT.additionalData then return end
			if not playerT.additionalData.PlayerArenaUnitID then return end
		end



		if not playerT.classToken then return end
		if playerT.classToken == "" then return end

		table_insert(self.PlayerSources[source], playerT)
	end

	function mainframe:FindPlayerInSource(source, playerT)
		local playerSource = self.PlayerSources[source]
		for i = 1, #playerSource do
			local playerData = playerSource[i]
			if playerData.name == playerT.name then
				return playerData
			end
		end
	end

	local function matchBattleFieldScoreToArenaEnemyPlayer(scoreTables, arenaPlayerInfo)
		BattleGroundEnemies:Debug("matchBattleFieldScoreToArenaEnemyPlayer", scoreTables, arenaPlayerInfo)
		local foundPlayer = false
		local foundMatchIndex
		for i = 1, #scoreTables do
			local scoreInfo = scoreTables[i]

			-- local faction = scoreInfo.faction
			-- local name = scoreInfo.name
			-- local classToken = scoreInfo.classToken
			-- local specName = scoreInfo.talentSpec
			-- local raceName = scoreInfo.raceName

			if scoreInfo.classToken and arenaPlayerInfo.classToken then
				if scoreInfo.faction == BattleGroundEnemies.EnemyFaction and scoreInfo.classToken == arenaPlayerInfo.classToken and scoreInfo.talentSpec == arenaPlayerInfo.specName then --specname/talentSpec can be nil for old expansions
					if foundPlayer then
						return false    -- we already had a match but found a second player that matches, unlucky
					end
					foundPlayer = true                                                                                                                                      --we found a match, make sure its the only one
					foundMatchIndex = i
				end
			end
		end
		if foundPlayer then
			return scoreTables[foundMatchIndex]
		end
	end

	function mainframe:AfterPlayerSourceUpdate()
		self:Debug("AfterPlayerSourceUpdate")
		local newPlayers = {} --contains combined data from PlayerSources
		if self.PlayerType == BattleGroundEnemies.consts.PlayerTypes.Enemies then
			if BattleGroundEnemies:IsTestmodeOrEditmodeActive() then
				newPlayers = self.PlayerSources[BattleGroundEnemies.consts.PlayerSources.FakePlayers]
			else
				local scoreboardEnemies = self.PlayerSources[BattleGroundEnemies.consts.PlayerSources.Scoreboard]
				local numScoreboardEnemies = #scoreboardEnemies
				local addScoreBoardPlayers = false
				if BattleGroundEnemies.states.isInArena then
					self:Debug("AfterPlayerSourceUpdate", "inArena")
					--use arenaPlayers is primary source to preserve same order arena1 to arena3, scoreboard doesn't offer this
					local arenaEnemies = self.PlayerSources[BattleGroundEnemies.consts.PlayerSources.ArenaPlayers]
					local numArenaEnemies = #arenaEnemies
					self:Debug("AfterPlayerSourceUpdate", numArenaEnemies)

					if numArenaEnemies > 0 then
						for i = 1, numArenaEnemies do
							local playerName
							local arenaEnemy = arenaEnemies[i]
							if arenaEnemy.name then
								playerName = arenaEnemy.name
							else
								--useful in solo shuffle in first round, then we can show a playername via data from scoreboard
								local match = matchBattleFieldScoreToArenaEnemyPlayer(scoreboardEnemies, arenaEnemy)
								if match then
									self:Debug("found a name match")
									playerName = match.name
								else
									self:Debug("didnt find a match", arenaEnemy.additionalData.PlayerArenaUnitID)
									-- use the unitID
									playerName = arenaEnemy.additionalData.PlayerArenaUnitID
								end
							end
							local t = Mixin({}, arenaEnemy)
							t.name = playerName
							table.insert(newPlayers, t)
						end
					else
						addScoreBoardPlayers = true
						--maybe we got some in scoreboard
					end
				else --in BattleGround
					if numScoreboardEnemies == 0 then
						if BattleGroundEnemies.states.isRatedBG and IsRetail then
							newPlayers = self.PlayerSources[BattleGroundEnemies.consts.PlayerSources.CombatLog]
						end
					else
						addScoreBoardPlayers = true
					end
				end
				if addScoreBoardPlayers then
					for i = 1, numScoreboardEnemies do
						local scoreboardEnemy = scoreboardEnemies[i]
						table.insert(newPlayers, {
							name = scoreboardEnemy.name,
							raceName = scoreboardEnemy.raceName,
							classToken = scoreboardEnemy.classToken,
							specName = scoreboardEnemy.talentSpec
						})
					end
				end
			end
		else --"Allies"
			local groupMembers = self.PlayerSources[BattleGroundEnemies.consts.PlayerSources.GroupMembers]
			local numGroupMembers = #groupMembers
			local addWholeGroup = false
			if BattleGroundEnemies:IsTestmodeOrEditmodeActive() then
				if BattleGroundEnemies.db.profile.Testmode_UseTeammates then
					addWholeGroup = true
				else
					--just addMyself and fill up the rest with fakeplayers
					if BattleGroundEnemies.UserButton.PlayerDetails then
						table.insert(newPlayers, groupMembers[numGroupMembers]) --i am always last in here
						local fakeAllies = self.PlayerSources[BattleGroundEnemies.consts.PlayerSources.FakePlayers]
						local numFakeAllies = #fakeAllies
						for i = 1, numFakeAllies do
							local fakeAlly = fakeAllies[i]
							table.insert(newPlayers, fakeAlly)
						end
					end
				end
			else
				addWholeGroup = true
			end
			if addWholeGroup then
				for i = 1, numGroupMembers do
					local groupMember = groupMembers[i]
					local specName = groupMember.specName
					if not specName or specName == "" then
						local name = groupMember.name
						--self:Debug("player", name, "doesnt have a spec from group member")
						local match = self:FindPlayerInSource(BattleGroundEnemies.consts.PlayerSources.Scoreboard, groupMember)
						if match then
							--self:Debug("player", name, "we found a spec from the scoreboard")
							groupMember.specName = match.talentSpec
						end
					end
					table.insert(newPlayers, groupMember)
				end
			end
		end
		self:BeforePlayerUpdate()
		for i = 1, #newPlayers do
			local newPlayer = newPlayers[i]
			local name = newPlayer.name
			local raceName = newPlayer.raceName
			local classToken = newPlayer.classToken
			local specName = newPlayer.specName
			local additionalData = newPlayer.additionalData
			self:Debug("AfterPlayer", name, raceName, classToken, specName, additionalData)
			self:CreateOrUpdatePlayerDetails(name, raceName, classToken, specName, additionalData)
		end
		self:SetPlayerCount(#newPlayers)
		self:CreateOrRemovePlayerButtons()
	end

	function mainframe:OnTestmodeTick()
		for name, playerButton in pairs(self.Players) do
			if playerButton.PlayerDetails.isFakePlayer then
				local numEvents = #testEvents
				local randomEvent = testEvents[math_random(1, numEvents)]
				randomEvent(self, playerButton)
				BattleGroundEnemies:UpdateFakeAurasTestmode(playerButton)
				playerButton:UNIT_HEALTH()

				playerButton:DispatchEvent("OnTestmodeTick")
			end
		end
	end

	function mainframe:OnEditmodeTick()
		for name, playerButton in pairs(self.Players) do
			if playerButton.PlayerDetails.isFakePlayer then
				BattleGroundEnemies:UpdateDRsEditMode(playerButton)
			end
		end
	end

	function mainframe:OnEditmodeEnabled()
		for name, playerButton in pairs(self.Players) do
			if playerButton.PlayerDetails.isFakePlayer then
				local numEvents = #testEvents
				for i = 1, numEvents do
					local event = testEvents[i]
					event(self, playerButton)
				end
				playerButton:UNIT_HEALTH()
				BattleGroundEnemies:UpdateFakeAurasEditmode(playerButton)
				BattleGroundEnemies:UpdateDRsEditMode(playerButton)
			end
		end
	end

	function mainframe:OnTestmodeEnabled()
		for playerName, playerButton in pairs(self.Players) do
			playerButton:DispatchEvent("OnTestmodeEnabled")
		end
		self.ActiveProfile:Show()

		if self.CurrentPlayerOrder[1] then
			BattleGroundEnemies:HandleTargetChanged(self.CurrentPlayerOrder[1])
		end
		if self.CurrentPlayerOrder[2] then
			BattleGroundEnemies:HandleFocusChanged(self.CurrentPlayerOrder[2])
		end
	end

	function mainframe:OnTestmodeDisabled()
		for playerName, playerButton in pairs(self.Players) do
			playerButton:DispatchEvent("OnTestmodeDisabled")
		end
		self:RemoveAllPlayersFromSource(BattleGroundEnemies.consts.PlayerSources.FakePlayers)


		self.ActiveProfile:Hide()
	end

	function mainframe:Enable()
		self:Debug("enabled")

		if BattleGroundEnemies:IsTestmodeOrEditmodeActive() then
		else
			if self.PlayerType == BattleGroundEnemies.consts.PlayerTypes.Enemies then
				self:Debug("Registered enemy events")
				self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
				self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
				self:RegisterEvent("UNIT_NAME_UPDATE")
				if HasSpeccs then
					self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
				end
			end


			if BattleGroundEnemies.states.isInArena or BattleGroundEnemies.states.isInBattleground then
				BattleGroundEnemies:CheckForArenaEnemies()
			end
		end
		self:Show()
	end

	function mainframe:Disable()
		self:Debug("disabled")
		self:UnregisterAllEvents()
		self:Hide()
	end

	function mainframe:NoActivePlayercountProfile()
		self.playerCountConfig = false
		self:Disable()
	end

	function mainframe:ApplyPlayerCountProfileSettings()
		if InCombatLockdown() then
			return BattleGroundEnemies:QueueForUpdateAfterCombat(self, "ApplyPlayerCountProfileSettings")
		end

		local conf = self.playerCountConfig
		if not conf then return end



		self:SetPlayerCountJustifyV(conf.BarVerticalGrowdirection)

		self.PlayerCount:ApplyFontStringSettings(BattleGroundEnemies.db.profile.PlayerCount.Text)

		self.ActiveProfile:ApplyFontStringSettings(BattleGroundEnemies.db.profile.PlayerCount.Text)

		self.ActiveProfile:SetText(L[self.PlayerType]..": ".. BattleGroundEnemies:GetPlayerCountConfigNameLocalized(self.playerCountConfig, self.playerTypeConfig.CustomPlayerCountConfigsEnabled))


		self:SortPlayers(true) --force repositioning

		self:UpdatePlayerCount()
		self:CheckEnableState()
	end

	function mainframe:SelectPlayerCountProfile(forceUpdate)
		self.playerTypeConfig = BattleGroundEnemies.db.profile[self.PlayerType]
		local maxNumPlayers = math_max(self.NumPlayers or 0)
		self:Debug("SelectPlayerCountProfile", maxNumPlayers)
		if not maxNumPlayers then return end
		if maxNumPlayers == 0 then return self:NoActivePlayercountProfile() end

		if maxNumPlayers > 40 then
			self:Disable()
			return
		end

		local playerCountConfigs
		if self.playerTypeConfig.CustomPlayerCountConfigsEnabled then
			playerCountConfigs = self.playerTypeConfig.customPlayerCountConfigs
		else
			playerCountConfigs = self.playerTypeConfig.playerCountConfigs
		end

		local foundProfilesForPlayerCount = {}
		for i = 1, #playerCountConfigs do
			local playerCountProfile = playerCountConfigs[i]
			local minPlayerCount = playerCountProfile.minPlayerCount
			local maxPlayerCount = playerCountProfile.maxPlayerCount

			if maxNumPlayers <= maxPlayerCount and maxNumPlayers >= minPlayerCount then
				table.insert(foundProfilesForPlayerCount, playerCountProfile)
			end
		end

		if #foundProfilesForPlayerCount == 0 then
			self:NoActivePlayercountProfile()
			return
			--return BattleGroundEnemies:Information("Can't find a profile for the current player count of " .. self.NumPlayers .." players for "..self.PlayerType.." please check the settings")
		end

		if #foundProfilesForPlayerCount > 1 then
			local overlappingProfilesString = ""
			for i = 1, #foundProfilesForPlayerCount do
				local overlappingIndexShownName = BattleGroundEnemies:GetPlayerCountConfigNameLocalized(foundProfilesForPlayerCount[i])
				overlappingProfilesString = overlappingProfilesString .. "and " .. overlappingIndexShownName
			end
			self:NoActivePlayercountProfile()
			BattleGroundEnemies:Information("Found multiple player count profiles fitting the current player count for "..self.PlayerType.." please check your settings and make sure they don't overlap")
			BattleGroundEnemies:Information("The following profiles are overlapping: "..overlappingProfilesString)

			return
		end



		if forceUpdate or foundProfilesForPlayerCount[1] ~= self.playerCountConfig then
			self.playerCountConfig = foundProfilesForPlayerCount[1]
			self:ApplyPlayerCountProfileSettings()
		end
	end

	function mainframe:CheckEnableState()
		self:Debug("CheckEnableState")
		if self.playerTypeConfig.Enabled and self.playerCountConfig and self.playerCountConfig.Enabled then
			if BattleGroundEnemies.states.isInArena and not BattleGroundEnemies.db.profile.ShowBGEInArena then
				return self:Disable()
			end
			if BattleGroundEnemies.states.isInBattleground and not BattleGroundEnemies.db.profile.ShowBGEInBattleground then
				return self:Disable()
			end
			self:Enable()
		else
			self:Disable()
		end
	end

	function mainframe:SetRealPlayerCount(realCount)
		self:Debug("SetRealPlayerCount", realCount)
		local oldCount = self.RealPlayerCount
		self.RealPlayerCount = realCount
		if not oldCount or oldCount ~= realCount then
			self:SelectPlayerCountProfile()
		end
		self:UpdatePlayerCount()
	end

	function mainframe:SetPlayerCount(count)
		local oldCount = self.NumPlayers
		self.NumPlayers = count
		if not oldCount or oldCount ~= count then
			self:SelectPlayerCountProfile()
		end
		self:UpdatePlayerCount()
	end

	function mainframe:UpdatePlayerCount()


		local maxNumPlayers = math_max(self.RealPlayerCount or 0, self.NumPlayers or 0)


		local isEnemy = self.PlayerType == BattleGroundEnemies.consts.PlayerTypes.Enemies
		self:Debug("UpdatePlayerCount", maxNumPlayers, isEnemy)


		BattleGroundEnemies:SetAllyFaction(BattleGroundEnemies.AllyFaction or (BattleGroundEnemies.UserFaction == "Horde" and 1 or 0))

		if self.playerCountConfig and self.playerCountConfig.PlayerCount.Enabled then
			self.PlayerCount:Show()
			self.PlayerCount:SetText(format(isEnemy == (BattleGroundEnemies.EnemyFaction == 0) and PLAYER_COUNT_HORDE or PLAYER_COUNT_ALLIANCE, maxNumPlayers))
		else
			self.PlayerCount:Hide()
		end
	end

	function mainframe:GetPlayerbuttonByUnitID(unitID)
		local uName = GetUnitName(unitID, true)

		return self.Players[uName]
	end

	function mainframe:GetRandomPlayer()
		local t = {}
		for playerName, playerButton in pairs(self.Players) do
			table.insert(t, playerButton)
		end
		local numPlayers = #t
		if numPlayers > 0 then
			return t[math_random(1, numPlayers)]
		end
	end

	function mainframe:SetPlayerCountJustifyV(direction)
		if direction == "downwards" then
			self.PlayerCount:SetJustifyV("BOTTOM")
		else
			self.PlayerCount:SetJustifyV("TOP")
		end
	end

	function mainframe:SetupButtonForNewPlayer(playerDetails)
		local playerButton = self.InactivePlayerButtons[#self.InactivePlayerButtons]
		if playerButton then --recycle a previous used button
			table_remove(self.InactivePlayerButtons, #self.InactivePlayerButtons)
			--Cleanup previous shown stuff of another player
			playerButton.MyTarget:Hide() --reset possible shown target indicator frame
			playerButton.MyFocus:Hide() --reset possible shown target indicator frame

			for moduleName, moduleFrameOnButton in pairs(BattleGroundEnemies.ButtonModules) do
				if playerButton[moduleName] and playerButton[moduleName].Reset then
					playerButton[moduleName]:Reset()
				end
			end


			if playerButton.UnitIDs then
				wipe(playerButton.UnitIDs.TargetedByEnemy)
				playerButton:UpdateTargetIndicators()
				if playerButton.PlayerIsEnemy then
					playerButton:DeleteActiveUnitID()
				end
			end
		else --no recycleable buttons remaining => create a new one
			self.buttonCounter = (self.buttonCounter or 0) + 1
			playerButton = BattleGroundEnemies:CreatePlayerButton(self, self.buttonCounter)
		end

		playerButton.UnitIDs = { TargetedByEnemy = {} }
		playerButton.unitID = nil
		playerButton.unit = nil

		playerButton.PlayerDetails = playerDetails
		playerButton:PlayerDetailsChanged()

		self.Target = nil

		local TimeSinceLastOnUpdate = 0
		local UpdatePeroid = 0.1 --update every 0.1seconds

		if playerButton.PlayerIsEnemy then
			playerButton:UpdateRange(false)
			if playerButton.PlayerDetails.isFakePlayer then
				playerButton:SetScript("OnUpdate", nil)
			else
				playerButton:SetScript("OnUpdate", function(self, elapsed)
					TimeSinceLastOnUpdate = TimeSinceLastOnUpdate + elapsed
					if TimeSinceLastOnUpdate > UpdatePeroid then
						if BattleGroundEnemies.states.userIsAlive then
							playerButton:UpdateAll()
						end
						TimeSinceLastOnUpdate = 0
					end
				end)
			end
		else
			playerButton:UpdateRange(true)
			if playerButton.PlayerDetails.isFakePlayer then
				playerButton:SetScript("OnUpdate", nil)
			else
				playerButton:SetScript("OnUpdate", function(self, elapsed)
					TimeSinceLastOnUpdate = TimeSinceLastOnUpdate + elapsed
					if TimeSinceLastOnUpdate > UpdatePeroid then
						if BattleGroundEnemies.states.userIsAlive then
							if playerButton ~= BattleGroundEnemies.UserButton then
								--self:Debug(IsItemInRange(self.playerTypeConfig.RangeIndicator_Range, allyButton.unitID), self.playerTypeConfig.RangeIndicator_Range, allyButton.unitID)
								playerButton:UpdateRangeViaLibRangeCheck(playerButton.unitID)
							else
								playerButton:UpdateRange(true)
							end
						end
						TimeSinceLastOnUpdate = 0
					end
				end)
			end
		end


		playerButton:Show()

		playerButton:WipeAllAuras()


		self.Players[playerButton.PlayerDetails.PlayerName] = playerButton

		return playerButton
	end

	function mainframe:RemovePlayer(playerButton)
		if playerButton == BattleGroundEnemies.UserButton then return end -- dont remove the Player itself

		local targetEnemyButton = playerButton.Target
		if targetEnemyButton then -- if that no longer exiting ally targeted something update the button of its target
			playerButton:IsNoLongerTarging(targetEnemyButton)
		end

		playerButton:Hide()

		table_insert(self.InactivePlayerButtons, playerButton)
		self.Players[playerButton.PlayerDetails.PlayerName] = nil
	end

	function mainframe:RemoveAllPlayers()
		for playerName, playerButton in pairs(self.Players) do
			self:RemovePlayer(playerButton)
		end
		self:SortPlayers()
	end

	function mainframe:GetPrevioiusPlayer()
		local currentTarget = BattleGroundEnemies.currentTarget

		local currentTargetIndex
		for i = 1, #self.CurrentPlayerOrder do
			local player = self.CurrentPlayerOrder[i]
			if player == currentTarget then
				currentTargetIndex = i
				break
			end
		end
		local newTargetIndex = (currentTargetIndex or 0) -1
		if newTargetIndex < 1 then
			newTargetIndex = #self.CurrentPlayerOrder
		end
		return newTargetIndex, self.CurrentPlayerOrder[newTargetIndex]
	end

	function mainframe:GetNextPlayer()
		local currentTarget = BattleGroundEnemies.currentTarget

		local currentTargetIndex
		for i = 1, #self.CurrentPlayerOrder do
			local player = self.CurrentPlayerOrder[i]
			if player == currentTarget then
				currentTargetIndex = i
				break
			end
		end
		local newTargetIndex = (currentTargetIndex or 0) + 1
		if newTargetIndex >#self.CurrentPlayerOrder then
			newTargetIndex = 0
		end
		return newTargetIndex, self.CurrentPlayerOrder[newTargetIndex]
	end

	function mainframe:SetUpBindings()
		--self:Debug("SetUpBindings", self.PlayerType)
		local maxPlayers = #self.CurrentPlayerOrder
		self:SetAttribute("maxUnits", maxPlayers)
		for j = 1, #self.CurrentPlayerOrder do
			self:SetAttribute("playerName"..j, self.CurrentPlayerOrder[j].PlayerDetails.PlayerName)
		end

		self:SetAttribute("playerIndex",1)


		if BattleGroundEnemies.db.profile.EnableMouseWheelPlayerTargeting then
			--SecureHandlerEnterLeaveTemplate ads _onenter and _onleave functionality
			mainframe:EnableMouseWheel(true)
			mainframe:SetAttribute("_onenter",[[
				self:SetBindingClick(true, "MOUSEWHEELUP",self:GetName(), "Button4")
				self:SetBindingClick(true, "MOUSEWHEELDOWN",self:GetName(), "Button5")
			]])
			-- onleave, clear override binding
			mainframe:SetAttribute("_onleave",[[
				self:ClearBindings()
			]])
		else
			mainframe:EnableMouseWheel(false)
			mainframe:SetAttribute("_onenter",nil)
			-- onleave, clear override binding
			mainframe:SetAttribute("_onleave",nil)
		end




		--button:SetAttribute("type1", "macro")
	end

	function mainframe:ButtonPositioning()
		self:Debug("ButtonPositioning")
		local orderedPlayers = self.CurrentPlayerOrder

		local config = self.playerCountConfig
		if not config then return end
		local columns = config.BarColumns


		local barHeight = config.BarHeight
		local barWidth = config.BarWidth

		local verticalSpacing = config.BarVerticalSpacing
		local horizontalSpacing = config.BarHorizontalSpacing

		local growDownwards = (config.BarVerticalGrowdirection == "downwards")
		local growRightwards = (config.BarHorizontalGrowdirection == "rightwards")

		local playerCount = #orderedPlayers

		local rowsPerColumn = math.ceil(playerCount / columns)

		local offsetX, offsetY

		local point, offsetDirectionX, offsetDirectionY = Data.Helpers.getContainerAnchorPointForConfig(growRightwards, growDownwards)

		self:SetScale(config.Framescale)
		self:ClearAllPoints()

		local scale = self:GetEffectiveScale()

		self:SetPoint(point, UIParent, "BOTTOMLEFT", config.Position_X / scale, config.Position_Y / scale)

		local column = 1
		local row = 1

		for i = 1, playerCount do
			local playerButton = orderedPlayers[i]
			if playerButton then --should never be nil
				playerButton.Position = i
				if column > 1 then
					offsetX = (column - 1) * (barWidth + horizontalSpacing) * offsetDirectionX
				else
					offsetX = 0
				end

				if row > 1 then
					offsetY = (row - 1) * (barHeight + verticalSpacing) * offsetDirectionY
				else
					offsetY = 0
				end


				playerButton:ClearAllPoints()
				playerButton:SetPoint(point, self, point, offsetX, offsetY)

				playerButton:ApplyButtonSettings()

				if row < rowsPerColumn then
					row = row + 1
				else
					column = column + 1
					row = 1
				end
			end
		end
		if playerCount > 0 then
			local lastButton = orderedPlayers[playerCount]
			local firstButton = orderedPlayers[1]

			local topButton
			local bottomButton

			if growDownwards then
				topButton = firstButton
				bottomButton = lastButton
			else
				topButton = lastButton
				bottomButton = firstButton
			end
			self:SetSize(barWidth, topButton:GetTop() - bottomButton:GetBottom())
		end
	end

	function mainframe:BeforePlayerUpdate()
		wipe(self.NewPlayersDetails)
	end

	function mainframe:CreateOrUpdatePlayerDetails(name, race, classToken, specName, additionalData)
		local spec = false
		if specName and specName ~= "" then
			spec = specName
		end
		local specData
		if classToken and spec then
			local t = Data.Classes[classToken]
			if t then
				specData = t[spec]
			end
		end

		local playerDetails = {
			PlayerName = name,
			PlayerClass = string.upper(classToken),                  --apparently it can happen that we get a lowercase "druid" from GetBattlefieldScore() in TBCC, IsTBCC
			PlayerClassColor = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[classToken],
			PlayerRace = race and LibRaces:GetRaceToken(race) or "Unknown", --delivers a locale independent token for relentless check
			PlayerSpecName = spec,                                 --set to false since we use Mixin() and Mixin doesnt mixin nil values and therefore we dont overwrite values with nil
			PlayerRole = specData and specData.roleID,
			PlayerLevel = false,
			isFakePlayer = false, --to set a base value, might be overwritten by mixin
			PlayerArenaUnitID = nil --to set a base value, might be overwritten by mixin
		}
		if additionalData then
			Mixin(playerDetails, additionalData)
		end

		-- self:Debug("CreateOrUpdatePlayerDetails", name, race, classToken, specName, additionalData)
		local playerButton = self.Players[name]
		if playerButton then --already existing
			local currentDetails = playerButton.PlayerDetails
			local detailsChanged = false

			for k, v in pairs(playerDetails) do
				if v ~= currentDetails[k] then
					detailsChanged = true
					-- self:Debug("k changed1", k)
					break
				end
			end

			if not detailsChanged then
				for k, v in pairs(currentDetails) do
					if v ~= playerDetails[k] then
						detailsChanged = true
						-- self:Debug("k changed2", k)
						break
					end
				end
			end
			playerButton.PlayerDetails = playerDetails

			if detailsChanged then
				playerButton:PlayerDetailsChanged()
			end

			playerButton.Status = 1 --1 means found, already existing
			playerDetails = playerButton.PlayerDetails
		else
			table.insert(self.NewPlayersDetails, playerDetails)
		end
	end

	function mainframe:CreateOrRemovePlayerButtons()
		local inCombat = InCombatLockdown()
		local existingPlayersCount = 0
		for playerName, playerButton in pairs(self.Players) do
			if playerButton.Status == 2 then --no longer existing
				if inCombat then
					return BattleGroundEnemies:QueueForUpdateAfterCombat(self, "AfterPlayerSourceUpdate")
				else
					self:RemovePlayer(playerButton)
				end
			else -- == 1 -- set to 2 for the next comparison
				playerButton.Status = 2
				existingPlayersCount = existingPlayersCount + 1
			end
		end

		for i = 1, #self.NewPlayersDetails do
			local playerDetails = self.NewPlayersDetails[i]
			if inCombat then
				return BattleGroundEnemies:QueueForUpdateAfterCombat(self, "AfterPlayerSourceUpdate")
			else
				local playerButton = self:SetupButtonForNewPlayer(playerDetails)
				playerButton.Status = 2
			end
		end
		self:SortPlayers(false)
	end

	do
		local BlizzardsSortOrder = {}
		for i = 1, #CLASS_SORT_ORDER do        -- Constants.lua
			BlizzardsSortOrder[CLASS_SORT_ORDER[i]] = i --key = ENGLISH CLASS NAME, value = number
		end

		local function PlayerSortingByRoleClassName(playerA, playerB) -- a and b are playerButtons
			local detailsPlayerA = playerA.PlayerDetails
			local detailsPlayerB = playerB.PlayerDetails


			--BattleGroundEnemies.db.profile.RoleSortingOrder is somethng like "HEALER_TANK_DAMAGER"

			local roleT = {strsplit("_", BattleGroundEnemies.db.profile.RoleSortingOrder)}
			local reverseRoleT = {}

			for k,v in pairs(roleT) do
				reverseRoleT[v] = k
			end

			local roleSortingNumerPlayerA = reverseRoleT[detailsPlayerA.PlayerRole]
			local roleSortingNumerPlayerB = reverseRoleT[detailsPlayerB.PlayerRole]

			if roleSortingNumerPlayerA and roleSortingNumerPlayerB then
				if roleSortingNumerPlayerA == roleSortingNumerPlayerB then
					if BlizzardsSortOrder[detailsPlayerA.PlayerClass] == BlizzardsSortOrder[detailsPlayerB.PlayerClass] then
						if detailsPlayerA.PlayerName < detailsPlayerB.PlayerName then return true end
					elseif BlizzardsSortOrder[detailsPlayerA.PlayerClass] < BlizzardsSortOrder[detailsPlayerB.PlayerClass] then
						return true
					end
				elseif roleSortingNumerPlayerA < roleSortingNumerPlayerB then
					return true
				end
			else
				if BlizzardsSortOrder[detailsPlayerA.PlayerClass] == BlizzardsSortOrder[detailsPlayerB.PlayerClass] then
					if detailsPlayerA.PlayerName < detailsPlayerB.PlayerName then return true end
				elseif BlizzardsSortOrder[detailsPlayerA.PlayerClass] < BlizzardsSortOrder[detailsPlayerB.PlayerClass] then
					return true
				end
			end
		end

		local function PlayerSortingByArenaUnitID(playerA, playerB) -- a and b are playerButtons
			if not (playerA and playerB) then return end
			local detailsPlayerA = playerA.PlayerDetails
			local detailsPlayerB = playerB.PlayerDetails
			if not (detailsPlayerA.PlayerArenaUnitID and detailsPlayerB.PlayerArenaUnitID) then return end
			if detailsPlayerA.PlayerArenaUnitID <= detailsPlayerB.PlayerArenaUnitID then
				return true
			end
		end

		local function CRFSort_Group_(playerA, playerB) -- this is basically a adapted CRFSort_Group to make the sorting in arena
			if not (playerA and playerB) then return end
			local detailsPlayerA = playerA.PlayerDetails
			local detailsPlayerB = playerB.PlayerDetails
			if not (detailsPlayerA.unitID and detailsPlayerB.unitID) then
				if detailsPlayerA.PlayerName < detailsPlayerB.PlayerName then return true end --for enabling testmode in arena since fake players don't have unitid
			end
			if (detailsPlayerA.unitID == "player") then
				return true;
			elseif (detailsPlayerB.unitID == "player") then
				return false;
			else
				return detailsPlayerA.unitID < detailsPlayerB.unitID; --String compare is OK since we don't go above 1 digit for party.
			end
		end

		function mainframe:SortPlayers(forceRepositioning)
			--self:Debug("SortPlayers", self.PlayerType)
			local newPlayerOrder = {}
			for playerName, playerButton in pairs(self.Players) do
				-- self:Debug(playerName)
				table.insert(newPlayerOrder, playerButton)
			end
			--[[
			self:Debug("before sorting")
			for i = 1, #newPlayerOrder do
				self:Debug(i, newPlayerOrder[i].PlayerDetails.PlayerName)
			end

 ]]

			if BattleGroundEnemies.states.isInArena then
				if (self.PlayerType == BattleGroundEnemies.consts.PlayerTypes.Enemies) then
					local usePlayerSortingByArenaUnitID = true
					for i = 1, #newPlayerOrder do
						if not newPlayerOrder[i].PlayerDetails.PlayerArenaUnitID then
							usePlayerSortingByArenaUnitID = false
							break
						end
					end
					if usePlayerSortingByArenaUnitID then
						-- self:Debug("usePlayerSortingByArenaUnitID", self.PlayerType)
						table.sort(newPlayerOrder, PlayerSortingByArenaUnitID)
					else
						-- self:Debug("dont usePlayerSortingByArenaUnitID", self.PlayerType)
						table.sort(newPlayerOrder, PlayerSortingByRoleClassName)
					end
				else
					local usePlayerSortingByUnitID = true -- fake players don't have unitid
					for i = 1, #newPlayerOrder do
						if not newPlayerOrder[i].PlayerDetails.unitID then
							usePlayerSortingByUnitID = false
							break
						end
					end
					if usePlayerSortingByUnitID then
						table.sort(newPlayerOrder, CRFSort_Group_)
					else
						table.sort(newPlayerOrder, PlayerSortingByRoleClassName)
					end
				end
			else
				table.sort(newPlayerOrder, PlayerSortingByRoleClassName)
			end

			local orderChanged = false
			for i = 1, math_max(#newPlayerOrder, #self.CurrentPlayerOrder) do --players can leave or join so #self.CurrentPlayerOrder can be unequal to #newPlayerOrder
				if newPlayerOrder[i] ~= self.CurrentPlayerOrder[i] then
					orderChanged = true
					break
				end
			end

			--[[ 			self:Debug("after sorting")
			for i = 1, #newPlayerOrder do
				self:Debug(i, newPlayerOrder[i].PlayerDetails.PlayerName)
			end ]]


			if orderChanged or forceRepositioning then
				local inCombat = InCombatLockdown()
				if inCombat then
					return BattleGroundEnemies:QueueForUpdateAfterCombat(self, "AfterPlayerSourceUpdate")
				end
				self.CurrentPlayerOrder = newPlayerOrder
				self:ButtonPositioning()
				self:SetUpBindings()
			end
		end
	end


	mainframe:SetClampedToScreen(true)
	mainframe:SetMovable(true)
	mainframe:SetUserPlaced(true)
	mainframe:SetResizable(true)
	mainframe:SetToplevel(true)

	mainframe.PlayerCount = BattleGroundEnemies.MyCreateFontString(mainframe)
	mainframe.PlayerCount:SetPoint("BOTTOMLEFT", mainframe, "TOPLEFT")
	mainframe.PlayerCount:SetPoint("BOTTOMRIGHT", mainframe, "TOPRIGHT")
	mainframe.PlayerCount:SetHeight(30)
	mainframe.PlayerCount:SetJustifyH("LEFT")
	mainframe.PlayerCount:SetJustifyV("MIDDLE")

	mainframe.ActiveProfile = BattleGroundEnemies.MyCreateFontString(mainframe)
	mainframe.ActiveProfile:SetPoint("BOTTOMLEFT", mainframe.PlayerCount, "TOPLEFT")
	mainframe.ActiveProfile:SetPoint("BOTTOMRIGHT", mainframe.PlayerCount, "TOPRIGHT")
	mainframe.ActiveProfile:SetHeight(30)
	mainframe.ActiveProfile:SetJustifyH("LEFT")
	mainframe.ActiveProfile:SetJustifyV("MIDDLE")
	mainframe.ActiveProfile:Hide()


    return mainframe
end

--@class BattleGroundEnemies.Allies: AllyFrame
BattleGroundEnemies.Allies = CreateMainFrame(BattleGroundEnemies.consts.PlayerTypes.Allies)
BattleGroundEnemies.Allies.GUIDToAllyname = {}



BattleGroundEnemies.Enemies = CreateMainFrame(BattleGroundEnemies.consts.PlayerTypes.Enemies)
BattleGroundEnemies.Enemies.Counter = {}


function BattleGroundEnemies.Allies:GroupInSpecT_Update(event, GUID, unitID, info)
	if not GUID or not info.class then return end

	BattleGroundEnemies.specCache[GUID] = info.spec_name_localized

	BattleGroundEnemies:GROUP_ROSTER_UPDATE()
end

function BattleGroundEnemies.Allies:AddGroupMember(name, isLeader, isAssistant, classToken, unitID)
	local raceName, raceFile, raceID = UnitRace(unitID)
	local GUID = UnitGUID(unitID)

	if not GUID then return end

	if name and raceName and classToken then
		local specName = BattleGroundEnemies.specCache[GUID]

		self:AddPlayerToSource(BattleGroundEnemies.consts.PlayerSources.GroupMembers, {
			name = name,
			raceName = raceName,
			classToken = classToken,
			specName = specName,
			additionalData = {
				isGroupLeader = isLeader,
				isGroupAssistant = isAssistant,
				GUID = GUID,
				unitID = unitID
			}
		})
	end

	self.GUIDToAllyname[GUID] = name

	if isLeader then
		self.groupLeader = name
	end
	if isAssistant then
		table_insert(self.assistants, name)
	end
end

function BattleGroundEnemies.Allies:UpdateAllUnitIDs()
	--it happens that numGroupMembers is higher than the value of the maximal players for that battleground, for example 15 in a 10 man bg, thats why we wipe AllyUnitIDToAllyDetails
	for allyName, allyButton in pairs(self.Players) do
		if allyButton then
			local unitID
			local targetUnitID
			if allyButton.PlayerDetails.PlayerName ~= BattleGroundEnemies.UserDetails.PlayerName then
				local unit = allyButton.PlayerDetails.unitID
				if not unit then return end

				unitID = unit
				targetUnitID = unitID .. "target"
			else
				unitID = "player"
				targetUnitID = "target"
				BattleGroundEnemies.UserButton = allyButton
			end
			if not (unitID and targetUnitID) then return end


			--self.unitID already gets assigned for allies before, info from GROUP_ROSTER_UPDATE

			if allyButton.unit ~= unitID then
				--ally has a new unitID now
				--self:Debug("player", groupMember.PlayerName, "has a new unit and targeted something")

				local targetButton = allyButton.Target
				if targetButton then
					--reset the TargetedByEnemy
					targetButton:IsNoLongerTarging(targetButton)
					targetButton:IsNowTargeting(targetButton)
				end

				if InCombatLockdown() then --if we are in combat we go get to set the stuff below later since GROUP_ROSTER_UPDATE also has a combat check and will get called after combat
					return BattleGroundEnemies:QueueForUpdateAfterCombat(BattleGroundEnemies[allyButton.PlayerType], "UpdateAllUnitIDs")
				else
					allyButton.unit = unitID
					allyButton:SetAttribute('unit', unitID)
					BattleGroundEnemies.Allies:SortPlayers()
				end
			end

			allyButton:UpdateUnitID(unitID, targetUnitID)
		end
	end
end

function BattleGroundEnemies.Enemies:ChangeName(oldName, newName) --only used in arena when players switch from "arenaX" to a real name
	local playerButton = self.Players[oldName]

	if playerButton then
		playerButton.PlayerDetails.PlayerName = newName
		self:Debug("name changed", oldName, newName)
		playerButton:PlayerDetailsChanged()

		self.Players[newName] = playerButton
		self.Players[oldName] = nil
	end
end

function BattleGroundEnemies.Enemies:CreateArenaEnemies()
	self:Debug("CreateArenaEnemies")
	if not BattleGroundEnemies.states.isInArena then return end

	self:BeforePlayerSourceUpdate(BattleGroundEnemies.consts.PlayerSources.ArenaPlayers)
	for i = 1, 15 do --we can have 15 enemies in the Arena Brawl Packed House
		local unitID = "arena" .. i


		local _, classToken, specName
		if GetArenaOpponentSpec and GetSpecializationInfoByID then --HasSpeccs
			local specID, gender = GetArenaOpponentSpec(i)

			if (specID and specID > 0) then
				_, specName, _, _, _, classToken, _ = GetSpecializationInfoByID(specID, gender)
			end
		else
			classToken = select(2, UnitClass(unitID))
		end
		self:Debug("classToken", classToken)
		self:Debug("specName", specName)


		if classToken then
			local playerName
			local name = GetUnitName(unitID, true)
			if name and name ~= UNKNOWN then
				-- player has a real name, check if he is already shown as arenaX
				self:ChangeName(unitID, name)
				playerName = name
			end

			local raceName = UnitRace(unitID)
			self:AddPlayerToSource(BattleGroundEnemies.consts.PlayerSources.ArenaPlayers, {
				name = playerName,
				raceName = raceName,
				classToken = classToken,
				specName = specName,
				additionalData = { PlayerArenaUnitID = unitID }
			})
		end
	end

	self:AfterPlayerSourceUpdate()

	for playerName, playerButton in pairs(self.Players) do
		local playerDetails = playerButton.PlayerDetails
		if playerDetails.PlayerArenaUnitID then
			playerButton:UpdateAll(playerDetails.PlayerArenaUnitID)
		end
	end
end

BattleGroundEnemies.Enemies.ARENA_PREP_OPPONENT_SPECIALIZATIONS = BattleGroundEnemies.Enemies.CreateArenaEnemies -- for Prepframe, not available in TBC

function BattleGroundEnemies.Enemies:UNIT_NAME_UPDATE(unitID)
	self:Debug("UNIT_NAME_UPDATE", unitID)
	BattleGroundEnemies:ThrottleUpdateArenaPlayers()
end

function BattleGroundEnemies.Enemies:NAME_PLATE_UNIT_ADDED(unitID)
	local enemyButton = self:GetPlayerbuttonByUnitID(unitID)
	if enemyButton then
		enemyButton:UpdateEnemyUnitID("Nameplate", unitID)
	end
end

function BattleGroundEnemies.Enemies:NAME_PLATE_UNIT_REMOVED(unitID)
	--self:Debug(unitID)
	local enemyButton = self:GetPlayerbuttonByUnitID(unitID)
	if enemyButton then
		enemyButton:UpdateEnemyUnitID("Nameplate", false)
	end
end

