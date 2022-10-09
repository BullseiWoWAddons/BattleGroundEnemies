local AddonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L
local GetTexCoordsForRoleSmallCircle = GetTexCoordsForRoleSmallCircle

local IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local IsTBCC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local IsWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC

local HasSpeccs = not (IsClassic or IsTBCC or IsWrath)



local defaultSettings = {
	Enabled = true,
	Parent = "healthBar",
	Width = 12,
	Height = 12,
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


local flags = {
	Height = "Variable",
	Width = "Variable"
}

local role = BattleGroundEnemies:NewButtonModule({
	moduleName = "Role",
	localizedModuleName = L.Role,
	flags = flags,
	defaultSettings = defaultSettings,
	options = nil,
	events = {"SetSpecAndRole"},
	expansions = {WOW_PROJECT_MAINLINE}
})

function role:AttachToPlayerButton(playerButton)
	playerButton.Role = CreateFrame("Frame", nil, playerButton)
	playerButton.Role.Icon = playerButton.Role:CreateTexture(nil, 'OVERLAY')
	playerButton.Role.Icon:SetAllPoints()

	playerButton.Role.ApplyAllSettings = function(self)
		if HasSpeccs then
			self:Show()
		else
			self:Hide()
		end
	end

	playerButton.Role.SetSpecAndRole = function(self)
		if playerButton.PlayerSpecName then
			self.Icon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
			self.Icon:SetTexCoord(GetTexCoordsForRoleSmallCircle(playerButton.PlayerRoleID))
		end
	end
end