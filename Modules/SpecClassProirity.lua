---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)
---@class BattleGroundEnemies
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L
local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local GetSpellTexture = C_Spell and C_Spell.GetSpellTexture or GetSpellTexture


local defaultSettings = {
	Enabled = true,
	Parent = "Button",
	Cooldown = {
		ShowNumber = true,
		FontSize = 12,
		FontOutline = "OUTLINE",
		EnableShadow = false,
		DrawSwipe = true,
		ShadowColor = {0, 0, 0, 1},
	},
	ActivePoints = 1,
	Points = {
		{
			Point = "TOPRIGHT",
			RelativeFrame = "Button",
			RelativePoint = "TOPLEFT",
		}
	},
    UseButtonHeightAsHeight = true,
    showSpecIfExists = true,
    showHighestPriority = true
}

local options = function(location)
	return {
        showSpecIfExists = {
			type = "toggle",
			name = L.ShowSpecIfExists,
			desc = L.ShowSpecIfExists_Desc,
			width = "normal",
			order = 1
		},
        showHighestPriority = {
			type = "toggle",
			name = L.showHighestPriority,
			desc = L.showHighestPriority_Desc,
			width = "normal",
			order = 2
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
			order = 3,
			args = Data.AddCooldownSettings(location.Cooldown)
		}
	}
end

local specClassPriorityOne = BattleGroundEnemies:NewButtonModule({
	moduleName = "specClassPriorityOne",
	localizedModuleName = L.specClassPriority,
	defaultSettings = defaultSettings,
	options = options,
	events = {"PlayerDetailsChanged", "ShouldQueryAuras", "CareAboutThisAura", "BeforeFullAuraUpdate", "NewAura", "AfterFullAuraUpdate", "GotInterrupted", "UnitDied"},
	enabledInThisExpansion = true
})

local specClassPriorityTwo = BattleGroundEnemies:NewButtonModule({
	moduleName = "specClassPriorityTwo",
	localizedModuleName = L.specClassPriority,
	defaultSettings = Mixin(defaultSettings, {
        Enabled= false,
        Points = {
            {
                Point = "TOPRIGHT",
                RelativeFrame = "Button",
                RelativePoint = "BOTTOMLEFT",
            }
        }
    }) ,
	options = options,
	events = {"PlayerDetailsChanged", "ShouldQueryAuras", "CareAboutThisAura", "BeforeFullAuraUpdate", "NewAura", "AfterFullAuraUpdate", "GotInterrupted", "UnitDied"},
	enabledInThisExpansion = true
})


