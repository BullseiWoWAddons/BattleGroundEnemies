---@class BattleGroundEnemies
local BattleGroundEnemies = BattleGroundEnemies

---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)
local GetTime = GetTime
local GetSpellTexture = C_Spell and C_Spell.GetSpellTexture or GetSpellTexture


local IsCataClassic = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC

local L = Data.L

local defaultSettings = {
	Enabled = true,
	Parent = "Button",
	Width = 36,
	ActivePoints = 2,
	Points = {
		{
			Point = "TOPRIGHT",
			RelativeFrame = "TargetIndicatorNumeric",
			RelativePoint = "TOPLEFT",
			OffsetX = -2
		},
		{
			Point = "BOTTOMRIGHT",
			RelativeFrame = "TargetIndicatorNumeric",
			RelativePoint = "BOTTOMLEFT",
			OffsetX = -2
		}
	},
	Cooldown = {
		FontSize = 12,
	},
	Text = {
		FontSize = 17,
	}
}

local options = function(location)
	return {
		TextSettings = {
			type = "group",
			name = L.Text,
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
			order = 2,
			args = Data.AddCooldownSettings(location.Cooldown)
		}
	}
end

local objectiveAndRespawn = BattleGroundEnemies:NewButtonModule({
	moduleName = "ObjectiveAndRespawn",
	localizedModuleName = L.ObjectiveAndRespawnTimer,
	defaultSettings = defaultSettings,
	options = options,
	events = {"ShouldQueryAuras", "BeforeFullAuraUpdate", "NewAura", "UnitDied", "UnitRevived", "ArenaOpponentShown", "ArenaOpponentHidden"},
	enabledInThisExpansion = true,
	attachSettingsToButton = true
})

function objectiveAndRespawn:AttachToPlayerButton(playerButton)
	local frame = CreateFrame("frame", nil, playerButton)
	frame:SetFrameLevel(playerButton:GetFrameLevel()+5)

	frame.Icon = frame:CreateTexture(nil, "BORDER")
	frame.Icon:SetAllPoints()

	frame:SetScript("OnSizeChanged", function(self, width, height)
		BattleGroundEnemies.CropImage(self.Icon, width, height)
	end)
	frame:Hide()

	frame.AuraText = BattleGroundEnemies.MyCreateFontString(frame)
	frame.AuraText:SetAllPoints()
	frame.AuraText:SetJustifyH("CENTER")

	frame.Cooldown = BattleGroundEnemies.MyCreateCooldown(frame)
	frame.Cooldown:Hide()


	frame.Cooldown:SetScript("OnCooldownDone", function()
		BattleGroundEnemies:Debug(playerButton.PlayerDetails.PlayerName, "OnCooldownDone")

		frame:Reset()
	end)
	-- ObjectiveAndRespawn.Cooldown:SetScript("OnCooldownDone", function()
	-- 	ObjectiveAndRespawn:Reset()
	-- end)

	function frame:Reset()
		self:Hide()
		self.Icon:SetTexture()
		if self.AuraText:GetFont() then self:HideText() end
		self.ActiveRespawnTimer = false
	end

	function frame:HideText()
		self.AuraText:SetText("")
		self.shownValue = false
	end


	function frame:ApplyAllSettings()
		local conf = self.config
		self.AuraText:ApplyFontStringSettings(conf.Text)
		self.Cooldown:ApplyCooldownSettings(conf.Cooldown, true, {0, 0, 0, 0.75})
	end
	function frame:SearchForDebuffs(aura)
		--BattleGroundEnemies:Debug("Läüft")
		local battleGroundDebuffs = BattleGroundEnemies.BattleGroundDebuffs
		local value
		if battleGroundDebuffs then
			for i = 1, #battleGroundDebuffs do
				if aura.spellId == battleGroundDebuffs[i] then
					if BattleGroundEnemies.CurrentMapID == 417 then -- 417 is Kotmogu, we scan for orb debuffs
	
						if aura.points and type(aura.points) == "table" then
							if aura.points[2] then
								if not self.shownValue then
									--BattleGroundEnemies:Debug("hier")
									--player just got the debuff
									self.Icon:SetTexture(GetSpellTexture(aura.spellId))
									self:Show()
									--BattleGroundEnemies:Debug("Texture set")
								end
								value = aura.points[2]
									--values for orb debuff:
									--BattleGroundEnemies:Debug(value1, value2, value3, value4)
									-- value1 = Reduces healing received by value1
									-- value2 = Increases damage taken by value2
									-- value3 = Increases damage done by value3
							end
						end
						--kotmogu
						
						--end of kotmogu
	
					else
						-- not kotmogu
						value = aura.applications
					end
					if value ~= self.shownValue then
						self.AuraText:SetText(value)
						self.shownValue = value
					end
					self.continue = false
					return
				end
			end
		end
	end

	function frame:ShouldQueryAuras(unitID, filter)
		if not unitID then return false end
		if BattleGroundEnemies.ArenaIDToPlayerButton[unitID] then
			return filter == "HARMFUL"
		else
			return false
		end
	end

	function frame:BeforeFullAuraUpdate(filter)
		if filter == "HARMFUL" then
			self.continue = true
		end
	end

	function frame:NewAura(unitID, filter, aura)
		if filter ~= "HARMFUL" then return end
		if not self.continue then return end

		if not BattleGroundEnemies.ArenaIDToPlayerButton[unitID] then return end -- This player is not shown on arena enemy so we dont care
		if BattleGroundEnemies.BattleGroundDebuffs then self:SearchForDebuffs(aura) end
	end

	function frame:UnitRevived()
		BattleGroundEnemies:Debug(playerButton.PlayerDetails.PlayerName, "UnitRevived")

		--BattleGroundEnemies:Debug("UnitRevived")
		if self.ActiveRespawnTimer then
			self.Cooldown:Clear()
		end
	end

	function frame:UnitDied()
		BattleGroundEnemies:Debug(playerButton.PlayerDetails.PlayerName, "UnitDied")

		if (BattleGroundEnemies.IsRatedBG or BattleGroundEnemies.IsSoloRBG or (BattleGroundEnemies.Testmode.Active)) then
		--BattleGroundEnemies:Debug("UnitIsDead SetCooldown")
			if not self.ActiveRespawnTimer then
				self:Show()
				self.Icon:SetTexture(GetSpellTexture(8326))
				self:HideText()
				self.ActiveRespawnTimer = true
			end
			local respawmTime = 26
			if IsCataClassic then
				respawmTime = 45
			else
				if BattleGroundEnemies.IsSoloRBG then
					respawmTime = 15
				end
			end
			self.Cooldown:SetCooldown(GetTime(), respawmTime) --overwrite an already active timer
		end
	end

	function frame:ArenaOpponentShown()
		BattleGroundEnemies:Debug(playerButton.PlayerDetails.PlayerName, "ArenaOpponentShown")
		if BattleGroundEnemies.BattlegroundBuff then
			BattleGroundEnemies:Debug(playerButton.PlayerDetails.PlayerName, "has buff")
			self.Icon:SetTexture(GetSpellTexture(BattleGroundEnemies.BattlegroundBuff[playerButton.PlayerIsEnemy and BattleGroundEnemies.EnemyFaction or BattleGroundEnemies.AllyFaction]))
			self:Show()
		end

		self:HideText()
	end

	function frame:ArenaOpponentHidden()
		BattleGroundEnemies:Debug(playerButton.PlayerDetails.PlayerName, "ArenaOpponentHidden")
		self:Reset()
	end
	playerButton.ObjectiveAndRespawn = frame
	return playerButton.ObjectiveAndRespawn
end