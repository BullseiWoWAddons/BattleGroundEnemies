local AddonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L

local CreateFrame = CreateFrame

local defaultSettings = {
	Enabled = true,
	Parent = "healthBar",
	Width = 8,
	Height = 10,
	ActivePoints = 2,
	Points = {
		{
			Point = "TOPLEFT",
			RelativeFrame = "Button",
			RelativePoint = "TOPLEFT",
			OffsetX = 1
		},
		{
			Point = "BOTTOMRIGHT",
			RelativeFrame = "Button",
			RelativePoint = "BOTTOMRIGHT",
			OffsetX = 1
		}
	},

}

local options = function(location, playerType)
	return {
		Width = {
			type = "range",
			name = L.Width,
			desc = L.RoleIcon_Size_Desc,
			min = 1,
			max = 20,
			step = 1,
			width = "normal",
			order = 1
		},
		Height = {
			type = "range",
			name = L.Height,
			min = 1,
			max = 20,
			step = 1,
			width = "normal",
			order = 2,
		}
	}
end

local symbolicTargetIndicator = BattleGroundEnemies:NewButtonModule({
	moduleName = "TargetIndicatorSymbolic",
	localizedModuleName = L.TargetIndicatorSymbolic,
	defaultSettings = defaultSettings,
	options = options,
	events = {"UpdateTargetIndicators"},
	expansions = "All"
})

function symbolicTargetIndicator:AttachToPlayerButton(playerButton)
	playerButton.TargetIndicatorSymbolic = CreateFrame("frame", nil, playerButton)
	playerButton.TargetIndicatorSymbolic.Symbols = {}

	function playerButton.TargetIndicatorSymbolic:UpdateTargetIndicators()

		local targetIndicatorConfig = self.config


		local i = 1
		for enemyButton in pairs(playerButton.UnitIDs.TargetedByEnemy) do
			local indicator = self.Symbols[i]
			if not indicator then
				indicator = CreateFrame("frame", nil, playerButton.TargetIndicatorSymbolic, BackdropTemplateMixin and "BackdropTemplate")
				indicator:SetSize(targetIndicatorConfig.Width, targetIndicatorConfig.Height)
				indicator:SetPoint("TOP",floor(i/2)*(i%2==0 and -10 or 10), 0) --1: 0, 0 2: -10, 0 3: 10, 0 4: -20, 0 > i = even > left, uneven > right
				indicator:SetBackdrop({
					bgFile = "Interface/Buttons/WHITE8X8", --drawlayer "BACKGROUND"
					edgeFile = 'Interface/Buttons/WHITE8X8', --drawlayer "BORDER"
					edgeSize = 1
				})
				indicator:SetBackdropBorderColor(0,0,0,1)
				self.Symbols[i] = indicator
			end
			local classColor = enemyButton.PlayerClassColor
			indicator:SetBackdropColor(classColor.r,classColor.g,classColor.b)
			indicator:Show()

			i = i + 1
		end

		while self.Symbols[i] do --hide no longer used ones
			self.Symbols[i]:Hide()
			i = i + 1
		end
	end
end

