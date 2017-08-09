local addonName, Data = ...
local L = LibStub("AceLocale-3.0"):GetLocale("BattleGroundEnemies")
local LSM = LibStub("LibSharedMedia-3.0")
LSM:Register("font", "PT Sans Narrow Bold", [[Interface\AddOns\BattleGroundEnemies\Fonts\PT Sans Narrow Bold.ttf]])
LSM:Register("statusbar", "UI-StatusBar", "Interface\\TargetingFrame\\UI-StatusBar")



local DRData = LibStub("DRData-1.0")

local LibRaces = LibStub("LibRaces-1.0")



--upvalues
local _G = _G
local pairs = pairs
local print = print
local type = type
local unpack = unpack
local floor = math.floor

local C_PvP = C_PvP
local GetArenaCrowdControlInfo = C_PvP.GetArenaCrowdControlInfo
local RequestCrowdControlSpell = C_PvP.RequestCrowdControlSpell
local IsInBrawl = C_PvP.IsInBrawl
local CheckInteractDistance = CheckInteractDistance
local CreateFrame = CreateFrame
local GetBattlefieldArenaFaction = GetBattlefieldArenaFaction
local GetBattlefieldScore = GetBattlefieldScore
local GetBattlefieldTeamInfo = GetBattlefieldTeamInfo
local GetClassInfoByID = GetClassInfoByID
local GetCurrentMapAreaID = GetCurrentMapAreaID
local GetLocale = GetLocale
local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetNumGroupMembers = GetNumGroupMembers
local GetNumSpecializationsForClassID = GetNumSpecializationsForClassID
local GetRaidRosterInfo = GetRaidRosterInfo
local GetSpecializationInfoForClassID = GetSpecializationInfoForClassID
local GetSpellInfo = GetSpellInfo
local GetSpellTexture = GetSpellTexture
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local IsInInstance = IsInInstance
local IsItemInRange = IsItemInRange
local IsRatedBattleground = IsRatedBattleground
local IsSpellInRange = IsSpellInRange
local PlaySound = PlaySound
local RaidNotice_AddMessage = RaidNotice_AddMessage
local RequestBattlefieldScoreData = RequestBattlefieldScoreData
local SetMapToCurrentZone = SetMapToCurrentZone
local UnitClass = UnitClass
local UnitDebuff = UnitDebuff
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitInRange = UnitInRange
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitName = UnitName


--variables used in multiple functions, if a variable is only used by one function its declared above that function
local BattlegroundBuff --contains the battleground specific enemy buff to watchout for of the current active battlefield
local IsRatedBG
local PlayerName

local BattleGroundEnemies = CreateFrame("Frame", "BattleGroundEnemies", UIParent)
local OnUpdateFrame = CreateFrame("Frame")
OnUpdateFrame:Hide()


BattleGroundEnemies.InactiveEnemyButtons = {} --index = number, value = button(table)

BattleGroundEnemies.ArenaEnemyIDToEnemyButtonObjective = {} --key = arenaID: arenaX, value = enemyButton of that unitID
BattleGroundEnemies.Enemys = {} --index = name, value = button(table), contains enemyButtons
BattleGroundEnemies.Allys = {} --index = name, value = table
BattleGroundEnemies.AllyUnitIDToAllyDetails = {} --index = unitID ("raid"..i) of raidmember, value = Allytable of that group member, contains unitID "player"



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
			BarTexture = 'UI-StatusBar',
			BarBackground = {0, 0, 0, 1},
			
			SpaceBetweenRows = 1,
			Growdirection = "downwards",
			
			RoleIcon_Enabled = true,
			
			RangeIndicator_Enabled = true,
			RangeIndicator_Range = 18904,
			RangeIndicator_Alpha = 0.55,
			
			ShowRealmnames = true,
			ConvertCyrillic = true,
			DisableArenaFrames = true,
			
			EnemyCount_Enabled = true,
			EnemyCount_Fontsize = 14,
			EnemyCount_Outline = "",
			EnemyCount_Textcolor = {1, 1, 1, 1},
			EnemyCount_EnableTextshadow = true,
			EnemyCount_TextShadowcolor = {0, 0, 0, 1},
			
			Locked = false,
			MaxPlayers = 15,
			Framescale = 1,
			Debug = false,
			Test = false,
			
			
			Spec_Width = 36,
			Role_Width = 28,
			
			SymbolicTargetindicator_Enabled = true,
			
			NumericTargetindicator_Enabled = true,
			NumericTargetindicator_Fontsize = 16,
			NumericTargetindicator_Outline = "",
			NumericTargetindicator_Textcolor = {1, 1, 1, 1},
			NumericTargetindicator_EnableTextshadow = true,
			NumericTargetindicator_TextShadowcolor = {0, 0, 0, 1},
			
			MyTarget_Color = {17, 27, 161, 1},
			MyFocus_Color = {0, 0, 0, 1},
			
			DrTracking_Enabled = true,
			DrTracking_ShowNumbers = true,
			DrTracking_Spacing = 1,
			
			MyDebuffs_Enabled = true,
			MyDebuffs_ShowNumbers = true,
			MyDebuffs_Fontsize = 10,
			MyDebuffs_Outline = "",
			MyDebuffs_Textcolor = {1, 1, 1, 1},
			MyDebuffs_EnableTextshadow = true,
			MyDebuffs_TextShadowcolor = {0, 0, 0, 1},
			MyDebuffs_Spacing = 1,

			ObjectiveAndRespawn_ObjectiveEnabled = true,
			ObjectiveAndRespawn_RespawnEnabled = true,
			ObjectiveAndRespawn_Width = 36,
			ObjectiveAndRespawn_ShowNumbers = true,
			ObjectiveAndRespawn_Fontsize = 18,
			ObjectiveAndRespawn_Outline = "",
			ObjectiveAndRespawn_Textcolor = {1, 1, 1, 1},
			ObjectiveAndRespawn_EnableTextshadow = true,
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
		PlayerName = UnitName("player")
		-- ArenaFrameCvar = GetCVar("showArenaEnemyFrames")
		-- print("ArenaFrameCvar login", ArenaFrameCvar)
		
		self.db = LibStub("AceDB-3.0"):New("BattleGroundEnemiesDB", DefaultSettings, true)
		self.db.RegisterCallback(self, "OnProfileChanged", "UpdateFrames")
		self.db.RegisterCallback(self, "OnProfileCopied", "UpdateFrames")
		self.db.RegisterCallback(self, "OnProfileReset", "UpdateFrames")
		
		self:SetupOptions()
		--DBObjectLib:ResetProfile(noChildren, noCallbacks)
		self:SetSize(self.db.profile.BarWidth, 30)
		self:SetClampedToScreen(true)
		self:SetMovable(true)
		self:SetUserPlaced(true)
		self:SetResizable(true)
		self:SetToplevel(true)
		self:SetScale(self.db.profile.Framescale)
		
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

