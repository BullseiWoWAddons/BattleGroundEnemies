---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)

---@class BattleGroundEnemies
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L

--WoW API
local RequestCrowdControlSpell = C_PvP.RequestCrowdControlSpell


--lua
local math_floor = math.floor
local math_max = math.max
local math_min = math.min
local math_random = math.random
local table_insert = table.insert
local table_remove = table.remove

local HasSpeccs = not not GetSpecializationInfoByID

--Libs
local LSM = LibStub("LibSharedMedia-3.0")
local LibRaces = LibStub("LibRaces-1.0")
local LRC = LibStub("LibRangeCheck-3.0")

local LGIST
if HasSpeccs then
	LGIST = LibStub:GetLibrary("LibGroupInSpecT-1.1")
end


local IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local IsTBCC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local IsWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC



local function FakeUnitAura(playerButton, index, filter)
	local fakePlayerAuras = BattleGroundEnemies.Testmode.FakePlayerAuras
	local aura = fakePlayerAuras[playerButton][filter][index]
	return aura
end

local auraFilters = { "HELPFUL", "HARMFUL" }

local enemyButtonFunctions = {}
do
	--Remove from OnUpdate
	function enemyButtonFunctions:DeleteActiveUnitID() --Delete from OnUpdate
		--BattleGroundEnemies:Debug("DeleteActiveUnitID")
		self.unitID = false
		self.TargetUnitID = false
		self:UpdateRange(false)

		if self.Target then
			self:IsNoLongerTarging(self.Target)
		end

		self.UnitIDs.HasAllyUnitID = false
		self:UNIT_AURA()
		self:DispatchEvent("UnitIdUpdate")
	end

	function enemyButtonFunctions:UpdateEnemyUnitID(key, value)
		if self.PlayerDetails.isFakePlayer then return end
		local unitIDs = self.UnitIDs
		if key then
			unitIDs[key] = value
		end

		local unitID = unitIDs.Arena or unitIDs.Nameplate or unitIDs.Target or unitIDs.Focus
		if unitID then
			unitIDs.HasAllyUnitID = false
			self:UpdateUnitID(unitID, unitID .. "target")
		elseif unitIDs.Ally then
			unitIDs.HasAllyUnitID = true
			local playerButton = BattleGroundEnemies:GetPlayerbuttonByUnitID(unitIDs.Ally)
			if playerButton and playerButton == self then
				self:UpdateUnitID(unitIDs.Ally, unitIDs.Ally .. "target")
				unitIDs.HasAllyUnitID = true
			end
		else
			self:DeleteActiveUnitID()
		end
	end
end


