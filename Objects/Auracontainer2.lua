local AddonName, Data = ...
local L = Data.L

local defaultSettings = {
	Scale = 1,
	PositionSetting = "RIGHT",
	Ofsx = 0,
	Ofsy = 0,
	Enabled = true,
	Buffs = {
		Enabled = false,
		Size = 15,
		HorizontalGrowDirection = "leftwards",
		HorizontalSpacing = 1,
		VerticalGrowdirection = "upwards",
		VerticalSpacing = 1,
		IconsPerRow = 8,
		Container_Point = "BOTTOMRIGHT",
		Container_RelativeTo = "Button",
		Container_RelativePoint = "BOTTOMLEFT",
		Container_OffsetX = 2,
		Container_OffsetY = 0,
		Stackfont = {
			Fontsize = 12,
			Outline = "OUTLINE",
			Textcolor = {1, 1, 1, 1},
			EnableTextshadow = true,
			TextShadowcolor = {0, 0, 0, 1},
		},		
		Cooldown = {
			ShowNumbers = true,
			Fontsize = 12,
			Outline = "OUTLINE",
			EnableTextshadow = false,
			TextShadowcolor = {0, 0, 0, 1},
		},
		Filtering = {
			Enabled = false,
			Blizzlike = false,
			ShowMine = true,
			ShowStealOrPurgeable = true,
			DebuffTypeFiltering_Enabled = false,
			DebuffTypeFiltering_Filterlist = {},
			SpellIDFiltering_Enabled = false,
			SpellIDFiltering_Filterlist = {},
		}
	},
	Debuffs = {
		Enabled = false,
		Size = 15,
		HorizontalGrowDirection = "leftwards",
		HorizontalSpacing = 1,
		VerticalGrowdirection = "upwards",
		VerticalSpacing = 1,
		IconsPerRow = 8,
		Container_Point = "BOTTOMRIGHT",
		Container_RelativeTo = "Button",
		Container_RelativePoint = "BOTTOMLEFT",
		Container_OffsetX = 2,
		Container_OffsetY = 0,
		Stackfont = {
			Fontsize = 12,
			Outline = "OUTLINE",
			Textcolor = {1, 1, 1, 1},
			EnableTextshadow = true,
			TextShadowcolor = {0, 0, 0, 1},
		},
		Cooldown = {
			ShowNumbers = true,
			Fontsize = 12,
			Outline = "OUTLINE",
			EnableTextshadow = false,
			TextShadowcolor = {0, 0, 0, 1},
		},
		Filtering = {
			Enabled = false,
			Blizzlike = false,
			ShowMine = true,
			ShowStealOrPurgeable = true,
			DebuffTypeFiltering_Enabled = false,
			DebuffTypeFiltering_Filterlist = {},
			SpellIDFiltering_Enabled = false,
			SpellIDFiltering_Filterlist = {},
		}
	}		
}

local function debuffFrameUpdateStatusBorder(debuffFrame)
	local color = DebuffTypeColor[debuffFrame.DebuffType or "none"]
	debuffFrame:SetBackdropBorderColor(color.r, color.g, color.b)
end

local function debuffFrameUpdateStatusText(debuffFrame)
	local color = DebuffTypeColor[debuffFrame.DebuffType or "none"]
	debuffFrame.Cooldown.Text:SetTextColor(color.r, color.g, color.b)
end

