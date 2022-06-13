local AddonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L
local C_Covenants = C_Covenants

local defaultSettings = {
	Enabled = true,
	Parent = "healthBar",
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
		FontSize = 18,
		Fontoutline = "",
		FontColor = {1, 1, 1, 1},
		EnableTextshadow = false,
		TextShadowcolor = {0, 0, 0, 1}
	}
}

local options = function(location, playerType) 
	return {		
		TextSettings = {
			type = "group",
			name = "",
			--desc = L.TrinketSettings_Desc,
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

local flags = {
	Height = "Fixed",
	Width = "Dynamic"
}

local events = {"UpdateTargetIndicators"}

local targetIndicatorNumeric = BattleGroundEnemies:NewModule("TargetIndicatorNumeric", "TargetIndicatorNumeric", flags, defaultSettings, options, events)

function targetIndicatorNumeric:AttachToPlayerButton(playerButton)


	playerButton.TargetIndicatorNumeric = BattleGroundEnemies.MyCreateFontString(playerButton)
	playerButton.TargetIndicatorNumeric:SetJustifyH("RIGHT")

	function playerButton.TargetIndicatorNumeric:UpdateTargetIndicators(playerButton)

		local targetIndicatorConfig = self.config

		local i = 1
		for enemyButton in pairs(playerButton.UnitIDs.TargetedByEnemy) do
			i = i + 1
		end

		local enemyTargets = i - 1


		self:SetText(enemyTargets)
	end

	playerButton.TargetIndicatorNumeric.ApplyAllSettings = function(self)
		self:ApplyFontStringSettings(self.config.Text)
		self:SetText(0)
	end

	playerButton.TargetIndicatorNumeric.Reset = function(self)
		--dont SetWidth before Hide() otherwise it won't work as aimed
		self:SetText(0) --we do that because the level is anchored right to this and the name is anhored right to the leve
	end
end

