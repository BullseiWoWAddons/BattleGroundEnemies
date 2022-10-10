local AddonName, Data = ...
local L = Data.L

local table_insert = table.insert

local GetSpellInfo = GetSpellInfo
local SpellGetVisibilityInfo = SpellGetVisibilityInfo
local SpellIsPriorityAura = SpellIsPriorityAura
local SpellIsSelfBuff = SpellIsSelfBuff
local UnitAffectingCombat = UnitAffectingCombat
local UnitName = UnitName

local defaults = {
	Enabled = true,
	Parent = "Button",
	Coloring_Enabled = true,
	PriorityAuras = {
		Enabled = true,
		AuraAmount = 3,
		Scale = 1.5,
		OnlyShowPriorityAuras = true,
	},
	Cooldown = {
		ShowNumber = true,
		FontSize = 8,
		FontOutline = "OUTLINE",
		EnableShadow = false,
		ShadowColor = {0, 0, 0, 1},
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
			DurationFilter_CustomMaxDuration = 10
		}
	}
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
	All = function (conditions) --all conditions must evaluate to true to return true
		for k,v in pairs(conditions) do
			if not v then return false end
		end
		return true
	end,
	Any =  function (conditions) --only one of the conditions must evaluate to true to return true
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
	return duration <= config.DurationFilter_CustomMaxDuration
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
						DurationFilter_CustomMaxDuration = {
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
		PriorityAuras = {
			type ="group",
			name = L.PriorityAuras,
			order = 1,
			get = function(option)
				return Data.GetOption(location.PriorityAuras, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.PriorityAuras, option, ...)
			end,
			args = {
				Enabled = {
					type = "toggle",
					name = VIDEO_OPTIONS_ENABLED,
				},
				OnlyShowPriorityAuras = {
					type = "toggle",
					name = L.OnlyShowPriorityAuras,
					desc = L.OnlyShowPriorityAuras_Desc,
					disabled = function() return not location.PriorityAuras.Enabled end,
				},
				AuraAmount = {
					type = "range",
					name = L.PriorityAuras_AuraAmount,
					desc = L.PriorityAuras_AuraAmount_Desc,
					disabled = function() return not location.PriorityAuras.Enabled end,
					min = 1,
					max = 10,
					step = 1,
					order = 16
				},
				Scale = {
					type = "range",
					name = L.PriorityAuras_Scale,
					desc = L.PriorityAuras_Scale_Desc,
					disabled = function() return not location.PriorityAuras.Enabled end,
					min = 1,
					max = 3,
					step = 0.05,
					order = 17
				}
			}
		},
	
		ContainerSettings = {
			type = "group",
			name = L.ContainerIconSettings,
			order = 5,
			get = function(option)
				return Data.GetOption(location.Container, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.Container, option, ...)
			end,
			args = Data.AddContainerSettings(),
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

local buffOptions = function(location)
	return AddAuraSettings(location, "HELPFUL")
end

local debuffOptions = function(location)
	return AddAuraSettings(location, "HARMFUL")
end

local flags = {
	Height = "Dynamic",
	Width = "Dynamic"
}

local events = {"ShouldQueryAuras", "CareAboutThisAura", "BeforeUnitAura", "UnitAura", "AfterUnitAura", "UnitDied"}

local buffs = BattleGroundEnemies:NewButtonModule({
	moduleName = "Buffs",
	localizedModuleName = L.Buffs,
	flags = flags,
	defaultSettings = defaults,
	options = buffOptions,
	events = events,
	expansions = "All"
})
local debuffs = BattleGroundEnemies:NewButtonModule({
	moduleName = "Debuffs",
	localizedModuleName = L.Debuffs,
	flags = flags,
	defaultSettings = defaults,
	options = debuffOptions,
	events = events,
	expansions = "All"
})



local function AttachToPlayerButton(playerButton, filter)
	local auraContainer = CreateFrame("Frame", nil, playerButton)

	auraContainer.Auras = {}
	auraContainer.AuraFrames = {}
	auraContainer.PriorityAuras = {}
	auraContainer.PriorityAuraFrames = {}
	auraContainer.filter = filter

	auraContainer:SetScript("OnHide", function(self)
		self:SetWidth(0.001)
		self:SetHeight(0.001)
	end)

	function auraContainer:Reset()
		wipe(self.Auras)
		wipe(self.PriorityAuras)
		self:AfterUnitAura(self.filter)
	end

	function auraContainer:ShouldQueryAuras(unitID, filter)
		if filter == self.filter then return true end
	end

	function auraContainer:BeforeUnitAura(unitID, filter)
		if not (filter == self.filter) then return end
		wipe(self.Auras)
		wipe(self.PriorityAuras)
	end

	function auraContainer:CareAboutThisAura(unitID, auraInfo, filter, spellID, duration, unitCaster, canStealOrPurge, canApplyAura, debuffType)
		if auraInfo then filter = auraInfo.isHarmful and "HARMFUL" or "HELPFUL" end
		if not (filter == self.filter) then return end

		local config = self.config
		local aurasEnabled, isDebuff
		local isMine
		local blizzlikeFunc
		local filterFunc

		if auraInfo then
			spellID = auraInfo.spellId
			canApplyAura = auraInfo.canApplyAura
			isMine = auraInfo.isFromPlayerOrPlayerPet
			debuffType = auraInfo.debuffType
		else
			isMine = unitCaster and UnitName(unitCaster) == BattleGroundEnemies.PlayerDetails.PlayerName
		end

		if filter == "HARMFUL" then
			isDebuff = true
			blizzlikeFunc = ShouldDisplayDebuffBlizzLike
		else
			isDebuff = false
			blizzlikeFunc = ShouldDisplayBuffBlizzLike
		end

		local filteringConfig = config.Filtering
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
				table_insert(conditions, myAuraFiltering(customFilterConfig, isMine))
			end

			if customFilterConfig.SpellIDFiltering_Enabled then
				table_insert(conditions, spellIDFiltering(customFilterConfig, spellID))
			end
			if customFilterConfig.DebuffTypeFiltering_Enabled then
				table_insert(conditions, debuffTypeFiltering(customFilterConfig, debuffType))
			end

			if not auraInfo then
				if customFilterConfig.DispelFilter_Enabled then
					table_insert(conditions, canStealorPurgeFiltering(customFilterConfig, canStealOrPurge))
				end

				if customFilterConfig.DurationFilter_Enabled then
					table_insert(conditions, maxDurationFiltering(customFilterConfig, duration))
				end
			end

			if conditionFuncs[customFilterConfig.ConditionsMode] and conditionFuncs[customFilterConfig.ConditionsMode](conditions) then
				return true
			end
		end
	end

	function auraContainer:UnitAura(unitID, filter, name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, nameplateShowAll, timeMod, value1, value2, value3, value4)
		if not (filter == self.filter) then return end
		-- only used to gather new auras for the testmode and for testing :)
		-- if true then
		-- 	BattleGroundEnemies.db.profile.Auras = BattleGroundEnemies.db.profile.Auras or {}
		-- 	BattleGroundEnemies.db.profile.Auras[filter] = BattleGroundEnemies.db.profile.Auras[filter] or {}
		-- 	BattleGroundEnemies.db.profile.Auras[filter][spellID] = BattleGroundEnemies.db.profile.Auras[filter][spellID] or {
		-- 		name = name,
		-- 		icon = icon,
		-- 		count = count,
		-- 		debuffType = debuffType,
		-- 		duration = duration,
		-- 		expirationTime = expirationTime,
		-- 		unitCaster = unitCaster,
		-- 		canStealOrPurge = canStealOrPurge,
		-- 		nameplateShowPersonal = nameplateShowPersonal,
		-- 		spellID = spellID,
		-- 		canApplyAura = canApplyAura,
		-- 		isBossAura = isBossAura,
		-- 		castByPlayer = castByPlayer,
		-- 		nameplateShowAll = nameplateShowAll,
		-- 		timeMod = timeMod
		-- 	}
		-- end

		if not auraContainer:CareAboutThisAura(unitID, nil, filter, spellID, duration, unitCaster, canStealOrPurge, canApplyAura, debuffType) then 
			--print("didnt make it through the filter") 
			return
		end
		local ID
		local priority = BattleGroundEnemies:GetBigDebuffsPriority(spellID) or Data.SpellPriorities[spellID]
		local auraDetails = {
			SpellID = spellID,
			Icon = icon,
			DebuffType = debuffType,
			Filter = filter,
			Priority =  priority,
			CanStealOrPurge = canStealOrPurge,
			Count = count,
			ExpirationTime = expirationTime,
			Duration = duration
		}
		if priority then
			ID = #self.PriorityAuras + 1
			auraDetails.ID = ID
			self.PriorityAuras[ID] = auraDetails
		else
			ID = #self.Auras + 1
			auraDetails.ID = ID
			self.Auras[ID] = auraDetails
		end

		-- ID = #self.Auras + 1
		-- auraDetails.ID = ID
		-- self.Auras[ID] = auraDetails
	end

	function auraContainer:AfterUnitAura(filter)
		if not (filter == self.filter) then return end
		self:DisplayAuras()
	end

	function auraContainer:UnitDied()
		self:Reset()
	end

	function auraContainer:Display()
		local previousFrame = self
		local config = self.config.Container
		local verticalGrowdirection = config.VerticalGrowdirection
		local horizontalGrowdirection = config.HorizontalGrowDirection
		local framesPerRow = config.IconsPerRow
		local horizontalSpacing = config.HorizontalSpacing
		local verticalSpacing = config.VerticalSpacing
		local iconSize = config.IconSize

		local growLeft = horizontalGrowdirection == "leftwards"
		local growUp = verticalGrowdirection == "upwards"
		self:Show()
		local framesInRow = 0
		local firstFrameInRow
		local width = 0
		local widestRow = 0
		local height = 0
		local pointX, relativePointX, offsetX, offsetY, pointY, relativePointY, pointNewRowY, relativePointNewRowY

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
			pointNewRowY = "BOTTOM"
			relativePointNewRowY = "TOP"
			offsetY = verticalSpacing
		else
			pointY = "TOP"
			relativePointY = "TOP"
			pointNewRowY = "TOP"
			relativePointNewRowY = "BOTTOM"
			offsetY = -verticalSpacing
		end



		local auraFrames = self.AuraFrames



		local auraTables = {self.PriorityAuras, self.Auras}

		local isPriorityAuras = false
		local numAuras = 0
		for i = 1, #auraTables do
			
			local auraTable = auraTables[i]

			if i == 1 then
				isPriorityAuras = true
			else
				isPriorityAuras = false
			end

			if self.config.PriorityAuras.OnlyShowPriorityAuras and not isPriorityAuras then break end
			
			for j = 1, #auraTable do
				numAuras = numAuras + 1

			
				local auraFrame = auraFrames[numAuras]
				if not auraFrame then
					auraFrame = CreateFrame('Button', nil, self, "CompactAuraTemplate")
					BattleGroundEnemies.AttachCooldownSettings(auraFrame.cooldown)
					if auraContainer.filter == "HARMFUL" then
						--add debufftype border
						auraFrame.border = auraFrame:CreateTexture(nil, "OVERLAY")
						auraFrame.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
						auraFrame.border:SetPoint("TOPLEFT", -1, 1)
						auraFrame.border:SetPoint("BOTTOMRIGHT", 1, -1)
						auraFrame.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
		
					elseif auraContainer.filter == "HELPFUL" then
						-- add dispellable border from targetframe.xml
					-- 	<Layer level="OVERLAY">
					-- 	<Texture name="$parentStealable" parentKey="Stealable" file="Interface\TargetingFrame\UI-TargetingFrame-Stealable" hidden="true" alphaMode="ADD">
					-- 		<Size x="24" y="24"/>
					-- 		<Anchors>
					-- 			<Anchor point="CENTER" x="0" y="0"/>
					-- 		</Anchors>
					-- 	</Texture>
					-- </Layer>
						auraFrame.Stealable = auraFrame:CreateTexture(nil, "OVERLAY")
						auraFrame.Stealable:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Stealable")
						auraFrame.Stealable:SetBlendMode("ADD")
						auraFrame.Stealable:SetPoint("CENTER")
					end
					-- auraFrame:SetBackdrop({
					-- 	bgFile = "Interface/Buttons/WHITE8X8", --drawlayer "BACKGROUND"
					-- 	edgeFile = 'Interface/Buttons/WHITE8X8', --drawlayer "BORDER"
					-- 	edgeSize = 1
					-- })
		
					-- auraFrame:SetBackdropColor(0, 0, 0, 0)
					-- auraFrame:SetBackdropBorderColor(0, 0, 0, 0)
		
					auraFrame:SetScript("OnClick", nil)
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
						table.remove(auraContainer.Auras, self.AuraDetails.ID)
						for i = 1, #auraContainer.Auras do
							local auraDetails = auraContainer.Auras[i]
							auraDetails.ID = i
						end
						auraContainer:AfterUnitAura(auraContainer.filter)
					end
		
		
		
					--auraFrame.Icon = auraFrame:CreateTexture(nil, "BACKGROUND")
					--auraFrame.icon:SetAllPoints()
		
					-- auraFrame.count = BattleGroundEnemies.MyCreateFontString(auraFrame)
					-- auraFrame.count:SetAllPoints()
					-- auraFrame.count:SetJustifyH("RIGHT")
					-- auraFrame.count:SetJustifyV("BOTTOM")
		
					--auraFrame.Cooldown = BattleGroundEnemies.MyCreateCooldown(auraFrame)
					auraFrame.cooldown:SetScript("OnCooldownDone", function(self) -- only do this for the case that we dont get a UNIT_AURA for an ending aura, if we dont do this the aura is stuck even tho its expired
						auraFrame:Remove()
					end)
		
					auraFrame.Container = self
					auraFrame.icon:SetDrawLayer("BORDER", -1) -- 1 to make it behind the SetBackdrop bg
		
		
		
					auraFrame.ApplyAuraFrameSettings = function(self)
						local conf = auraContainer.config
		
						--self.count:ApplyFontStringSettings(conf.StackText)
						local cooldownConfig = conf.Cooldown
						self.cooldown:ApplyCooldownSettings(cooldownConfig, true, false)
						self:SetSize(conf.Container.IconSize, conf.Container.IconSize)
						if auraContainer.filter == "HELPFUL" then
							self.Stealable:SetSize(conf.Container.IconSize + 3, conf.Container.IconSize + 3)
						end
					end
					auraFrame:ApplyAuraFrameSettings()
					self.AuraFrames[numAuras] = auraFrame
				end
		
		
		
				local iSize
				
				if isPriorityAuras then
					local scale = self.config.PriorityAuras.Scale or 1
	
					auraFrame:SetScale(scale)
					iSize = (scale) * iconSize
				else
					auraFrame:SetScale(1)
					iSize = iconSize
				end
		
	
				local auraDetails = auraTable[j]
				auraFrame.AuraDetails = auraDetails
				if self.filter == "HELPFUL" then
					auraFrame.Stealable:SetShown(auraDetails.CanStealOrPurge)
				else
					--HARMFUL
					local debuffType = auraDetails.DebuffType
					local color
					if debuffType then
						color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"]
					else
						color = DebuffTypeColor["none"]
					end
					auraFrame.border:SetVertexColor(color.r, color.g, color.b)

				end

				if auraDetails.Count and auraDetails.Count > 1 then
					auraFrame.count:SetText(auraDetails.Count)
				else
					auraFrame.count:SetText("")
				end
		
		
				auraFrame.icon:SetTexture(auraDetails.Icon)
				auraFrame.cooldown:SetCooldown(auraDetails.ExpirationTime - auraDetails.Duration, auraDetails.Duration)
				--BattleGroundEnemies:Debug("SetCooldown", expirationTime - duration, duration)
		
				auraFrame:ClearAllPoints()
		
		
				if framesInRow < framesPerRow then
					if numAuras == 1 then
						auraFrame:SetPoint(pointY..pointX, previousFrame, pointY..pointX, 0, 0)
						firstFrameInRow = auraFrame
					else
						auraFrame:SetPoint(pointY..pointX, previousFrame, relativePointY..relativePointX, offsetX, 0)
					end
					framesInRow = framesInRow + 1
					width = width + iSize  + horizontalSpacing
					if width > widestRow then
						widestRow = width
					end
				else
					width = 0
					auraFrame:SetPoint(pointNewRowY..pointX, firstFrameInRow, relativePointNewRowY..relativePointX, 0, offsetY)
					framesInRow = 1
					firstFrameInRow = auraFrame
					height = height + iSize + verticalSpacing
				end
				previousFrame = auraFrame
		--		print("previousFrame inside", previousFrame)
				auraFrame:Show()
			end
		
			
		end
		for i = numAuras + 1, #auraFrames do --hide all unused frames
			local auraFrame = auraFrames[i]
			auraFrame:Hide()
		end
	
		if widestRow == 0 then
			self:Hide()
		else
			self:SetWidth(widestRow - horizontalSpacing)
			self:SetHeight(height + iconSize)
		end


	
	end

	function auraContainer:DisplayAuras()

		local previousFrame = self:Display(self.PriorityAuras, self, true)
	end



	function auraContainer:ApplyAllSettings()
		self:DisplayAuras()
		for i = 1, #self.AuraFrames do
			local auraFrame = self.AuraFrames[i]
			auraFrame:ApplyAuraFrameSettings()
		end
		for i = 1, #self.PriorityAuraFrames do
			local priorityAuraFrame = self.PriorityAuraFrames[i]
			priorityAuraFrame:ApplyAuraFrameSettings()
		end
	end
	return auraContainer
end


function buffs:AttachToPlayerButton(playerButton)
	playerButton.Buffs = AttachToPlayerButton(playerButton, "HELPFUL")
end

function debuffs:AttachToPlayerButton(playerButton)
	playerButton.Debuffs = AttachToPlayerButton(playerButton, "HARMFUL")
end










