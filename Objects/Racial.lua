local AddonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L

local GetTime = GetTime

local IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IsTBCC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

local defaultSettings = {
	Width = 28,
	Points = {
		{
			Point = "TOPLEFT",
			RelativeFrame = "Trinket",
			RelativePoint = "TOPRIGHT",
			OffsetX = 1
		},
		{
			Point = "BOTTOMLEFT",
			RelativeFrame = "Trinket",
			RelativePoint = "BOTTOMRIGHT",
			OffsetX = 1
		}
	},
	Cooldown = {
		ShowNumbers = true,
		Fontsize = 12,
		Outline = "OUTLINE",
		EnableTextshadow = false,
		TextShadowcolor = {0, 0, 0, 1},
	},
	Filtering_Enabled = false,
	Filtering_Filterlist = {}, --key = spellID, value = spellName or false
}

local options = function(location) 
	return {
		CooldownTextSettings = {
			type = "group",
			name = L.Countdowntext,
			--desc = L.TrinketSettings_Desc,
			inline = true,
			get = function(option)
				return Data.GetOption(location.Cooldown, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.Cooldown, option, ...)
			end,
			order = 1,
			args = Data.AddCooldownSettings(location.Cooldown)
		},
		RacialFilteringSettings = {
			type = "group",
			name = FILTER,
			desc = L.RacialFilteringSettings_Desc,
			--inline = true,
			order = 2,
			args = {
				Filtering_Enabled = {
					type = "toggle",
					name = L.Filtering_Enabled,
					desc = L.RacialFiltering_Enabled_Desc,
					width = 'normal',
					order = 1
				},
				Fake = Data.AddHorizontalSpacing(2),
				Filtering_Filterlist = {
					type = "multiselect",
					name = L.Filtering_Filterlist,
					desc = L.RacialFiltering_Filterlist_Desc,
					disabled = function() return not location.Filtering_Enabled end,
					get = function(option, key)
						for spellID in pairs(Data.RacialNameToSpellIDs[key]) do
							return location.Filtering_Filterlist[spellID]
						end
					end,
					set = function(option, key, state) -- value = spellname
						for spellID in pairs(Data.RacialNameToSpellIDs[key]) do
							location.Filtering_Filterlist[spellID] = state or nil
						end
					end,
					values = Data.Racialnames,
					order = 3
				}
			}
		}
	}
end

local events = {"SPELL_CAST_SUCCESS"}

local racial = BattleGroundEnemies:NewModule("Racial", "Racial", 3, defaultSettings, options, events)

function racial:AttachToPlayerButton(playerButton)

	local frame = CreateFrame("frame", nil, playerButton)
	-- trinket
	frame:HookScript("OnEnter", function(self)
		if self.SpellID then
			BattleGroundEnemies:ShowTooltip(self, function() 
				GameTooltip:SetSpellByID(self.SpellID)
			end)
		end
	end)
	
	frame:HookScript("OnLeave", function(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end)
	
	function frame:Reset()
		self:SetWidth(0.01)
		self.SpellID = false
		self.Icon:SetTexture(nil)
		self.Cooldown:Clear()	--reset Trinket Cooldown
	end
	
	function frame:ApplyAllSettings()
		local moduleSettings = self.config
		self.Cooldown:ApplyCooldownSettings(moduleSettings.Cooldown.ShowNumbers, true, true, {0, 0, 0, 0.5})
		self.Cooldown.Text:ApplyFontStringSettings(moduleSettings.Cooldown)
	end

	
	frame.Icon = frame:CreateTexture()
	frame.Icon:SetAllPoints()
	frame:SetScript("OnSizeChanged", function(self, width, height)
		BattleGroundEnemies.CropImage(self.Icon, width, height)
	end)
	
	frame.Cooldown = BattleGroundEnemies.MyCreateCooldown(frame)
	
	function frame:RacialCheck(spellID)
		if not Data.RacialSpellIDtoCooldown[spellID] then return end
		local config = frame.config
		local insi = playerButton.Trinket
		

		if Data.RacialSpellIDtoCooldown[spellID].trinketCD and not (insi.SpellID == 336128) and insi.SpellID and insi.Cooldown:GetCooldownDuration() < Data.RacialSpellIDtoCooldown[spellID].trinketCD * 1000 then
			insi.Cooldown:SetCooldown(GetTime(), Data.RacialSpellIDtoCooldown[spellID].trinketCD)
		end
		
		if config.RacialFiltering_Enabled and not config.RacialFiltering_Filterlist[spellID] then return end
		
		self.SpellID = spellID
		self.Icon:SetTexture(GetSpellTexture(spellID))
		self.Cooldown:SetCooldown(GetTime(), Data.RacialSpellIDtoCooldown[spellID].cd)
	end

	function frame:SPELL_CAST_SUCCESS(srcName, destName, spellID)
		self:RacialCheck(spellID)
	end
	playerButton.Racial = frame
end


