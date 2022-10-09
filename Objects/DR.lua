local AddonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L

local LSM = LibStub("LibSharedMedia-3.0")


local GetSpellTexture = GetSpellTexture
local CreateFrame = CreateFrame
local BackdropTemplateMixin = BackdropTemplateMixin
local GameTooltip = GameTooltip

local IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC



local DRList = LibStub("DRList-1.0")

local defaultSettings = {
	Enabled = true,
	Parent = "Button",
	DisplayType = "Frame",
	Cooldown = {
		ShowNumber = true,
		FontSize = 12,
		FontOutline = "OUTLINE",
		EnableShadow = false,
		ShadowColor = {0, 0, 0, 1},
	},
	Filtering_Enabled = false,
	Filtering_Filterlist = {},
}

local options = function(location)
	return {
		ContainerSettings = {
			type = "group",
			name = L.ContainerIconSettings,
			order = 1,
			get = function(option)
				return Data.GetOption(location.Container, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.Container, option, ...)
			end,
			args = Data.AddContainerSettings(),
		},
		DisplayType = {
			type = "select",
			name = L.DisplayType,
			desc = L.DrTracking_DisplayType_Desc,
			values = Data.DisplayType,
			order = 2
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
			order = 3,
			args = Data.AddCooldownSettings(location.Cooldown)
		},
		Fake1 = Data.AddVerticalSpacing(6),
		FilteringSettings = {
			type = "group",
			name = FILTER,
			--desc = L.DrTrackingFilteringSettings_Desc,
			--inline = true,
			order = 4,
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
					disabled = function() return not location.Filtering_Enabled end,
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

local flags = {
	Height = "Fixed",
	Width = "Dynamic"
}

local dRTracking = BattleGroundEnemies:NewButtonModule({
	moduleName = "DRTracking",
	localizedModuleName = "DRTracking",
	flags = flags,
	defaultSettings = defaultSettings,
	options = options,
	events = {"AuraRemoved"},
	expansions = "All"
})


function dRTracking:AttachToPlayerButton(playerButton)

	local frame = CreateFrame("frame", nil, playerButton, BackdropTemplateMixin and "BackdropTemplate")

	--frame:SetBackdropColor(0, 0, 0, 0)
	frame.DRFrames = {}

	function frame:ApplyAllSettings()
		self:UpdateBackdrop(self.config.Container.BorderThickness)
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

	function frame:SetWidthOfAuraFrames(height)
		local borderThickness = self.config.Container.BorderThickness
		for drCategorie, drFrame in pairs(self.DRFrames) do
			drFrame:SetWidth(height - borderThickness * 2)
		end
	end



	function frame:DisplayDR(drCat, spellID, spellName)
		local drFrame = self.DRFrames[drCat]
		if not drFrame then  --create a new frame for this categorie

			drFrame = CreateFrame("Frame", nil, self, BackdropTemplateMixin and "BackdropTemplate")
			drFrame.Cooldown = BattleGroundEnemies.MyCreateCooldown(drFrame)

			drFrame.Cooldown:SetScript("OnCooldownDone", function()
				drFrame:Remove()
			end)
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

				self.Cooldown:ApplyCooldownSettings(frame.config.Cooldown, false, false)
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
				if frame.config.DisplayType == "Frame" then
					self.SetStatus = drFrameUpdateStatusBorder
				else
					self.SetStatus = drFrameUpdateStatusText
				end
			end

			drFrame:SetWidth(playerButton.bgSizeConfig.BarHeight - frame.config.Container.BorderThickness * 2)

			drFrame:SetBackdrop({
				bgFile = "Interface/Buttons/WHITE8X8", --drawlayer "BACKGROUND"
				edgeFile = 'Interface/Buttons/WHITE8X8', --drawlayer "BORDER"
				edgeSize = 1
			})

			drFrame:SetBackdropColor(0, 0, 0, 0)
			drFrame:SetBackdropBorderColor(0, 0, 0, 0)

			drFrame.Icon = drFrame:CreateTexture(nil, "BORDER", nil, -1) -- -1 to make it behind the SetBackdrop bg
			drFrame.Icon:SetAllPoints()



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
		local config = self.config.Container
		local spacing = config.HorizontalSpacing
		local borderThickness = config.BorderThickness
		local growLeft = config.HorizontalGrowDirection == "leftwards"
		local barHeight = playerButton.bgSizeConfig.BarHeight
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
		--print("UpdateBackdrop")
		-- self:SetBackdrop(nil)
		-- self:SetBackdrop({
		-- 	bgFile = "Interface/Buttons/WHITE8X8", --drawlayer "BACKGROUND"
		-- 	edgeFile = 'Interface/Buttons/WHITE8X8', --drawlayer "BORDER"
		-- 	edgeSize = borderThickness
		-- })
		-- self:SetBackdropColor(0, 0, 0, 0)
		-- self:SetBackdropBorderColor(unpack(self.config.Container.Color))
		self:SetBackdrop(nil)
		--print("Border", self.config.Container.Border)
		self:SetBackdrop({edgeFile = LSM:Fetch("border", self.config.Container.Border)  or 'Interface/Buttons/WHITE8X8',
			bgFile=[[Interface\DialogFrame\UI-DialogBox-Background-Dark]],
			tile = true, tileSize = 16, edgeSize = 16,
			insets = { left = 0, right = 0, top = 0, bottom = 0 }})

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
