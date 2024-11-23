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
local GetClassAtlas = GetClassAtlas

local generalDefaults = {
    showSpecIfExists = true,
    showHighestPriority = true
}

local defaultSettings = {
	Enabled = true,
	Parent = "Button",
	Cooldown = {
		FontSize = 12,
	},
    Width = 36,
	ActivePoints = 1,
	Points = {
		{
			Point = "TOPRIGHT",
			RelativeFrame = "Button",
			RelativePoint = "TOPLEFT",
		}
	},
    UseButtonHeightAsHeight = true,
}

local generalOptions = function (location)
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
			name = L.ShowHighestPriority,
			desc = L.ShowHighestPriority_Desc,
			width = "normal",
			order = 2
		},
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
			order = 3,
			args = Data.AddCooldownSettings(location.Cooldown)
		}
	}
end

local SpecClassPriorityOne = BattleGroundEnemies:NewButtonModule({
	moduleName = "SpecClassPriorityOne",
	localizedModuleName = L.SpecClassPriorityOne,
	defaultSettings = defaultSettings,
	generalDefaults = generalDefaults,
	options = options,
	generalOptions = generalOptions,
	events = {"ShouldQueryAuras", "BeforeFullAuraUpdate", "NewAura", "AfterFullAuraUpdate", "GotInterrupted", "UnitDied"},
	enabledInThisExpansion = true
})

local SpecClassPriorityTwo = BattleGroundEnemies:NewButtonModule({
	moduleName = "SpecClassPriorityTwo",
	localizedModuleName = L.SpecClassPriorityTwo,
	defaultSettings = Mixin(defaultSettings, {
        Enabled= false,
        Points = {
            {
                Point = "TOPRIGHT",
                RelativeFrame = "Button",
                RelativePoint = "BOTTOMLEFT",
            }
        }
    }),
	generalDefaults = generalDefaults,
	options = options,
	generalOptions = generalOptions,
	events = {"ShouldQueryAuras", "BeforeFullAuraUpdate", "NewAura", "AfterFullAuraUpdate", "GotInterrupted", "UnitDied"},
	enabledInThisExpansion = true
})


local function attachToPlayerButton(playerButton)
    local frame = CreateFrame("frame", nil, playerButton)
    frame.Background = frame:CreateTexture(nil, 'BACKGROUND')
	frame.Background:SetAllPoints()
	frame.Background:SetColorTexture(0,0,0,0.8)
	frame.PriorityAuras = {}
	frame.ActiveInterrupt = false
	frame.ShowsSpec = false
	frame.SpecClassIcon = frame:CreateTexture(nil, 'BORDER', nil, 2)
	frame.SpecClassIcon:SetAllPoints()
    frame.PriorityIcon = frame:CreateTexture(nil, 'BORDER', nil, 3)
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
                local numClasses = GetNumClasses()
                local localizedClass
                for i = 1, numClasses do -- we could also just save the localized class name it into the button itself, but since its only used for this tooltip no need for that
					local className, classFile, classID = GetClassInfo(i)
					if classFile and classFile == playerDetails.PlayerClass then
                        localizedClass = className
					end
				end
                if not localizedClass then return end

                if playerDetails.PlayerSpecName then
                    GameTooltip:SetText(localizedClass.." ".. playerDetails.PlayerSpecName)
                else
                    return GameTooltip:SetText(localizedClass)
                end
            end
		end)
	end)


	frame:SetScript("OnSizeChanged", function(self, width, height)
        self:CropImage()
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
			frame.SpecClassIcon:Hide()
			frame.DisplayedAura = highestPrioritySpell
			frame.PriorityIcon:Show()
			frame.PriorityIcon:SetTexture(highestPrioritySpell.icon)
			frame.Cooldown:SetCooldown(highestPrioritySpell.expirationTime - highestPrioritySpell.duration, highestPrioritySpell.duration)
		else
			frame.SpecClassIcon:Show()
			frame.DisplayedAura = false
			frame.PriorityIcon:Hide()
			frame.Cooldown:Clear()
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

	function frame:ShouldQueryAuras(unitID, filter)
		return self.config.showHighestPriority
	end

	function frame:BeforeFullAuraUpdate(filter)
		--only wipe before the auras for the first filter come in, otherwise we wipe our buffs away ...
		if filter == "HELPFUL" then
			wipe(self.PriorityAuras)
		end
	end

	function frame:NewAura(unitID, filter, aura)
		if not aura.Priority then return end
        if not self.config.showHighestPriority then return end

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
		self:ResetPriorityData()
	end

    frame.CropImage = function(self)
        local width = self:GetWidth()
        local height = self:GetHeight()
        if width and height and width > 0 and height > 0 then
			if self.ShowsSpec then
				BattleGroundEnemies.CropImage(self.SpecClassIcon, width, height)
			end
            BattleGroundEnemies.CropImage(self.PriorityIcon, width, height)
        end
    end

	frame.ApplyAllSettings = function(self)
		if not self.config then return end
        local moduleSettings = self.config
		self:Show()
		local playerDetails = playerButton.PlayerDetails
		if not playerDetails then return end
		self.ShowsSpec = false

        local specData = playerButton:GetSpecData()
        if specData and self.config.showSpecIfExists then
            self.SpecClassIcon:SetTexture(specData.specIcon)
			self.ShowsSpec = true
        else

			local classIconAtlas = GetClassAtlas and GetClassAtlas(playerDetails.PlayerClass)
			if ( classIconAtlas ) then
				self.SpecClassIcon:SetAtlas(classIconAtlas)
			else
				local coords = CLASS_ICON_TCOORDS[playerDetails.PlayerClass]
				if playerDetails.PlayerClass and coords then
					self.SpecClassIcon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
					self.SpecClassIcon:SetTexCoord(unpack(coords))
				else
					self.SpecClassIcon:SetTexture(nil)
				end
			end
        end
		self:CropImage()
		self.Cooldown:ApplyCooldownSettings(moduleSettings.Cooldown, true, {0, 0, 0, 0.5})
        if not moduleSettings.showHighestPriority then
            self:ResetPriorityData()
        end
		self:MakeSureWeAreOnTop()
	end
	return frame
end

function SpecClassPriorityOne:AttachToPlayerButton(playerButton)
	playerButton.SpecClassPriorityOne = attachToPlayerButton(playerButton)
	return playerButton.SpecClassPriorityOne
end

function SpecClassPriorityTwo:AttachToPlayerButton(playerButton)
	playerButton.SpecClassPriorityTwo = attachToPlayerButton(playerButton)
	return playerButton.SpecClassPriorityTwo
end

