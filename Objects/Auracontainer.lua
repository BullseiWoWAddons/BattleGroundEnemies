local AddonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local DebuffTypeColor = DebuffTypeColor

local table_insert = table.insert


BattleGroundEnemies.Objects.AuraContainer = {}

local function debuffFrameUpdateStatusBorder(debuffFrame)
	local color = DebuffTypeColor[debuffFrame.DebuffType or "none"]
	debuffFrame:SetBackdropBorderColor(color.r, color.g, color.b)
end

local function debuffFrameUpdateStatusText(debuffFrame)
	local color = DebuffTypeColor[debuffFrame.DebuffType or "none"]
	debuffFrame.Cooldown.Text:SetTextColor(color.r, color.g, color.b)
end


function BattleGroundEnemies.Objects.AuraContainer.New(playerButton, type)


	local AuraContainer = CreateFrame("Frame", nil, playerButton)
	AuraContainer.Auras = {}
	AuraContainer.AuraFrames = {}
	AuraContainer.PriorityAuras = {}
	AuraContainer.type = type
	AuraContainer.filter = type == "debuff" and "HARMFUL" or "HELPFUL"

	AuraContainer:SetScript("OnHide", function(self)
		self:SetWidth(0.001)
		self:SetHeight(0.001)
	end)

	AuraContainer:Hide()

	AuraContainer.SetPosition = function(self, point, relativeTo, relativePoint, offsetX, offsetY)
		self:ClearAllPoints()
		if relativeTo == "Button" then
			relativeTo = playerButton
		else
			relativeTo = playerButton[relativeTo]
		end
		self:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY)
	end

	AuraContainer.Reset = function(self)
		wipe(self.Auras)
		self:AuraUpdateFinished()
	end

	AuraContainer.ApplySettings = function(self)
		local conf = playerButton.bgSizeConfig
		if self.type == "buff" then
			if not conf.Auras_Buffs_Enabled then self:Reset() end
		else
			if not conf.Auras_Debuffs_Enabled then self:Reset() end
		end

		for i = 1, #self.AuraFrames do
			local auraFrame = self.AuraFrames[i]
			auraFrame:ApplyAuraFrameSettings()
			if self.type == "debuff" then
				auraFrame:ChangeDisplayType()
			end
		end

		self:SetContainerPosition()
	end

	AuraContainer.SetContainerPosition = function(self)
		local conf = playerButton.bgSizeConfig
		if self.type == "buff" then
			self:SetPosition(conf.Auras_Buffs_Container_Point, conf.Auras_Buffs_Container_RelativeTo, conf.Auras_Buffs_Container_RelativePoint, conf.Auras_Buffs_Container_OffsetX, conf.Auras_Buffs_Container_OffsetY)
		else
			self:SetPosition(conf.Auras_Debuffs_Container_Point, conf.Auras_Debuffs_Container_RelativeTo, conf.Auras_Debuffs_Container_RelativePoint, conf.Auras_Debuffs_Container_OffsetX, conf.Auras_Debuffs_Container_OffsetY)
		end
	end

	AuraContainer.PrepareForUpdate = function(self)
		wipe(self.Auras)
	end

	AuraContainer.NewAura = function(self, name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, nameplateShowAll, timeMod)

		local filter = self.filter
		if true then
 			BattleGroundEnemies.db.profile.Auras = BattleGroundEnemies.db.profile.Auras or {}
			BattleGroundEnemies.db.profile.Auras[filter] = BattleGroundEnemies.db.profile.Auras[filter] or {}
			BattleGroundEnemies.db.profile.Auras[filter][spellID] = BattleGroundEnemies.db.profile.Auras[filter][spellID] or {
				name = name,
				icon = icon,
				count = count,
				debuffType = debuffType,
				duration = duration,
				expirationTime = expirationTime,
				unitCaster = unitCaster,
				canStealOrPurge = canStealOrPurge,
				nameplateShowPersonal = nameplateShowPersonal,
				spellID = spellID,
				canApplyAura = canApplyAura,
				isBossAura = isBossAura,
				castByPlayer = castByPlayer,
				nameplateShowAll = nameplateShowAll,
				timeMod = timeMod
			}
		end


		if not playerButton:ShouldDisplayAura(false, filter, spellID, unitCaster, canStealOrPurge, canApplyAura, debuffType) then print("didnt make it through the filter") return end

		local conf = playerButton.bgSizeConfig

		local priority = Data.SpellPriorities[spellID]
		local ID = #self.Auras + 1
		local auraDetails = {
			ID = ID,
			SpellID = spellID,
			Icon = icon,
			DebuffType = debuffType,
			Type = self.type,
			Priority = priority,
			Stacks = count,
			ExpirationTime = expirationTime,
			Duration = duration
		}
		self.Auras[ID] = auraDetails
	end

	AuraContainer.AuraUpdateFinished = function(self)

		-- for Spec_HighestActivePriority
		wipe(self.PriorityAuras)
		for i = 1, #self.Auras do
			local auraDetails = self.Auras[i]
			if auraDetails.Priority and self.type == "debuff" then
				table_insert(self.PriorityAuras, auraDetails)
			end
		end
		playerButton.Spec_HighestActivePriority:Update()

		local conf = playerButton.bgSizeConfig
		if self.type == "buff" then
			self:DisplayAuras(conf.Auras_Buffs_Size, conf.Auras_Buffs_VerticalGrowdirection, conf.Auras_Buffs_HorizontalGrowDirection, conf.Auras_Buffs_IconsPerRow, conf.Auras_Buffs_HorizontalSpacing, conf.Auras_Buffs_VerticalSpacing)
		else
			self:DisplayAuras(conf.Auras_Debuffs_Size, conf.Auras_Debuffs_VerticalGrowdirection, conf.Auras_Debuffs_HorizontalGrowDirection, conf.Auras_Debuffs_IconsPerRow, conf.Auras_Debuffs_HorizontalSpacing, conf.Auras_Debuffs_VerticalSpacing)
		end
	end

	AuraContainer.DisplayAuras = function(self, iconSize, verticalGrowdirection, horizontalGrowdirection, framesPerRow, horizontalSpacing, verticalSpacing)
		local growLeft = horizontalGrowdirection == "leftwards"
		local growUp = verticalGrowdirection == "upwards"
		local previousFrame = self
		self:Show()
		local framesInRow = 0
		local count = 0
		local firstFrameInRow
		local width = 0
		local widestRow = 0
		local height = 0
		local pointX, relativePointX, offsetX, offsetY, pointY, relativePointY, pointNewRow, relativePointNewRow

		if growLeft then
			pointX = "RIGHT"
			relativePointX = "LEFT"
			offsetX = -horizontalSpacing
		else
			pointX = "LEFT"
			relativePointX = "RIGHT"
			offsetX = horizontalSpacing
		end

		if growUp then
			pointY = "BOTTOM"
			relativePointY = "BOTTOM"
			pointNewRow = "BOTTOM"
			relativePointNewRow = "TOP"
			offsetY = verticalSpacing
		else
			pointY = "TOP"
			relativePointY = "TOP"
			pointNewRow = "TOP"
			relativePointNewRow = "BOTTOM"
			offsetY = -verticalSpacing
		end

		local numAuras = #self.Auras
		for i = 1, numAuras do
			local auraDetails = self.Auras[i]
			local auraFrame = self.AuraFrames[i]
			if not auraFrame then
				auraFrame = CreateFrame('Frame', nil, self, BackdropTemplateMixin and "BackdropTemplate")
				auraFrame:SetFrameLevel(self:GetFrameLevel() + 5)


				auraFrame:SetScript("OnEnter", function(self)
					BattleGroundEnemies:ShowTooltip(self, function()
						BattleGroundEnemies:ShowAuraTooltip(playerButton, auraFrame.AuraDetails)
					end)
				end)

				auraFrame:SetScript("OnLeave", function(self)
					if GameTooltip:IsOwned(self) then
						GameTooltip:Hide()
					end
				end)

				function auraFrame:Remove()
					table.remove(AuraContainer.Auras, auraFrame.AuraDetails.ID)
					for i = 1, #AuraContainer.Auras do
						local auraDetails = AuraContainer.Auras[i]
						auraDetails.ID = i
					end
					AuraContainer:AuraUpdateFinished()
				end



				auraFrame.Icon = auraFrame:CreateTexture(nil, "BACKGROUND")
				auraFrame.Icon:SetAllPoints()

				auraFrame.Stacks = BattleGroundEnemies.MyCreateFontString(auraFrame)
				auraFrame.Stacks:SetAllPoints()
				auraFrame.Stacks:SetJustifyH("RIGHT")
				auraFrame.Stacks:SetJustifyV("BOTTOM")

				auraFrame.Cooldown = BattleGroundEnemies.MyCreateCooldown(auraFrame)
				auraFrame.Cooldown:SetScript("OnCooldownDone", function(self) -- only do this for the case that we dont get a UNIT_AURA for an ending aura, if we dont do this the aura is stuck even tho its expired
					auraFrame.Remove()
				end)

				auraFrame.Container = self
				auraFrame.Icon:SetDrawLayer("BORDER", -1) -- 1 to make it behind the SetBackdrop bg

				auraFrame:SetBackdrop({
					bgFile = "Interface/Buttons/WHITE8X8", --drawlayer "BACKGROUND"
					edgeFile = 'Interface/Buttons/WHITE8X8', --drawlayer "BORDER"
					edgeSize = 1
				})

				auraFrame:SetBackdropColor(0, 0, 0, 0)
				auraFrame:SetBackdropBorderColor(0, 0, 0, 0)

				auraFrame.ApplyAuraFrameSettings = function(self)
					local conf = playerButton.bgSizeConfig
					local container = self:GetParent()
					if container.type == "buff"	then
						self.Stacks:SetTextColor(unpack(conf.Auras_Buffs_Textcolor))
						self.Stacks:ApplyFontStringSettings(conf.Auras_Buffs_Fontsize, conf.Auras_Buffs_Outline, conf.Auras_Buffs_EnableShadow, conf.Auras_Buffs_ShadowColor)
						self.Cooldown:ApplyCooldownSettings(conf.Auras_Buffs_ShowNumbers, true, false)
						self.Cooldown.Text:ApplyFontStringSettings(conf.Auras_Buffs_Cooldown_Fontsize, conf.Auras_Buffs_Cooldown_Outline, conf.Auras_Buffs_Cooldown_EnableShadow, conf.Auras_Buffs_Cooldown_ShadowColor)
						self:SetSize(conf.Auras_Buffs_Size, conf.Auras_Buffs_Size)
					else
						self.Stacks:SetTextColor(unpack(conf.Auras_Debuffs_Textcolor))
						self.Stacks:ApplyFontStringSettings(conf.Auras_Debuffs_Fontsize, conf.Auras_Debuffs_Outline, conf.Auras_Debuffs_EnableShadow, conf.Auras_Debuffs_ShadowColor)
						self.Cooldown:ApplyCooldownSettings(conf.Auras_Debuffs_ShowNumbers, true, false)
						self.Cooldown.Text:ApplyFontStringSettings(conf.Auras_Debuffs_Cooldown_Fontsize, conf.Auras_Debuffs_Cooldown_Outline, conf.Auras_Debuffs_Cooldown_EnableShadow, conf.Auras_Debuffs_Cooldown_ShadowColor)
						self:SetSize(conf.Auras_Debuffs_Size, conf.Auras_Debuffs_Size)
					end

				end
				if self.type == "debuff" then
					auraFrame.ChangeDisplayType = function(self)
						self:SetDisplayType()

						--reset settings
						self.Cooldown.Text:SetTextColor(1, 1, 1, 1)
						self:SetBackdropBorderColor(0, 0, 0, 0)
						if playerButton.bgSizeConfig.Auras_Debuffs_Coloring_Enabled then self:SetType() end
					end

					auraFrame.SetDisplayType = function(self)
						if playerButton.bgSizeConfig.Auras_Debuffs_DisplayType == "Frame" then
							self.SetType = debuffFrameUpdateStatusBorder
						else
							self.SetType = debuffFrameUpdateStatusText
						end
					end

					auraFrame:SetDisplayType()
				end
				auraFrame:ApplyAuraFrameSettings()
				self.AuraFrames[i] = auraFrame
			end

			auraFrame.AuraDetails = auraDetails

			auraFrame.Stacks:SetText(auraDetails.Stacks > 1 and auraDetails.Stacks)
			if auraDetails.Type == "debuff" then
				if playerButton.bgSizeConfig.Auras_Debuffs_Coloring_Enabled then auraFrame:SetType() end
			end
			auraFrame.Icon:SetTexture(auraDetails.Icon)
			auraFrame.Cooldown:SetCooldown(auraDetails.ExpirationTime - auraDetails.Duration, auraDetails.Duration)
			--BattleGroundEnemies:Debug("SetCooldown", expirationTime - duration, duration)

			auraFrame:ClearAllPoints()
			if framesInRow < framesPerRow then
				if count == 0 then
					auraFrame:SetPoint(pointY..pointX, previousFrame, relativePointY..pointX, 0, 0)
					firstFrameInRow = auraFrame
				else
					auraFrame:SetPoint(pointX, previousFrame, relativePointX, offsetX, 0)
				end
				framesInRow = framesInRow + 1
				width = width + iconSize + horizontalSpacing
				if width > widestRow then
					widestRow = width
				end
			else
				width = 0
				auraFrame:SetPoint(pointNewRow, firstFrameInRow, relativePointNewRow, 0, offsetY)
				framesInRow = 1
				firstFrameInRow = auraFrame
				height = height + iconSize + verticalSpacing
			end
			previousFrame = auraFrame
			count = count + 1
			auraFrame:Show()
		end

		for i = numAuras + 1, #self.AuraFrames do --hide all unused frames
			local auraFrame = self.AuraFrames[i]
			auraFrame:Hide()
		end

		if widestRow == 0 then
			self:Hide()
		else
			self:SetWidth(widestRow - horizontalSpacing)
			self:SetHeight(height + iconSize)
		end
	end
	-- AuraContainer:Show()
	-- AuraContainer:SetBackdrop({
		-- bgFile = "Interface/Buttons/WHITE8X8", --drawlayer "BACKGROUND"
		-- edgeFile = 'Interface/Buttons/WHITE8X8', --drawlayer "BORDER"
		-- edgeSize = 1
	-- })
	-- AuraContainer:SetBackdropColor(1, 1, 1, 1)
	--AuraContainer:SetSize(50,50)

	return AuraContainer
end

