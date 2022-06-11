local AddonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L

local IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IsTBCC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

local DRList = LibStub("DRList-1.0")

local defaultSettings = {
	HorizontalSpacing = 1,
	GrowDirection = "leftwards",
	Container_Color = {0, 0, 1, 1},
	Container_BorderThickness = 1,
	BasicPosition = {
		BasicPoint = "RIGHT",
		RelativeTo = "Button",
		RelativePoint = "LEFT",
		OffsetX = 1,
	},
	DisplayType = "Countdowntext",
	Cooldown = {
		ShowNumbers = true,
		Fontsize = 12,
		Outline = "OUTLINE",
		EnableTextshadow = false,
		TextShadowcolor = {0, 0, 0, 1},
	},
	Filtering_Enabled = false,
	Filtering_Filterlist = {},
}

local options = function(location)
	return {
		HorizontalSpacing = {
			type = "range",
			name = L.DrTracking_Spacing,
			desc = L.DrTracking_Spacing_Desc,
			min = 0,
			max = 10,
			step = 1,
			order = 3
		},
		Container_Color = {
			type = "color",
			name = L.Container_Color,
			desc = L.DrTracking_Container_Color_Desc,
			hasAlpha = true,
			order = 4
		},
		Container_BorderThickness = {
			type = "range",
			name = L.BorderThickness,
			min = 1,
			max = 6,
			step = 1,
			order = 5
		},
		DisplayType = {
			type = "select",
			name = L.DisplayType,
			desc = L.DrTracking_DisplayType_Desc,
			values = Data.DisplayType,
			order = 6
		},
		GrowDirection = {
			type = "select",
			name = L.VerticalGrowdirection,
			desc = L.VerticalGrowdirection_Desc,
			values = Data.HorizontalDirections,
			order = 7
		},
		CooldownTextSettings = {
			type = "group",
			name = L.Countdowntext,
			--desc = L.TrinketSettings_Desc,
			get = function(option)
				return Data.GetOption(location.Cooldown, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.Cooldown, option, ...)
			end,
			order = 8,
			args = Data.AddCooldownSettings(location.Cooldown)
		},
		Fake1 = Data.AddVerticalSpacing(6),
		FilteringSettings = {
			type = "group",
			name = FILTER,
			--desc = L.DrTrackingFilteringSettings_Desc,
			--inline = true,
			order = 9,
			args = {
				Filtering_Enabled = {
					type = "toggle",
					name = L.Filtering_Enabled,
					desc = L.DrTrackingFiltering_Enabled_Desc,
					width = 'normal',
					order = 1
				},
				Filtering_Filterlist = {
					type = "multiselect",
					name = L.Filtering_Filterlist,
					desc = L.DrTrackingFiltering_Filterlist_Desc,
					disabled = function() return not location.DrTrackingFiltering_Enabled end,
					get = function(option, key)
						return location.Filtering_Filterlist[key]
					end,
					set = function(option, key, state) -- key = category name
						location.Filtering_Filterlist[key] = state or nil
					end,
					values = Data.DrCategorys,
					order = 2
				}
			}
		}
	}
end

local dRstates = {
	[1] = { 0, 1, 0, 1}, --green (next cc in DR time will be only half duration)
	[2] = { 1, 1, 0, 1}, --yellow (next cc in DR time will be only 1/4 duration)
	[3] = { 1, 0, 0, 1}, --red (next cc in DR time will not apply, player is immune)
}

local function drFrameUpdateStatusBorder(drFrame)
	drFrame:SetBackdropBorderColor(unpack(dRstates[drFrame.status] or dRstates[3]))
end

local function drFrameUpdateStatusText(drFrame)
	drFrame.Cooldown.Text:SetTextColor(unpack(dRstates[drFrame.status] or dRstates[3]))
end	


local events = {"AuraRemoved"}

local dRTracking = BattleGroundEnemies:NewModule("DRTracking", "DRTracking", 3, defaultSettings, options, events)


