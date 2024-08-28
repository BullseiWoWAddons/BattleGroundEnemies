---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)
---@class BattleGroundEnemies
local BattleGroundEnemies = BattleGroundEnemies

local L = Data.L

local defaultSettings = {
	Enabled = true,
	Parent = "healthBar",
	ActivePoints = 2,
	Points = {
		{
			Point = "TOPRIGHT",
			RelativeFrame = "healthBar",
			RelativePoint = "TOPRIGHT",
			OffsetX = -5,
			OffsetY = 0
		},
		{
			Point = "BOTTOMRIGHT",
			RelativeFrame = "healthBar",
			RelativePoint = "BOTTOMRIGHT",
			OffsetX = -5,
			OffsetY = 0
		},
	},
	Text = {
		FontSize = 13,
		FontOutline = "",
		FontColor = {1, 1, 1, 1},
		EnableShadow = true,
		ShadowColor = {0, 0, 0, 1},
		JustifyH = "RIGHT",
		JustifyV = "MIDDLE"
	}
}

local options = function(location, playerType)
	return {
		TextSettings = {
			type = "group",
			name = L.TextSettings,
			inline = true,
			order = 4,
			get = function(option)
				return Data.GetOption(location.Text, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.Text, option, ...)
			end,
			args = Data.AddNormalTextSettings(location.Text)
		}
	}
end

local targetIndicatorNumeric = BattleGroundEnemies:NewButtonModule({
	moduleName = "TargetIndicatorNumeric",
	localizedModuleName = L.TargetIndicatorNumeric,
	defaultSettings = defaultSettings,
	options = options,
	events = {"UpdateTargetIndicators"},
	enabledInThisExpansion = true
})

function targetIndicatorNumeric:AttachToPlayerButton(playerButton)
	playerButton.TargetIndicatorNumeric = BattleGroundEnemies.MyCreateFontString(playerButton)

	function playerButton.TargetIndicatorNumeric:UpdateTargetIndicators()
		local i = 0
		for enemyButton in pairs(playerButton.UnitIDs.TargetedByEnemy) do
			i = i + 1
		end

		local enemyTargets = i

		
		self:SetText(enemyTargets)
	end

	playerButton.TargetIndicatorNumeric.ApplyAllSettings = function(self)
		self:ApplyFontStringSettings(self.config.Text)
		self:SetText(0)
	end

	playerButton.TargetIndicatorNumeric.Reset = function(self)
		--dont SetWidth before Hide() otherwise it won't work as aimed
		if not self:GetFont() then return end
		self:SetText(0) --we do that because the level is anchored right to this and the name is anhored right to the level
	end
end



local defaultSettings = {
	Enabled = true,
	Parent = "healthBar",
	IconWidth = 8,
	IconHeight = 10,
	IconSpacing = 10,
	ActivePoints = 2,
	Points = {
		{
			Point = "TOPLEFT",
			RelativeFrame = "healthBar",
			RelativePoint = "TOPLEFT",
			OffsetX = 0
		},
		{
			Point = "BOTTOMRIGHT",
			RelativeFrame = "healthBar",
			RelativePoint = "BOTTOMRIGHT",
			OffsetX = 0
		}
	},

}

local options = function(location, playerType)
	return {
		IconWidth = {
			type = "range",
			name = L.Width,
			min = 1,
			max = 20,
			step = 1,
			width = "normal",
			order = 1
		},
		IconHeight = {
			type = "range",
			name = L.Height,
			min = 1,
			max = 20,
			step = 1,
			width = "normal",
			order = 2,
		},
		IconSpacing = {
			type = "range",
			name = L.HorizontalSpacing,
			min = 1,
			max = 20,
			step = 1,
			width = "normal",
			order = 3,
		}
	}
end

local symbolicTargetIndicator = BattleGroundEnemies:NewButtonModule({
	moduleName = "TargetIndicatorSymbolic",
	localizedModuleName = L.TargetIndicatorSymbolic,
	defaultSettings = defaultSettings,
	options = options,
	events = {"UpdateTargetIndicators"},
	enabledInThisExpansion = true
})

