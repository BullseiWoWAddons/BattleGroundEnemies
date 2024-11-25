---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)

---@class BattleGroundEnemies
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L


local IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local IsTBCC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local IsWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC

local SetRaidTargetIconTexture = SetRaidTargetIconTexture

local GetTexCoordsForRoleSmallCircle = GetTexCoordsForRoleSmallCircle or function(role)
	if ( role == "TANK" ) then
		return 0, 19/64, 22/64, 41/64;
	elseif ( role == "HEALER" ) then
		return 20/64, 39/64, 1/64, 20/64;
	elseif ( role == "DAMAGER" ) then
		return 20/64, 39/64, 22/64, 41/64;
	else
		error("Unknown role: "..tostring(role));
	end
end



--WoW API
local C_PvP = C_PvP
local C_UnitAuras = C_UnitAuras
local CreateFrame = CreateFrame
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local IsItemInRange = IsItemInRange
local RequestCrowdControlSpell = C_PvP.RequestCrowdControlSpell
local UnitExists = UnitExists
local UnitIsDeadOrGhost = UnitIsDeadOrGhost

--lua
local _G = _G
local math_floor = math.floor
local math_random = math.random
local math_min = math.min
local pairs = pairs
local print = print
local table_insert = table.insert
local table_remove = table.remove
local time = time
local type = type
local unpack = unpack


--Libs
local LSM = LibStub("LibSharedMedia-3.0")
local LRC = LibStub("LibRangeCheck-3.0")



local auraFilters = { "HELPFUL", "HARMFUL" }
---comment
---@param playerButton any
---@param index number
---@param filter string
---@return AuraData
local function FakeUnitAura(playerButton, index, filter)
	local fakePlayerAuras = BattleGroundEnemies.Testmode.FakePlayerAuras
	local aura = fakePlayerAuras[playerButton][filter][index]
	return aura