function dRTracking:AttachToPlayerButton(playerButton)

	local frame = CreateFrame("frame", nil, playerButton)

	Mixin(frame, BackdropTemplateMixin)
	frame:SetPoint("TOPRIGHT", playerButton, "TOPLEFT", -1, 0)
	frame:SetPoint("BOTTOMRIGHT", playerButton, "BOTTOMLEFT", -1, 0)
	frame:SetBackdropColor(0, 0, 0, 0)
	frame.DRFrames = {}

	function frame:ApplyAllSettings()
		self:UpdateBackdrop(self.config.Container_BorderThickness)
		self:SetPosition()
		self:DrPositioning()
		
		for drCategory, drFrame in pairs(self.DRFrames) do
			drFrame:ApplyDrFrameSettings()
			drFrame:ChangeDisplayType()
		end	
	end
	
	function frame:Reset()
		for drCategory, drFrame in pairs(self.DRFrames) do
			drFrame.Cooldown:Clear()
			drFrame:Remove()
		end	
	end
	
	function frame:SetPosition()
		BattleGroundEnemies.SetBasicPosition(self, self.config.BasicPosition.BasicPoint, self.config.BasicPosition.RelativeTo, self.config.BasicPosition.RelativePoint, self.config.BasicPosition.OffsetX)
	end


	function frame:SetWidthOfAuraFrames(height)
		local borderThickness = self.config.Container_BorderThickness
		for drCategorie, drFrame in pairs(self.DRFrames) do
			drFrame:SetWidth(height - borderThickness * 2)
		end
	end
	


	function frame:DisplayDR(drCat, spellID, spellName)
		local drFrame = self.DRFrames[drCat]
		if not drFrame then  --create a new frame for this categorie
			
			drFrame = CreateFrame("Frame", nil, self, BackdropTemplateMixin and "BackdropTemplate")

			drFrame:HookScript("OnEnter", function(self)
				BattleGroundEnemies:ShowTooltip(self, function() 
					if IsClassic then return end
					GameTooltip:SetSpellByID(self.SpellID)
				end)
			end)
			
			drFrame:HookScript("OnLeave", function(self)
				if GameTooltip:IsOwned(self) then
					GameTooltip:Hide()
				end
			end)
			
			drFrame.Container = self
			
			drFrame.ApplyDrFrameSettings = function(self)
				local conf = playerButton.config
				
				self.Cooldown:ApplyCooldownSettings(conf.Cooldown.ShowNumbers, false, false)
				self.Cooldown.Text:ApplyFontStringSettings(conf.Cooldown)
			end



			drFrame.ChangeDisplayType = function(self)
				self:SetDisplayType()
				
				--reset settings
				self.Cooldown.Text:SetTextColor(1, 1, 1, 1)
				self:SetBackdropBorderColor(0, 0, 0, 0)
				if self.status ~= 0 then self:SetStatus() end
			end

			drFrame.IncreaseDRState = function(self)
				self.status = self.status + 1
				self:SetStatus()
			end

			drFrame.SetDisplayType = function(self)
				if playerButton.config.DisplayType == "Frame" then
					self.SetStatus = drFrameUpdateStatusBorder
				else
					self.SetStatus = drFrameUpdateStatusText
				end
			end
			
			drFrame:SetWidth(playerButton.config.BarHeight - frame.config.Container_BorderThickness * 2)

			drFrame:SetBackdrop({
				bgFile = "Interface/Buttons/WHITE8X8", --drawlayer "BACKGROUND"
				edgeFile = 'Interface/Buttons/WHITE8X8', --drawlayer "BORDER"
				edgeSize = 1
			})

			drFrame:SetBackdropColor(0, 0, 0, 0)
			drFrame:SetBackdropBorderColor(0, 0, 0, 0)

			drFrame.Icon = drFrame:CreateTexture(nil, "BORDER", nil, -1) -- -1 to make it behind the SetBackdrop bg
			drFrame.Icon:SetAllPoints()
			
			drFrame.Cooldown = BattleGroundEnemies.MyCreateCooldown(drFrame)
		
			drFrame.Cooldown:SetScript("OnCooldownDone", function()
				drFrame:Remove()
			end)

			drFrame.Remove = function()
				drFrame:Hide()
				drFrame.SpellID = false
				drFrame.status = 0
				self:DrPositioning() --self = DRContainer
			end
			
			drFrame.status = 0
			
			drFrame:SetDisplayType()
			drFrame:ApplyDrFrameSettings()
			
			drFrame:Hide()
			
			self.DRFrames[drCat] = drFrame
		end						
		
		if not drFrame:IsShown() then
			drFrame:Show()
			self:DrPositioning()
		end
		drFrame.SpellID = spellID

		drFrame.Icon:SetTexture(IsClassic and GetSpellTexture(DRList.spells[spellName].spellID) or GetSpellTexture(spellID))
		drFrame.Cooldown:SetCooldown(GetTime(), DRList:GetResetTime(drCat))
	end

	function frame:DrPositioning()
		local config = playerButton.bgSizeConfig
		local spacing = config.DrTracking_HorizontalSpacing
		local borderThickness = config.DrTracking_Container_BorderThickness
		local growLeft = config.DrTracking_GrowDirection == "leftwards"
		local barHeight = config.BarHeight
		local anchor = self
		local totalWidth = 0
		local point, relativePoint, offsetX
		self:Show()
		
		if growLeft then 
			point = "RIGHT"
			relativePoint = "LEFT"
			offsetX = -borderThickness
		else
			point = "LEFT"
			relativePoint = "RIGHT"
			offsetX = borderThickness
		end
	
		for categorie, drFrame in pairs(self.DRFrames) do
			if drFrame:IsShown() then
				drFrame:ClearAllPoints()
				if totalWidth == 0 then
					drFrame:SetPoint("TOP"..point, anchor, "TOP"..point, offsetX, -borderThickness)
					drFrame:SetPoint("BOTTOM"..point, anchor, "BOTTOM"..point, offsetX, borderThickness)
				else
					drFrame:SetPoint("TOP"..point, anchor, "TOP"..relativePoint, growLeft and -spacing or spacing, 0)
					drFrame:SetPoint("BOTTOM"..point, anchor, "BOTTOM"..relativePoint, growLeft and -spacing or spacing, 0)
				end
				anchor = drFrame
				totalWidth = totalWidth + spacing + barHeight - 2 * borderThickness
			end
		end
		if totalWidth == 0 then
			self:Hide()
			self:SetWidth(0.001)
		else
			totalWidth = totalWidth + 2 * borderThickness - spacing
			self:SetWidth(totalWidth)
		end
	end

	function frame:UpdateBackdrop(borderThickness)
		self:SetBackdrop(nil)
		self:SetBackdrop({
			bgFile = "Interface/Buttons/WHITE8X8", --drawlayer "BACKGROUND"
			edgeFile = 'Interface/Buttons/WHITE8X8', --drawlayer "BORDER"
			edgeSize = borderThickness
		})
		self:SetBackdropColor(0, 0, 0, 0)
		self:SetBackdropBorderColor(unpack(self.config.Container_Color))
		self:SetWidthOfAuraFrames(playerButton:GetHeight())
		self:DrPositioning()
	end

	function frame:AuraRemoved(spellID, spellName)
		local config = self.config
		--BattleGroundEnemies:Debug(operation, spellID)

		local drCat = DRList:GetCategoryBySpellID(IsClassic and spellName or spellID)

		if not drCat then return end

		local drTrackingEnabled = not config.Filtering_Enabled or config.Filtering_Filterlist[drCat]
					
		if drTrackingEnabled then
			self:DisplayDR(drCat, spellID, spellName)
			local drFrame = self.DRFrames[drCat]
				--BattleGroundEnemies:Debug("DR Problem")
			drFrame:IncreaseDRState()
		end
	end
	playerButton.DRTracking = frame
end
