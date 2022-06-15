local AddonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local LSM = LibStub("LibSharedMedia-3.0")
local L = Data.L
local GetTime = GetTime

local defaultSettings = {
	Enabled = false,
	Parent = "Button",
	Height = 4,
	Texture = 'UI-StatusBar',
	Background = {0, 0, 0, 0.66},
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
		Height = {
			type = "range",
			name = L.Height,
			desc = L.PowerBar_Height_Desc,
			min = 1,
			max = 10,
			step = 1,
			width = "normal",
			order = 2
		},
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
	Height = "Variable",
	Width = "Fixed"
}

local events = {"UNIT_POWER_FREQUENT"}

local power = BattleGroundEnemies:NewModule("Power", "Power", nil, defaultSettings, options, events)

function power:AttachToPlayerButton(playerButton)
	playerButton.Power = CreateFrame('StatusBar', nil, playerButton)
	playerButton.Power:SetMinMaxValues(0, 1)

	
	--playerButton.Power.Background = playerButton.Power:CreateTexture(nil, 'BACKGROUND', nil, 2)
	playerButton.Power.Background = playerButton.Power:CreateTexture(nil, 'BACKGROUND', nil, 2)
	playerButton.Power.Background:SetAllPoints()
	playerButton.Power.Background:SetTexture("Interface/Buttons/WHITE8X8")

	function playerButton.Power:CheckForNewPowerColor(powerToken)
		if self.powerToken ~= powerToken then
			local color = PowerBarColor[powerToken]
			if color then
				self:SetStatusBarColor(color.r, color.g, color.b)
				self.powerToken = powerToken
			end
		end
	end
	--	
	function playerButton.Power:UNIT_POWER_FREQUENT(unitID, powerToken)
		if powerToken then
			self:CheckForNewPowerColor(powerToken)
		else
			local powerType, powerToken, altR, altG, altB = UnitPowerType(unitID)
			self:CheckForNewPowerColor(powerToken)
		end
		self:SetValue(UnitPower(unitID)/UnitPowerMax(unitID))
	end


	function playerButton.Power:ApplyAllSettings()
		-- power
		self:SetHeight(self.config.Height or 0.01)
		self:SetStatusBarTexture(LSM:Fetch("statusbar", self.config.Texture))--self.healthBar:SetStatusBarTexture(137012)
		self.Background:SetVertexColor(unpack(self.config.Background))
	end

	function playerButton.Power:Reset()
		-- power
		self:SetHeight(0.01)
	end
end










-- on new player on unit