function BattleGroundEnemies:UpdateFrames()

end



-- Updates the TargetedByAlly tables.
function BattleGroundEnemies:UnitTargetCheck(unitID, isPlayer)

	local allyDetails = self.AllyUnitIDToAllyDetails[unitID]
	local newTargetUnitID = unitID.."target"
	
	local oldTargetEnemyButton = allyDetails.target
	if oldTargetEnemyButton then
		if isPlayer then
			oldTargetEnemyButton.MyTarget:Hide()
		end
		oldTargetEnemyButton:UpdateTargetIndicators(allyDetails, nil)
	end
	
	local newTargetEnemyButton = self:GetEnemybuttonByUnitID(newTargetUnitID)
	if newTargetEnemyButton then --ally targets an existing enemy
		if isPlayer then
			newTargetEnemyButton.MyTarget:Show()
		end
		allyDetails.target = newTargetEnemyButton
		newTargetEnemyButton:UpdateTargetIndicators(allyDetails, true)
		self:ScanUnit(newTargetUnitID, newTargetEnemyButton)
	else
		allyDetails.target = false
	end
end

function BattleGroundEnemies:SavePosition()
	self:StopMovingOrSizing()
	if not InCombatLockdown() then
		local scale = self:GetEffectiveScale()
		self.db.profile.Position_X = self:GetLeft() * scale
		self.db.profile.Position_Y = self:GetTop() * scale
	end
end

function BattleGroundEnemies:ScanUnit(unitID, enemyButton)
	if not enemyButton then --do checks if valid target
		if not UnitExists(unitID) then 
			return
		end
		
		enemyButton = self:GetEnemybuttonByUnitID(unitID)
		if not enemyButton then --unit is not a shown enemy
			return
		end
	end
	
	enemyButton:UpdateHealthRangeAndRespawn(unitID)
	
	--unitID and GUID update
	local enemyDetails = enemyButton.PlayerDetails
	if enemyDetails.UnitID then -- if player has a unitID he always has already a guid assigned, not vice-versa
		if enemyDetails.GUID ~= UnitGUID(enemyDetails.UnitID) then --the currently assigned unitID doesn't fit to this player anymore
			--print("Hallo")
			enemyDetails.UnitID = unitID --the current unitID isn't this player anymore, update it
		end
	else
		if not enemyDetails.GUID then
			enemyDetails.GUID = UnitGUID(unitID)
		end
		enemyDetails.UnitID = unitID
	end
end

do
	local TimeSinceLastOnUpdate = 0
	local UpdatePeroid = 1 --update every second
	function BattleGroundEnemies:OnUpdate(elapsed) --OnUpdate runs if the frame OnUpdateFrame is shown
		TimeSinceLastOnUpdate = TimeSinceLastOnUpdate + elapsed
		if TimeSinceLastOnUpdate > UpdatePeroid then
			for name, enemyButton in pairs(BattleGroundEnemies.Enemys) do
				local unitID = enemyButton.PlayerDetails.UnitID
				if unitID then 
					if UnitGUID(unitID) == enemyButton.PlayerDetails.GUID then
						enemyButton:UpdateHealthRangeAndRespawn(unitID)
					else -- unitID doesn't fit to that player anymore
						enemyButton.PlayerDetails.UnitID = nil
					end
				else
					local settings = BattleGroundEnemies.db.profile
					if settings.RangeIndicator_Enabled then
						enemyButton:SetAlpha(settings.RangeIndicator_Alpha) 
					end
				end
			end
			TimeSinceLastOnUpdate = 0
		end
	end
	OnUpdateFrame:SetScript("OnUpdate", BattleGroundEnemies.OnUpdate)
end


--fires when a arena enemy appears and a frame is ready to be shown
function BattleGroundEnemies:ARENA_OPPONENT_UPDATE(unitID, unitEvent)
	if unitEvent == "cleared" then 
		local enemyButtonObjective = self.ArenaEnemyIDToEnemyButtonObjective[unitID]
		if enemyButtonObjective then
			self.ArenaEnemyIDToEnemyButtonObjective[unitID] = nil
			enemyButtonObjective.Icon:SetTexture()
			enemyButtonObjective.Value = false
			enemyButtonObjective:UnregisterAllEvents()
			enemyButtonObjective:Hide()
		end
	else -- "unseen", "seen" or "destroyed"
		--print(UnitName(unitID))
		local enemyButton = self:GetEnemybuttonByUnitID(unitID)
		if enemyButton then
			--print("Button exists")
			enemyButton.ObjectiveAndRespawn:ArenaOpponentShown(unitID)
		end
	end
end

function BattleGroundEnemies:COMBAT_LOG_EVENT_UNFILTERED(timestamp,subevent,hide,srcGUID,srcName,srcF1,srcF2,destGUID,destName,destF1,destF2,spellID,spellName,spellSchool, auraType)
	if subevent == "SPELL_AURA_APPLIED" then
		if auraType == "DEBUFF" then
			local enemyButton = self.Enemys[destName]
			if enemyButton then
				enemyButton:UpdateDR(spellID, true)
				enemyButton:RelentlessCheck(spellID)
				enemyButton.Trinket:TrinketCheck(spellID, true) --adaptation used, maybe?
				enemyButton:DebuffChanged(srcName, spellID, true, false)
			end
		end
	elseif subevent == "SPELL_AURA_REFRESH" then
		if auraType == "DEBUFF" then
			local enemyButton = self.Enemys[destName]
			if enemyButton then
				enemyButton:UpdateDR(spellID, true, true)
				enemyButton:RelentlessCheck(spellID)
				enemyButton:DebuffChanged(srcName, spellID, true, true)
			end
		end
	elseif subevent == "SPELL_AURA_REMOVED" then
		if auraType == "DEBUFF" then
			local enemyButton = self.Enemys[destName]
			if enemyButton then
				enemyButton:UpdateDR(spellID, false, true)
				enemyButton:DebuffChanged(srcName, spellID, false, true)
			end
		end
	elseif subevent == "SPELL_CAST_SUCCESS" then
		local enemyButton = self.Enemys[srcName]
		if enemyButton then
			if Data.RacialSpellIDtoCooldown[spellID] then --racial used, maybe?
				--if not self.db.profile.Racial then return end
				local insi = enemyButton.Trinket
				local racial = enemyButton.Racial
				racial.Icon:SetTexture(Data.TriggerSpellIDToDisplayFileId[spellID])
				racial.Cooldown:SetCooldown(GetTime(), Data.RacialSpellIDtoCooldown[spellID])
																		-- relentless check						only set if shorter than 30 seconds
				if self.db.profile.Racial_Enabled and Data.RacialSpellIDtoCooldownTrigger[spellID] and not insi.HasTrinket == 4 and insi.Cooldown:GetCooldownDuration() < 30000 then
					insi.Cooldown:SetCooldown(GetTime(), Data.RacialSpellIDtoCooldownTrigger[spellID])
				end
			else
				enemyButton.Trinket:TrinketCheck(spellID, true)
			end
		end
	elseif subevent == "UNIT_DIED" then
		local enemyButton = self.Enemys[srcName]
		if enemyButton then
			enemyButton.ObjectiveAndRespawn:ShowRespawnTimer(27)
		end
	end