end

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
		self:WipeAllAuras()
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
        if self.PlayerType == BattleGroundEnemies.consts.PlayerTypes.Enemies then
            return BattleGroundEnemies.Allies
        else
            return BattleGroundEnemies.Enemies
        end
	end

	function buttonFunctions:Debug(...)
		return BattleGroundEnemies:Debug(self.PlayerDetails.PlayerName, ...)
	end 

	function buttonFunctions:OnDragStart()
		return BattleGroundEnemies.db.profile.Locked or self:GetParent():StartMoving()
	end

	function buttonFunctions:OnDragStop()
		local parent = self:GetParent()
		parent:StopMovingOrSizing()
		if not InCombatLockdown() then
			local scale = self:GetEffectiveScale()

			local growDownwards = (self.playerCountConfig.BarVerticalGrowdirection == "downwards")
			local growRightwards = (self.playerCountConfig.BarHorizontalGrowdirection == "rightwards")

			if growDownwards then
				self.playerCountConfig.Position_Y = parent:GetTop() * scale
			else
				self.playerCountConfig.Position_Y = parent:GetBottom() * scale
			end

			if growRightwards then
				self.playerCountConfig.Position_X = parent:GetLeft() * scale
			else
				self.playerCountConfig.Position_X = parent:GetRight() * scale
			end
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
		--BattleGroundEnemies:Debug("UpdateAll", unitID, updateStuffWithEvents)
		if not unitID then return end
		--BattleGroundEnemies:Debug("UpdateAll", 1)

		if not UnitExists(unitID) then return end

		--this further checks dont seem necessary since they dont seem to rule out any other unitiDs (all unit ids that exist also are a button and are also this frame)


		--[[ BattleGroundEnemies:Debug("UpdateAll", 2)

		local playerButton = BattleGroundEnemies:GetPlayerbuttonByUnitID(unitID)

		if not playerButton then return end
		BattleGroundEnemies:Debug("UpdateAll", 3)
		if playerButton ~= self then return	end
		BattleGroundEnemies:Debug("UpdateAll", 4) ]]


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
		self:ApplyModuleSettings()
	end

	function buttonFunctions:UpdateRaidTargetIcon(forceIndex)
		local unit = self:GetUnitID()
		local newIndex = forceIndex --used for testmode, otherwise it will just be nil and overwritten when one actually exists
		if unit then
			newIndex = GetRaidTargetIndex(unit)
			if newIndex then
				if newIndex == 8 and (not self.RaidTargetIconIndex or self.RaidTargetIconIndex ~= 8) then
					if BattleGroundEnemies.states.isRatedBG and BattleGroundEnemies.db.profile.RBG.TargetCalling_NotificationEnable then
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
		local moduleConfigOnButton = {}

		if not self.playerCountConfig then return end

		local playerSizeModuleConfig = self.playerCountConfig.ButtonModules[moduleName]

		local globalModuleConfig = BattleGroundEnemies.db.profile.ButtonModules[moduleName] or {}

		Mixin(moduleConfigOnButton, globalModuleConfig, playerSizeModuleConfig)


		if moduleConfigOnButton.Enabled and BattleGroundEnemies:IsModuleEnabledOnThisExpansion(moduleName) then
			moduleFrameOnButton.Enabled = true
		else
			moduleFrameOnButton.Enabled = false
		end
		moduleFrameOnButton.config = moduleConfigOnButton
	end

	function buttonFunctions:SetAllModuleConfigs()
		for moduleName, moduleFrame in pairs(BattleGroundEnemies.ButtonModules) do
			self:SetModuleConfig(moduleName)
		end
	end

	function buttonFunctions:CallExistingFuncOnAllButtonModuleFrames(funcName, ...)
		for moduleName, moduleFrame in pairs(BattleGroundEnemies.ButtonModules) do
			local moduleFrameOnButton = self[moduleName]
			if moduleFrameOnButton then
				if moduleFrameOnButton and type(moduleFrameOnButton[funcName]) == "function" then
					moduleFrameOnButton[funcName](moduleFrameOnButton, ...)
				end
 			end
		end
	end

	function buttonFunctions:CallExistingFuncOnAllEnabledButtonModuleFrames(funcName, ...)
		for moduleName, moduleFrame in pairs(BattleGroundEnemies.ButtonModules) do
			local moduleFrameOnButton = self[moduleName]
			if moduleFrameOnButton then
				if moduleFrameOnButton.Enabled then
					if type(moduleFrameOnButton[funcName]) == "function" then
						moduleFrameOnButton[funcName](moduleFrameOnButton, ...)
					end
				end
 			end
		end
	end

	function buttonFunctions:CallFuncOnAllButtonModuleFrames(func)
		for moduleName, moduleFrame in pairs(BattleGroundEnemies.ButtonModules) do
			local moduleFrameOnButton = self[moduleName]
			if moduleFrameOnButton then
				func(self, moduleFrameOnButton)
 			end
		end
	end

	function buttonFunctions:CallFuncOnAllEnabledButtonModuleFrames(func)
		for moduleName, moduleFrame in pairs(BattleGroundEnemies.ButtonModules) do
			local moduleFrameOnButton = self[moduleName]
			if moduleFrameOnButton then
				if moduleFrameOnButton.Enabled then
					func(self, moduleFrameOnButton)
				end
 			end
		end
	end

	function buttonFunctions:SetModulePositions()
		if not self:GetRect() then return end --the position of the button is not set yet
		local i = 1
		repeat                          -- we basically run this roop to get out of the anchring hell (making sure all the frames that a module is depending on is set)
			local allModulesSet = true
			for moduleName, moduleFrame in pairs(BattleGroundEnemies.ButtonModules) do
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
									local scale = (moduleFrameOnButton.config.Scale or 1)
									moduleFrameOnButton:SetScale(scale)
									if relativeFrame:GetNumPoints() > 0 then
										local effectiveScale = moduleFrameOnButton:GetEffectiveScale()
										moduleFrameOnButton:SetPoint(pointConfig.Point, relativeFrame,
											pointConfig.RelativePoint, (pointConfig.OffsetX or 0) / effectiveScale, (pointConfig.OffsetY or 0) / effectiveScale)
									else
										-- the module we are depending on hasn't been set yet
										allModulesSet = false
										--BattleGroundEnemies:Debug("moduleName", moduleName, "isnt set yet")
									end
								else
									return print("error", relativeFrame, "for module", moduleName, "doesnt exist")
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
			i = i + 1

			if i > 10 then
				self:Debug("something went wrong in ApplyModuleSettings")
			end
		until allModulesSet or i > 10 --maxium of 10 tries
		self.MyTarget:SetParent(self.healthBar)
		self.MyTarget:SetPoint("TOPLEFT", self.healthBar, "TOPLEFT")
		self.MyTarget:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMRIGHT")
		self.MyFocus:SetParent(self.healthBar)
		self.MyFocus:SetPoint("TOPLEFT", self.healthBar, "TOPLEFT")
		self.MyFocus:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMRIGHT")
	end

	function buttonFunctions:ApplyModuleSettings()
		wipe(self.ButtonEvents)
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

	function buttonFunctions:SetConfigShortCuts()
		self.config = BattleGroundEnemies.db.profile[self.PlayerType]
		self.playerCountConfig = BattleGroundEnemies[self.PlayerType].playerCountConfig
		if self.playerCountConfig then
			self.basePath = {"BattleGroundEnemies", self.PlayerIsEnemy and "EnemySettings" or "AllySettings", BattleGroundEnemies:GetPlayerCountConfigName(self.playerCountConfig) }
		else
			self.basePath = {}
		end
		self:SetAllModuleConfigs()
	end

	function buttonFunctions:GetOptionsPath()
		local t = CopyTable(self.basePath)
		table.insert(t, "ButtonSettings")
		return t
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

		self:SetModulePositions()
		self:ApplyModuleSettings()
		self:SetBindings()
	end

	do
		local mouseButtons = {
			[1] = "LeftButton",
			[2] = "RightButton",
			[3] = "MiddleButton"
		}

		function buttonFunctions:SetBindings()
			self:Debug("SetBindings")
			if not self.config then return end
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

	function buttonFunctions:PlayerIsDead()
		if not self.isDead then
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
	end

	function buttonFunctions:PlayerIsAlive()
		if self.isDead then
			self:DispatchEvent("UnitRevived")
			self.isDead = false
		end
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

	function buttonFunctions:UpdateHealth(unitID, health, maxHealth)
		self:DispatchEvent("UpdateHealth", unitID, health, maxHealth)
		if unitID and UnitIsDeadOrGhost(unitID) or health == 0 then
			self:PlayerIsDead()
		else
			self:PlayerIsAlive()
		end
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

		self:UpdateHealth(unitID, health, maxHealth)
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
		self:UpdateRange(self.wasInRange, true)
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

		if self == BattleGroundEnemies.UserButton then
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

		if BattleGroundEnemies.states.isRatedBG then
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

	function buttonFunctions:UpdateRange(inRange, forceUpdate)
		if not self.config then return end
		--BattleGroundEnemies:Information("UpdateRange", inRange, self.PlayerName, self.config.RangeIndicator_Enabled, self.config.RangeIndicator_Alpha)

		if not self.config.RangeIndicator_Enabled then return end

		if forceUpdate or inRange ~= self.wasInRange then
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

	function buttonFunctions:WipeAllAuras()
		self.Auras = self.Auras or {}
		for i = 1, #auraFilters do
			local filter = auraFilters[i]
			self.Auras[filter] = {}
		end
		self:SendAllAurasToModules()
	end

	function buttonFunctions:SendAllAurasToModules(unitID)
		for i = 1, #auraFilters do
			local filter = auraFilters[i]
			self:DispatchEvent("BeforeFullAuraUpdate", filter)
			for _, aura in pairs(self.Auras[filter]) do
				self:DispatchEvent("NewAura", unitID, filter, aura)
			end
			self:DispatchEvent("AfterFullAuraUpdate", filter)
		end
	end

	---comment
	---@param unitID UnitToken
	---@param second UnitAuraUpdateInfo?
	function buttonFunctions:UNIT_AURA(unitID, second)
		if not self.isShown then return end
		local now = GetTime()
		if self.lastAuraUpdate and self.lastAuraUpdate == now then  --this event will fire for the same player multiple times if lets say he is shown on nameplate and on target frame
			if unitID and BattleGroundEnemies.ArenaIDToPlayerButton[unitID] then
				return self:SendAllAurasToModules(unitID)
			else
				return
			end
		end

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

				self.Auras[filter] = {}

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

		self:SendAllAurasToModules(unitID)

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
				if allyBtn ~= BattleGroundEnemies.UserButton then
					allyUnitID = allyBtn.TargetUnitID
					break
				end
			end
			self:UpdateEnemyUnitID("Ally", allyUnitID)
		end
	end

	function buttonFunctions:IsNowTargeting(playerButton)
		--BattleGroundEnemies:Debug("IsNowTargeting", self.PlayerName, self.unitID, playerButton.PlayerName)
		self.Target = playerButton

		if not self:IsEnemyToMe(playerButton) then return end --we only care of the other player is of opposite faction

		playerButton:UpdateTargetedByEnemy(self, true)
	end

	function buttonFunctions:IsNoLongerTarging(playerButton)
		--BattleGroundEnemies:Debug("IsNoLongerTarging", self.PlayerName, self.unitID, playerButton.PlayerName)
		self.Target = nil

		if not self:IsEnemyToMe(playerButton) then return end --we only care of the other player is of opposite faction

		playerButton:UpdateTargetedByEnemy(self, nil)
	end

	function buttonFunctions:UpdateTarget()
		--BattleGroundEnemies:Debug("UpdateTarget", self.PlayerName, self.unitID)

		local oldTargetPlayerButton = self.Target
		local newTargetPlayerButton

		if self.TargetUnitID then
			newTargetPlayerButton = BattleGroundEnemies:GetPlayerbuttonByUnitID(self.TargetUnitID)
		end


		if oldTargetPlayerButton then
			--BattleGroundEnemies:Debug("UpdateTarget", "oldTargetPlayerButton", self.PlayerName, self.unitID, oldTargetPlayerButton.PlayerName, oldTargetPlayerButton.unitID)

			if newTargetPlayerButton and oldTargetPlayerButton == newTargetPlayerButton then return end
			self:IsNoLongerTarging(oldTargetPlayerButton)
		end

		--player didnt have a target before or the player targets a new player

		if newTargetPlayerButton then --player targets an existing player and not for example a pet or a NPC
			--BattleGroundEnemies:Debug("UpdateTarget", "newTargetPlayerButton", self.PlayerName, self.unitID, newTargetPlayerButton.PlayerName, newTargetPlayerButton.unitID)
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

