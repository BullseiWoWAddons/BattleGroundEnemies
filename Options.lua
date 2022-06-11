local AddonName, Data = ...
local GetAddOnMetadata = GetAddOnMetadata

local L = Data.L
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local LSM = LibStub("LibSharedMedia-3.0")


local CTimerNewTicker = C_Timer.NewTicker

function Data.AddPositionSetting(location)
	local numPoints = 0
	local temp = {}
	if location.Points then
		numPoints = #location.Points
		
		for i = 1, numPoints do
			temp["Point"..i] = {
				type = "group",
				name = "Point"..i,
				desc = "",
				get =  function(option)
					return Data.GetOption(location.Points[i], option)
				end,
				set = function(option, ...) 
					return Data.SetOption(location.Points[i], option, ...)
				end,
				inline = true,
				order = i,
				args = {
					Point = {
						type = "select",
						name = "Point",
						values = Data.AllPositions,
						order = 1
					},
					RelativeFrame = {
						type = "select",
						name = "RelativeFrame",
						values = {1,2,3},
						order = 2
					},
					RelativePoint = {
						type = "select",
						name = "RelativePoint",
						values = Data.AllPositions,
						order = 3
					},
					OffsetX = {
						type = "range",
						name = L.OffsetX,
						min = -100,
						max = 100,
						step = 1,
						order = 2,
						order = 4
					},
					OffsetY = {
						type = "range",
						name = L.OffsetY,
						min = -100,
						max = 100,
						step = 1,
						order = 2,
						order = 5
					},
					DeletePoint = {
						type = "execute",
						name = "delete Point point",
						func = function() 
							location.Points[i] = nil
			
							BattleGroundEnemies:ProfileChanged()
							AceConfigRegistry:NotifyChange("BattleGroundEnemies");
						end,
						width = "full",
						order = 6,
					}
				}
			}
			
		end
	end
	
	temp.AddPoint = {
		type = "execute",
		name = "Add another point",
		func = function() 
			location.Points = location.Points or {}
			location.Points[numPoints + 1] = {}

			BattleGroundEnemies:ProfileChanged()
			AceConfigRegistry:NotifyChange("BattleGroundEnemies");
		end,
		width = "full",
		order = numPoints + 1
	}
	temp.EnableWidth = {
		type =  "toggle",
		name = "Set Width",
		order = numPoints + 2
	}
	temp.Width = {
		type = "range",
		name = "width",
		min = 0,
		max = 100,
		step = 1,
		disabled = function() return not location.EnableWidth end,
		order = numPoints + 3
	}
	temp.EnableHeight = {
		type =  "toggle",
		name = "Set Height",
		order = numPoints + 4
	}
	temp.Height = {
		type = "range",
		name = "Height",
		min = 0,
		max = 100,
		step = 1,
		disabled = function() return not location.EnableHeight end,
		order = numPoints + 5
	}
	return temp
end


-- returns true if <frame> or one of the frames that <frame> is dependent on is anchored to <otherFrame> and nil otherwise
-- dont ancher to otherframe is 
local function IsFrameDependentOnFrame(frame, otherFrame)
	if frame == nil then
		return false
	end

	if otherFrame == nil then
		return false
	end

	if frame == otherFrame then
		return true
	end

	local points = frame:GetNumPoints()
	for i = 1, points do
		local _, relFrame = frame:GetPoint(i)
		if relFrame and IsFrameDependentOnFrame(relFrame, otherFrame) then
			return true
		end
	end
end


local function copy(obj)
	if type(obj) ~= 'table' then return obj end
	local res = {}
	for k, v in pairs(obj) do res[copy(k)] = copy(v) end
	return res
end
						
