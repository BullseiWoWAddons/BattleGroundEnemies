local AddonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L
local GetTime = GetTime
local MaxLevel = GetMaxPlayerLevel()


local IsTBCC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local options = {

}

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
			OffsetY = 2,
		},
	},
}


local flags = {
	Height = "Variable",
	Width = "Variable"
}

local events = {"SetSpecAndRole"}

local role = BattleGroundEnemies:NewModule("Role", "Role", flags, defaultSettings, options, events)

function role:AttachToPlayerButton(playerButton)
	playerButton.Role = CreateFrame("Frame", nil, playerButton)
	playerButton.Role.Icon = playerButton.Role:CreateTexture(nil, 'OVERLAY')
	playerButton.Role.Icon:SetAllPoints()

	playerButton.Role.ApplyAllSettings = function(self)
		if not (IsTBCC or IsClassic) then 
			self:Show()
		else
			self:Reset()
		end
	end

	playerButton.Role.SetSpecAndRole = function(self)
		if playerButton.PlayerSpecName then 
			self.Icon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
			self.Icon:SetTexCoord(GetTexCoordsForRoleSmallCircle(playerButton.PlayerRoleID))
		end
	end
	playerButton.Role.Reset = function(self)
		self:Hide()
		self:SetSize(0.01, 0.01)
	end
end










-- on new player on unit




		
		
		-- name
		