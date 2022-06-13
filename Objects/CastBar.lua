local AddonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L
local CastingBarFrame_SetUnit = CastingBarFrame_SetUnit


local defaultSettings = {
	Enabled = true,
	Parent = "Button",
	Points = {
		{
			Point = "TOPRIGHT",
			RelativeFrame = "Button",
			RelativePoint = "TOPLEFT",
		},
	},
	Width = 80,
	Height = 14
}

local flags = {
	Height = "Variable",
	Width = "Variable"
}

local events = {"NewUnitID"}

local castBar = BattleGroundEnemies:NewModule("CastBar", "CastBar", flags, defaultSettings, nil, nil)

function castBar:AttachToPlayerButton(playerButton)
-- Covenant Icon
	playerButton.CastBar = CreateFrame("StatusBar", nil, playerButton, "ArenaCastingBarFrameTemplate")

	--when unitID changes
	
	playerButton.CastBar.NewUnitID = function(self, unitID)
		CastingBarFrame_SetUnit(self, unitID, false, false);
	end

	playerButton.CastBar.Reset = function(self)
		self:UnregisterAllEvents()
	end

	playerButton.CastBar.ApplyAllSettings = function(self)
		self:Show()
	end

	playerButton.CastBar.Disable = function(self)
		self:UnregisterAllEvents()
	end
end





		



	
		
	