local buttonFunctions = {}
do
	function buttonFunctions:GetOppositeMainFrame()
		return BattleGroundEnemies
			[self.PlayerType == BattleGroundEnemies.consts.PlayerTypes.Enemies and BattleGroundEnemies.consts.PlayerTypes.Allies or BattleGroundEnemies.consts.PlayerTypes.Enemies]
	end

	function buttonFunctions:OnDragStart()
		return BattleGroundEnemies.db.profile.Locked or self:GetParent():StartMoving()
	end

	function buttonFunctions:OnDragStop()
		local parent = self:GetParent()
		parent:StopMovingOrSizing()
		if not InCombatLockdown() then
			local scale = self:GetEffectiveScale()
			self.playerCountConfig.Position_X = parent:GetLeft() * scale
			self.playerCountConfig.Position_Y = parent:GetTop() * scale
		end
	end

	function buttonFunctions:UpdateAll(temporaryUnitID)
		local updateStuffWithEvents = false --only update health, power, etc for players that dont get events for that or that dont have a unitID assigned
		local unitID
		local updateAuras = false
		if temporaryUnitID then
			updateStuffWithEvents = true
			unitID = temporaryUnitID
			updateAuras = true
		else
			if self.unitID then
				unitID = self.unitID
				if self.UnitIDs.HasAllyUnitID then
					updateStuffWithEvents = true

					--throttle the aura updates in case we only have a ally unitID
					local lastAuraUpdate = self.lastAuraUpdate
					if lastAuraUpdate then
						if GetTime() - lastAuraUpdate > 0.5 then
							updateAuras = true
						end
					else
						updateAuras = true
					end
				end
			end
		end
		--BattleGroundEnemies:LogToSavedVariables("UpdateAll", unitID, updateStuffWithEvents)
		if not unitID then return end
		--BattleGroundEnemies:LogToSavedVariables("UpdateAll", 1)

		if not UnitExists(unitID) then return end

		--this further checks dont seem necessary since they dont seem to rule out any other unitiDs (all unit ids that exist also are a button and are also this frame)


		--[[ BattleGroundEnemies:LogToSavedVariables("UpdateAll", 2)

		local playerButton = BattleGroundEnemies:GetPlayerbuttonByUnitID(unitID)

		if not playerButton then return end
		BattleGroundEnemies:LogToSavedVariables("UpdateAll", 3)
		if playerButton ~= self then return	end
		BattleGroundEnemies:LogToSavedVariables("UpdateAll", 4) ]]


		if updateStuffWithEvents then
			self:UNIT_POWER_FREQUENT(unitID)
			self:UNIT_HEALTH(unitID)
			if updateAuras then
				self:UNIT_AURA(unitID) --throttle aura updates
			end
		end

		self:UpdateRangeViaLibRangeCheck(unitID)
		self:UpdateTarget()
	end

	function buttonFunctions:GetSpecData()
		if not self.PlayerDetails then return end
		if self.PlayerDetails.PlayerClass and self.PlayerDetails.PlayerSpecName then
			local t = Data.Classes[self.PlayerDetails.PlayerClass]
			if t then
				t = t[self.PlayerDetails.PlayerSpecName]
				return t
			end
		end
	end

	function buttonFunctions:PlayerDetailsChanged()
		self:SetBindings()
		self:DispatchEvent("PlayerDetailsChanged")
	end

	function buttonFunctions:UpdateRaidTargetIcon(forceIndex)
		local unit = self:GetUnitID()
		local newIndex =
			forceIndex --used for testmode, otherwise it will just be nil and overwritten when one actually exists
		if unit then
			newIndex = GetRaidTargetIndex(unit)
			if newIndex then
				if newIndex == 8 and (not self.RaidTargetIconIndex or self.RaidTargetIconIndex ~= 8) then
					if BattleGroundEnemies.IsRatedBG and BattleGroundEnemies.db.profile.RBG.TargetCalling_NotificationEnable then
						local path = LSM:Fetch("sound",
							BattleGroundEnemies.db.profile.RBG.TargetCalling_NotificationSound, true)
						if path then
							PlaySoundFile(path, "Master")
						end
					end
				end
			end
		end
		self.RaidTargetIconIndex = newIndex
		self:DispatchEvent("UpdateRaidTargetIcon", self.RaidTargetIconIndex)
	end

	function buttonFunctions:UpdateCrowdControl(unitID)
		local spellId, itemID, startTime, duration
		if IsClassic or IsTBCC or IsWrath then
			spellId, itemID, startTime, duration = C_PvP.GetArenaCrowdControlInfo(unitID)
		else
			spellId, startTime, duration = C_PvP.GetArenaCrowdControlInfo(unitID)
		end

		if spellId then
			self.Trinket:DisplayTrinket(spellId, itemID)
			self.Trinket:SetTrinketCooldown(startTime / 1000.0, duration / 1000.0)
		end
	end

	function buttonFunctions:UpdateUnitID(unitID, targetUnitID)
		if not UnitExists(unitID) then return end
		self.unitID = unitID
		self.TargetUnitID = targetUnitID
		if self.PlayerIsEnemy then
			self:UpdateRaidTargetIcon()
		end
		self:UpdateAll(unitID)
		self:DispatchEvent("UnitIdUpdate", unitID)
	end

	function buttonFunctions:SetModuleConfig(moduleName)
		local moduleFrameOnButton = self[moduleName]
		local moduleConfigOnButton = self.playerCountConfig.ButtonModules[moduleName]

		moduleFrameOnButton.config = moduleConfigOnButton
		if moduleConfigOnButton.Enabled and BattleGroundEnemies:IsModuleEnabledOnThisExpansion(moduleName) then
			moduleFrameOnButton.Enabled = true
		else
			moduleFrameOnButton.Enabled = false
		end
	end

	function buttonFunctions:SetAllModuleConfigs()
		for moduleName, moduleFrame in pairs(BattleGroundEnemies.ButtonModules) do
			self:SetModuleConfig(moduleName)
		end
	end

	function buttonFunctions:SetModulePositions()
		self:SetConfigShortCuts()
		if not self:GetRect() then return end --the position of the button is not set yet
		local i = 1
		repeat                          -- we basically run this roop to get out of the anchring hell (making sure all the frames that a module is depending on is set)
			local allModulesSet = true
			for moduleName, moduleFrame in pairs(BattleGroundEnemies.ButtonModules) do
				self:SetModuleConfig(moduleName)
				local moduleFrameOnButton = self[moduleName]

				local config = moduleFrameOnButton.config
				if not config then return end


				if config.Points then
					if i == 1 then moduleFrameOnButton:ClearAllPoints() end

					for j = 1, config.ActivePoints do
						local pointConfig = config.Points[j]
						if pointConfig then
							if pointConfig.RelativeFrame then
								local relativeFrame = self:GetAnchor(pointConfig.RelativeFrame)


								if relativeFrame then
									if relativeFrame:GetNumPoints() > 0 then
										moduleFrameOnButton:SetPoint(pointConfig.Point, relativeFrame,
											pointConfig.RelativePoint, pointConfig.OffsetX or 0, pointConfig.OffsetY or 0)
									else
										-- the module we are depending on hasn't been set yet
										allModulesSet = false
										--BattleGroundEnemies:LogToSavedVariables("moduleName", moduleName, "isnt set yet")
									end
								else
									if not relativeFrame then return print("error", relativeFrame, "for module", moduleName, "doesnt exist")
									end
								end
							else
								--do nothing, the point was probably deleted
							end
						end
					end
				end
				if config.Parent then
					moduleFrameOnButton:SetParent(self:GetAnchor(config.Parent))
				end

				if not moduleFrameOnButton.Enabled and moduleFrame.flags.SetZeroWidthWhenDisabled then
					moduleFrameOnButton:SetWidth(0.01)
				else
					if config.UseButtonHeightAsWidth then
						moduleFrameOnButton:SetWidth(self:GetHeight())
					else
						if config.Width and BattleGroundEnemies:ModuleFrameNeedsWidth(moduleFrame, config) then
							moduleFrameOnButton:SetWidth(config.Width)
						end
					end
				end


				if not moduleFrameOnButton.Enabled and moduleFrame.flags.SetZeroHeightWhenDisabled then
					moduleFrameOnButton:SetHeight(0.001)
				else
					if config.UseButtonHeightAsHeight then
						moduleFrameOnButton:SetHeight(self:GetHeight())
					else
						if config.Height and BattleGroundEnemies:ModuleFrameNeedsHeight(moduleFrame, config) then
							moduleFrameOnButton:SetHeight(config.Height)
						end
					end
				end
			end

			self.MyTarget:SetParent(self.healthBar)
			self.MyTarget:SetPoint("TOPLEFT", self.healthBar, "TOPLEFT")
			self.MyTarget:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMRIGHT")
			self.MyFocus:SetParent(self.healthBar)
			self.MyFocus:SetPoint("TOPLEFT", self.healthBar, "TOPLEFT")
			self.MyFocus:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMRIGHT")

			i = i + 1

			-- if i > 10 then
			-- 	BattleGroundEnemies:LogToSavedVariables("something went wrong in SetModulePositions")
			-- end
		until allModulesSet or i > 10 --maxium of 10 tries
	end

	function buttonFunctions:SetConfigShortCuts()
		self.config = BattleGroundEnemies.db.profile[self.PlayerType]
		self.playerCountConfig = BattleGroundEnemies[self.PlayerType].playerCountConfig
	end

	function buttonFunctions:ApplyButtonSettings()
		self:SetConfigShortCuts()
		local conf = self.playerCountConfig
		if not conf then return end

		self:SetWidth(conf.BarWidth)
		self:SetHeight(conf.BarHeight)

		self:ApplyRangeIndicatorSettings()

		-- auras on spec

		--MyTarget, indicating the current target of the player
		self.MyTarget:SetBackdrop({
			bgFile = "Interface/Buttons/WHITE8X8", --drawlayer "BACKGROUND"
			edgeFile = 'Interface/Buttons/WHITE8X8', --drawlayer "BORDER"
			edgeSize = BattleGroundEnemies.db.profile.MyTarget_BorderSize
		})
		self.MyTarget:SetBackdropColor(0, 0, 0, 0)
		self.MyTarget:SetBackdropBorderColor(unpack(BattleGroundEnemies.db.profile.MyTarget_Color))

		--MyFocus, indicating the current focus of the player
		self.MyFocus:SetBackdrop({
			bgFile = "Interface/Buttons/WHITE8X8", --drawlayer "BACKGROUND"
			edgeFile = 'Interface/Buttons/WHITE8X8', --drawlayer "BORDER"
			edgeSize = BattleGroundEnemies.db.profile.MyFocus_BorderSize
		})
		self.MyFocus:SetBackdropColor(0, 0, 0, 0)
		self.MyFocus:SetBackdropBorderColor(unpack(BattleGroundEnemies.db.profile.MyFocus_Color))




		wipe(self.ButtonEvents)
		self:SetAllModuleConfigs()
		self:SetModulePositions()

		for moduleName, moduleFrame in pairs(BattleGroundEnemies.ButtonModules) do
			local moduleFrameOnButton = self[moduleName]

			if moduleFrameOnButton.Enabled then
				if moduleFrame.events then
					for i = 1, #moduleFrame.events do
						local event = moduleFrame.events[i]
						self.ButtonEvents[event] = self.ButtonEvents[event] or {}

						table_insert(self.ButtonEvents[event], moduleFrameOnButton)
					end
				end
				moduleFrameOnButton.Enabled = true
				moduleFrameOnButton:Show()
				if moduleFrameOnButton.Enable then moduleFrameOnButton:Enable() end
				if moduleFrameOnButton.ApplyAllSettings then moduleFrameOnButton:ApplyAllSettings() end
			else
				moduleFrameOnButton.Enabled = false
				moduleFrameOnButton:Hide()
				if moduleFrameOnButton.Disable then moduleFrameOnButton:Disable() end
				if moduleFrameOnButton.Reset then moduleFrameOnButton:Reset() end
			end
		end
	end

	do
		local mouseButtons = {
			[1] = "LeftButton",
			[2] = "RightButton",
			[3] = "MiddleButton"
		}

		function buttonFunctions:SetBindings()
			local setupUsualAttributes = true
			--use a table to track changes and compare them to GetAttribute
			--set baseline



			local newAttributes = {
				unit = not self.PlayerIsEnemy and self.unit or false,
				type1 = false,
				type2 = false,
				type3 = false,
				macrotext1 = false,
				macrotext2 = false,
				macrotext3 = false
			}

			if ClickCastFrames[self] then
				ClickCastFrames[self] = nil
			end

			if self.PlayerIsEnemy then
				if self.PlayerDetails.PlayerArenaUnitID then --its a arena enemy
					newAttributes.unit = self.PlayerDetails.PlayerArenaUnitID
					-- newAttributes.type1 = "target"    -- type1 = LEFT-Click to target
					-- newAttributes.type2 = "focus"     -- type2 = Right-Click to focus
					-- setupUsualAttributes = false
				end
			else
				if BattleGroundEnemies.db.profile[self.PlayerType].UseClique then
					BattleGroundEnemies:Debug("Clique used")
					ClickCastFrames[self] = true
					setupUsualAttributes = false
				end
			end





			if setupUsualAttributes then
				newAttributes.type1 = "macro" -- type1 = LEFT-Click
				newAttributes.type2 = "macro" -- type2 = Right-Click
				newAttributes.type3 = "macro" -- type3 = Middle-Click

				for i = 1, 3 do
					local bindingType = self.config[mouseButtons[i] .. "Type"]

					if bindingType == "Target" then
						newAttributes['macrotext' .. i] = '/cleartarget\n' ..
							'/targetexact ' ..
							self.PlayerDetails.PlayerName
					elseif bindingType == "Focus" then
						newAttributes['macrotext' .. i] = '/targetexact ' .. self.PlayerDetails.PlayerName .. '\n' ..
							'/focus\n' ..
							'/targetlasttarget'
					else -- Custom
						local macrotext = (BattleGroundEnemies.db.profile[self.PlayerType][mouseButtons[i] .. "Value"])
							:gsub("%%n", self.PlayerDetails.PlayerName)
						newAttributes['macrotext' .. i] = macrotext
					end
				end
			end

			--check what have actually changed
			local updateNeeded = false
			for attribute, value in pairs(newAttributes) do
				local currentValue = self:GetAttribute(attribute)
				if currentValue ~= value then
					updateNeeded = true
					break
				end
			end
			local newRegisterForClicksValue = BattleGroundEnemies.db.profile[self.PlayerType].ActionButtonUseKeyDown and "AnyDown" or "AnyUp"
			if self.registerForClicksValue == nil or self.registerForClicksValue ~= newRegisterForClicksValue then
				updateNeeded = true
			end
			if updateNeeded then
				if InCombatLockdown() then
					return BattleGroundEnemies:QueueForUpdateAfterCombat(self, "SetBindings")
				end
				self:RegisterForClicks(newRegisterForClicksValue)
				self.registerForClicksValue = newRegisterForClicksValue
				for attribute, value in pairs(newAttributes) do
					self:SetAttribute(attribute, value)
				end
			end
		end
	end

	function buttonFunctions:PlayerDied()
		if self.PlayerDetails.isFakePlayer then
			if BattleGroundEnemies.Testmode.FakePlayerAuras[self] then
				wipe(BattleGroundEnemies.Testmode.FakePlayerAuras
					[self])
			end
			if BattleGroundEnemies.Testmode.FakePlayerDRs[self] then
				wipe(BattleGroundEnemies.Testmode.FakePlayerDRs
					[self])
			end
		end

		self:DispatchEvent("UnitDied")
		self.isDead = true
	end

	local maxHealths = {} --key = playerbutton, value = {}
	local deadPlayers = {}

	function buttonFunctions:FakeUnitHealth()
		local now = GetTime()
		if deadPlayers[self] then
			--this player is dead, check if we can revive him
			if deadPlayers[self] + 26 < now then -- he died more than 26 seconds ago
				deadPlayers[self] = nil
			else
				return 0 -- let the player be dead
			end
		end
		local maxHealth = self:FakeUnitHealthMax()

		local health = math_random(0, 100)
		if health == 0 then
			deadPlayers[self] = now
			self:PlayerDied()
			return 0
		else
			return math_floor((health / 100) * maxHealth)
		end
	end

	function buttonFunctions:FakeUnitHealthMax()
		if not maxHealths[self] then
			local myMaxHealth = UnitHealthMax("player")
			local playerMaxHealthDifference = math_random(-15, 15) -- the player has the same health as me +/- 15%
			local playerMaxHealth = math.ceil(myMaxHealth * (1 + (playerMaxHealthDifference / 100)))
			maxHealths[self] = playerMaxHealth
		end
		return maxHealths[self]
	end

	function buttonFunctions:UNIT_HEALTH(unitID) --gets health of nameplates, player, target, focus, raid1 to raid40, partymember
		if not self.isShown then return end
		local health
		local maxHealth
		if self.PlayerDetails.isFakePlayer then
			health = self:FakeUnitHealth()
			maxHealth = self:FakeUnitHealthMax()
		else
			health = UnitHealth(unitID)
			maxHealth = UnitHealthMax(unitID)
		end

		self:DispatchEvent("UpdateHealth", unitID, health, maxHealth)
		if unitID then
			if UnitIsDeadOrGhost(unitID) then
				self:PlayerDied()
			else
				self.isDead = false
			end
		else
			-- we are in testmode
			self.isDead = health == 0
		end
	end

	function buttonFunctions:ApplyRangeIndicatorSettings()
		--set everything to default
		for frameName, enableRange in pairs(self.config.RangeIndicator_Frames) do
			if self[frameName] then
				self[frameName]:SetAlpha(1)
			else
				--probably old saved variables version
				self.config.RangeIndicator_Frames[frameName] = nil
			end
		end
		self:SetAlpha(1)
		self:UpdateRange(not self.wasInRange)
	end

	function buttonFunctions:ArenaOpponentShown(unitID)
		if unitID then
			BattleGroundEnemies.ArenaIDToPlayerButton[unitID] = self
			if self.PlayerIsEnemy then
				self:UpdateEnemyUnitID("Arena", unitID)
			end
			RequestCrowdControlSpell(unitID)
		end
		self:DispatchEvent("ArenaOpponentShown")
	end

	-- Shows/Hides targeting indicators for a button
	function buttonFunctions:UpdateTargetIndicators()
		self:DispatchEvent("UpdateTargetIndicators")
		local isAlly = false
		local isPlayer = false

		if self == UserButton then
			isPlayer = true
		elseif not self.PlayerIsEnemy then
			isAlly = true
		end

		local i = 0
		for enemyButton in pairs(self.UnitIDs.TargetedByEnemy) do
			i = i + 1
		end

		if not BattleGroundEnemies.db.profile.RBG then return end

		local enemyTargets = i

		if BattleGroundEnemies.IsRatedBG then
			if isAlly then
				if BattleGroundEnemies.db.profile.RBG.EnemiesTargetingAllies_Enabled then
					if enemyTargets >= (BattleGroundEnemies.db.profile.RBG.EnemiesTargetingAllies_Amount or 1) then
						local path = LSM:Fetch("sound", BattleGroundEnemies.db.profile.RBG.EnemiesTargetingAllies_Sound,
							true)
						if path then
							PlaySoundFile(path, "Master")
						end
					end
				end
			end
			if isPlayer then
				if BattleGroundEnemies.db.profile.RBG.EnemiesTargetingMe_Enabled then
					if enemyTargets >= BattleGroundEnemies.db.profile.RBG.EnemiesTargetingMe_Amount then
						local path = LSM:Fetch("sound", BattleGroundEnemies.db.profile.RBG.EnemiesTargetingMe_Sound, true)
						if path then
							PlaySoundFile(path, "Master")
						end
					end
				end
			end
		end
	end

	function buttonFunctions:UpdateRange(inRange)
		--BattleGroundEnemies:Information("UpdateRange", inRange, self.PlayerName, self.config.RangeIndicator_Enabled, self.config.RangeIndicator_Alpha)

		if not self.config.RangeIndicator_Enabled then return end

		if inRange ~= self.wasInRange then
			local alpha = inRange and 1 or self.config.RangeIndicator_Alpha
			if self.config.RangeIndicator_Everything then
				self:SetAlpha(alpha)
			else
				for frameName, enableRange in pairs(self.config.RangeIndicator_Frames) do
					if enableRange then
						self[frameName]:SetAlpha(alpha)
					end
				end
			end
			self.wasInRange = inRange
		end
	end

	function buttonFunctions:UpdateRangeViaItem(unitID)
		--BattleGroundEnemies:Information("UpdateRange", inRange, self.PlayerName, self.config.RangeIndicator_Enabled, self.config.RangeIndicator_Alpha)

		if not self.config.RangeIndicator_Enabled then return end
		self:UpdateRange(IsItemInRange(self.config.RangeIndicator_Range, unitID))
	end

	function buttonFunctions:UpdateRangeViaLibRangeCheck(unitID)
		if not self.config.RangeIndicator_Enabled then return end
		local checker, range = LRC[self.PlayerIsEnemy and "GetHarmMaxChecker"  or "GetFriendMaxChecker"](LRC, self.config.RangeIndicator_Range, true)
		if not checker then return self:UpdateRange(true) end
		self:UpdateRange(checker(unitID))
	end



	function buttonFunctions:GetUnitID()
		return self.unitID
	end

	function buttonFunctions:AuraRemoved(spellId, spellName)
		if not self.isShown then return end
		self:DispatchEvent("AuraRemoved", spellId, spellName)
		--BattleGroundEnemies:Debug(operation, spellId)
	end

	function buttonFunctions:ShouldSkipAuraUpdate(isFullUpdate, updatedAuraInfos, isRelevantFunc, unitID)
		if isFullUpdate then return false end
		-- Early out if the update cannot affect the frame

		local skipUpdate = false
		if updatedAuraInfos and isRelevantFunc then
			skipUpdate = true
			for i = 1, #updatedAuraInfos do
				local auraInfo = updatedAuraInfos[i]

				if isRelevantFunc(self, unitID, auraInfo) then
					skipUpdate = false
					break
				end
			end
		end
		return skipUpdate
	end

	function buttonFunctions:ShouldDisplayAura(unitID, filter, aura)
		if self:DispatchUntilTrue("CareAboutThisAura", unitID, filter, aura) then return true end
		return false --nobody cares about this aura
	end

	--[[


	updatedAuraInfos = {  Optional table of information about changed auras.


		Key						Type		Description
		canApplyAura			boolean		Whether or not the player can apply this aura.
		debuffType				string		Type of debuff this aura applies. May be an empty string.
		isBossAura				boolean		Whether or not this aura was applied by a boss.
		isFromPlayerOrPlayerPet	boolean		Whether or not this aura was applied by the player or their pet.
		isHarmful				boolean		Whether or not this aura is a debuff.
		isHelpful				boolean		Whether or not this aura is a buff.
		isNameplateOnly			boolean		Whether or not this aura should appear on nameplates.
		isRaid					boolean		Whether or not this aura meets the conditions of the RAID aura filter.
		name					string		The name of the aura.
		nameplateShowAll		boolean		Whether or not this aura should be shown on all nameplates, instead of just the personal one.
		sourceUnit				UnitId		Token of the unit that applied the aura.
		spellId					number		The spell ID of the aura.
	}

	]]

	local function addPriority(aura)
		aura.Priority = BattleGroundEnemies:GetSpellPriority(aura.spellId)
		return aura
	end

	--packaged the aura into the new UnitAura packaged format (structure UnitAuraInfo)
	local function UnitAuraToUnitAuraInfo(filter, name, icon, count, debuffType, duration, expirationTime, unitCaster,
										  canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossAura,
										  castByPlayer, nameplateShowAll, timeMod, value1, value2, value3, value4)
		local aura
		if type(name) == "table" then --seems already packaged
			aura = name
		else
			local isDebuff = filter == "HARMFUL" or "HELPFUL"
			--package that stuff up
			aura = {
				applications = count,
				auraInstanceID = nil,
				canApplyAura = canApplyAura,
				charges = nil,
				dispelName = debuffType,
				duration = duration,
				expirationTime = expirationTime,
				icon = icon,
				isBossAura = isBossAura,
				isFromPlayerOrPlayerPet = castByPlayer,
				isHarmful = isDebuff,
				isHelpful = not isDebuff,
				isNameplateOnly = nil,
				isRaid = nil,
				isStealable = canStealOrPurge,
				maxCharges = nil,
				name = name,
				nameplateShowAll = nameplateShowAll,
				nameplateShowPersonal = nameplateShowPersonal,
				points = { value1, value2, value3, value4 }, --	array	Variable returns - Some auras return additional values that typically correspond to something shown in the tooltip, such as the remaining strength of an absorption effect.
				sourceUnit = unitCaster,
				spellId = spellId,
				timeMod = timeMod,
			}
		end
		aura = addPriority(aura)
		return aura
	end

	---comment
	---@param unitID UnitToken
	---@param second UnitAuraUpdateInfo
	---@param third any
	function buttonFunctions:UNIT_AURA(unitID, second, third)
		if not self.isShown then return end
		local now = GetTime()
		if self.lastAuraUpdate and self.lastAuraUpdate == now then return end --this event will fire for the same player multiple times if lets say he is shown on nameplate and on target frame

		local updatedAuraInfos = {
			addedAuras = {},
			isFullUpdate = true
		}

		if second and type(second) == "table" then --new 10.0 UNIT_AURA
			updatedAuraInfos = second
		end

		--[[

				third arg until patch 9.x (changed in 10.0)
				canApplyAura	boolean	Whether or not the player can apply this aura.
				debuffType	string	Type of debuff this aura applies. May be an empty string.
				isBossAura	boolean	Whether or not this aura was applied by a boss.
				isFromPlayerOrPlayerPet	boolean	Whether or not this aura was applied by the player or their pet.
				isHarmful	boolean	Whether or not this aura is a debuff.
				isHelpful	boolean	Whether or not this aura is a buff.
				isNameplateOnly	boolean	Whether or not this aura should appear on nameplates.
				isRaid	boolean	Whether or not this aura meets the conditions of the RAID aura filter.
				name	string	The name of the aura.
				nameplateShowAll	boolean	Whether or not this aura should be shown on all nameplates, instead of just the personal one.
				sourceUnit	UnitId	Token of the unit that applied the aura.
				spellId	number	The spell ID of the aura.



			10.0 second argument:

			addedAuras	UnitAuraInfo[]?	List of auras added to the unit during this update.
			updatedAuraInstanceIDs	number[]?	List of existing auras on the unit modified during this update.
			removedAuraInstanceIDs	number[]?	List of existing auras removed from the unit during this update.
			isFullUpdate	boolean	Wwhether or not a full update of the units' auras should be performed. If this is set, the other fields will likely be nil.


			structure UnitAuraInfo
			applications	number
			auraInstanceID	number
			canApplyAura	boolean
			charges	number
			dispelName	string?
			duration	number
			expirationTime	number
			icon	number
			isBossAura	boolean
			isFromPlayerOrPlayerPet	boolean
			isHarmful	boolean
			isHelpful	boolean
			isNameplateOnly	boolean
			isRaid	boolean
			isStealable	boolean
			maxCharges	number
			name	string
			nameplateShowAll	boolean
			nameplateShowPersonal	boolean
			points	array	Variable returns - Some auras return additional values that typically correspond to something shown in the tooltip, such as the remaining strength of an absorption effect.
			sourceUnit	string?
			spellId	number
			timeMod	number
		]]

		if updatedAuraInfos.isFullUpdate then
			local batchCount = 40 -- TODO make this a option the player can choose, maximum amount of buffs / debuffs
			local shouldQueryAuras

			for i = 1, #auraFilters do
				local filter = auraFilters[i]
				wipe(self.Auras[filter])
				if unitID then
					shouldQueryAuras = self:DispatchUntilTrue("ShouldQueryAuras", unitID, filter) --ask all subscribers/modules if Aura Scanning is necessary for this filter
					if shouldQueryAuras then
						if AuraUtil.ForEachAura then
							local usePackedAura = true --this will make the function AuraUtil.ForEachAura return a aura info table instead of many returns, added in 10.0
							AuraUtil.ForEachAura(unitID, filter, batchCount, function(...)
								local aura = UnitAuraToUnitAuraInfo(filter, ...)
								if aura.auraInstanceID then
									self.Auras[filter][aura.auraInstanceID] = aura
								else
									table_insert(self.Auras[filter], aura)
								end
							end, usePackedAura)
						else
							for j = 1, batchCount do
								local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossAura, castByPlayer, nameplateShowAll, timeMod, value1, value2, value3, value4 =
									UnitAura(unitID, j, filter)

								if not name then break end

								local aura = UnitAuraToUnitAuraInfo(filter, name, icon, count, debuffType, duration,
									expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, spellId,
									canApplyAura, isBossAura, castByPlayer, nameplateShowAll, timeMod, value1, value2,
									value3, value4)
								if aura.auraInstanceID then
									self.Auras[filter][aura.auraInstanceID] = aura
								else
									table_insert(self.Auras[filter], aura)
								end
							end
						end
					end
				else
					if self.PlayerDetails.isFakePlayer then
						for j = 1, batchCount do
							local aura = FakeUnitAura(self, j, filter)
							if aura then
								table_insert(self.Auras[filter], addPriority(aura))
							end
						end
					end
				end
			end
		else
			local addedAuras = updatedAuraInfos.addedAuras
			if addedAuras ~= nil then
				for i = 1, #addedAuras do
					local addedAura = addedAuras[i]
					self.Auras[Data.Helpers.getFilterFromAuraInfo(addedAura)][addedAura.auraInstanceID] = addPriority(addedAura)
				end
			end

			local updatedAuraInstanceIDs = updatedAuraInfos.updatedAuraInstanceIDs
			if updatedAuraInstanceIDs ~= nil then
				for i = 1, #updatedAuraInstanceIDs do
					local auraInstanceID = updatedAuraInstanceIDs[i]
					local updatedAura = C_UnitAuras.GetAuraDataByAuraInstanceID(unitID, auraInstanceID)
					if updatedAura then
						if self.Auras.HELPFUL[auraInstanceID] then
							self.Auras.HELPFUL[auraInstanceID] = addPriority(updatedAura)
						elseif self.Auras.HARMFUL[auraInstanceID] then
							self.Auras.HARMFUL[auraInstanceID] = addPriority(updatedAura)
						end
					end
				end
			end

			local removedAuraInstanceIDs = updatedAuraInfos.removedAuraInstanceIDs
			if removedAuraInstanceIDs ~= nil then
				for i = 1, #removedAuraInstanceIDs do
					local auraInstanceID = removedAuraInstanceIDs[i]
					if self.Auras.HELPFUL[auraInstanceID] ~= nil then
						self.Auras.HELPFUL[auraInstanceID] = nil
					end
					if self.Auras.HARMFUL[auraInstanceID] ~= nil then
						self.Auras.HARMFUL[auraInstanceID] = nil
					end
				end
			end
		end

		for i = 1, #auraFilters do
			local filter = auraFilters[i]
			self:DispatchEvent("BeforeFullAuraUpdate", filter)
			for _, aura in pairs(self.Auras[filter]) do
				self:DispatchEvent("NewAura", unitID, filter, aura)
			end
			self:DispatchEvent("AfterFullAuraUpdate", filter)
		end
		self.lastAuraUpdate = now
	end

	buttonFunctions.UNIT_HEALTH_FREQUENT = buttonFunctions.UNIT_HEALTH --TBC compability, IsTBCC
	buttonFunctions.UNIT_MAXHEALTH = buttonFunctions.UNIT_HEALTH
	buttonFunctions.UNIT_HEAL_PREDICTION = buttonFunctions.UNIT_HEALTH
	buttonFunctions.UNIT_ABSORB_AMOUNT_CHANGED = buttonFunctions.UNIT_HEALTH
	buttonFunctions.UNIT_HEAL_ABSORB_AMOUNT_CHANGED = buttonFunctions.UNIT_HEALTH


	function buttonFunctions:UNIT_POWER_FREQUENT(unitID, powerToken) --gets power of nameplates, player, target, focus, raid1 to raid40, partymember
		if not self.isShown then return end
		self:DispatchEvent("UpdatePower", unitID, powerToken)
	end

	-- returns true if the other button is a enemy from the point of view of the button. True if button is ally and other button is enemy, and vice versa
	function buttonFunctions:IsEnemyToMe(playerButton)
		return self.PlayerIsEnemy ~= playerButton.PlayerIsEnemy
	end

	function buttonFunctions:UpdateTargetedByEnemy(playerButton, targeted)
		local unitIDs = self.UnitIDs
		unitIDs.TargetedByEnemy[playerButton] = targeted
		self:UpdateTargetIndicators()

		if self.PlayerIsEnemy then
			local allyUnitID = false

			for allyBtn in pairs(unitIDs.TargetedByEnemy) do
				if allyBtn ~= UserButton then
					allyUnitID = allyBtn.TargetUnitID
					break
				end
			end
			self:UpdateEnemyUnitID("Ally", allyUnitID)
		end
	end

	function buttonFunctions:IsNowTargeting(playerButton)
		--BattleGroundEnemies:LogToSavedVariables("IsNowTargeting", self.PlayerName, self.unitID, playerButton.PlayerName)
		self.Target = playerButton

		if not self:IsEnemyToMe(playerButton) then return end --we only care of the other player is of opposite faction

		playerButton:UpdateTargetedByEnemy(self, true)
	end

	function buttonFunctions:IsNoLongerTarging(playerButton)
		--BattleGroundEnemies:LogToSavedVariables("IsNoLongerTarging", self.PlayerName, self.unitID, playerButton.PlayerName)
		self.Target = nil

		if not self:IsEnemyToMe(playerButton) then return end --we only care of the other player is of opposite faction

		playerButton:UpdateTargetedByEnemy(self, nil)
	end

	function buttonFunctions:UpdateTarget()
		--BattleGroundEnemies:LogToSavedVariables("UpdateTarget", self.PlayerName, self.unitID)

		local oldTargetPlayerButton = self.Target
		local newTargetPlayerButton

		if self.TargetUnitID then
			newTargetPlayerButton = BattleGroundEnemies:GetPlayerbuttonByUnitID(self.TargetUnitID)
		end


		if oldTargetPlayerButton then
			--BattleGroundEnemies:LogToSavedVariables("UpdateTarget", "oldTargetPlayerButton", self.PlayerName, self.unitID, oldTargetPlayerButton.PlayerName, oldTargetPlayerButton.unitID)

			if newTargetPlayerButton and oldTargetPlayerButton == newTargetPlayerButton then return end
			self:IsNoLongerTarging(oldTargetPlayerButton)
		end

		--player didnt have a target before or the player targets a new player

		if newTargetPlayerButton then --player targets an existing player and not for example a pet or a NPC
			--BattleGroundEnemies:LogToSavedVariables("UpdateTarget", "newTargetPlayerButton", self.PlayerName, self.unitID, newTargetPlayerButton.PlayerName, newTargetPlayerButton.unitID)
			self:IsNowTargeting(newTargetPlayerButton)
		end
	end

	function buttonFunctions:DispatchEvent(event, ...)
		if not self.ButtonEvents then return end

		local moduleFrames = self.ButtonEvents[event]

		if not moduleFrames then return end
		for i = 1, #moduleFrames do
			local moduleFrameOnButton = moduleFrames[i]
			if moduleFrameOnButton[event] then
				moduleFrameOnButton[event](moduleFrameOnButton, ...)
			else
				BattleGroundEnemies:OnetimeInformation("Event:", event,
					"There is no key with the event name for this module", moduleFrameOnButton.moduleName)
			end
		end
	end

	-- used for the AuraInfo (third return of UNIT_AURA) of UNIT_AURA, we dispatch until one of the consumers (modules) returns true, then we proceed with aura scanning
	function buttonFunctions:DispatchUntilTrue(event, ...)
		local moduleFrames = self.ButtonEvents[event]
		if not moduleFrames then return end

		for i = 1, #moduleFrames do
			local moduleFrameOnButton = moduleFrames[i]
			if moduleFrameOnButton[event] then
				if moduleFrameOnButton[event](moduleFrameOnButton, ...) then return true end
			else
				BattleGroundEnemies:OnetimeInformation("Event:", event,
					"There is no key with the event name for this module", moduleFrameOnButton.moduleName)
			end
		end
	end

	function buttonFunctions:GetAnchor(relativeFrame)
		return relativeFrame == "Button" and self or self[relativeFrame]
	end