local function AddFilteringSettings(location)
	location = location.Filtering
	return {
		type = "group",
		name = FILTER,
		desc = L.AurasFilteringSettings_Desc,
		get = function(option)
			return Data.GetOption(location, option)
		end,
		set = function(option, ...)
			return Data.SetOption(location, option, ...)
		end,
		disabled = function() return not location.Enabled end,
		order = 9,
		args = {
			Filtering_Enabled = {
				type = "toggle",
				name = L.Filtering_Enabled,
				width = 'normal',
				order = 1
			},
			FilterSettings = {
				type = "group",
				name = L.FilterSettings,
				desc = L.AurasFilteringSettings_Desc,
				disabled = function() return not location.Enabled end,
				order = 2,
				args = {
					Filtering_Mode = {
						type = "select",
						name = L.Auras_Filtering_Mode,
						desc = L.Auras_Filtering_Mode_Desc,
						width = 'normal',
						values = {
							Custom = L.AurasCustomConditions,
							Blizz = L.BlizzlikeAuraFiltering
						},
						order = 1
					},
					CustomFilteringSettings = {
						type = "group",
						name = L.AurasCustomConditions,
						disabled = function() 
							return not location.Filtering_Mode == "Custom" 
						end,
						inline = true,
						order = 2,
						args = {
							CustomFiltering_ConditionsMode = {
								type = "select",
								name = L.Auras_CustomFiltering_ConditionsMode,
								desc = L.Auras_CustomFiltering_ConditionsMode_Desc,
								width = 'normal',
								values = {
									All = L.Auras_CustomFiltering_Conditions_All,
									Any = L.Auras_CustomFiltering_Conditions_Any
								},
								order = 1
							},

							Fake = Data.AddVerticalSpacing(2),
							SourceFilter_Enabled = {
								type = "toggle",
								name = L.SourceFilter,
								order = 3,
							},
							ShowMine = {
								type = "toggle",
								name = L.ShowMine,
								desc = L.ShowMine_Desc:format(L.Debuffs),
								hidden = function() return not (location.Enabled and location.SourceFilter_Enabled) end,
								order = 4,
							},
							Fake1 = Data.AddVerticalSpacing(5),
							DispellFilter_Enabled = {
								type = "toggle",
								name = L.DispellFilter,
								order = 6,
							},
							ShowDispellable = {
								type = "toggle",
								name = L.ShowDispellable,
								desc = L.ShowMine_Desc:format(L.Buffs),
								hidden = function() return not (location.Enabled and location.DispellFilter_Enabled) end,
								order = 7,
							},
							Fake2 = Data.AddVerticalSpacing(8),
							DebuffTypeFiltering_Enabled = {
								type = "toggle",
								name = L.DebuffType_Filtering,
								desc = L.DebuffType_Filtering_Desc,
								width = 'normal',
								order = 9
							},
							DebuffTypeFiltering_Filterlist = {
								type = "multiselect",
								name = "",
								desc = "",
								hidden = function() return not (location.Enabled and location.DebuffTypeFiltering_Enabled) end,
								get = function(option, key)
									return location.DebuffTypeFiltering_Filterlist[key]
								end,
								set = function(option, key, state) -- value = spellname
									location.DebuffTypeFiltering_Filterlist[key] = state
								end,
								width = 'normal',
								values = Data.DebuffTypes[type],
								order = 10
							},
							SpellIDFiltering_Enabled = {
								type = "toggle",
								name = L.SpellID_Filtering,
								order = 11
							},
							SpellIDFiltering_AddSpellID = {
								type = "input",
								name = L.AurasFiltering_AddSpellID,
								desc = L.AurasFiltering_AddSpellID_Desc,
								hidden = function() return not (location.Enabled and location.SpellIDFiltering_Enabled) end,
								get = function() return "" end,
								set = function(option, value, state)
									local spellIDs = {strsplit(",", value)}
									for i = 1, #spellIDs do
										local spellID = tonumber(spellIDs[i])
										location.SpellIDFiltering_Filterlist[spellID] = true
									end
								end,
								width = 'double',
								order = 12
							},
							Fake3 = Data.AddVerticalSpacing(13),
							SpellIDFiltering_Filterlist = {
								type = "multiselect",
								name = L.Filtering_Filterlist,
								desc = L.AurasFiltering_Filterlist_Desc:format(L.debuff),
								hidden = function() return not (location.Enabled and location.SpellIDFiltering_Enabled) end,
								get = function()
									return true --to make it checked
								end,
								set = function(option, value) 
									location.SpellIDFiltering_Filterlist[value] = nil
								end,
								values = function()
									local valueTable = {}
									for spellID in pairs(location.SpellIDFiltering_Filterlist) do
										valueTable[spellID] = spellID..": "..(GetSpellInfo(spellID) or "")
									end
									return valueTable
								end,
								order = 14
							}
						}
					}
				}
			}
		}
	}
end

local function AddAuraSettings(type, location)
	location = location[type]
	
	return {
		Enabled = {
			type = "toggle",
			name = ENABLE,
			desc = _G[SHOW..type],
			order = 1
		},
		Fake = Data.AddVerticalSpacing(2),
		Coloring_Enabled= {
			type = "toggle",
			name = L.Coloring_Enabled,
			desc = L.Coloring_Enabled_Desc,
			disabled = function() return not location.Enabled end,
			order = 3
		},
		DisplayType = {
			type = "select",
			name = L.DisplayType,
			disabled = function() return not location.Coloring_Enabled end,
			values = Data.DisplayType,
			order = 4
		},
		Container_IconSettings = {
			type = "group",
			name = L.DebuffIcon,
			disabled = function() return not location.Enabled end,
			order = 5,
			args = Data.AddIconPositionSettings(location),
		},
		Container_PositioningSettings = {
			type = "group",
			name = L.ContainerPosition,
			disabled = function() return not location.Enabled end,
			args = Data.AddContainerPositionSettings(location),
			order = 6
		},
		StacktextSettings = {
			type = "group",
			name = L.AurasStacktextSettings,
			--desc = L.MyAuraSettings_Desc,
			disabled = function() return not location.Enabled end,
			order = 7,
			args = Data.AddNormalTextSettings(location)
		},
		CooldownTextSettings = {
			type = "group",
			name = L.Countdowntext,
			--desc = L.TrinketSettings_Desc,
			disabled = function() return not location.Enabled end,
			order = 8,
			args = Data.AddCooldownTextsettings(location)
		},
		FilteringSettings = AddFilteringSettings(location)
	}
end

local types = {"BUFFS", "DEBUFFS"}

local auras = BattleGroundEnemies:NewModule("Auras", "Auras", 3, defaultSettings)

