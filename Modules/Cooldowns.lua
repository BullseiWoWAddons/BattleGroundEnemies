---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)
---@class BattleGroundEnemies
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L

local LSM = LibStub("LibSharedMedia-3.0")


local GetSpellTexture = C_Spell and C_Spell.GetSpellTexture or GetSpellTexture

local CreateFrame = CreateFrame
local BackdropTemplateMixin = BackdropTemplateMixin
local GameTooltip = GameTooltip

local IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

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

local options = function(location)
	return {
		ContainerSettings = {
			type = "group",
			name = L.ContainerSettings,
			order = 1,
			get = function(option)
				return Data.GetOption(location.Container, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.Container, option, ...)
			end,
			args = Data.AddContainerSettings(location.Container),
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
			get = function(option)
				return Data.GetOption(location.Cooldown, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.Cooldown, option, ...)
			end,
			order = 3,
			args = Data.AddCooldownSettings(location.Cooldown)
		},
	}
end

local flags = {
	HasDynamicSize = true
}

local cooldowns = BattleGroundEnemies:NewButtonModule({
	moduleName = "Cooldowns",
	localizedModuleName = L.Cooldowns,
	flags = flags,
	defaultSettings = defaultSettings,
	options = options,
	events = {"SPELL_CAST_SUCCESS"},
	enabledInThisExpansion = true
})

local function createNewCooldownFrame(playerButton, container)
	local cooldownFrame = CreateFrame("Frame", nil, container, BackdropTemplateMixin and "BackdropTemplate")
	cooldownFrame.Cooldown = BattleGroundEnemies.MyCreateCooldown(cooldownFrame)

	cooldownFrame.Cooldown:SetScript("OnCooldownDone", function()
		cooldownFrame:Remove()
	end)
	cooldownFrame:HookScript("OnEnter", function(self)
		BattleGroundEnemies:ShowTooltip(self, function()
			if IsClassic then return end
			GameTooltip:SetSpellByID(self.spellId)
		end)
	end)

	cooldownFrame:HookScript("OnLeave", function(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end)

	cooldownFrame.Container = container

	cooldownFrame.ApplyChildFrameSettings = function(self)
		self.Cooldown:ApplyCooldownSettings(container.config.Cooldown, false, {0, 0, 0, 0.5})
	end

	cooldownFrame.GetStatus = function(self)
		local status = self.input.status
		status = (math.min(status, 3))
		return status
	end

	cooldownFrame:SetBackdrop({
		bgFile = "Interface/Buttons/WHITE8X8", --drawlayer "BACKGROUND"
		edgeFile = 'Interface/Buttons/WHITE8X8', --drawlayer "BORDER"
		edgeSize = 1
	})

	cooldownFrame:SetBackdropColor(0, 0, 0, 0)
	cooldownFrame:SetBackdropBorderColor(0, 0, 0, 0)

	cooldownFrame.Icon = cooldownFrame:CreateTexture(nil, "BORDER", nil, -1) -- -1 to make it behind the SetBackdrop bg
	cooldownFrame.Icon:SetAllPoints()
    cooldownFrame:SetScript("OnSizeChanged", function(self, width, height)
		BattleGroundEnemies.CropImage(self.Icon, width, height)
	end)

	cooldownFrame:ApplyChildFrameSettings()

	cooldownFrame:Hide()
	return cooldownFrame
end

local function setupCooldownFrame(container, cooldownFrame, cooldownDetails)
    print("setupCooldownFrame")
	cooldownFrame.spellId = cooldownDetails.spellId
	cooldownFrame.Icon:SetTexture(GetSpellTexture(cooldownDetails.spellId))
	cooldownFrame.Cooldown:SetCooldown(cooldownDetails.startTime, cooldownDetails.duration)
end

function cooldowns:AttachToPlayerButton(playerButton)
	local container = BattleGroundEnemies:NewContainer(playerButton, createNewCooldownFrame, setupCooldownFrame)
	--frame:SetBackdropColor(0, 0, 0, 0)



	function container:GetCooldown(spellID)
		local cooldownData


		return cooldownData
	end

	function container:SPELL_CAST_SUCCESS(srcGUID, srcName, destGUID, destName, spellId)
		if true then return end
        print("SPELL_CAST_SUCCESS", srcName, destName, spellId)
		local config = self.config
		--BattleGroundEnemies:Debug(operation, spellId)


		print("1")
		local cooldownData = BattleGroundEnemies:GetSpellCooldownData(spellId)
		print("2")

		if not cooldownData then return end
		print("3")

		local cooldown = cooldownData.duration
		if not cooldown then return end
		print("4")

        local input = self:FindInputByAttribute("spellId", spellId)
        if not input then
            input = self:NewInput({
                spellId = spellId
            })
        end

		local currentTime = GetTime()

        input.duration = cooldown
        input.startTime = currentTime
        self:Display()
	end

	playerButton.Cooldowns = container
	return playerButton.Cooldowns
end
