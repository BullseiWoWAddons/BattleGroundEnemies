---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)
---@class BattleGroundEnemies
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L
local MaxLevel = GetMaxPlayerLevel()


local generalDefaults = {
	OnlyShowIfNotMaxLevel = true,
}

local defaultSettings = {
	Enabled = false,
	Parent = "healthBar",
	UseButtonHeightAsHeight = true,
	ActivePoints = 1,
	Points = {
		{
			Point = "TOPLEFT",
			RelativeFrame = "Covenant",
			RelativePoint = "TOPRIGHT",
			OffsetX = 2,
			OffsetY = 2
		}
	},
	Text = {
		FontSize = 18,
		JustifyH = "LEFT"
	}
}

local generalOptions = function (location)
	return {
		OnlyShowIfNotMaxLevel = {
			type = "toggle",
			name = L.LevelText_OnlyShowIfNotMaxLevel,
			order = 2
		}
	}
end

local options = function(location)
	return {
		LevelTextTextSettings = {
			type = "group",
			name = L.Text,
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

local level = BattleGroundEnemies:NewButtonModule({
	moduleName = "Level",
	localizedModuleName = LEVEL,
	defaultSettings = defaultSettings,
	generalDefaults = generalDefaults,
	options = options,
	generalOptions = generalOptions,
	events = {"UnitIdUpdate"},
	enabledInThisExpansion = true,
	attachSettingsToButton = true
})

function level:AttachToPlayerButton(playerButton)
	local fs = BattleGroundEnemies.MyCreateFontString(playerButton)

	function fs:DisplayLevel()
		if (not self.config.OnlyShowIfNotMaxLevel or (playerButton.PlayerLevel and playerButton.PlayerLevel < MaxLevel)) then
			self:SetText(MaxLevel - 1) -- to set the width of the frame (the name shoudl have the same space from the role icon/spec icon regardless of level shown)
			self:SetWidth(0)
			self:SetText(playerButton.PlayerLevel)
		else
			self:SetText("")
		end
	end

	-- Level

	function fs:UnitIdUpdate(unitID)
		if unitID then
			self:SetLevel(UnitLevel(unitID))
		end
	end


	function fs:SetLevel(level)
		if not playerButton.PlayerLevel or level ~= playerButton.PlayerLevel then
			playerButton.PlayerLevel = level
			
		end
		self:DisplayLevel()
	end

	function fs:ApplyAllSettings()
		if not self.config then return end
		self:ApplyFontStringSettings(self.config.Text)
		local playerDetails = playerButton.PlayerDetails
		if not playerDetails then return end
		if playerDetails.PlayerLevel then self:SetLevel(playerDetails.PlayerLevel) end --for testmode
		self:DisplayLevel()
	end
	playerButton.Level = fs
	return playerButton.Level
end