local AddonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L


local defaultSettings = {
	Enabled = false,
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

local castBar = BattleGroundEnemies:NewModule("CastBar", "CastBar", nil, defaultSettings, nil, events)


function castBar:AttachToPlayerButton(playerButton)
-- Covenant Icon
	playerButton.CastBar = CreateFrame("StatusBar", nil, playerButton, "ArenaCastingBarFrameTemplate")
	CastingBarFrame_OnLoad(playerButton.CastBar, "fake") --set a fake unit to avoid The error in the onupdate script CastingBarFrame_OnUpdate which gets set by the template
	
	--when unitID changes
	playerButton.CastBar.NewUnitID = function(self, unitID)
		CastingBarFrame_SetUnit(self, unitID);
	end

	playerButton.CastBar.Reset = function(self)
		CastingBarFrame_SetUnit(self, nil)
	end

	playerButton.CastBar.Disable = function(self)
		CastingBarFrame_SetUnit(self, nil)
	end

	playerButton.CastBar.Enable = function(self)
		self:Hide()

		local unitID = playerButton:GetUnitID()
		CastingBarFrame_SetUnit(playerButton.CastBar, unitID)
	end
end





		



	
		
	