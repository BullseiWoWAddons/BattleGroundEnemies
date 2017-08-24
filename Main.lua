local addonName, Data = ...
local L = LibStub("AceLocale-3.0"):GetLocale("BattleGroundEnemies")
local LSM = LibStub("LibSharedMedia-3.0")
local DRData = LibStub("DRData-1.0")
local LibRaces = LibStub("LibRaces-1.0")
LSM:Register("font", "PT Sans Narrow Bold", [[Interface\AddOns\BattleGroundEnemies\Fonts\PT Sans Narrow Bold.ttf]])
LSM:Register("statusbar", "UI-StatusBar", "Interface\\TargetingFrame\\UI-StatusBar")







--upvalues
local _G = _G
local pairs = pairs
local print = print
local type = type
local unpack = unpack
local floor = math.floor
local tinsert = table.insert
local tremove = table.remove

local C_PvP = C_PvP
local GetArenaCrowdControlInfo = C_PvP.GetArenaCrowdControlInfo
local RequestCrowdControlSpell = C_PvP.RequestCrowdControlSpell
local IsInBrawl = C_PvP.IsInBrawl
local CreateFrame = CreateFrame
local GetBattlefieldArenaFaction = GetBattlefieldArenaFaction
local GetBattlefieldScore = GetBattlefieldScore
local GetBattlefieldTeamInfo = GetBattlefieldTeamInfo
local GetCurrentMapAreaID = GetCurrentMapAreaID
local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetNumGroupMembers = GetNumGroupMembers
local GetRaidRosterInfo = GetRaidRosterInfo
local GetSpellInfo = GetSpellInfo
local GetSpellTexture = GetSpellTexture
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local IsInInstance = IsInInstance
local IsItemInRange = IsItemInRange
local IsRatedBattleground = IsRatedBattleground
local PlaySound = PlaySound
local PowerBarColor = PowerBarColor --table
local RaidNotice_AddMessage = RaidNotice_AddMessage
local RequestBattlefieldScoreData = RequestBattlefieldScoreData
local SetMapToCurrentZone = SetMapToCurrentZone
local UnitDebuff = UnitDebuff
local UnitExists = UnitExists
--local UnitGUID = UnitGUID
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitName = UnitName


--variables used in multiple functions, if a variable is only used by one function its declared above that function
local BattlegroundBuff --contains the battleground specific enemy buff to watchout for of the current active battlefield
local IsRatedBG
local PlayerDetails = {}

local BattleGroundEnemies = CreateFrame("Frame", "BattleGroundEnemies", UIParent)
BattleGroundEnemies:Hide()



local RequestFrame = CreateFrame("Frame")
RequestFrame:Hide()


BattleGroundEnemies.InactiveEnemyButtons = {} --index = number, value = button(table)

BattleGroundEnemies.RangeUpdate = {} --key = number from 1 to x, value = enemyButton
BattleGroundEnemies.ArenaEnemyIDToEnemyButton = {} --key = arenaID: arenaX, value = enemyButton of that unitID
BattleGroundEnemies.Enemies = {} --index = name, value = button(table), contains enemyButtons
BattleGroundEnemies.EnemySortingTable = {} --index = number, value = enemy name
BattleGroundEnemies.Allys = {} --index = name, value = table
BattleGroundEnemies.AllyUnitIDToAllyDetails = {} --index = unitID ("raid"..i) of raidmember, value = Allytable of that group member

