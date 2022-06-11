local AddonName, Data = ...
local L = Data.L
local filters = {"HELPFUL", "HARMFUL"}

local temp = {
	Enabled = true,
	Icons = {
		Size = 15,
		IconsPerRow = 8,
		HorizontalGrowDirection = "leftwards",
		HorizontalSpacing = 1,
		VerticalGrowdirection = "upwards",
		VerticalSpacing = 1,
	},
	PriorityAuras = {
		Enabled = true,
		AuraAmount = 3,
	},
	Container = {
		Point = "BOTTOMRIGHT",
		RelativeTo = "Button",
		RelativePoint = "BOTTOMLEFT",
		OffsetX = 2,
		OffsetY = 0,
	},
	StackText = {
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
		Mode = "Blizzlike",
		CustomFiltering = {
			ConditionsMode = "",
			SourceFilter_Enabled = false,
			ShowMine = true,
			DispelFilter_Enabled = false,
			CanStealorPurge = true,
			DebuffTypeFiltering_Enabled = false,
			DebuffTypeFiltering_Filterlist = {},
			SpellIDFiltering_Enabled = false,
			SpellIDFiltering_Filterlist = {},
			DurationFilter_Enabled = false,
			DurationFilter_CustomdMaxDuration = 10
		}
	}
}

local defaultSettings = {
	Points = {
		{
			Point = "LEFT",
			relativeFrame = "Button",
			relativePoint = "RIGHT",
			OffsetX = 1
		}
	},
	Enabled = true,
	HELPFUL = temp,
	HARMFUL = temp,		
}

-- CompactUnitFrame_Util_IsPriorityDebuff
local function IsPriorityDebuff(spellID)
	if BattleGroundEnemies.PlayerDetails.PlayerClass == "PALADIN" then
		local isForbearance = (spellID == 25771)
		return isForbearance or SpellIsPriorityAura(spellID);
	else
		return SpellIsPriorityAura(spellID)
	end
end

