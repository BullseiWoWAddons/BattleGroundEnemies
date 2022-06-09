local AddonName, Data = ...
local L = Data.L

local defaultSettings = {
	Cooldown = {
		ShowNumbers = true,
		Fontsize = 12,
		Outline = "OUTLINE",
		EnableTextshadow = false,
		TextShadowcolor = {0, 0, 0, 1},
	}	
}

local options = function(location) 
	return {
		CooldownTextSettings = {
			type = "group",
			name = L.Countdowntext,
			--desc = L.TrinketSettings_Desc,
			inline = true,
			order = 1,
			args = Data.AddCooldownSettings(location.Cooldown)
		}
	}
end

local events = {"ShouldQueryAuras", "CareAboutThisAura", "BeforeUnitAura", "UnitAura", "AfterUnitAura", "GotInterrupted", "UnitDied"}

local spec_HighestActivePriority = BattleGroundEnemies:NewModule("HighestPriority", "highestPriority", 3, defaultSettings, options, events)

function spec_HighestActivePriority:AttachToPlayerButton(playerButton)
	local frame = CreateFrame("frame", nil, playerButton)
	frame:HookScript("OnEnter", function(self)
		BattleGroundEnemies:ShowTooltip(self, function()
			BattleGroundEnemies:ShowAuraTooltip(playerButton, frame.DisplayedAura)
		end)
	end)
	
	frame:HookScript("OnLeave", function(self)
		if GameTooltip:IsOwned(frame) then
			GameTooltip:Hide()
		end
	end)

	frame:Hide()

	function frame:NewAura(unitID, filter, name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, nameplateShowAll, timeMod)
		local priority = BattleGroundEnemies:GetBigDebuffsPriority(spellID) or Data.SpellPriorities[spellID]
		if not priority then return end
		local ID = #self.PriorityAuras + 1
		local auraDetails = {
			ID = ID,
			SpellID = spellID,
			Icon = icon,
			DebuffType = debuffType,
			Priority = priority,
			Stacks = count,
			ExpirationTime = expirationTime,
			Duration = duration
		}
		self.PriorityAuras[ID] = auraDetails
	end

	function frame:Update()	
		local highestPrioritySpell
		local currentTime = GetTime()

		local priorityAuras = self.PriorityAuras
		for i = 1, #priorityAuras do
			
			local priorityAura = priorityAuras[i]
			if priorityAura.ExpirationTime < currentTime then
			else 
				if not highestPrioritySpell or priorityAura.Priority > highestPrioritySpell.Priority then 
					highestPrioritySpell = priorityAura
				end
			end
		end
		if frame.ActiveInterrupt then
			if frame.ActiveInterrupt.ExpirationTime < currentTime then
				frame.ActiveInterrupt = false
			else
				if not highestPrioritySpell or frame.ActiveInterrupt.Priority > highestPrioritySpell.Priority then 
					highestPrioritySpell = frame.ActiveInterrupt
				end
			end
		end

		if highestPrioritySpell then
			frame.DisplayedAura = highestPrioritySpell
			frame:Show()
			frame.Icon:SetTexture(highestPrioritySpell.Icon)
			frame.Cooldown:SetCooldown(highestPrioritySpell.ExpirationTime - highestPrioritySpell.Duration, highestPrioritySpell.Duration)
		else
			frame.DisplayedAura = false
			frame:Hide()
		end
	end	

	function frame:ApplyAllSettings()
		local moduleSettings = self.config
		self.Cooldown:ApplyCooldownSettings(moduleSettings.Cooldown.ShowNumbers, true, true, {0, 0, 0, 0.5})
		self.Cooldown.Text:ApplyFontStringSettings(moduleSettings.Cooldown)
	end
	
	function frame:Reset()
		self.ActiveInterrupt = false
		wipe(self.PriorityAuras)
		self:Update()
	end


	frame:SetAllPoints()
	frame:SetFrameLevel(playerButton.Spec:GetFrameLevel() + 1)
	frame.PriorityAuras = {}
	frame.ActiveInterrupt = false
	frame.Icon = frame:CreateTexture(nil, 'BACKGROUND')
	frame.Icon:SetAllPoints()
	frame.Cooldown = BattleGroundEnemies.MyCreateCooldown(frame)
	frame.Cooldown:SetScript("OnCooldownDone", function(self)
		frame:Update()
	end)

	function frame:GotInterrupted(spellID, interruptDuration)
		self.ActiveInterrupt = {
			SpellID = spellID,
			Icon = GetSpellTexture(spellID),
			ExpirationTime = GetTime() + interruptDuration,
			Duration = interruptDuration,
			Priority = BattleGroundEnemies:GetBigDebuffsPriority(spellID) or 4
		}
		self:Update()
	end
	
	function frame:CareAboutThisAura(unitID, auraInfo, filter, spellID, unitCaster, canStealOrPurge, canApplyAura, debuffType)
	
		if auraInfo then spellID = auraInfo.spellId end
	
		if Data.SpellPriorities[spellID] then return true end
	end
	
	function frame:ShouldQueryAuras(unitID, filter)
		return true -- we care about all auras
	end
	
	function frame:BeforeUnitAura(filter)
		wipe(self.PriorityAuras)
	end
	
	function frame:UnitAura(unitID, filter, ...)
		self:NewAura(unitID, filter, ...)
	end
	
	function frame:AfterUnitAura(filter)
		self:Update()
	end
	
	function frame:UnitDied()
		self:Reset()
	end
	playerButton.HighestPriority = frame
end

