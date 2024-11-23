---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)
---@class BattleGroundEnemies
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L

local CreateFrame = CreateFrame
local GetTime = GetTime
local GameTooltip = GameTooltip
local GetSpellTexture = C_Spell and C_Spell.GetSpellTexture or GetSpellTexture


local generalDefaults = {
	Filtering_Enabled = false,
	Filtering_Filterlist = {}, --key = spellId, value = spellName or false
}


local defaultSettings = {
	Enabled = true,
	Parent = "Button",
	UseButtonHeightAsHeight = true,
	UseButtonHeightAsWidth = true,
	ActivePoints = 1,
	Cooldown = {
		FontSize = 12,
	},

}
local generalOptions = function(location)
	return {
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
				for spellId in pairs(Data.RacialNameToSpellIDs[key]) do
					return location.Filtering_Filterlist[spellId]
				end
			end,
			set = function(option, key, state) -- value = spellname
				for spellId in pairs(Data.RacialNameToSpellIDs[key]) do
					location.Filtering_Filterlist[spellId] = state or nil
				end
			end,
			values = Data.Racialnames,
			order = 3
		}
	}
end


local options = function(location)
	return {
		CooldownTextSettings = {
			type = "group",
			name = L.Countdowntext,
			inline = true,
			get = function(option)
				return Data.GetOption(location.Cooldown, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.Cooldown, option, ...)
			end,
			order = 1,
			args = Data.AddCooldownSettings(location.Cooldown)
		}
	}
end

local racial = BattleGroundEnemies:NewButtonModule({
	moduleName = "Racial",
	localizedModuleName = L.Racial,
	defaultSettings = defaultSettings,
	generalDefaults = generalDefaults,
	options = options,
	generalOptions = generalOptions,
	events = {"SPELL_CAST_SUCCESS"},
	enabledInThisExpansion = true
})

function racial:AttachToPlayerButton(playerButton)

	local frame = CreateFrame("frame", nil, playerButton)
	-- trinket
	frame:HookScript("OnEnter", function(self)
		if self.spellId then
			BattleGroundEnemies:ShowTooltip(self, function()
				GameTooltip:SetSpellByID(self.spellId)
			end)
		end
	end)

	frame:HookScript("OnLeave", function(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end)

	function frame:Reset()
		self.spellId = false
		self.Icon:SetTexture(nil)
		self.Cooldown:Clear()	--reset Trinket Cooldown
	end

	function frame:ApplyAllSettings()
		if not self.config then return end
		local moduleSettings = self.config
		self.Cooldown:ApplyCooldownSettings(moduleSettings.Cooldown, false, {0, 0, 0, 0.5})

		if self.spellId then
			if moduleSettings.Filtering_Enabled and not moduleSettings.Filtering_Filterlist[self.spellId] then 
				self:Reset()
			end
		end
	end


	frame.Icon = frame:CreateTexture()
	frame.Icon:SetAllPoints()
	frame:SetScript("OnSizeChanged", function(self, width, height)
		BattleGroundEnemies.CropImage(self.Icon, width, height)
	end)

	frame.Cooldown = BattleGroundEnemies.MyCreateCooldown(frame)

	function frame:RacialCheck(spellId)
		if not Data.RacialSpellIDtoCooldown[spellId] then return end
		local config = frame.config
		local insi = playerButton.Trinket


		if Data.RacialSpellIDtoCooldown[spellId].trinketCD and not (insi.spellId == 336128) and insi.spellId and insi.Cooldown:GetCooldownDuration() < Data.RacialSpellIDtoCooldown[spellId].trinketCD * 1000 then
			insi.Cooldown:SetCooldown(GetTime(), Data.RacialSpellIDtoCooldown[spellId].trinketCD)
		end

		if config.Filtering_Enabled and not config.Filtering_Filterlist[spellId] then return end

		self.spellId = spellId
		self.Icon:SetTexture(GetSpellTexture(spellId))
		self.Cooldown:SetCooldown(GetTime(), Data.RacialSpellIDtoCooldown[spellId].cd)
	end

	function frame:SPELL_CAST_SUCCESS(srcGUID, srcName, destGUID, destName, spellId)
		self:RacialCheck(spellId)
	end
	playerButton.Racial = frame
	return playerButton.Racial
end