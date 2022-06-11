local AddonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L
local C_Covenants = C_Covenants

local defaultSettings = {
	Enabled = true,
	Numeric = {
		Enabled = true,
		Text = {
			Fontsize = 18,
			Outline = "",
			Textcolor = {1, 1, 1, 1},
			EnableTextshadow = false,
			TextShadowcolor = {0, 0, 0, 1}
		}
	},
	SymbolicTargetIndicator_Enabled = true
}

local options = function(location, playerType) 
	return {
		NumericTargetindicatorSettings = {
			type = "group",
			name = "",
			--desc = L.TrinketSettings_Desc,
			disabled = function() return not location.NumericTargetindicator_Enabled end,
			inline = true,
			order = 2,
			args = {
				Enabled = {
					type = "toggle",
					name = L.NumericTargetindicator_Enabled,
					desc = L.NumericTargetindicator_Enabled_Desc:format(L[playerType == "Enemies" and "enemy" or "ally"]),
					width = "full",
					order = 1
				},
				TextSettings = {
					type = "group",
					name = "",
					--desc = L.TrinketSettings_Desc,
					inline = true,
					order = 4,
					get = function(option)
						return Data.GetOption(location.Numeric.Text, option)
					end,
					set = function(option, ...)
						return Data.SetOption(location.Numeric.Text, option, ...)
					end,
					args = Data.AddNormalTextSettings(location.Numeric.Text)
				}
			}
		},
		Fake2 = Data.addVerticalSpacing(3),
		SymbolicTargetindicator_Enabled = {
			type = "toggle",
			name = L.SymbolicTargetindicator_Enabled,
			desc = L.SymbolicTargetindicator_Enabled_Desc:format(L[playerType == "Enemies" and "enemy" or "ally"]),
			width = "full",
			order = 4
		}
	}
end

local events = {"UpdateTargetIndicators"}

local targetIndicator = BattleGroundEnemies:NewModule("TargetIndicator", "TargetIndicator", 3, defaultSettings, options, events)

function targetIndicator:AttachToPlayerButton(playerButton)

	playerButton.TargetIndicator = CreateFrame("frame", nil, playerButton)
	playerButton.TargetIndicator.Numeric = BattleGroundEnemies.MyCreateFontString(playerButton.TargetIndicator)
	playerButton.TargetIndicator.Numeric:SetPoint('TOPRIGHT', playerButton, "TOPRIGHT", -5, 0)
	playerButton.TargetIndicator.Numeric:SetPoint('BOTTOMRIGHT', playerButton, "BOTTOMRIGHT", -5, 0)
	playerButton.TargetIndicator.Numeric:SetJustifyH("RIGHT")
	playerButton.TargetIndicator.Symbolic = {}

	function playerButton.TargetIndicator:UpdateTargetIndicators(PlayerButton)
		BattleGroundEnemies.Counter.UpdateTargetIndicators = (BattleGroundEnemies.Counter.UpdateTargetIndicators or 0) + 1
		local isAlly = false
		local isPlayer = false

		if playerButton == PlayerButton then
			isPlayer = true
		elseif not playerButton.PlayerIsEnemy then 
			isAlly = true 
		end
		local targetIndicatorConfig = self.config

		local i = 1
		for enemyButton in pairs(playerButton.UnitIDs.TargetedByEnemy) do
			if targetIndicatorConfig.SymbolicTargetIndicator_Enabled then
				local indicator = self.Symbolic[i]
				if not indicator then
					indicator = CreateFrame("frame", nil, playerButton.healthBar, BackdropTemplateMixin and "BackdropTemplate")
					indicator:SetSize(8,10)
					indicator:SetPoint("TOP",floor(i/2)*(i%2==0 and -10 or 10), 0) --1: 0, 0 2: -10, 0 3: 10, 0 4: -20, 0 > i = even > left, uneven > right
					indicator:SetBackdrop({
						bgFile = "Interface/Buttons/WHITE8X8", --drawlayer "BACKGROUND"
						edgeFile = 'Interface/Buttons/WHITE8X8', --drawlayer "BORDER"
						edgeSize = 1
					}) 
					indicator:SetBackdropBorderColor(0,0,0,1)
					self.Symbolic[i] = indicator
				end
				local classColor = enemyButton.PlayerClassColor
				indicator:SetBackdropColor(classColor.r,classColor.g,classColor.b)
				indicator:Show()
			end
			i = i + 1
		end

		local enemyTargets = i - 1


		if targetIndicatorConfig.Numeric.Enabled then 
			self.Numeric:SetText(enemyTargets)
		end
		while self.Symbolic[i] do --hide no longer used ones
			self.Symbolic[i]:Hide()
			i = i + 1
		end
	end

	playerButton.TargetIndicator.ApplySettings = function(self)
		self.Numeric:SetShown(self.config.TargetIndicator.Numeric.Enabled) 
		self.Numeric:ApplyFontStringSettings(self.config.TargetIndicator.Numeric.Text)
		self.Numeric:SetText(0)
	end

	playerButton.TargetIndicator.Reset = function(self)
		--dont SetWidth before Hide() otherwise it won't work as aimed
		self.Numeric:SetText(0) --we do that because the level is anchored right to this and the name is anhored right to the leve
	end
end