local function attachToPlayerButton(playerButton, type)
    local frame = CreateFrame("frame", nil, playerButton)
    frame.Background = frame:CreateTexture(nil, 'BACKGROUND')
	frame.Background:SetAllPoints()
	frame.Background:SetColorTexture(0,0,0,0.8)
	frame.PriorityAuras = {}
	frame.ActiveInterrupt = false
	frame.Icon = frame:CreateTexture(nil, 'BACKGROUND')
	frame.Icon:SetAllPoints()
    frame.PriorityIcon = frame:CreateTexture(nil, 'BORDER')
	frame.PriorityIcon:SetAllPoints()
	frame.Cooldown = BattleGroundEnemies.MyCreateCooldown(frame)
	frame.Cooldown:SetScript("OnCooldownDone", function(self)
		frame:Update()
	end)

	frame:HookScript("OnLeave", function(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end)


	frame:HookScript("OnEnter", function(self)
		BattleGroundEnemies:ShowTooltip(self, function()
            if frame.DisplayedAura then
                BattleGroundEnemies:ShowAuraTooltip(playerButton, frame.DisplayedAura)

            else
                local playerDetails = playerButton.PlayerDetails
                if not playerDetails.PlayerClass then return end

                if playerDetails.PlayerSpecName then
                    GameTooltip:SetText(playerDetails.PlayerClass..": ".. playerDetails.PlayerSpecName)
                else
                    local numClasses = GetNumClasses()
                    for i = 1, numClasses do -- we could also just save the localized class name it into the button itself, but since its only used for this tooltip no need for that
                        local className, classFile, classID = GetClassInfo(i)
                        if classFile and classFile == playerDetails.PlayerClass then
                            return GameTooltip:SetText(className)
                        end
                    end
                end
            end
		end)
	end)


	frame:SetScript("OnSizeChanged", function(self, width, height)
		BattleGroundEnemies.CropImage(self.Icon, width, height)
        BattleGroundEnemies.CropImage(self.PriorityIcon, width, height)
	end)

	frame:Hide()

	function frame:MakeSureWeAreOnTop()
        if true then return end
		local numPoints = self:GetNumPoints()
		local highestLevel = 0
		for i = 1, numPoints do
			local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint(i)
			if relativeTo then
				local level = relativeTo:GetFrameLevel()
				if level and level > highestLevel then
					highestLevel = level
				end
			end
		end
		self:SetFrameLevel(highestLevel + 1)
	end

	function frame:Update()
		self:MakeSureWeAreOnTop()
		local highestPrioritySpell
		local currentTime = GetTime()

		local priorityAuras = self.PriorityAuras
		for i = 1, #priorityAuras do

			local priorityAura = priorityAuras[i]
			if not highestPrioritySpell or (priorityAura.Priority > highestPrioritySpell.Priority) then
				highestPrioritySpell = priorityAura
			end
		end
		if frame.ActiveInterrupt then
			if frame.ActiveInterrupt.expirationTime < currentTime then
				frame.ActiveInterrupt = false
			else
				if not highestPrioritySpell or (frame.ActiveInterrupt.Priority > highestPrioritySpell.Priority) then
					highestPrioritySpell = frame.ActiveInterrupt
				end
			end
		end

		if highestPrioritySpell then
			frame.DisplayedAura = highestPrioritySpell
			frame.PriorityIcon:Show()
			frame.PriorityIcon:SetTexture(highestPrioritySpell.icon)
			frame.Cooldown:SetCooldown(highestPrioritySpell.expirationTime - highestPrioritySpell.duration, highestPrioritySpell.duration)
		else
			frame.DisplayedAura = false
			frame.PriorityIcon:Hide()
		end
	end

	function frame:ResetPriorityData()
		self.ActiveInterrupt = false
		wipe(self.PriorityAuras)
		self:Update()
	end


	function frame:GotInterrupted(spellId, interruptDuration)
		self.ActiveInterrupt = {
			spellId = spellId,
			icon = GetSpellTexture(spellId),
			expirationTime = GetTime() + interruptDuration,
			duration = interruptDuration,
			Priority = BattleGroundEnemies:GetSpellPriority(spellId) or 4
		}
		self:Update()
	end

	function frame:CareAboutThisAura(unitID, filter, aura)
		return aura.Priority
	end

	function frame:ShouldQueryAuras(unitID, filter)
		return self.config.showHighestPriority -- we care about all auras
	end

	function frame:BeforeFullAuraUpdate(filter)
		--only wipe before the auras for the first filter come in, otherwise we wipe our buffs away ...
		if filter == "HELPFUL" then
			wipe(self.PriorityAuras)
		end
	end

	function frame:NewAura(unitID, filter, aura)
		if not aura.Priority then return end

		local ID = #self.PriorityAuras + 1

		aura.ID = ID
		self.PriorityAuras[ID] = aura
	end

	function frame:AfterFullAuraUpdate(filter)
		-- only update after the last filter is done
		if filter == "HARMFUL" then
			self:Update()
		end
	end

	function frame:UnitDied()
		self:Reset()
	end

	frame.PlayerDetailsChanged = function(self)
		local playerDetails = playerButton.PlayerDetails
		if not playerDetails then return end

        local specData = playerButton:GetSpecData()
        if specData and self.config.showSpecIfExists then
            self.Icon:SetTexture(specData.specIcon)
        else
            local coords = CLASS_ICON_TCOORDS[playerDetails.PlayerClass]
			if playerDetails.PlayerClass and coords then
				self.Icon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
				self.Icon:SetTexCoord(unpack(coords))
			else
				self.Icon:SetTexture(nil)
			end
        end
		self:CropImage()
	end

	frame.ApplyAllSettings = function(self)

        local moduleSettings = self.config
		self:Show()
		self:PlayerDetailsChanged()
		self.Cooldown:ApplyCooldownSettings(moduleSettings.Cooldown, true, {0, 0, 0, 0.5})
        if not self.config.showHighestPriority then
            self:ResetPriorityData()
        end
		self:MakeSureWeAreOnTop()
	end
	return frame
end

function specClassPriorityOne:AttachToPlayerButton(playerButton)
	playerButton.SpecClassPriorityOne = attachToPlayerButton(playerButton, "specClassPriorityOne")
	return playerButton.SpecClassPriorityOne
end

function specClassPriorityTwo:AttachToPlayerButton(playerButton)
	playerButton.SpecClassPriorityTwo = attachToPlayerButton(playerButton, "specClassPriorityTwo")
	return playerButton.SpecClassPriorityTwo
end

