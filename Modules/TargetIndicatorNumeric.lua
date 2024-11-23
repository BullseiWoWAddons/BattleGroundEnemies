---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)
---@class BattleGroundEnemies
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L

local generalDefaults = {
	HideWhenZero = false,
}

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
		JustifyH = "RIGHT",
		JustifyV = "MIDDLE"
	}
}

local generalOptions = function(location, playerType)
	return {
		HideWhenZero = {
			type = "toggle",
			name = L.HideWhenZero,
			desc = L.TargetIndicatorNumeric_HideWhenZero_Desc,
			width = 'normal',
			order = 1
		}
	}
end

local options = function(location, playerType)
	return {
		TextSettings = {
			type = "group",
			name = L.Text,
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
	generalDefaults = generalDefaults,
	options = options,
	generalOptions = generalOptions,
	events = {"UpdateTargetIndicators"},
	enabledInThisExpansion = true,
	attachSettingsToButton = true
})

function targetIndicatorNumeric:AttachToPlayerButton(playerButton)
	playerButton.TargetIndicatorNumeric = BattleGroundEnemies.MyCreateFontString(playerButton)

	function playerButton.TargetIndicatorNumeric:UpdateTargetIndicators()
		local enemyTargets = 0

		if playerButton.UnitIDs and playerButton.UnitIDs.TargetedByEnemy then
			for enemyButton in pairs(playerButton.UnitIDs.TargetedByEnemy) do
				enemyTargets = enemyTargets + 1
			end
		end
		
		if enemyTargets == 0 and self.config.HideWhenZero then
			self:SetText("")
		else
			self:SetText(enemyTargets)
		end
	end

	playerButton.TargetIndicatorNumeric.ApplyAllSettings = function(self)
		if not self.config then return end
		self:ApplyFontStringSettings(self.config.Text)
		self:UpdateTargetIndicators()
	end

	playerButton.TargetIndicatorNumeric.Reset = function(self)
		--dont SetWidth before Hide() otherwise it won't work as aimed
		if not self:GetFont() then return end
		self:SetText(0) --we do that because the level is anchored right to this and the name is anhored right to the level
	end
	return playerButton.TargetIndicatorNumeric
end