local function addStaticPopupForPlayerTypeConfigImport(playerType, oppositePlayerType)
	StaticPopupDialogs["CONFIRM_OVERRITE_"..AddonName..playerType] = {
	  text = L.ConfirmProfileOverride:format(L[playerType], L[oppositePlayerType]),
	  button1 = YES,
	  button2 = NO,
	  OnAccept = function (self) 
			BattleGroundEnemies.db.profile[playerType] = copy(BattleGroundEnemies.db.profile[oppositePlayerType])
			BattleGroundEnemies:ProfileChanged()
			AceConfigRegistry:NotifyChange("BattleGroundEnemies")
	  end,
	  OnCancel = function (self) end,
	  OnHide = function (self) self.data = nil; self.selectedIcon = nil; end,
	  hideOnEscape = 1,
	  timeout = 30,
	  exclusive = 1,
	  whileDead = 1,
	}
end
addStaticPopupForPlayerTypeConfigImport("Enemies", "Allies")
addStaticPopupForPlayerTypeConfigImport("Allies", "Enemies")


local function addStaticPopupBGTypeConfigImport(playerType, oppositePlayerType, BGSize)
	StaticPopupDialogs["CONFIRM_OVERRITE_"..AddonName..playerType..BGSize] = {
	  text = L.ConfirmProfileOverride:format(L[playerType]..": "..L["BGSize_"..BGSize], L[oppositePlayerType]..": "..L["BGSize_"..BGSize]),
	  button1 = YES,
	  button2 = NO,
	  OnAccept = function (self) 
			BattleGroundEnemies.db.profile[playerType][BGSize] = copy(BattleGroundEnemies.db.profile[oppositePlayerType][BGSize])
			if BattleGroundEnemies.BGSize and BattleGroundEnemies.BGSize == tonumber(BGSize) then BattleGroundEnemies[playerType]:ApplyBGSizeSettings() end
			AceConfigRegistry:NotifyChange("BattleGroundEnemies")
	  end,
	  OnCancel = function (self) end,
	  OnHide = function (self) self.data = nil; self.selectedIcon = nil; end,
	  hideOnEscape = 1,
	  timeout = 30,
	  exclusive = 1,
	  whileDead = 1,
	}
end
addStaticPopupBGTypeConfigImport("Enemies", "Allies", "5")
addStaticPopupBGTypeConfigImport("Allies", "Enemies", "5")
addStaticPopupBGTypeConfigImport("Enemies", "Allies", "15")
addStaticPopupBGTypeConfigImport("Allies", "Enemies", "15")
addStaticPopupBGTypeConfigImport("Enemies", "Allies", "40")
addStaticPopupBGTypeConfigImport("Allies", "Enemies", "40")