function auras:AttachToPlayerButton(playerButton)
	for i = 1, #types do
		local type = types[i]
		
		local auraContainer = CreateFrame("Frame", nil, playerButton)

		auraContainer.Auras = {}
		auraContainer.AuraFrames = {}
		auraContainer.PriorityAuras = {}
		auraContainer.type = type
		auraContainer.filter = type == "DEBUFFS" and "HARMFUL" or "HELPFUL"
	
		auraContainer:SetScript("OnHide", function(self) 
			self:SetWidth(0.001)
			self:SetHeight(0.001)
		end)
		
		auraContainer:Hide()
		
		auraContainer.SetPosition = function(self, point, relativeTo, relativePoint, offsetX, offsetY)
			self:ClearAllPoints()
			if relativeTo == "Button" then 
				relativeTo = playerButton
			else
				relativeTo = playerButton[relativeTo]
			end
			self:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY)
		end
		
		auraContainer.Reset = function(self)
			wipe(self.Auras)
			self:AuraUpdateFinished()
		end
		
		auraContainer.ApplySettings = function(self, moduleConfig)
			if not self.config.Enabled then self:Reset() end
		
			for i = 1, #self.AuraFrames do
				local auraFrame = self.AuraFrames[i]
				auraFrame:ApplyAuraFrameSettings()
				if self.type == "DEBUFFS" then
					auraFrame:ChangeDisplayType()
				end
			end
			
			self:SetContainerPosition()
		end
		
		auraContainer.SetContainerPosition = function(self)
			local conf = self.config
			self:SetPosition(conf.Container_Point, conf.Container_RelativeTo, conf.Container_RelativePoint, conf.Container_OffsetX, conf.Container_OffsetY)
		end
	
		auraContainer.PrepareForUpdate = function(self)
			wipe(self.Auras)
		end
		
		auraContainer.NewAura = function(self, name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, nameplateShowAll, timeMod)
	
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
	
		auraContainer.AuraUpdateFinished = function(self)
			
			-- for Spec_Auradisplay
			wipe(self.PriorityAuras)
			for i = 1, #self.Auras do
				local auraDetails = self.Auras[i]
				if auraDetails.Priority and self.type == "DEBUFFS" then 
					table_insert(self.PriorityAuras, auraDetails)
				end
			end
			playerButton.Spec_AuraDisplay:Update()
	
			local conf = self.config
			self:DisplayAuras(conf.Size, conf.VerticalGrowdirection, conf.HorizontalGrowDirection, conf.IconsPerRow, conf.HorizontalSpacing, conf.VerticalSpacing)
		
		end
	
		auraContainer.DisplayAuras = function(self, iconSize, verticalGrowdirection, horizontalGrowdirection, framesPerRow, horizontalSpacing, verticalSpacing)
			local growLeft = horizontalGrowdirection == "leftwards"
			local growUp = verticalGrowdirection == "upwards"
			local previousFrame = self
			self:Show()
			local framesInRow = 0
			local count = 0
			local firstFrameInRow
			local lastFrameInRow
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
						table.remove(auraContainer.Auras, auraFrame.AuraDetails.ID)
						for i = 1, #auraContainer.Auras do
							local auraDetails = auraContainer.Auras[i]
							auraDetails.ID = i
						end
						auraContainer:AuraUpdateFinished()
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
						local conf = auraContainer.config
						local container = self:GetParent()
					
						local stackTextConfig = conf.Stackfont
						self.Stacks:SetTextColor(unpack(stackTextConfig.Textcolor))
						self.Stacks:ApplyFontStringSettings(stackTextConfig.Fontsize, stackTextConfig.Outline, stackTextConfig.EnableTextshadow, stackTextConfig.TextShadowcolor)
						local cooldownConfig = conf.Cooldown
						self.Cooldown:ApplyCooldownSettings(cooldownConfig.ShowNumbers, true, false)
						self.Cooldown.Text:ApplyFontStringSettings(cooldownConfig.Cooldown_Fontsize, cooldownConfig.Cooldown_Outline, cooldownConfig.Cooldown_EnableTextshadow, cooldownConfig.Cooldown_TextShadowcolor)
						self:SetSize(conf.Size, conf.Size)
					
					
						
					end
					if self.type == "DEBUFFS" then
						auraFrame.ChangeDisplayType = function(self)
							self:SetDisplayType()
							
							--reset settings
							self.Cooldown.Text:SetTextColor(1, 1, 1, 1)
							self:SetBackdropBorderColor(0, 0, 0, 0)
							if auraContainer.config.Coloring_Enabled then self:SetType() end
						end
		
						auraFrame.SetDisplayType = function(self)
							if auraContainer.config.DisplayType == "Frame" then
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
				if auraDetails.Type == "DEBUFFS" then
					if auraContainer.config.Coloring_Enabled then auraFrame:SetType() end
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
					lastFrameInRow = previousFrame
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



		playerButton[type] = auraContainer
	end
end

function auras:ApplyAllSettings(playerButton, moduleSettings)
	for containerName, containerFrame in pairs(playerButton) do
		containerFrame.config = moduleSettings[containerName]
		containerFrame:ApplySettings()
	end
end
