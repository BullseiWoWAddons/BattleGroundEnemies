local addonName, Data = ...
local GetAddOnMetadata = GetAddOnMetadata

local L = LibStub("AceLocale-3.0"):GetLocale("BattleGroundEnemies")
local LSM = LibStub("LibSharedMedia-3.0")
local DRData = LibStub("DRData-1.0")


function copy(obj)
	if type(obj) ~= 'table' then return obj end
	local res = {}
	for k, v in pairs(obj) do res[copy(k)] = copy(v) end
	return res
end

local function OptionsType(option)

	local playerType, IsGeneralsetting
	if option[1] == "EnemySettings" then
		playerType = "Enemies"
	elseif option[1] == "AllySettings" then
		playerType = "Allies"
	end
	
	if playerType and option[2] == "GeneralSettings" then
		IsGeneralsetting = true
	end
	
	
	return playerType, IsGeneralsetting
end

local function Optionslocation(option)
	local playerType, IsGeneralsetting = OptionsType(option)
	local location = BattleGroundEnemies.db.profile
	
	if playerType then
		location = location[playerType]
		if not IsGeneralsetting then
			location = location[option[2]] -- its an BGSize option
		end
	end
	return location
end

local function getOption(option)
	local location = Optionslocation(option)
	local value = location[option[#option]]
	if type(value) == "table" then
		--print("is table")
		return unpack(value)
	else
		return value
	end
end

local function setOption(option, value)
	-- local setting = BattleGroundEnemies.db
	-- for i = 1, #option do
		-- setting = setting[option[i]]
	-- end
	-- setting = value
	print(option.arg, value, option[0], option[1], option[2], option[3], option[4])
	local location = Optionslocation(option)
	--print(type(value), value)
	-- BattleGroundEnemies:Debug(key, value)
	-- BattleGroundEnemies:Debug(unpack(value))
	location[option[#option]] = value
	
	--BattleGroundEnemies.db.profile[key] = value
end

local function CallInDeepness(obj, fixedsubtable, subtablename, subsubtablename, func, ...)
	if fixedsubtable then obj = obj[fixedsubtable] end
	if subtablename then 
		obj = obj[subtablename] 
		if subsubtablename then 
			obj = obj[subsubtablename] 
		end
	end
	
	--print(func, ...)
	obj[func](obj, ...)
end

local function ApplySettingsToButton(playerButton, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename, func, ...)
	if loopInButton1 then
		for k, obj in pairs(playerButton[loopInButton1]) do
			CallInDeepness(obj, fixedsubtable, subtablename, subsubtablename, func, ...)
		end
		if loopInButton2 then
			for k, obj in pairs(playerButton[loopInButton2]) do
				CallInDeepness(obj, fixedsubtable, subtablename, subsubtablename, func, ...)
			end
		end
	else
		CallInDeepness(playerButton, fixedsubtable, subtablename, subsubtablename, func, ...)
	end
end


local function UpdateButtons(option, value, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename, func, ...)
	setOption(option, value)	
	
	local playerType, IsGeneralsetting = OptionsType(option)
	
	print("IsEnemyOrAlly:", IsEnemyOrAlly, "playerType:", playerType)
	
	if playerType and not IsGeneralsetting and BattleGroundEnemies.BGSize ~= tonumber(option[2]) then return end
	
	
	for name, playerButton in pairs(BattleGroundEnemies[playerType].Players) do
		ApplySettingsToButton(playerButton, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename, func, ...)
	end
	for i = 1, #BattleGroundEnemies[playerType].InactivePlayerButtons do
		local playerButton = BattleGroundEnemies[playerType].InactivePlayerButtons[i]
		ApplySettingsToButton(playerButton, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename, func, ...)
	end
end


local function ApplySetting(option, value, LoopOverButtons, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename, func, ...)
	setOption(option, value)
	
	if LoopOverButtons then
		UpdateButtons(option, value, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename, func, ...)
	else
		local playerType = option[1] == "EnemySettings" and "Enemies" or "Allies"
		CallInDeepness(BattleGroundEnemies[playerType], fixedsubtable, subtablename, subsubtablename, func, ...)
	end
end

local function ApplySettingToEnemiesAndAllies(option, value, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename, func, ...)
	setOption(option, value)	
	for number, playerType in pairs({BattleGroundEnemies.Allies, BattleGroundEnemies.Enemies}) do
		for name, playerButton in pairs(playerType.Players) do
			ApplySettingsToButton(playerButton, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename, func, ...)
		end
		for i = 1, #playerType.InactivePlayerButtons do
			local playerButton = playerType.InactivePlayerButtons[i]
			ApplySettingsToButton(playerButton, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename, func, ...)
		end
	end
end

local function addVerticalSpacing(order)
	local verticalSpacing = {
		type = "description",
		name = " ",
		fontSize = "large",
		width = "full",
		order = order
	}
	return verticalSpacing
end

local function addHorizontalSpacing(order)
	local horizontalSpacing = {
		type = "description",
		name = " ",
		width = "half",	
		order = order,
	}
	return horizontalSpacing
end



local function applyMainfont(playerButton, value)
	local conf = playerButton.bgSizeConfig
	playerButton.Name:SetFont(LSM:Fetch("font", value), conf.Name_Fontsize, conf.Name_Outline)
	playerButton.NumericTargetindicator:SetFont(LSM:Fetch("font", value), conf.NumericTargetindicator_Fontsize, conf.NumericTargetindicator_Outline)
	playerButton.ObjectiveAndRespawn.AuraText:SetFont(LSM:Fetch("font", value), conf.ObjectiveAndRespawn_Fontsize, conf.ObjectiveAndRespawn_Outline)
	playerButton.Trinket.Cooldown.Text:SetFont(LSM:Fetch("font", value), conf.Trinket_Cooldown_Fontsize, conf.Trinket_Cooldown_Outline)
	playerButton.Racial.Cooldown.Text:SetFont(LSM:Fetch("font", value), conf.Racial_Cooldown_Fontsize, conf.Racial_Cooldown_Outline)

	for spellID, frame in pairs(playerButton.MyAuras) do
		frame.Stacks:SetFont(LSM:Fetch("font", value), conf.MyAuras_Fontsize, conf.MyAuras_Outline)
		frame.Cooldown.Text:SetFont(LSM:Fetch("font", value), conf.MyAuras_Cooldown_Fontsize, conf.MyAuras_Cooldown_Outline)
	end
	for spellID, frame in pairs(playerButton.InactiveAuras) do
		frame.Stacks:SetFont(LSM:Fetch("font", value), conf.MyAuras_Fontsize, conf.MyAuras_Outline)
		frame.Cooldown.Text:SetFont(LSM:Fetch("font", value), conf.MyAuras_Cooldown_Fontsize, conf.MyAuras_Cooldown_Outline)
	end
	for drCat, drFrame in pairs(playerButton.DR) do
		drFrame.Cooldown.Text:SetFont(LSM:Fetch("font", value), conf.DrTracking_Cooldown_Fontsize, conf.DrTracking_Cooldown_Outline)
	end
end

local function addNormalTextSettings(playerType, BGSize, optionname, maindisable, LoopOverButtons, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename)
	local fontsize = optionname.."_Fontsize"
	local textcolor = optionname.."_Textcolor"
	local outline = optionname.."_Outline"
	local enableTextShadow = optionname.."_EnableTextshadow"
	local textShadowcolor = optionname.."_TextShadowcolor"
	
	local conf = BattleGroundEnemies.db.profile[playerType][BGSize]
	
	local options = {
		[fontsize] = {
			type = "range",
			name = L.Fontsize,
			desc = L[fontsize.."_Desc"],
			disabled = function() return maindisable and not conf[maindisable] end,
			set = function(option, value)
				ApplySetting(option, value, LoopOverButtons, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename, "SetFont", LSM:Fetch("font", BattleGroundEnemies.db.profile.Font), value, conf[outline])
			end,
			min = 1,
			max = 40,
			step = 1,
			width = "normal",
			order = 1
		},
		[outline] = {
			type = "select",
			name = L.Font_Outline,
			desc = L.Font_Outline_Desc,
			disabled = function() return maindisable and not conf[maindisable] end,
			set = function(option, value)
				ApplySetting(option, value, LoopOverButtons, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename, "SetFont", LSM:Fetch("font", BattleGroundEnemies.db.profile.Font), conf[fontsize], value)
			end,
			values = Data.FontOutlines,
			order = 2
		},
		Fake = addVerticalSpacing(3),
		[textcolor] = {
			type = "color",
			name = L.Fontcolor,
			desc = L[textcolor.."_Desc"],
			disabled = function() return maindisable and not conf[maindisable] end,
			set = function(option, ...)
				local color = {...}
				ApplySetting(option, color, LoopOverButtons, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename, "SetTextColor", ...)
			end,
			hasAlpha = true,
			width = "half",
			order = 4
		},
		[enableTextShadow] = {
			type = "toggle",
			name = L.FontShadow_Enabled,
			desc = L.FontShadow_Enabled_Desc,
			disabled = function() return maindisable and not conf[maindisable] end,
			set = function(option, value)
				ApplySetting(option, value, LoopOverButtons, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename, "EnableShadowColor", value)
			end,
			order = 5
		},
		[textShadowcolor] = {
			type = "color",
			name = L.FontShadowColor,
			desc = L.FontShadowColor_Desc,
			disabled = function() return maindisable and not conf[maindisable] or not conf[enableTextShadow] end,
			set = function(option, ...)
				local color = {...}
				ApplySetting(option, color, LoopOverButtons, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename, "SetShadowColor", ...)
			end,
			hasAlpha = true,
			order = 6
		}
	}
	return options
end



local function addCooldownTextsettings(playerType, BGSize, optionname, maindisable, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename)
	local showNumbers = optionname.."_ShowNumbers"
	local fontsize = optionname.."_Cooldown_Fontsize"
	local outline = optionname.."_Cooldown_Outline"
	local enableTextShadow = optionname.."_Cooldown_EnableTextshadow"
	local textShadowcolor = optionname.."_Cooldown_TextShadowcolor"	
	
	local mainconfig = BattleGroundEnemies.db.profile
	
	local conf = BattleGroundEnemies.db.profile[playerType][BGSize]

	local options = {
		[showNumbers] = {
			type = "toggle",
			name = L.ShowNumbers,
			desc = L[showNumbers.."_Desc"],
			set = function(option, value)
				UpdateButtons(option, value, loopInButton1, loopInButton2, fixedsubtable, "Cooldown", subsubtablename, "SetHideCountdownNumbers", not value)
			end,
			order = 1
		},
		asdfasdf = {
			type = "group",
			name = "",
			desc = "",
			disabled = function() return maindisable and not conf[maindisable] or not conf[showNumbers] end, 
			inline = true,
			order = 2,
			args = {
				[fontsize] = {
					type = "range",
					name = L.Fontsize,
					desc = L[fontsize.."_Desc"],
					set = function(option, value)
						UpdateButtons(option, value, loopInButton1, loopInButton2, fixedsubtable, "Cooldown", "Text", "SetFont", LSM:Fetch("font", mainconfig.Font), value, conf[outline])
					end,
					min = 6,
					max = 40,
					step = 1,
					width = "normal",
					order = 3
				},
				[outline] = {
					type = "select",
					name = L.Font_Outline,
					desc = L.Font_Outline_Desc,
					set = function(option, value)
						UpdateButtons(option, value, loopInButton1, loopInButton2, fixedsubtable, "Cooldown", "Text", "SetFont", LSM:Fetch("font", mainconfig.Font), conf[fontsize], value)
					end,
					values = Data.FontOutlines,
					order = 4
				},
				Fake1 = addVerticalSpacing(5),
				[enableTextShadow] = {
					type = "toggle",
					name = L.FontShadow_Enabled,
					desc = L.FontShadow_Enabled_Desc,
					set = function(option, value)
						UpdateButtons(option, value, loopInButton1, loopInButton2, fixedsubtable, "Cooldown", "Text", "EnableShadowColor", value, conf[textShadowcolor])
					end,
					order = 6
				},
				[textShadowcolor] = {
					type = "color",
					name = L.FontShadowColor,
					desc = L.FontShadowColor_Desc,
					disabled = function() return maindisable and not conf[maindisable] or not conf[showNumbers] or not conf[enableTextShadow] end, 
					set = function(option, ...)
						local color = {...}
						UpdateButtons(option, color, loopInButton1, loopInButton2, fixedsubtable, "Cooldown", "Text", "EnableShadowColor", conf[enableTextShadow], color)
					end,
					hasAlpha = true,
					order = 7
				}
			}
		}
	}
	return options
end

local function addEnemyAndAllySettings(self)
	local playerType = self.PlayerType
	local oppositePlayerType = playerType == "Enemies" and "Allies" or "Enemies"
	local settings = {}
	
	settings.GeneralSettings = {
		type = "group",
		name = GENERAL,
		desc = L["GeneralSettings"..playerType],
		get =  function(option)
			local value = option.arg and self.config[option.arg] or self.config[option[#option]]
			if type(value) == "table" then
				--print("is table")
				return unpack(value)
			else
				return value
			end
		end,
		--childGroups = "tab",
		order = 1,
		args = {
			Enabled = {
				type = "toggle",
				name = ENABLE,
				desc = "test",
				set = function(option, value) 
					setOption(option, value)
					self:CheckIfEnabled()
				end,
				order = 1
			},
			Fake = addHorizontalSpacing(2),
			Fake1 = addHorizontalSpacing(3),
			Fake2 = addHorizontalSpacing(4),
			CopySettings = {
				type = "execute",
				name = L.CopySettings:format(oppositePlayerType),
				desc = L.CopySettings_Desc:format(oppositePlayerType),
				func = function()
					print(playerType, oppositePlayerType)
					BattleGroundEnemies.db.profile[playerType] = copy(BattleGroundEnemies.db.profile[oppositePlayerType])
					BattleGroundEnemies:ProfileChanged()
				end,
				order = 5
			},
			RangeIndicator_Settings = {
				type = "group",
				name = L.RangeIndicator_Settings,
				desc = L.RangeIndicator_Settings_Desc,
				order = 6,
				args = {
					RangeIndicator_Enabled = {
						type = "toggle",
						name = L.RangeIndicator_Enabled,
						desc = L.RangeIndicator_Enabled_Desc,
						set = function(option, value) 
							UpdateButtons(option, value, nil, nil, "RangeIndicator_Frame", nil, nil, "SetAlpha", value and self.config.RangeIndicator_Alpha or 1)
						end,
						order = 1
					},
					RangeIndicator_Range = {
						type = "select",
						name = L.RangeIndicator_Range,
						desc = L.RangeIndicator_Range_Desc,
						disabled = function() return not self.config.RangeIndicator_Enabled end,
						get = function() return Data[playerType.."ItemIDToRange"][self.config.RangeIndicator_Range] end,
						set = function(option, value)
							value = Data[playerType.."RangeToItemID"][value]
							setOption(option, value)
						end,
						values = Data[playerType.."RangeToRange"],
						width = "half",
						order = 2
					},
					RangeIndicator_Alpha = {
						type = "range",
						name = L.RangeIndicator_Alpha,
						desc = L.RangeIndicator_Alpha_Desc,
						disabled = function() return not self.config.RangeIndicator_Enabled end,
						min = 0,
						max = 1,
						step = 0.05,
						order = 3
					},
					RangeIndicator_Frame = {
						type = "select",
						name = L.RangeIndicator_Frame,
						desc = L.RangeIndicator_Frame_Desc,
						disabled = function() return not self.config.RangeIndicator_Enabled end,
						set = function(option, value) 
							UpdateButtons(option, value, nil, nil, nil, nil, nil, "SetRangeIncicatorFrame")
						end,
						values = {All = L.Everything, PowerAndHealth = L.HealthBarSettings.." "..L.AND.." "..L.PowerBarSettings},
						width = "double",
						order = 4
					}
				}
			},
			Name = {
				type = "group",
				name = L.Name,
				desc = L.Name_Desc,
				order = 7,
				args = {
					ConvertCyrillic = {
						type = "toggle",
						name = L.ConvertCyrillic,
						desc = L.ConvertCyrillic_Desc,
						set = function(option, value)
							UpdateButtons(option, value, nil, nil, nil, nil, nil, "SetName")
						end,
						width = "normal",
						order = 1
					},
					ShowRealmnames = {
						type = "toggle",
						name = L.ShowRealmnames,
						desc = L.ShowRealmnames_Desc,
						set = function(option, value)
							UpdateButtons(option, value, nil, nil, nil, nil, nil, "SetName")
						end,
						width = "normal",
						order = 2
					}
				}
			},
			KeybindSettings = {
				type = "group",
				name = KEY_BINDINGS,
				desc = L.KeybindSettings_Desc,
				disabled = InCombatLockdown,
				set = function(option, value) 
					UpdateButtons(option, value, nil, nil, nil, nil, nil, "SetBindings")
				end,
				--childGroups = "tab",
				order = 9,
				args = {
					LeftButtonType = {
						type = "select",
						name = KEY_BUTTON1,
						values = Data.Buttons,
						order = 1
					},
					LeftButtonValue = {
						type = "input",
						name = ENTER_MACRO_LABEL,
						desc = L.CustomMacro_Desc,
						disabled = function() return self.config.LeftButtonType == "Target" or self.config.LeftButtonType == "Focus" end,
						multiline = true,
						width = 'double',
						order = 2
					},
					Fake = addVerticalSpacing(3),
					RightButtonType = {
						type = "select",
						name = KEY_BUTTON2,
						values = Data.Buttons,
						order = 4
					},
					RightButtonValue = {
						type = "input",
						name = ENTER_MACRO_LABEL,
						desc = L.CustomMacro_Desc,
						disabled = function() return self.config.RightButtonType == "Target" or self.config.RightButtonType == "Focus" end,
						multiline = true,
						width = 'double',
						order = 5
					},
					Fake1 = addVerticalSpacing(6),
					MiddleButtonType = {
						type = "select",
						name = KEY_BUTTON3,
						values = Data.Buttons,
						order = 7
					},
					MiddleButtonValue = {
						type = "input",
						name = ENTER_MACRO_LABEL,
						desc = L.CustomMacro_Desc,
						disabled = function() return self.config.MiddleButtonType == "Target" or self.config.MiddleButtonType == "Focus" end,
						multiline = true,
						width = 'double',
						order = 8
					}
				}
			}
		}
	}
	

	for k, BGSize in pairs({"15", "40"}) do
		settings[BGSize] = {
			type = "group", 
			name = L["BGSize_"..BGSize],
			desc = L["BGSize_"..BGSize.."_Desc"]:format(L[playerType]),
			disabled = function() return not self.config.Enabled end,
			order = k + 1, 
			args = {
				Enabled = {
					type = "toggle",
					name = ENABLE,
					desc = "test",
					set = function(option, value) 
						setOption(option, value)
						self:CheckIfEnabled()
					end,
					order = 1
				},
				Fake = addHorizontalSpacing(2),
				CopySettings = {
					type = "execute",
					name = L.CopySettings:format(oppositePlayerType..": "..L["BGSize_"..BGSize]),
					desc = L.CopySettings_Desc:format(oppositePlayerType..": "..L["BGSize_"..BGSize]),
					func = function()
						print(playerType, oppositePlayerType)
						BattleGroundEnemies.db.profile[playerType][BGSize] = copy(BattleGroundEnemies.db.profile[oppositePlayerType][BGSize])
						if BattleGroundEnemies.BGSize and BattleGroundEnemies.BGSize == tonumber(BGSize) then BattleGroundEnemies:ProfileChanged() end
						
					end,
					width = "double",
					order = 3
				},
				MainFrameSettings = {
					type = "group",
					name = L.MainFrameSettings,
					desc = L.MainFrameSettings_Desc:format(L[playerType == "Enemies" and "enemies" or "allies"]),
					disabled = function() return not self.config[BGSize].Enabled end,
					--childGroups = "tab",
					order = 4,
					args = {
						Framescale = {
							type = "range",
							name = L.Framescale,
							desc = L.Framescale_Desc,
							disabled = InCombatLockdown,
							set = function(option, value)
								setOption(option, value)
								if BattleGroundEnemies.BGSize ~= tonumber(BGSize) then return end
								self:SetScale(value)
							end,
							min = 0.3,
							max = 2,
							step = 0.05,
							order = 1
						},
						PlayerCount = {
							type = "group",
							name = L.PlayerCount_Enabled,
							order = 2,
							inline = true,
							args = {
								PlayerCount_Enabled = {
									type = "toggle",
									name = L.PlayerCount_Enabled,
									desc = L.PlayerCount_Enabled_Desc,
									set = function(option, value)
										setOption(option, value)
										if BattleGroundEnemies.BGSize ~= tonumber(BGSize) then return end
									
										self.PlayerCount:SetShown(value)
									end,
									order = 1
								},
								PlayerCountTextSettings = {
									type = "group",
									name = "",
									--desc = L.TrinketSettings_Desc,
									disabled = function() return not self.config[BGSize].PlayerCount_Enabled end,
									inline = true,
									order = 2,
									args = addNormalTextSettings(playerType, BGSize, "PlayerCount", "PlayerCount_Enabled", false, false, false, "PlayerCount")
								}
							}
						}
					}
				},
				BarSettings = {
					type = "group",
					name = L.BarSettings,
					desc = L.BarSettings_Desc,
					disabled = function() return not self.config[BGSize].Enabled end,
					--childGroups = "tab",
					order = 5,
					args = {
						BarWidth = {
							type = "range",
							name = L.Width,
							desc = L.BarWidth_Desc,
							disabled = InCombatLockdown,
							set = function(option, value)
								if BattleGroundEnemies.BGSize and BattleGroundEnemies.BGSize == tonumber(BGSize) then self:SetWidth(value) end
								UpdateButtons(option, value, nil, nil, nil, nil, nil, "SetWidth", value)
							end,
							min = 1,
							max = 400,
							step = 1,
							order = 1
						},
						BarHeight = {
							type = "range",
							name = L.Height,
							desc = L.BarHeight_Desc,
							disabled = InCombatLockdown,
							set = function(option, value) 
								UpdateButtons(option, value, nil, nil, nil, nil, nil, "SetHeight", value)
							end,
							min = 1,
							max = 40,
							step = 1,
							order = 2
						},
						BarVerticalGrowdirection = {
							type = "select",
							name = L.VerticalGrowdirection,
							desc = L.VerticalGrowdirection_Desc,
							set = function(option, value) 
								setOption(option, value)
								if BattleGroundEnemies.BGSize ~= tonumber(BGSize) then return end
								
								self:ButtonPositioning()
								self:SetPlayerCountJustifyV(value)
							end,
							values = {upwards = L.Upwards, downwards = L.Downwards},
							order = 3
						},
						BarVerticalSpacing = {
							type = "range",
							name = L.SpaceBetweenRows,
							desc = L.SpaceBetweenRows_Desc,
							set = function(option, value) 
								setOption(option, value)
								if BattleGroundEnemies.BGSize ~= tonumber(BGSize) then return end
								
								self:ButtonPositioning()
							end,
							min = 0,
							max = 20,
							step = 1,
							order = 4
						},
						BarColumns = {
							type = "range",
							name = L.Columns,
							set = function(option, value) 
								setOption(option, value)
								if BattleGroundEnemies.BGSize ~= tonumber(BGSize) then return end
								
								self:ButtonPositioning()
							end,
							min = 1,
							max = 4,
							step = 1,
							order = 5
						},
						BarHorizontalGrowdirection = {
							type = "select",
							name = L.VerticalGrowdirection,
							desc = L.VerticalGrowdirection_Desc,
							hidden = function() return not self.config[BGSize].Enabled or self.config[BGSize].BarColumns < 2 end,
							set = function(option, value) 
								setOption(option, value)
								if BattleGroundEnemies.BGSize ~= tonumber(BGSize) then return end
								
								self:ButtonPositioning()
								self:SetPlayerCountJustifyV(value)
							end,
							values = {leftwards = L.Leftwards, rightwards = L.Rightwards},
							order = 6
						},
						BarHorizontalSpacing = {
							type = "range",
							name = L.SpaceBetweenRows,
							desc = L.SpaceBetweenRows_Desc,
							hidden = function() return not self.config[BGSize].Enabled or self.config[BGSize].BarColumns < 2 end,
							set = function(option, value) 
								setOption(option, value)
								if BattleGroundEnemies.BGSize ~= tonumber(BGSize) then return end
								
								self:ButtonPositioning()
							end,
							min = 0,
							max = 400,
							step = 1,
							order = 7
						},
						HealthBarSettings = {
							type = "group",
							name = L.HealthBarSettings,
							desc = L.HealthBarSettings_Desc,
							order = 8,
							args = {
								General = {
									type = "group",
									name = L.General,
									desc = "",
									--inline = true,
									order = 7,
									args = {
										HealthBar_Texture = {
											type = "select",
											name = L.BarTexture,
											desc = L.HealthBar_Texture_Desc,
											set = function(option, value)
												UpdateButtons(option, value, nil, nil, "Health", nil, nil, "SetStatusBarTexture", LSM:Fetch("statusbar", value))
											end,
											dialogControl = 'LSM30_Statusbar',
											values = AceGUIWidgetLSMlists.statusbar,
											width = "normal",
											order = 1
										},
										Fake = addHorizontalSpacing(2),
										HealthBar_Background = {
											type = "color",
											name = L.BarBackground,
											desc = L.HealthBar_Background_Desc,
											set = function(option, ...)
												local color = {...} 
												UpdateButtons(option, color, nil, nil, "Health", "Background", nil, "SetVertexColor", ...)
											end,
											hasAlpha = true,
											width = "normal",
											order = 3
										}
									}
								},
								Name = {
									type = "group",
									name = L.Name,
									desc = L.Name_Desc,
									order = 2,
									args = {
										NameTextSettings = {
											type = "group",
											name = "",
											--desc = L.TrinketSettings_Desc,
											inline = true,
											order = 1,
											args = addNormalTextSettings(playerType, BGSize, "Name", false, true, false, false, "Name")
										},
									}
								},
								RoleIconSettings = {
									type = "group",
									name = L.RoleIconSettings,
									desc = L.RoleIconSettings_Desc,
									--childGroups = "select",
									--inline = true,
									order = 3,
									args = {
										RoleIcon_Enabled = {
											type = "toggle",
											name = L.RoleIcon_Enabled,
											desc = L.RoleIcon_Enabled_Desc,
											set = function(option, value)
												UpdateButtons(option, value, nil, nil, "Role", nil, nil, "SetSize", value and self.config[BGSize].RoleIcon_Size or 0.01, value and self.config[BGSize].RoleIcon_Size or 0.01)
											end,
											width = "normal",
											order = 1
										},
										RoleIcon_Size = {
											type = "range",
											name = L.Size,
											desc = L.RoleIcon_Size_Desc,
											disabled = function() return not self.config[BGSize].RoleIcon_Enabled end,
											set = function(option, value)
												UpdateButtons(option, value, nil, nil, "Role", nil, nil, "SetSize", value, value)
											end,
											min = 2,
											max = 20,
											step = 1,
											width = "normal",
											order = 2
										}
									}
								},
								TargetIndicator = {
									type = "group",
									name = L.TargetIndicator,
									desc = L.TargetIndicator_Desc,
									--childGroups = "select",
									--inline = true,
									order = 4,
									args = {
										NumericTargetindicator_Enabled = {
											type = "toggle",
											name = L.NumericTargetindicator_Enabled,
											desc = L.NumericTargetindicator_Enabled_Desc:format(L[playerType == "Enemies" and "enemies" or "allies"]),
											set = function(option, value)
												UpdateButtons(option, value, nil, nil, "NumericTargetindicator", nil, nil, "SetShown", value)
											end,
											width = "full",
											order = 1
										},
										NumericTargetindicatorTextSettings = {
											type = "group",
											name = "",
											--desc = L.TrinketSettings_Desc,
											disabled = function() return not self.config[BGSize].NumericTargetindicator_Enabled end,
											inline = true,
											order = 2,
											args = addNormalTextSettings(playerType, BGSize, "NumericTargetindicator", "NumericTargetindicator_Enabled", true, false, false, "NumericTargetindicator")
										},
										Fake2 = addVerticalSpacing(3),
										SymbolicTargetindicator_Enabled = {
											type = "toggle",
											name = L.SymbolicTargetindicator_Enabled,
											desc = L.SymbolicTargetindicator_Enabled_Desc:format(L[playerType == "Enemies" and "enemy" or "ally"]),
											set = function(option, value)
												UpdateButtons(option, value, "TargetIndicators", nil, nil, nil, nil, "SetShown", value)
											end,
											width = "full",
											order = 4
										}
									}
								}
							}
						},
						PowerBarSettings = {
							type = "group",
							name = L.PowerBarSettings,
							desc = L.PowerBarSettings_Desc,
							order = 8,
							args = {
								PowerBar_Enabled = {
									type = "toggle",
									name = L.PowerBar_Enabled,
									desc = L.PowerBar_Enabled_Desc,
									set = function(option, value)
										if value then
											if self:IsShown() and not self.TestmodeActive then
												self:RegisterEvent("UNIT_POWER_FREQUENT")
											end
											UpdateButtons(option, value, nil, nil, "Power", nil, nil, "SetHeight", self.config[BGSize].PowerBar_Height)
										else
											self:UnregisterEvent("UNIT_POWER_FREQUENT")
											UpdateButtons(option, value, nil, nil, "Power", nil, nil, "SetHeight", 0.01)
										end
									end,
									order = 1
								},
								PowerBar_Height = {
									type = "range",
									name = L.Height,
									desc = L.PowerBar_Height_Desc,
									disabled = function() return not self.config[BGSize].PowerBar_Enabled end,
									set = function(option, value)
										UpdateButtons(option, value, nil, nil, "Power", nil, nil, "SetHeight", value)
									end,
									min = 1,
									max = 10,
									step = 1,
									width = "normal",
									order = 2
								},
								PowerBar_Texture = {
									type = "select",
									name = L.BarTexture,
									desc = L.PowerBar_Texture_Desc,
									disabled = function() return not self.config[BGSize].PowerBar_Enabled end,
									set = function(option, value)
										UpdateButtons(option, value, nil, nil, "Power", nil, nil, "SetStatusBarTexture", LSM:Fetch("statusbar", value))
									end,
									dialogControl = 'LSM30_Statusbar',
									values = AceGUIWidgetLSMlists.statusbar,
									width = "normal",
									order = 3
								},
								Fake = addHorizontalSpacing(4),
								PowerBar_Background = {
									type = "color",
									name = L.BarBackground,
									desc = L.PowerBar_Background_Desc,
									disabled = function() return not self.config[BGSize].PowerBar_Enabled end,
									set = function(option, ...)
										local color = {...} 
										UpdateButtons(option, color, nil, nil, "Power", "Background", nil, "SetVertexColor", ...)
									end,
									hasAlpha = true,
									width = "normal",
									order = 5
								}
							}
						},
						TrinketSettings = {
							type = "group",
							name = L.TrinketSettings,
							desc = L.TrinketSettings_Desc,
							order = 9,
							args = {
								Trinket_Enabled = {
									type = "toggle",
									name = L.Trinket_Enabled,
									desc = L.Trinket_Enabled_Desc,
									set = function(option, value)
										UpdateButtons(option, value, nil, nil, nil, nil, nil, "EnableTrinket")
									end,
									order = 1
								},
								Trinket_Width = {
									type = "range",
									name = L.Width,
									desc = L.Trinket_Width_Desc,
									disabled = function() return not self.config[BGSize].Trinket_Enabled end,
									set = function(option, value)
										UpdateButtons(option, value, nil, nil, nil, nil, nil, "EnableTrinket")
									end,
									min = 1,
									max = 40,
									step = 1,
									order = 2
								},
								TrinketCooldownTextSettings = {
									type = "group",
									name = L.Countdowntext,
									--desc = L.TrinketSettings_Desc,
									disabled = function() return not self.config[BGSize].Trinket_Enabled end,
									inline = true,
									order = 3,
									args = addCooldownTextsettings(playerType, BGSize, "Trinket", "Trinket_Enabled", nil, nil, "Trinket")
								}
							}
						},
						RacialSettings = {
							type = "group",
							name = L.RacialSettings,
							desc = L.RacialSettings_Desc,
							order = 10,
							args = {
								Racial_Enabled = {
									type = "toggle",
									name = L.Racial_Enabled,
									desc = L.Racial_Enabled_Desc,
									set = function(option, value)
										UpdateButtons(option, value, nil, nil, nil, nil, nil, "EnableRacial")
									end,
									order = 1
								},
								Racial_Width = {
									type = "range",
									name = L.Width,
									desc = L.Racial_Width_Desc,
									disabled = function() return not self.config[BGSize].Racial_Enabled end,
									set = function(option, value)
										UpdateButtons(option, value, nil, nil, nil, nil, nil, "EnableRacial")
									end,
									min = 1,
									max = 40,
									step = 1,
									order = 2
								},
								RacialCooldownTextSettings = {
									type = "group",
									name = L.Countdowntext,
									--desc = L.TrinketSettings_Desc,
									disabled = function() return not self.config[BGSize].Racial_Enabled end,
									inline = true,
									order = 3,
									args = addCooldownTextsettings(playerType, BGSize, "Racial", "Racial_Enabled", nil, nil, "Racial")
								},
								RacialFilteringSettings = {
									type = "group",
									name = FILTER,
									desc = L.RacialFilteringSettings_Desc,
									disabled = function() return not self.config[BGSize].Racial_Enabled end,
									--inline = true,
									order = 4,
									args = {
										RacialFiltering_Enabled = {
											type = "toggle",
											name = L.Filtering_Enabled,
											desc = L.RacialFiltering_Enabled_Desc,
											disabled = function() return not self.config[BGSize].Racial_Enabled end,
											width = 'normal',
											order = 1
										},
										Fake = addHorizontalSpacing(2),
										RacialFiltering_Filterlist = {
											type = "multiselect",
											name = L.Filtering_Filterlist,
											desc = L.RacialFiltering_Filterlist_Desc,
											disabled = function() return not self.config[BGSize].RacialFiltering_Enabled or not self.config[BGSize].Racial_Enabled end,
											get = function(option, key)
												for spellID in pairs(Data.RacialNameToSpellIDs[key]) do
													return self.config[BGSize].RacialFiltering_Filterlist[spellID]
												end
											end,
											set = function(option, key, state) -- value = spellname
												for spellID in pairs(Data.RacialNameToSpellIDs[key]) do
													self.config[BGSize].RacialFiltering_Filterlist[spellID] = state or nil
												end
											end,
											values = Data.Racialnames,
											order = 3
										}
									}
								}
							}
						},
						SpecSettings = {
							type = "group",
							name = L.SpecSettings,
							desc = L.SpecSettings_Desc,
							order = 11,
							args = {
								Spec_Width = {
									type = "range",
									name = L.Width,
									desc = L.Spec_Width_Desc,
									set = function(option, value)
										UpdateButtons(option, value, nil, nil, "Spec", nil, nil, "SetWidth", value)
									end,
									min = 1,
									max = 50,
									step = 1,
									order = 1
								},
								Spec_AuraDisplay_Enabled = {
									type = "toggle",
									name = L.Spec_AuraDisplay_Enabled,
									desc = L.Spec_AuraDisplay_Enabled_Desc,
									order = 2,
								},
								Fake = addVerticalSpacing(3),
								DrTrackingCooldownTextSettings = {
									type = "group",
									name = L.Countdowntext,
									--desc = L.TrinketSettings_Desc,
									disabled = function() return not self.config[BGSize].Spec_AuraDisplay_Enabled end,
									inline = true,
									order = 4,
									args = addCooldownTextsettings(playerType, BGSize, "Spec_AuraDisplay", "Spec_AuraDisplay_Enabled", nil, nil, "Spec_AuraDisplay")
								}
							}
						},
						DrTrackingSettings = {
							type = "group",
							name = L.DrTrackingSettings,
							desc = L.DrTrackingSettings_Desc,
							order = 12,
							args = {
								DrTracking_Enabled = {
									type = "toggle",
									name = L.DrTracking_Enabled,
									desc = L.DrTracking_Enabled_Desc,
									order = 1
								},
								DrTracking_Spacing = {
									type = "range",
									name = L.DrTracking_Spacing,
									desc = L.DrTracking_Spacing_Desc,
									disabled = function() return not self.config[BGSize].DrTracking_Enabled end,
									set = function(option, value)
										UpdateButtons(option, value, nil, nil, nil, nil, nil, "DrPositioning")
									end,
									min = 0,
									max = 10,
									step = 1,
									order = 2
								},
								DrTracking_DisplayType = {
									type = "select",
									name = L.DrTracking_DisplayType,
									desc = L.DrTracking_DisplayType_Desc,
									disabled = function() return not self.config[BGSize].DrTracking_Enabled end,
									set = function(option, value)
										UpdateButtons(option, value, "DR", nil, nil, nil, nil, "ChangeDisplayType")
									end,
									values = Data.DrTrackingDisplayType,
									order = 3
								},
								DrTrackingCooldownTextSettings = {
									type = "group",
									name = L.Countdowntext,
									--desc = L.TrinketSettings_Desc,
									disabled = function() return not self.config[BGSize].DrTracking_Enabled end,
									order = 4,
									args = addCooldownTextsettings(playerType, BGSize, "DrTracking", "DrTracking_Enabled", "DR")
								},
								Fake1 = addVerticalSpacing(5),
								DrTrackingFilteringSettings = {
									type = "group",
									name = FILTER,
									--desc = L.DrTrackingFilteringSettings_Desc,
									disabled = function() return not self.config[BGSize].DrTracking_Enabled end,
									--inline = true,
									order = 6,
									args = {
										DrTrackingFiltering_Enabled = {
											type = "toggle",
											name = L.Filtering_Enabled,
											desc = L.DrTrackingFiltering_Enabled_Desc,
											disabled = function() return not self.config[BGSize].DrTracking_Enabled end,
											width = 'normal',
											order = 1
										},
										DrTrackingFiltering_Filterlist = {
											type = "multiselect",
											name = L.Filtering_Filterlist,
											desc = L.DrTrackingFiltering_Filterlist_Desc,
											disabled = function() return not self.config[BGSize].DrTrackingFiltering_Enabled or not self.config[BGSize].DrTracking_Enabled end,
											get = function(option, key)
												return self.config[BGSize].DrTrackingFiltering_Filterlist[key]
											end,
											set = function(option, key, state) -- key = category name
												self.config[BGSize].DrTrackingFiltering_Filterlist[key] = state or nil
											end,
											values = Data.DrCategorys,
											order = 2
										}
									}
								}
							}
						},
						MyAurasSettings = {
							type = "group",
							name = L.MyAurasSettings,
							desc = L.MyAurasSettings_Desc,
							order = 13,
							args = {
								MyAuras_Enabled = {
									type = "toggle",
									name = L.MyAuras_Enabled,
									desc = L.MyAuras_Enabled_Desc,
									order = 1
								},
								MyAuras_Spacing = {
									type = "range",
									name = L.MyAuras_Spacing,
									desc = L.MyAuras_Spacing_Desc,
									disabled = function() return not self.config[BGSize].MyAuras_Enabled end,
									set = function(option, value)
										UpdateButtons(option, value, nil, nil, nil, nil, nil, "AuraPositioning")
									end,
									min = 0,
									max = 10,
									step = 1,
									order = 2
								},
								Fake = addVerticalSpacing(3),
								MyAurasStacktextSettings = {
									type = "group",
									name = L.MyAurasStacktextSettings,
									--desc = L.MyAuraSettings_Desc,
									disabled = function() return not self.config[BGSize].MyAuras_Enabled end,
									inline = true,
									order = 4,
									args = addNormalTextSettings(playerType, BGSize, "MyAuras", "MyAuras_Enabled", true, "MyAuras", "InactiveAuras", "Stacks")
								},
								MyAurasCooldownTextSettings = {
									type = "group",
									name = L.Countdowntext,
									--desc = L.TrinketSettings_Desc,
									disabled = function() return not self.config[BGSize].MyAuras_Enabled end,
									inline = false,
									order = 5,
									args = addCooldownTextsettings(playerType, BGSize, "MyAuras", "MyAuras_Enabled", "MyAuras", "InactiveAuras")
								},
								MyAurasFilteringSettings = {
									type = "group",
									name = FILTER,
									desc = L.MyAurasFilteringSettings_Desc,
									disabled = function() return not self.config[BGSize].MyAuras_Enabled end,
									--inline = true,
									order = 6,
									args = {
										MyAurasFiltering_Enabled = {
											type = "toggle",
											name = L.Filtering_Enabled,
											desc = L.MyAurasFiltering_Enabled_Desc,
											disabled = function() return not self.config[BGSize].MyAuras_Enabled end,
											width = 'normal',
											order = 1
										},
										MyAurasFiltering_AddSpellID = {
											type = "input",
											name = L.MyAurasFiltering_AddSpellID,
											desc = L.MyAurasFiltering_AddSpellID_Desc,
											disabled = function() return not self.config[BGSize].MyAurasFiltering_Enabled or not self.config[BGSize].MyAuras_Enabled end,
											get = function() return "" end,
											set = function(option, value, state)
												local spellIDs = {strsplit(",", value)}
												for i = 1, #spellIDs do
													local spellID = tonumber(spellIDs[i])
													self.config[BGSize].MyAurasFiltering_Filterlist[spellID] = true
												end
											end,
											width = 'double',
											order = 2
										},
										Fake = addVerticalSpacing(3),
										MyAurasFiltering_Filterlist = {
											type = "multiselect",
											name = L.Filtering_Filterlist,
											desc = L.MyAurasFiltering_Filterlist_Desc,
											disabled = function() return not self.config[BGSize].MyAurasFiltering_Enabled or not self.config[BGSize].MyAuras_Enabled end,
											get = function()
												return true --to make it checked
											end,
											set = function(option, value) 
												self.config[BGSize].MyAurasFiltering_Filterlist[value] = nil
											end,
											values = function()
												local valueTable = {}
												for spellID in pairs(self.config[BGSize].MyAurasFiltering_Filterlist) do
													valueTable[spellID] = spellID..": "..(GetSpellInfo(spellID) or "")
												end
												return valueTable
											end,
											order = 4
										}
									}
								}
							}
						}
					}
				}
			}
		}
	end
	local BGSize = "15"
	
	settings["15"].args.BarSettings.args.ObjectiveAndRespawnSettings = {
		type = "group",
		name = L.ObjectiveAndRespawnSettings,
		desc = L.ObjectiveAndRespawnSettings_Desc,
		order = 13,
		args = {
			ObjectiveAndRespawn_ObjectiveEnabled = {
				type = "toggle",
				name = L.ObjectiveAndRespawn_ObjectiveEnabled,
				desc = L.ObjectiveAndRespawn_ObjectiveEnabled_Desc,
				set = function(option, value)
					setOption(option, value)
					if BattleGroundEnemies.BGSize ~= tonumber(BGSize) then return end
				
					for playerName, playerButton in pairs(self.Players) do
						if value then
							if playerButton.ObjectiveAndRespawn.Icon:GetTexture() then
								playerButton.ObjectiveAndRespawn:Show()
							end
						else
							playerButton.ObjectiveAndRespawn:Hide()
						end
					end
					for playerName, playerButton in pairs(self.InactivePlayerButtons) do
						if value then
							if playerButton.ObjectiveAndRespawn.Icon:GetTexture() then
								playerButton.ObjectiveAndRespawn:Show()
							end
						else
							playerButton.ObjectiveAndRespawn:Hide()
						end
					end
				end,
				order = 1
			},
			ObjectiveAndRespawn_Width = {
				type = "range",
				name = L.Width,
				desc = L.ObjectiveAndRespawn_Width_Desc,
				disabled = function() return not self.config[BGSize].ObjectiveAndRespawn_ObjectiveEnabled end,
				set = function(option, value)
					UpdateButtons(option, value, nil, nil, "ObjectiveAndRespawn", nil, nil, "SetWidth", value)
				end,
				min = 1,
				max = 50,
				step = 1,
				order = 2
			},
			ObjectiveAndRespawn_Position = {
				type = "select",
				name = L.ObjectiveAndRespawn_Position,
				desc = L.ObjectiveAndRespawn_Position_Desc,
				disabled = function() return not self.config[BGSize].ObjectiveAndRespawn_ObjectiveEnabled end,
				set = function(option, value)
					UpdateButtons(option, value, nil, nil, nil, nil, nil, "SetObjectivePosition", value)
				end,
				values = Data.ObjectiveAndRespawnPosition,
				order = 3
			},
			ObjectiveAndRespawnTextSettings = {
				type = "group",
				name = "",
				--desc = L.TrinketSettings_Desc,
				disabled = function() return not self.config[BGSize].ObjectiveAndRespawn_ObjectiveEnabled end,
				inline = true,
				order = 4,
				args = addNormalTextSettings(playerType, BGSize, "ObjectiveAndRespawn", "ObjectiveAndRespawn_ObjectiveEnabled", true, false, false, "ObjectiveAndRespawn", "AuraText")
			}
		}
	}
	settings["15"].args.BarSettings.args.RBGSpecificSettings = {
		type = "group",
		name = L.RBGSpecificSettings,
		desc = L.RBGSpecificSettings_Desc,
		--inline = true,
		order = 14,
		args = {
			Notifications_Enabled = {
				type = "toggle",
				name = L.Notifications_Enabled,
				desc = L.Notifications_Enabled_Desc,
				--inline = true,
				order = 1
			},
			-- PositiveSound = {
				-- type = "select",
				-- name = L.PositiveSound,
				-- desc = L.PositiveSound_Desc,
				-- disabled = function() return not self.config[BGSize].Notifications_Enabled end,
				-- dialogControl = 'LSM30_Sound',
				-- values = AceGUIWidgetLSMlists.sound,
				-- order = 2
			-- },
			-- NegativeSound = {
				-- type = "select",
				-- name = L.NegativeSound,
				-- desc = L.NegativeSound_Desc,
				-- disabled = function() return not self.config[BGSize].Notifications_Enabled end,
				-- dialogControl = 'LSM30_Sound',
				-- values = AceGUIWidgetLSMlists.sound,
				-- order = 3
			-- },
			ObjectiveAndRespawn_RespawnEnabled = {
				type = "toggle",
				name = L.ObjectiveAndRespawn_RespawnEnabled,
				desc = L.ObjectiveAndRespawn_RespawnEnabled_Desc,
				order = 4
			},
			ObjectiveAndRespawnCooldownTextSettings = {
				type = "group",
				name = L.Countdowntext,
				--desc = L.TrinketSettings_Desc,
				disabled = function() return not self.config[BGSize].ObjectiveAndRespawn_RespawnEnabled end,
				inline = true,
				order = 5,
				args = addCooldownTextsettings(playerType, BGSize, "ObjectiveAndRespawn", "ObjectiveAndRespawn_RespawnEnabled", nil, nil, "ObjectiveAndRespawn")
			}
		}
	}
	
	
	return settings
end






function BattleGroundEnemies:SetupOptions()
	self.options = {
		type = "group",
		name = "BattleGroundEnemies " .. GetAddOnMetadata(addonName, "Version"),
		childGroups = "tab",
		get = getOption,
		set = setOption,
		args = {
			TestmodeSettings = {
				type = "group",
				name = L.TestmodeSettings,
				disabled = function() return InCombatLockdown() or (self:IsShown() and not self.TestmodeActive) end,
				inline = true,
				order = 1,
				args = {
					Testmode_BGSize = {
						type = "select",
						name = L.BattlegroundSize,
						order = 1,
						get = function() return self.BGSize end,
						set = function(option, value)
							self.BGSize = value
							self:EnableAlliesAndEnemies()
							self:ProfileChanged()
							
							if self.TestmodeActive then
								self:FillData()
							end
						end,
						values = {[15] = L.BGSize_15, [40] = L.BGSize_40}
					},
					Testmode_Enabled = {
						type = "execute",
						name = L.Testmode_Toggle,
						desc = L.Testmode_Toggle_Desc,
						disabled = function() return InCombatLockdown() or (self:IsShown() and not self.TestmodeActive) or not self.BGSize end,
						func = self.ToggleTestmode,
						order = 2
					},
					Testmode_ToggleAnimation = {
						type = "execute",
						name = L.Testmode_ToggleAnimation,
						desc = L.Testmode_ToggleAnimation_Desc,
						disabled = function() return InCombatLockdown() or not self.TestmodeActive end,
						func = self.ToggleTestmodeOnUpdate,
						order = 3
					}
				}
			},
			GeneralSettings = {
				type = "group",
				name = L.GeneralSettings,
				desc = L.GeneralSettings_Desc,
				order = 3,
				args = {
					Locked = {
						type = "toggle",
						name = L.Locked,
						desc = L.Locked_Desc,
						order = 1
					},
					DisableArenaFrames = {
						type = "toggle",
						name = L.DisableArenaFrames,
						desc = L.DisableArenaFrames_Desc,
						set = function(option, value) 
							setOption(option, value)
							self:ToggleArenaFrames()
						end,
						order = 3
					},
					Font = {
						type = "select",
						name = L.Font,
						desc = L.Font_Desc,
						set = function(option, value)
							for number, playerType in pairs({BattleGroundEnemies.Allies, BattleGroundEnemies.Enemies}) do
								for playerName, playerButton in pairs (playerType.Players) do
									applyMainfont(playerButton, value)
								end
								for playerName, playerButton in pairs (playerType.InactivePlayerButtons) do
									applyMainfont(playerButton, value)
								end
							end
							setOption(option, value)
						end,
						dialogControl = "LSM30_Font",
						values = AceGUIWidgetLSMlists.font,
						order = 4
					},
					MyTarget_Color = {
						type = "color",
						name = L.MyTarget_Color,
						desc = L.MyTarget_Color_Desc,
						set = function(option, ...)
							local color = {...} 
							ApplySettingToEnemiesAndAllies(option, color, nil, nil, "MyTarget", nil, nil, "SetBackdropBorderColor", ...)
						end,
						hasAlpha = true,
						order = 7
					},
					MyFocus_Color = {
						type = "color",
						name = L.MyFocus_Color,
						desc = L.MyFocus_Color_Desc,
						set = function(option, ...)
							local color = {...} 
							ApplySettingToEnemiesAndAllies(option, color, nil, nil, "MyFocus", nil, nil, "SetBackdropBorderColor", ...)
						end,
						hasAlpha = true,
						order = 8
					},
					Highlight_Color = {
						type = "color",
						name = L.Highlight_Color,
						desc = L.Highlight_Color_Desc,
						set = function(option, ...)
							local color = {...} 
							ApplySettingToEnemiesAndAllies(option, color, nil, nil, "SelectionHighlight", nil, nil, "SetColorTexture", ...)
						end,
						hasAlpha = true,
						order = 9
					}
				}
			},
			EnemySettings = {
				type = "group",
				name = L.Enemies,
				childGroups = "tab",
				order = 4,
				args = addEnemyAndAllySettings(self.Enemies)
			},
			AllySettings = {
				type = "group",
				name = L.Allies,
				childGroups = "tab",
				order = 5,
				args = addEnemyAndAllySettings(self.Allies)
			}
		}
	}
	LibStub("AceConfig-3.0"):RegisterOptionsTable("BattleGroundEnemies", self.options)
	
	local AceConfigDialog = LibStub("AceConfigDialog-3.0")
	
	AceConfigDialog:SetDefaultSize("BattleGroundEnemies", 709, 532)
	
	--profiles
	self.options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	self.options.args.profiles.order = -1
	self.options.args.profiles.disabled = InCombatLockdown
	
	AceConfigDialog:AddToBlizOptions("BattleGroundEnemies", "BattleGroundEnemies")
end

SLASH_BattleGroundEnemies1, SLASH_BattleGroundEnemies2, SLASH_BattleGroundEnemies3 = "/BattleGroundEnemies", "/bge", "/BattleGroundEnemies"
SlashCmdList["BattleGroundEnemies"] = function(msg)
	LibStub("AceConfigDialog-3.0"):Open("BattleGroundEnemies")
end