function Data.GetOption(location, option)
	local value = location[option[#option]]

	if type(value) == "table" then
		--BattleGroundEnemies:Debug("is table")
		return unpack(value)
	else
		return value
	end
end


function Data.SetOption(location, option, ...)
	local value
	if option.type == "color" then
		value = {...}   -- local r, g, b, alpha = ...
	else
		value = ...
	end

	location[option[#option]] = value
	BattleGroundEnemies:ApplyAllSettings()
	

	--BattleGroundEnemies.db.profile[key] = value
end


function Data.AddVerticalSpacing(order)
	local verticalSpacing = {
		type = "description",
		name = " ",
		fontSize = "large",
		width = "full",
		order = order
	}
	return verticalSpacing
end

function Data.AddHorizontalSpacing(order)
	local horizontalSpacing = {
		type = "description",
		name = " ",
		width = "half",	
		order = order,
	}
	return horizontalSpacing
end


function Data.AddIconPositionSettings()	
	return {
		Size = {
			type = "range",
			name = L.Size,
			min = 0,
			max = 80,
			step = 1,
			order = 1
		},
		IconsPerRow = {
			type = "range",
			name = L.IconsPerRow,
			min = 4,
			max = 30,
			step = 1,
			order = 2
		},
		Fake = Data.AddVerticalSpacing(3),
		HorizontalGrowDirection = {
			type = "select",
			name = L.HorizontalGrowdirection,
			values = Data.HorizontalDirections,
			order = 4
		},
		HorizontalSpacing = {
			type = "range",
			name = L.HorizontalSpacing,
			min = 0,
			max = 20,
			step = 1,
			order = 5
		},
		Fake1 = Data.AddVerticalSpacing(6),
		VerticalGrowdirection = {
			type = "select",
			name = L.VerticalGrowdirection,
			values = Data.VerticalDirections,
			order = 7
		},
		VerticalSpacing = {
			type = "range",
			name = L.VerticalSpacing,
			min = 0,
			max = 20,
			step = 1,
			order = 8
		}
	}
end


-- all positions, corners, middle, left etc.
function Data.AddContainerPositionSettings()
	return {
		Point = {
			type = "select",
			name = L.Point,
			width = "normal",
			values = Data.AllPositions,
			order = 1
		},
		RelativeTo = {
			type = "select",
			name = L.AttachToObject,
			desc = L.AttachToObject_Desc,
			values = Data.Frames,
			order = 2
		},
		Fake = Data.AddVerticalSpacing(3),
		RelativePoint = {
			type = "select",
			name = L.PointAtObject,
			width = "normal",
			values = Data.AllPositions,
			order = 4
		},
		OffsetX = {
			type = "range",
			name = L.OffsetX,
			min = -20,
			max = 20,
			step = 1,
			order = 5
		},
		OffsetY = {
			type = "range",
			name = L.OffsetY,
			min = -20,
			max = 20,
			step = 1,
			order = 6
		}
	}
end

-- sets 2 points, user can choose left and right, 1 point at TOP..setting, and another point BOTTOM..setting is set
function Data.AddBasicPositionSettings()	
	return {
		BasicPoint = {
			type = "select",
			name = L.Side,
			width = "normal",
			values = Data.BasicPositions,
			order = 1
		},
		RelativeTo = {
			type = "select",
			name = L.AttachToObject,
			desc = L.AttachToObject_Desc,
			values = Data.Frames,
			order = 2
		},
		Fake = Data.AddVerticalSpacing(3),
		RelativePoint = {
			type = "select",
			name = L.SideAtObject,
			width = "normal",
			values = Data.BasicPositions,
			order = 4
		},
		OffsetX = {
			type = "range",
			name = L.OffsetX,
			min = -20,
			max = 20,
			step = 1,
			order = 5
		}
	}
end

function Data.AddNormalTextSettings(location)		
	return {
		Fontsize = {
			type = "range",
			name = L.Fontsize,
			desc = L.Fontsize_Desc,
			min = 1,
			max = 40,
			step = 1,
			width = "normal",
			order = 1
		},
		Outline = {
			type = "select",
			name = L.Font_Outline,
			desc = L.Font_Outline_Desc,
			values = Data.FontOutlines,
			order = 2
		},
		Fake = Data.AddVerticalSpacing(3),
		Textcolor = {
			type = "color",
			name = L.Fontcolor,
			desc = L.Fontcolor_Desc,
			hasAlpha = true,
			order = 4
		},
		EnableTextshadow = {
			type = "toggle",
			name = L.FontShadow_Enabled,
			desc = L.FontShadow_Enabled_Desc,
			order = 5
		},
		TextShadowcolor = {
			type = "color",
			name = L.FontShadowColor,
			desc = L.FontShadowColor_Desc,
			disabled = function() 
				return not location.EnableTextshadow
			end,
			hasAlpha = true,
			order = 6
		}
	}
end


function Data.AddCooldownSettings(location)
	return {
		ShowNumbers = {
			type = "toggle",
			name = L.ShowNumbers,
			desc = L.ShowNumbers_Desc,
			order = 1
		},
		asdfasdf = {
			type = "group",
			name = "",
			desc = "",
			disabled = function() 
				return not location.ShowNumbers
			end, 
			inline = true,
			order = 2,
			args = {
				Fontsize = {
					type = "range",
					name = L.Fontsize,
					desc = L.Fontsize_Desc,
					min = 6,
					max = 40,
					step = 1,
					width = "normal",
					order = 3
				},
				Outline = {
					type = "select",
					name = L.Font_Outline,
					desc = L.Font_Outline_Desc,
					values = Data.FontOutlines,
					order = 4
				},
				Fake1 = Data.AddVerticalSpacing(5),
				EnableTextShadow = {
					type = "toggle",
					name = L.FontShadow_Enabled,
					desc = L.FontShadow_Enabled_Desc,
					order = 6
				},
				TextShadowcolor = {
					type = "color",
					name = L.FontShadowColor,
					desc = L.FontShadowColor_Desc,
					disabled = function()
						return not location.EnableTextShadow
					end, 
					hasAlpha = true,
					order = 7
				}
			}
		}
	}
end

function BattleGroundEnemies:AddModuleSettings(location, defaults, playerType) 
	local i = 1
	local temp = {}
	for moduleName, moduleFrame in pairs(self.Modules) do
	

		local locationn = location.Modules[moduleName]

		temp[moduleName]  = {
			type = "group",
			name = moduleFrame.localizedModuleName,
			order = moduleFrame.order,
			get =  function(option)
				return Data.GetOption(locationn, option)
			end,
			set = function(option, ...) 
				return Data.SetOption(locationn, option, ...)
			end,
			args = {
				Enabled = {
					type = "toggle",
					name = VIDEO_OPTIONS_ENABLED,
					width = "normal",
					order = 1
				}, 
				ModuleSettings = {
					type = "group",
					name = "Settings",
					get =  function(option)
						return Data.GetOption(locationn, option)
					end,
					set = function(option, ...) 
						return Data.SetOption(locationn, option, ...)
					end,
					disabled = not locationn.Enabled,
					order = 2,
					args = type(moduleFrame.options) == "function" and moduleFrame.options(locationn, playerType) or moduleFrame.options or {}
				},
				PositionSetting = {
					type = "group",
					name = "PositionSettings",
					get =  function(option)
						return Data.GetOption(location, option)
					end,
					set = function(option, ...) 
						return Data.SetOption(location, option, ...)
					end,
					args = Data.AddPositionSetting(location)

				},
				Reset = {
					type = "execute",
					name = "Reset the settings of this section",
					func = function() 
						location.Modules[moduleName] = copy(defaults.Modules[moduleName])

						BattleGroundEnemies:ProfileChanged()
						AceConfigRegistry:NotifyChange("BattleGroundEnemies");
					end,
					width = "full",
					order = 3,
				}
			}
		}
	end
	return temp
end


local function addEnemyAndAllySettings(self, mainFrame)
	local playerType = mainFrame.PlayerType
	local oppositePlayerType = playerType == "Enemies" and "Allies" or "Enemies"
	local settings = {}
	local location = BattleGroundEnemies.db.profile[playerType]

	
	settings.GeneralSettings = {
		type = "group",
		name = GENERAL,
		desc = L["GeneralSettings"..playerType],
		get =  function(option)
			return Data.GetOption(location, option)
		end,
		set = function(option, ...) 
			return Data.SetOption(location, option, ...)
		end,
		--childGroups = "tab",
		order = 1,
		args = {
			Enabled = {
				type = "toggle",
				name = ENABLE,
				desc = "test",
				order = 1
			},
			Fake = Data.AddHorizontalSpacing(2),
			Fake1 = Data.AddHorizontalSpacing(3),
			Fake2 = Data.AddHorizontalSpacing(4),
			CopySettings = {
				type = "execute",
				name = L.CopySettings:format(L[oppositePlayerType]),
				desc = L.CopySettings_Desc:format(L[oppositePlayerType])..L.NotAvailableInCombat,
				disabled = InCombatLockdown,
				func = function()
					StaticPopup_Show("CONFIRM_OVERRITE_"..AddonName..playerType)
				end,
				width = "double",
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
						order = 1
					},
					RangeIndicator_Range = {
						type = "select",
						name = L.RangeIndicator_Range,
						desc = L.RangeIndicator_Range_Desc,
						disabled = function() return not location.RangeIndicator_Enabled end,
						get = function() return Data[playerType.."ItemIDToRange"][location.RangeIndicator_Range] end,
						set = function(option, value)
							value = Data[playerType.."RangeToItemID"][value]
							return Data.SetOption(location, option, value)
						end,
						values = Data[playerType.."RangeToRange"],
						width = "half",
						order = 2
					},
					RangeIndicator_Alpha = {
						type = "range",
						name = L.RangeIndicator_Alpha,
						desc = L.RangeIndicator_Alpha_Desc,
						disabled = function() return not location.RangeIndicator_Enabled end,
						min = 0,
						max = 1,
						step = 0.05,
						order = 3
					},
					Fake = Data.AddVerticalSpacing(4),
					RangeIndicator_Everything = {
						type = "toggle",
						name = L.RangeIndicator_Everything,
						disabled = function() return not location.RangeIndicator_Enabled end,
						order = 6
					},
					RangeIndicator_Frames = {
						type = "multiselect",
						name = L.RangeIndicator_Frames,
						desc = L.RangeIndicator_Frames_Desc,
						hidden = function() return (not location.RangeIndicator_Enabled or location.RangeIndicator_Everything) end,
						get = function(option, key)
							return location.RangeIndicator_Frames[key]
						end,
						set = function(option, key, state) 
							location.RangeIndicator_Frames[key] = state
							BattleGroundEnemies:ApplyAllSettings()
						end,
						width = "double",
						values = Data.RangeFrames,
						order = 7
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
						width = "normal",
						order = 1
					},
					ShowRealmnames = {
						type = "toggle",
						name = L.ShowRealmnames,
						desc = L.ShowRealmnames_Desc,
						width = "normal",
						order = 2
					}
				}
			},
			KeybindSettings = {
				type = "group",
				name = KEY_BINDINGS,
				desc = L.KeybindSettings_Desc..L.NotAvailableInCombat,
				disabled = InCombatLockdown,
				--childGroups = "tab",
				order = 9,
				args = {
					UseClique = {
						type = "toggle",
						name = L.EnableClique,
						desc = L.EnableClique_Desc,
						order = 1,
						hidden = playerType == "Enemies"
					},
					LeftButton = {
						type = "group",
						name = KEY_BUTTON1,
						order = 2,
						disabled = function() return location.UseClique end,
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
								disabled = function() return location.LeftButtonType == "Target" or location.LeftButtonType == "Focus" end,
								multiline = true,
								width = 'double',
								order = 2
							},

						}
					},
					RightButton = {
						type = "group",
						name = KEY_BUTTON2,
						order = 3,
						disabled = function() return location.UseClique end,
						args = {
							RightButtonType = {
								type = "select",
								name = KEY_BUTTON2,
								values = Data.Buttons,
								order = 1
							},
							RightButtonValue = {
								type = "input",
								name = ENTER_MACRO_LABEL,
								desc = L.CustomMacro_Desc,
								disabled = function() return location.RightButtonType == "Target" or location.RightButtonType == "Focus" end,
								multiline = true,
								width = 'double',
								order = 2
							},

						}
					},
					MiddleButton = {
						type = "group",
						name = KEY_BUTTON3,
						order = 4,
						disabled = function() return location.UseClique end,
						args = {

							MiddleButtonType = {
								type = "select",
								name = KEY_BUTTON3,
								values = Data.Buttons,
								order = 1
							},
							MiddleButtonValue = {
								type = "input",
								name = ENTER_MACRO_LABEL,
								desc = L.CustomMacro_Desc,
								disabled = function() return location.MiddleButtonType == "Target" or location.MiddleButtonType == "Focus" end,
								multiline = true,
								width = 'double',
								order = 2
							}
						}
					}
				}
			}
		}
	}
	

	for k, BGSize in pairs({"5", "15", "40"}) do
		local location = BattleGroundEnemies.db.profile[playerType][BGSize]
		local defaults = BattleGroundEnemies.db.defaults.profile[playerType][BGSize]
		settings[BGSize] = {
			type = "group", 
			name = L["BGSize_"..BGSize],
			desc = L["BGSize_"..BGSize.."_Desc"]:format(L[playerType]),
			disabled = function() return not mainFrame.config.Enabled end,
			get =  function(option)
				return Data.GetOption(location, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location, option, ...)
			end,
			order = k + 1, 
			args = {
				Enabled = {
					type = "toggle",
					name = ENABLE,
					desc = "test",
					order = 1
				},
				Fake = Data.AddHorizontalSpacing(2),
				CopySettings = {
					type = "execute",
					name = L.CopySettings:format(L[oppositePlayerType]..": "..L["BGSize_"..BGSize]),
					desc = L.CopySettings_Desc:format(L[oppositePlayerType]..": "..L["BGSize_"..BGSize]),
					func = function()
						StaticPopup_Show("CONFIRM_OVERRITE_"..AddonName..playerType..BGSize)
					end,
					width = "double",
					order = 3
				},
				MainFrameSettings = {
					type = "group",
					name = L.MainFrameSettings,
					desc = L.MainFrameSettings_Desc:format(L[playerType == "Enemies" and "enemies" or "allies"]),
					disabled = function() return not location.Enabled end,
					--childGroups = "tab",
					order = 4,
					args = {
						Framescale = {
							type = "range",
							name = L.Framescale,
							desc = L.Framescale_Desc..L.NotAvailableInCombat,
							disabled = InCombatLockdown,
							min = 0.3,
							max = 2,
							step = 0.05,
							order = 1
						},
						PlayerCount = {
							type = "group",
							name = L.PlayerCount_Enabled,
							get = function(option)
								return Data.GetOption(location.PlayerCount, option)
							end,
							set = function(option, ...)
								return Data.SetOption(location.PlayerCount, option, ...)
							end,
							order = 2,
							inline = true,
							args = {
								Enabled = {
									type = "toggle",
									name = L.PlayerCount_Enabled,
									desc = L.PlayerCount_Enabled_Desc,
									order = 1
								},
								PlayerCountTextSettings = {
									type = "group",
									name = "",
									--desc = L.TrinketSettings_Desc,
									disabled = function() return not location.PlayerCount_Enabled end,
									get = function(option)
										return Data.GetOption(location.PlayerCount.Text, option)
									end,
									set = function(option, ...)
										return Data.SetOption(location.PlayerCount.Text, option, ...)
									end,
									inline = true,
									order = 2,
									args = Data.AddNormalTextSettings(location.PlayerCount.Text)
								}
							}
						}
					}
				},
				BarSettings = {
					type = "group",
					name = L.BarSettings,
					desc = L.BarSettings_Desc,
					disabled = function() return not location.Enabled end,
					--childGroups = "tab",
					order = 5,
					args = {
						BarWidth = {
							type = "range",
							name = L.Width,
							desc = L.BarWidth_Desc..L.NotAvailableInCombat,
							disabled = InCombatLockdown,
							min = 1,
							max = 400,
							step = 1,
							order = 1
						},
						BarHeight = {
							type = "range",
							name = L.Height,
							desc = L.BarHeight_Desc..L.NotAvailableInCombat,
							disabled = InCombatLockdown,
							min = 1,
							max = 100,
							step = 1,
							order = 2
						},
						BarVerticalGrowdirection = {
							type = "select",
							name = L.VerticalGrowdirection,
							desc = L.VerticalGrowdirection_Desc..L.NotAvailableInCombat,
							disabled = InCombatLockdown,
							values = Data.VerticalDirections,
							order = 3
						},
						BarVerticalSpacing = {
							type = "range",
							name = L.VerticalSpacing,
							desc = L.VerticalSpacing..L.NotAvailableInCombat,
							disabled = InCombatLockdown,
							min = 0,
							max = 20,
							step = 1,
							order = 4
						},
						BarColumns = {
							type = "range",
							name = L.Columns,
							desc = L.Columns_Desc..L.NotAvailableInCombat,
							disabled = InCombatLockdown,
							min = 1,
							max = 4,
							step = 1,
							order = 5
						},
						BarHorizontalGrowdirection = {
							type = "select",
							name = L.VerticalGrowdirection,
							desc = L.VerticalGrowdirection_Desc..L.NotAvailableInCombat,
							hidden = function() return location.BarColumns < 2 end,
							disabled = InCombatLockdown,
							values = Data.HorizontalDirections,
							order = 6
						},
						BarHorizontalSpacing = {
							type = "range",
							name = L.HorizontalSpacing,
							desc = L.HorizontalSpacing..L.NotAvailableInCombat,
							hidden = function() return location.BarColumns < 2 end,
							disabled = InCombatLockdown,
							min = 0,
							max = 400,
							step = 1,
							order = 7
						},
						ModuleSettings = {
							type = "group",
							name = "Module Settings",
							desc = "Module specific settings",
							order = 3,
							args = self:AddModuleSettings(location, defaults, playerType)
						}
					}
				}
			}
		}
	end
	return settings