--Utility Functions copy from CompactUnitFrame_UtilShouldDisplayBuff and mofified
local function ShouldDisplayBuffBlizzLike(unitCaster, spellID, canApplyAura)

	local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT");

	if ( hasCustom ) then
		return showForMySpec or (alwaysShowMine and (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle"));
	else
		return (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") and canApplyAura and not SpellIsSelfBuff(spellID);
	end
end

-- CompactUnitFrame_Util_ShouldDisplayDebuff
local function ShouldDisplayDebuffBlizzLike(unitCaster, spellID, canApplyAura)

	if IsPriorityDebuff(spellID) then return true end

	local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT");
	if ( hasCustom ) then
		return showForMySpec or (alwaysShowMine and (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") );	--Would only be "mine" in the case of something like forbearance.
	else
		return true;
	end
end

local conditionFuncs = {
	All = function (conditions)
		for k,v in pairs(conditions) do 
			if not v then return false end
		end
		return true
	end,
	Any =  function (conditions)
		for k,v in pairs(conditions) do 
			if v then return true end
		end
	end
}

local function myAuraFiltering(config, isMine)
	return config.ShowMine and isMine					
end

local function debuffTypeFiltering(config, debuffType)
	return config.DebuffTypeFiltering_Filterlist[debuffType] 
end

local function spellIDFiltering(config, spellID)
	return not not config.SpellIDFiltering_Filterlist[spellID] -- the not not is necessary for the loop in conditionFuncs, otherwise the for loop does not loop thorugh the item since its nil
end

local function canStealorPurgeFiltering(config, canStealOrPurge)
	return config.CanStealOrPurge and canStealOrPurge
end

local function maxDurationFiltering(config, duration)
	return duration <= config.DurationFilter_Customduration
end



local function debuffFrameUpdateStatusBorder(debuffFrame)
	local color = DebuffTypeColor[debuffFrame.DebuffType or "none"]
	debuffFrame:SetBackdropBorderColor(color.r, color.g, color.b)
end

local function debuffFrameUpdateStatusText(debuffFrame)
	local color = DebuffTypeColor[debuffFrame.DebuffType or "none"]
	debuffFrame.Cooldown.Text:SetTextColor(color.r, color.g, color.b)
end

local function AddFilteringSettings(location, filter)
	return {
		Enabled = {
			type = "toggle",
			name = L.Filtering_Enabled,
			width = 'normal',
			order = 1
		},
		FilterSettings = {
			type = "group",
			name = L.FilterSettings,
			desc = L.AurasFilteringSettings_Desc,
			get = function(option)
				return Data.GetOption(location, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location, option, ...)
			end,
			disabled = function() return not location.Enabled end,
			order = 2,
			args = {
				Mode = {
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
					get = function(option)
						return Data.GetOption(location.CustomFiltering, option)
					end,
					set = function(option, ...)
						return Data.SetOption(location.CustomFiltering, option, ...)
					end,
					inline = true,
					order = 2,
					args = {
						ConditionsMode = {
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
							hidden = function() return not location.CustomFiltering.SourceFilter_Enabled end,
							order = 4,
						},
						Fake1 = Data.AddVerticalSpacing(5),
						DispelFilter_Enabled = {
							type = "toggle",
							name = L.DispellFilter,
							order = 6,
						},
						CanStealorPurge = {
							type = "toggle",
							name = L.ShowDispellable,
							desc = L.ShowMine_Desc:format(L.Buffs),
							hidden = function() return not location.CustomFiltering.DispelFilter_Enabled end,
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
							hidden = function() return not location.CustomFiltering.DebuffTypeFiltering_Enabled end,
							get = function(option, key)
								return location.CustomFiltering.DebuffTypeFiltering_Filterlist[key]
							end,
							set = function(option, key, state) -- value = spellname
								location.CustomFiltering.DebuffTypeFiltering_Filterlist[key] = state
							end,
							width = 'normal',
							values = Data.DebuffTypes[filter],
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
							hidden = function() return not location.CustomFiltering.SpellIDFiltering_Enabled end,
							get = function() return "" end,
							set = function(option, value, state)
								local spellIDs = {strsplit(",", value)}
								for i = 1, #spellIDs do
									local spellID = tonumber(spellIDs[i])
									location.CustomFiltering.SpellIDFiltering_Filterlist[spellID] = true
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
							hidden = function() return not location.CustomFiltering.SpellIDFiltering_Enabled end,
							get = function()
								return true --to make it checked
							end,
							set = function(option, value) 
								location.CustomFiltering.SpellIDFiltering_Filterlist[value] = nil
							end,
							values = function()
								local valueTable = {}
								for spellID in pairs(location.CustomFiltering.SpellIDFiltering_Filterlist) do
									valueTable[spellID] = spellID..": "..(GetSpellInfo(spellID) or "")
								end
								return valueTable
							end,
							order = 14
						},
						DurationFilter_Enabled = {
							type = "toggle",
							name = L.DurationFilter,
							desc = L.DurationFilter_desc,
							order = 15
						},
						DurationFilter_CustomdMaxDuration = {
							type = "range",
							name = L.DurationFilter_OnlyShowWhenDuration,
							desc = L.DurationFilter_OnlyShowWhenDuration_Desc,
							hidden = function() return not location.CustomFiltering.DurationFilter_Enabled end,
							min = 1,
							max = 600,
							step = 1,
							order = 16
						}
					}
				}
			}
		}
	}
end

local function AddAuraSettings(location, filter)	
	return {
		Coloring_Enabled= {
			type = "toggle",
			name = L.Coloring_Enabled,
			desc = L.Coloring_Enabled_Desc,
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
			order = 5,
			args = Data.AddIconPositionSettings(),
		},
		Container_PositioningSettings = {
			type = "group",
			name = L.ContainerPosition,
			get = function(option)
				return Data.GetOption(location.Container, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.Container, option, ...)
			end,
			order = 6,
			args = Data.AddContainerPositionSettings()
		},
		StackTextSettings = {
			type = "group",
			name = L.AurasStackTextSettings,
			--desc = L.MyAuraSettings_Desc,
			get = function(option)
				return Data.GetOption(location.StackText, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.StackText, option, ...)
			end,
			order = 7,
			args = Data.AddNormalTextSettings(location.StackText)
		},
		CooldownSettings = {
			type = "group",
			name = L.Countdowntext,
			--desc = L.MyAuraSettings_Desc,
			get = function(option)
				return Data.GetOption(location.Cooldown, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.Cooldown, option, ...)
			end,
			order = 8,
			args = Data.AddCooldownSettings(location.Cooldown),
		},
		FilteringSettings = {
			type = "group",
			name = L.FilterSettings,
			desc = L.AurasFilteringSettings_Desc,
			get = function(option)
				return Data.GetOption(location.Filtering, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.Filtering, option, ...)
			end,
			order = 9,
			args = AddFilteringSettings(location.Filtering, filter)
		} 
	}
end

local options = function(location) 
	return {
		Auras_BuffsSettings = {
			type = "group",
			name = L.Buffs,
			order = 1,
			get = function(option)
				return Data.GetOption(location.HELPFUL, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.HELPFUL, option, ...)
			end,
			args = AddAuraSettings(location.HELPFUL, "HELPFUL")
		},
		Auras_DebuffsSettings = {
			type = "group",
			name = L.Debuffs,
			order = 2,
			get = function(option)
				return Data.GetOption(location.HARMFUL, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.HARMFUL, option, ...)
			end,
			args = AddAuraSettings(location.HARMFUL, "HARMFUL")
		}
	}
end


local events = {"ShouldQueryAuras", "CareAboutThisAura", "BeforeUnitAura, UnitAura, AfterUnitAura", "UnitDied"}

local auras = BattleGroundEnemies:NewModule("Auras", "Auras", 3, defaultSettings, options, events)

function auras:AttachToPlayerButton(playerButton)
	local frame = CreateFrame("frame", nil, playerButton)

	for i = 1, #filters do
		local filter = filters[i]
		
		local auraContainer = CreateFrame("Frame", nil, frame)

		auraContainer.Auras = {}
		auraContainer.AuraFrames = {}
		auraContainer.PriorityAuras = {}
		auraContainer.filter = filter
	
		auraContainer:SetScript("OnHide", function(self) 
			self:SetWidth(0.001)
			self:SetHeight(0.001)
		end)
		
		auraContainer:Hide()
		
		function auraContainer:SetPosition(point, relativeTo, relativePoint, offsetX, offsetY)
			self:ClearAllPoints()
			if relativeTo == "Button" then 
				relativeTo = frame
			else
				relativeTo = frame[relativeTo]
			end
			self:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY)
		end
		
		function auraContainer:Reset()
			wipe(self.Auras)
			self:AuraUpdateFinished()
		end
		
		function auraContainer:ApplySettings(moduleConfig)
			if not self.config.Enabled then self:Reset() end
		
			for i = 1, #self.AuraFrames do
				local auraFrame = self.AuraFrames[i]
				auraFrame:ApplyAuraFrameSettings()
				if self.filter == "HARMFUL" then
					auraFrame:ChangeDisplayType()
				end
			end
			
			self:SetContainerPosition()
		end
		
		function auraContainer:SetContainerPosition()
			local conf = self.config.Container
			self:SetPosition(conf.Container_Point, conf.Container_RelativeTo, conf.Container_RelativePoint, conf.Container_OffsetX, conf.Container_OffsetY)
		end
	
		function auraContainer:PrepareForUpdate()
			wipe(self.Auras)
		end
		
		function auraContainer:NewAura(name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, nameplateShowAll, timeMod)
	
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
	
			if not frame:CareAboutThisAura(frame, nil, nil, filter, spellID, duration, unitCaster, canStealOrPurge, canApplyAura, debuffType) then print("didnt make it through the filter") return end	
					
			local ID = #self.Auras + 1
			local auraDetails = {
				ID = ID,
				SpellID = spellID,
				Icon = icon,
				DebuffType = debuffType,
				Filter = self.filter,
				Priority =  BattleGroundEnemies:GetBigDebuffsPriority(spellID) or Data.SpellPriorities[spellID],
				Stacks = count,
				ExpirationTime = expirationTime,
				Duration = duration
			}
			self.Auras[ID] = auraDetails
		end
	
		function auraContainer:AuraUpdateFinished()	
			local conf = self.config.Icons
			self:DisplayAuras(conf.Size, conf.VerticalGrowdirection, conf.HorizontalGrowDirection, conf.IconsPerRow, conf.HorizontalSpacing, conf.VerticalSpacing)
		end
	
		function auraContainer:DisplayAuras(iconSize, verticalGrowdirection, horizontalGrowdirection, framesPerRow, horizontalSpacing, verticalSpacing)
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
						local container = self:Getframe()
					
						self.Stacks:ApplyFontStringSettings(conf.StackText)
						local cooldownConfig = conf.Cooldown
						self.Cooldown:ApplyCooldownSettings(cooldownConfig.ShowNumbers, true, false)
						self.Cooldown.Text:ApplyFontStringSettings(cooldownConfig.Cooldown_Fontsize, cooldownConfig.Cooldown_Outline, cooldownConfig.Cooldown_EnableTextshadow, cooldownConfig.Cooldown_TextShadowcolor)
						self:SetSize(conf.Icons.Size, conf.Icons.Size)
					end
					if self.filter == "HARMFUL" then
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
				if auraDetails.Type == "Debuffs" then
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



		frame[filter] = auraContainer
	end

	function frame:CallFuncOnAllContainers(func)
		for i = 1, #filters do
			local filter = filters[i]
	
			local containerFrame = self[filter]
			containerFrame[func](containerFrame)
		end
	end

	function frame:Reset()
		self:CallFuncOnAllContainers("Reset")
	end
		
	function frame:ApplyAllSettings()
		for i = 1, #filters do
			local filter = filters[i]
	
			local containerFrame = self[filter]
			containerFrame.config = self.config
			containerFrame:ApplySettings()
		end
	end

	--[[ auraInfo = {  Optional table of information about changed auras.

	
	Key						Type		Description
	canApplyAura			boolean		Whether or not the player can apply this aura.
	debuffType				string		Type of debuff this aura applies. May be an empty string.
	isBossAura				boolean		Whether or not this aura was applied by a boss.
	isFromPlayerOrPlayerPet	boolean		Whether or not this aura was applied by the player or their pet.
	isHarmful				boolean		Whether or not this aura is a debuff.
	isHelpful				boolean		Whether or not this aura is a buff.
	isNameplateOnly			boolean		Whether or not this aura should appear on nameplates.
	isRaid					boolean		Whether or not this aura meets the conditions of the RAID aura filter.
	name					string		The name of the aura.
	nameplateShowAll		boolean		Whether or not this aura should be shown on all nameplates, instead of just the personal one.
	sourceUnit				UnitId		Token of the unit that applied the aura.
	spellId					number		The spell ID of the aura.
}  ]]

	function frame:CareAboutThisAura(unitID, auraInfo, filter, spellID, duration, unitCaster, canStealOrPurge, canApplyAura, debuffType)
		local config = self.config
		local auraConfig
		local aurasEnabled, isDebuff
		local isMine
		local blizzlikeFunc
		local filterFunc 

		if auraInfo then
			spellID = auraInfo.spellId
			canApplyAura = auraInfo.canApplyAura
			isMine = auraInfo.isFromPlayerOrPlayerPet
			debuffType = auraInfo.debuffType
			filter = auraInfo.isHarmful and "HARMFUL" or "HELPFUL"
		else
			isMine = unitCaster and UnitName(unitCaster) == BattleGroundEnemies.PlayerDetails.PlayerName
		end

		if filter == "HARMFUL" then
			isDebuff = true
			blizzlikeFunc = ShouldDisplayDebuffBlizzLike
			auraConfig = config.Debuffs
		else
			isDebuff = false
			auraConfig = config.Buffs
			blizzlikeFunc = ShouldDisplayBuffBlizzLike
		end


		if not auraConfig.Enabled then return false end		
		local filteringConfig = auraConfig.Filtering
		if not filteringConfig.Enabled then 
			return true
		end
		if filteringConfig.Mode == "Blizz" then
			if blizzlikeFunc(unitCaster, spellID, canApplyAura) then
				return true
			end
		else --custom filtering

			local conditions = {}
			local customFilterConfig = filteringConfig.CustomFiltering

			if customFilterConfig.SourceFilter_Enabled then
				table_insert(conditions, myAuraFiltering(auraConfig, isMine))
			end
			
			if customFilterConfig.SpellIDFiltering_Enabled then
				table_insert(conditions, spellIDFiltering(auraConfig, spellID))
			end
			if customFilterConfig.DebuffTypeFiltering_Enabled then
				table_insert(conditions, debuffTypeFiltering(auraConfig, debuffType))
			end

			if not auraInfo then
				if customFilterConfig.DispelFilter_Enabled then
					table_insert(conditions, canStealorPurgeFiltering(config, canStealOrPurge))
				end
		
				if customFilterConfig.DurationFilter_Enabled then
					table_insert(conditions, maxDurationFiltering(config, duration))
				end
			end

			if conditionFuncs[customFilterConfig.CustomFiltering_ConditionsMode] and conditionFuncs[customFilterConfig.CustomFiltering_ConditionsMode](conditions) then
				return true
			end
		end
	end

	function frame:ShouldQueryAuras(unitID, filter)
		return self[filter].config.Enabled 
	end

	function frame:BeforeUnitAura(filter)
		self[filter]:PrepareForUpdate()
	end

	function frame:UnitAura(unitID, filter, ...)
		self[filter]:NewAura(unitID, filter, ...)
	end

	function frame:AfterUnitAura(filter)
		self[filter]:AuraUpdateFinished()
	end

	function frame:UnitDied()
		self:Reset()
	end
	playerButton.Auras = frame
end








