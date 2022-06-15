local AddonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local LSM = LibStub("LibSharedMedia-3.0")
local L = Data.L
local GetTime = GetTime

local IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IsTBCC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC


local defaultSettings = {
	Enabled = true,
	Texture = 'UI-StatusBar',
	Background = {0, 0, 0, 0.66},
	HealthPrediction_Enabled = true,
	Points = {
		{
			Point = "BOTTOMLEFT",
			RelativeFrame = "Power",
			RelativePoint = "TOPLEFT",
		},
		{
			Point = "TOPRIGHT",
			RelativeFrame = "Button",
			RelativePoint = "TOPRIGHT",
		}
	}
}

local options = function(location) 
	return {
		Texture = {
			type = "select",
			name = L.BarTexture,
			desc = L.HealthBar_Texture_Desc,
			dialogControl = 'LSM30_Statusbar',
			values = AceGUIWidgetLSMlists.statusbar,
			width = "normal",
			order = 1
		},
		Fake = Data.AddHorizontalSpacing(2),
		Background = {
			type = "color",
			name = L.BarBackground,
			desc = L.HealthBar_Background_Desc,
			hasAlpha = true,
			width = "normal",
			order = 3
		},
		Fake1 = Data.AddVerticalSpacing(4),
		HealthPrediction_Enabled = {
			type = "toggle",
			name = COMPACT_UNIT_FRAME_PROFILE_DISPLAYHEALPREDICTION,
			width = "normal",
			order = 5,
		}
	}
end

local flags = {
	Height = "Variable",
	Width = "Fixed"
}

local events = {"UNIT_HEALTH", "OnNewPlayer"}

local healthBar = BattleGroundEnemies:NewModule("healthBar", "HealthBar", nil, defaultSettings, options, events)

function healthBar:AttachToPlayerButton(playerButton)
	playerButton.healthBar = CreateFrame('StatusBar', nil, playerButton)
	playerButton.healthBar:SetPoint('BOTTOMLEFT', playerButton, "TOPLEFT")
	playerButton.healthBar:SetPoint('TOPRIGHT', playerButton, "TOPRIGHT")
	playerButton.healthBar:SetMinMaxValues(0, 1)

	playerButton.myHealPrediction = playerButton.healthBar:CreateTexture(nil, "BORDER", nil, 5)
	playerButton.myHealPrediction:ClearAllPoints();
	playerButton.myHealPrediction:SetColorTexture(1,1,1);
	playerButton.myHealPrediction:SetGradient("VERTICAL", 8/255, 93/255, 72/255, 11/255, 136/255, 105/255);
	playerButton.myHealPrediction:SetVertexColor(0.0, 0.659, 0.608);


	playerButton.myHealAbsorb = playerButton.healthBar:CreateTexture(nil, "ARTWORK", nil, 1)
	playerButton.myHealAbsorb:ClearAllPoints();
	playerButton.myHealAbsorb:SetTexture("Interface\\RaidFrame\\Absorb-Fill", true, true);

	playerButton.myHealAbsorbLeftShadow = playerButton.healthBar:CreateTexture(nil, "ARTWORK", nil, 1)
	playerButton.myHealAbsorbLeftShadow:ClearAllPoints();

	playerButton.myHealAbsorbRightShadow = playerButton.healthBar:CreateTexture(nil, "ARTWORK", nil, 1)
	playerButton.myHealAbsorbRightShadow:ClearAllPoints();

	playerButton.otherHealPrediction = playerButton.healthBar:CreateTexture(nil, "BORDER", nil, 5)
	playerButton.otherHealPrediction:SetColorTexture(1,1,1);
	playerButton.otherHealPrediction:SetGradient("VERTICAL", 11/255, 53/255, 43/255, 21/255, 89/255, 72/255);


	playerButton.totalAbsorbOverlay = playerButton.healthBar:CreateTexture(nil, "BORDER", nil, 6)
	playerButton.totalAbsorbOverlay:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true);	--Tile both vertically and horizontally
	playerButton.totalAbsorbOverlay.tileSize = 20;

	playerButton.totalAbsorb = playerButton.healthBar:CreateTexture(nil, "BORDER", nil, 5)
	playerButton.totalAbsorb:SetTexture("Interface\\RaidFrame\\Shield-Fill");
	playerButton.totalAbsorb.overlay = playerButton.totalAbsorbOverlay
	playerButton.totalAbsorbOverlay:SetAllPoints(playerButton.totalAbsorb);

	playerButton.overAbsorbGlow = playerButton.healthBar:CreateTexture(nil, "ARTWORK", nil, 2)
	playerButton.overAbsorbGlow:SetTexture("Interface\\RaidFrame\\Shield-Overshield");
	playerButton.overAbsorbGlow:SetBlendMode("ADD");
	playerButton.overAbsorbGlow:SetPoint("BOTTOMLEFT", playerButton.healthBar, "BOTTOMRIGHT", -7, 0);
	playerButton.overAbsorbGlow:SetPoint("TOPLEFT", playerButton.healthBar, "TOPRIGHT", -7, 0);
	playerButton.overAbsorbGlow:SetWidth(16);
	playerButton.overAbsorbGlow:Hide()

	playerButton.overHealAbsorbGlow = playerButton.healthBar:CreateTexture(nil, "ARTWORK", nil, 2)
	playerButton.overHealAbsorbGlow:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb");
	playerButton.overHealAbsorbGlow:SetBlendMode("ADD");
	playerButton.overHealAbsorbGlow:SetPoint("BOTTOMRIGHT", playerButton.healthBar, "BOTTOMLEFT", 7, 0);
	playerButton.overHealAbsorbGlow:SetPoint("TOPRIGHT", playerButton.healthBar, "TOPLEFT", 7, 0);
	playerButton.overHealAbsorbGlow:SetWidth(16);
	playerButton.overHealAbsorbGlow:Hide()


	playerButton.healthBar.Background = playerButton.healthBar:CreateTexture(nil, 'BACKGROUND', nil, 2)
	playerButton.healthBar.Background:SetAllPoints()
	playerButton.healthBar.Background:SetTexture("Interface/Buttons/WHITE8X8")


	--	
	function playerButton.healthBar:UNIT_HEALTH(unitID)
		local config = playerButton.healthBar.config
		self:SetMinMaxValues(0, UnitHealthMax(unitID))
		self:SetValue(UnitHealth(unitID))


		--next wo lines are needed for CompactUnitFrame_UpdateHealPrediction()
		self.displayedUnit = unitID
		self.optionTable = {displayHealPrediction = config.HealthPrediction_Enabled}
		if not (IsTBCC or IsClassic) then CompactUnitFrame_UpdateHealPrediction(playerButton) end
	end

	function playerButton.healthBar:OnNewPlayer()
		local color = playerButton.PlayerClassColor
		self:SetStatusBarColor(color.r,color.g,color.b)
		self:SetMinMaxValues(0, 1)
		self:SetValue(1)
		
		playerButton.totalAbsorbOverlay:Hide()
		playerButton.totalAbsorb:Hide()
	end

	function playerButton.healthBar:ApplyAllSettings()
		local config = self.config
		self:SetStatusBarTexture(LSM:Fetch("statusbar", config.Texture))--self.healthBar:SetStatusBarTexture(137012)
		self.Background:SetVertexColor(unpack(config.Background))
	end
end










-- on new player on unit