function BattleGroundEnemies:CreatePlayerButton(mainframe, num)
	--local playerButton = CreateFrame('Button', "BattleGroundEnemies" .. mainframe.PlayerType .. "frame" ..num, mainframe)


	---@class PlayerButton: Button
	local playerButton = CreateFrame('Button', "BattleGroundEnemies" .. mainframe.PlayerType .. "frame" ..num, mainframe, 'SecureUnitButtonTemplate')
	BattleGroundEnemies.EditMode.EditModeManager:AddFrame(playerButton, "playerButton", L.Button, playerButton)
	playerButton:RegisterForClicks('AnyUp')
	playerButton:SetPropagateMouseMotion(true) --to send the mouse wheel event to the other frame behind it (the mainframe)
	playerButton:Hide()
	-- setmetatable(playerButton, self)
	-- self.__index = self


	playerButton.ButtonEvents = playerButton.ButtonEvents or {}

	playerButton.PlayerType = mainframe.PlayerType
	playerButton.PlayerIsEnemy = playerButton.PlayerType == BattleGroundEnemies.consts.PlayerTypes.Enemies and true or false
	playerButton.MainFrame = mainframe

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
			local moduleOnFrame = moduleFrame:AttachToPlayerButton(playerButton)
			if moduleOnFrame then
				if not moduleFrame.attachSettingsToButton then
					BattleGroundEnemies.EditMode.EditModeManager:AddFrame(moduleOnFrame, moduleName, moduleFrame.localizedModuleName, playerButton)
				end
			end

			if not playerButton[moduleName] then
				print("something went wrong here after AttachToPlayerButton",
					moduleName)
			end

			playerButton[moduleName].GetConfig = function(self)
				self.config = playerButton.playerCountConfig.ButtonModules[moduleName]
				return self.config
			end

			playerButton[moduleName].Debug = function(self, ...)
				BattleGroundEnemies:Debug(moduleName, playerButton.PlayerDetails and playerButton.PlayerDetails.PlayerName, ...)
			end

			playerButton[moduleName].GetOptionsPath = function(self)
				local optionsPath = CopyTable(playerButton.basePath)
				table.insert(optionsPath, "ModuleSettings")
				table.insert(optionsPath, moduleName)
				return optionsPath
			end
			playerButton[moduleName].moduleName = moduleName
		end
	end
	return playerButton
end