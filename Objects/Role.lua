local AddonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L
local GetTime = GetTime
local MaxLevel = GetMaxPlayerLevel()


local IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IsTBCC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local options = {

}

local defaultSettings = {
	Size = 13,
	VerticalPosition = 2,
	Points = {
		{
			Point = "TOPLEFTT",
			RelativeFrame = "healthBar",
			RelativePoint = "TOPLEFT",
		},
		{
			Point = "BOTTOMLEFT",
			RelativeFrame = "healthBar",
			RelativePoint = "BOTTOMLEFT",
		}
	},
}

local options = function(location) 
	return {
		Size = {
			type = "range",
			name = L.Size,
			desc = L.RoleIcon_Size_Desc,
			min = 2,
			max = 80,
			step = 1,
			width = "normal",
			order = 2
		},
		VerticalPosition = {
			type = "range",
			name = L.VerticalPosition,
			min = 0,
			max = 50,
			step = 1,
			width = "normal",
			order = 3,
		}
	}
end

local events = {"SetSpecAndRole"}

local role = BattleGroundEnemies:NewModule("Role", "Role", 3, defaultSettings, options, events)

function role:AttachToPlayerButton(playerButton)
	playerButton.Role = CreateFrame("Frame", nil, playerButton)
	playerButton.Role:SetPoint("TOPLEFT")
	playerButton.Role:SetPoint("BOTTOMLEFT")
	playerButton.Role.Icon = playerButton.Role:CreateTexture(nil, 'OVERLAY')

	playerButton.Role.ApplyAllSettings = function(self)
		if not (IsTBCC or IsClassic) then 
			self.config.
			self:SetWidth(self.config.Size)
			self.Icon:SetSize(self.config.Size, self.config.Size)
			self.Icon:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -self.config.VerticalPosition)
			self:Show()
		else
			self:Disable()
		end
	end

	playerButton.Role.SetSpecAndRole = function(self)
		if playerButton.PlayerSpecName then 
			self.Role.Icon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
			self.Role.Icon:SetTexCoord(GetTexCoordsForRoleSmallCircle(playerButton.PlayerRoleID))
			self.Spec.Icon:SetTexture(Data.Classes[playerButton.PlayerClass][playerButton.PlayerSpecName].specIcon)
		end
	end
	playerButton.Role.Disable = function(self)
		self:Hide()
		self:SetSize(0.01, 0.01)
	end
end










-- on new player on unit




		
		
		-- name
		