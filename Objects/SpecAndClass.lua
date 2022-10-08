local AddonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L
local CreateFrame = CreateFrame
local GameTooltip = GameTooltip


local specDefaults = {
	Enabled = true,
	Parent = "Button",
	Points = {
		{
			Point = "TOPLEFT",
			RelativeFrame = "Class",
			RelativePoint = "TOPLEFT",
		},
		{
			Point = "BOTTOMRIGHT",
			RelativeFrame = "Class",
			RelativePoint = "BOTTOMRIGHT",
		}
	},
}

local classDefaults = {
	Enabled = true,
	OnlyShowIfNoSpec = true,
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


local classFlags = {
	Height = "Fixed",
	Width = "Variable"
}

local events = {"SetSpecAndRole"}

local class = BattleGroundEnemies:NewButtonModule("Class", L.Class, classFlags, classDefaults, nil, events)
local spec = BattleGroundEnemies:NewButtonModule("Spec", L.Spec, nil, specDefaults, nil, events)




local function attachToPlayerButton(playerButton, type)
	local frame = CreateFrame("Frame", nil, playerButton)
	frame.type = type

	frame:SetScript("OnSizeChanged", function(self, width, height)
		self:CropImage(width, height)
	end)

	function frame:CropImage(width, height)
		if playerButton.PlayerSpecName then
			BattleGroundEnemies.CropImage(self.Icon, width, height)
		end
	end

	frame:HookScript("OnEnter", function(self)
		BattleGroundEnemies:ShowTooltip(self, function()
			if self.type == "Class" then
				if not playerButton.PlayerClass then return end
				local numClasses = GetNumClasses()
				for i = 1, numClasses do -- we could also just save the localized class name it into the button itself, but since its only used for this tooltip no need for that
					local className, classFile, classID = GetClassInfo(i)
					if classFile and classFile == playerButton.PlayerClass then
						return GameTooltip:SetText(className)
					end
				end
			else --"Spec"
				if not playerButton.PlayerSpecName then return end
				GameTooltip:SetText(playerButton.PlayerSpecName)
			end
		end)
	end)

	frame:HookScript("OnLeave", function(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end)

	frame.Background = playerButton.Spec:CreateTexture(nil, 'BACKGROUND')
	frame.Background:SetAllPoints()
	frame.Background:SetColorTexture(0,0,0,0.8)

	frame.Icon = frame:CreateTexture(nil, 'OVERLAY')
	frame.Icon:SetAllPoints()

	frame.SetSpecAndRole = function(self)
		if self.type == "Class" then
			if playerButton.PlayerSpecName and self.config.OnlyShowIfNoSpec then
				self.Icon:SetTexture(nil)
			else
				--either no spec or the player wants to always see it > display it
				if playerButton.PlayerClass then
					self.Icon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
					self.Icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[playerButton.PlayerClass]))
				else
					self.Icon:SetTexture(nil)
				end
			end
		else -- "Spec"
			if playerButton.PlayerSpecName then
				self.Icon:SetTexture(Data.Classes[playerButton.PlayerClass][playerButton.PlayerSpecName].specIcon)
			end
		end

		local width = self:GetWidth()
		local height = self:GetHeight()
		if width and height and width > 0 and height > 0 then
			self:CropImage(self:GetWidth(), self:GetHeight())
		end
	end


	frame.ApplyAllSettings = function(self)
		self:Show()
		self:SetSpecAndRole()
	end
end

function class:AttachToPlayerButton(playerButton)
	playerButton.Class = attachToPlayerButton(playerButton, "Class")
end

function spec:AttachToPlayerButton(playerButton)
	playerButton.Spec = attachToPlayerButton(playerButton, "Spec")
end