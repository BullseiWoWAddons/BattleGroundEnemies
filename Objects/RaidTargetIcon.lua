
local BattleGroundEnemies = BattleGroundEnemies
local AddonName, Data = ...

local BackdropTemplateMixin = BackdropTemplateMixin
local CreateFrame = CreateFrame
local GetRaidTargetIndex = GetRaidTargetIndex
local SetRaidTargetIconTexture = SetRaidTargetIconTexture
local L = Data.L


local defaultSettings = {
	Enabled = true,
	Parent = "healthBar",
	Width = 30,
	Height = 30,
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

local flags = {
	Height = "Variable",
	Width = "Variable"
}

local events = {"UpdateRaidTargetIcon", "PlayerButtonSizeChanged"}

local raidTargetIcon = BattleGroundEnemies:NewButtonModule("RaidTargetIcon", L.RaidTargetIcon, flags, defaultSettings, nil, events)

function raidTargetIcon:AttachToPlayerButton(playerButton)
	playerButton.RaidTargetIcon = CreateFrame('Frame', nil, playerButton, BackdropTemplateMixin and "BackdropTemplate")
	playerButton.RaidTargetIcon.Icon = playerButton.RaidTargetIcon:CreateTexture(nil, "OVERLAY")
	playerButton.RaidTargetIcon.Icon:SetTexture("Interface/TargetingFrame/UI-RaidTargetingIcons")
	playerButton.RaidTargetIcon.Icon:SetAllPoints()


	function playerButton.RaidTargetIcon:UpdateRaidTargetIcon()
		local unit = playerButton:GetUnitID()
		if unit then
			local index = GetRaidTargetIndex(unit)
			if index then
				SetRaidTargetIconTexture(self.Icon, index)
				self:Show()
			else
				self:Hide()
			end
		else
			self:Hide()
		end
	end

	function playerButton.RaidTargetIcon:PlayerButtonSizeChanged(width, height)
		self:SetWidth(height)
	end

	function playerButton.RaidTargetIcon:ApplyAllSettings()
		self:UpdateRaidTargetIcon()
	end
end










-- on new player on unit