end


function BattleGroundEnemies:UNIT_TARGET(unitID)
	--print("unitID:", unitID, "unit:", UnitName(unitID), "unittarget:", UnitName(unitID.."target"))
	
	if self.AllyUnitIDToAllyDetails[unitID] and unitID ~= "player" then
		--print("target changed")
		self:UnitTargetCheck(unitID)
	end
end

function BattleGroundEnemies:PLAYER_TARGET_CHANGED()
	self:UnitTargetCheck("player", true)
end

do
	local oldFocus
	function BattleGroundEnemies:PLAYER_FOCUS_CHANGED()
		local enemyButton = self:GetEnemybuttonByUnitID("focus")
		if oldFocus then
			oldFocus.MyFocus:Hide()
		end
		if enemyButton then
			enemyButton.MyFocus:Show()
			oldFocus = enemyButton
			self:ScanUnit("focus", enemyButton)
		end
	end
end

function BattleGroundEnemies:UPDATE_MOUSEOVER_UNIT()
	self:ScanUnit("mouseover")
end

BattleGroundEnemies.UNIT_HEALTH_FREQUENT = BattleGroundEnemies.ScanUnit --gets health of nameplates, player, target, focus, raid1 to raid40, partymember
BattleGroundEnemies.NAME_PLATE_UNIT_ADDED = BattleGroundEnemies.ScanUnit


-- if lets say raid1 leaves all remaining players get shifted up, so raid2 is the new raid1, raid 3 gets raid2 etc.
function BattleGroundEnemies:GROUP_ROSTER_UPDATE()
	if not self then self = BattleGroundEnemies end -- for the C_Timer.After call
	wipe(self.AllyUnitIDToAllyDetails)
	local numGroupMembers = GetNumGroupMembers()
	if numGroupMembers > 0 then
		
		for i = 1, numGroupMembers do
			local unitID = "raid"..i --it happens that numGroupMembers is higher than the value of the maximal players for that battleground, for example 15 in a 10 man bg, thats why we wipe AllyUnitIDToAllyDetails
			local allyName, _, _, _, _, classTag = GetRaidRosterInfo(i)
			if allyName and classTag then
				local allyDetails = self.Allys[allyName]
				if allyDetails then --found, already existing
					allyDetails.status = 1 --found, already existing
				else--new 
					allyDetails = {classColor = RAID_CLASS_COLORS[classTag]}
					self.Allys[allyName] = allyDetails
				end
				
				if allyName == PlayerName then
					unitID = "player"
				end
				allyDetails.unitID = unitID --always update unitID
				self.AllyUnitIDToAllyDetails[unitID] = allyDetails
			else
				C_Timer.After(1, BattleGroundEnemies.GROUP_ROSTER_UPDATE) --recheck in 1 second
			end
		end
	end
	
	for allyName, allyDetails in pairs(self.Allys) do
		if allyDetails.status == 2 then --doesn't exist anymore
			local targetEnemyButton = allyDetails.target
			if targetEnemyButton then -- if that no longer exiting ally targeted something update the button of its target
				targetEnemyButton:UpdateTargetIndicators(allyDetails, nil)
			end
			self.Allys[allyName] = nil
		else
			allyDetails.status = 2
		end
	end
end

-- function BattleGroundEnemies:LOSS_OF_CONTROL_ADDED()
	-- local numEvents = C_LossOfControl.GetNumEvents()
	-- for i = 1, numEvents do
		-- local locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType = C_LossOfControl.GetEventInfo(i)
		-- --print(C_LossOfControl.GetEventInfo(i))
		-- if not self.LOSS_OF_CONTROL then self.LOSS_OF_CONTROL = {} end
		-- self.LOSS_OF_CONTROL[spellID] = locType
	-- end
-- end

function BattleGroundEnemies:GetEnemybuttonByUnitID(unitID)
	local uName, realm = UnitName(unitID)
	if realm then
		uName = uName.."-"..realm
	end
	return self.Enemys[uName]
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
		self:UnitTargetCheck(allyDetails.unitID)
	end	
end

