---@class Data
---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata

local L = Data.L
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local LSM = LibStub("LibSharedMedia-3.0")


local LRC = LibStub:GetLibrary("LibRangeCheck-3.0")

local function GetAllModuleAnchors(moduleName)
	local moduleAnchors = {}
	for moduleNamee, moduleFrame in pairs(BattleGroundEnemies.ButtonModules) do
		if moduleName ~= moduleNamee then --cant anchor to itself
			moduleAnchors[moduleNamee] = moduleFrame.localizedModuleName
		end
	end
	moduleAnchors.Button = L.Button
	return moduleAnchors
end

local function overWriteSettigsKeepPlayerCount(t, k, v)
	local minPlayers, maxPlayers = BattleGroundEnemies:GetPlayerCountsFromConfig(t[k])

	t[k] = CopyTable(v)
	t[k].minPlayerCount = minPlayers
	t[k].maxPlayerCount = maxPlayers
	BattleGroundEnemies:NotifyChange()
end


local function getDefaultSettingsForGroup(group, defaults, ignoreChildGroups)
	local newSettings = {}
	local groupSettings = group.args
	for childKey, childData in pairs(groupSettings) do
		if childData.type == "group" then
			if not ignoreChildGroups then
				if childData.get or childData.set then
					return error("can't reset that since we don't know where the defaults live")
				else
					Mixin(newSettings, getDefaultSettingsForGroup(childData, defaults))
				end
			end
		else
			if type(defaults[childKey]) == "table" then
				newSettings[childKey] = CopyTable(defaults[childKey], false)
			else
				newSettings[childKey] = defaults[childKey]
			end
		end
	end
	return newSettings
end

local addResetFunctionForgroup = function(dbLocation, defaults, ignoreChildGroups)
	local function func(info)
		local option = CopyTable(info.options, false)
		for i = 1, #info -1 do
			option = option.args[info[i]]
		end
		local defaultsForGroup = getDefaultSettingsForGroup(option, defaults, ignoreChildGroups)

		Mixin(dbLocation, defaultsForGroup)
		BattleGroundEnemies:NotifyChange()
	end
	return func
end

local function convertPermutations(permutations)
    local result = {}

    for _, perm in ipairs(permutations) do
        local key = table.concat(perm, "_")
        local values = {}

        for _, role in ipairs(perm) do
            table.insert(values, _G[role])
        end

        result[key] = values
    end

    return result
end


---comment
---@param playerCountConfigs any
local function sortByMinPlayerCount(playerCountConfigs)
	table.sort(playerCountConfigs, function(playerCountConfigA, playerCountConfigB)
		return playerCountConfigA.minPlayerCount < playerCountConfigB.minPlayerCount
	end)
end

---comment
---@param playerCountConfigs any
---@param inputs any
---@param profileToIgnore any
---@return boolean
---@return string?
local function isValidPlayerCountRange(playerCountConfigs, isCustom, inputs, profileToIgnore)
	local min = inputs.MinPlayerCount
	local max = inputs.MaxPlayerCount
	if not min then return false, L.MinCantBeUndefined end
	if not max then return false, L.MaxCantBeUndefined end

	if min > max then return false, L.MaxNeedsToBeEqualOrGreater end

	for i = 1, #playerCountConfigs do
		local playerCountConfig = playerCountConfigs[i]
		if not profileToIgnore or playerCountConfig ~= profileToIgnore then
			local range = {
				min = playerCountConfig.minPlayerCount,
				max = playerCountConfig.maxPlayerCount
			}
			local newRange = {
				min = min,
				max = max
			}
			if Data.Helpers.AreOverlappingRanges(newRange, range) then
				return false, L.RangeOverlapping:format(BattleGroundEnemies:GetPlayerCountConfigNameLocalized(playerCountConfig, isCustom))
			end
		end
	end
	return true
end

---comment
---@return table
local function GetAllModuleFrames()
	local t = {}
	for moduleNamee, moduleFrame in pairs(BattleGroundEnemies.ButtonModules) do
		t[moduleNamee] = moduleFrame.localizedModuleName
	end
	return t
end

-- Points
-- TOPLEFT 		TOP 		TOPRIGHT
-- LEFT 		CENTER 		RIGHT
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

---comment
---@param Point1 any
---@param Point2 any
---@return boolean
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
	return false
end

function BattleGroundEnemies:GetActivePoints(config)
	if not config.Points then return end
	local activePoints = {}
	for i = 1, config.ActivePoints do
		activePoints[i] = config.Points[i]
	end
	return activePoints
end

function BattleGroundEnemies:FrameNeedsHeight(Point1, Point2)
	if not Point1 and not Point2 then return end
	if Point1 and not Point2 then return true end
	return isInSameHorizontal(Point1, Point2)
end

function BattleGroundEnemies:ModuleFrameNeedsHeight(moduleFrame, config)
	local flags = moduleFrame.flags

	if flags.HasDynamicSize then return false end

	local heightFlag = flags.Width

	if heightFlag == "Fixed" then return end

	local activePoints = self:GetActivePoints(config)
	if not activePoints then return end
	return BattleGroundEnemies:FrameNeedsWidth(activePoints[1], activePoints[2])
end


function BattleGroundEnemies:FrameNeedsWidth(Point1, Point2)
	if not Point1 and not Point2 then return end
	if Point1 and not Point2 then return true end
	return isInSameVertical(Point1, Point2)
end

function BattleGroundEnemies:ModuleFrameNeedsWidth(moduleFrame, config)
	local flags = moduleFrame.flags

	if flags.HasDynamicSize then return false end

	local widthFlag = flags.Width

	if widthFlag == "Fixed" then return end

	local activePoints = self:GetActivePoints(config)
	if not activePoints then return end
	return BattleGroundEnemies:FrameNeedsWidth(activePoints[1], activePoints[2])
end

local function canAddPoint(location, moduleFrame)
	local activePoints = location.ActivePoints
	if activePoints >1 then return false end
	if activePoints == 0 then return true end

	--if only 1 point is set
	if moduleFrame.flags.HasDynamicSize then return false end --Containers can only have 1 point
	if moduleFrame.flags.Width == "Fixed" and moduleFrame.flags.Height == "Fixed" then return false end

	return true
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
			--we basically end the loop after just one player since all player frames are using same options
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


