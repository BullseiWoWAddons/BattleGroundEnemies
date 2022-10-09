local AddonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L

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
	Height = "Variable",
	Width = "Variable"
}

local targetIndicatorNumeric = BattleGroundEnemies:NewButtonModule({
	moduleName = "TargetIndicatorNumeric",
	localizedModuleName = L.TargetIndicatorNumeric,
	flags = flags,
	defaultSettings = defaultSettings,
	options = options,
	events = {"UpdateTargetIndicators"},
	expansions = "All"
})

function targetIndicatorNumeric:AttachToPlayerButton(playerButton)


	playerButton.TargetIndicatorNumeric = BattleGroundEnemies.MyCreateFontString(playerButton)

	function playerButton.TargetIndicatorNumeric:UpdateTargetIndicators()
		local targetIndicatorConfig = self.config

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
		self:SetText(0) --we do that because the level is anchored right to this and the name is anhored right to the leve
	end
end