end


local function CreateMainFrame(playerType)
	local mainframe = CreateFrame("Frame", nil, BattleGroundEnemies)
	mainframe.Players = {}            --index = name, value = button(table), contains enemyButtons
	mainframe.CurrentPlayerOrder = {} --index = number, value = playerButton(table)
	mainframe.InactivePlayerButtons = {} --index = number, value = button(table)
	mainframe.NewPlayersDetails = {}  -- index = numeric, value = playerdetails, used for creation of new buttons, use (temporary) table to not create an unnecessary new button if another player left
	mainframe.PlayerType = playerType
	mainframe.PlayerSources = {}
	mainframe.NumPlayers = 0
    mainframe.Counter = {}

    mainframe.Counter = {}


    mainframe:Hide()
    mainframe:SetScript("OnEvent", function(self, event, ...)
        --self.Counter[event] = (self.Counter[event] or 0) + 1
        --BattleGroundEnemies:Debug("Enemies OnEvent", event, ...)
        self[event](self, ...)
    end)


	function mainframe:InitializeAllPlayerSources()
		for sourceName in pairs(BattleGroundEnemies.consts.PlayerSources) do
			mainframe.PlayerSources[sourceName] = {}
		end
	end

	mainframe:InitializeAllPlayerSources()
	mainframe.config = BattleGroundEnemies.db.profile[playerType]

	function mainframe:RemoveAllPlayersFromAllSources()
		self:InitializeAllPlayerSources()
		self:AfterPlayerSourceUpdate()
	end

	function mainframe:RemoveAllPlayersFromSource(source)
		self:BeforePlayerSourceUpdate(source)
		self:AfterPlayerSourceUpdate()
	end

	function mainframe:BeforePlayerSourceUpdate(source)
		self.PlayerSources[source] = {}
	end

	function mainframe:AddPlayerToSource(source, playerT)
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
		local foundPlayer = false
		local foundMatchIndex
		for i = 1, #scoreTables do
			local scoreInfo = scoreTables[i]

			-- local faction = scoreInfo.faction
			-- local name = scoreInfo.name
			-- local classToken = scoreInfo.classToken
			-- local specName = scoreInfo.talentSpec
			-- local raceName = scoreInfo.raceName

			if scoreInfo.classToken and arenaPlayerInfo.classTag then
				if scoreInfo.faction == BattleGroundEnemies.EnemyFaction and scoreInfo.classToken == arenaPlayerInfo.classTag and scoreInfo.talentSpec == arenaPlayerInfo.specName then --specname/talentSpec can be nil for old expansions
					if foundPlayer then
						return false                                                                                                                                        -- we already had a match but found a second player that matches, unlucky
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
		local newPlayers = {} --contains combined data from PlayerSources
		if self.PlayerType == BattleGroundEnemies.consts.PlayerTypes.Enemies then
			if BattleGroundEnemies.Testmode.Active then
				newPlayers = self.PlayerSources[BattleGroundEnemies.consts.PlayerSources.FakePlayers]
			else
				local scoreboardEnemies = self.PlayerSources[BattleGroundEnemies.consts.PlayerSources.Scoreboard]
				local numScoreboardEnemies = #scoreboardEnemies
				local addScoreBoardPlayers = false
				if BattleGroundEnemies.states.isInArena then
					--use arenaPlayers is primary source
					local arenaEnemies = self.PlayerSources[BattleGroundEnemies.consts.PlayerSources.ArenaPlayers]
					local numArenaEnemies = #arenaEnemies
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
									--BattleGroundEnemies:LogToSavedVariables("found a match")
									playerName = match.name
								else
									--BattleGroundEnemies:LogToSavedVariables("didnt find a match", arenaEnemy.additionalData.PlayerArenaUnitID)
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
						if self.IsRatedBG and IsRetail then
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
							classTag = scoreboardEnemy.classToken,
							specName = scoreboardEnemy.talentSpec
						})
					end
				end
			end
		else --"Allies"
			local groupMembers = self.PlayerSources[BattleGroundEnemies.consts.PlayerSources.GroupMembers]
			local numGroupMembers = #groupMembers
			local addWholeGroup = false
			if BattleGroundEnemies.Testmode.Active then
				if BattleGroundEnemies.db.profile.Testmode_UseTeammates then
					addWholeGroup = true
				else
					--just addMyself and fill up the rest with fakeplayers
					if UserButton.PlayerDetails then
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
						--BattleGroundEnemies:LogToSavedVariables("player", name, "doesnt have a spec from group member")
						local match = self:FindPlayerInSource(BattleGroundEnemies.consts.PlayerSources.Scoreboard, groupMember)
						if match then
							--BattleGroundEnemies:LogToSavedVariables("player", name, "we found a spec from the scoreboard")
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
			local classTag = newPlayer.classTag
			local specName = newPlayer.specName
			local additionalData = newPlayer.additionalData
			self:CreateOrUpdatePlayerDetails(name, raceName, classTag, specName, additionalData)
		end
		self:SetPlayerCount(#newPlayers)
		self:CreateOrRemovePlayerButtons()
	end

	function mainframe:Enable()
		--BattleGroundEnemies:LogToSavedVariables(self.PlayerType, "enabled")

		if BattleGroundEnemies.Testmode.Active then
		else
			if self.PlayerType == BattleGroundEnemies.consts.PlayerTypes.Enemies then
				--BattleGroundEnemies:LogToSavedVariables("Registered enemie events")
				self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
				self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
				self:RegisterEvent("UNIT_NAME_UPDATE")
				if HasSpeccs then
					self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
				end
			end


			if BattleGroundEnemies.states.isInArena or BattleGroundEnemies.states.IsInBattleground then
				BattleGroundEnemies:CheckForArenaEnemies()
			end
		end
		self:Show()
	end

	function mainframe:Disable()
		--BattleGroundEnemies:LogToSavedVariables(self.PlayerType, "disabled")
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

		self:SetSize(conf.BarWidth, 30)
		self:SetScale(conf.Framescale)

		self:ClearAllPoints()
		if not conf.Position_X and not conf.Position_Y then
			self:SetPoint("CENTER", UIParent, "CENTER")
		else
			local scale = self:GetEffectiveScale()
			self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", conf.Position_X / scale, conf.Position_Y / scale)
		end
		self:SetPlayerCountJustifyV(conf.BarVerticalGrowdirection)

		self.PlayerCount:ApplyFontStringSettings(conf.PlayerCount.Text)

		self:SortPlayers(true) --force repositioning

		for name, playerButton in pairs(self.Players) do
			playerButton:ApplyButtonSettings()
			playerButton:SetBindings()
		end


		for number, playerButton in pairs(self.InactivePlayerButtons) do
			playerButton:ApplyButtonSettings()
		end

		self:UpdatePlayerCount()
		self:CheckEnableState()
	end

	function mainframe:GetPlayerCountsFromConfig(playerCountConfig)
		if type(playerCountConfig) ~= "table" then
			error("playerCountConfig must be a table")
		end
		local minPlayers = playerCountConfig.minPlayerCount
		local maxPlayers = playerCountConfig.maxPlayerCount
		return minPlayers, maxPlayers
	end

	function mainframe:GetPlayerCountConfigName(playerCountConfig)
		local minPlayers, maxPlayers = self:GetPlayerCountsFromConfig(playerCountConfig)
		return minPlayers.."–"..maxPlayers.. " ".. L.players
	end

	function mainframe:SelectPlayerCountProfile(forceUpdate)
		self.config = BattleGroundEnemies.db.profile[self.PlayerType]
		local maxNumPlayers = math_max(self.NumPlayers or 0)
		--BattleGroundEnemies:LogToSavedVariables("SelectPlayerCountProfile", MaxNumPlayers)
		if not maxNumPlayers then return end
		if maxNumPlayers == 0 then return self:NoActivePlayercountProfile() end

		if maxNumPlayers > 40 then
			self:Disable()
			return
		end

		local playerCountConfigs
		if self.config.CustomPlayerCountConfigsEnabled then
			playerCountConfigs = self.config.customPlayerCountConfigs
		else
			playerCountConfigs = self.config.playerCountConfigs
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
				local overlappingIndexShownName = self:GetPlayerCountConfigName(foundProfilesForPlayerCount[i])
				overlappingProfilesString = overlappingProfilesString .. "and " .. overlappingIndexShownName
			end
			self:NoActivePlayercountProfile()
			BattleGroundEnemies:Information("Founds multiple player count profiles fitting the current player count for "..self.PlayerType.." please  check your settings and make sure they don't overlap")
			BattleGroundEnemies:Information("The following profiles are overlapping: "..overlappingProfilesString)

			return
		end



		if forceUpdate or foundProfilesForPlayerCount[1] ~= self.playerCountConfig then
			self.playerCountConfig = foundProfilesForPlayerCount[1]
			self:ApplyPlayerCountProfileSettings()
		end
	end

	function mainframe:CheckEnableState()
		if self.config.Enabled and self.playerCountConfig and self.playerCountConfig.Enabled then
			if BattleGroundEnemies.states.isInArena and not BattleGroundEnemies.db.profile.ShowBGEInArena then
				return self:Disable()
			end
			if BattleGroundEnemies.states.IsInBattleground and not BattleGroundEnemies.db.profile.ShowBGEInBattleground then
				return self:Disable()
			end
			self:Enable()
		else
			self:Disable()
		end
	end

	function mainframe:SetRealPlayerCount(realCount)
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
		--BattleGroundEnemies:LogToSavedVariables("UpdatePlayerCount", currentCount)


		local maxNumPlayers = math_max(self.RealPlayerCount or 0, self.NumPlayers or 0)


		local isEnemy = self.PlayerType == BattleGroundEnemies.consts.PlayerTypes.Enemies
		BattleGroundEnemies:SetEnemyFaction(BattleGroundEnemies.EnemyFaction or (BattleGroundEnemies.UserFaction == "Horde" and 1 or 0))

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

			if playerButton.Auras then
				if playerButton.Auras.HELPFUL then
					wipe(playerButton.Auras.HELPFUL)
				end
				if playerButton.Auras.HARMFUL then
					wipe(playerButton.Auras.HARMFUL)
				end
			end

			playerButton.unitID = nil
			playerButton.unit = nil
		else --no recycleable buttons remaining => create a new one
			self.buttonCounter = (self.buttonCounter or 0) + 1
			playerButton = CreateFrame('Button', "BattleGroundEnemies" .. self.PlayerType .. "frame" ..
			self.buttonCounter, self, 'SecureUnitButtonTemplate')
			playerButton:RegisterForClicks('AnyUp')
			playerButton:Hide()
			-- setmetatable(playerButton, self)
			-- self.__index = self


			playerButton.ButtonEvents = playerButton.ButtonEvents or {}
			playerButton.UnitIDs = { TargetedByEnemy = {} }
			playerButton.Auras = {
				HELPFUL = {},
				HARMFUL = {}
			}


			playerButton.PlayerType = self.PlayerType
			playerButton.PlayerIsEnemy = playerButton.PlayerType == BattleGroundEnemies.consts.PlayerTypes.Enemies and true or false

			playerButton:SetScript("OnSizeChanged", function(self, width, height)
				--self.DRContainer:SetWidthOfAuraFrames(height)
				self:DispatchEvent("PlayerButtonSizeChanged", width, height)
			end)

			Mixin(playerButton, buttonFunctions)

			if playerButton.PlayerIsEnemy then
				Mixin(playerButton, enemyButtonFunctions)
			end

			playerButton.Counter = {}
			playerButton:SetScript("OnEvent", function(self, event, ...)
				--self.Counter[event] = (self.Counter[event] or 0) + 1

				self[event](self, ...)
			end)
			playerButton:SetScript("OnShow", function()
				playerButton.isShown = true
			end)
			playerButton:SetScript("OnHide", function()
				playerButton.isShown = false
			end)

			-- events/scripts
			playerButton:RegisterForDrag('LeftButton')
			playerButton:SetClampedToScreen(true)

			playerButton:SetScript('OnDragStart', playerButton.OnDragStart)
			playerButton:SetScript('OnDragStop', playerButton.OnDragStop)


			--MyTarget, indicating the current target of the player
			playerButton.MyTarget = CreateFrame('Frame', nil, playerButton.healthBar,
				BackdropTemplateMixin and "BackdropTemplate")

			playerButton.MyTarget:Hide()

			--MyFocus, indicating the current focus of the player
			playerButton.MyFocus = CreateFrame('Frame', nil, playerButton.healthBar,
				BackdropTemplateMixin and "BackdropTemplate")
			playerButton.MyFocus:SetBackdrop({
				bgFile = "Interface/Buttons/WHITE8X8", --drawlayer "BACKGROUND"
				edgeFile = 'Interface/Buttons/WHITE8X8', --drawlayer "BORDER"
				edgeSize = 1
			})
			playerButton.MyFocus:SetBackdropColor(0, 0, 0, 0)
			playerButton.MyFocus:Hide()

			playerButton.ButtonModules = {}
			for moduleName, moduleFrame in pairs(BattleGroundEnemies.ButtonModules) do
				if moduleFrame.AttachToPlayerButton then
					moduleFrame:AttachToPlayerButton(playerButton)

					if not playerButton[moduleName] then
						print("something went wrong here after AttachToPlayerButton",
							moduleName)
					end

					playerButton[moduleName].GetConfig = function(self)
						self.config = playerButton.playerCountConfig.ButtonModules[moduleName]
						return self.config
					end
					playerButton[moduleName].moduleName = moduleName
				end
			end

			playerButton:ApplyButtonSettings()
		end


		playerButton.PlayerDetails = playerDetails
		-- BattleGroundEnemies:LogToSavedVariables("PlayerDetailsChanged")
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
						if BattleGroundEnemies.PlayerIsAlive then
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
						if BattleGroundEnemies.PlayerIsAlive then
							if playerButton ~= UserButton then
								--BattleGroundEnemies:Debug(IsItemInRange(self.config.RangeIndicator_Range, allyButton.unitID), self.config.RangeIndicator_Range, allyButton.unitID)
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

		playerButton:UNIT_AURA()
		playerButton:Show()

		self.Players[playerButton.PlayerDetails.PlayerName] = playerButton

		return playerButton
	end

	function mainframe:RemovePlayer(playerButton)
		if playerButton == UserButton then return end -- dont remove the Player itself

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

	function mainframe:ButtonPositioning()
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

		local pointX, offsetX, offsetY, pointY, relPointY, offsetDirectionX, offsetDirectionY

		if growRightwards then
			pointX = "LEFT"
			offsetDirectionX = 1
		else
			pointX = "RIGHT"
			offsetDirectionX = -1
		end

		if growDownwards then
			pointY = "TOP"
			relPointY = "BOTTOM"
			offsetDirectionY = -1
		else
			pointY = "BOTTOM"
			relPointY = "TOP"
			offsetDirectionY = 1
		end

		local point = pointY .. pointX
		local relpoint = relPointY .. pointX

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
				playerButton:SetPoint(point, self, relpoint, offsetX, offsetY)

				playerButton:SetModulePositions()


				if row < rowsPerColumn then
					row = row + 1
				else
					column = column + 1
					row = 1
				end
			end
		end
	end

	function mainframe:BeforePlayerUpdate()
		wipe(self.NewPlayersDetails)
	end

	function mainframe:CreateOrUpdatePlayerDetails(name, race, classTag, specName, additionalData)
		local spec = false
		if specName and specName ~= "" then
			spec = specName
		end
		local specData
		if classTag and spec then
			local t = Data.Classes[classTag]
			if t then
				specData = t[spec]
			end
		end

		local playerDetails = {
			PlayerName = name,
			PlayerClass = string.upper(classTag),                  --apparently it can happen that we get a lowercase "druid" from GetBattlefieldScore() in TBCC, IsTBCC
			PlayerClassColor = RAID_CLASS_COLORS[classTag],
			PlayerRace = race and LibRaces:GetRaceToken(race) or "Unknown", --delivers a locale independent token for relentless check
			PlayerSpecName = spec,                                 --set to false since we use Mixin() and Mixin doesnt mixin nil values and therefore we dont overwrite values with nil
			PlayerRoleNumber = specData and specData.roleNumber,
			PlayerLevel = false,
			isFakePlayer = false, --to set a base value, might be overwritten by mixin
			PlayerArenaUnitID = nil --to set a base value, might be overwritten by mixin
		}
		if additionalData then
			Mixin(playerDetails, additionalData)
		end

		-- BattleGroundEnemies:LogToSavedVariables("CreateOrUpdatePlayerDetails", name, race, classTag, specName, additionalData)
		local playerButton = self.Players[name]
		if playerButton then --already existing
			local currentDetails = playerButton.PlayerDetails
			local detailsChanged = false

			for k, v in pairs(playerDetails) do
				if v ~= currentDetails[k] then
					detailsChanged = true
					-- BattleGroundEnemies:LogToSavedVariables("k changed1", k)
					break
				end
			end

			if not detailsChanged then
				for k, v in pairs(currentDetails) do
					if v ~= playerDetails[k] then
						detailsChanged = true
						-- BattleGroundEnemies:LogToSavedVariables("k changed2", k)
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

			if detailsPlayerA.PlayerRoleNumber and detailsPlayerB.PlayerRoleNumber then
				if detailsPlayerA.PlayerRoleNumber == detailsPlayerB.PlayerRoleNumber then
					if BlizzardsSortOrder[detailsPlayerA.PlayerClass] == BlizzardsSortOrder[detailsPlayerB.PlayerClass] then
						if detailsPlayerA.PlayerName < detailsPlayerB.PlayerName then return true end
					elseif BlizzardsSortOrder[detailsPlayerA.PlayerClass] < BlizzardsSortOrder[detailsPlayerB.PlayerClass] then
						return true
					end
				elseif detailsPlayerA.PlayerRoleNumber < detailsPlayerB.PlayerRoleNumber then
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
			if not (detailsPlayerA.unitID and detailsPlayerB.unitID) then return true end
			if (detailsPlayerA.unitID == "player") then
				return true;
			elseif (detailsPlayerB.unitID == "player") then
				return false;
			else
				return detailsPlayerA.unitID < detailsPlayerB.unitID; --String compare is OK since we don't go above 1 digit for party.
			end
		end

		function mainframe:SortPlayers(forceRepositioning)
			--BattleGroundEnemies:LogToSavedVariables("SortPlayers", self.PlayerType)
			local newPlayerOrder = {}
			for playerName, playerButton in pairs(self.Players) do
				-- BattleGroundEnemies:LogToSavedVariables(playerName)
				table.insert(newPlayerOrder, playerButton)
			end
			--[[
			BattleGroundEnemies:LogToSavedVariables("before sorting")
			for i = 1, #newPlayerOrder do
				BattleGroundEnemies:LogToSavedVariables(i, newPlayerOrder[i].PlayerDetails.PlayerName)
			end

 ]]

			if BattleGroundEnemies.states.isInArena then
				if (self.PlayerType == BattleGroundEnemies.consts.PlayerTypes.Enemies) then
					local usePlayerSortingByArenaUnitID = false
					usePlayerSortingByArenaUnitID = true
					for i = 1, #newPlayerOrder do
						if not newPlayerOrder[i].PlayerDetails.PlayerArenaUnitID then
							usePlayerSortingByArenaUnitID = false
							break
						end
					end
					if usePlayerSortingByArenaUnitID then
						-- BattleGroundEnemies:LogToSavedVariables("usePlayerSortingByArenaUnitID", self.PlayerType)
						table.sort(newPlayerOrder, PlayerSortingByArenaUnitID)
					else
						-- BattleGroundEnemies:LogToSavedVariables("dont usePlayerSortingByArenaUnitID", self.PlayerType)
						table.sort(newPlayerOrder, PlayerSortingByRoleClassName)
					end
				else
					table.sort(newPlayerOrder, CRFSort_Group_)
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

			--[[ 			BattleGroundEnemies:LogToSavedVariables("after sorting")
			for i = 1, #newPlayerOrder do
				BattleGroundEnemies:LogToSavedVariables(i, newPlayerOrder[i].PlayerDetails.PlayerName)
			end ]]


			if orderChanged or forceRepositioning then
				local inCombat = InCombatLockdown()
				if inCombat then
					return BattleGroundEnemies:QueueForUpdateAfterCombat(self, "AfterPlayerSourceUpdate")
				end
				self.CurrentPlayerOrder = newPlayerOrder
				self:ButtonPositioning()
			end
		end
	end


	mainframe:SetClampedToScreen(true)
	mainframe:SetMovable(true)
	mainframe:SetUserPlaced(true)
	mainframe:SetResizable(true)
	mainframe:SetToplevel(true)

	mainframe.PlayerCount = BattleGroundEnemies.MyCreateFontString(mainframe)
	mainframe.PlayerCount:SetAllPoints()
	mainframe.PlayerCount:SetJustifyH("LEFT")

    return mainframe
end

BattleGroundEnemies.Allies = CreateMainFrame(BattleGroundEnemies.consts.PlayerTypes.Allies)
BattleGroundEnemies.Allies.GUIDToAllyname = {}



BattleGroundEnemies.Enemies = CreateMainFrame(BattleGroundEnemies.consts.PlayerTypes.Enemies)
BattleGroundEnemies.Enemies.Counter = {}


function BattleGroundEnemies.Allies:GroupInSpecT_Update(event, GUID, unitID, info)
	if not GUID or not info.class then return end

	BattleGroundEnemies.specCache[GUID] = info.spec_name_localized

	BattleGroundEnemies:GROUP_ROSTER_UPDATE()
end