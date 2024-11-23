
---@class BattleGroundEnemies
local BattleGroundEnemies = BattleGroundEnemies
---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)
local LibSpellIconSelector = LibStub("LibSpellIconSelector")

local L = Data.L

local CTimerNewTicker = C_Timer.NewTicker


local generalDefaults = {
	Combat = {
		Enabled = true,
		Icon = 132147
	},
	OutOfCombat = {
		Enabled = true,
		Icon = 132310
	},
	UpdatePeriod = 0.1
}


local defaultSettings = {
	Enabled = false,
	Parent = "healthBar",
	ActivePoints = 1,
	Width = 21,
	Height = 21,
	Points = {
		{
			Point = "TOPLEFT",
			RelativeFrame = "Level",
			RelativePoint = "TOPRIGHT",
			OffsetX = -13,
			OffsetY = -15
		}
	},
}

local Icons = { --one of the two (or both) must be enabled, otherwise u won't see an icon
	"Combat",
	"OutOfCombat"
}


local generalOptions = function(location)
	local t = {}
	for i = 1, #Icons do
		t[Icons[i]] = {
			type = "group",
			name = L[Icons[i]],
			inline = true,
			order = 4,
			get = function(option)
				return Data.GetOption(location[Icons[i]], option)
			end,
			set = function(option, ...)
				return Data.SetOption(location[Icons[i]], option, ...)
			end,
			args = {
				Enabled = {
					type = "toggle",
					name = VIDEO_OPTIONS_ENABLED,
					order = 1
				},
				Icon = {
					type = "execute",
					name = L.Icon,
					image = function() return location[Icons[i]].Icon end,
					func = function(option)
						local locationn = location[Icons[i]]
						local optiontable = {} --hold a copy of the option table for the OnOkayButtonPressed otherweise the table will be empty
						Mixin(optiontable, option)
						LibSpellIconSelector:Show(locationn, function(spelldata)
							Data.SetOption(locationn, optiontable, spelldata.icon)
							BattleGroundEnemies:NotifyChange()
						end)
					end,
					disabled = function() return not location[Icons[i]].Enabled end,
					width = "half",
					order = 2,

				}
			}
		}
	end
	t.UpdatePeriod = {
		type = "range",
		name = L.UpdatePeriod,
		desc = L.UpdatePeriod_Desc,
		min = 0.01,
		max = 2,
		step = 0.05,
		order = 3
	}
	return t
end

local combatIndicator = BattleGroundEnemies:NewButtonModule({
	moduleName = "CombatIndicator",
	localizedModuleName = L.CombatIndicator,
	defaultSettings = defaultSettings,
	generalDefaults = generalDefaults,
	events = {"OnTestmodeEnabled", "OnTestmodeDisabled", "OnTestmodeTick"},
	generalOptions = generalOptions,
	enabledInThisExpansion = true,
	attachSettingsToButton = true
})



local states = {
	Unknown = 0,
	Combat = 1,
	OutOfCombat = 2
}

local stateStateToIcon = {
	Unknown = {
		Combat = false,
		OutOfCombat = false
	},
	Combat = {
		Combat = true,
		OutOfCombat = false
	},
	OutOfCombat = {
		Combat = false,
		OutOfCombat = true
	},
}

local function getState(inCombat)
	if inCombat == nil then
		return 0
	elseif inCombat then
		return 1
	else
		return 2
	end
end


function combatIndicator:AttachToPlayerButton(playerButton)
	playerButton.CombatIndicator = CreateFrame("Frame", nil, playerButton)
	playerButton.CombatIndicator.Ticker = false
	playerButton.CombatIndicator.currentState = nil

	for i = 1, #Icons do
		local type = Icons[i]

		local iconFrame = CreateFrame("Frame", nil, playerButton.CombatIndicator)
		iconFrame:SetAllPoints()
		iconFrame:Hide()

		iconFrame.type = type
		iconFrame.texture = iconFrame:CreateTexture(nil, "BACKGROUND")
		iconFrame.texture:SetAllPoints()
		--RaiseFrameLevel(frame)
		iconFrame:SetFrameLevel(playerButton:GetFrameLevel()+1)

		playerButton.CombatIndicator[type] = iconFrame
	end

	function playerButton.CombatIndicator:ShowIconForState(newState)
		local showCombat = false
		local showOutOfCombat = false
		if newState ~= 0 then
			if newState == 1 then
				if self.config.Combat.Enabled then
					showCombat = true
				end
			else
				if self.config.OutOfCombat.Enabled then
					showOutOfCombat = true
				end
			end
		end

		self.Combat:SetShown(showCombat)
		self.OutOfCombat:SetShown(showOutOfCombat)

		self.currentState = newState
	end

	function playerButton.CombatIndicator:Update(forceState, applyConfig)
		local inCombat
		local newState

		--set showCombat and showOutOfCombat to false (this takes effect when the player doesnt have a unitID)

		if forceState ~= nil then
			newState = forceState
		else
			local unitID = playerButton:GetUnitID()
			if unitID then
				inCombat = UnitAffectingCombat(unitID)
			end
			newState = getState(inCombat)
		end

		if applyConfig or self.currentState ~= newState then
			self:ShowIconForState(newState)
		end
	end

	function playerButton.CombatIndicator:CallFuncOnAllIconFrames(func)
		for i = 1, #Icons do
			local type = Icons[i]
			local iconFrame = self[type]
			func(iconFrame)
		end
	end

	function playerButton.CombatIndicator:Disable()
		self:DisableTicker()
	end

	function playerButton.CombatIndicator:DisableTicker()
		if self.Ticker then
			self.Ticker:Cancel()
		end
	end

	function playerButton.CombatIndicator:OnTestmodeEnabled()
		self.testmodeEnabled = true
		self:DisableTicker()
	end

	function playerButton.CombatIndicator:OnTestmodeDisabled()
		self.testmodeEnabled = false
		self:Update(0)
	end

	function playerButton.CombatIndicator:OnTestmodeTick()
		if not self.testmodeEnabled then
			self:DisableTicker()
			self.testmodeEnabled = true
		end
		local newState = math.random(1,2)
		self:Update(newState)
	end



	function playerButton.CombatIndicator:ApplyAllSettings()
		if not self.config then return end
		self:CallFuncOnAllIconFrames(function(iconFrame)
			iconFrame.texture:SetTexture(self.config[iconFrame.type].Icon)
		end)

		self:Update(nil, true)

		if self.Ticker then
			self.Ticker:Cancel()
		end
		if self.config.UpdatePeriod and not self.testmodeEnabled then
			self.Ticker = CTimerNewTicker(self.config.UpdatePeriod, function()
				self:Update()
			end)
		end
	end
	return playerButton.CombatIndicator
end