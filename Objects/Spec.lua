local AddonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L
local CreateFrame = CreateFrame
local GameTooltip = GameTooltip


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


local flags = {
	Height = "Fixed",
	Width = "Variable"
}

local events = {"SetSpecAndRole"}

local spec = BattleGroundEnemies:NewButtonModule("Spec", L.Spec, flags, defaultSettings, nil, events)

function spec:AttachToPlayerButton(playerButton)
	playerButton.Spec = CreateFrame("Frame", nil, playerButton)

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
			--hasSpeccs
			self.Icon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
			self.Icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[playerButton.PlayerClass]))
		end
		local width = self:GetWidth()
		local height = self:GetHeight()
		if width and height and width > 0 and height > 0 then
			self:CropImage(self:GetWidth(), self:GetHeight())
		end
	end


	playerButton.Spec.ApplyAllSettings = function(self)
		self:Show()
	end
end
