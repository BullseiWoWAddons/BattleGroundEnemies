local AddonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L
local C_Covenants = C_Covenants

local defaultSettings = {
	Enabled = true,
	Width = 36,
	Parent = "Button",
	Points = {
		{
			Point = "TOPLEFT",
			RelativeFrame = "Button",
			RelativePoint = "TOPLEFT",
		},
		{
			Point = "BOTTOMLEFT",
			RelativeFrame = "Button",
			RelativePoint = "BOTTOMLEFT",
		}
	},
}

local options = function(location) 
	return {
		Width = {
			type = "range",
			name = L.Width,
			desc = L.Spec_Width_Desc,
			min = 1,
			max = 80,
			step = 1,
			order = 2
		}
	}
end

local flags = {
	Height = "Fixed",
	Width = "Variable"
}

local events = {"SetSpecAndRole"}

local spec = BattleGroundEnemies:NewModule("Spec", "Spec", nil, defaultSettings, options, events)

function spec:AttachToPlayerButton(playerButton)
	playerButton.Spec = CreateFrame("Frame", nil, playerButton) 
			
	playerButton.Spec:SetPoint('TOPLEFT', playerButton, 'TOPLEFT', 0, 0)
	playerButton.Spec:SetPoint('BOTTOMLEFT' , playerButton, 'BOTTOMLEFT', 0, 0)

	playerButton.Spec:SetScript("OnSizeChanged", function(self, width, height)
		self:CropImage(width, height)
	end)

	function playerButton.Spec:CropImage(width, height)
		if playerButton.PlayerSpecName then
			BattleGroundEnemies.CropImage(self.Icon, width, height)
		end
		--BattleGroundEnemies.CropImage(playerButton.Spec_HighestActivePriority.Icon, width, height)
	end

	playerButton.Spec:HookScript("OnEnter", function(self)
		BattleGroundEnemies:ShowTooltip(self, function()
			if not playerButton.PlayerSpecName then return end 
			GameTooltip:SetText(playerButton.PlayerSpecName)
		end)
	end)

	playerButton.Spec:HookScript("OnLeave", function(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end)

	playerButton.Spec.Background = playerButton.Spec:CreateTexture(nil, 'BACKGROUND')
	playerButton.Spec.Background:SetAllPoints()
	playerButton.Spec.Background:SetColorTexture(0,0,0,0.8)

	playerButton.Spec.Icon = playerButton.Spec:CreateTexture(nil, 'OVERLAY')
	playerButton.Spec.Icon:SetAllPoints()

	playerButton.Spec.SetSpecAndRole = function(self)
		if playerButton.PlayerSpecName then
			self.Icon:SetTexture(Data.Classes[playerButton.PlayerClass][playerButton.PlayerSpecName].specIcon)
		else
			--isTBCC, TBCC
			self.Icon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
			self.Icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[playerButton.PlayerClass]))
		end
		self:CropImage(self:GetWidth(), self:GetHeight())
	end


	playerButton.Spec.ApplyAllSettings = function(self)
		self:Show()
		self:SetWidth(self.config.Width)
	end
end
