local AddonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L
local C_Covenants = C_Covenants

local defaultSettings = {
	Points = {
		{
			Point = "TOPLEFTT",
			RelativeFrame = "Role",
			RelativePoint = "TOPRIGHT",
		},
		{
			Point = "BOTTOMLEFT",
			RelativeFrame = "Role",
			RelativePoint = "BOTTOMRIGHT",
		}
	},
	Size = 20,
	VerticalPosition = 3,
}

local options = function(location) 
	return {
		Size = {
			type = "range",
			name = L.Size,
			desc = L.CovenantIcon_Size_Desc,
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

local events = {"OnNewPlayer"}

local covenant = BattleGroundEnemies:NewModule("Covenant", "Covenant", 3, defaultSettings, options, events)

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

	playerButton.Covenant:SetPoint("TOPLEFT", playerButton.Role, "TOPRIGHT")
	playerButton.Covenant:SetPoint("BOTTOMLEFT", playerButton.Role, "BOTTOMRIGHT")
	playerButton.Covenant:SetWidth(0.001)
	playerButton.Covenant.covenantID = false
	playerButton.Covenant.Icon = playerButton.Covenant:CreateTexture(nil, 'OVERLAY')

	playerButton.Covenant.DisplayCovenant = function(self, covenantID)
		self.covenantID = covenantID
		self.Icon:SetTexture(Data.CovenantIcons[covenantID])
		self:ApplyAllSettings()
	end

	playerButton.Covenant.Reset = function(self)
		self.covenantID = false
		self:Hide()
		self:SetSize(0.01, 0.01)
	end

	playerButton.Covenant.ApplyAllSettings = function(self)
		self:SetWidth(self.config.Size)
		self.Icon:SetSize(self.config.Size, self.config.Size)
		self.Icon:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -self.config.VerticalPosition)
		self:Show()
	end
end










-- on new player on unit




		
		
		-- name
		