function symbolicTargetIndicator:AttachToPlayerButton(playerButton)
	playerButton.TargetIndicatorSymbolic = CreateFrame("frame", nil, playerButton)
	playerButton.TargetIndicatorSymbolic.Symbols = {}


	playerButton.TargetIndicatorSymbolic.SetSizeAndPosition = function(self, index)
		local config = self.config
		local symbol = self.Symbols[index]
		if not symbol then return end
		if not (config.IconWidth and config.IconHeight) then return end
		symbol:SetSize(config.IconWidth, config.IconHeight)
		symbol:SetPoint("TOP",floor(index/2)*(index%2==0 and -config.IconSpacing or config.IconSpacing), 0) --1: 0, 0 2: -10, 0 3: 10, 0 4: -20, 0 > i = even > left, uneven > right
	end

	function playerButton.TargetIndicatorSymbolic:UpdateTargetIndicators()
		local i = 1
		for enemyButton in pairs(playerButton.UnitIDs.TargetedByEnemy) do
			local indicator = self.Symbols[i]
			if not indicator then
				indicator = CreateFrame("frame", nil, playerButton.TargetIndicatorSymbolic, BackdropTemplateMixin and "BackdropTemplate")
				indicator:SetBackdrop({
					bgFile = "Interface/Buttons/WHITE8X8", --drawlayer "BACKGROUND"
					edgeFile = 'Interface/Buttons/WHITE8X8', --drawlayer "BORDER"
					edgeSize = 1
				})
				indicator:SetBackdropBorderColor(0,0,0,1)
				self.Symbols[i] = indicator

				self:SetSizeAndPosition(i)
			end
			local classColor = enemyButton.PlayerDetails.PlayerClassColor
			indicator:SetBackdropColor(classColor.r,classColor.g,classColor.b)
			indicator:Show()

			i = i + 1
		end

		while self.Symbols[i] do --hide no longer used ones
			self.Symbols[i]:Hide()
			i = i + 1
		end
	end



	playerButton.TargetIndicatorSymbolic.ApplyAllSettings = function(self)
		for i = 1, #self.Symbols do
			self:SetSizeAndPosition(i)
		end
	end
end


local GameTooltip = GameTooltip


local specDefaults = {
	Enabled = true,
	Parent = "Button",
	ActivePoints = 2,
	Points = {
		{
			Point = "TOPLEFT",
			RelativeFrame = "Class",
			RelativePoint = "TOPLEFT",
		},
		{
			Point = "BOTTOMRIGHT",
			RelativeFrame = "Class",
			RelativePoint = "BOTTOMRIGHT",
		}
	}
}

local classDefaults = {
	Enabled = true,
	Width = 36,
	Parent = "Button",
	ActivePoints = 2,
	Points = {
		{
			Point = "TOPRIGHT",
			RelativeFrame = "Button",
			RelativePoint = "TOPLEFT",
		},
		{
			Point = "BOTTOMRIGHT",
			RelativeFrame = "Button",
			RelativePoint = "BOTTOMLEFT",
		}
	}
}

local events = {"PlayerDetailsChanged"}

local class = BattleGroundEnemies:NewButtonModule({
	moduleName = "Class",
	localizedModuleName = CLASS,
	defaultSettings = classDefaults,
	options = nil,
	events = events,
	enabledInThisExpansion = true
})
local spec = BattleGroundEnemies:NewButtonModule({
	moduleName = "Spec",
	localizedModuleName = SPECIALIZATION,
	defaultSettings = specDefaults,
	options = nil,
	events = events,
	enabledInThisExpansion = not not GetSpecializationInfoByID
})