---comment
---@param location any
---@param moduleName any
---@param moduleFrame any
---@param playerType any
---@return table
function Data.AddPositionSetting(location, moduleName, moduleFrame, playerType)
	local numPoints = location.ActivePoints
	local temp = {}
	temp.Parent = {
		type = "select",
		name = "Parent",
		values = GetAllModuleAnchors(moduleName),
		order = 2
	}
	temp.Fake1 = Data.AddVerticalSpacing(3)
	if location.Points and numPoints then

		for i = 1, numPoints do
			temp["Point"..i] = {
				type = "group",
				name = L.Point.." "..i,
				desc = "",
				get =  function(option)
					return Data.GetOption(location.Points[i], option)
				end,
				set = function(option, ...)
					return Data.SetOption(location.Points[i], option, ...)
				end,
				inline = true,
				order = i + 3,
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
						name = "RelativeFrame",
						values = GetAllModuleAnchors(moduleName),
						validate = function(option, value)

							if validateAnchor(playerType, moduleName, value) then
								-- print("validated")
								return true
							else
								--invalid anchor, there might be some looping issues
							--	print("hier")
								PlaySound(882)
								BattleGroundEnemies:NotifyChange()
								return false
							end
						end,
						order = 2
					},
					RelativePoint = {
						type = "select",
						name = "Relative Point",
						values = Data.AllPositions,
						order = 3
					},
					OffsetX = {
						type = "range",
						name = L.OffsetX,
						min = -300,
						max = 300,
						step = 1,
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
						name = L.DeletePoint:format(i),
						func = function()
							location.ActivePoints = i - 1
							BattleGroundEnemies:NotifyChange()
						end,
						disabled = i ~= numPoints or i == 1, --only allow to remove the last point, dont allow removal of all Points
						width = "full",
						order = 6,
					}
				}
			}

		end
	end

	-- temp.AddPoint = {
	-- 	type = "execute",
	-- 	name = L.AddPoint,
	-- 	func = function()
	-- 		location.ActivePoints = numPoints + 1
	-- 		location.Points = location.Points or {}
	-- 		location.Points[numPoints + 1] = location.Points[numPoints + 1] or {
	-- 			Point = "TOPLEFT",
	-- 			RelativeFrame = "Button",
	-- 			RelativePoint = "TOPLEFT"
	-- 		}
	-- 		BattleGroundEnemies:NotifyChange()
	-- 	end,
	-- 	disabled = function()
	-- 		if not location.Points then return false end

	-- 		--dynamic containers with dynamic width and height can have a maximum of 1 point
	-- 		return not canAddPoint(location, moduleFrame)
	-- 	end,
	-- 	width = "full",
	-- 	order = numPoints + 4
	-- }
	temp.WidthGroup = {
		type = "group",
		name = L.Width,
		order = numPoints + 5,
		hidden = function()
			local widthNeeded = BattleGroundEnemies:ModuleFrameNeedsWidth(moduleFrame, location)
			if not widthNeeded then
				return true
			end
		end,
		inline = true,
		args = {
			UseButtonHeightAsWidth = {
				type = "toggle",
				name = L.UseButtonHeight,
				order = 1
			},
			Width = {
				type = "range",
				name = L.Width,
				min = 0,
				max = 100,
				step = 1,
				hidden = function()
					local hidden = location.UseButtonHeightAsWidth
					if hidden then
						BattleGroundEnemies:NotifyChange()
						return true
					end
				end,
				order = 2
			}
		}
	}
	temp.HeightGroup = {
		type = "group",
		name = L.Height,
		order = numPoints + 6,
		hidden = function()
			local heightNeeded = BattleGroundEnemies:ModuleFrameNeedsHeight(moduleFrame, location)
			if not heightNeeded then
				return true
			end
		end,
		inline = true,
		args = {
			UseButtonHeightAsHeight = {
				type = "toggle",
				name = L.UseButtonHeight,
				order = 1
			},
			Height = {
				type = "range",
				name = L.Height,
				min = 0,
				max = 100,
				step = 1,
				hidden = function()
					local hidden = location.UseButtonHeightAsHeight
					if hidden then
						location.Height = false
						BattleGroundEnemies:NotifyChange()
						return true
					end
				end,
				order = 2
			}
		}
	}


	return temp
end





-- local function copy(obj)
-- 	if type(obj) ~= 'table' then return obj end
-- 	local res = {}
-- 	for k, v in pairs(obj) do res[copy(k)] = copy(v) end
-- 	return res
-- end

