local AddonName, Data = ...
local GetAddOnMetadata = GetAddOnMetadata

local L = Data.L
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local LSM = LibStub("LibSharedMedia-3.0")



local function GetAllAnchors()
	local t = {}
	for moduleName, moduleFrame in pairs(BattleGroundEnemies.ButtonModules) do
		t[moduleName] = moduleFrame.localizedModuleName
	end
	t.Button = L.Button
	return t
end



-- Points
-- TOPLEFT 		TOP 		TOPRIGHT
-- LEFT 		CENTER 		Right
-- BOTTOMLEFT 	BOTTOM 		BOTTOMRIGHT

local function isInSameHorizontal(Point1, Point2)
    local p1 = (Point1.Point:match("(TOP)")) or (Point1.Point:match("(BOTTOM)")) or false
    local p2 = (Point2.Point:match("(TOP)")) or (Point2.Point:match("(BOTTOM)")) or false
    if p1=="TOP" and p2=="TOP" then
        return true
    elseif not (p1=="TOP" or p2=="TOP" or p1=="BOTTOM" or p2=="BOTTOM") then
        return true
    elseif p1=="BOTTOM" and p2=="BOTTOM" then
        return true
    end
end

local function isInSameVertical(Point1, Point2)
    local p1 = (Point1.Point:match("(LEFT)")) or (Point1.Point:match("(RIGHT)")) or false
    local p2 = (Point2.Point:match("(LEFT)")) or (Point2.Point:match("(RIGHT)")) or false
    if p1=="LEFT" and p2=="LEFT" then
        return true
    elseif not (p1=="LEFT" or p2=="LEFT" or p1=="RIGHT" or p2=="RIGHT") then
        return true
    elseif p1=="RIGHT" and p2=="RIGHT" then
        return true
    end
end


local function needsWidth(Point1, Point2)
	if not Point1 and not Point2 then return end
	if Point1 and not Point2 then return true end
	return isInSameVertical(Point1, Point2)
end

--user wants to anchor the module to the relative frame, check if the relative frame is already anchored to that module
local function validateAnchor(playerType, moduleName, relativeFrame)
	local players = BattleGroundEnemies[playerType].Players
	if players then
		local i = 0
		for playerName, playerButton in pairs(players) do
			i = i + 0
			local anchor = playerButton:GetAnchor(relativeFrame)
			local isDependant = BattleGroundEnemies:IsFrameDependentOnFrame(anchor, playerButton[moduleName])
			if isDependant then
				--thats bad, dont allow this setting
				BattleGroundEnemies:Information("You can't anchor this module's frame to this frame because this would result in looped frame anchoring because the frame or one of the frame that this frame is dependant on are already attached to this module.")
				return false
			else
				return true
			end
		end
		if i == 0 then
			BattleGroundEnemies:Information("There are currently no players for the selected option available. You can start the testmode to add some players. Otherwise your selected frame can't be validated and there might be frame looping issues, therefore your selected frame is not saved to avoid this issue.")
			return false
		end
	else
		BattleGroundEnemies:Information("There are currently no players for the selected option available. You can start the testmode to add some players. Otherwise your selected frame can't be validated and there might be frame looping issues, therefore your selected frame is not saved to avoid this issue.")
		return false
	end
end

local function needsHeight(Point1, Point2)
	if not Point1 and not Point2 then return end
	if Point1 and not Point2 then return true end
	return isInSameHorizontal(Point1, Point2)
end