local function attachToPlayerButton(playerButton, type)
	local frame = CreateFrame("Frame", nil, playerButton)
	frame.type = type
	if type == "Spec" then
		if playerButton.Class and playerButton.Class.GetFrameLevel then
			frame:SetFrameLevel(playerButton.Class:GetFrameLevel() + 1) -- to always make sure the level is above the spec in case they are stacked ontop of each other
		end
	end

	frame:SetScript("OnSizeChanged", function(self, width, height)
		self:CropImage()
	end)

	function frame:CropImage()
		local playerDetails = playerButton.PlayerDetails
		if not playerDetails then return end
		if playerDetails.PlayerSpecName and self.type == "Spec" then
			local width = self:GetWidth()
			local height = self:GetHeight()
			if width and height and width > 0 and height > 0 then
				BattleGroundEnemies.CropImage(self.Icon, width, height)
			end
		end
	end

	frame:HookScript("OnEnter", function(self)
		BattleGroundEnemies:ShowTooltip(self, function()
			local playerDetails = playerButton.PlayerDetails
			if self.type == "Class" then
				if not playerDetails.PlayerClass then return end
				local numClasses = GetNumClasses()
				for i = 1, numClasses do -- we could also just save the localized class name it into the button itself, but since its only used for this tooltip no need for that
					local className, classFile, classID = GetClassInfo(i)
					if classFile and classFile == playerDetails.PlayerClass then
						return GameTooltip:SetText(className)
					end
				end
			else --"Spec"
				if not playerDetails.PlayerSpecName then return end
				GameTooltip:SetText(playerDetails.PlayerSpecName)
			end
		end)
	end)

	frame:HookScript("OnLeave", function(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end)

	frame.Background = frame:CreateTexture(nil, 'BACKGROUND')
	frame.Background:SetAllPoints()
	frame.Background:SetColorTexture(0,0,0,0.8)

	frame.Icon = frame:CreateTexture(nil, 'OVERLAY')
	frame.Icon:SetAllPoints()

	frame.PlayerDetailsChanged = function(self)
		local playerDetails = playerButton.PlayerDetails
		if not playerDetails then return end
		if self.type == "Class" then
			--either no spec or the player wants to always see it > display it
			local coords = CLASS_ICON_TCOORDS[playerDetails.PlayerClass]
			if playerDetails.PlayerClass and coords then
				self.Icon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
				self.Icon:SetTexCoord(unpack(coords))
			else
				self.Icon:SetTexture(nil)
			end	
		else -- "Spec"
			local specData = playerButton:GetSpecData()
			if specData then
				self.Icon:SetTexture(specData.specIcon)
			else
				self.Icon:SetTexture(nil)
			end
		end

		self:CropImage()
	end


	frame.ApplyAllSettings = function(self)
		self:Show()
		self:PlayerDetailsChanged()
	end
	return frame
end

function class:AttachToPlayerButton(playerButton)
	playerButton.Class = attachToPlayerButton(playerButton, "Class")
end

function spec:AttachToPlayerButton(playerButton)
	playerButton.Spec = attachToPlayerButton(playerButton, "Spec")
end

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

local defaultSettings = {
	Enabled = true,
	Parent = "healthBar",
	Width = 12,
	Height = 12,
	ActivePoints = 1,
	Points = {
		{
			Point = "TOPLEFT",
			RelativeFrame = "healthBar",
			RelativePoint = "TOPLEFT",
			OffsetX = 2,
			OffsetY = -2,
		},
	},
}

local role = BattleGroundEnemies:NewButtonModule({
	moduleName = "Role",
	localizedModuleName = ROLE,
	defaultSettings = defaultSettings,
	options = nil,
	events = {"PlayerDetailsChanged"},
	enabledInThisExpansion = not not GetSpecializationRole
})

function role:AttachToPlayerButton(playerButton)
	playerButton.Role = CreateFrame("Frame", nil, playerButton)
	playerButton.Role.Icon = playerButton.Role:CreateTexture(nil, 'OVERLAY')
	playerButton.Role.Icon:SetAllPoints()

	playerButton.Role.ApplyAllSettings = function(self)
		self:PlayerDetailsChanged()
	end

	playerButton.Role.PlayerDetailsChanged = function(self)
		local playerDetails = playerButton.PlayerDetails
		if not playerDetails then return end
		local specData = playerButton:GetSpecData()
		if specData then
			if specData.roleID then
				self.Icon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
				self.Icon:SetTexCoord(GetTexCoordsForRoleSmallCircle(specData.roleID))
			end
		end
	end
end



local BackdropTemplateMixin = BackdropTemplateMixin
local CreateFrame = CreateFrame
local GetRaidTargetIndex = GetRaidTargetIndex
local SetRaidTargetIconTexture = SetRaidTargetIconTexture
local L = Data.L


local defaultSettings = {
	Enabled = true,
	Parent = "healthBar",
	Width = 30,
	ActivePoints = 2,
	Points = {
		{
			Point = "TOP",
			RelativeFrame = "healthBar",
			RelativePoint = "TOP"
		},
		{
			Point = "BOTTOM",
			RelativeFrame = "healthBar",
			RelativePoint = "BOTTOM"
		}
	}
}


local raidTargetIcon = BattleGroundEnemies:NewButtonModule({
	moduleName = "RaidTargetIcon",
	localizedModuleName = TARGETICONS,
	defaultSettings = defaultSettings,
	options = nil,
	events = {"UpdateRaidTargetIcon", "PlayerButtonSizeChanged"},
	enabledInThisExpansion = true
})

function raidTargetIcon:AttachToPlayerButton(playerButton)
	playerButton.RaidTargetIcon = CreateFrame('Frame', nil, playerButton, BackdropTemplateMixin and "BackdropTemplate")
	playerButton.RaidTargetIcon.Icon = playerButton.RaidTargetIcon:CreateTexture(nil, "OVERLAY")
	playerButton.RaidTargetIcon.Icon:SetTexture("Interface/TargetingFrame/UI-RaidTargetingIcons")
	playerButton.RaidTargetIcon.Icon:SetAllPoints()


	function playerButton.RaidTargetIcon:UpdateRaidTargetIcon(raidTargetIconIndex)
		if raidTargetIconIndex then
			SetRaidTargetIconTexture(self.Icon, raidTargetIconIndex)
			self.Icon:Show()
		else
			self.Icon:Hide()
		end
	end

	function playerButton.RaidTargetIcon:PlayerButtonSizeChanged(width, height)
		self:SetWidth(height)
	end

	function playerButton.RaidTargetIcon:ApplyAllSettings()
		self:UpdateRaidTargetIcon()
	end
end


local LSM = LibStub("LibSharedMedia-3.0")

local PowerBarColor = PowerBarColor --table
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local math_random = math.random


local defaultSettings = {
	Enabled = true,
	Parent = "Button",
	Height = 5,
	Texture = 'Blizzard Raid Bar',
	Background = {0, 0, 0, 0.66},
	ActivePoints = 2,
	Points = {
		{
			Point = "BOTTOMLEFT",
			RelativeFrame = "Spec",
			RelativePoint = "BOTTOMRIGHT",
		},
		{
			Point = "BOTTOMRIGHT",
			RelativeFrame = "Button",
			RelativePoint = "BOTTOMRIGHT",
		}
	}
}

local options = function(location)
	return {
		Texture = {
			type = "select",
			name = L.BarTexture,
			desc = L.PowerBar_Texture_Desc,
			dialogControl = 'LSM30_Statusbar',
			values = AceGUIWidgetLSMlists.statusbar,
			width = "normal",
			order = 3
		},
		Fake = Data.AddHorizontalSpacing(4),
		Background = {
			type = "color",
			name = L.BarBackground,
			desc = L.PowerBar_Background_Desc,
			hasAlpha = true,
			width = "normal",
			order = 5
		}
	}
end

local flags = {
	SetZeroHeightWhenDisabled = true
}

local power = BattleGroundEnemies:NewButtonModule({
	moduleName = "Power",
	localizedModuleName = L.PowerBar,
	flags = flags,
	defaultSettings = defaultSettings,
	options = options,
	events = {"UnitIdUpdate", "UpdatePower", "PlayerDetailsChanged"},
	enabledInThisExpansion = true
})

function power:AttachToPlayerButton(playerButton)
	playerButton.Power = CreateFrame('StatusBar', nil, playerButton)
	playerButton.Power:SetMinMaxValues(0, 1)
	playerButton.Power.maxValue = 1


	--playerButton.Power.Background = playerButton.Power:CreateTexture(nil, 'BACKGROUND', nil, 2)
	playerButton.Power.Background = playerButton.Power:CreateTexture(nil, 'BACKGROUND', nil, 2)
	playerButton.Power.Background:SetAllPoints()
	playerButton.Power.Background:SetTexture("Interface/Buttons/WHITE8X8")


	function playerButton.Power:UpdateMinMaxValues(max)
		if max and max ~= self.maxValue then
			self:SetMinMaxValues(0, max)
			self.maxValue = max
		end
	end

	function playerButton.Power:CheckForNewPowerColor(powerToken)
		--BattleGroundEnemies:LogToSavedVariables("CheckForNewPowerColor", powerToken)

		if self.powerToken ~= powerToken then
			local color = PowerBarColor[powerToken]
			if color then
				self:SetStatusBarColor(color.r, color.g, color.b)
				self.powerToken = powerToken
			end
		end
	end

	function playerButton.Power:UnitIdUpdate(unitID)
		if unitID then
			local powerType, powerToken, altR, altG, altB = UnitPowerType(unitID)
		
			self:CheckForNewPowerColor(powerToken)
			self:UpdatePower(unitID)
		end
	end

	function playerButton.Power:PlayerDetailsChanged()
		local playerDetails = playerButton.PlayerDetails
		if not playerDetails then return end
		if not playerDetails.PlayerClass then return end
		
		local powerToken
		if playerDetails.PlayerClass then
			local t = Data.Classes[playerDetails.PlayerClass]
			if t then
				if playerDetails.PlayerSpecName then
					t = t[playerDetails.PlayerSpecName]
				end
			end
			if t then powerToken = t.Ressource end
		end
		
		self:CheckForNewPowerColor(powerToken)
	end
	
	
	function playerButton.Power:UpdatePower(unitID)
		--BattleGroundEnemies:LogToSavedVariables("UpdatePower", unitID, powerToken)
		if unitID then
			self:UpdateMinMaxValues(UnitPowerMax(unitID))
			self:SetValue(UnitPower(unitID))
		else
			--for testmode
			self:SetValue(math_random(0, 100)/100)
		end
	end


	function playerButton.Power:ApplyAllSettings()
		-- power
		self:SetHeight(self.config.Height or 0.01)
		self:SetStatusBarTexture(LSM:Fetch("statusbar", self.config.Texture))--self.healthBar:SetStatusBarTexture(137012)
		self.Background:SetVertexColor(unpack(self.config.Background))
		self:PlayerDetailsChanged()
	end
end



local defaultSettings = {
	Enabled = true,
	Parent = "healthBar",
	ActivePoints = 2,
	Points = {
		{
			Point = "TOPLEFT",
			RelativeFrame = "Level",
			RelativePoint = "TOPRIGHT",
			OffsetX = 5,
			OffsetY = -2
		},
		{
			Point = "BOTTOMRIGHT",
			RelativeFrame = "TargetIndicatorNumeric",
			RelativePoint = "BOTTOMLEFT",
		}
	},
	Text = {
		FontSize = 13,
		FontOutline = "",
		FontColor = {1, 1, 1, 1},
		EnableShadow = true,
		ShadowColor = {0, 0, 0, 1},
		JustifyH = "LEFT",
		JustifyV = "MIDDLE",
		WordWrap = false
	},
	ShowRealmnames = true
}

local options = function(location)
	return {
		ShowRealmnames = {
			type = "toggle",
			name = L.ShowRealmnames,
			desc = L.ShowRealmnames_Desc,
			width = "normal",
			order = 2
		},
		TextSettings = {
			type = "group",
			name = L.TextSettings,
			inline = true,
			order = 4,
			get = function(option)
				return Data.GetOption(location.Text, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.Text, option, ...)
			end,
			args = Data.AddNormalTextSettings(location.Text)
		}
	}
end

local name = BattleGroundEnemies:NewButtonModule({
	moduleName = "Name",
	localizedModuleName = L.Name,
	defaultSettings = defaultSettings,
	options = options,
	events = {"PlayerDetailsChanged"},
	enabledInThisExpansion = true
})


function name:AttachToPlayerButton(playerButton)
	playerButton.Name = BattleGroundEnemies.MyCreateFontString(playerButton)

	function playerButton.Name:SetName()
		if not playerButton.PlayerDetails then return end
		local playerName = playerButton.PlayerDetails.PlayerName
		if not playerName then return end

		local name, realm = strsplit( "-", playerName, 2)

		if BattleGroundEnemies.db.profile.ConvertCyrillic then
			playerName = ""
			for i = 1, name:utf8len() do
				local c = name:utf8sub(i,i)

				if Data.CyrillicToRomanian[c] then
					playerName = playerName..Data.CyrillicToRomanian[c]
					if i == 1 then
						playerName = playerName:gsub("^.",string.upper) --uppercase the first character
					end
				else
					playerName = playerName..c
				end
			end
			--self.DisplayedName = self.DisplayedName:gsub("-.",string.upper) --uppercase the realm name
			name = playerName
			if realm then
				playerName = playerName.."-"..realm
			end
		end

		if self.config.ShowRealmnames then
			name = playerName
		end

		self:SetText(name)
		self.DisplayedName = name
	end

	function playerButton.Name:PlayerDetailsChanged()
		self:SetName()
	end

	function playerButton.Name:ApplyAllSettings()
		local config = self.config
		-- name
		self:ApplyFontStringSettings(config.Text)
		self:SetName()
	end
end

local MaxLevel = GetMaxPlayerLevel()


local defaultSettings = {
	Enabled = false,
	Parent = "healthBar",
	UseButtonHeightAsHeight = true,
	ActivePoints = 1,
	Points = {
		{
			Point = "TOPLEFT",
			RelativeFrame = "Covenant",
			RelativePoint = "TOPRIGHT",
			OffsetX = 2,
			OffsetY = 2
		}
	},
	OnlyShowIfNotMaxLevel = true,
	Text = {
		FontSize = 18,
		FontOutline = "",
		FontColor = {1, 1, 1, 1},
		EnableShadow = false,
		ShadowColor = {0, 0, 0, 1},
		JustifyH = "LEFT"
	}
}

local options = function(location)
	return {
		OnlyShowIfNotMaxLevel = {
			type = "toggle",
			name = L.LevelText_OnlyShowIfNotMaxLevel,
			order = 2
		},
		LevelTextTextSettings = {
			type = "group",
			name = L.TextSettings,
			get = function(option)
				return Data.GetOption(location.Text, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.Text, option, ...)
			end,
			inline = true,
			order = 3,
			args = Data.AddNormalTextSettings(location.Text)
		}
	}
end

local level = BattleGroundEnemies:NewButtonModule({
	moduleName = "Level",
	localizedModuleName = LEVEL,
	defaultSettings = defaultSettings,
	options = options,
	events = {"UnitIdUpdate"},
	enabledInThisExpansion = true
})

function level:AttachToPlayerButton(playerButton)
	local fs = BattleGroundEnemies.MyCreateFontString(playerButton)

	function fs:DisplayLevel()
		if (not self.config.OnlyShowIfNotMaxLevel or (playerButton.PlayerLevel and playerButton.PlayerLevel < MaxLevel)) then
			self:SetText(MaxLevel - 1) -- to set the width of the frame (the name shoudl have the same space from the role icon/spec icon regardless of level shown)
			self:SetWidth(0)
			self:SetText(playerButton.PlayerLevel)
		else
			self:SetText("")
		end
	end

	-- Level

	function fs:PlayerDetailsChanged()
		local playerDetails = playerButton.PlayerDetails
		if not playerDetails then return end
		if playerDetails.PlayerLevel then self:SetLevel(playerDetails.PlayerLevel) end --for testmode
	end

	function fs:UnitIdUpdate(unitID)
		if unitID then
			self:SetLevel(UnitLevel(unitID))
		end
	end


	function fs:SetLevel(level)
		if not playerButton.PlayerLevel or level ~= playerButton.PlayerLevel then
			playerButton.PlayerLevel = level
			
		end
		self:DisplayLevel()
	end

	function fs:ApplyAllSettings()
		self:ApplyFontStringSettings(self.config.Text)
		self:PlayerDetailsChanged()
		self:DisplayLevel()
	end
	playerButton.Level = fs
end

local CompactUnitFrame_UpdateHealPrediction = CompactUnitFrame_UpdateHealPrediction

local HealthTextTypes = {
	health = COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH,
	losthealth = COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH,
	perc = COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC
}

local defaultSettings = {
	Parent = "Button",
	Enabled = true,
	Texture = 'Blizzard Raid Bar',
	Background = {0, 0, 0, 0.66},
	HealthPrediction_Enabled = true,
	HealthTextEnabled = false,
	HealthTextType = "health",
	HealthText = {
		FontSize = 17,
		FontOutline = "",
		FontColor = {1, 1, 1, 1},
		EnableShadow = false,
		ShadowColor = {0, 0, 0, 1},
		JustifyH = "CENTER",
		JustifyV = "TOP",
	},
	ActivePoints = 2,
	Points = {
		{
			Point = "BOTTOMLEFT",
			RelativeFrame = "Power",
			RelativePoint = "TOPLEFT",
		},
		{
			Point = "TOPRIGHT",
			RelativeFrame = "Button",
			RelativePoint = "TOPRIGHT",
		}
	}
}

local options = function(location)
	return {
		Texture = {
			type = "select",
			name = L.BarTexture,
			desc = L.HealthBar_Texture_Desc,
			dialogControl = 'LSM30_Statusbar',
			values = AceGUIWidgetLSMlists.statusbar,
			width = "normal",
			order = 1
		},
		Fake = Data.AddHorizontalSpacing(2),
		Background = {
			type = "color",
			name = L.BarBackground,
			desc = L.HealthBar_Background_Desc,
			hasAlpha = true,
			width = "normal",
			order = 3
		},
		Fake1 = Data.AddVerticalSpacing(4),
		HealthPrediction_Enabled = {
			type = "toggle",
			name = COMPACT_UNIT_FRAME_PROFILE_DISPLAYHEALPREDICTION,
			width = "normal",
			order = 5,
		},
		HealthTextEnabled = {
			type = "toggle",
			name = L.HealthTextEnabled,
			width = "normal",
			order = 6,
		},
		HealthTextType = {
			type = "select",
			name = L.HealthTextType,
			width = "normal",
			values = HealthTextTypes,
			disabled = function() return not location.HealthTextEnabled end,
			order = 7,
		},
		HealthText = {
			type = "group",
			name = L.HealthTextSettings,
			get = function(option)
				return Data.GetOption(location.HealthText, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.HealthText, option, ...)
			end,
			disabled = function() return not location.HealthTextEnabled end,
			inline = true,
			order = 8,
			args = Data.AddNormalTextSettings(location.HealthText)
		}
	}
end

local healthBar = BattleGroundEnemies:NewButtonModule({
	moduleName = "healthBar",
	localizedModuleName = L.HealthBar,
	defaultSettings = defaultSettings,
	options = options,
	events = {"UpdateHealth", "PlayerDetailsChanged"},
	enabledInThisExpansion = true
})


function healthBar:AttachToPlayerButton(playerButton)
	playerButton.healthBar = CreateFrame('StatusBar', nil, playerButton)
	playerButton.healthBar:SetMinMaxValues(0, 1)

	playerButton.healthBar.HealthText = BattleGroundEnemies.MyCreateFontString(playerButton.healthBar)
	playerButton.healthBar.HealthText:SetPoint("BOTTOMLEFT", playerButton.healthBar, "BOTTOMLEFT", 3, 3)
	playerButton.healthBar.HealthText:SetPoint("TOPRIGHT", playerButton.healthBar, "TOPRIGHT", -3, -3)

	playerButton.myHealPrediction = playerButton.healthBar:CreateTexture(nil, "BORDER", nil, 5)
	playerButton.myHealPrediction:ClearAllPoints();
	playerButton.myHealPrediction:SetColorTexture(1,1,1);
	if playerButton.myHealPrediction.SetGradientAlpha then --this only exists until Dragonflight. 10.0 In dragonflight this :SetGradientAlpha got merged into SetGradient and CreateColor is required
		playerButton.myHealPrediction:SetGradient("VERTICAL", 8/255, 93/255, 72/255, 11/255, 136/255, 105/255);
	else
		playerButton.myHealPrediction:SetGradient("VERTICAL", CreateColor(8/255, 93/255, 72/255, 1), CreateColor(11/255, 136/255, 105/255, 1));
	end
	playerButton.myHealPrediction:SetVertexColor(0.0, 0.659, 0.608);


	playerButton.myHealAbsorb = playerButton.healthBar:CreateTexture(nil, "ARTWORK", nil, 1)
	playerButton.myHealAbsorb:ClearAllPoints();
	playerButton.myHealAbsorb:SetTexture("Interface\\RaidFrame\\Absorb-Fill", true, true);

	playerButton.myHealAbsorbLeftShadow = playerButton.healthBar:CreateTexture(nil, "ARTWORK", nil, 1)
	playerButton.myHealAbsorbLeftShadow:ClearAllPoints();

	playerButton.myHealAbsorbRightShadow = playerButton.healthBar:CreateTexture(nil, "ARTWORK", nil, 1)
	playerButton.myHealAbsorbRightShadow:ClearAllPoints();

	playerButton.otherHealPrediction = playerButton.healthBar:CreateTexture(nil, "BORDER", nil, 5)
	playerButton.otherHealPrediction:SetColorTexture(1,1,1);
	if playerButton.otherHealPrediction.SetGradientAlpha then
		playerButton.otherHealPrediction:SetGradient("VERTICAL", 11/255, 53/255, 43/255, 21/255, 89/255, 72/255);
	else
		playerButton.otherHealPrediction:SetGradient("VERTICAL", CreateColor(11/255, 53/255, 43/255, 1), CreateColor(21/255, 89/255, 72/255, 1));
	end
	


	playerButton.totalAbsorbOverlay = playerButton.healthBar:CreateTexture(nil, "BORDER", nil, 6)
	playerButton.totalAbsorbOverlay:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true);	--Tile both vertically and horizontally
	playerButton.totalAbsorbOverlay.tileSize = 20;

	playerButton.totalAbsorb = playerButton.healthBar:CreateTexture(nil, "BORDER", nil, 5)
	playerButton.totalAbsorb:SetTexture("Interface\\RaidFrame\\Shield-Fill");
	playerButton.totalAbsorb.overlay = playerButton.totalAbsorbOverlay
	playerButton.totalAbsorbOverlay:SetAllPoints(playerButton.totalAbsorb);

	playerButton.overAbsorbGlow = playerButton.healthBar:CreateTexture(nil, "ARTWORK", nil, 2)
	playerButton.overAbsorbGlow:SetTexture("Interface\\RaidFrame\\Shield-Overshield");
	playerButton.overAbsorbGlow:SetBlendMode("ADD");
	playerButton.overAbsorbGlow:SetPoint("BOTTOMLEFT", playerButton.healthBar, "BOTTOMRIGHT", -7, 0);
	playerButton.overAbsorbGlow:SetPoint("TOPLEFT", playerButton.healthBar, "TOPRIGHT", -7, 0);
	playerButton.overAbsorbGlow:SetWidth(16);
	playerButton.overAbsorbGlow:Hide()

	playerButton.overHealAbsorbGlow = playerButton.healthBar:CreateTexture(nil, "ARTWORK", nil, 2)
	playerButton.overHealAbsorbGlow:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb");
	playerButton.overHealAbsorbGlow:SetBlendMode("ADD");
	playerButton.overHealAbsorbGlow:SetPoint("BOTTOMRIGHT", playerButton.healthBar, "BOTTOMLEFT", 7, 0);
	playerButton.overHealAbsorbGlow:SetPoint("TOPRIGHT", playerButton.healthBar, "TOPLEFT", 7, 0);
	playerButton.overHealAbsorbGlow:SetWidth(16);
	playerButton.overHealAbsorbGlow:Hide()


	playerButton.healthBar.Background = playerButton.healthBar:CreateTexture(nil, 'BACKGROUND', nil, 2)
	playerButton.healthBar.Background:SetAllPoints()
	playerButton.healthBar.Background:SetTexture("Interface/Buttons/WHITE8X8")



	playerButton.healthBar.UpdateHealthText = function(self, health, maxHealth)
		if health and maxHealth then
			local config = self.config
			if not config.HealthTextEnabled then return end
			if config.HealthTextType == "health" then
				health = AbbreviateLargeNumbers(health)
				self.HealthText:SetText(health);
				self.HealthText:Show()
			elseif config.HealthTextType == "losthealth" then
				local healthLost = maxHealth - health
				if ( healthLost > 0 ) then
					healthLost = AbbreviateLargeNumbers(healthLost)
					self.HealthText:SetText("-"..healthLost)
					self.HealthText:Show()
				else
					self.HealthText:Hide()
				end
			elseif (config.HealthTextType == "perc") and (maxHealth > 0) then
				local perc = math.ceil(100 * (health/maxHealth))
				self.HealthText:SetFormattedText("%d%%", perc);
				self.HealthText:Show()
			else
				self.HealthText:Hide()
			end
		else
			self.HealthText:Hide()
		end
	end
	--
	function playerButton.healthBar:UpdateHealth(unitID, health, maxHealth)
		self:SetMinMaxValues(0, maxHealth)
		self:SetValue(health)


		--next wo lines are needed for CompactUnitFrame_UpdateHealPrediction()

		self:UpdateHealthText(health, maxHealth)
		if unitID and CompactUnitFrame_UpdateHealPrediction then
			local config = self.config
			playerButton.displayedUnit = unitID
			playerButton.optionTable = {displayHealPrediction = config.HealthPrediction_Enabled}
			CompactUnitFrame_UpdateHealPrediction(playerButton)
		end
	end

	function playerButton.healthBar:PlayerDetailsChanged()
		local playerDetails = playerButton.PlayerDetails
		if not playerDetails then return end
		local color = playerDetails.PlayerClassColor
		self:SetStatusBarColor(color.r,color.g,color.b)
		self:SetMinMaxValues(0, 1)
		self:SetValue(1)
		self:UpdateHealthText(false, false)

		playerButton.totalAbsorbOverlay:Hide()
		playerButton.totalAbsorb:Hide()
	end

	function playerButton.healthBar:ApplyAllSettings()
		local config = self.config
		self:SetStatusBarTexture(LSM:Fetch("statusbar", config.Texture))--self.healthBar:SetStatusBarTexture(137012)
		self.Background:SetVertexColor(unpack(config.Background))
		if config.HealthTextEnabled then
			self.HealthText:Show()
		else
			self.HealthText:Hide()
		end

		self.HealthText:ApplyFontStringSettings(config.HealthText)
		self:PlayerDetailsChanged()
	end
end

