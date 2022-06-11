local AddonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L
local C_Covenants = C_Covenants

local defaultSettings = {
	Text = {
		Fontsize = 18,
		Outline = "",
		Textcolor = {1, 1, 1, 1},
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

local events = {"UpdateTargetIndicators"}

local numericTargetIndicator = BattleGroundEnemies:NewModule("NumericTargetIndicator", "NumericTargetIndicator", 3, defaultSettings, options, events)

function numericTargetIndicator:AttachToPlayerButton(playerButton)


	playerButton.NumericTargetIndicator = BattleGroundEnemies.MyCreateFontString(playerButton)
	playerButton.NumericTargetIndicator:SetPoint('TOPRIGHT', playerButton, "TOPRIGHT", -5, 0)
	playerButton.NumericTargetIndicator:SetPoint('BOTTOMRIGHT', playerButton, "BOTTOMRIGHT", -5, 0)
	playerButton.NumericTargetIndicator:SetJustifyH("RIGHT")

	function playerButton.NumericTargetIndicator:UpdateTargetIndicators(playerButton)

		local targetIndicatorConfig = self.config

		local i = 1
		for enemyButton in pairs(playerButton.UnitIDs.TargetedByEnemy) do
			i = i + 1
		end

		local enemyTargets = i - 1


		self:SetText(enemyTargets)
	end

	playerButton.NumericTargetIndicator.ApplySettings = function(self)
		self:ApplyFontStringSettings(self.config.Text)
		self:SetText(0)
	end

	playerButton.NumericTargetIndicator.Reset = function(self)
		--dont SetWidth before Hide() otherwise it won't work as aimed
		self:SetText(0) --we do that because the level is anchored right to this and the name is anhored right to the leve
	end
end

