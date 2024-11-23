---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)
---@class BattleGroundEnemies
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L

local LSM = LibStub("LibSharedMedia-3.0")


local GetSpellTexture = C_Spell and C_Spell.GetSpellTexture or GetSpellTexture
local GetSpellName = C_Spell and C_Spell.GetSpellName or GetSpellName

local CreateFrame = CreateFrame
local BackdropTemplateMixin = BackdropTemplateMixin
local GameTooltip = GameTooltip

local IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC



local DRList = LibStub("DRList-1.0")

local generalDefaults = {
	CustomCategoryIconsEnabled = false,
	CustomCategoryIcons = {},
	Filtering_Enabled = false,
	Filtering_Filterlist = {},
	DisplayType = "Frame",
}

local defaultSettings = {
	Enabled = true,
	Parent = "Button",
	ActivePoints = 1,
	IconSize = 20,
	Cooldown = {
		FontSize = 12,
	},
	Container = {
		UseButtonHeightAsSize = true,
		IconSize = 15,
		IconsPerRow = 10,
		HorizontalGrowDirection = "rightwards",
		HorizontalSpacing = 2,
		VerticalGrowdirection = "downwards",
		VerticalSpacing = 1,
	},
}


local generalOptions = function(location)
	local categories = DRList:GetCategories()
	local categoryoptions = {}
	local order = 1
	for engCategory, localCategory in pairs(categories) do
		categoryoptions[engCategory] = {
			type = "select",
			name = localCategory,
			values = function()
				local spells = {}

				for spellID, category in DRList:IterateSpellsByCategory(engCategory) do
					local iconID = GetSpellTexture(spellID)
					local spellName = GetSpellName(spellID)
					if iconID then
						spells[spellID] = string.format("|T%s:20|t %s", iconID, spellName) --https://wowwiki-archive.fandom.com/wiki/UI_escape_sequences
					end
				end
				spells[false] = false
				return spells
			end,
			sorting = function (a,b,c) --needs a numeric table with keys from 1 to ..., values are the keys for values function above
				local categorySpells = {}
				local function sortSpells(a,b)
					return a.name < b.name
				end

				for spellID, category in DRList:IterateSpellsByCategory(engCategory) do
					local spellName = GetSpellName(spellID)
					if spellName then
						table.insert(categorySpells, {
							spellId = spellID,
							name = spellName
						})
					end
				end
				table.sort(categorySpells, sortSpells)
				local sortedSpellNames = {} --key is spellID, value = key from values function return table
				for i = 1, #categorySpells do
					table.insert(sortedSpellNames, categorySpells[i].spellId)
				end
				table.insert(sortedSpellNames, 1, false)
				return sortedSpellNames
			end,
			get = function(option)
				return Data.GetOption(location.CustomCategoryIcons, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.CustomCategoryIcons, option, ...)
			end,
			order = order
		}
		order = order + 1
	end

	return {
		DisplayType = {
			type = "select",
			name = L.DisplayType,
			desc = L.DrTracking_DisplayType_Desc,
			values = Data.DisplayType,
			order = 1
		},
		CustomIconsSelect = {
			type = "group",
			name = L.Icons,
			order = 2,
			args = {
				CustomCategoryIconsEnabled = {
					type = "toggle",
					name = L.EnableCustomDRCategoryIcons,
					desc = L.EnableCustomDRCategoryIcons_Desc,
					order = 1
				},
				CustomCategoryIcons = {
					type = "group",
					name = "",
					inline = true,
					order = 2,
					args = categoryoptions,
					disabled = function ()
						return not location.CustomCategoryIconsEnabled
					end,
				}
			}
		},
		FilteringSettings = {
			type = "group",
			name = FILTER,
			--desc = L.DrTrackingFilteringSettings_Desc,
			--inline = true,
			order = 7,
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
					name = "",
					desc = L.DrTrackingFiltering_Filterlist_Desc,
					disabled = function() return not location.Filtering_Enabled end,
					get = function(option, key)
						return location.Filtering_Filterlist[key]
					end,
					set = function(option, key, state) -- key = category name
						location.Filtering_Filterlist[key] = state or nil
					end,
					values = DRList:GetCategories(),
					order = 2
				}
			}
		}
	}

end


local options = function(location)
	return {
		ContainerSettings = {
			type = "group",
			name = L.ContainerSettings,
			order = 4,
			get = function(option)
				return Data.GetOption(location.Container, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.Container, option, ...)
			end,
			args = Data.AddContainerSettings(location.Container),
		},
		CooldownTextSettings = {
			type = "group",
			name = L.Countdowntext,
			get = function(option)
				return Data.GetOption(location.Cooldown, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.Cooldown, option, ...)
			end,
			order = 5,
			args = Data.AddCooldownSettings(location.Cooldown)
		},
	}
end

local dRstates = {
	[1] = { 0, 1, 0, 1}, --green (next cc in DR time will be only half duration)
	[2] = { 1, 1, 0, 1}, --yellow (next cc in DR time will be only 1/4 duration)
	[3] = { 1, 0, 0, 1}, --red (next cc in DR time will not apply, player is immune)
}

local function drFrameUpdateStatusBorder(drFrame)
	drFrame:SetBackdropBorderColor(unpack(dRstates[drFrame:GetStatus()]))
