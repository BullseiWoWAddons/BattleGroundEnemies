
local BattleGroundEnemies = BattleGroundEnemies
local AddonName, Data = ...

local L = Data.L



local defaultSettings = {
	Enabled = false,
	Parent = "healthBar",
	ActivePoints = 2,
	Points = {
		{
			Point = "TOPLEFT",
			RelativeFrame = "Level",
			RelativePoint = "TOPRIGHT",
			OffsetX = 5,
			OffsetY = -2
		},
		{
			Point = "BOTTOMRIGHT",
			RelativeFrame = "TargetIndicatorNumeric",
			RelativePoint = "BOTTOMLEFT",
		}
	},
	CombatIconEnabled = true,
	OutOfCombatIconEnabled = true,
	UpdatePeriod = 0.1
}

local options = function(location)
	return {
		CombatIconEnabled = {
			type = "toggle",
			name = L.CombatIconEnabled,
			width = "normal",
			order = 1
		},
		OutOfCombatIconEnabled = {
			type = "toggle",
			name = L.OutOfCombatIconEnabled,
			order = 2
		},
		UpdatePeriod = {
			type = "range",
			name = L.UpdatePeriod,
			desc = L.UpdatePeriod_Desc,
			min = 0.05,
			max = 2,
			step = 0.05,
			order = 3
		}
	}
end

local name = BattleGroundEnemies:NewButtonModule({
	moduleName = "CombatIndicator",
	localizedModuleName = L.CombatIndicator,
	defaultSettings = defaultSettings,
	options = options,
	expansions = "All"
})

local Icons = { --one of the two (or both) must be enabled, otherwise u won't see an icon
	"Combat",
	"OutOfCombat"
}

local Textures = {
	Combat = 132147, --"Interface/Icons/Ability_DualWield",
	OutOfCombat = 132310, -- Interface/Icons/ABILITY_SAP",
}


function name:AttachToPlayerButton(playerButton)
	playerButton.CombatIndicator = CreateFrame("Frame", nil, playerButton)
	playerButton.CombatIndicator.Ticker = false

	for i = 1, #Icons do
		local type = #Icons[i]

		local iconFrame = CreateFrame("Frame", nil, playerButton.CombatIndicator)
		iconFrame:SetScript("OnShow", function(self)
			self.isVisible = true
		end)
		iconFrame:SetScript("OnHide", function(self)
			self.isVisible = false
		end)
		iconFrame:SetAllPoints()
		iconFrame:Hide()

		iconFrame.type = type
		iconFrame.texture = iconFrame:CreateTexture(nil, "BACKGROUND")
		iconFrame.texture:SetAllPoints()
		--RaiseFrameLevel(frame)
		iconFrame:SetFrameLevel(playerButton:GetFrameLevel()+1)

		playerButton.CombatIndicator[type] = iconFrame
	end

	function playerButton.CombatIndicator:Update()
		local unitID = playerButton:GetUnitID()
		local showCombat = false
		local showOutOfCombat = false
		if unitID then
			local inCombat = UnitAffectingCombat(unitID)
			
			if inCombat then
				if self.config.CombatIconEnabled then
					showCombat = true
					showOutOfCombat = false
				else
					showCombat = false
					showOutOfCombat = false
				end
			else
				if self.config.OutOfCombatIconEnabled then
					showCombat = false
					showOutOfCombat = true
				else
					showCombat = false
					showOutOfCombat = false
				end
			end
		end
		if showCombat then
			if self.Combat and not self.Combat.isVisible then
				self.Combat:Show()
			end
		else
			if self.Combat and self.Combat.isVisible then
				self.Combat:Hide()
			end
		end

		if showOutOfCombat then
			if self.OutOfCombat and not self.OutOfCombat.isVisible then
				self.OutOfCombat:Show()
			end
		else
			if self.OutOfCombat and self.OutOfCombat.isVisible then
				self.OutOfCombat:Hide()
			end
		end
	end

	function playerButton.CombatIndicator:CallFuncOnAllIconFrames(func)
		for i = 1, #Icons do
			local type = #Icons[i]
			local iconFrame = self[type]
			func(iconFrame)
		end
	end

	function playerButton.CombatIndicator:Disable()
		if self.Ticker then
			self.Ticker:Cancel()
		end
	end

	function playerButton.CombatIndicator:ApplyAllSettings()

		self:CallFuncOnAllIconFrames(function(iconFrame)
			iconFrame.texture:SetTexture(Textures[iconFrame.type])
		end)

		if self.Ticker then
			self.Ticker:Cancel()
		end
		if self.config.UpdatePeriod then
			self.Ticker = CTimerNewTicker(self.config.UpdatePeriod, function ()
				self:Update()
			end)
		end
	end
end