--Notes about UnitIDs
--priority of unitIDs:
--1. Arena, detected by UNIT_HEALTH_FREQUENT (health upate), ARENA_OPPONENT_UPDATE (this units exist, don't exist anymore)
--2. nameplates, detected by UNIT_HEALTH_FREQUENT, NAME_PLATE_UNIT_ADDED, NAME_PLATE_UNIT_REMOVED
--3. player's target
--4. player's focus
--5. ally targets, UNIT_TARGET fires if the target changes



local function CreateFontString(parent, Setallpoints, tablePoint1, tablePoint2, justifyH, justifyV, Fontsize, FontOutline, Textcolor, enableShadow, shadowColor)
	parent.FontString = parent:CreateFontString(nil, "OVERLAY")
	if Setallpoints then
		parent.FontString:SetAllPoints()
	else
		parent.FontString:SetPoint(unpack(tablePoint1))
		parent.FontString:SetPoint(unpack(tablePoint2))
	end

	parent.FontString:SetFont(LSM:Fetch("font", BattleGroundEnemies.db.profile.Font), Fontsize, FontOutline)
	parent.FontString:SetTextColor(unpack(Textcolor))
	
	if justifyH then
		parent.FontString:SetJustifyH(justifyH)
	end
	if justifyV then
		parent.FontString:SetJustifyV(justifyV)
	end
	
	parent.FontString:SetShadowColor(unpack(shadowColor))
	if enableShadow then 
		parent.FontString:SetShadowOffset(1, -1)
	else
		parent.FontString:SetShadowOffset(0, 0)
	end
	parent.FontString:SetDrawLayer('OVERLAY', 2)
	return parent.FontString
end


do 
	local DefaultSettings = {
		profile = {
			Font = "PT Sans Narrow Bold",
			
			Name_Fontsize = 13,
			Name_Outline = "",
			Name_Textcolor = {1, 1, 1, 1}, 
			Name_EnableTextshadow = true,
			Name_TextShadowcolor = {0, 0, 0, 1},
			
			Position_X = false,
			Position_Y = false,
			BarWidth = 220,
			BarHeight = 28,
			HealthBar_Texture = 'UI-StatusBar',
			HealthBar_Background = {0, 0, 0, 0.66},
			
			PowerBar_Enabled = false,
			PowerBar_Height = 4,
			PowerBar_Texture = 'UI-StatusBar',
			PowerBar_Background = {0, 0, 0, 0.66},
			
			SpaceBetweenRows = 1,
			Growdirection = "downwards",
			
			RoleIcon_Enabled = false,
			RoleIcon_Size = 13,
			
			RangeIndicator_Enabled = true,
			RangeIndicator_Range = 28767,
			RangeIndicator_Alpha = 0.55,
			
			ShowRealmnames = true,
			ConvertCyrillic = true,
			DisableArenaFrames = false,
			
			EnemyCount_Enabled = true,
			EnemyCount_Fontsize = 14,
			EnemyCount_Outline = "OUTLINE",
			EnemyCount_Textcolor = {1, 1, 1, 1},
			EnemyCount_EnableTextshadow = false,
			EnemyCount_TextShadowcolor = {0, 0, 0, 1},
			
			Locked = false,
			MaxPlayers = 15,
			Framescale = 1,
			Debug = false,
			
			
			Spec_Width = 36,
			Role_Width = 28,
			
			SymbolicTargetindicator_Enabled = true,
			
			NumericTargetindicator_Enabled = true,
			NumericTargetindicator_Fontsize = 18,
			NumericTargetindicator_Outline = "",
			NumericTargetindicator_Textcolor = {1, 1, 1, 1},
			NumericTargetindicator_EnableTextshadow = false,
			NumericTargetindicator_TextShadowcolor = {0, 0, 0, 1},
			
			MyTarget_Color = {17, 27, 161, 1},
			MyFocus_Color = {0, 0.988235294117647, 0.729411764705882, 1},
			
			DrTracking_Enabled = true,
			DrTracking_ShowNumbers = true,
			DrTracking_Spacing = 2,
			
			MyDebuffs_Enabled = true,
			MyDebuffs_ShowNumbers = true,
			MyDebuffs_Fontsize = 12,
			MyDebuffs_Outline = "OUTLINE",
			MyDebuffs_Textcolor = {1, 1, 1, 1},
			MyDebuffs_EnableTextshadow = true,
			MyDebuffs_TextShadowcolor = {0, 0, 0, 1},
			MyDebuffs_Spacing = 2,

			ObjectiveAndRespawn_ObjectiveEnabled = true,
			ObjectiveAndRespawn_RespawnEnabled = true,
			ObjectiveAndRespawn_Width = 36,
			ObjectiveAndRespawn_ShowNumbers = true,
			ObjectiveAndRespawn_Fontsize = 17,
			ObjectiveAndRespawn_Outline = "THICKOUTLINE",
			ObjectiveAndRespawn_Textcolor = {1, 1, 1, 1},
			ObjectiveAndRespawn_EnableTextshadow = false,
			ObjectiveAndRespawn_TextShadowcolor = {0, 0, 0, 1},
			
			Trinket_Enabled = true,
			Trinket_ShowNumbers = true,
			
			Racial_Enabled = true,
			Racial_ShowNumbers = true,
			
			Notificatoins_Enabled = true,
			PositiveSound = [[Interface\AddOns\WeakAuras\Media\Sounds\BatmanPunch.ogg]],
			NegativeSound = [[Sound\Interface\UI_BattlegroundCountdown_Timer.ogg]],
		}
	}

	function BattleGroundEnemies:PLAYER_LOGIN()
		PlayerDetails.PlayerName = UnitName("player")
		PlayerDetails.ClassColor = RAID_CLASS_COLORS[(select(2, UnitClass("player")))]
		PlayerDetails.TargetUnitID = "target"
		-- ArenaFrameCvar = GetCVar("showArenaEnemyFrames")
		-- self:Debug("ArenaFrameCvar login", ArenaFrameCvar)
		
		self.db = LibStub("AceDB-3.0"):New("BattleGroundEnemiesDB", DefaultSettings, true)
		-- self.db.RegisterCallback(self, "OnProfileChanged", "UpdateFrames")
		-- self.db.RegisterCallback(self, "OnProfileCopied", "UpdateFrames")
		-- self.db.RegisterCallback(self, "OnProfileReset", "UpdateFrames")
		
		self:SetupOptions()
		--DBObjectLib:ResetProfile(noChildren, noCallbacks)
		self:SetSize(self.db.profile.BarWidth, 30)
		self:SetClampedToScreen(true)
		self:SetMovable(true)
		self:SetUserPlaced(true)
		self:SetResizable(true)
		self:SetToplevel(true)
		self:SetScale(self.db.profile.Framescale)
		
		self:SetScript("OnShow", function(self) 
			if not self.TestmodeActive then
				self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
				self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
				self:RegisterEvent("PLAYER_TARGET_CHANGED")
				self:RegisterEvent("PLAYER_FOCUS_CHANGED")
				self:RegisterEvent("UNIT_TARGET")
				self:RegisterEvent("UNIT_HEALTH_FREQUENT")
				self:RegisterEvent("UNIT_POWER_FREQUENT")
				self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
				self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
				self:RegisterEvent("ARENA_OPPONENT_UPDATE")
				self:RegisterEvent("ARENA_CROWD_CONTROL_SPELL_UPDATE")
				self:RegisterEvent("ARENA_COOLDOWNS_UPDATE")
				self:RegisterEvent("GROUP_ROSTER_UPDATE")
				-- self:RegisterEvent("LOSS_OF_CONTROL_ADDED")
				self:RegisterEvent("PLAYER_ALIVE")
				self:RegisterEvent("PLAYER_UNGHOST")
			end
		end)
		
		self:ClearAllPoints()
		if not self.db.profile.Position_X and not self.db.profile.Position_X then
			self:SetPoint("CENTER")
		else
			local scale = self:GetEffectiveScale()
			self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", self.db.profile.Position_X / scale, self.db.profile.Position_Y / scale)
		end
		
		local conf = self.db.profile
		if self.db.profile.Growdirection == "downwards" then
			self.EnemyCount = CreateFontString(self, true, false, false, 'LEFT', "BOTTOM", conf.EnemyCount_Fontsize, conf.EnemyCount_Outline, conf.EnemyCount_Textcolor, conf.EnemyCount_EnableTextshadow, conf.EnemyCount_TextShadowcolor )
		else
			self.EnemyCount = CreateFontString(self, true, false, false, 'LEFT', "TOP", conf.EnemyCount_Fontsize, conf.EnemyCount_Outline, conf.EnemyCount_Textcolor, conf.EnemyCount_EnableTextshadow, conf.EnemyCount_TextShadowcolor)
		end 
		self:UnregisterEvent("PLAYER_LOGIN")
	end
end

function BattleGroundEnemies:Debug(...)
	if self.db.profile.Debug then print("BGE:", ...) end
end

do
	local TimeSinceLastOnUpdate = 0
	local UpdatePeroid = 0.1 --update every second
	function BattleGroundEnemies:RealEnemies(elapsed)
		--BattleGroundEnemies:Debug("läuft")
		TimeSinceLastOnUpdate = TimeSinceLastOnUpdate + elapsed
		if TimeSinceLastOnUpdate > UpdatePeroid then
			if BattleGroundEnemies.PlayerIsAlive then
				local rangeUpdate = BattleGroundEnemies.RangeUpdate
				for i = 1, #rangeUpdate do
					local enemyButton = rangeUpdate[i]
					local unitIDs = enemyButton.UnitIDs
					local activeUnitID = unitIDs.Active
					if unitIDs.UpdateHealth then
						if unitIDs.UpdatePower then
							enemyButton:UpdatePower(activeUnitID)
						end
						enemyButton:UpdateHealth(activeUnitID)
					end
					
					enemyButton:UpdateRange(IsItemInRange(self.db.profile.RangeIndicator_Range, activeUnitID))
				end
			end
		end
	end
	BattleGroundEnemies:SetScript("OnUpdate", BattleGroundEnemies.RealEnemies)
end

function BattleGroundEnemies:SetupButtonForNewPlayer(enemyDetails, name)
	
	local enemyButton = self.InactiveEnemyButtons[#self.InactiveEnemyButtons] 
	if enemyButton then --recycle a previous used button
		tremove(self.InactiveEnemyButtons, #self.InactiveEnemyButtons)
		--Cleanup previous shown stuff of another player
		enemyButton:SetAlpha(self.db.profile.RangeIndicator_Alpha)
		enemyButton.Trinket.HasTrinket = nil
		enemyButton.Trinket.Icon:SetTexture(nil)
		enemyButton.Trinket.Cooldown:Clear()	--reset Trinket Cooldown
		enemyButton.Racial.Icon:SetTexture(nil)
		enemyButton.Racial.Cooldown:Clear()	--reset Racial Cooldown
		enemyButton.MyTarget:Hide()	--reset possible shown target indicator frame
		enemyButton.MyFocus:Hide()	--reset possible shown target indicator frame
		if enemyButton.UnitIDs then  --check because of testmode
			wipe(enemyButton.UnitIDs.TargetedByAlly)  
			enemyButton:UpdateTargetIndicators() --update numerical and symbolic target indicator
			enemyButton:DeleteActiveUnitID()
		end
		enemyButton.ObjectiveAndRespawn:Hide()
		enemyButton.ObjectiveAndRespawn.Cooldown:Clear()
		
		for categorie, drFrame in pairs(enemyButton.DR) do --set status of DR-Tracker to 1
			drFrame.status = 1
		end
	else --no recycleable buttons remaining => create a new one
		enemyButton = self:CreateNewPlayerButton()
	end
	

	enemyButton.PlayerRace = enemyDetails.PlayerRace
	enemyButton.PlayerClass = enemyDetails.PlayerClass
	enemyButton.PlayerSpec = enemyDetails.PlayerSpec
	
	
	local specData = Data.Classes[enemyButton.PlayerClass][enemyButton.PlayerSpec]
	
	
	enemyButton.PlayerRoleNumber = specData.roleNumber
	enemyButton.PlayerRoleID = specData.roleID
	enemyButton.Role.Icon:SetTexCoord(GetTexCoordsForRoleSmallCircle(enemyButton.PlayerRoleID))
	if enemyButton.config.RoleIcon_Enabled then 
		enemyButton.Role:SetSize(enemyButton.config.RoleIcon_Size, enemyButton.config.RoleIcon_Size) 
	else
		enemyButton.Role:SetSize(0.01, 0.01)
	end
	
	enemyButton.Spec.Icon:SetTexture(specData.specIcon)
	
	local c = RAID_CLASS_COLORS[enemyButton.PlayerClass]
	enemyButton.Health:SetStatusBarColor(c.r,c.g,c.b)
	enemyButton.Health:SetValue(1)
	
	c = PowerBarColor[Data.Classes[enemyButton.PlayerClass][enemyButton.PlayerSpec].Ressource]
	enemyButton.Power:SetStatusBarColor(c.r, c.g, c.b)
	
	enemyButton:SetName(name)
	
	enemyButton:Show()

	return enemyButton
end



function BattleGroundEnemies:RemoveEnemy(name, enemyButton)	
	if not enemyButton then enemyButton = self.Enemies[name] end
	
	tremove(self.EnemySortingTable, enemyButton.Position)
	enemyButton:Hide()

	tinsert(self.InactiveEnemyButtons, enemyButton)
	self.Enemies[name] = nil
end


do
	local BlizzardsSortOrder = {} 
	for i = 1, #CLASS_SORT_ORDER do -- Constants.lua
		BlizzardsSortOrder[CLASS_SORT_ORDER[i]] = i --key = ENGLISH CLASS NAME, value = number
	end

	local function PlayerSortingByRoleClassName(a, b)-- a and b are playernames
		local playerA = BattleGroundEnemies.Enemies[a]
		local playerB = BattleGroundEnemies.Enemies[b]
		if playerA.PlayerRoleNumber == playerB.PlayerRoleNumber then
			if BlizzardsSortOrder[ playerA.PlayerClass ] == BlizzardsSortOrder[ playerB.PlayerClass ] then
				if a < b then return true end
			elseif BlizzardsSortOrder[ playerA.PlayerClass ] < BlizzardsSortOrder[ playerB.PlayerClass ] then return true end
		elseif playerA.PlayerRoleNumber < playerB.PlayerRoleNumber then return true end
	end

	function BattleGroundEnemies:SortEnemies()
		table.sort(self.EnemySortingTable, PlayerSortingByRoleClassName)
		
		local previousButton = self
		for number, name in ipairs(self.EnemySortingTable) do
			local enemyButton = self.Enemies[name]
			enemyButton.Position = number
			enemyButton:SetPosition(self.db.profile.Growdirection, previousButton, self.db.profile.SpaceBetweenRows)
			previousButton = enemyButton
		end
	end
end



function BattleGroundEnemies.SavePosition()
	BattleGroundEnemies:StopMovingOrSizing()
	if not InCombatLockdown() then
		local scale = BattleGroundEnemies:GetEffectiveScale()
		BattleGroundEnemies.db.profile.Position_X = BattleGroundEnemies:GetLeft() * scale
		BattleGroundEnemies.db.profile.Position_Y = BattleGroundEnemies:GetTop() * scale
	end
end

do
	local TimeSinceLastOnUpdate = 0
	local UpdatePeroid = 2 --update every second
	function BattleGroundEnemies:RequestTicker(elapsed) --OnUpdate runs if the frame RequestFrame is shown
		TimeSinceLastOnUpdate = TimeSinceLastOnUpdate + elapsed
		if TimeSinceLastOnUpdate > UpdatePeroid then
			RequestBattlefieldScoreData()
			TimeSinceLastOnUpdate = 0
		end
	end
	RequestFrame:SetScript("OnUpdate", BattleGroundEnemies.RequestTicker)
end


--fires when a arena enemy appears and a frame is ready to be shown
function BattleGroundEnemies:ARENA_OPPONENT_UPDATE(unitID, unitEvent)
	--self:Debug("ARENA_OPPONENT_UPDATE", unitID, unitEvent)
	if unitEvent == "cleared" then 
		local enemyButton = self.ArenaEnemyIDToEnemyButton[unitID]
		if enemyButton then
			local objective = enemyButton.ObjectiveAndRespawn
			
			--self:Debug("ARENA_OPPONENT_UPDATE", enemyButton.DisplayedName, "cleared")
			self.ArenaEnemyIDToEnemyButton[unitID] = nil
			objective.Icon:SetTexture()
			objective.Value = false
			objective:UnregisterAllEvents()
			objective:Hide()

			enemyButton.UnitIDs.Arena = false
			enemyButton:FetchAnotherUnitID()
		end
	else -- "unseen", "seen" or "destroyed"
		--self:Debug(UnitName(unitID))
		local enemyButton = self:GetEnemybuttonByUnitID(unitID)
		if enemyButton then
			--self:Debug("Button exists")
			enemyButton:ArenaOpponentShown(unitID)
		end
	end
end

function BattleGroundEnemies:COMBAT_LOG_EVENT_UNFILTERED(timestamp,subevent,hide,srcGUID,srcName,srcF1,srcF2,destGUID,destName,destF1,destF2,spellID,spellName,spellSchool, auraType)
	if subevent == "SPELL_AURA_APPLIED" then
		if auraType == "DEBUFF" then
			local enemyButton = self.Enemies[destName]
			if enemyButton then
				enemyButton:UpdateDR(spellID, spellName, true)
				enemyButton:RelentlessCheck(spellID, spellName)
				enemyButton.Trinket:TrinketCheck(spellID, true) --adaptation used, maybe?
				enemyButton:DebuffChanged(false, srcName, spellID, spellName, true, false)
			end
		end
	elseif subevent == "SPELL_AURA_REFRESH" then
		if auraType == "DEBUFF" then
			local enemyButton = self.Enemies[destName]
			if enemyButton then
				enemyButton:UpdateDR(spellID, spellName, true, true)
				enemyButton:RelentlessCheck(spellID, spellName)
				enemyButton:DebuffChanged(false, srcName, spellID, spellName, true, true)
			end
		end
	elseif subevent == "SPELL_AURA_REMOVED" then
		if auraType == "DEBUFF" then
			local enemyButton = self.Enemies[destName]
			if enemyButton then
				enemyButton:UpdateDR(spellID, spellName, false, true)
				enemyButton:DebuffChanged(false, srcName, spellID, spellName, false, true)
			end
		end
	elseif subevent == "SPELL_CAST_SUCCESS" then
		local enemyButton = self.Enemies[srcName]
		if enemyButton then
			if Data.RacialSpellIDtoCooldown[spellID] then --racial used, maybe?
				enemyButton:RacialUsed(spellID)
			else
				enemyButton.Trinket:TrinketCheck(spellID, true)
			end
		end
	elseif subevent == "UNIT_DIED" then
		--self:Debug("subevent", destName, "UNIT_DIED")
		local enemyButton = self.Enemies[destName]
		if enemyButton then
			enemyButton.ObjectiveAndRespawn:ShowRespawnTimer(27)
		end
	end
end

-- if lets say raid1 leaves all remaining players get shifted up, so raid2 is the new raid1, raid 3 gets raid2 etc.
function BattleGroundEnemies:GROUP_ROSTER_UPDATE()
	if not self then self = BattleGroundEnemies end -- for the C_Timer.After call
	wipe(self.AllyUnitIDToAllyDetails)
	local numGroupMembers = GetNumGroupMembers()
	if numGroupMembers > 0 then
		
		for i = 1, numGroupMembers do
			
			local allyName, _, _, _, _, classTag = GetRaidRosterInfo(i)
			if allyName and classTag then
				if allyName ~= PlayerDetails.PlayerName then
				
					local unitID = "raid"..i --it happens that numGroupMembers is higher than the value of the maximal players for that battleground, for example 15 in a 10 man bg, thats why we wipe AllyUnitIDToAllyDetails
					local targetUnitID = unitID.."target"

					local allyDetails = self.Allys[allyName]
					if allyDetails then --found, already existing
						if allyDetails.UnitID ~= unitID then -- ally has a new unitID now
							local targetEnemyButton = allyDetails.Target
							if targetEnemyButton then
								--self:Debug("player", allyName, "has a new unitID and targeted something")
								if targetEnemyButton.UnitIDs.Active == allyDetails.TargetUnitID then
									targetEnemyButton.UnitIDs.Active = targetUnitID
								end
								if targetEnemyButton.UnitIDs.Ally == allyDetails.TargetUnitID then
									targetEnemyButton.UnitIDs.Ally = targetUnitID
								end
								
							end
						end
						allyDetails.status = 1 --found, already existing
					else--new ally
						allyDetails = {ClassColor = RAID_CLASS_COLORS[classTag]}
						self.Allys[allyName] = allyDetails
					end

					allyDetails.UnitID = unitID --always update unitID
					allyDetails.TargetUnitID = targetUnitID
					self.AllyUnitIDToAllyDetails[unitID] = allyDetails
				end
			else
				C_Timer.After(1, BattleGroundEnemies.GROUP_ROSTER_UPDATE) --recheck in 1 second
			end
		end
	end
	
	for allyName, allyDetails in pairs(self.Allys) do
		if allyDetails.status == 2 then --doesn't exist anymore
			local targetEnemyButton = allyDetails.Target
			if targetEnemyButton then -- if that no longer exiting ally targeted something update the button of its target
				targetEnemyButton:NoLongerTargetedBy(allyDetails)
			end
			self.Allys[allyName] = nil
		else
			allyDetails.status = 2
		end
	end
end


function BattleGroundEnemies:UNIT_TARGET(unitID)
	--self:Debug("unitID:", unitID, "unit:", UnitName(unitID), "unittarget:", UnitName(unitID.."target"))
	
	if self.AllyUnitIDToAllyDetails[unitID] then
		--self:Debug("target changed")
		self:UpdateAllyTargets(unitID)
	end
end


function BattleGroundEnemies:UpdateAllyTargets(unitID)
	--self:Debug(unitID, "target changed")

	local allyDetails = self.AllyUnitIDToAllyDetails[unitID]
	
	local targetUnitID = allyDetails.TargetUnitID
	local oldTargetEnemyButton = allyDetails.Target
	local newTargetEnemyButton = self:GetEnemybuttonByUnitID(targetUnitID)
	
	
	if oldTargetEnemyButton then
		oldTargetEnemyButton:NoLongerTargetedBy(allyDetails)
		--self:Debug(oldTargetEnemyButton.DisplayedName, "is not targeted by", unitID, "anymore")
	end
	
	if newTargetEnemyButton then --ally targets an existing enemy
		if not newTargetEnemyButton.UnitIDs.Active then 
			newTargetEnemyButton.UnitIDs.Active = targetUnitID
			newTargetEnemyButton:RegisterForRangeUpdate() 
		end
		newTargetEnemyButton:NowTargetedBy(allyDetails)
		allyDetails.Target = newTargetEnemyButton
		--self:Debug(newTargetEnemyButton.DisplayedName, "is now targeted by", unitID)
	else
		allyDetails.Target = false
	end
end

do
	local oldTarget
	function BattleGroundEnemies:PLAYER_TARGET_CHANGED()
		local enemyButton = self:GetEnemybuttonByUnitID("target")
		
		if oldTarget then
			oldTarget.MyTarget:Hide()
			oldTarget.UnitIDs.TargetedByAlly[PlayerDetails] = nil
			oldTarget:UpdateTargetIndicators()			
			oldTarget.UnitIDs.Target = false
			if oldTarget.UnitIDs.Active == "target" then oldTarget:FetchAnotherUnitID() end
		end
		
		if enemyButton then --ally targets an existing enemy
			enemyButton.MyTarget:Show()
			enemyButton.UnitIDs.TargetedByAlly[PlayerDetails] = true
			enemyButton:UpdateTargetIndicators()
			enemyButton.UnitIDs.Target = "target"
			enemyButton:FetchAnotherUnitID()
			oldTarget = enemyButton
		else
			oldTarget = false
		end
	end
end

do
	local oldFocus
	function BattleGroundEnemies:PLAYER_FOCUS_CHANGED()
		local enemyButton = self:GetEnemybuttonByUnitID("focus")
		if oldFocus then
			oldFocus.MyFocus:Hide()
			oldFocus.UnitIDs.Focus = false
			if oldFocus.UnitIDs.Active == "focus" then oldFocus:FetchAnotherUnitID() end
		end
		if enemyButton then
			enemyButton.MyFocus:Show()
			enemyButton.UnitIDs.Focus = "focus"
			enemyButton:FetchAnotherUnitID()
			oldFocus = enemyButton
		else
			oldFocus = false
		end
	end
end

function BattleGroundEnemies:UNIT_HEALTH_FREQUENT(unitID) --gets health of nameplates, player, target, focus, raid1 to raid40, partymember
	local enemyButton = self:GetEnemybuttonByUnitID(unitID)
	if enemyButton then --unit is a shown enemy
		enemyButton:UpdateHealth(unitID)
	end
end

function BattleGroundEnemies:UNIT_POWER_FREQUENT(unitID, powerToken) --gets power of nameplates, player, target, focus, raid1 to raid40, partymember
	local enemyButton = self:GetEnemybuttonByUnitID(unitID)
	if enemyButton then --unit is a shown enemy
		enemyButton:UpdatePower(unitID, powerToken)
	end
end

function BattleGroundEnemies:UPDATE_MOUSEOVER_UNIT()
	local enemyButton = self:GetEnemybuttonByUnitID("mouseover")
	if enemyButton then --unit is a shown enemy
		enemyButton:UpdateAll("mouseover")
	end
end

function BattleGroundEnemies:NAME_PLATE_UNIT_ADDED(unitID)
	local enemyButton = self:GetEnemybuttonByUnitID(unitID)
	if enemyButton then
		enemyButton.UnitIDs.Nameplate = unitID
		enemyButton:FetchAnotherUnitID()
	end
end

function BattleGroundEnemies:NAME_PLATE_UNIT_REMOVED(unitID)
	--self:Debug(unitID)
	local enemyButton = self:GetEnemybuttonByUnitID(unitID)
	if enemyButton then
		enemyButton.UnitIDs.Nameplate = false
		if enemyButton.UnitIDs.Active == unitID then enemyButton:FetchAnotherUnitID() end
	end
end	


-- function BattleGroundEnemies:LOSS_OF_CONTROL_ADDED()
	-- local numEvents = C_LossOfControl.GetNumEvents()
	-- for i = 1, numEvents do
		-- local locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType = C_LossOfControl.GetEventInfo(i)
		-- --self:Debug(C_LossOfControl.GetEventInfo(i))
		-- if not self.LOSS_OF_CONTROL then self.LOSS_OF_CONTROL = {} end
		-- self.LOSS_OF_CONTROL[spellID] = locType
	-- end
-- end

function BattleGroundEnemies:GetEnemybuttonByUnitID(unitID)
	local uName, realm = UnitName(unitID)
	if realm then
		uName = uName.."-"..realm
	end
	return self.Enemies[uName]
end

--fires when data requested by C_PvP.RequestCrowdControlSpell(unitID) is available
function BattleGroundEnemies:ARENA_CROWD_CONTROL_SPELL_UPDATE(unitID, spellID)
	local enemyButton = self:GetEnemybuttonByUnitID(unitID)
	if enemyButton  then
		enemyButton.Trinket:TrinketCheck(spellID, false)
	end
	--if spellID ~= 72757 then --cogwheel (30 sec cooldown trigger by racial)
	--end
end

--fires when a arenaX enemy used a trinket or racial to break cc, C_PvP.GetArenaCrowdControlInfo(unitID) shoudl be called afterwards to get used CCs
--this event is kinda stupid, it doesn't say which unit used which cooldown, it justs says that somebody used some sort of trinket
function BattleGroundEnemies:ARENA_COOLDOWNS_UPDATE()
	--if not self.db.profile.Trinket then return end
	for i = 1, 4 do
		local unitID = "arena"..i
		local enemyButton = self:GetEnemybuttonByUnitID(unitID)
		if enemyButton then
			local spellID, startTime, duration = GetArenaCrowdControlInfo(unitID)
			if spellID then
				if (startTime ~= 0 and duration ~= 0) then
					enemyButton.Trinket.Cooldown:SetCooldown(startTime/1000.0, duration/1000.0)
				else
					enemyButton.Trinket.Cooldown:Clear()
				end
			end
		end
	end
end

function BattleGroundEnemies:PlayerAlive()
	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("PLAYER_FOCUS_CHANGED")
	self:RegisterEvent("UNIT_TARGET")
	--recheck the targets of groupmembers
	for allyName, allyDetails in pairs(self.Allys) do
		self:UpdateAllyTargets(allyDetails.UnitID)
	end
	self.PlayerIsAlive = true
end

function BattleGroundEnemies:PLAYER_ALIVE()
	if UnitIsGhost("player") then --Releases his ghost to a graveyard.
		self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
		self:UnregisterEvent("PLAYER_TARGET_CHANGED")
		self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
		self:UnregisterEvent("UNIT_TARGET")
		self.PlayerIsAlive = false
	else --alive (resed while not being a ghost)
		self:PlayerAlive()
	end
end

BattleGroundEnemies.PLAYER_UNGHOST = BattleGroundEnemies.PlayerAlive --player is alive again


do
	local BrawlCheck
	local CurrentMapID --contains the map id of the current active battleground
	do
		local BattleGroundDebuffs = {} --contains battleground specific enemy debbuffs to watchout for of the current active battlefield
		

		local function MyCreateFrame(frameType, parent, tablepoint1, tablepoint2, width, height)
			local frame = CreateFrame(frameType, nil, parent)
			frame:SetPoint(unpack(tablepoint1))
			if tablepoint2 then frame:SetPoint(unpack(tablepoint2)) end
			if width then frame:SetWidth(width) end
			if height then frame:SetHeight(height) end
			return frame 
		end
		
		local function CreateCooldown(parent, showNumber, cdReverse, setDrawSwipe, swipeColor)
			local cooldown = CreateFrame("Cooldown", nil, parent)
			cooldown:SetAllPoints()
			cooldown:SetSwipeTexture('Interface/Buttons/WHITE8X8')
			cooldown:SetReverse(cdReverse)
			cooldown:SetDrawSwipe(setDrawSwipe)
			if swipeColor then cooldown:SetSwipeColor(unpack(swipeColor)) end
			cooldown:SetHideCountdownNumbers(not showNumber)
			return cooldown
		end
			
		local function SetBackdrop(frame, backdropColor, backdropBorderColor)
			frame:SetBackdrop({
				bgFile = "Interface/Buttons/WHITE8X8", --drawlayer "BACKGROUND"
				edgeFile = 'Interface/Buttons/WHITE8X8', --drawlayer "BORDER"
				edgeSize = 1
				})
			if backdropColor then frame:SetBackdropColor(unpack(backdropColor)) end
			if backdropBorderColor then frame:SetBackdropBorderColor(unpack(backdropBorderColor)) end
			return frame
		end
		
		local objectiveFrameFunctions = {}
		do 
		
			function objectiveFrameFunctions:Kotmoguorbs(event, unitID)
				--BattleGroundEnemies:Debug("Läüft")
				local battleGroundDebuffs = BattleGroundDebuffs
				for i = 1, #battleGroundDebuffs do
					local name, _, _, count, _, _, _, _, _, _, spellID, _, _, _, _, _, value2, value3, value4 = UnitDebuff(unitID, battleGroundDebuffs[i])
					--values for orb debuff:
					--BattleGroundEnemies:Debug(value0, value1, value2, value3, value4, value5)
					-- value2 = Reduces healing received by value2
					-- value3 = Increases damage taken by value3
					-- value4 = Increases damage done by value4
					if value3 then
						if not self.Value then
							--BattleGroundEnemies:Debug("hier")
							--player just got the debuff
							self.Icon:SetTexture(GetSpellTexture(spellID))
							self:Show()
							--BattleGroundEnemies:Debug("Texture set")
						end
						if value3 ~= self.Value then
							self.AuraText:SetText(value3)
							self.Value = value3
						end
						return
					end
				end
			end
			
			function objectiveFrameFunctions:NotKotmogu(event, unitID)
				local battleGroundDebuffs = BattleGroundDebuffs
				for i = 1, #battleGroundDebuffs do
					local _, _, _, count = UnitDebuff(unitID, battleGroundDebuffs[i])
					--values for orb debuff:
					--BattleGroundEnemies:Debug(value0, value1, value2, value3, value4, value5)
					-- value2 = Reduces healing received by value2
					-- value3 = Increases damage taken by value3
					-- value4 = Increases damage done by value4
					
					if count then -- Focused Assault, Brutal Assault
						if count ~= self.Value then
							self.AuraText:SetText(count)
							self.Value = count
						end
						return
					end
				end
			end 
			
			function objectiveFrameFunctions:ShowRespawnTimer(duration)
				--BattleGroundEnemies:Debug("ShowRespawnTimer")
				if (IsRatedBG or BattleGroundEnemies.TestmodeActive) and BattleGroundEnemies.db.profile.ObjectiveAndRespawn_RespawnEnabled  then
					--BattleGroundEnemies:Debug("ShowRespawnTimer SetCooldown")
					if not self.ActiveRespawnTimer then
						self:Show()
						self.Icon:SetTexture(GetSpellTexture(8326))
						self.AuraText:SetText("")
						self.Cooldown:SetCooldown(GetTime(), duration)
						self.ActiveRespawnTimer = true
					end
				end
			end
		end
		
		local enemyButtonFunctions = {}
		do
			function enemyButtonFunctions:SetPosition(direction, anchorFrame, verticalSpacing)
				self:ClearAllPoints()
				if direction == "downwards" then
					self:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -verticalSpacing)
					self:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT", 0, -verticalSpacing)
				else
					self:SetPoint("BOTTOMLEFT", anchorFrame, "TOPLEFT", 0, verticalSpacing)
					self:SetPoint("BOTTOMRIGHT", anchorFrame, "TOPRIGHT", 0, verticalSpacing)
				end
			end
			
			function enemyButtonFunctions:SetName(playername)

				local name, realm = strsplit( "-", playername, 2 )
					
				if self.config.ConvertCyrillic then
					playername = ""
					for i = 1, name:utf8len() do
						local c = name:utf8sub(i,i)

						if Data.CyrillicToRomanian[c] then
							playername = playername..Data.CyrillicToRomanian[c]
							if i == 1 then
								playername = playername:gsub("^.",string.upper) --uppercase the first character
							end
						else
							playername = playername..c
						end
					end
					--self.DisplayedName = self.DisplayedName:gsub("-.",string.upper) --uppercase the realm name
					name = playername
					if realm then
						playername = playername.."-"..realm
					end
				end
				
				if self.config.ShowRealmnames then
					self.Name:SetText(playername)
				else
					self.Name:SetText(name)
				end
				
				self.DisplayedName = playername
			end
	
	
			function enemyButtonFunctions:ArenaOpponentShown(unitID)
				if self.config.ObjectiveAndRespawn_ObjectiveEnabled then
					local objective = self.ObjectiveAndRespawn
					if BattlegroundBuff then
						--BattleGroundEnemies:Debug("has buff")
						objective.Icon:SetTexture(GetSpellTexture(BattlegroundBuff))
						objective:Show()
					end
					objective:RegisterUnitEvent("UNIT_AURA", unitID)
					objective.AuraText:SetText("")
					objective.Value = false
					BattleGroundEnemies.ArenaEnemyIDToEnemyButton[unitID] = self
					self.UnitIDs.Arena = unitID
					self:FetchAnotherUnitID()
				end
				RequestCrowdControlSpell(unitID)
			end
			
			function enemyButtonFunctions:RegisterForRangeUpdate() --Add to RangeUpdate
				if not self.UnitIDs.RangeUpdate then
					local i = #BattleGroundEnemies.RangeUpdate + 1
					BattleGroundEnemies.RangeUpdate[i] = self
					self.UnitIDs.RangeUpdate = i
				end
				self:UpdateHealth(self.UnitIDs.Active)
				self:UpdatePower(self.UnitIDs.Active)
			end
			--Remove from RangeUpdate
			function enemyButtonFunctions:DeleteActiveUnitID() --Delete from RangeUpdate
				--BattleGroundEnemies:Debug("DeleteActiveUnitID")
				local unitIDs = self.UnitIDs
				unitIDs.Active = false
				self:UpdateRange(false)
				
				local rangeUpdate = self.UnitIDs.RangeUpdate
				if rangeUpdate then
					unitIDs.RangeUpdate = false
					unitIDs.UpdateHealth = false
					unitIDs.UpdatePower = false
					local BGErangeUpdate = BattleGroundEnemies.RangeUpdate
					tremove(BGErangeUpdate, rangeUpdate)
					for i = rangeUpdate, #BGErangeUpdate do
						local enemyButton = BGErangeUpdate[i]
						enemyButton.UnitIDs.RangeUpdate = i
					end
				end
			end
			
			function enemyButtonFunctions:FetchAnotherUnitID()
				local unitIDs = self.UnitIDs
				unitIDs.Active = unitIDs.Arena or unitIDs.Nameplate or unitIDs.Target or unitIDs.Focus
				if unitIDs.Active then
					self:RegisterForRangeUpdate()
				else
					if unitIDs.Ally then 
						unitIDs.Active = unitIDs.Ally
						unitIDs.UpdateHealth = true
						if self.config.PowerBar_Enabled then
							unitIDs.UpdatePower = true
						end
						self:RegisterForRangeUpdate()
					else
						self:DeleteActiveUnitID()
					end 
				end
			end
			
			function enemyButtonFunctions:NowTargetedBy(allyGainedDetails)
				local unitIDs = self.UnitIDs
				unitIDs.TargetedByAlly[allyGainedDetails] = true
				self:UpdateTargetIndicators()
				if not unitIDs.Ally then
					unitIDs.Ally = allyGainedDetails.TargetUnitID
				end
			end

			function enemyButtonFunctions:NoLongerTargetedBy(allyLostDetails)
				local unitIDs = self.UnitIDs
				unitIDs.TargetedByAlly[allyLostDetails] = nil
				self:UpdateTargetIndicators()
				
				if allyLostDetails.TargetUnitID == unitIDs.Ally then
					unitIDs.Ally = false
					for allyDetails in pairs(unitIDs.TargetedByAlly) do
						if not allyDetails.TargetUnitID == "target" then
							unitIDs.Ally = allyDetails.TargetUnitID
							break
						end
					end
				end
				
				if allyLostDetails.TargetUnitID == unitIDs.Active then
					self:DeleteActiveUnitID()
				end
			end

			-- Shows/Hides targeting indicators for a button
			-- Updates the TargetedByAlly tables.
			function enemyButtonFunctions:UpdateTargetIndicators()
			
				local i = 1
				for allyDetails in pairs(self.UnitIDs.TargetedByAlly) do
					if self.config.SymbolicTargetindicator_Enabled then
						local indicator = self.TargetIndicators[i]
						if not indicator then
							indicator = CreateFrame("frame",nil,self.Health)
							indicator:SetSize(8,10)
							indicator:SetPoint("TOP",floor(i/2)*(i%2==0 and -10 or 10), 0) --1: 0, 0 2: -10, 0 3: 10, 0 4: -20, 0 > i = even > left, uneven > right 
							indicator = SetBackdrop(indicator, nil, {0,0,0,1})
							self.TargetIndicators[i] = indicator
						end
						local classColor = allyDetails.ClassColor
						indicator:SetBackdropColor(classColor.r,classColor.g,classColor.b)
						indicator:Show()
						if not allyTarget and allyDetails.TargetUnitID ~= "target" then
							allyTarget = allyDetails.TargetUnitID
						end
					end
					i = i+1
				end
				if self.config.NumericTargetindicator_Enabled then 
					self.TargetCounter.Text:SetText(i-1)
				end
				while self.TargetIndicators[i] do --hide no longer used ones
					self.TargetIndicators[i]:Hide()
					i = i+1
				end
			end
			
			function enemyButtonFunctions:UpdateHealth(unitID)
				-- RespawnTimer
				-- if not UnitExists(unitID) then
					-- BattleGroundEnemies:Debug("UpdateAll", unitID, self.DisplayedName, "doesn't exist")
				-- end
				--BattleGroundEnemies:Debug(unitID, self.DisplayedName)
				if UnitIsDead(unitID) then
					--BattleGroundEnemies:Debug("UpdateAll", UnitName(unitID), "UnitIsDead")
					self.ObjectiveAndRespawn:ShowRespawnTimer(27)
				elseif self.ObjectiveAndRespawn.ActiveRespawnTimer then --player is alive again
					self.ObjectiveAndRespawn.Cooldown:Clear()
				end
				self.Health:SetValue(UnitHealth(unitID)/UnitHealthMax(unitID))
			end
			
			function enemyButtonFunctions:CheckForNewPowerColor(powerToken)
				if self.Power.powerToken ~= powerToken then
					local color = PowerBarColor[powerToken]
					if color then
						self.Power:SetStatusBarColor(color.r, color.g, color.b)
						self.Power.powerToken = powerToken
					end
				end
			end

			function enemyButtonFunctions:UpdatePower(unitID, powerToken)
				if powerToken then
					self:CheckForNewPowerColor(powerToken)
				else
					local powerType, powerToken, altR, altG, altB = UnitPowerType(unitID)
					self:CheckForNewPowerColor(powerToken)
				end
				self.Power:SetValue(UnitPower(unitID)/UnitPowerMax(unitID))
			end
			
			function enemyButtonFunctions:UpdateRange(inRange)
				if self.config.RangeIndicator_Enabled and not inRange then
					self:SetAlpha(self.config.RangeIndicator_Alpha)
				else
					self:SetAlpha(1)
				end
			end
			
			function enemyButtonFunctions:UpdateAll(unitID)
				self:UpdateRange(IsItemInRange(self.config.RangeIndicator_Range, unitID))
				self:UpdateHealth(unitID)
				if self.config.PowerBar_Enabled then self:UpdatePower(unitID) end
			end
		
			
			--Relentless maybe
			function enemyButtonFunctions:RelentlessCheck(spellID, spellName)
				if not self.config.Trinket_Enabled then return end
				
				if self.Trinket.HasTrinket then
					return
				end
				
				local activeUnitID = self.UnitIDs.Active
				if not activeUnitID then
					return 
				end
				
				local drCat = DRData:GetSpellCategory(spellID)
				if not Data.cCduration[drCat] then 
					return 
				end
				
				local normalDuration = Data.cCduration[drCat][spellID]
				if not normalDuration then 
					return 
				end
				
				local _, _, _, _, _, actualDuration = UnitDebuff(activeUnitID, spellName)

				if not actualDuration then
					return 
				end
				local Racefaktor = 1
				if drCat == "stun" and self.PlayerRace == "Orc" then
					Racefaktor = 0.8	--Hardiness
				end

				
				--local diminish = actualduraion/(Racefaktor * normalDuration * Trinketfaktor)
				--local trinketFaktor * diminish = actualDuration/(Racefaktor * normalDuration) 
				--trinketTimesDiminish = trinketFaktor * diminish
				--trinketTimesDiminish = without relentless : 1, 0.5, 0.25, with relentless: 0.8, 0.4, 0.2
				local trinketTimesDiminish = (actualDuration/(Racefaktor * normalDuration))
				
				if trinketTimesDiminish == 0.8 or trinketTimesDiminish == 0.4 or trinketTimesDiminish == 0.2 then --Relentless
					self.Trinket.HasTrinket = 4
					self.Trinket.Icon:SetTexture(GetSpellTexture(196029))
				end
			end
			
			function enemyButtonFunctions:RacialUsed(spellID)
				if not self.config.Racial_Enabled then return end
				local insi = self.Trinket
				local racial = self.Racial
				racial.Icon:SetTexture(Data.TriggerSpellIDToDisplayFileId[spellID])
				racial.Cooldown:SetCooldown(GetTime(), Data.RacialSpellIDtoCooldown[spellID])
																		-- relentless check						only set if shorter than 30 seconds
				if Data.RacialSpellIDtoCooldownTrigger[spellID] and not insi.HasTrinket == 4 and insi.Cooldown:GetCooldownDuration() < 30000 then
					insi.Cooldown:SetCooldown(GetTime(), Data.RacialSpellIDtoCooldownTrigger[spellID])
				end
			end
			
		
			function enemyButtonFunctions:DrPositioning()

				local anchor = self.DrContainerStartAnchor
				for categorie, drFrame in pairs(self.DR) do
					if drFrame:IsShown() then
						local spacing = self.config.DrTracking_Spacing
						drFrame:SetPoint("TOPRIGHT", anchor, "TOPLEFT", -spacing, 0)
						drFrame:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMLEFT", -spacing, 0)
						anchor = drFrame
					end
				end
				if self.DebuffContainerStartAnchor ~= anchor then
					self.DebuffContainerStartAnchor = anchor
					self:DebuffPositioning()
				end
			end
			
			function enemyButtonFunctions:DebuffPositioning()

				local anchor = self.DebuffContainerStartAnchor
				for spellID, debuffFrame in pairs(self.MyDebuffs) do
	
					local spacing = self.config.MyDebuffs_Spacing
					debuffFrame:SetPoint("TOPRIGHT", anchor, "TOPLEFT", -spacing, 0)
					debuffFrame:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMLEFT", -spacing, 0)
					anchor = debuffFrame
				end
			end
			
			do
				local UAspellIDs = {
					[233490] = true,
					[233496] = true,
					[233497] = true,
					[233498] = true,
					[233499] = true,	
				}
				local function debuffFrameCooldown_OnHide(self)
					local debuffFrame = self:GetParent()
					debuffFrame.Stacks:SetText("")
					debuffFrame:Hide()
					local enemyButton = debuffFrame:GetParent()
					enemyButton.MyDebuffs[debuffFrame.SpellID] = nil
					enemyButton:DebuffPositioning()
					enemyButton.InactiveDebuffs[#enemyButton.InactiveDebuffs + 1] = debuffFrame
				end
				
				
				function enemyButtonFunctions:SetNewDebuff(spellID, count, duration)

					local debuffFrame = self.InactiveDebuffs[#self.InactiveDebuffs] 
					if debuffFrame then --recycle a previous used Frame
						tremove(self.InactiveDebuffs, #self.InactiveDebuffs)
						debuffFrame:Show()
					else -- create a new Frame 
					
						debuffFrame = CreateFrame('Frame', nil, self)
						debuffFrame:SetWidth(self.config.BarHeight)
						
						debuffFrame.Icon = debuffFrame:CreateTexture(nil, "BACKGROUND")
						debuffFrame.Icon:SetAllPoints()

						debuffFrame.Stacks = CreateFontString(debuffFrame, true, nil, nil, "RIGHT", "BOTTOM", self.config.MyDebuffs_Fontsize, self.config.MyDebuffs_Outline, self.config.MyDebuffs_Textcolor, self.config.MyDebuffs_EnableTextshadow, self.config.MyDebuffs_TextShadowcolor)
						
						debuffFrame.Cooldown = CreateCooldown(debuffFrame, self.config.MyDebuffs_ShowNumbers, true, false)
						debuffFrame.Cooldown:SetScript("OnHide", debuffFrameCooldown_OnHide)
					end

					debuffFrame.SpellID = spellID
					debuffFrame.Icon:SetTexture(GetSpellTexture(spellID))
					if count > 0 then
						debuffFrame.Stacks:SetText(count)
					end
					debuffFrame.Cooldown:SetCooldown(GetTime(), duration)
					
					self.MyDebuffs[spellID] = debuffFrame
					self:DebuffPositioning()
				end
				
				
				
				function enemyButtonFunctions:DebuffChanged(testmode, srcName, _spellID, spellName, applied, removed, count, duration)
					
					if not self.config.MyDebuffs_Enabled then return end
					
					local myDebuffFrame = self.MyDebuffs[_spellID]
					if removed and myDebuffFrame then
						myDebuffFrame.Cooldown:Clear()
					end
					
					
					if applied then
						if not testmode then
						
							local activeUnitID = self.UnitIDs.Active
							if not activeUnitID or srcName ~= PlayerDetails.PlayerName then return end
						
							local spellID, _
							if UAspellIDs[_spellID] then --more expensier way since we need to iterate through all debuffs
								for i = 1, 40 do
									_, _, _, count, _, duration, _, _, _, _, spellID, _, _, _, _, _, _, _, _ = UnitDebuff(activeUnitID, i, "PLAYER")
									if spellID == _spellID then
										break
									end
								end
							else
								local spellName = GetSpellInfo(_spellID)
								_, _, _, count, _, duration, _, _, _, _, spellID, _, _, _, _, _, _, _, _ = UnitDebuff(activeUnitID, spellName, nil, "PLAYER")
							end
						end
						
						if duration and duration > 0 then
							self:SetNewDebuff(_spellID, count, duration)
						end
					end
				end
			end
			
			
			--Checks if an enemy uses Relentless
			do
				local dRstates = {
					[1] = { 0, 1, 0, 1}, --green (next cc in DR time will be only half duration)
					[2] = { 1, 1, 0, 1}, --yellow (next cc in DR time will be only 1/4 duration)
					[3] = { 1, 0, 0, 1}, --red (next cc in DR time will not apply, player is immune)
				}
				
				local function drFrame_SetCooldown(enemyButton, drFrame, starttime, duration, spellID)
					if not drFrame:IsShown() then
						drFrame:Show()
						enemyButton:DrPositioning() 
					end
					drFrame.Icon:SetTexture(GetSpellTexture(spellID))
					drFrame.Cooldown:SetCooldown(starttime, duration)
				end
				
				local function drFrameCooldown_OnHide(self)
					local drFrame = self:GetParent()
					drFrame:Hide()
					drFrame.status = 1
					drFrame:GetParent():DrPositioning() --enemyButton:DrPositioning()
				end
			
				function enemyButtonFunctions:UpdateDR(spellID, spellName, applied, removed)
					if not self.config.DrTracking_Enabled then return end
					
					local drCat = DRData:GetSpellCategory(spellID)
					--BattleGroundEnemies:Debug(operation, spellID)
					if not drCat then return end

					--refreshed (for example a resheep) is basically removed + applied 
					local drFrame = self.DR[drCat]
					if not drFrame then  --create a new frame for this categorie
						
						drFrame = CreateFrame("Frame", nil, self)
						drFrame:SetWidth(self.config.BarHeight)

						drFrame = SetBackdrop(drFrame, {0,0,0,0}, nil)
			
						
						drFrame.Icon = drFrame:CreateTexture(nil, "BORDER", nil, -1) -- -1 to make it behind the SetBackdrop bg
						drFrame.Icon:SetAllPoints()
						
						drFrame.Cooldown = CreateCooldown(drFrame, self.config.DrTracking_ShowNumbers, false, false)
						
						drFrame.status = 1
						-- for _, region in next, {drFrame.Cooldown:GetRegions()} do
							-- if ( region:GetObjectType() == "FontString" ) then
								-- region:SetFont("Fonts\\FRIZQT__.TTF", , "OUTLINE")
							-- end
						-- end
						
						drFrame.Cooldown:SetScript("OnHide", drFrameCooldown_OnHide)
						drFrame:Hide()
						
						self.DR[drCat] = drFrame
					end

					
					
					
					if removed then --removed
						if drFrame.status == 1 then -- we didn't get the applied, so we set the color and increase the dr state
							--BattleGroundEnemies:Debug("DR Problem")
							drFrame:SetBackdropBorderColor(unpack(dRstates[drFrame.status]))
							drFrame.status = drFrame.status + 1
						end
						drFrame_SetCooldown(self, drFrame, GetTime(), DRData:GetResetTime(drCat), spellID)
					end
					
					if applied and drFrame.status < 4 then --applied
						if spellName and self.UnitIDs.Active then --check for spellname for testmode, we don't wanna show a long duration in testmode
							local _, _, _, _, _, actualDuration = UnitDebuff(self.UnitIDs.Active, spellName) 
							--BattleGroundEnemies:Debug(GetTime(), actualDuration, GetTime() + actualDuration)
							if actualDuration then
								drFrame_SetCooldown(self, drFrame, GetTime(), DRData:GetResetTime(drCat) + actualDuration, spellID)
							end
						end
						drFrame:SetBackdropBorderColor(unpack(dRstates[drFrame.status]))
						drFrame.status = drFrame.status + 1
					end
				end
			end
			
		end
			
		
		local TrinketFrameFunctions = {}
		function TrinketFrameFunctions:TrinketCheck(spellID, setCooldown)
			if not BattleGroundEnemies.db.profile.Trinket_Enabled then return end
			if not Data.TriggerSpellIDToTrinketnumber[spellID] then return end
			self.HasTrinket = Data.TriggerSpellIDToTrinketnumber[spellID]
			self.Icon:SetTexture(Data.TriggerSpellIDToDisplayFileId[spellID])
			if setCooldown then
				self.Cooldown:SetCooldown(GetTime(), Data.TrinketTriggerSpellIDtoCooldown[spellID])
			end
		end
		
		
		local function button_OnDragStart()
			return BattleGroundEnemies.db.profile.Locked or BattleGroundEnemies:StartMoving()
		end
		
		function BattleGroundEnemies:CropImage(texture, width, height)
			local ratio = height / width
			local left, right, top, bottom = 5, 59, 5, 59
			if ratio > 1 then --crop the sides
				ratio = 1/ratio 
				texture:SetTexCoord( (left/64) + ((1- ratio) / 2), (right/64) - ((1- ratio) / 2), top/64, bottom/64) 
			elseif ratio == 1 then
				texture:SetTexCoord( left/64, right/64, top/64, bottom/64 ) 
			else
				-- crop the height
				texture:SetTexCoord( left/64, right/64, (top/64) + ((1- ratio) / 2), (bottom/64) - ( (1- ratio) / 2)) 
			end
		end
		
		function BattleGroundEnemies:CreateNewPlayerButton()
			local conf = self.db.profile
			local button = CreateFrame('Button', nil, self, 'SecureActionButtonTemplate')
			-- setmetatable(button, self)
			-- self.__index = self
			
			for functionName, func in pairs(enemyButtonFunctions) do
				button[functionName] = func
			end
			
			button:SetScript("OnSizeChanged", function(self, width, height)
				self.Trinket:SetWidth(height)
				self.Racial:SetWidth(height)
				for drCategorie, drFrame in pairs(self.DR) do
					drFrame:SetWidth(height)
				end
				for spellID, debuffFrame in pairs(self.MyDebuffs) do
					debuffFrame:SetWidth(height)
				end
				
				
			end)
			
			
			
			button:SetHeight(conf.BarHeight)
			
					
			-- events/scripts
			button:RegisterForClicks('AnyUp')
			button:RegisterForDrag('LeftButton')
			button:SetAttribute('type1','macro')-- type1 = Left-Click
			button:SetAttribute('type2','macro')-- type2 = Right-Click, type3 = Middle-Click

			button:SetScript('OnDragStart', button_OnDragStart)
			button:SetScript('OnDragStop', BattleGroundEnemies.SavePosition)
			
			
			-- spec
			button.Spec = MyCreateFrame("Frame", button, {'TOPLEFT'}, {'BOTTOMLEFT'}, conf.Spec_Width)
			
			button.Spec.Icon = button.Spec:CreateTexture(nil, 'BACKGROUND')
			button.Spec.Icon:SetAllPoints()
		
			button.Spec:SetScript("OnSizeChanged", function(self, width, height)
				BattleGroundEnemies:CropImage(self.Icon, width, height)
			end)

			-- power
			button.Power = MyCreateFrame('StatusBar', button, {'BOTTOMLEFT', button.Spec, "BOTTOMRIGHT", 1, 1}, {'BOTTOMRIGHT', button, "BOTTOMRIGHT", -1, 1}, nil, conf.PowerBar_Height)
			button.Power:SetStatusBarTexture(LSM:Fetch("statusbar", conf.PowerBar_Texture))--enemyButton.Health:SetStatusBarTexture(137012)
			button.Power:SetMinMaxValues(0, 1)

			
			--button.Power.Background = button.Power:CreateTexture(nil, 'BACKGROUND', nil, 2)
			button.Power.Background = button.Power:CreateTexture(nil, 'BACKGROUND')
			button.Power.Background:SetAllPoints()
			button.Power.Background:SetTexture("Interface/Buttons/WHITE8X8")
			button.Power.Background:SetVertexColor(unpack(conf.PowerBar_Background))
			
			-- health
			button.Health = MyCreateFrame('StatusBar', button, {'BOTTOMLEFT', button.Power, "TOPLEFT", 0, 0}, {'TOPRIGHT', button, "TOPRIGHT", -1, -1})
			button.Health:SetStatusBarTexture(LSM:Fetch("statusbar", conf.HealthBar_Texture))--enemyButton.Health:SetStatusBarTexture(137012)
			button.Health:SetMinMaxValues(0, 1)
			
			-- role
			button.Role = MyCreateFrame("Frame", button, {'TOPLEFT', button.Health, 'TOPLEFT', 2, -2}, nil, 12, 12)
			
			button.Role.Icon = button.Role:CreateTexture(nil, 'OVERLAY')
			button.Role.Icon:SetAllPoints()		
			button.Role.Icon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")

			
			--button.Health.Background = button.Health:CreateTexture(nil, 'BACKGROUND', nil, 2)
			button.Health.Background = button.Health:CreateTexture(nil, 'BACKGROUND')
			button.Health.Background:SetAllPoints()
			button.Health.Background:SetTexture("Interface/Buttons/WHITE8X8")
			button.Health.Background:SetVertexColor(unpack(conf.HealthBar_Background))
			
			--MyTarget, indicating the current target of the player
			
			button.MyTarget = MyCreateFrame('Frame', button.Health, {"TOPLEFT", button.Health, "TOPLEFT", -1, 1}, {"BOTTOMRIGHT", button.Power, "BOTTOMRIGHT", 1, -1}, nil)
			button.MyTarget = SetBackdrop(button.MyTarget, {0, 0, 0, 0}, conf.MyTarget_Color)
			button.MyTarget:Hide()
			
			--MyFocus, indicating the current focus of the player
			button.MyFocus = MyCreateFrame('Frame', button.Health, {"TOPLEFT", button.Health, "TOPLEFT", -1, 1}, {"BOTTOMRIGHT", button.Power, "BOTTOMRIGHT", 1, -1}, nil)
			button.MyFocus = SetBackdrop(button.MyFocus, {0, 0, 0, 0}, conf.MyFocus_Color)
			button.MyFocus:Hide()
			
			-- numerical target indicator
			button.TargetCounter = MyCreateFrame("Frame", button, {'TOPRIGHT', button.Health, "TOPRIGHT", -5, 0}, {'BOTTOMRIGHT', button.Health, "BOTTOMRIGHT", -5, 0}, 20)
			
			button.TargetCounter.Text = CreateFontString(button.TargetCounter, true, nil, nil, 'RIGHT', nil, conf.NumericTargetindicator_Fontsize, conf.NumericTargetindicator_Outline, conf.NumericTargetindicator_Textcolor, conf.NumericTargetindicator_EnableTextshadow, conf.NumericTargetindicator_TextShadowcolor)
			button.TargetCounter.Text:SetText(0)
			
			-- symbolic target indicator
			button.TargetIndicators = {}

			-- name
			button.Name = CreateFontString(button.Health, false, {'TOPLEFT', button.Role, "TOPRIGHT", 5, 2}, {'BOTTOMRIGHT', button.TargetCounter, "BOTTOMLEFT", 0, 0}, 'LEFT', nil, conf.Name_Fontsize, conf.Name_Outline, conf.Name_Textcolor, conf.Name_EnableTextshadow, conf.Name_TextShadowcolor)
			
			-- trinket
			button.Trinket = MyCreateFrame("Frame", button, {'TOPLEFT', button, 'TOPRIGHT', 1, 0}, {'BOTTOMLEFT', button, 'BOTTOMRIGHT', 1, 0}, conf.BarHeight)
						
			button.Trinket.Icon = button.Trinket:CreateTexture()
			button.Trinket.Icon:SetAllPoints()
			button.Trinket.Icon:SetTexCoord(0.075, 0.925, 0.075, 0.925)
			
			button.Trinket.Cooldown = CreateCooldown(button.Trinket, conf.Trinket_ShowNumbers, false, true, {0, 0, 0, 0.75})
			
			-- for _, region in next, {button.Trinket.Cooldown:GetRegions()} do
				-- if ( region:GetObjectType() == "FontString" ) then
					-- region:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
				-- end
			-- end
			button.Trinket.TrinketCheck = TrinketFrameFunctions.TrinketCheck 
	
			
			-- RACIALS
			button.Racial = MyCreateFrame("Frame", button, {'TOPLEFT', button.Trinket, 'TOPRIGHT', 1, 0}, {'BOTTOMLEFT', button.Trinket, 'BOTTOMRIGHT', 1, 0}, conf.BarHeight)

			button.Racial.Icon = button.Racial:CreateTexture()
			button.Racial.Icon:SetAllPoints()
			button.Racial.Icon:SetTexCoord(0.075, 0.925, 0.075, 0.925)
			
			button.Racial.Cooldown = CreateCooldown(button.Racial, conf.Racial_ShowNumbers, false, true, {0, 0, 0, 0.75})		
			
			-- Diminishing Returns
			button.DR = {}
			
			
			-- MyDebuffs
			button.MyDebuffs = {}
			button.InactiveDebuffs = {}

			
			button.ObjectiveAndRespawn = MyCreateFrame("Frame", button, {'TOPRIGHT', button, 'TOPLEFT', -1, 0}, {'BOTTOMRIGHT', button, 'BOTTOMRIGHT', -1, 0}, conf.ObjectiveAndRespawn_Width)
			
			button.ObjectiveAndRespawn:SetScript("OnHide", function() 
				--self:Debug("ObjectiveAndRespawn hidden")
				button.DrContainerStartAnchor = button.Spec
				button:DrPositioning()
			end)
			button.ObjectiveAndRespawn:SetScript("OnShow", function() 
				--self:Debug("ObjectiveAndRespawn shown")
				button.DrContainerStartAnchor = button.ObjectiveAndRespawn
				button:DrPositioning()
			end)
			
			button.ObjectiveAndRespawn.ShowRespawnTimer = objectiveFrameFunctions.ShowRespawnTimer
			
			button.ObjectiveAndRespawn.Icon = button.ObjectiveAndRespawn:CreateTexture(nil, "BORDER")
			button.ObjectiveAndRespawn.Icon:SetAllPoints()
			
			button.ObjectiveAndRespawn:SetScript("OnSizeChanged", function(self, width, height)
				BattleGroundEnemies:CropImage(self.Icon, width, height)
			end)
			

			button.ObjectiveAndRespawn.AuraText = CreateFontString(button.ObjectiveAndRespawn, true, nil, nil, "CENTER", nil, conf.ObjectiveAndRespawn_Fontsize, conf.ObjectiveAndRespawn_Outline, conf.ObjectiveAndRespawn_Textcolor, conf.ObjectiveAndRespawn_EnableTextshadow, conf.ObjectiveAndRespawn_TextShadowcolor)
			
			button.ObjectiveAndRespawn.Cooldown = CreateCooldown(button.ObjectiveAndRespawn, conf.ObjectiveAndRespawn_ShowNumbers, true, true, {0, 0, 0, 0.75})	
			
		
			button.ObjectiveAndRespawn.Cooldown:SetScript("OnHide", function() 
				--self:Debug("ObjectiveAndRespawn.Cooldown hidden")
				button.ObjectiveAndRespawn.Icon:SetTexture()
				button.ObjectiveAndRespawn:Hide()
				button.ObjectiveAndRespawn.ActiveRespawnTimer = false
			end)
			
			button.config = conf
			return button
		end
		
		
		
		local RoleIcons = {
			HEALER = "Interface\\AddOns\\BattleGroundEnemies\\Images\\Healer",
			TANK = "Interface\\AddOns\\BattleGroundEnemies\\Images\\Tank",
			DAMAGER = "Interface\\AddOns\\BattleGroundEnemies\\Images\\Damager",
		}
		
		
		do
			local usersParent = {}
			local usersPetParent = {}
			local fakeParent
			local fakeFrame = CreateFrame("frame")
		
			function BattleGroundEnemies:ToggleArenaFrames()
				if not self then self = BattleGroundEnemies end

				if not InCombatLockdown() then
					--self:Debug("self.db.profile.DisableArenaFrames", self.db.profile.DisableArenaFrames)
					if self.db.profile.DisableArenaFrames then
						if CurrentMapID then
							if not fakeParent then
								for i = 1, 4 do
									local arenaFrame = _G["ArenaEnemyFrame"..i]
									usersParent[i] = arenaFrame:GetParent() 
									arenaFrame:SetParent(fakeFrame)
									local arenaPetFrame = _G["ArenaEnemyFrame"..i.."PetFrame"]
									usersPetParent[i] = arenaPetFrame:GetParent() 
									arenaPetFrame:SetParent(fakeFrame)
								end
								fakeParent = true
								fakeFrame:Hide()
							end
						elseif fakeParent then
							for i = 1, 4 do
								local arenaFrame = _G["ArenaEnemyFrame"..i]
								arenaFrame:SetParent(usersParent[i])
								local arenaPetFrame = _G["ArenaEnemyFrame"..i.."PetFrame"]
								arenaPetFrame:SetParent(usersPetParent[i])
							end
							fakeParent = false
						end
					elseif fakeParent then
						for i = 1, 4 do
							local arenaFrame = _G["ArenaEnemyFrame"..i]
							arenaFrame:SetParent(usersParent[i])
							local arenaPetFrame = _G["ArenaEnemyFrame"..i.."PetFrame"]
							arenaPetFrame:SetParent(usersPetParent[i])
						end
						fakeParent = false
					end
				else
					C_Timer.After(0.1, self.ToggleArenaFrames)
				end
			end
		end
		
		local numArenaOpponents
		
		local function ArenaEnemiesAtBeginn()
			if #BattleGroundEnemies.EnemySortingTable > 1 then --this ensures that we checked for enmys and the flag carrier will be shown (if its an enemy)
				for i = 1,  numArenaOpponents do
					local unitID = "arena"..i
					--BattleGroundEnemies:Debug(UnitName(unitID))
					local enemyButton = BattleGroundEnemies:GetEnemybuttonByUnitID(unitID)
					if enemyButton then
						--BattleGroundEnemies:Debug("Button exists")
						enemyButton:ArenaOpponentShown(unitID)
					end
				end
			else
				C_Timer.After(2, ArenaEnemiesAtBeginn)
			end
		end
						
		
		local oldNumEnemies, EnemyFaction
		
		
		function BattleGroundEnemies:UPDATE_BATTLEFIELD_SCORE()

			--self:Debug(GetCurrentMapAreaID())
			-- self:Debug("UPDATE_BATTLEFIELD_SCORE")
			-- self:Debug("GetBattlefieldArenaFaction", GetBattlefieldArenaFaction())
			-- self:Debug("C_PvP.IsInBrawl", C_PvP.IsInBrawl())
			-- self:Debug("GetCurrentMapAreaID", GetCurrentMapAreaID())
			--self:Debug("horde players:", GetBattlefieldTeamInfo(0))
			--self:Debug("alliance players:", GetBattlefieldTeamInfo(1))
					
			

			if not CurrentMapID then
				local wmf = WorldMapFrame
				if wmf and not wmf:IsShown() then
					SetMapToCurrentZone()
					local mapID = GetCurrentMapAreaID()
					--self:Debug(mapID)
					if mapID == -1 or mapID == 0 then --if this values occur GetCurrentMapAreaID() doesn't return valid values yet.
						return
					end
					local numScores = GetNumBattlefieldScores()
					if not numScores or numScores < 5 then return end --otherwise we will get incorrent data from GetBattlefieldArenaFaction()
					CurrentMapID = mapID
				end
				
				
				
				--self:Debug("test")
				if BrawlCheck and not IsInBrawl() then
					RequestFrame:Hide() --stopp the OnUpdateScript
					self:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE")--stopping the onupdate script should do it but other addons make "UPDATE_BATTLEFIELD_SCORE" trigger aswell
					return --no valid zone
				end
				
				
				local MyBgFaction = GetBattlefieldArenaFaction()  -- returns the playered faction 0 for horde, 1 for alliance
				if MyBgFaction == 0 then -- i am Horde
					EnemyFaction = 1 --Enemy is Alliance
				else
					EnemyFaction = 0 --Enemy is Horde
				end
				
				if Data.BattlegroundspezificBuffs[CurrentMapID] then
					BattlegroundBuff = Data.BattlegroundspezificBuffs[CurrentMapID][EnemyFaction]
				end
				
				BattleGroundDebuffs = Data.BattlegroundspezificDebuffs[CurrentMapID]
				
				--Check if we joined a match late and there are already arena unitids (flag-, orb-, or minecart-carriers) we wont get a ARENA_OPPONENT_UPDATE 
				numArenaOpponents = GetNumArenaOpponents()-- returns valid data on PLAYER_ENTERING_WORLD
				--self:Debug(numArenaOpponents)
				if numArenaOpponents > 0 then 
					C_Timer.After(2, ArenaEnemiesAtBeginn)
				end
				
				self:ToggleArenaFrames()
				
				oldNumEnemies = 0
				IsRatedBG = IsRatedBattleground()
				--self:Debug("IsRatedBG", IsRatedBG)
				self:GROUP_ROSTER_UPDATE()
			end
			
			
			local _, _, _, _, numEnemies = GetBattlefieldTeamInfo(EnemyFaction)
			
			if numEnemies ~= oldNumEnemies then
				if IsRatedBG and self.db.profile.Notificatoins_Enabled then
					if numEnemies < oldNumEnemies then
						RaidNotice_AddMessage(RaidWarningFrame, L.EnemyLeft, ChatTypeInfo["RAID_WARNING"]) 
						PlaySound("LEVELUPSOUND")
					else -- numEnemies > oldNumEnemies
						RaidNotice_AddMessage(RaidWarningFrame, L.EnemyJoined, ChatTypeInfo["RAID_WARNING"]) 
						PlaySound("RaidWarning")
					end
				end
				if self.db.profile.EnemyCount_Enabled then
					if EnemyFaction == 0 then -- enemy is Horde
						self.EnemyCount:SetText(format(PLAYER_COUNT_HORDE, numEnemies))
					else --enemy is Alliance
						self.EnemyCount:SetText(format(PLAYER_COUNT_ALLIANCE, numEnemies))
					end
				end

				oldNumEnemies = numEnemies
			end
			
			
			if InCombatLockdown() then return end
			
			
			if numEnemies and numEnemies <= self.db.profile.MaxPlayers and numEnemies > 0 then
				self:Show()
			else
				self:Hide()
				return
			end
			
			
			local numScores = GetNumBattlefieldScores()
			local newPlayerDetails = {} --use a local table to not create an unnecessary new button if another player left
			local resort = false
			for i = 1, numScores do
				local name,_,_,_,_,faction,race, _, classTag,_,_,_,_,_,_,spec = GetBattlefieldScore(i)
				--name = name-realm, faction = 0 or 1, race = localized race e.g. "Mensch",classTag = e.g. "PALADIN", spec = localized specname e.g. "holy"
				--locale dependent are: race, spec
				
				if faction == EnemyFaction and name and race and classTag and spec then
					local enemyButton = self.Enemies[name]
					if enemyButton then	--already existing
						enemyButton.Status = 1 --1 means found, already existing
						if enemyButton.PlayerSpec ~= spec then--its possible to change spec in battleground
							enemyButton.PlayerRoleNumber = Data.Classes[classTag][spec].roleNumber
							enemyButton.PlayerRoleID = Data.Classes[classTag][spec].roleID
							enemyButton.Spec.Icon:SetTexture(Data.Classes[classTag][spec].specIcon)
							enemyButton.PlayerSpec = spec
							
							resort = true
						end
					else
						newPlayerDetails[name] = { -- details of this new player
							PlayerRace = LibRaces:GetRaceToken(race), --delifers are local independent token for relentless check
							PlayerClass = classTag,
							PlayerSpec = spec,
						}
						resort = true
					end
				end
			end
			
			--Rückwärts um keine Probleme mit tremove zu bekommen, wenn man mehr als einen Spieler in einem Schleifendurchlauf entfernt,
			-- da ansonsten die enemyButton.Position nicht mehr passen (sie sind zu hoch)
			for i = #self.EnemySortingTable, 1, -1 do
				local name = self.EnemySortingTable[i]
				local enemyButton = self.Enemies[name]
				if enemyButton.Status == 2 then --no longer existing
					self:RemoveEnemy(name, enemyButton)
					resort = true
				else -- == 1 -- set to 2 for the next comparison
					enemyButton.Status = 2
				end 
			end
			for name, enemyDetails in pairs(newPlayerDetails) do
				local enemyButton = self:SetupButtonForNewPlayer(enemyDetails, name)
				
				-- set data for real enemies
				enemyButton.Status = 2
				
				enemyButton:SetAttribute('macrotext1',
					'/cleartarget\n'..
					'/targetexact '..name
				)

				enemyButton:SetAttribute('macrotext2',
					'/targetexact '..name..'\n'..
					'/focus\n'..
					'/targetlasttarget'
				)

				if BattleGroundDebuffs then
					if CurrentMapID == 856 then --8456 is kotmogu
						enemyButton.ObjectiveAndRespawn:SetScript('OnEvent', objectiveFrameFunctions.Kotmoguorbs)
					else
						enemyButton.ObjectiveAndRespawn:SetScript('OnEvent', objectiveFrameFunctions.NotKotmogu)
					end
				end
				
				enemyButton.UnitIDs = {TargetedByAlly = {}}
				enemyButton:UpdateRange(false)
				-- end set data for real enemies
				
				tinsert(self.EnemySortingTable, name)				
				self.Enemies[name] = enemyButton
			end

			if resort then
				self:SortEnemies()
			end
			
		end--functions end
	end-- do-end block end for locals of the function UPDATE_BATTLEFIELD_SCORE
	
	function BattleGroundEnemies:PLAYER_ENTERING_WORLD()
		if self.TestmodeActive then --disable testmode
			self:DisableTestMode()
		end
	
		local _, zone = IsInInstance()
		if zone == "pvp" or zone == "arena" then
			if zone == "arena" then
				BrawlCheck = true
			end
			CurrentMapID = false
			-- self:Debug("PLAYER_ENTERING_WORLD")
			-- self:Debug("GetBattlefieldArenaFaction", GetBattlefieldArenaFaction())
			-- self:Debug("C_PvP.IsInBrawl", C_PvP.IsInBrawl())
			-- self:Debug("GetCurrentMapAreaID", GetCurrentMapAreaID())

			
			
			for i = #self.EnemySortingTable, 1, -1 do
				local name = self.EnemySortingTable[i]
				self:RemoveEnemy(name)
			end

			RequestFrame:Show()
			self.PlayerIsAlive = true
			
			self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
		else
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
			self:UnregisterEvent("PLAYER_TARGET_CHANGED")
			self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
			self:UnregisterEvent("UNIT_TARGET")
			self:UnregisterEvent("UNIT_HEALTH_FREQUENT") --fires when health of player, target, focus, nameplateX, arenaX, raidX updates
			self:UnregisterEvent("UNIT_POWER_FREQUENT") --fires when health of player, target, focus, nameplateX, arenaX, raidX updates
			self:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE")
			self:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
			self:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
			self:UnregisterEvent("ARENA_OPPONENT_UPDATE")--fires when a arena enemy appears and a frame is ready to be shown
			self:UnregisterEvent("ARENA_CROWD_CONTROL_SPELL_UPDATE") --fires when data requested by C_PvP.RequestCrowdControlSpell(unitID) is available
			self:UnregisterEvent("ARENA_COOLDOWNS_UPDATE") --fires when a arenaX enemy used a trinket or racial to break cc, C_PvP.GetArenaCrowdControlInfo(unitID) shoudl be called afterwards to get used CCs
			self:UnregisterEvent("GROUP_ROSTER_UPDATE")
			-- self:UnregisterEvent("LOSS_OF_CONTROL_ADDED")
			self:UnregisterEvent("PLAYER_ALIVE")
			self:UnregisterEvent("PLAYER_UNGHOST")
			
			self:ToggleArenaFrames()
			BrawlCheck = false
			RequestFrame:Hide()
			self:Hide()
		end
	end
end


BattleGroundEnemies:RegisterEvent("PLAYER_LOGIN")
BattleGroundEnemies:RegisterEvent("PLAYER_ENTERING_WORLD")
BattleGroundEnemies:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