end

local function drFrameUpdateStatusText(drFrame)
	drFrame.Cooldown.Text:SetTextColor(unpack(dRstates[drFrame:GetStatus()]))
end

local flags = {
	HasDynamicSize = true
}

local dRTracking = BattleGroundEnemies:NewButtonModule({
	moduleName = "DRTracking",
	localizedModuleName = L.DRTracking,
	flags = flags,
	defaultSettings = defaultSettings,
	generalDefaults = generalDefaults,
	options = options,
	generalOptions = generalOptions,
	events = {"AuraRemoved"},
	enabledInThisExpansion = true
})

local function createNewDrFrame(playerButton, container)
	local drFrame = CreateFrame("Frame", nil, container, BackdropTemplateMixin and "BackdropTemplate")
	drFrame.Cooldown = BattleGroundEnemies.MyCreateCooldown(drFrame)

	drFrame.Cooldown:SetScript("OnCooldownDone", function()
		drFrame:Remove()
	end)
	drFrame:HookScript("OnEnter", function(self)
		BattleGroundEnemies:ShowTooltip(self, function()
			if IsClassic then return end
			GameTooltip:SetSpellByID(self.spellId)
		end)
	end)

	drFrame:HookScript("OnLeave", function(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end)

	drFrame.Container = container

	drFrame.ApplyChildFrameSettings = function(self)
		self.Cooldown:ApplyCooldownSettings(container.config.Cooldown, true , {0, 0, 0, 0.5})
		self:SetDisplayType()
	end

	drFrame.GetStatus = function(self)
		local status = self.input.status
		status = (math.min(status, 3))
		return status
	end

	drFrame.SetDisplayType = function(self)
		if container.config.DisplayType == "Frame" then
			self.SetStatus = drFrameUpdateStatusBorder
		else
			self.SetStatus = drFrameUpdateStatusText
		end

		self.Cooldown.Text:SetTextColor(1, 1, 1, 1)
		self:SetBackdropBorderColor(0, 0, 0, 0)
		if self.input and self.input.status ~= 0 then self:SetStatus() end
	end

	drFrame:SetBackdrop({
		bgFile = "Interface/Buttons/WHITE8X8", --drawlayer "BACKGROUND"
		edgeFile = 'Interface/Buttons/WHITE8X8', --drawlayer "BORDER"
		edgeSize = 1
	})

	drFrame:SetBackdropColor(0, 0, 0, 0)
	drFrame:SetBackdropBorderColor(0, 0, 0, 0)

	drFrame.Icon = drFrame:CreateTexture(nil, "BORDER", nil, -1) -- -1 to make it behind the SetBackdrop bg
	drFrame.Icon:SetAllPoints()

	drFrame:ApplyChildFrameSettings()

	drFrame:Hide()
	return drFrame
end

local function setupDrFrame(container, drFrame, drDetails)
	local globalModuleSetting = BattleGroundEnemies.db.profile.ButtonModules.DRTracking
	drFrame:SetStatus()

	drFrame.spellId = drDetails.spellId
	--drFrame.Icon:SetTexture(IsClassic and GetSpellTexture(DRList.spells[drDetails.spellName].spellId) or GetSpellTexture(drDetails.spellId)) no longer needed classic seems to support spellIDs now
	local icon
	if globalModuleSetting.CustomCategoryIconsEnabled then
		local spellIdForICon = globalModuleSetting.CustomCategoryIcons[drDetails.drCat]
		if spellIdForICon then
			icon = GetSpellTexture(spellIdForICon)
			if not icon then
				BattleGroundEnemies:OnetimeInformation("The custom spell icon you selected for the DR category "..  drDetails.drCat.. " doesn't seem to exist anymore, please choose a new icon for this category. Using the spell's icon instead.")
			end
		else --if we end up here the user probably doesn't want a custom icon for this category since he left that option untouched/nil
		end
	end
	if not icon then icon = GetSpellTexture(drDetails.spellId) end
	drFrame.Icon:SetTexture(icon)
	local duration = DRList:GetResetTime(drDetails.drCat)
	drFrame.Cooldown:SetCooldown(drDetails.startTime, duration)
end

function dRTracking:AttachToPlayerButton(playerButton)
	local container = BattleGroundEnemies:NewContainer(playerButton, createNewDrFrame, setupDrFrame)
	--frame:SetBackdropColor(0, 0, 0, 0)

	function container:AuraRemoved(spellId, spellName)
		local config = self.config
		--self:Debug(operation, spellId)

		--local drCat = DRList:GetCategoryBySpellID(IsClassic and spellName or spellId) --no longer needed, classic seems to support spellIDs now
		local drCat = DRList:GetCategoryBySpellID(spellId)

		if not drCat then return end

		local drTrackingEnabled = not config.Filtering_Enabled or config.Filtering_Filterlist[drCat]
		if not drTrackingEnabled then return end

		local input = self:FindInputByAttribute("drCat", drCat)
		if input then
			input = self:UpdateInput(input, {spellId = spellId})
		else
			input = self:NewInput({
				drCat = drCat,
				spellId = spellId
			})
		end

		input.status = (input.status or 0) + 1

		input.startTime = GetTime()
		self:Display()
	end

	playerButton.DRTracking = container
	return playerButton.DRTracking
end
