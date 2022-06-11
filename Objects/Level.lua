local AddonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L
local GetTime = GetTime
local MaxLevel = GetMaxPlayerLevel()


local IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IsTBCC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

local defaultSettings = {
	Level = {
		OnlyShowIfNotMaxLevel = true,
		Text = {
			Fontsize = 18,
			Outline = "",
			Textcolor = {1, 1, 1, 1},
			EnableTextshadow = false,
			TextShadowcolor = {0, 0, 0, 1}
		}
	},
}

local options = function(location) 
	return {
		Points = {
			{
				Point = "TOPLEFTT",
				relativeFrame = "Covenant",
				relativePoint = "TOPRIGHT",
				offsetX = 2,
				offsetY = 2
			}
		},
		OnlyShowIfNotMaxLevel = {
			type = "toggle",
			name = L.LevelText_OnlyShowIfNotMaxLevel,
			order = 2
		},
		LevelTextTextSettings = {
			type = "group",
			name = "",
			--desc = L.TrinketSettings_Desc,
			get = function(option)
				return Data.GetOption(location.Text, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.Text, option, ...)
			end,
			inline = true,
			order = 3,
			args = Data.AddNormalTextSettings(location.Text)
		}
	}
end

local events = {"AllyNewUnitID", "EnemyHasUnitID", "OnNewPlayer", "PlayerButtonSizeChanged"}

local Level = BattleGroundEnemies:NewModule("Level", "Level", 2, defaultSettings, options, events)

function Level:AttachToPlayerButton(playerButton)
	local fs = BattleGroundEnemies.MyCreateFontString(playerButton)
	fs:SetPoint("TOPLEFT", playerButton.Covenant, "TOPRIGHT", 2, 2)
	fs:SetJustifyH("LEFT")


	function fs:DisplayLevel()
		if self.config.Enabled and (not self.config.OnlyShowIfNotMaxLevel or (playerButton.PlayerLevel and playerButton.PlayerLevel < MaxLevel)) then
			self:SetText(MaxLevel - 1) -- to set the width of the frame (the name shoudl have the same space from the role icon/spec icon regardless of level shown)
			self:SetWidth(0)
			self:SetText(self.PlayerLevel)
		else
			self:SetWidth(0.01) --we do that because the name is anhored right to the level and with this method the name moves more towards the edge
		end
	end

	-- Level

	function fs:OnNewPlayer()
		if playerButton.PlayerLevel then self:SetLevel(playerButton.PlayerLevel) end --for testmode
	end

	function fs:EnemyHasUnitID(unitID)
		self:SetLevel(UnitLevel(unitID))
	end

	
	function fs:SetLevel(level)
		if not playerButton.PlayerLevel or level ~= playerButton.PlayerLevel then
			self.PlayerLevel = level
			self:DisplayLevel()
		end
	end

	function fs:PlayerButtonSizeChanged(width, height)
		fs:SetHeight(height)
		self:DisplayLevel()
	end

	function fs:SetPosition()
		BattleGroundEnemies.SetBasicPosition(self, playerButton.bgSizeConfig.Level_BasicPoint, playerButton.bgSizeConfig.Level_RelativeTo, playerButton.bgSizeConfig.Level_RelativePoint, playerButton.bgSizeConfig.Level_OffsetX)
	end
	
	function fs:Reset()
		return
	end
	
	function fs:ApplyAllSettings()
		-- level
		self:ApplyFontStringSettings(self.config.Text)
		self:DisplayLevel()
	end
	playerButton.Level = fs
end

