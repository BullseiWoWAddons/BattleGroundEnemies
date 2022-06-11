
local BattleGroundEnemies = BattleGroundEnemies
local AddonName, Data = ...
local GetTime = GetTime

local AddonName, Data = ...
local L = Data.L

local defaultSettings = {
	Points = {
		{
			Point = "TOPLEFT",
			RelativeFrame = "Level",
			RelativePoint = "TOPRIGHT",
		},
		{
			Point = "BOTTOMLEFT",
			RelativeFrame = "Button",
			RelativePoint = "BOTTOMLEFT",
		}
	},
	Text = {
		Fontsize = 13,
		Outline = "",
		Textcolor = {1, 1, 1, 1}, 
		EnableTextshadow = true,
		TextShadowcolor = {0, 0, 0, 1},
	},
	ConvertCyrillic = true,
	ShowRealmnames = true
}

local options = function(location) 
	return {

		TextSettings = {
			type = "group",
			name = "",
			--desc = L.TrinketSettings_Desc,
			inline = true,
			order = 4,
			get = function(option)
				return Data.GetOption(location.Text, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.Text, option, ...)
			end,
			args = Data.AddNormalTextSettings(location.Text)
		},
	}
end

local events = {"OnNewPlayer"}

local healthBar = BattleGroundEnemies:NewModule("Name", "Name", 3, defaultSettings, options, events)

function healthBar:AttachToPlayerButton(playerButton)
	playerButton.Name = BattleGroundEnemies.MyCreateFontString(playerButton)
	playerButton.Name:SetJustifyH("LEFT")

	function playerButton.Name:OnNewPlayer()
		local playerName = playerButton.PlayerName
		
		local name, realm = strsplit( "-", playerName, 2)
			
		if self.config.ConvertCyrillic then
			playerName = ""
			for i = 1, name:utf8len() do
				local c = name:utf8sub(i,i)

				if Data.CyrillicToRomanian[c] then
					playerName = playerName..Data.CyrillicToRomanian[c]
					if i == 1 then
						playerName = playerName:gsub("^.",string.upper) --uppercase the first character
					end
				else
					playerName = playerName..c
				end
			end
			--self.DisplayedName = self.DisplayedName:gsub("-.",string.upper) --uppercase the realm name
			name = playerName
			if realm then
				playerName = playerName.."-"..realm
			end
		end
		
		if self.config.ShowRealmnames then
			name = playerName
		end
		
		self:SetText(name)
		self.DisplayedName = name
	end

	function playerButton.Name:ApplyAllSettings()
		local config = self.config
		-- name
		self:SetTextColor(unpack(config.Text.Textcolor))
		self:ApplyFontStringSettings(config.Text)
		self:SetName()
	end
end










-- on new player on unit




		
		
		-- name
		