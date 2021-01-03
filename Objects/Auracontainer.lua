local addonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local DebuffTypeColor = DebuffTypeColor
BattleGroundEnemies.Objects.AuraContainer = {}

local function debuffFrameUpdateStatusBorder(debuffFrame)
	local color = DebuffTypeColor[debuffFrame.Type or "none"]
	debuffFrame:SetBackdropBorderColor(color.r, color.g, color.b)
end

local function debuffFrameUpdateStatusText(debuffFrame)
	local color = DebuffTypeColor[debuffFrame.Type or "none"]
	debuffFrame.Cooldown.Text:SetTextColor(color.r, color.g, color.b)
end


function BattleGroundEnemies.Objects.AuraContainer.New(playerButton, type)

	
    local AuraContainer = CreateFrame("Frame", nil, playerButton)
	AuraContainer.Active = {}
	AuraContainer.Inactive = {}
	AuraContainer.type = type

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
	
	AuraContainer.SetIconSize = function(self, size)	
		for identifier, auraFrame in pairs(self.Active) do
			auraFrame:SetSize(size, size)
		end
		for identifier, auraFrame in pairs(self.Inactive) do
			auraFrame:SetSize(size, size)
		end
		self:AuraPositioning()
	end
	
	AuraContainer.Reset = function(self)
		for identifier, auraFrame in pairs(self.Active) do
			auraFrame.Cooldown:Clear()
		end
    end
    
    AuraContainer.ApplySettings = function(self)
		local conf = playerButton.bgSizeConfig
		
		--self:ApplyBackdrop(conf.Auras_Buffs_Container_BorderThickness)

		for identifier, auraFrame in pairs(self.Active) do
            auraFrame:ApplyAuraFrameSettings()
            if type == "debuff" then
                auraFrame:ChangeDisplayType()
            end
		end
	
		for identifier, auraFrame in pairs(self.Inactive) do
            auraFrame:ApplyAuraFrameSettings()
            if type == "debuff" then
                auraFrame:ChangeDisplayType()
            end 
		end
		
		self:SetContainerPosition()
	end
	
	AuraContainer.AuraPositioning = function(self)
        local conf = playerButton.bgSizeConfig
        if self.type == "buff" then
            self:Positioning(conf.Auras_Buffs_Size, conf.Auras_Buffs_VerticalGrowdirection, conf.Auras_Buffs_HorizontalGrowDirection, conf.Auras_Buffs_IconsPerRow, conf.Auras_Buffs_HorizontalSpacing, conf.Auras_Buffs_VerticalSpacing)
        else
            self:Positioning(conf.Auras_Debuffs_Size, conf.Auras_Debuffs_VerticalGrowdirection, conf.Auras_Debuffs_HorizontalGrowDirection, conf.Auras_Debuffs_IconsPerRow, conf.Auras_Debuffs_HorizontalSpacing, conf.Auras_Debuffs_VerticalSpacing)
        end
	end
	
	AuraContainer.SetContainerPosition = function(self)
        local conf = playerButton.bgSizeConfig
        if self.type == "buff" then
		    self:SetPosition(conf.Auras_Buffs_Container_Point, conf.Auras_Buffs_Container_RelativeTo, conf.Auras_Buffs_Container_RelativePoint, conf.Auras_Buffs_Container_OffsetX, conf.Auras_Buffs_Container_OffsetY)
        else
            self:SetPosition(conf.Auras_Debuffs_Container_Point, conf.Auras_Debuffs_Container_RelativeTo, conf.Auras_Debuffs_Container_RelativePoint, conf.Auras_Debuffs_Container_OffsetX, conf.Auras_Debuffs_Container_OffsetY)
        end
    end
	
	AuraContainer.DisplayAura = function (self, spellID, srcName, amount, duration, endTime, debuffType)
		local identifier = spellID..srcName
		local conf = playerButton.bgSizeConfig
		
		local auraFrame = self.Active[identifier]
		if not auraFrame then 
			auraFrame = self.Inactive[#self.Inactive] 
			if auraFrame then --recycle a previous used Frame
				tremove(self.Inactive, #self.Inactive)
				auraFrame:Show()
			end
		end
        if not auraFrame then
            auraFrame = CreateFrame('Frame', nil, self, BackdropTemplateMixin and "BackdropTemplate")
            auraFrame:SetFrameLevel(self:GetFrameLevel() + 5)
            
            
            auraFrame:SetScript("OnEnter", function(self)
                if playerButton.bgSizeConfig.Auras_ShowTooltips then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
                    GameTooltip:SetSpellByID(self.SpellID)
                end
            end)
            
            auraFrame:SetScript("OnLeave", function(self)
                if GameTooltip:IsOwned(self) then
                    GameTooltip:Hide()
                end
            end)
                
            auraFrame.Icon = auraFrame:CreateTexture(nil, "BACKGROUND")
            auraFrame.Icon:SetAllPoints()

            auraFrame.Stacks = BattleGroundEnemies.MyCreateFontString(auraFrame)
            auraFrame.Stacks:SetAllPoints()
            auraFrame.Stacks:SetJustifyH("RIGHT")
            auraFrame.Stacks:SetJustifyV("BOTTOM")

            auraFrame.Cooldown = BattleGroundEnemies.MyCreateCooldown(auraFrame)
            auraFrame.Cooldown:SetScript("OnHide", function() 
                auraFrame.Stacks:SetText("")
                auraFrame:Hide()
                auraFrame.Container.Active[auraFrame.Identifier] = nil
                auraFrame.Container:AuraPositioning()
                auraFrame.Container.Inactive[#auraFrame.Container.Inactive + 1] = auraFrame
            end)
            -- auraFrame.Cooldown:SetScript("OnCooldownDone", function() 
            -- 	auraFrame.Stacks:SetText("")
            -- 	auraFrame:Hide()
            -- 	auraFrame.Active[auraFrame.Identifier] = nil
            -- 	auraFrame.Container:AuraPositioning()
            -- 	auraFrame.Inactive[#auraFrame.Inactive + 1] = auraFrame
            -- end)
            

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
                    self.Stacks:ApplyFontStringSettings(conf.Auras_Buffs_Fontsize, conf.Auras_Buffs_Outline, conf.Auras_Buffs_EnableTextshadow, conf.Auras_Buffs_TextShadowcolor)
                    self.Cooldown:ApplyCooldownSettings(conf.Auras_Buffs_ShowNumbers, true, false)
                    self.Cooldown.Text:ApplyFontStringSettings(conf.Auras_Buffs_Cooldown_Fontsize, conf.Auras_Buffs_Cooldown_Outline, conf.Auras_Buffs_Cooldown_EnableTextshadow, conf.Auras_Buffs_Cooldown_TextShadowcolor)
                    self:SetSize(conf.Auras_Buffs_Size, conf.Auras_Buffs_Size)
                else
                    self.Stacks:SetTextColor(unpack(conf.Auras_Debuffs_Textcolor))
                    self.Stacks:ApplyFontStringSettings(conf.Auras_Debuffs_Fontsize, conf.Auras_Debuffs_Outline, conf.Auras_Debuffs_EnableTextshadow, conf.Auras_Debuffs_TextShadowcolor)
                    self.Cooldown:ApplyCooldownSettings(conf.Auras_Debuffs_ShowNumbers, true, false)
                    self.Cooldown.Text:ApplyFontStringSettings(conf.Auras_Debuffs_Cooldown_Fontsize, conf.Auras_Debuffs_Cooldown_Outline, conf.Auras_Debuffs_Cooldown_EnableTextshadow, conf.Auras_Debuffs_Cooldown_TextShadowcolor)
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
		end
		auraFrame.Identifier = identifier
		auraFrame.SpellID = spellID
		auraFrame.Type = debuffType
		auraFrame.Icon:SetTexture(GetSpellTexture(spellID))
		if amount > 1 then
			auraFrame.Stacks:SetText(amount)
		else
			auraFrame.Stacks:SetText()
        end
        if self.type == "debuff" then
            if playerButton.bgSizeConfig.Auras_Debuffs_Coloring_Enabled then auraFrame:SetType() end
        end
       

		auraFrame.Cooldown:SetCooldown(endTime - duration, duration)
		--BattleGroundEnemies:Debug("SetCooldown", endTime - duration, duration)
		auraFrame:Show()
		self.Active[identifier] = auraFrame
		self:AuraPositioning()
	end
	
	AuraContainer.Positioning = function(self, iconSize, verticalGrowdirection, horizontalGrowdirection, framesPerRow, horizontalSpacing, verticalSpacing)
		local growLeft = horizontalGrowdirection == "leftwards"
		local growUp = verticalGrowdirection == "upwards"
		local previousFrame = self
		self:Show()
		local framesInRow = 0
		local count = 0
		local firstFrameInRow
		local lastFrameInRow
		local width = 0
		local height = 0
		if growLeft then
			if growUp then
				for Identifier, auraFrame in pairs(self.Active) do
					auraFrame:ClearAllPoints()
					if framesInRow <= framesPerRow then
						if count == 0 then
							auraFrame:SetPoint("BOTTOMRIGHT", previousFrame, "BOTTOMRIGHT", 0, 0)
							firstFrameInRow = auraFrame
						else
							auraFrame:SetPoint("RIGHT", previousFrame, "LEFT", -horizontalSpacing, 0)
						end
						framesInRow = framesInRow + 1
						width = width + iconSize + horizontalSpacing
					else
						auraFrame:SetPoint("BOTTOM", firstFrameInRow, "TOP", 0, verticalSpacing)
						framesInRow = 1
						firstFrameInRow = auraFrame
						lastFrameInRow = previousFrame
						height = height + iconSize + verticalSpacing
					end
					previousFrame = auraFrame
					count = count + 1
				end
			else
				for Identifier, auraFrame in pairs(self.Active) do
					auraFrame:ClearAllPoints()
					if framesInRow < framesPerRow then
						if framesInRow == 0 then
							if count == 0 then
								auraFrame:SetPoint("TOPRIGHT", previousFrame, "TOPRIGHT", 0, 0)
								firstFrameInRow = auraFrame
							end
						else
							auraFrame:SetPoint("RIGHT", previousFrame, "LEFT", -horizontalSpacing, 0)
						end
						framesInRow = framesInRow + 1
					else
						auraFrame:SetPoint("TOP", firstFrameInRow, "BOTTOM", 0, -verticalSpacing)
						framesInRow = 1
						firstFrameInRow = auraFrame
                        lastFrameInRow = previousFrame
                        height = height + iconSize + verticalSpacing
					end
					previousFrame = auraFrame
					count = count + 1
				end
			end
		else
			if growUp then
				for Identifier, auraFrame in pairs(self.Active) do
					auraFrame:ClearAllPoints()
					if framesInRow < framesPerRow then
						if framesInRow == 0 then
							if count == 0 then
								auraFrame:SetPoint("BOTTOMLEFT", previousFrame, "BOTTOMLEFT", 0, 0)
								firstFrameInRow = auraFrame
							end
						else
							auraFrame:SetPoint("LEFT", previousFrame, "RIGHT", horizontalSpacing, 0)
						end
						framesInRow = framesInRow + 1
					else
						auraFrame:SetPoint("BOTTOM", firstFrameInRow, "TOP", 0, verticalSpacing)
						framesInRow = 1
						firstFrameInRow = auraFrame
                        lastFrameInRow = previousFrame
                        height = height + iconSize + verticalSpacing
					end
					previousFrame = auraFrame
					count = count + 1
				end
			else
				for Identifier, auraFrame in pairs(self.Active) do
					auraFrame:ClearAllPoints()
					if framesInRow < framesPerRow then
						if framesInRow == 0 then
							if count == 0 then
								auraFrame:SetPoint("TOPLEFT", previousFrame, "TOPLEFT", 0, 0)
								firstFrameInRow = auraFrame
							end
						else
							auraFrame:SetPoint("LEFT", previousFrame, "RIGHT", horizontalSpacing, 0)
						end
						framesInRow = framesInRow + 1
					else
						auraFrame:SetPoint("TOP", firstFrameInRow, "BOTTOM", 0, -verticalSpacing)
						framesInRow = 1
						firstFrameInRow = auraFrame
                        lastFrameInRow = previousFrame
                        height = height + iconSize + verticalSpacing
					end
					previousFrame = auraFrame
					count = count + 1
				end
			end
		end
		if width == 0 then 
			self:Hide()
		else
			self:SetWidth(width - horizontalSpacing)
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

