local addonName, Data = ...
local GetAddOnMetadata = GetAddOnMetadata

local L = LibStub("AceLocale-3.0"):GetLocale("BattleGroundEnemies")
local LSM = LibStub("LibSharedMedia-3.0")
local DRData = LibStub("DRData-1.0")


local function getOption(option)
	local value = option.arg and BattleGroundEnemies.db.profile[option.arg] or BattleGroundEnemies.db.profile[option[#option]]
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
	-- BattleGroundEnemies:Debug(option.arg, value, option[0], option[1], option[2], option[3], option[4])
	local key = option[#option]
	--print(type(value), value)
	-- BattleGroundEnemies:Debug(key, value)
	-- BattleGroundEnemies:Debug(unpack(value))
	BattleGroundEnemies.db.profile[key] = value
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

local function ApplySettingsToButton(enemyButton, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename, func, ...)
	if loopInButton1 then
		for k, obj in pairs(enemyButton[loopInButton1]) do
			CallInDeepness(obj, fixedsubtable, subtablename, subsubtablename, func, ...)
		end
		if loopInButton2 then
			for k, obj in pairs(enemyButton[loopInButton2]) do
				CallInDeepness(obj, fixedsubtable, subtablename, subsubtablename, func, ...)
			end
		end
	else
		CallInDeepness(enemyButton, fixedsubtable, subtablename, subsubtablename, func, ...)
	end
end


local function UpdateButtons(option, value, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename, func, ...)
	setOption(option, value)
	for name, enemyButton in pairs(BattleGroundEnemies.Enemies) do
		ApplySettingsToButton(enemyButton, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename, func, ...)
	end
	for i = 1, #BattleGroundEnemies.InactiveEnemyButtons do
		local enemyButton = BattleGroundEnemies.InactiveEnemyButtons[i]
		ApplySettingsToButton(enemyButton, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename, func, ...)
	end
end


local function ApplySetting(option, value, LoopOverButtons, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename, func, ...)
	setOption(option, value)
	if LoopOverButtons then
		UpdateButtons(option, value, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename, func, ...)
	else
		CallInDeepness(BattleGroundEnemies, fixedsubtable, subtablename, subsubtablename, func, ...)
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

local function applyMainfont(enemyButton, value)
	local conf = BattleGroundEnemies.db.profile
	enemyButton.Name:SetFont(LSM:Fetch("font", value), conf.Name_Fontsize, conf.Name_Outline)
	enemyButton.NumericTargetindicator.Text:SetFont(LSM:Fetch("font", value), conf.NumericTargetindicator_Fontsize, conf.NumericTargetindicator_Outline)
	enemyButton.ObjectiveAndRespawn.AuraText:SetFont(LSM:Fetch("font", value), conf.ObjectiveAndRespawn_Fontsize, conf.ObjectiveAndRespawn_Outline)
	enemyButton.Trinket.Cooldown.Text:SetFont(LSM:Fetch("font", value), conf.Trinket_Cooldown_Fontsize, conf.Trinket_Cooldown_Outline)
	enemyButton.Racial.Cooldown.Text:SetFont(LSM:Fetch("font", value), conf.Racial_Cooldown_Fontsize, conf.Racial_Cooldown_Outline)

	for spellID, frame in pairs(enemyButton.MyDebuffs) do
		frame.Stacks:SetFont(LSM:Fetch("font", value), conf.MyDebuffs_Fontsize, conf.MyDebuffs_Outline)
		frame.Cooldown.Text:SetFont(LSM:Fetch("font", value), conf.MyDebuffs_Cooldown_Fontsize, conf.MyDebuffs_Cooldown_Outline)
	end
	for spellID, frame in pairs(enemyButton.InactiveDebuffs) do
		frame.Stacks:SetFont(LSM:Fetch("font", value), conf.MyDebuffs_Fontsize, conf.MyDebuffs_Outline)
		frame.Cooldown.Text:SetFont(LSM:Fetch("font", value), conf.MyDebuffs_Cooldown_Fontsize, conf.MyDebuffs_Cooldown_Outline)
	end
	for drCat, drFrame in pairs(enemyButton.DR) do
		drFrame.Cooldown.Text:SetFont(LSM:Fetch("font", value), conf.DrTracking_Cooldown_Fontsize, conf.DrTracking_Cooldown_Outline)
	end
end

local function addNormalTextSettings(optionname, maindisable, LoopOverButtons, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename)
	local fontsize = optionname.."_Fontsize"
	local textcolor = optionname.."_Textcolor"
	local outline = optionname.."_Outline"
	local enableTextShadow = optionname.."_EnableTextshadow"
	local textShadowcolor = optionname.."_TextShadowcolor"
	
	local conf = BattleGroundEnemies.db.profile
	
	local options = {
		[fontsize] = {
			type = "range",
			name = L.Fontsize,
			desc = L[fontsize.."_Desc"],
			disabled = function() return maindisable and not conf[maindisable] end,
			set = function(option, value)
				ApplySetting(option, value, LoopOverButtons, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename, "SetFont", LSM:Fetch("font", conf.Font), value, conf[outline])
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
				ApplySetting(option, value, LoopOverButtons, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename, "SetFont", LSM:Fetch("font", conf.Font), conf[fontsize], value)
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



local function addCooldownTextsettings(optionname, maindisable, loopInButton1, loopInButton2, fixedsubtable, subtablename, subsubtablename)
	local showNumbers = optionname.."_ShowNumbers"
	local fontsize = optionname.."_Cooldown_Fontsize"
	local outline = optionname.."_Cooldown_Outline"
	local enableTextShadow = optionname.."_Cooldown_EnableTextshadow"
	local textShadowcolor = optionname.."_Cooldown_TextShadowcolor"	
	
	local conf = BattleGroundEnemies.db.profile

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
						UpdateButtons(option, value, loopInButton1, loopInButton2, fixedsubtable, "Cooldown", "Text", "SetFont", LSM:Fetch("font", conf.Font), value, conf[outline])
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
						local conf = BattleGroundEnemies.db.profile
						UpdateButtons(option, value, loopInButton1, loopInButton2, fixedsubtable, "Cooldown", "Text", "SetFont", LSM:Fetch("font", conf.Font), conf[fontsize], value)
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
						local conf = BattleGroundEnemies.db.profile
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

function BattleGroundEnemies:SetupOptions()
	self.options = {
		type = "group",
		name = "BattleGroundEnemies " .. GetAddOnMetadata(addonName, "Version"),
		childGroups = "tab",
		get = getOption,
		set = setOption,
		args = {
			Testmode = {
				type = "execute",
				name = L.Testmode_Toggle,
				desc = L.Testmode_Toggle_Desc,
				disabled = function() return self:IsShown() and not self.TestmodeActive end,
				func  = self.ToggleTestmode,
				order = 1	
			},
			Testmode_ToggleAnimation = {
				type = "execute",
				name = L.Testmode_ToggleAnimation,
				desc = L.Testmode_ToggleAnimation_Desc,
				hidden = function() return not self.TestmodeActive end,
				func  = self.ToggleTestmodeOnUpdate,
				order = 2
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
					Framescale = {
						type = "range",
						name = L.Framescale,
						desc = L.Framescale_Desc,
						disabled = InCombatLockdown,
						set = function(option, value) 
							self:SetScale(value)
							setOption(option, value)
						end,
						min = 0.3,
						max = 2,
						step = 0.05,
						order = 2
					},
					MaxPlayers = {
						type = "range",
						name = L.MaxPlayers,
						desc = L.MaxPlayers_Desc,
						min = 1,
						max = 15,
						step = 1,
						order = 3
					},
					DisableArenaFrames = {
						type = "toggle",
						name = L.DisableArenaFrames,
						desc = L.DisableArenaFrames_Desc,
						set = function(option, value) 
							setOption(option, value)
							self:ToggleArenaFrames()
						end,
						order = 4
					},
					Font = {
						type = "select",
						name = L.Font,
						desc = L.Font_Desc,
						set = function(option, value)
							local conf = self.db.profile
							for name, enemyButton in pairs(self.Enemies) do
								applyMainfont(enemyButton, value)
							end
							for number, enemyButton in ipairs(self.InactiveEnemyButtons) do
								applyMainfont(enemyButton, value)
							end
							setOption(option, value)
						end,
						dialogControl = "LSM30_Font",
						values = AceGUIWidgetLSMlists.font,
						order = 5
					},
					Growdirection = {
						type = "select",
						name = L.Growdirection,
						desc = L.Growdirection_Desc,
						set = function(option, value) 
							setOption(option, value)
							self:ButtonPositioning()
							self:SetEnemyCountJustifyV(value)
						end,
						values = {upwards = L.Upwards, downwards = L.Downwards},
						order = 6
					},
					Fake = addVerticalSpacing(7),
					EnemyCount = {
						type = "group",
						name = L.EnemyCount_Enabled,
						inline = true,
						order = 8,
						args = {
							EnemyCount_Enabled = {
								type = "toggle",
								name = L.EnemyCount_Enabled,
								desc = L.EnemyCount_Enabled_Desc,
								set = function(option, value)
									self.EnemyCount:SetShown(value)
									setOption(option, value)
								end,
								order = 1
							},
							EnemyCountTextSettings = {
								type = "group",
								name = "",
								--desc = L.TrinketSettings_Desc,
								disabled = function() return not self.db.profile.EnemyCount_Enabled end,
								inline = true,
								order = 2,
								args = addNormalTextSettings("EnemyCount", "EnemyCount_Enabled", false, false, false, "EnemyCount")
							}
						}
					}
				}
			},
			BarSettings = {
				type = "group",
				name = L.BarSettings,
				desc = L.BarSettings_Desc,
				--childGroups = "tab",
				order = 4,
				args = {
					BarWidth = {
						type = "range",
						name = L.Width,
						desc = L.BarWidth_Desc,
						disabled = InCombatLockdown,
						set = function(option, value)
							self:SetWidth(value)
							setOption(option, value)
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
					SpaceBetweenRows = {
						type = "range",
						name = L.SpaceBetweenRows,
						desc = L.SpaceBetweenRows_Desc,
						set = function(option, value) 
							setOption(option, value)
							self:ButtonPositioning()
						end,
						min = 0,
						max = 20,
						step = 1,
						order = 3
					},
					RangeIndicator_Settings = {
						type = "group",
						name = L.RangeIndicator_Settings,
						desc = L.RangeIndicator_Settings_Desc,
						order = 4,
						args = {
							RangeIndicator_Enabled = {
								type = "toggle",
								name = L.RangeIndicator_Enabled,
								desc = L.RangeIndicator_Enabled_Desc,
								set = function(option, value) 
									UpdateButtons(option, value, nil, nil, "RangeIndicator_Frame", nil, nil, "SetAlpha", value and self.db.profile.RangeIndicator_Alpha or 1)
								end,
								order = 1
							},
							RangeIndicator_Range = {
								type = "select",
								name = L.RangeIndicator_Range,
								desc = L.RangeIndicator_Range_Desc,
								disabled = function() return not self.db.profile.RangeIndicator_Enabled end,
								get = function() return Data.ItemIDToRange[self.db.profile.RangeIndicator_Range] end,
								set = function(option, value)
									value = Data.RangeToItemID[value]
									setOption(option, value)
								end,
								values = Data.RangeToRange,
								width = "half",
								order = 2
							},
							RangeIndicator_Alpha = {
								type = "range",
								name = L.RangeIndicator_Alpha,
								desc = L.RangeIndicator_Alpha_Desc,
								disabled = function() return not self.db.profile.RangeIndicator_Enabled end,
								min = 0,
								max = 1,
								step = 0.05,
								order = 3
							},
							RangeIndicator_Frame = {
								type = "select",
								name = L.RangeIndicator_Frame,
								desc = L.RangeIndicator_Frame_Desc,
								disabled = function() return not self.db.profile.RangeIndicator_Enabled end,
								set = function(option, value) 
									UpdateButtons(option, value, nil, nil, nil, nil, nil, "SetRangeIncicatorFrame")
								end,
								values = {All = L.Everything, PowerAndHealth = L.HealthBarSettings.." "..L.AND.." "..L.PowerBarSettings},
								width = "double",
								order = 4
							}
						}
					},
					MyTarget_Color = {
						type = "color",
						name = L.MyTarget_Color,
						desc = L.MyTarget_Color_Desc,
						set = function(option, ...)
							local color = {...} 
							UpdateButtons(option, color, nil, nil, "MyTarget", nil, nil, "SetBackdropBorderColor", ...)
						end,
						hasAlpha = true,
						order = 5
					},
					MyFocus_Color = {
						type = "color",
						name = L.MyFocus_Color,
						desc = L.MyFocus_Color_Desc,
						set = function(option, ...)
							local color = {...} 
							UpdateButtons(option, color, nil, nil, "MyFocus", nil, nil, "SetBackdropBorderColor", ...)
						end,
						hasAlpha = true,
						order = 6
					},
					HealthBarSettings = {
						type = "group",
						name = L.HealthBarSettings,
						desc = L.HealthBarSettings_Desc,
						order = 7,
						args = {
							General = {
								type = "group",
								name = L.General,
								desc = "",
								--inline = true,
								order = 1,
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
										args = addNormalTextSettings("Name", false, true, false, false, "Name")
									},
									Fake4 = addVerticalSpacing(2),
									ConvertCyrillic = {
										type = "toggle",
										name = L.ConvertCyrillic,
										desc = L.ConvertCyrillic_Desc,
										set = function(option, value)
											UpdateButtons(option, value, nil, nil, nil, nil, nil, "SetName")
										end,
										width = "normal",
										order = 3
									},
									ShowRealmnames = {
										type = "toggle",
										name = L.ShowRealmnames,
										desc = L.ShowRealmnames_Desc,
										set = function(option, value)
											UpdateButtons(option, value, nil, nil, nil, nil, nil, "SetName")
										end,
										width = "normal",
										order = 4
									}
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
											UpdateButtons(option, value, nil, nil, "Role", nil, nil, "SetSize", value and self.db.profile.RoleIcon_Size or 0.01, value and self.db.profile.RoleIcon_Size or 0.01)
										end,
										width = "normal",
										order = 1
									},
									RoleIcon_Size = {
										type = "range",
										name = L.Size,
										desc = L.RoleIcon_Size_Desc,
										disabled = function() return not self.db.profile.RoleIcon_Enabled end,
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
										desc = L.NumericTargetindicator_Enabled_Desc,
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
										disabled = function() return not self.db.profile.NumericTargetindicator_Enabled end,
										inline = true,
										order = 2,
										args = addNormalTextSettings("NumericTargetindicator", "NumericTargetindicator_Enabled", true, false, false, "NumericTargetindicator")
									},
									Fake2 = addVerticalSpacing(3),
									SymbolicTargetindicator_Enabled = {
										type = "toggle",
										name = L.SymbolicTargetindicator_Enabled,
										desc = L.SymbolicTargetindicator_Enabled_Desc,
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
										UpdateButtons(option, value, nil, nil, "Power", nil, nil, "SetHeight", self.db.profile.PowerBar_Height)
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
								disabled = function() return not self.db.profile.PowerBar_Enabled end,
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
								disabled = function() return not self.db.profile.PowerBar_Enabled end,
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
								disabled = function() return not self.db.profile.PowerBar_Enabled end,
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
							TrinketCooldownTextSettings = {
								type = "group",
								name = L.Countdowntext,
								--desc = L.TrinketSettings_Desc,
								disabled = function() return not self.db.profile.Trinket_Enabled end,
								inline = true,
								order = 2,
								args = addCooldownTextsettings("Trinket", "Trinket_Enabled", nil, nil, "Trinket")
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
							RacialCooldownTextSettings = {
								type = "group",
								name = L.Countdowntext,
								--desc = L.TrinketSettings_Desc,
								disabled = function() return not self.db.profile.Racial_Enabled end,
								inline = true,
								order = 2,
								args = addCooldownTextsettings("Racial", "Racial_Enabled", nil, nil, "Racial")
							},
							RacialFilteringSettings = {
								type = "group",
								name = FILTER,
								desc = L.MyDebuffsFilteringSettings_Desc,
								disabled = function() return not self.db.profile.Racial_Enabled end,
								--inline = true,
								order = 4,
								args = {
									RacialFiltering_Enabled = {
										type = "toggle",
										name = L.Filtering_Enabled,
										desc = L.RacialFiltering_Enabled_Desc,
										disabled = function() return not self.db.profile.Racial_Enabled end,
										width = 'normal',
										order = 1
									},
									Fake = addHorizontalSpacing(2),
									RacialFiltering_Filterlist = {
										type = "multiselect",
										name = L.Filtering_Filterlist,
										desc = L.RacialFiltering_Filterlist_Desc,
										disabled = function() return not self.db.profile.RacialFiltering_Enabled or not self.db.profile.Racial_Enabled end,
										get = function(option, key)
											for spellID in pairs(Data.RacialNameToSpellIDs[key]) do
												return self.db.profile.RacialFiltering_Filterlist[spellID]
											end
										end,
										set = function(option, key, state) -- value = spellname
											for spellID in pairs(Data.RacialNameToSpellIDs[key]) do
												self.db.profile.RacialFiltering_Filterlist[spellID] = state or nil
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
								disabled = function() return not self.db.profile.Spec_AuraDisplay_Enabled end,
								inline = true,
								order = 4,
								args = addCooldownTextsettings("Spec_AuraDisplay", "Spec_AuraDisplay_Enabled", nil, nil, "Spec_AuraDisplay")
							}
						}
					},
					ObjectiveAndRespawnSettings = {
						type = "group",
						name = L.ObjectiveAndRespawnSettings,
						desc = L.ObjectiveAndRespawnSettings_Desc,
						order = 12,
						args = {
							ObjectiveAndRespawn_ObjectiveEnabled = {
								type = "toggle",
								name = L.ObjectiveAndRespawn_ObjectiveEnabled,
								desc = L.ObjectiveAndRespawn_ObjectiveEnabled_Desc,
								set = function(option, value)
									for name, enemyButton in pairs(self.Enemies) do
										if value then
											if enemyButton.ObjectiveAndRespawn.Icon:GetTexture() then
												enemyButton.ObjectiveAndRespawn:Show()
											end
										else
											enemyButton.ObjectiveAndRespawn:Hide()
										end
									end
									setOption(option, value)
								end,
								order = 1
							},
							ObjectiveAndRespawn_Width = {
								type = "range",
								name = L.Width,
								desc = L.ObjectiveAndRespawn_Width_Desc,
								disabled = function() return not self.db.profile.ObjectiveAndRespawn_ObjectiveEnabled end,
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
								disabled = function() return not self.db.profile.ObjectiveAndRespawn_ObjectiveEnabled end,
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
								disabled = function() return not self.db.profile.ObjectiveAndRespawn_ObjectiveEnabled end,
								inline = true,
								order = 4,
								args = addNormalTextSettings("ObjectiveAndRespawn", "ObjectiveAndRespawn_ObjectiveEnabled", true, false, false, "ObjectiveAndRespawn", "AuraText")
							},
						}
					},
					DrTrackingSettings = {
						type = "group",
						name = L.DrTrackingSettings,
						desc = L.DrTrackingSettings_Desc,
						order = 13,
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
								disabled = function() return not self.db.profile.DrTracking_Enabled end,
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
								disabled = function() return not self.db.profile.DrTracking_Enabled end,
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
								disabled = function() return not self.db.profile.DrTracking_Enabled end,
								order = 4,
								args = addCooldownTextsettings("DrTracking", "DrTracking_Enabled", "DR")
							},
							Fake1 = addVerticalSpacing(5),
							DrTrackingFilteringSettings = {
								type = "group",
								name = FILTER,
								--desc = L.DrTrackingFilteringSettings_Desc,
								disabled = function() return not self.db.profile.DrTracking_Enabled end,
								--inline = true,
								order = 6,
								args = {
									DrTrackingFiltering_Enabled = {
										type = "toggle",
										name = L.Filtering_Enabled,
										desc = L.DrTrackingFiltering_Enabled_Desc,
										disabled = function() return not self.db.profile.DrTracking_Enabled end,
										width = 'normal',
										order = 1
									},
									DrTrackingFiltering_Filterlist = {
										type = "multiselect",
										name = L.Filtering_Filterlist,
										desc = L.DrTrackingFiltering_Filterlist_Desc,
										disabled = function() return not self.db.profile.DrTrackingFiltering_Enabled or not self.db.profile.DrTracking_Enabled end,
										get = function(option, key)
											return self.db.profile.DrTrackingFiltering_Filterlist[key]
										end,
										set = function(option, key, state) -- key = category name
											self.db.profile.DrTrackingFiltering_Filterlist[key] = state or nil
										end,
										values = Data.DrCategorys,
										order = 2
									}
								}
							}
						}
					},
					MyDebuffSettings = {
						type = "group",
						name = L.MyDebuffSettings,
						desc = L.MyDebuffSettings_Desc,
						order = 14,
						args = {
							MyDebuffs_Enabled = {
								type = "toggle",
								name = L.MyDebuffs_Enabled,
								desc = L.MyDebuffs_Enabled_Desc,
								order = 1
							},
							MyDebuffs_Spacing = {
								type = "range",
								name = L.MyDebuffs_Spacing,
								desc = L.MyDebuffs_Spacing_Desc,
								disabled = function() return not self.db.profile.MyDebuffs_Enabled end,
								set = function(option, value)
									UpdateButtons(option, value, nil, nil, nil, nil, nil, "DebuffPositioning")
								end,
								min = 0,
								max = 10,
								step = 1,
								order = 2
							},
							Fake = addVerticalSpacing(3),
							MyDebuffsStacktextSettings = {
								type = "group",
								name = L.MyDebuffsStacktextSettings,
								--desc = L.MyDebuffSettings_Desc,
								disabled = function() return not self.db.profile.MyDebuffs_Enabled end,
								inline = true,
								order = 4,
								args = addNormalTextSettings("MyDebuffs", "MyDebuffs_Enabled", true, "MyDebuffs", "InactiveDebuffs", "Stacks")
							},
							MyDebuffsCooldownTextSettings = {
								type = "group",
								name = L.Countdowntext,
								--desc = L.TrinketSettings_Desc,
								disabled = function() return not self.db.profile.MyDebuffs_Enabled end,
								inline = false,
								order = 5,
								args = addCooldownTextsettings("MyDebuffs", "MyDebuffs_Enabled", "MyDebuffs", "InactiveDebuffs")
							},
							MyDebuffsFilteringSettings = {
								type = "group",
								name = FILTER,
								desc = L.MyDebuffsFilteringSettings_Desc,
								disabled = function() return not self.db.profile.MyDebuffs_Enabled end,
								--inline = true,
								order = 6,
								args = {
									MyDebuffsFiltering_Enabled = {
										type = "toggle",
										name = L.Filtering_Enabled,
										desc = L.MyDebuffsFiltering_Enabled_Desc,
										disabled = function() return not self.db.profile.MyDebuffs_Enabled end,
										width = 'normal',
										order = 1
									},
									MyDebuffsFiltering_AddSpellID = {
										type = "input",
										name = L.MyDebuffsFiltering_AddSpellID,
										desc = L.MyDebuffsFiltering_AddSpellID_Desc,
										disabled = function() return not self.db.profile.MyDebuffsFiltering_Enabled or not self.db.profile.MyDebuffs_Enabled end,
										get = function() return "" end,
										set = function(option, value, state)
											local spellIDs = {strsplit(",", value)}
											for i = 1, #spellIDs do
												local spellID = tonumber(spellIDs[i])
												self.db.profile.MyDebuffsFiltering_Filterlist[spellID] = true
											end
										end,
										width = 'double',
										order = 2
									},
									Fake = addVerticalSpacing(3),
									MyDebuffsFiltering_Filterlist = {
										type = "multiselect",
										name = L.Filtering_Filterlist,
										desc = L.MyDebuffsFiltering_Filterlist_Desc,
										disabled = function() return not self.db.profile.MyDebuffsFiltering_Enabled or not self.db.profile.MyDebuffs_Enabled end,
										get = function()
											return true --to make it checked
										end,
										set = function(option, value) 
											self.db.profile.MyDebuffsFiltering_Filterlist[value] = nil
										end,
										values = function()
											local valueTable = {}
											for spellID in pairs(self.db.profile.MyDebuffsFiltering_Filterlist) do
												valueTable[spellID] = spellID..": "..(GetSpellInfo(spellID) or "")
											end
											return valueTable
										end,
										order = 4
									}
								}
							}
						}
					},
					RBGSpecificSettings = {
						type = "group",
						name = L.RBGSpecificSettings,
						desc = L.RBGSpecificSettings_Desc,
						--inline = true,
						order = 15,
						args = {
							Notificatoins_Enabled = {
								type = "toggle",
								name = L.Notificatoins_Enabled,
								desc = L.Notificatoins_Enabled_Desc,
								--inline = true,
								order = 1
							},
							-- PositiveSound = {
								-- type = "select",
								-- name = L.PositiveSound,
								-- desc = L.PositiveSound_Desc,
								-- disabled = function() return not self.db.profile.Notificatoins_Enabled end,
								-- dialogControl = 'LSM30_Sound',
								-- values = AceGUIWidgetLSMlists.sound,
								-- order = 2
							-- },
							-- NegativeSound = {
								-- type = "select",
								-- name = L.NegativeSound,
								-- desc = L.NegativeSound_Desc,
								-- disabled = function() return not self.db.profile.Notificatoins_Enabled end,
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
								disabled = function() return not self.db.profile.ObjectiveAndRespawn_RespawnEnabled end,
								inline = true,
								order = 5,
								args = addCooldownTextsettings("ObjectiveAndRespawn", "ObjectiveAndRespawn_RespawnEnabled", nil, nil, "ObjectiveAndRespawn")
							}
						}
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
				order = 5,
				args = {
					LeftButtonType = {
						type = "select",
						name = KEY_BUTTON1,
						values =  Data.Buttons,
						order = 1
					},
					LeftButtonValue = {
						type = "input",
						name = ENTER_MACRO_LABEL,
						desc = L.CustomMacro_Desc,
						disabled = function() return self.db.profile.LeftButtonType == "Target" or self.db.profile.LeftButtonType == "Focus" end,
						multiline = true,
						width = 'double',
						order = 2
					},
					RightButtonType = {
						type = "select",
						name = KEY_BUTTON2,
						values =  Data.Buttons,
						order = 3
					},
					RightButtonValue = {
						type = "input",
						name = ENTER_MACRO_LABEL,
						desc = L.CustomMacro_Desc,
						disabled = function() return self.db.profile.RightButtonType == "Target" or self.db.profile.RightButtonType == "Focus" end,
						multiline = true,
						width = 'double',
						order = 4
					},
					MiddleButtonType = {
						type = "select",
						name = KEY_BUTTON3,
						values =  Data.Buttons,
						order = 5
					},
					MiddleButtonValue = {
						type = "input",
						name = ENTER_MACRO_LABEL,
						desc = L.CustomMacro_Desc,
						disabled = function() return self.db.profile.MiddleButtonType == "Target" or self.db.profile.MiddleButtonType == "Focus" end,
						multiline = true,
						width = 'double',
						order = 6
					}
				}
			}
		}
	}
	LibStub("AceConfig-3.0"):RegisterOptionsTable("BattleGroundEnemies", self.options)
	
	local AceConfigDialog = LibStub("AceConfigDialog-3.0")
	
	AceConfigDialog:SetDefaultSize("BattleGroundEnemies", 700, 500)
	
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