function Data.AddPositionSetting(location, moduleName, moduleFrame, playerType)
	local numPoints = 0
	local temp = {}
	temp.Parent = {
		type = "select",
		name = L.Parent,
		values = GetAllAnchors,
		order = 1
	}
	temp.Fake1 = Data.AddVerticalSpacing(2)
	if location.Points then
		numPoints = #location.Points

		for i = 1, numPoints do
			temp["Point"..i] = {
				type = "group",
				name = L.Point..i,
				desc = "",
				get =  function(option)
					return Data.GetOption(location.Points[i], option)
				end,
				set = function(option, ...)
					return Data.SetOption(location.Points[i], option, ...)
				end,
				inline = true,
				order = i + 2,
				args = {
					Point = {
						type = "select",
						name = L.Point,
						values = Data.AllPositions,
						confirm = function()
							return "Are you sure you want to change this value?"
						end,
						order = 1
					},
					RelativeFrame = {
						type = "select",
						name = L.RelativeFrame,
						values = GetAllAnchors,
						validate = function(option, value)

							if validateAnchor(playerType, moduleName, value) then
								print("validated")
								return true
							else
								--invalid anchor, there might be some looping issues
								print("hier")
								PlaySound(882)
								BattleGroundEnemies:NotifyChange()
								return false
							end
						end,
						order = 2
					},
					RelativePoint = {
						type = "select",
						name = L.RelativePoint,
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
						order = 5
					},
					DeletePoint = {
						type = "execute",
						name = L.DeletePoint..i,
						func = function()
							location.Points[i] = nil
							BattleGroundEnemies:NotifyChange()
						end,
						disabled = i == 1, --dont allow to remove the first point
						width = "full",
						order = 6,
					}
				}
			}

		end
	end

	temp.AddPoint = {
		type = "execute",
		name = L.AddPoint,
		func = function()
			location.Points = location.Points or {}
			location.Points[numPoints + 1] = {
				Point = "TOPLEFT",
				RelativeFrame = "Button",
				RelativePoint = "TOPLEFT"
			}
			BattleGroundEnemies:NotifyChange()
		end,
		disabled = function()
			if not location.Points then return false end

			--dynamic containers with dynamic width and height can have a maximum of 1 points
			return (#location.Points >= 2) or (#location.Points >= 1 and moduleFrame.flags and moduleFrame.flags.Width == "Dynamic" and moduleFrame.flags.Height == "Dynamic")
		end,
		width = "full",
		order = numPoints + 3
	}
	temp.UseButtonHeightAsWidth = {
		type = "toggle",
		name = L.UseButtonHeight,
		hidden = moduleFrame.flags and moduleFrame.flags.Width == "Dynamic"  or not needsWidth(location.Points and location.Points[1], location.Points[2]),
		order = numPoints + 4
	}
	temp.Width = {
		type = "range",
		name = L.Width,
		min = 0,
		max = 100,
		step = 1,
		hidden = function()
			local hidden =  moduleFrame.flags and moduleFrame.flags.Width == "Dynamic"  or not needsWidth(location.Points and location.Points[1], location.Points[2]) or location.UseButtonHeightAsWidth
			if hidden then
				location.Width = nil
				BattleGroundEnemies:NotifyChange()
				return true
			end
		end,
		order = numPoints + 5
	}
	temp.UseButtonHeightAsHeight = {
		type = "toggle",
		name = L.UseButtonHeight,
		hidden = moduleFrame.flags and moduleFrame.flags.Height == "Dynamic" or not needsHeight(location.Points and location.Points[1], location.Points[2]),
		order = numPoints + 6
	}
	temp.Height = {
		type = "range",
		name = L.Height,
		min = 0,
		max = 100,
		step = 1,
		hidden = function()
			local hidden = moduleFrame.flags and moduleFrame.flags.Height == "Dynamic" or not needsHeight(location.Points and location.Points[1], location.Points[2]) or location.UseButtonHeightAsHeight
			if hidden then
				location.Height = nil
				BattleGroundEnemies:NotifyChange()
				return true
			end
		end,
		order = numPoints + 7
	}
	return temp
end





local function copy(obj)
	if type(obj) ~= 'table' then return obj end
	local res = {}
	for k, v in pairs(obj) do res[copy(k)] = copy(v) end
	return res
end


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


function Data.AddContainerSettings()
	return {
		Border = {
			type = "select",
			name = L.Font,
			desc = L.Font_Desc,
			dialogControl = "LSM30_Border",
			values = AceGUIWidgetLSMlists.border,
		},
		IconSize = {
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

local JustifyHValues = {
	LEFT = L.LEFT,
	CENTER = L.CENTER,
	RIGHT = L.RIGHT
}

local JustifyVValues = {
	TOP = L.TOP,
	MIDDLE = L.MIDDLE,
	BOTTOM = L.BOTTOM
}

function Data.AddNormalTextSettings(location)
	return {
		JustifyH = {
			type = "select",
			name = L.JustifyH,
			desc = L.JustifyH_Desc,
			values = JustifyHValues
		},
		JustifyV = {
			type = "select",
			name = L.JustifyV,
			desc = L.JustifyV_Desc,
			values = JustifyVValues
		},
		FontSize = {
			type = "range",
			name = L.Fontsize,
			desc = L.FontSize_Desc,
			min = 1,
			max = 40,
			step = 1,
			width = "normal",
			order = 1
		},
		FontOutline = {
			type = "select",
			name = L.Font_Outline,
			desc = L.Font_Outline_Desc,
			values = Data.FontOutlines,
			order = 2
		},
		Fake = Data.AddVerticalSpacing(3),
		FontColor = {
			type = "color",
			name = L.Fontcolor,
			desc = L.Fontcolor_Desc,
			hasAlpha = true,
			order = 4
		},
		EnableShadow = {
			type = "toggle",
			name = L.FontShadow_Enabled,
			desc = L.FontShadow_Enabled_Desc,
			order = 5
		},
		ShadowColor = {
			type = "color",
			name = L.FontShadowColor,
			desc = L.FontShadowColor_Desc,
			disabled = function()
				return not location.EnableShadow
			end,
			hasAlpha = true,
			order = 6
		}
	}
end


function Data.AddCooldownSettings(location)
	return {
		ShowNumber = {
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
				return not location.ShowNumber
			end,
			inline = true,
			order = 2,
			args = {
				FontSize = {
					type = "range",
					name = L.FontSize,
					desc = L.Fontsize_Desc,
					min = 6,
					max = 40,
					step = 1,
					width = "normal",
					order = 3
				},
				FontOutline = {
					type = "select",
					name = L.Font_Outline,
					desc = L.Font_Outline_Desc,
					values = Data.FontOutlines,
					order = 4
				},
				Fake1 = Data.AddVerticalSpacing(5),
				EnableShadow = {
					type = "toggle",
					name = L.FontShadow_Enabled,
					desc = L.FontShadow_Enabled_Desc,
					order = 6
				},
				ShadowColor = {
					type = "color",
					name = L.FontShadowColor,
					desc = L.FontShadowColor_Desc,
					disabled = function()
						return not location.EnableShadow
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
	for moduleName, moduleFrame in pairs(self.ButtonModules) do


		local locationn = location.ButtonModules[moduleName]

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
					name = L.ModuleSpecificSettings,
					get =  function(option)
						return Data.GetOption(locationn, option)
					end,
					set = function(option, ...)
						return Data.SetOption(locationn, option, ...)
					end,
					disabled  = function() return not locationn.Enabled or not moduleFrame.options end,
					order = 2,
					args = type(moduleFrame.options) == "function" and moduleFrame.options(locationn, playerType) or moduleFrame.options or {}
				},
				PositionSetting = {
					type = "group",
					name = L.Position .. " " .. L.AND .. " " .. L.Size,
					get =  function(option)
						return Data.GetOption(locationn, option)
					end,
					set = function(option, ...)
						return Data.SetOption(locationn, option, ...)
					end,
					disabled  = function() return not locationn.Enabled end,
					args = Data.AddPositionSetting(locationn, moduleName, moduleFrame, playerType)
				},
				Reset = {
					type = "execute",
					name = "Reset the settings of this section",
					func = function()
						location.ButtonModules[moduleName] = copy(defaults.ButtonModules[moduleName])
						BattleGroundEnemies:NotifyChange()
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
					BattleGroundEnemies.db.profile[playerType] = copy(BattleGroundEnemies.db.profile[oppositePlayerType])
					BattleGroundEnemies:NotifyChange()
				end,
				confirm = function() return L.ConfirmProfileOverride:format(L[playerType], L[oppositePlayerType]) end,
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
						print("func called")
						BattleGroundEnemies.db.profile[playerType][BGSize] = copy(BattleGroundEnemies.db.profile[oppositePlayerType][BGSize])
						BattleGroundEnemies:NotifyChange()
					end,
					confirm = function()
						return L.ConfirmProfileOverride:format(L[playerType]..": "..L["BGSize_"..BGSize], L[oppositePlayerType]..": "..L["BGSize_"..BGSize])
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
									name = L.TextSettings,
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
					name = L.Button,
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
							name = L.ModuleSettings,
							order = 8,
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
							if self.TestmodeActive then
								self:FillData(value)
							end
						end,
						values = {[5] = ARENA, [15] = L.BGSize_15, [40] = L.BGSize_40}
					},
					Testmode_UseTeammates = {
						type = "toggle",
						name = L.Testmode_UseTeammates,
						desc = L.Testmode_UseTeammates_Desc,
						disabled = function() return self.TestmodeActive end,
						order = 1
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
					},
					UseBigDebuffsPriority = {
						type = "toggle",
						name = L.UseBigDebuffsPriority,
						desc = L.UseBigDebuffsPriority_Desc,
						order = 12
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
						func = function()
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