function BattleGroundEnemies:PLAYER_ALIVE()
	if UnitIsGhost("player") then --Releases his ghost to a graveyard.
		self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
		self:UnregisterEvent("PLAYER_TARGET_CHANGED")
		self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
		self:UnregisterEvent("UNIT_TARGET")
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
		local Classes = {}
		for classId = 1, MAX_CLASSES do --example classes[EnglishClass][SpecName].
			local _, classTag = GetClassInfoByID(classId)
			
			do
				local roleNameToRoleNumber = {
					["DAMAGER"] = 3,
					["HEALER"] = 1,
					["TANK"] = 2
				}
				
				Classes[classTag] = {}
				for i = 1, GetNumSpecializationsForClassID(classId) do
					local id,specName,_,icon,role = GetSpecializationInfoForClassID(classId, i)
					if roleNameToRoleNumber[role] then
						Classes[classTag][specName] = {roleNumber = roleNameToRoleNumber[role], roleID = role}
					end
					Classes[classTag][specName].icon = icon
				end
			end
		end

		local function MyCreateFrame(frameType, parent, tablepoint1, tablepoint2, width)
			local frame = CreateFrame(frameType, nil, parent)
			frame:SetPoint(unpack(tablepoint1))
			frame:SetPoint(unpack(tablepoint2))
			if width then frame:SetWidth(width) end
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
				--print("Läüft")
				local battleGroundDebuffs = BattleGroundDebuffs
				for i = 1, #battleGroundDebuffs do
					local name, _, _, count, _, _, _, _, _, _, spellID, _, _, _, _, _, value2, value3, value4 = UnitDebuff(unitID, battleGroundDebuffs[i])
					--values for orb debuff:
					--print(value0, value1, value2, value3, value4, value5)
					-- value2 = Reduces healing received by value2
					-- value3 = Increases damage taken by value3
					-- value4 = Increases damage done by value4
					if value3 then
						if not self.Value then
							--print("hier")
							--player just got the debuff
							self.Icon:SetTexture(GetSpellTexture(spellID))
							self:Show()
							--print("Texture set")
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
					--print(value0, value1, value2, value3, value4, value5)
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
			
			function objectiveFrameFunctions:ArenaOpponentShown(unitID)
				if BattleGroundEnemies.db.profile.ObjectiveAndRespawn_ObjectiveEnabled then
					if BattlegroundBuff then
						--print("has buff")
						self.Icon:SetTexture(GetSpellTexture(BattlegroundBuff))
						self:Show()
					end
					self:RegisterUnitEvent("UNIT_AURA", unitID)
					self.AuraText:SetText("")
					self.Value = false
					BattleGroundEnemies.ArenaEnemyIDToEnemyButtonObjective[unitID] = self
				end
				RequestCrowdControlSpell(unitID)
			end
			
			function objectiveFrameFunctions:ShowRespawnTimer(duration)
				--print("ShowRespawnTimer")
				if IsRatedBG and BattleGroundEnemies.db.profile.ObjectiveAndRespawn_RespawnEnabled then
					--print("ShowRespawnTimer SetCooldown")
					if self.Cooldown:GetCooldownDuration() == 0 then
						self:Show()
						self.Icon:SetTexture(GetSpellTexture(8326))
						self.AuraText:SetText("")
						self.Cooldown:SetCooldown(GetTime(), duration)
						if not self.hasHideScript then 
							--print("script set")
							self.Cooldown:SetScript("OnHide", function() --don't set the script on frame creation, otherwise it happens when doing a reload while a flag carrier is shown that this script gets called after the buff should got shown.
								--print("ObjectiveAndRespawn.Cooldown hidden")
								self.Icon:SetTexture()
								self:Hide()
							end)
							self.hasHideScript = true
						end
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
			
			-- Shows/Hides targeting indicators for a button
			function enemyButtonFunctions:UpdateTargetIndicators(allyDetails, status, wipes)
				local targetedByAlly = self.PlayerDetails.TargetedByAlly
				if wipes then
					wipe(targetedByAlly)
				else
					targetedByAlly[allyDetails] = status
				end

				local i = 1
				for allyDetails in pairs(targetedByAlly) do
					if BattleGroundEnemies.db.profile.SymbolicTargetindicator_Enabled then
						local indicator = self.TargetIndicators[i]
						if not indicator then
							indicator = CreateFrame("frame",nil,self.Health)
							indicator:SetSize(8,10)
							indicator:SetPoint("TOP",floor(i/2)*(i%2==0 and -10 or 10), 0) --1: 0, 0 2: -10, 0 3: 10, 0 4: -20, 0 > i = even > left, uneven > right 
							indicator = SetBackdrop(indicator, nil, {0,0,0,1})
							self.TargetIndicators[i] = indicator
						end
						local classColor = allyDetails.classColor
						indicator:SetBackdropColor(classColor.r,classColor.g,classColor.b)
						indicator:Show()
					end
					i = i+1
				end
				if BattleGroundEnemies.db.profile.NumericTargetindicator_Enabled then 
					self.TargetCounter.Text:SetText(i-1)
				end
				while self.TargetIndicators[i] do --hide no longer used ones
					self.TargetIndicators[i]:Hide()
					i = i+1
				end
			end
			
			
			function enemyButtonFunctions:UpdateHealthRangeAndRespawn(unitID)
				local settings = BattleGroundEnemies.db.profile
				-- RespawnTimer
				if UnitIsDead(unitID) then
					--print("isdead")
					self.ObjectiveAndRespawn:ShowRespawnTimer(26)
				end
				
				if settings.RangeIndicator_Enabled then
					-- Range Check
					if IsItemInRange(settings.RangeIndicator_Range, unitID) then
						self:SetAlpha(1)
					else
						self:SetAlpha(settings.RangeIndicator_Alpha)
					end
				end
				
				--health update
				self.Health:SetValue(UnitHealth(unitID)/UnitHealthMax(unitID))
			end
		
			
			--Relentless maybe
			function enemyButtonFunctions:RelentlessCheck(spellID)
				if not BattleGroundEnemies.db.profile.Trinket_Enabled then return end
			
				local enemyDetails = self.PlayerDetails
				
				if self.Trinket.HasTrinket then
					return
				end
				
				if not enemyDetails.UnitID then
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
				
				local spellName = GetSpellInfo(spellID)
				local _, _, _, _, _, actualDuration = UnitDebuff(enemyDetails.UnitID, spellName)

				if not actualDuration then
					return 
				end
				local Racefaktor = 1
				if drCat == "stun" and enemyDetails.Race == "Orc" then
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
			
		
			function enemyButtonFunctions:DrPositioning()

				local anchor = self.DrContainerStartAnchor
				for categorie, drFrame in pairs(self.DR) do
					if drFrame:IsShown() then
						local spacing = BattleGroundEnemies.db.profile.DrTracking_Spacing
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
	
					local spacing = BattleGroundEnemies.db.profile.MyDebuffs_Spacing
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
					table.insert(enemyButton.InactiveDebuffs, debuffFrame)
				end
				
				function enemyButtonFunctions:DebuffChanged(srcName, _spellID, applied, removed)
					
					if not BattleGroundEnemies.db.profile.MyDebuffs_Enabled then return end
					local enemyButton = self
					local enemyUnitID = self.PlayerDetails.UnitID
					
					
					local myDebuffFrame = self.MyDebuffs[_spellID]
					if removed and myDebuffFrame then
						myDebuffFrame.Cooldown:Clear()
					end
					
					if not enemyUnitID or srcName ~= PlayerName then return end
					if applied then
						local spellID, duration, count, _
						if UAspellIDs[_spellID] then --more expensier way since we need to iterate through all debuffs
							for i = 1, 40 do
								_, _, _, count, _, duration, _, _, _, _, spellID, _, _, _, _, _, _, _, _ = UnitDebuff(enemyUnitID, i, "PLAYER")
								if spellID == _spellID then
									break
								end
							end
						else
							local spellName = GetSpellInfo(_spellID)
							_, _, _, count, _, duration, _, _, _, _, spellID, _, _, _, _, _, _, _, _ = UnitDebuff(enemyUnitID, spellName, nil, "PLAYER")
						end
						
						if duration and duration > 0 then
							local debuffFrame = self.InactiveDebuffs[#self.InactiveDebuffs] 
							if debuffFrame then --recycle a previous used Frame
								table.remove(self.InactiveDebuffs, #self.InactiveDebuffs)
								debuffFrame:Show()
							else -- create a new Frame 
							
								debuffFrame = CreateFrame('Frame', nil, self)
								debuffFrame:SetWidth(BattleGroundEnemies.db.profile.BarHeight)
								
								debuffFrame.Icon = debuffFrame:CreateTexture(nil, "BACKGROUND")
								debuffFrame.Icon:SetAllPoints()
								
								local conf = BattleGroundEnemies.db.profile
								debuffFrame.Stacks = CreateFontString(debuffFrame, true, nil, nil, "RIGHT", "BOTTOM", conf.MyDebuffs_Fontsize, conf.MyDebuffs_Outline, conf.MyDebuffs_Textcolor, conf.MyDebuffs_EnableTextshadow, conf.MyDebuffs_TextShadowcolor)
								
								debuffFrame.Cooldown = CreateCooldown(debuffFrame, BattleGroundEnemies.db.profile.MyDebuffs_ShowNumbers, true, false)
								debuffFrame.Cooldown:SetScript("OnHide", debuffFrameCooldown_OnHide)
							end
							
							
							debuffFrame.SpellID = _spellID
							debuffFrame.Icon:SetTexture(GetSpellTexture(_spellID))
							if count > 0 then
								debuffFrame.Stacks:SetText(count)
							end
							debuffFrame.Cooldown:SetCooldown(GetTime(), duration)
							
							self.MyDebuffs[_spellID] = debuffFrame
							self:DebuffPositioning()
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
				
				local function drFrameCooldown_OnHide(self)
					local drFrame = self:GetParent()
					drFrame:Hide()
					drFrame.status = 1
					drFrame:GetParent():DrPositioning() --enemyButton:DrPositioning()
				end
			
				function enemyButtonFunctions:UpdateDR(spellID, applied, removed)
					if not BattleGroundEnemies.db.profile.DrTracking_Enabled then return end
					
					local drCat = DRData:GetSpellCategory(spellID)
					--print(operation, spellID)
					if not drCat then return end

					--refreshed (for example a resheep) is basically removed + applied 
					local drFrame = self.DR[drCat]
					if not drFrame then  --create a new frame for this categorie
	
						drFrame = CreateFrame("Frame", nil, self)
						drFrame:SetWidth(BattleGroundEnemies.db.profile.BarHeight)
						
						drFrame = SetBackdrop(drFrame, {0,0,0,0}, nil)
			
						
						drFrame.Icon = drFrame:CreateTexture(nil, "BORDER", nil, -1) -- -1 to make it behind the SetBackdrop bg
						drFrame.Icon:SetAllPoints()
						
						drFrame.Cooldown = CreateCooldown(drFrame, BattleGroundEnemies.db.profile.DrTracking_ShowNumbers, false, false)
						
						drFrame.status = 1
						-- for _, region in next, {drFrame.Cooldown:GetRegions()} do
							-- if ( region:GetObjectType() == "FontString" ) then
								-- region:SetFont("Fonts\\FRIZQT__.TTF", , "OUTLINE")
							-- end
						-- end
						
						drFrame.Cooldown:SetScript("OnHide", drFrameCooldown_OnHide)
						
						self.DR[drCat] = drFrame
					end

					
					
					
					if removed then --removed
						if drFrame.status == 1 then -- we didn't get the applied, so we set the color and increase the dr state
							--print("DR Problem")
							drFrame:SetBackdropBorderColor(unpack(dRstates[drFrame.status]))
							drFrame.status = drFrame.status + 1
						end
						
						if not drFrame:IsShown() then
							drFrame:Show()
							self:DrPositioning() 
						end
						drFrame.Icon:SetTexture(GetSpellTexture(spellID))
						drFrame.Cooldown:SetCooldown(GetTime(), DRData:GetResetTime(drCat))
					end
					
					if applied and drFrame.status < 4 then --applied
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
		
		local function button_OnDragStop()
			BattleGroundEnemies:SavePosition()
		end
		
		function BattleGroundEnemies:CropImage(texture, height, width)
			local ratio = height / width
			local left, right, top, bottom = unpack({5, 59, 5, 59 })
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
			local button = CreateFrame('Button', nil, self, 'SecureActionButtonTemplate')
			-- setmetatable(button, self)
			-- self.__index = self
			
			for functionName, func in pairs(enemyButtonFunctions) do
				button[functionName] = func
			end
			local conf = self.db.profile
			
			button:SetHeight(conf.BarHeight)		
					
			-- events/scripts
			button:RegisterForClicks('AnyUp')
			button:RegisterForDrag('LeftButton')
			button:SetAttribute('type1','macro')
			button:SetAttribute('type2','macro')

			button:SetScript('OnDragStart', button_OnDragStart)
			button:SetScript('OnDragStop', button_OnDragStop)
			
			
			-- spec
			button.Spec = MyCreateFrame("Frame", button, {'TOPLEFT'}, {'BOTTOMLEFT'}, conf.Spec_Width)
			
			button.Spec.Icon = button.Spec:CreateTexture(nil, 'BACKGROUND')
			button.Spec.Icon:SetAllPoints()
			--button.Spec.Icon:SetTexCoord( 5/64, 59/64, 5/64, 59/64 ) 
		
			self:CropImage(button.Spec.Icon, conf.BarHeight, conf.Spec_Width)

			
			-- health
			button.Health = MyCreateFrame('StatusBar', button, {'TOPLEFT', button.Spec, "TOPRIGHT", 1, -1}, {'BOTTOMRIGHT', button, "BOTTOMRIGHT", -1, 1}, nil)
			button.Health:SetStatusBarTexture(LSM:Fetch("statusbar", conf.BarTexture))--enemyButton.Health:SetStatusBarTexture(137012)
			button.Health:SetMinMaxValues(0, 1)
			
			--button.Health.Background = button.Health:CreateTexture(nil, 'BACKGROUND', nil, 2)
			button.Health.Background = button.Health:CreateTexture(nil, 'BACKGROUND')
			button.Health.Background:SetAllPoints()
			button.Health.Background:SetTexture("Interface/Buttons/WHITE8X8")
			button.Health.Background:SetVertexColor(0,0,0,1)
			
			--MyTarget, indicating the current target of the player
			
			button.MyTarget = MyCreateFrame('Frame', button.Health, {"TOPLEFT", button.Health, "TOPLEFT", -1, 1}, {"BOTTOMRIGHT", button.Health, "BOTTOMRIGHT", 1, -1}, nil)
			button.MyTarget = SetBackdrop(button.MyTarget, {0, 0, 0, 0}, conf.MyTarget_Color)
			button.MyTarget:Hide()
			
			--MyFocus, indicating the current focus of the player
			button.MyFocus = MyCreateFrame('Frame', button.Health, {"TOPLEFT", button.Health, "TOPLEFT", -1, 1}, {"BOTTOMRIGHT", button.Health, "BOTTOMRIGHT", 1, -1}, nil)
			button.MyFocus = SetBackdrop(button.MyFocus, {0, 0, 0, 0}, conf.MyFocus_Color)
			button.MyFocus:Hide()
			
			-- numerical target indicator
			button.TargetCounter = MyCreateFrame("Frame", button, {'TOPRIGHT', -5, 0}, {'BOTTOMRIGHT', -5, 0}, 20)
			
			button.TargetCounter.Text = CreateFontString(button.TargetCounter, true, nil, nil, 'RIGHT', nil, conf.NumericTargetindicator_Fontsize, conf.NumericTargetindicator_Outline, conf.NumericTargetindicator_Textcolor, conf.NumericTargetindicator_EnableTextshadow, conf.NumericTargetindicator_TextShadowcolor)
			button.TargetCounter.Text:SetText(0)
			
			-- symbolic target indicator
			button.TargetIndicators = {}

			-- name
			button.Name = CreateFontString(button.Health, false, {'LEFT', 5, 0}, {'RIGHT', button.TargetCounter, "RIGHT", 0, 0}, 'LEFT', nil, conf.Name_Fontsize, conf.Name_Outline, conf.Name_Textcolor, conf.Name_EnableTextshadow, conf.Name_TextShadowcolor)
			
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
				--print("ObjectiveAndRespawn hidden")
				button.DrContainerStartAnchor = button.Spec
				button:DrPositioning()
			end)
			button.ObjectiveAndRespawn:SetScript("OnShow", function() 
				--print("ObjectiveAndRespawn shown")
				button.DrContainerStartAnchor = button.ObjectiveAndRespawn
				button:DrPositioning()
			end)
			button.ObjectiveAndRespawn:Hide()
			
			button.ObjectiveAndRespawn.ArenaOpponentShown = objectiveFrameFunctions.ArenaOpponentShown
			button.ObjectiveAndRespawn.ShowRespawnTimer =	objectiveFrameFunctions.ShowRespawnTimer
			
			button.ObjectiveAndRespawn.Icon = button.ObjectiveAndRespawn:CreateTexture(nil, "BORDER")
			button.ObjectiveAndRespawn.Icon:SetAllPoints()
			--button.ObjectiveAndRespawn.Icon:SetTexCoord( 4/64, 59/64, 12/64, 52/64 )
			
			self:CropImage(button.ObjectiveAndRespawn.Icon, conf.BarHeight, conf.ObjectiveAndRespawn_Width)

			button.ObjectiveAndRespawn.AuraText = CreateFontString(button.ObjectiveAndRespawn, true, nil, nil, "CENTER", nil, conf.ObjectiveAndRespawn_Fontsize, conf.ObjectiveAndRespawn_Outline, conf.ObjectiveAndRespawn_Textcolor, conf.ObjectiveAndRespawn_EnableTextshadow, conf.ObjectiveAndRespawn_TextShadowcolor)
			
			button.ObjectiveAndRespawn.Cooldown = CreateCooldown(button.ObjectiveAndRespawn, conf.ObjectiveAndRespawn_ShowNumbers, true, true, {0, 0, 0, 0.75})	
			---don't set the cooldown OnHide  script on frame creation, otherwise it happens when doing a reload while a flag carrier is shown that this script gets called after the buff should got shown.
		
			
			return button
		end
		
		
		
		local RoleIcons = {
			HEALER = "Interface\\AddOns\\BattleGroundEnemies\\Images\\Healer",
			TANK = "Interface\\AddOns\\BattleGroundEnemies\\Images\\Tank",
			DAMAGER = "Interface\\AddOns\\BattleGroundEnemies\\Images\\Damager",
		}
		
		
		local BlizzardsSortOrder = {} 
		for i = 1, #CLASS_SORT_ORDER do -- Constants.lua
			BlizzardsSortOrder[CLASS_SORT_ORDER[i]] = i --key = ENGLISH CLASS NAME, value = number
		end

		local function PlayerSortingByRoleClassName(a, b)-- a and b are playernames
			local detailsPlayerA = BattleGroundEnemies.Enemys[a].PlayerDetails
			local detailsPlayerB = BattleGroundEnemies.Enemys[b].PlayerDetails
			if detailsPlayerA.RoleNumber == detailsPlayerB.RoleNumber then
				if BlizzardsSortOrder[ detailsPlayerA.Class ] == BlizzardsSortOrder[ detailsPlayerB.Class ] then
					if a < b then return true end
				elseif BlizzardsSortOrder[ detailsPlayerA.Class ] < BlizzardsSortOrder[ detailsPlayerB.Class ] then return true end
			elseif detailsPlayerA.RoleNumber < detailsPlayerB.RoleNumber then return true end
		end
		do
			local usersParent = {}
			local usersPetParent = {}
			local fakeParent
			local fakeFrame = CreateFrame("frame")
		
			function BattleGroundEnemies:ToggleArenaFrames()
				if not self then self = BattleGroundEnemies end

				if not InCombatLockdown() then
					--print("self.db.profile.DisableArenaFrames", self.db.profile.DisableArenaFrames)
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
		
		local numArenaOpponents, EnemyFaction
		
		local function AreneEnemysAtBeginn()
			if #BattleGroundEnemies.EnemySortingTable > 1 then --this ensures that we checked for enmys and the flag carrier will be shown (if its an enemy)
				for i = 1,  numArenaOpponents do
					local unitID = "arena"..i
					--print(UnitName(unitID))
					local enemyButton = BattleGroundEnemies:GetEnemybuttonByUnitID(unitID)
					if enemyButton then
						--print("Button exists")
						enemyButton.ObjectiveAndRespawn:ArenaOpponentShown(unitID)
					end
				end
			else
				C_Timer.After(2, AreneEnemysAtBeginn)
			end
		end
						
		
		local oldNumEnemys
		BattleGroundEnemies.EnemySortingTable = {} --index = number, value = enemy name
		
		function BattleGroundEnemies:UPDATE_BATTLEFIELD_SCORE()

			--print(GetCurrentMapAreaID())
			-- print("UPDATE_BATTLEFIELD_SCORE")
			-- print("GetBattlefieldArenaFaction", GetBattlefieldArenaFaction())
			-- print("C_PvP.IsInBrawl", C_PvP.IsInBrawl())
			-- print("GetCurrentMapAreaID", GetCurrentMapAreaID())
			--print("horde players:", GetBattlefieldTeamInfo(0))
			--print("alliance players:", GetBattlefieldTeamInfo(1))
					
			

			if not CurrentMapID then
				local wmf = WorldMapFrame
				if wmf and not wmf:IsShown() then
					SetMapToCurrentZone()
					local mapID = GetCurrentMapAreaID()
					--print(mapID)
					if mapID == -1 or mapID == 0 then --if this values occur GetCurrentMapAreaID() doesn't return valid values yet.
						return
					end
					local numScores = GetNumBattlefieldScores()
					if not numScores or numScores < 5 then return end --otherwise we will get incorrent data from GetBattlefieldArenaFaction()
					CurrentMapID = mapID
				end
				
				
				
				--print("test")
				if not BrawlCheck or IsInBrawl() then
					self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
					self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
					self:RegisterEvent("PLAYER_TARGET_CHANGED")
					self:RegisterEvent("PLAYER_FOCUS_CHANGED")
					self:RegisterEvent("UNIT_TARGET")
					self:RegisterEvent("UNIT_HEALTH_FREQUENT")
					self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
					self:RegisterEvent("ARENA_OPPONENT_UPDATE")
					self:RegisterEvent("ARENA_CROWD_CONTROL_SPELL_UPDATE")
					self:RegisterEvent("ARENA_COOLDOWNS_UPDATE")
					self:RegisterEvent("GROUP_ROSTER_UPDATE")
					-- self:RegisterEvent("LOSS_OF_CONTROL_ADDED")
					self:RegisterEvent("PLAYER_ALIVE")
					self:RegisterEvent("PLAYER_UNGHOST")
				else
					OnUpdateFrame:Hide() --stopp the OnUpdateScript
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
				--print(numArenaOpponents)
				if numArenaOpponents > 0 then 
					C_Timer.After(2, AreneEnemysAtBeginn)
				end
				
				self:ToggleArenaFrames()
				
				oldNumEnemys = 0
				IsRatedBG = IsRatedBattleground()
				--print("IsRatedBG", IsRatedBG)
				self:GROUP_ROSTER_UPDATE()
			end
			
			
			local _, _, _, _, numEnemys = GetBattlefieldTeamInfo(EnemyFaction)
			
			if numEnemys ~= oldNumEnemys then
				if IsRatedBG then
					if numEnemys < oldNumEnemys then
						RaidNotice_AddMessage(RaidWarningFrame, "An enemy left the battleground", ChatTypeInfo["RAID_WARNING"]) 
						PlaySound("LEVELUPSOUND")
					else -- numEnemys > oldNumEnemys
						RaidNotice_AddMessage(RaidWarningFrame, "An enemy joined the battleground", ChatTypeInfo["RAID_WARNING"]) 
						PlaySound("RaidWarning")
					end
				end
				if self.db.profile.EnemyCount_Enabled then
					if EnemyFaction == 0 then -- enemy is Horde
						self.EnemyCount:SetText(format(PLAYER_COUNT_HORDE, numEnemys))
					else --enemy is Alliance
						self.EnemyCount:SetText(format(PLAYER_COUNT_ALLIANCE, numEnemys))
					end
				end

				oldNumEnemys = numEnemys
			end
			
			
			if InCombatLockdown() then return end
			
			
			if numEnemys and numEnemys <= self.db.profile.MaxPlayers and numEnemys > 0 then
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
					local enemyButton = self.Enemys[name]
					if enemyButton then	--already existing
						enemyButton.PlayerDetails.Status = 1 --1 means found, already existing
						if enemyButton.PlayerDetails.Spec ~= spec then--its possible to change spec in battleground
							enemyButton.PlayerDetails.Spec = spec
							enemyButton.Spec.Icon:SetTexture(Classes[classTag][spec].icon)
							enemyButton.PlayerDetails.RoleNumber = Classes[classTag][spec].roleNumber
							enemyButton.PlayerDetails.RoleID = Classes[classTag][spec].roleID
							enemyButton.PlayerDetails.SpecIcon = Classes[classTag][spec].icon
							
							resort = true
						end
					else
						newPlayerDetails[name] = { -- details of this new player
							Race = LibRaces:GetRaceToken(race), --delifers are local independent token for relentless check
							Class = classTag,
							Spec = spec,
							TargetedByAlly = {},
							RoleNumber = Classes[classTag][spec].roleNumber,
							RoleID = Classes[classTag][spec].roleID,
							SpecIcon = Classes[classTag][spec].icon,
							Status = 2
						}
						
						resort = true
					end
				end
			end
			-- for name, enemyButton in pairs(self.Enemys) do
				-- if enemyButton.PlayerDetails.Status == 2 then --no longer existing
					-- print("Delitation")
					-- print(name, enemyButton.Position, "gets removed")
					-- print(self.EnemySortingTable[enemyButton.Position])
					-- table.remove(self.EnemySortingTable, enemyButton.Position)
					-- enemyButton:Hide()
					
					-- table.insert(self.InactiveEnemyButtons, enemyButton)
					-- self.Enemys[name] = nil
					
					-- resort = true
				-- end 
			-- end
			
			--Rückwärts um keine Probleme mit table.remove zu bekommen, wenn man mehr als einen Spieler in einem Schleifendurchlauf entfernt,
			-- da ansonsten die enemyButton.Position nicht mehr passen (sie sind zu hoch)
			for i = #self.EnemySortingTable, 1, -1 do
				local name = self.EnemySortingTable[i]
				local enemyButton = self.Enemys[name]
				if enemyButton.PlayerDetails.Status == 2 then --no longer existing
					table.remove(self.EnemySortingTable, enemyButton.Position)
					enemyButton:Hide()
					
					table.insert(self.InactiveEnemyButtons, enemyButton)
					self.Enemys[name] = nil
					
					resort = true
				else -- == 1 -- set to 2 for the next comparison
					enemyButton.PlayerDetails.Status = 2
				end 
			end
			for name, enemyDetails in pairs(newPlayerDetails) do
				local enemyButton = self.InactiveEnemyButtons[#self.InactiveEnemyButtons] 
				
				if enemyButton then --recycle a previous used button
					table.remove(self.InactiveEnemyButtons, #self.InactiveEnemyButtons)
					--Cleanup previous shown stuff of another player
					enemyButton.Trinket.HasTrinket = nil
					enemyButton.Trinket.Icon:SetTexture(nil)
					enemyButton.Trinket.Cooldown:Clear()	--reset Trinket Cooldown
					enemyButton.Racial.Icon:SetTexture(nil)
					enemyButton.Racial.Cooldown:Clear()	--reset Racial Cooldown
					enemyButton.MyTarget:Hide()	--reset possible shown target indicator frame
					enemyButton.MyFocus:Hide()	--reset possible shown target indicator frame
					enemyButton:UpdateTargetIndicators(nil, nil, true) --update numerical and symbolic target indicator
					enemyButton.ObjectiveAndRespawn:Hide()
					
					for categorie, drFrame in pairs(enemyButton.DR) do --set status of DR-Tracker to 1
						drFrame.status = 1
					end
				else --no recycleable buttons remaining => create a new one
					enemyButton = self:CreateNewPlayerButton()
				end
				
				--print(name, "is new")
				
				enemyButton:SetAttribute('macrotext1',
					'/cleartarget\n'..
					'/targetexact '..name
				)

				enemyButton:SetAttribute('macrotext2',
					'/targetexact '..name..'\n'..
					'/focus\n'..
					'/targetlasttarget'
				)
				
				enemyButton.Spec.Icon:SetTexture(enemyDetails.SpecIcon)		
				--enemyButton.Role.Icon:SetTexCoord(GetTexCoordsForRole(enemyDetails.RoleID))		
				-- enemyButton.Role.Icon:SetTexture(RoleIcons[enemyDetails.RoleID])	
				-- enemyButton.Role:Show()

				local c = RAID_CLASS_COLORS[enemyDetails.Class]
				enemyButton.Health:SetStatusBarColor(c.r,c.g,c.b)
				enemyButton.Health:SetValue(1)
				
				enemyDetails.DisplayedName = name
				if self.db.profile.ConvertCyrillic then
					enemyDetails.DisplayedName = ""
					for i = 1, name:utf8len() do
						local c = name:utf8sub(i,i)
						if Data.CyrillicToRomanian[c] then
							if i == 1 then
								enemyDetails.DisplayedName = enemyDetails.DisplayedName..Data.CyrillicToRomanian[c]:upper()
							else
								enemyDetails.DisplayedName = enemyDetails.DisplayedName..Data.CyrillicToRomanian[c]
							end
						else
							enemyDetails.DisplayedName = enemyDetails.DisplayedName..c
						end
					end
				end
				
				if self.db.profile.ShowRealmnames then
					enemyButton.Name:SetText(enemyDetails.DisplayedName)
				else
					enemyButton.Name:SetText(enemyDetails.DisplayedName:match("[^%-]*"))
				end
				
				
				table.insert(self.EnemySortingTable, name)
				
				
				if BattleGroundDebuffs then
					if CurrentMapID == 856 then --8456 is kotmogu
						enemyButton.ObjectiveAndRespawn:SetScript('OnEvent', objectiveFrameFunctions.Kotmoguorbs)
					else
						enemyButton.ObjectiveAndRespawn:SetScript('OnEvent', objectiveFrameFunctions.NotKotmogu)
					end
				end
				
				enemyButton:Show()
				enemyButton.PlayerDetails = enemyDetails
								
				self.Enemys[name] = enemyButton
				
			end

			if resort then
				table.sort(self.EnemySortingTable, PlayerSortingByRoleClassName)
				
				local previousButton = self
				for number, name in ipairs(self.EnemySortingTable) do
					local enemyButton = self.Enemys[name]
					enemyButton.Position = number
					enemyButton:SetPosition(self.db.profile.Growdirection, previousButton, self.db.profile.SpaceBetweenRows)
					previousButton = enemyButton
				end
			end
			
		end--functions end
	end-- do-end block end for locals of the function UPDATE_BATTLEFIELD_SCORE
	
	function BattleGroundEnemies:PLAYER_ENTERING_WORLD()
		local _, zone = IsInInstance()
		if zone == "pvp" or zone == "arena" then
			if zone == "arena" then
				BrawlCheck = true
			end
			CurrentMapID = false
			-- print("PLAYER_ENTERING_WORLD")
			-- print("GetBattlefieldArenaFaction", GetBattlefieldArenaFaction())
			-- print("C_PvP.IsInBrawl", C_PvP.IsInBrawl())
			-- print("GetCurrentMapAreaID", GetCurrentMapAreaID())

			
			
			-- wipe(self.EnemySortingTable)
			for name, enemyButton in pairs(self.Enemys) do
				-- table.insert(self.InactiveEnemyButtons, enemyButton) --to make them usable again
				enemyButton:Hide()
				-- self.Enemys[name] = nil
			end
			OnUpdateFrame:Show()
			self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
		else
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
			self:UnregisterEvent("PLAYER_TARGET_CHANGED")
			self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
			self:UnregisterEvent("UNIT_TARGET")
			self:UnregisterEvent("UNIT_HEALTH_FREQUENT")
			self:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE")
			self:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
			self:UnregisterEvent("ARENA_OPPONENT_UPDATE")--fires when a arena enemy appears and a frame is ready to be shown
			self:UnregisterEvent("ARENA_CROWD_CONTROL_SPELL_UPDATE") --fires when data requested by C_PvP.RequestCrowdControlSpell(unitID) is available
			self:UnregisterEvent("ARENA_COOLDOWNS_UPDATE") --fires when a arenaX enemy used a trinket or racial to break cc, C_PvP.GetArenaCrowdControlInfo(unitID) shoudl be called afterwards to get used CCs
			self:UnregisterEvent("GROUP_ROSTER_UPDATE")
			-- self:UnregisterEvent("LOSS_OF_CONTROL_ADDED")
			self:UnregisterEvent("PLAYER_ALIVE")
			self:UnregisterEvent("PLAYER_UNGHOST")
			
			self:ToggleArenaFrames()
			BrawlCheck = false
			OnUpdateFrame:Hide()
			self:Hide()
		end
	end
end


BattleGroundEnemies:RegisterEvent("PLAYER_LOGIN")
BattleGroundEnemies:RegisterEvent("PLAYER_ENTERING_WORLD")
BattleGroundEnemies:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
