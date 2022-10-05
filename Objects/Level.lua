local AddonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L
local MaxLevel = GetMaxPlayerLevel()


local defaultSettings = {
	Enabled = false,
	Parent = "healthBar",
	Points = {
		{
			Point = "TOPLEFT",
			RelativeFrame = "Covenant",
			RelativePoint = "TOPRIGHT",
			OffsetX = 2,
			OffsetY = 2
		}
	},
	OnlyShowIfNotMaxLevel = true,
	Text = {
		FontSize = 18,
		FontOutline = "",
		FontColor = {1, 1, 1, 1},
		EnableShadow = false,
		ShadowColor = {0, 0, 0, 1},
		JustifyH = "LEFT"
	}
}

local options = function(location)
	return {
		OnlyShowIfNotMaxLevel = {
			type = "toggle",
			name = L.LevelText_OnlyShowIfNotMaxLevel,
			order = 2
		},
		LevelTextTextSettings = {
			type = "group",
			name = L.LevelTextSettings,
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

local flags = {
	Height = "Dynamic",
	Width = "Dynamic"
}

local events = {"NewUnitID", "OnNewPlayer", "PlayerButtonSizeChanged"}

local Level = BattleGroundEnemies:NewButtonModule("Level", "Level", flags, defaultSettings, options, events)

function Level:AttachToPlayerButton(playerButton)
	local fs = BattleGroundEnemies.MyCreateFontString(playerButton)

	function fs:DisplayLevel()
		if (not self.config.OnlyShowIfNotMaxLevel or (playerButton.PlayerLevel and playerButton.PlayerLevel < MaxLevel)) then
			self:SetText(MaxLevel - 1) -- to set the width of the frame (the name shoudl have the same space from the role icon/spec icon regardless of level shown)
			self:SetWidth(0)
			self:SetText(self.PlayerLevel)
		end
	end

	-- Level

	function fs:OnNewPlayer()
		if playerButton.PlayerLevel then self:SetLevel(playerButton.PlayerLevel) end --for testmode
	end

	function fs:NewUnitID(unitID)
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

	function fs:ApplyAllSettings()
		-- level
		self:ApplyFontStringSettings(self.config.Text)
		self:DisplayLevel()
	end
	playerButton.Level = fs
end

