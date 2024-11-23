---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)
---@class BattleGroundEnemies
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L
local C_Covenants = C_Covenants

local CreateFrame = CreateFrame
local GameTooltip = GameTooltip

local defaultSettings = {
	Enabled = true,
	Parent = "healthBar",
	ActivePoints = 1,
	Points = {
		{
			Point = "TOPLEFT",
			RelativeFrame = "Role",
			RelativePoint = "TOPRIGHT",
		},
	},
	Width = 20,
	Height = 20
}

local covenant = BattleGroundEnemies:NewButtonModule({
	moduleName = "Covenant",
	localizedModuleName = L.Covenant,
	defaultSettings = defaultSettings,
	flags = {
		SetZeroHeightWhenDisabled = true,
		SetZeroWidthWhenDisabled = true
	},
	options = nil,
	events = {},
	enabledInThisExpansion = LE_EXPANSION_LEVEL_CURRENT == LE_EXPANSION_SHADOWLANDS,
	attachSettingsToButton = true
})

function covenant:AttachToPlayerButton(playerButton)
-- Covenant Icon
	playerButton.Covenant = CreateFrame("Frame", nil, playerButton)

	playerButton.Covenant:HookScript("OnEnter", function(self)
		BattleGroundEnemies:ShowTooltip(self, function()
			if self.covenantID then
				GameTooltip:SetText(C_Covenants.GetCovenantData(self.covenantID).name)
			end
		end)
	end)

	playerButton.Covenant:HookScript("OnLeave", function(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end)
	playerButton.Covenant.covenantID = false
	playerButton.Covenant.Icon = playerButton.Covenant:CreateTexture(nil, 'OVERLAY')
	playerButton.Covenant.Icon:SetAllPoints()

	playerButton.Covenant.DisplayCovenant = function(self)
		if self.covenantID then
			local texture = Data.CovenantIcons[self.covenantID]
			if texture then
				self.Icon:SetTexture(texture)
			end
		end
	end

	playerButton.Covenant.UpdateCovenant = function(self, covenantID)
		self.covenantID = covenantID
		self:DisplayCovenant()
	end

	playerButton.Covenant.ApplyAllSettings = function(self)
		if not self.config then return end
		self:DisplayCovenant()
	end

	playerButton.Covenant.Reset = function(self)
		self.covenantID = false
	end
	return playerButton.Covenant
end