local CopyTable = CopyTable or function(settings, shallow)
	local copy = {};
	for k, v in pairs(settings) do
		if type(v) == "table" and not shallow then
			copy[k] = CopyTable(v);
		else
			copy[k] = v;
		end
	end
	return copy;
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
		value = {...}  --local r, g, b, alpha = ...
	else
		value = ...
	end
	--DevTool:AddData(CopyTable(location) , "location")
	--DevTool:AddData(CopyTable(option) , "option")
	location[option[#option]] = value
	BattleGroundEnemies:ApplyAllSettingsDebounce()


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


function Data.AddContainerSettings(location)
	return {
		IconSize = {
			type = "range",
			name = L.Size,
			min = 0,
			max = 80,
			step = 1,
			order = 1,
			hidden = function() return location.UseButtonHeightAsSize end,
		},
		UseButtonHeightAsSize = {
			type = "toggle",
			name = L.UseButtonHeight,
			desc = L.UseButtonHeight_Desc,
			order = 2
		},
		IconsPerRow = {
			type = "range",
			name = L.IconsPerRow,
			min = 4,
			max = 30,
			step = 1,
			order = 3
		},
		Fake = Data.AddVerticalSpacing(4),
		HorizontalGrowDirection = {
			type = "select",
			name = L.HorizontalGrowdirection,
			values = Data.HorizontalDirections,
			order = 5
		},
		HorizontalSpacing = {
			type = "range",
			name = L.HorizontalSpacing,
			min = 0,
			max = 20,
			step = 1,
			order = 6
		},
		Fake1 = Data.AddVerticalSpacing(7),
		VerticalGrowdirection = {
			type = "select",
			name = L.VerticalGrowdirection,
			values = Data.VerticalDirections,
			order = 8
		},
		VerticalSpacing = {
			type = "range",
			name = L.VerticalSpacing,
			min = 0,
			max = 20,
			step = 1,
			order = 9
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

local FontOutlines = {
	[""] = L.None,
	["OUTLINE"] = L.Normal,
	["THICKOUTLINE"] = L.Thick,
}

function Data.AddNormalTextSettings(location, defaults)
	return {
		Reset = {
			type = "execute",
			name = SETTINGS_DEFAULTS,
			func = addResetFunctionForgroup(location, defaults),
			width = "full",
			hidden = not defaults,
			order = 1,
		},
		JustifyH = {
			type = "select",
			name = L.JustifyH,
			desc = L.JustifyH_Desc,
			values = JustifyHValues,
			order = 2
		},
		JustifyV = {
			type = "select",
			name = L.JustifyV,
			desc = L.JustifyV_Desc,
			values = JustifyVValues,
			order = 3
		},
		FontSize = {
			type = "range",
			name = L.FontSize,
			desc = L.FontSize_Desc,
			min = 1,
			max = 40,
			step = 1,
			width = "normal",
			order = 4
		}
	}
end


function Data.AddCooldownSettings(location)
	return {
		FontSize = {
			type = "range",
			name = L.FontSize,
			desc = L.FontSize_Desc,
			min = 6,
			max = 40,
			step = 1,
			width = "normal",
			order = 3
		},
	}
end

--nice idea but it kinda sucks
local function generateOverwritableOptions(location, options)
	local newOptions = {}
	for k,v in pairs(options) do
		if v.type ~= "group" then
			if v.name and v.name ~= " " then
				local newK = "overWrite"..k
				newOptions[newK] = {
					type = "group",
					name = "",
					desc = L.overwrite_desc,
					inline = true,
					order = v.order or 1,
					args = {}
				}
				newOptions[newK].args[newK] =  {
					name = L.overwrite,
					desc = L.overwrite_desc,
					type = "toggle",
					order = 1
				}
				print("k", k)
				newOptions[newK].args[k] = v
				newOptions[newK].args[k].order = 2
				newOptions[newK].args[k].disabled = function()
					return not location[newK]
				end
			end
		else
			newOptions[k] = v
			newOptions[k].args = generateOverwritableOptions(location, v.args)
		end
	end
	return newOptions
end

function BattleGroundEnemies:GetModuleOptions(location, options)
	local moduleOptions = type(options) == "function" and options(location) or options
	return moduleOptions
end

function BattleGroundEnemies:AddModulesSettings(location, playerCountConfigDefault, playerType, condidtionFunc)
	local temp = {}
	for moduleName, moduleFrame in pairs(self.ButtonModules) do

		local locationn = location.ButtonModules[moduleName]

		local moduleOptions = BattleGroundEnemies:GetModuleOptions(locationn, moduleFrame.options)


		if condidtionFunc(moduleFrame) then
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
				disabled = function() return not BattleGroundEnemies:IsModuleEnabledOnThisExpansion(moduleName) end,
				childGroups = "tab",
				args = {
					Enabled = {
						type = "toggle",
						name = VIDEO_OPTIONS_ENABLED,
						width = "normal",
						order = 1
					},
					ShowGeneralOptions = {
						type = "execute",
						name = L.JumpToGeneralOptions,
						desc = L.JumpToGeneralOptions_Desc,
						func = function()
							local optionsPath = {"BattleGroundEnemies", "GeneralSettings", "ButtonModules", moduleName}
							AceConfigDialog:SelectGroup(unpack(optionsPath))
						end,
						hidden = not BattleGroundEnemies.ButtonModules[moduleName].generalOptions,
						width = "full",
						order = 2
					},
					Reset = {
						type = "execute",
						name = SETTINGS_DEFAULTS,
						desc = L.ResetModule_Desc:format(L[playerType], BattleGroundEnemies:GetPlayerCountConfigNameLocalized(location)),
						func = function()
							location.ButtonModules[moduleName] = CopyTable(playerCountConfigDefault.ButtonModules[moduleName])
							BattleGroundEnemies:NotifyChange()
						end,
						width = "full",
						order = 3,
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
						hidden = moduleFrame.flags.FixedPosition,
						order = 4,
						args = Data.AddPositionSetting(locationn, moduleName, moduleFrame, playerType)
					},
					ModuleSettings = moduleOptions and {
						type = "group",
						name = L.ModuleSpecificSettings,
						get =  function(option)
							return Data.GetOption(locationn, option)
						end,
						set = function(option, ...)
							return Data.SetOption(locationn, option, ...)
						end,
						order = 5,
						disabled = function() return not locationn.Enabled end,
						args = moduleOptions,
						childGroups = "tab"
					},

				}
			}
		end


	end
	return temp
end

function BattleGroundEnemies:AddGeneralModuleSettings()
	local temp = {}
	for moduleName, moduleFrame in pairs(self.ButtonModules) do
		if moduleFrame.generalOptions then
			local locationn = BattleGroundEnemies.db.profile.ButtonModules[moduleName]
			local defaults = BattleGroundEnemies.db.defaults.profile.ButtonModules[moduleName]


			local moduleOptions = self:GetModuleOptions(locationn, moduleFrame.generalOptions)

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
				disabled = function() return not BattleGroundEnemies:IsModuleEnabledOnThisExpansion(moduleName) end,
				hidden = not moduleFrame.generalOptions,
				childGroups = "tab",
				args = {
					Reset = {
						type = "execute",
						name = SETTINGS_DEFAULTS,
						desc = L.ResetGeneralModule_Desc,
						func = function()
							BattleGroundEnemies.db.profile.ButtonModules[moduleName] = CopyTable(defaults)
							BattleGroundEnemies:NotifyChange()
						end,
						width = "full",
						order = 1,
					}
				}
			}
			if moduleOptions then
				for k,v in pairs(moduleOptions) do
					temp[moduleName].args[k] = v
					temp[moduleName].args[k].order = temp[moduleName].args[k].order + 1
				end
			end
		end
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
				order = 1
			},
			CustomPlayerCountConfigsEnabled = {
				type = "toggle",
				name = L.EnableCustomPlayerCountProfiles,
				desc = L.EnableCustomPlayerCountProfiles_Desc,
				get =  function(option)
					return Data.GetOption(location, option)
				end,
				set = function(option, ...)

					Data.SetOption(location, option, ...)
					BattleGroundEnemies:NotifyChange()
				end,
				order = 2,
				width = "double",
			},
			CopySettings = {
				type = "select",
				name = L.CopySettings,
				desc = L.Normal.."\n".. L.CopySettingsNormal_Desc.."\n\n"..L.Mirrored..'\n' ..L.CopySettingsMirrored_Desc,
				get = function() return "" end,
				set = function(option, value)
					if value == "Normal" then
						BattleGroundEnemies.db.profile[playerType] = CopyTable(BattleGroundEnemies.db.profile[oppositePlayerType], false)
					elseif value == "Mirrored" then
						BattleGroundEnemies.db.profile[playerType] = BattleGroundEnemies:FlipSettingsHorizontallyRecursive(BattleGroundEnemies.db.profile[oppositePlayerType])
					end
					BattleGroundEnemies:NotifyChange()
				end,
				values = {
					Normal = L.Normal..": ".. L[oppositePlayerType],
					Mirrored = L.Mirrored..": "..L[oppositePlayerType]
				},
				confirm = function(t, value)
					local phrase
					if value == "Mirrored" then
						phrase = L.OverwriteMirroredConfirm
					elseif value == "Normal" then
						phrase = L.OverwriteNormalConfirm
					end
					return phrase:format(L[playerType], L[oppositePlayerType])
				end,
				order = 3
			},
			LoadDefaults = {
				type = "execute",
				name = SETTINGS_DEFAULTS,
				func = function()
					BattleGroundEnemies.db.profile[playerType] = CopyTable(BattleGroundEnemies.db.defaults.profile[playerType], false)
					BattleGroundEnemies:NotifyChange()
				end,
				confirm = function ()
					return "Are you sure?"
				end,
				width = 1.6,
				order = 4
			},
			RangeIndicator_Settings = {
				type = "group",
				name = L.RangeIndicator_Settings,
				desc = L.RangeIndicator_Settings_Desc,
				order = 7,
				args = {
					Reset = {
						type = "execute",
						name = SETTINGS_DEFAULTS,
						func = addResetFunctionForgroup(location, BattleGroundEnemies.db.defaults.profile[playerType]),
						width = "full",
						order = 1,
					},
					RangeIndicator_Enabled = {
						type = "toggle",
						name = L.RangeIndicator_Enabled,
						desc = L.RangeIndicator_Enabled_Desc,
						order = 2
					},
					RangeIndicator_Range = {
						type = "select",
						name = L.RangeIndicator_Range,
						desc = L.RangeIndicator_Range_Desc,
						disabled = function() return not location.RangeIndicator_Enabled end,
						-- get = function() return Data[playerType.."ItemIDToRange"][location.RangeIndicator_Range] end,
						-- set = function(option, value)
						-- 	value = Data[playerType.."RangeToItemID"][value]
						-- 	return Data.SetOption(location, option, value)
						-- end,
						-- values =   Data[playerType.."RangeToRange"],
						values = function()
							local checkers
							if playerType == "Enemies" then
								checkers = LRC:GetHarmCheckers(true)
							else
								checkers = LRC:GetFriendCheckers(true)
							end
							local ranges = {}
							for range, checker in checkers do
								ranges[range] = range
							end
							return ranges
						end,
						width = "half",
						order = 3
					},
					RangeIndicator_Alpha = {
						type = "range",
						name = L.RangeIndicator_Alpha,
						desc = L.RangeIndicator_Alpha_Desc,
						disabled = function() return not location.RangeIndicator_Enabled end,
						min = 0,
						max = 1,
						step = 0.05,
						order = 4
					},
					Fake = Data.AddVerticalSpacing(5),
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
						end,
						width = "double",
						values = function() return GetAllModuleFrames() end,
						order = 7
					}
				}
			},
			KeybindSettings = {
				type = "group",
				name = KEY_BINDINGS,
				desc = L.KeybindSettings_Desc.." "..L.NotAvailableInCombat,
				disabled = InCombatLockdown,
				--childGroups = "tab",
				order = 8,
				args = {
					Reset = {
						type = "execute",
						name = SETTINGS_DEFAULTS,
						func = addResetFunctionForgroup(location, BattleGroundEnemies.db.defaults.profile[playerType]),
						width = "full",
						order = 1,
					},
					ActionButtonUseKeyDown = {
						type = "toggle",
						name = ACTION_BUTTON_USE_KEY_DOWN,
						desc = OPTION_TOOLTIP_ACTION_BUTTON_USE_KEY_DOWN,
						order = 2,
					},
					UseClique = {
						type = "toggle",
						name = L.EnableClique,
						desc = L.EnableClique_Desc,
						order = 3,
						hidden = playerType == "Enemies"
					},
					LeftButton = {
						type = "group",
						name = KEY_BUTTON1,
						order = 4,
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
							}
						}
					},
					RightButton = {
						type = "group",
						name = KEY_BUTTON2,
						order = 5,
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
							}
						}
					},
					MiddleButton = {
						type = "group",
						name = KEY_BUTTON3,
						order = 6,
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

	local isCustomProfileEnabled
	local playerCountConfigs = BattleGroundEnemies.db.profile[playerType].playerCountConfigs
	local customPlayerCountConfigs = BattleGroundEnemies.db.profile[playerType].customPlayerCountConfigs
	local thisPlayerCountConfigs


	local allDbLocations = {}
	local allPlayerCountConfigOptionsNames = {}
	local numBasicProfile = #playerCountConfigs
	for i = 1, #playerCountConfigs do
		table.insert(allDbLocations, playerCountConfigs[i])
		table.insert(allPlayerCountConfigOptionsNames, L[playerType]..": ".. BattleGroundEnemies:GetPlayerCountConfigNameLocalized(playerCountConfigs[i], false))

	end

	if BattleGroundEnemies.db.profile[playerType].CustomPlayerCountConfigsEnabled then
		isCustomProfileEnabled = true
		thisPlayerCountConfigs = customPlayerCountConfigs
		-- add the 3 basic profiles, but disable them, also add the custome ones

		for i = 1, #customPlayerCountConfigs do
			table.insert(allDbLocations, customPlayerCountConfigs[i])
			table.insert(allPlayerCountConfigOptionsNames, L[playerType]..": ".. BattleGroundEnemies:GetPlayerCountConfigNameLocalized(customPlayerCountConfigs[i], true))
		end
	else
		thisPlayerCountConfigs = playerCountConfigs
	end


	for i = 1, #allDbLocations do
		local indexThisPlayerCountConfg
		local isCustomProfile
		local location = allDbLocations[i]

		

		if i > numBasicProfile then
			isCustomProfile = true
			indexThisPlayerCountConfg = i - numBasicProfile
		else
			isCustomProfile = false
			indexThisPlayerCountConfg = i
		end

		local currentProfileName = BattleGroundEnemies:GetPlayerCountConfigNameLocalized(location, isCustomProfile)

		local allConfigsWithoutCurrent = {}
		local allPlayerCountConfigOptionsNamesWithoutCurrent = {}
		for j = 1, #allDbLocations do
			if allDbLocations[j] ~= location then
				table.insert(allConfigsWithoutCurrent, allDbLocations[j])
				table.insert(allPlayerCountConfigOptionsNamesWithoutCurrent, allPlayerCountConfigOptionsNames[j])
			end
		end

		local playerCountConfigDefaults = BattleGroundEnemies.db.defaults.profile[playerType].playerCountConfigs
		local playerCountConfigDefault = playerCountConfigDefaults[i]

		local tempInputs = {
			MinPlayerCount = location.minPlayerCount,
			MaxPlayerCount = location.maxPlayerCount
		}
		-- local playerCountConfigsCopy = CopyTable(playerCountConfigs)
		-- local playerCountConfigsWithoutCurrentConfig = table.remove(playerCountConfigsCopy, i)
		-- print("i is ", i, #playerCountConfigsWithoutCurrentConfig)
		-- print("bla", #playerCountConfigsCopy)
		settings[BattleGroundEnemies:GetPlayerCountConfigName(location)] = {
			type = "group",
			name = currentProfileName,
			desc = currentProfileName.."desc",
			disabled = function()
				return not mainFrame.playerTypeConfig.Enabled or isCustomProfileEnabled and not isCustomProfile
			end,
			get =  function(option)
				return Data.GetOption(location, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location, option, ...)
			end,
			order = i + 1,
			args = {
				Enabled = {
					type = "toggle",
					name = ENABLE,
					order = 1
				},
				--Fake = Data.AddVerticalSpacing(2),
				CopySettings = {
					type = "select",
					name = L.CopySettings,
					get = function() return "" end,
					set = function(option, value)
						overWriteSettigsKeepPlayerCount(thisPlayerCountConfigs, indexThisPlayerCountConfg, allConfigsWithoutCurrent[value])
					end,
					values = allPlayerCountConfigOptionsNamesWithoutCurrent,
					confirm = function()
						return L.ConfirmProfileOverride:format(L[playerType]..": "..currentProfileName, L[playerType]..": "..currentProfileName)
					end,
					width = 1.5,
					order = 3
				},
				LoadFromDefaultPlayerCountProfile = {
					type = "select",
					name = SETTINGS_DEFAULTS,
				 	get = function() return "" end,
						-- set = function(option, value)
						-- 	value = Data[playerType.."RangeToItemID"][value]
						-- 	return Data.SetOption(location, option, value)
						-- end,
						-- values =   Data[playerType.."RangeToRange"],
					set = function(option, value)
						overWriteSettigsKeepPlayerCount(thisPlayerCountConfigs, indexThisPlayerCountConfg, isCustomProfileEnabled and playerCountConfigDefaults[value] or playerCountConfigDefault)
					end,
					values = function()
						local t = {}
						table.insert(t, L[playerType]..": ".. BattleGroundEnemies:GetPlayerCountConfigNameLocalized(playerCountConfigDefault))
						return t
					end,
					confirm = function ()
						return "Are you sure?"
					end,
					width = 1.5,
					order = 4
				},
				blub = {
					type = "group",
					name = "",
					order = 5,
					inline = true,
					hidden = not isCustomProfile,
					args = {
						MinPlayerCount = {
							type = "range",
							min = 1,
							max = 40,
							step = 1,
							name = L.MinPlayerCount,
							get = function()
								return tempInputs.MinPlayerCount
							end,
							set = function(option, value)
								tempInputs.MinPlayerCount = value
							end,
							order = 1
						},
						MaxPlayerCount = {
							type = "range",
							min = 1,
							max = 40,
							step = 1,
							name = L.MaxPlayerCount,
							get = function()
								return tempInputs.MaxPlayerCount
								end,
							set = function(option, value)
								tempInputs.MaxPlayerCount = value
							end,
							order = 2
						},
						ChangePlayerCount = {
							type = "execute",
							name = L.Change,
							func = function(option, value)
								location.minPlayerCount = tempInputs.MinPlayerCount
								location.maxPlayerCount = tempInputs.MaxPlayerCount
								sortByMinPlayerCount(thisPlayerCountConfigs)
								BattleGroundEnemies:NotifyChange()
							end,
							confirm = function()
								return "Are you sure you want to change this profile so its used for "..tempInputs.MinPlayerCount.." to "..tempInputs.MaxPlayerCount.."players for "..playerType.." ?"
							end,
							disabled = function ()
								return not isValidPlayerCountRange(thisPlayerCountConfigs, true, tempInputs,  location)
							end,
							order = 3
						},
						DeletePlayerCountProfile = {
							type = "execute",
							name = DELETE,
							desc = L.DeletePlayerCountProfile_Desc .. ": " ..L[playerType]..": "..currentProfileName,
							func = function()
								table.remove(thisPlayerCountConfigs, indexThisPlayerCountConfg)
								BattleGroundEnemies:NotifyChange()
							end,
							confirm = function()
								return L.ConfirmDeletePlayerCountProfile..": ".. L[playerType]..": "..currentProfileName
							end,
							hidden = not isCustomProfileEnabled,
							width = "half",
							order = 4
						},
						errormsg =  {
							type = "description",
							fontSize = "large",
							name = function ()
								local isGood, errorMessage = isValidPlayerCountRange(thisPlayerCountConfigs, true, tempInputs, location)
								if not isGood then
									return ERRORS..": ".. errorMessage
								end
							end,
							hidden = function ()
								if not isCustomProfileEnabled then return true end
								return isValidPlayerCountRange(thisPlayerCountConfigs, true, tempInputs, location)
							end,
							order = 5
						}
					}
				},
				MainFrameSettings = {
					type = "group",
					name = L.MainFrameSettings,
					desc = L.MainFrameSettings_Desc:format(L[playerType == "Enemies" and "enemies" or "allies"]),
					disabled = function() return not location.Enabled end,
					--childGroups = "tab",
					order = 6,
					args = {
						Framescale = {
							type = "range",
							name = L.Framescale,
							desc = L.Framescale_Desc.." "..L.NotAvailableInCombat,
							disabled = InCombatLockdown,
							min = 0.3,
							max = 2,
							step = 0.05,
							order = 1
						},
						PlayerCount = {
							type = "group",
							name = "",
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
									name = L.PlayerCount,
									desc = L.PlayerCount_Enabled_Desc,
									order = 1
								}
							}
						}
					}
				},
				ButtonSettings = {
					type = "group",
					name = L.Button,
					disabled = function() return not location.Enabled end,
					--childGroups = "tab",
					order = 7,
					args = {
						Reset = {
							type = "execute",
							name = SETTINGS_DEFAULTS,
							func = addResetFunctionForgroup(location, playerCountConfigDefault, true),
							width = "full",
							order = 1,
						},
						BarWidth = {
							type = "range",
							name = L.Width,
							desc = L.BarWidth_Desc.." "..L.NotAvailableInCombat,
							disabled = InCombatLockdown,
							min = 1,
							max = 400,
							step = 1,
							order = 2
						},
						BarHeight = {
							type = "range",
							name = L.Height,
							desc = L.BarHeight_Desc.." "..L.NotAvailableInCombat,
							disabled = InCombatLockdown,
							min = 1,
							max = 100,
							step = 1,
							order = 3
						},
						BarVerticalGrowdirection = {
							type = "select",
							name = L.VerticalGrowdirection,
							desc = L.VerticalGrowdirection_Desc.." "..L.NotAvailableInCombat,
							disabled = InCombatLockdown,
							values = Data.VerticalDirections,
							order = 4
						},
						BarVerticalSpacing = {
							type = "range",
							name = L.VerticalSpacing,
							desc = L.VerticalSpacing.." "..L.NotAvailableInCombat,
							disabled = InCombatLockdown,
							min = 0,
							max = 100,
							step = 1,
							order = 5
						},
						BarColumns = {
							type = "range",
							name = L.Columns,
							desc = L.Columns_Desc.." "..L.NotAvailableInCombat,
							disabled = InCombatLockdown,
							min = 1,
							max = 4,
							step = 1,
							order = 6
						},
						BarHorizontalGrowdirection = {
							type = "select",
							name = L.HorizontalGrowdirection,
							desc = L.HorizontalGrowdirection_Desc.." "..L.NotAvailableInCombat,
							hidden = function() return location.BarColumns < 2 end,
							disabled = InCombatLockdown,
							values = Data.HorizontalDirections,
							order = 7
						},
						BarHorizontalSpacing = {
							type = "range",
							name = L.HorizontalSpacing,
							desc = L.HorizontalSpacing.." "..L.NotAvailableInCombat,
							hidden = function() return location.BarColumns < 2 end,
							disabled = InCombatLockdown,
							min = 0,
							max = 400,
							step = 1,
							order = 8
						}
					}
				},
				ModuleSettings = {
					type = "group",
					name = L.Modules,
					order = 8,
					args = self:AddModulesSettings(location, playerCountConfigDefault, playerType, function(options) return not options.attachSettingsToButton end)
				}
			}
		}
		Mixin(settings[BattleGroundEnemies:GetPlayerCountConfigName(location)].args.ButtonSettings.args, self:AddModulesSettings(location, playerCountConfigDefault, playerType, function(options) return options.attachSettingsToButton end))
	end

	local inputs = {
		MinPlayerCount = 1,
		MaxPlayerCount = 1
	}

	settings.NewPlayerCountProfile = {
		type = "group",
		name = "+",
		childGroups = "tab",
		order = #allDbLocations + 2,
		hidden = not isCustomProfileEnabled,
		args = {
			MinPlayerCount = {
				type = "range",
				min = 1,
				max = 40,
				step = 1,
				name = L.MinPlayerCount,
				get = function()
					return inputs.MinPlayerCount
				end,
				set = function(option, value)
					inputs.MinPlayerCount = value
				end,
				order = 1
			},
			MaxPlayerCount = {
				type = "range",
				min = 1,
				max = 40,
				step = 1,
				name = L.MaxPlayerCount,
				get = function()
					return inputs.MaxPlayerCount
					end,
				set = function(option, value)
					inputs.MaxPlayerCount = value
				end,
				order = 2
			},
			BaseProfile = {
				type = "select",
				name = L.CopyFrom,
				get = function() return "" end,
				set = function(option, value)
					table.insert(thisPlayerCountConfigs, CopyTable(allDbLocations[value]))
					thisPlayerCountConfigs[#thisPlayerCountConfigs].minPlayerCount = inputs.MinPlayerCount
					thisPlayerCountConfigs[#thisPlayerCountConfigs].maxPlayerCount = inputs.MaxPlayerCount
					sortByMinPlayerCount(thisPlayerCountConfigs)
					BattleGroundEnemies:NotifyChange()
				end,
				values = allPlayerCountConfigOptionsNames,
				disabled = function ()
					return not isValidPlayerCountRange(thisPlayerCountConfigs, true, inputs)
				end,
				width = "double",
				order = 3
			},
			errormsg =  {
				type = "description",
				fontSize = "large",
				name = function ()
					local isGood, errorMessage = isValidPlayerCountRange(thisPlayerCountConfigs, true, inputs)
					if not isGood then
						return ERRORS..": ".. errorMessage
					end
				end,
				hidden = function ()
					return isValidPlayerCountRange(thisPlayerCountConfigs, true, inputs)
				end,
				order = 4,
			},

		}
	}
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
				disabled = function() return InCombatLockdown() end,
				inline = true,
				order = 1,
				args = {
					Testmode_PlayerCount = {
						type = "range",
						name = L.PlayerCount,
						disabled = InCombatLockdown,
						min = 1,
						max = 40,
						step = 1,
						get = function() return self.Testmode.PlayerCountTestmode end,
						set = function(option, value)
							self:TestModePlayerCountChanged(value)
						end,
						order = 1
					},
					Testmode_Enabled = {
						type = "execute",
						name = L.Testmode_Toggle,
						desc = L.Testmode_Toggle_Desc,
						disabled = function() return InCombatLockdown() end,
						func = self.ToggleTestmode,
						order = 2
					},
					Editmode_Enabled = {
						type = "execute",
						name = L.Editmode_Toggle,
						desc = L.Editmode_Toggle_Desc,
						disabled = function() return InCombatLockdown() end,
						func = self.ToggleEditmode,
						order = 2
					},
					Testmode_ToggleAnimation = {
						type = "execute",
						name = L.Testmode_ToggleAnimation,
						desc = L.Testmode_ToggleAnimation_Desc,
						disabled = function() return InCombatLockdown() or not self.Testmode.Active end,
						func = self.ToggleTestmodeOnUpdate,
						order = 3
					},
					Testmode_UseTeammates = {
						type = "toggle",
						name = L.Testmode_UseTeammates,
						desc = L.Testmode_UseTeammates_Desc,
						disabled = function() return self.Testmode.Active end,
						width = "full",
						order = 4
					},
				}
			},
			GeneralSettings = {
				type = "group",
				name = GENERAL,
				desc = L.GeneralSettings_Desc,
				order = 2,
				args = {
					Locked = {
						type = "toggle",
						name = L.Locked,
						desc = L.Locked_Desc,
						order = 1
					},
					ShowBGEInArena = {
						type = "toggle",
						name = L.EnableInArenas,
						order = 2
					},
					ShowBGEInBattleground = {
						type = "toggle",
						name = L.EnableInBattlegrounds,
						order = 3
					},
					miscellaneous = {
						type = "group",
						name = MISCELLANEOUS,
						order = 4,
						args = {
							Reset = {
								type = "execute",
								name = SETTINGS_DEFAULTS,
								func = addResetFunctionForgroup(BattleGroundEnemies.db.profile, BattleGroundEnemies.db.defaults.profile),
								width = "full",
								order = 1,
							},
							EnableMouseWheelPlayerTargeting = {
								type = "toggle",
								name = L.MouseWheelPlayerTargeting,
								desc = L.MouseWheelPlayerTargeting_Desc,
								order = 2
							},
							ShowTooltips = {
								type = "toggle",
								name = L.ShowTooltips,
								desc = L.ShowTooltips_Desc,
								order = 3
							},
							ConvertCyrillic = {
								type = "toggle",
								name = L.ConvertCyrillic,
								desc = L.ConvertCyrillic_Desc,
								width = "normal",
								order = 4
							},
							RoleSortingOrder = {
								type = "select",
								name = L.RoleSortingOrder,
								desc = L.RoleSortingOrder_Desc,
								values = function ()
									local roles = Data.PlayerRoles
									local allRolePermutations = Data.Helpers.permgen(roles)

									local result = {}
									for _, perm in ipairs(allRolePermutations) do
										local key = table.concat(perm, "_")
										local values = {}

										for _, role in ipairs(perm) do
											table.insert(values, _G[role])
										end
										result[key] = table.concat(values, " > ")
									end

									return result
								end,
								width = "double",
							},
							HideArenaframesIn = {
								type = "group",
								name = L.HideArenaframesIn,
								inline = true,
								order = 7,
								args = {
									DisableArenaFramesInArena = {
										type = "toggle",
										name = ARENA,
										order = 1
									},
									DisableArenaFramesInBattleground = {
										type = "toggle",
										name = BATTLEFIELDS,
										order = 2
									}
								}
							},
							HideRaidframesIn = {
								type = "group",
								name = L.HideRaidframesIn,
								inline = true,
								order = 8,
								args = {
									DisableRaidFramesInArena = {
										type = "toggle",
										name = ARENA,
										order = 1
									},
									DisableRaidFramesInBattleground = {
										type = "toggle",
										name = BATTLEFIELDS,
										order = 2
									}
								}
							},
							MyTarget = {
								type = "group",
								name = L.MyTarget,
								inline = true,
								order = 9,
								args = {
									MyTarget_Color = {
										type = "color",
										name = L.Color,
										desc = L.MyTarget_Color_Desc,
										hasAlpha = true,
										order = 1
									},
									MyTarget_BorderSize = {
										type = "range",
										name = L.BorderSize,
										min = 1,
										max = 5,
										step = 1,
										order = 2
									}
								}
							},
							MyFocus = {
								type = "group",
								name = L.MyFocus,
								inline = true,
								order = 10,
								args = {
									MyFocus_Color = {
										type = "color",
										name = L.Color,
										desc = L.MyFocus_Color_Desc,
										hasAlpha = true,
										order = 1
									},
									MyFocus_BorderSize = {
										type = "range",
										name = L.BorderSize,
										min = 1,
										max = 5,
										step = 1,
										order = 2
									}
								}
							},

						}
					},
					DataSettings = {
						type = "group",
						name = L.Data,
						childGroups = "tab",
						order = 5,
						args = {
							Reset = {
								type = "execute",
								name = SETTINGS_DEFAULTS,
								func = addResetFunctionForgroup(BattleGroundEnemies.db.profile, BattleGroundEnemies.db.defaults.profile),
								width = "full",
								order = 1,
							},
							UseBigDebuffsPriority = {
								type = "toggle",
								name = L.UseBigDebuffsPriority,
								desc = L.UseBigDebuffsPriority_Desc:format(L.Buffs, L.Debuffs, L.HighestPriorityAura),
								width = "full",
								order = 2
							},
						}
					},
					CooldownSettings = {
						type = "group",
						name = L.Cooldown,
						get = function(option)
							return Data.GetOption(location.Cooldown, option)
						end,
						set = function(option, ...)
							return Data.SetOption(location.Cooldown, option, ...)
						end,
						args = {
							Reset = {
								type = "execute",
								name = SETTINGS_DEFAULTS,
								func = function()
									location.Cooldown = CopyTable(BattleGroundEnemies.db.defaults.profile.Cooldown)
									BattleGroundEnemies:NotifyChange()
								end,
								width = "full",
								order = 1,
							},
							ShowNumber = {
								type = "toggle",
								name = L.ShowNumbers,
								desc = L.ShowNumbers_Desc,
								order = 2
							},
							DrawSwipe = {
								type = "toggle",
								name = L.Enable_DrawSwipe,
								desc = L.Enable_DrawSwipe_Desc,
								order = 3
							}
						},
						order = 6
					},
					TextSettings = {
						type = "group",
						name = L.Text,
						get = function(option)
							return Data.GetOption(location.Text, option)
						end,
						set = function(option, ...)
							return Data.SetOption(location.Text, option, ...)
						end,
						args = {
							Reset = {
								type = "execute",
								name = SETTINGS_DEFAULTS,
								func = function()
									location.Text = CopyTable(BattleGroundEnemies.db.defaults.profile.Text)
									BattleGroundEnemies:NotifyChange()
								end,
								width = "full",
								order = 1,
							},
							Font = {
								type = "select",
								name = L.Font,
								desc = L.Font_Desc,
								dialogControl = "LSM30_Font",
								values = AceGUIWidgetLSMlists.font,
								order = 2
							},
							FontColor = {
								type = "color",
								name = L.Fontcolor,
								desc = L.Fontcolor_Desc,
								hasAlpha = true,
								order = 3
							},
							Fake = Data.AddVerticalSpacing(4),
							FontOutline = {
								type = "select",
								name = L.Font_Outline,
								desc = L.Font_Outline_Desc,
								values = FontOutlines,
								order = 5
							},
							Fake1 = Data.AddVerticalSpacing(6),
							EnableShadow = {
								type = "toggle",
								name = L.FontShadow_Enabled,
								desc = L.FontShadow_Enabled_Desc,
								order = 7
							},
							ShadowColor = {
								type = "color",
								name = L.FontShadowColor,
								desc = L.FontShadowColor_Desc,
								disabled = function()
									return not location.Text.EnableShadow
								end,
								hasAlpha = true,
								order = 8
							}
						},
						order = 7
					},
					PlayerCount = {
						type = "group",
						name = L.PlayerCount,
						get = function(option)
							return Data.GetOption(location.PlayerCount.Text, option)
						end,
						set = function(option, ...)
							return Data.SetOption(location.PlayerCount.Text, option, ...)
						end,
						order = 8,
						args = Data.AddNormalTextSettings(location.PlayerCount.Text, BattleGroundEnemies.db.defaults.profile.PlayerCount.Text)
					},
					ButtonModules = {
						type = "group",
						name = L.Modules,
						args = self:AddGeneralModuleSettings(),
						order = 9
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
			RBGSettings = {
				type = "group",
				name = L.RBGSpecificSettings,
				desc = L.RBGSpecificSettings_Desc,
				--inline = true,
				order = 6,
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
			MoreProfileOptions = {
				type = "group",
				name = L.MoreProfileOptions,
				childGroups = "tab",
				order = 7,
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
						func = function ()
							return BattleGroundEnemies:ExportButtonPressed()
						end,
						order = 2,
					},
					-- shareActiveProfile = {
					-- 	type = "toggle",
					-- 	name = L.EnableProfileSharing,
					-- 	desc = L.EnableProfileSharing_Desc
					-- }
				}
			},
			DebugOptions = {
				type = "group",
				name = "Debug",
				childGroups = "tab",
				order = 8,
				hidden = not self.db.profile.Debug,
				args = {
					Debug = {
						type = "toggle",
						name = "Enable Debug",
						order = 1,
					},
					SvDebugging = {
						type = "group",
						name = "Saved Variables",
						order = 2,
						inline = true,
						args = {
							DebugToSV = {
								type = "toggle",
								name = "Debug to Saved Variables",
								order = 1,
							},
							DebugToSV_ResetOnPlayerLogin = {
								type = "toggle",
								name = "Reset SV log on player login",
								order = 2,
							},
							ResetSVLog = {
								type = "execute",
								name = "Reset Saved variables log",
								func = function()
									self.db.profile.log = {}
								end,
								order = 3,
							},
						}
					},
					ChatDebugging = {
						type = "group",
						name = "Chat",
						inline = true,
						order = 3,
						args = {
							DebugToChat_AddTimestamp = {
								type = "toggle",
								name = "Add timestamp to chat",
								order = 1,
							},
							DebugToChat = {
								type = "toggle",
								name = "Debug to Chat",
								order = 2,
							},
							ShowDebugChatFrame = {
								type = "execute",
								name = "Show debug chat frame",
								func = function()
									if not self.DebugFrame then self:GetDebugFrame() end
									self.DebugFrame:Show()
								end,
								order = 3,
							}
						}
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