end






function BattleGroundEnemies:SetupOptions()
	local location = self.db.profile
	self.options = {
		type = "group",
		name = "BattleGroundEnemies " .. GetAddOnMetadata(AddonName, "Version"),
		childGroups = "tab",
		get = function(option)
			return Data.GetOption(location, option)
		end,
		set = function(option, ...)
			return Data.SetOption(location, option, ...)
		end,
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
							self.Allies:UpdatePlayerCount(value)
							self.Enemies:UpdatePlayerCount(value)
							
							if self.TestmodeActive then
								self:FillData()
							end
						end,
						values = {[5] = ARENA, [15] = L.BGSize_15, [40] = L.BGSize_40}
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
				order = 2,
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
							Data.SetOption(location, option, value)
							self:ToggleArenaFrames()
						end,
						order = 3
					},
					Font = {
						type = "select",
						name = L.Font,
						desc = L.Font_Desc,
						dialogControl = "LSM30_Font",
						values = AceGUIWidgetLSMlists.font,
						order = 4
					},
					MyTarget_Color = {
						type = "color",
						name = L.MyTarget_Color,
						desc = L.MyTarget_Color_Desc,
						hasAlpha = true,
						order = 7
					},
					MyFocus_Color = {
						type = "color",
						name = L.MyFocus_Color,
						desc = L.MyFocus_Color_Desc,
						hasAlpha = true,
						order = 8
					},
					Fake1 = Data.AddVerticalSpacing(10),
					ShowTooltips = {
						type = "toggle",
						name = L.ShowTooltips,
						desc = L.ShowTooltips_Desc,
						order = 11
					}
				}
			},
			RBGSettings = {
				type = "group",
				name = L.RBGSpecificSettings,
				desc = L.RBGSpecificSettings_Desc,
				--inline = true,
				order = 14,
				get = function(option)
					return Data.GetOption(location.RBG, option)
				end,
				set = function(option, ...)
					return Data.SetOption(location.RBG, option, ...)
				end,
				args = {
					Notifications = {
						type = "group",
						name = COMMUNITIES_NOTIFICATION_SETTINGS,
						order = 1,
						args = {
							EnemiesTargetingMe = {
								type = "group",
								name = L.IAmTargeted,
								order = 1,
								args = {
									EnemiesTargetingMe_Enabled = {
										type = "toggle",
										name = ENABLE,
										desc = L.EnemiesTargetingMe_Enabled_Desc,
										order = 1
									},
									EnemiesTargetingMe_Amount = {
										type = "range",
										name = L.TargetAmount,
										desc = L.TargetAmount_Me,
										min = 1,
										max = 10,
										step = 1,
										disabled = function() return not location.RBG.EnemiesTargetingMe_Enabled end,
										order = 2
										
									},
									EnemiesTargetingMe_Sound = {
										type = "select",
										name = SOUND,
										values = AceGUIWidgetLSMlists.sound,
										width = "full",
										dialogControl = "LSM30_Sound",
										disabled = function() return not location.RBG.EnemiesTargetingMe_Enabled end,
										order = 3
									}
									
								}
								
								

							},
							EnemiesTargetingAllies = {
								type = "group",
								name = L.AllyIsTargeted,
								order = 2,
								args = {
									EnemiesTargetingAllies_Enabled = {
										type = "toggle",
										name = ENABLE,
										desc = L.EnemiesTargetingAllies_Enabled_Desc,
										order = 1
									},
									EnemiesTargetingAllies_Amount = {
										type = "range",
										name = L.TargetAmount,
										desc = L.TargetAmount_Ally,
										min = 1,
										max = 10,
										step = 1,
										disabled = function() return not location.RBG.EnemiesTargetingAllies_Enabled end,
										order = 2
										
									},
									EnemiesTargetingAllies_Sound = {
										type = "select",
										name = SOUND,
										values = AceGUIWidgetLSMlists.sound,
										width = "full",
										dialogControl = "LSM30_Sound",
										disabled = function() return not location.RBG.EnemiesTargetingAllies_Enabled end,
										order = 3
									}

								}
								

							}
							
						}
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

					
					ObjectiveAndRespawn = {
						type = "group",
						name = L.ObjectiveAndRespawn_RespawnEnabled,
						order = 4,
						args = {
							ObjectiveAndRespawn_RespawnEnabled = {
								type = "toggle",
								name = ENABLE,
								desc = L.ObjectiveAndRespawn_RespawnEnabled_Desc,
								order = 1
							},
							ObjectiveAndRespawnCooldownTextSettings = {
								type = "group",
								name = L.Countdowntext,
								--desc = L.TrinketSettings_Desc,
								disabled = function() return not location.RBG.ObjectiveAndRespawn_RespawnEnabled end,
								order = 5,
								args = Data.AddCooldownSettings(location.RBG)
							}
						}
					},
					TargetCallingSettings = {
						type = "group",
						name = L.TargetCalling,
						order = 6,
						args = {
							TargetCalling_SetMark = {
								type = "toggle",
								name = L.TargetCallingSetMark,
								desc = L.TargetCallingSetMark_Desc,
								order = 1,
								width = "full",
							},
							TargetCalling_NotificationEnable = {
								type = "toggle",
								name = L.TargetCallingNotificationEnable,
								desc = L.TargetCallingNotificationEnable_Desc,
								order = 2,
								width = "full",
							},
							TargetCalling_NotificationSound = {
								type = "select",
								name = SOUND,
								values = AceGUIWidgetLSMlists.sound,
								dialogControl = "LSM30_Sound",
								disabled = function() return not location.RBG.TargetCalling_NotificationEnable end,
								order = 3,
								width = "full",
							}
								
							
							-- Sounds = {
							-- 	type = "group",
							-- 	name = SOUNDS,
							-- 	order = 2,
							-- 	args = {
		
							-- 		
							-- 	}
		
							-- }
						}
						
					}
				}
			},
			EnemySettings = {
				type = "group",
				name = L.Enemies,
				childGroups = "tab",
				order = 4,
				args = addEnemyAndAllySettings(self, self.Enemies)
			},
			AllySettings = {
				type = "group",
				name = L.Allies,
				childGroups = "tab",
				order = 5,
				args = addEnemyAndAllySettings(self, self.Allies)
			},
			ImportExportProfile = {
				type = "group",
				name = L.ImportExportProfile,
				childGroups = "tab",
				order = 6,
				args = {
					ImportButton = {
						type = "execute",
						name = L.ImportButton,
						desc = L.ImportButton_Desc,
						func = function(arg1, arg2) 

							BattleGroundEnemies:ImportExportFrameSetupForMode("Import")

						end,
						order = 1,
					},
					ExportButton = {
						type = "execute",
						name = L.ExportButton,
						desc = L.ExportButton_Desc,
						func = function() 
							BattleGroundEnemies:ExportDataViaPrint(BattleGroundEnemies.db.profile)
						end,
						order = 2,
					}
				}
			}
		}
	}


	AceConfigRegistry:RegisterOptionsTable("BattleGroundEnemies", self.options)
		
	
	
	--add profile tab to the options 
	self.options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	self.options.args.profiles.order = -1
	self.options.args.profiles.disabled = InCombatLockdown
end

SLASH_BattleGroundEnemies1, SLASH_BattleGroundEnemies2 = "/BattleGroundEnemies", "/bge"
SlashCmdList["BattleGroundEnemies"] = function(msg)
	AceConfigDialog:Open("BattleGroundEnemies")
end
