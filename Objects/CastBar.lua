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


local CastingBarFrame_OnLoad = CastingBarFrame_OnLoad or CastingBarMixin.OnLoad --CastingBarMixin is used in Dragonflight 10.0
local CastingBarFrame_SetUnit = CastingBarFrame_SetUnit or CastingBarMixin.SetUnit
local CreateFrame = CreateFrame

local castBar = BattleGroundEnemies:NewButtonModule({
	moduleName = "CastBar",
	localizedModuleName = L.CastBar,
	defaultSettings = defaultSettings,
	options = nil,
	events = {"NewUnitID"},
	expansions = "All"
})

LoadAddOn("Blizzard_ArenaUI")

function castBar:AttachToPlayerButton(playerButton)
-- Covenant Icon
	playerButton.CastBar = CreateFrame("StatusBar", nil, playerButton, "ArenaCastingBarFrameTemplate")
	playerButton.CastBar.Icon:SetPoint("RIGHT", playerButton.CastBar, "LEFT", -5, 0)
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











