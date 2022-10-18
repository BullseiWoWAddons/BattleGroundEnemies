local AddonName, Data = ...

Data.defaultSettings = {
	profile = {
		Font = "PT Sans Narrow Bold",

		Locked = false,
		Debug = false,

		DisableArenaFrames = false,

		MyTarget_Color = {1, 1, 1, 1},
		MyFocus_Color = {0, 0.988235294117647, 0.729411764705882, 1},
		Highlight_Color = {1, 1, 0.5, 1},
		ShowTooltips = true,
		UseBigDebuffsPriority = true,

		RBG = {
			TargetCalling_SetMark = false,
			TargetCalling_NotificationEnable = false,
			EnemiesTargetingMe_Enabled = false,
			EnemiesTargetingMe_Amount = 5,
			EnemiesTargetingAllies_Enabled = false,
			EnemiesTargetingAllies_Amount = 5
		},

		Enemies = {
			Enabled = true,

			ShowRealmnames = true,
			ConvertCyrillic = true,


			RangeIndicator_Enabled = true,
			RangeIndicator_Range = 28767,
			RangeIndicator_Alpha = 0.55,
			RangeIndicator_Everything = false,
			RangeIndicator_Frames = {},

			LeftButtonType = "Target",
			LeftButtonValue = "",
			RightButtonType = "Focus",
			RightButtonValue = "",
			MiddleButtonType = "Custom",
			MiddleButtonValue = "",

			["5"] = {
				Enabled = true,


				Position_X = false,
				Position_Y = false,
				BarWidth = 220,
				BarHeight = 28,
				BarVerticalGrowdirection = "downwards",
				BarVerticalSpacing = 1,
				BarColumns = 1,
				BarHorizontalGrowdirection = "rightwards",
				BarHorizontalSpacing = 100,

				PlayerCount = {
					Enabled = true,
					Text = {
						FontSize = 14,
						FontOutline = "OUTLINE",
						FontColor = {1, 1, 1, 1},
						EnableShadow = false,
						ShadowColor = {0, 0, 0, 1},
					}
				},

				ButtonModules = {
					PriorityBuffs= {
						ActivePoints = 1,
						Points = {
							{
								Point = "BOTTOMRIGHT",
								RelativeFrame = "DRTracking",
								RelativePoint = "BOTTOMLEFT",
								OffsetX = -2,
								OffsetY = 1
							}
						},
						Container = {
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "leftwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
						},
					},
					PriorityDebuffs= {
						ActivePoints = 1,
						Points = {
							{
								Point = "BOTTOMRIGHT",
								RelativeFrame = "PriorityBuffs",
								RelativePoint = "BOTTOMLEFT",
								OffsetX = -8
							}
						},
						Container = {
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "leftwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
						},
					},
					NonPriorityBuffs= {
						ActivePoints = 1,
						Points = {
							{
								Point = "BOTTOMRIGHT",
								RelativeFrame = "PriorityDebuffs",
								RelativePoint = "BOTTOMLEFT",
								OffsetX = -2,
								OffsetY = 1
							}
						},
						Container = {
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "leftwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
						},
					},
					NonPriorityDebuffs= {
						ActivePoints = 1,
						Points = {
							{
								Point = "BOTTOMRIGHT",
								RelativeFrame = "NonPriorityBuffs",
								RelativePoint = "BOTTOMLEFT",
								OffsetX = -8
							}
						},
						Container = {
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "leftwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
						},
					},
					DRTracking= {
						ActivePoints = 2,
						Points = {
							{
								Point = "TOPRIGHT",
								RelativeFrame = "Button",
								RelativePoint = "TOPLEFT",
							},
							{
								Point = "BOTTOMRIGHT",
								RelativeFrame = "Button",
								RelativePoint = "BOTTOMLEFT",
							}
						},
						Container = {
							UseButtonHeightAsSize = true,
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "leftwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
							Color = {0, 0, 1, 1},
							Border = "Blizzard Dialog",
							BorderThickness = 1,
						},
					},
					Trinket = {
						ActivePoints = 2,
						Points = {
							{
								Point = "TOPLEFT",
								RelativeFrame = "Button",
								RelativePoint = "TOPRIGHT",
								OffsetX = 1
							},
							{
								Point = "BOTTOMLEFT",
								RelativeFrame = "Button",
								RelativePoint = "BOTTOMRIGHT",
								OffsetX = 1
							}
						},
					},
					Racial = {
						ActivePoints = 2,
						Points = {
							{
								Point = "TOPLEFT",
								RelativeFrame = "Trinket",
								RelativePoint = "TOPRIGHT",
								OffsetX = 1
							},
							{
								Point = "BOTTOMLEFT",
								RelativeFrame = "Trinket",
								RelativePoint = "BOTTOMRIGHT",
								OffsetX = 1
							}
						},
					}
				},

				Framescale = 1,

				-- PositiveSound = [[Interface\AddOns\WeakAuras\Media\Sounds\BatmanPunch.ogg]],
				-- NegativeSound = [[Sound\Interface\UI_BattlegroundCountdown_Timer.ogg]],
			},
			["15"] = {
				Enabled = true,

				Position_X = false,
				Position_Y = false,
				BarWidth = 220,
				BarHeight = 28,
				BarVerticalGrowdirection = "downwards",
				BarVerticalSpacing = 1,
				BarColumns = 1,
				BarHorizontalGrowdirection = "rightwards",
				BarHorizontalSpacing = 100,

				PlayerCount = {
					Enabled = true,
					Text = {
						FontSize = 14,
						FontOutline = "OUTLINE",
						FontColor = {1, 1, 1, 1},
						EnableShadow = false,
						ShadowColor = {0, 0, 0, 1},
					}
				},

				ButtonModules = {
					PriorityBuffs= {
						ActivePoints = 1,
						Points = {
							{
								Point = "BOTTOMRIGHT",
								RelativeFrame = "DRTracking",
								RelativePoint = "BOTTOMLEFT",
								OffsetX = -2,
								OffsetY = 1
							}
						},
						Container = {
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "leftwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
						},
					},
					PriorityDebuffs= {
						ActivePoints = 1,
						Points = {
							{
								Point = "BOTTOMRIGHT",
								RelativeFrame = "PriorityBuffs",
								RelativePoint = "BOTTOMLEFT",
								OffsetX = -8
							}
						},
						Container = {
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "leftwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
						},
					},
					NonPriorityBuffs= {
						ActivePoints = 1,
						Points = {
							{
								Point = "BOTTOMRIGHT",
								RelativeFrame = "PriorityBuffs",
								RelativePoint = "BOTTOMLEFT",
								OffsetX = -2,
								OffsetY = 1
							}
						},
						Container = {
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "leftwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
						},
					},
					NonPriorityDebuffs= {
						ActivePoints = 1,
						Points = {
							{
								Point = "BOTTOMRIGHT",
								RelativeFrame = "NonPriorityBuffs",
								RelativePoint = "BOTTOMLEFT",
								OffsetX = -8
							}
						},
						Container = {
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "leftwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
						},
					},
					DRTracking= {
						ActivePoints = 2,
						Points = {
							{
								Point = "TOPRIGHT",
								RelativeFrame = "Button",
								RelativePoint = "TOPLEFT",
							},
							{
								Point = "BOTTOMRIGHT",
								RelativeFrame = "Button",
								RelativePoint = "BOTTOMLEFT",
							}
						},
						Container = {
							UseButtonHeightAsSize = true,
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "leftwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
							Color = {0, 0, 1, 1},
							Border = "Blizzard Dialog",
							BorderThickness = 1,
						},
					},
					Trinket = {
						ActivePoints = 2,
						Points = {
							{
								Point = "TOPLEFT",
								RelativeFrame = "Button",
								RelativePoint = "TOPRIGHT",
								OffsetX = 1
							},
							{
								Point = "BOTTOMLEFT",
								RelativeFrame = "Button",
								RelativePoint = "BOTTOMRIGHT",
								OffsetX = 1
							}
						},
					},
					Racial = {
						ActivePoints = 2,
						Points = {
							{
								Point = "TOPLEFT",
								RelativeFrame = "Trinket",
								RelativePoint = "TOPRIGHT",
								OffsetX = 1
							},
							{
								Point = "BOTTOMLEFT",
								RelativeFrame = "Trinket",
								RelativePoint = "BOTTOMRIGHT",
								OffsetX = 1
							}
						},
					}
				},

				Framescale = 1,



				-- PositiveSound = [[Interface\AddOns\WeakAuras\Media\Sounds\BatmanPunch.ogg]],
				-- NegativeSound = [[Sound\Interface\UI_BattlegroundCountdown_Timer.ogg]],
			},
			["40"] = {
				Enabled = true,

				Position_X = false,
				Position_Y = false,
				BarWidth = 220,
				BarHeight = 22,
				BarVerticalGrowdirection = "downwards",
				BarVerticalSpacing = 1,
				BarColumns = 1,
				BarHorizontalGrowdirection = "rightwards",
				BarHorizontalSpacing = 100,

				PlayerCount = {
					Enabled = true,
					Text = {
						FontSize = 14,
						FontOutline = "OUTLINE",
						FontColor = {1, 1, 1, 1},
						EnableShadow = false,
						ShadowColor = {0, 0, 0, 1},
					}
				},

				ButtonModules = {
					PriorityBuffs= {
						ActivePoints = 1,
						Points = {
							{
								Point = "BOTTOMRIGHT",
								RelativeFrame = "DRTracking",
								RelativePoint = "BOTTOMLEFT",
								OffsetX = -2,
								OffsetY = 1
							}
						},
						Container = {
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "leftwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
						},
					},
					PriorityDebuffs= {
						ActivePoints = 1,
						Points = {
							{
								Point = "BOTTOMRIGHT",
								RelativeFrame = "PriorityBuffs",
								RelativePoint = "BOTTOMLEFT",
								OffsetX = -8
							}
						},
						Container = {
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "leftwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
						},
					},
					NonPriorityBuffs= {
						ActivePoints = 1,
						Points = {
							{
								Point = "BOTTOMRIGHT",
								RelativeFrame = "PriorityDebuffs",
								RelativePoint = "BOTTOMLEFT",
								OffsetX = -2,
								OffsetY = 1
							}
						},
						Container = {
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "leftwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
						},
					},
					NonPriorityDebuffs= {
						ActivePoints = 1,
						Points = {
							{
								Point = "BOTTOMRIGHT",
								RelativeFrame = "NonPriorityBuffs",
								RelativePoint = "BOTTOMLEFT",
								OffsetX = -8
							}
						},
						Container = {
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "leftwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
						},
					},
					DRTracking= {
						ActivePoints = 2,
						Points = {
							{
								Point = "TOPRIGHT",
								RelativeFrame = "Button",
								RelativePoint = "TOPLEFT",
							},
							{
								Point = "BOTTOMRIGHT",
								RelativeFrame = "Button",
								RelativePoint = "BOTTOMLEFT",
							}
						},
						Container = {
							UseButtonHeightAsSize = true,
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "leftwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
							Color = {0, 0, 1, 1},
							Border = "Blizzard Dialog",
							BorderThickness = 1,
						},
					},
					Trinket = {
						ActivePoints = 2,
						Points = {
							{
								Point = "TOPLEFT",
								RelativeFrame = "Button",
								RelativePoint = "TOPRIGHT",
								OffsetX = 1
							},
							{
								Point = "BOTTOMLEFT",
								RelativeFrame = "Button",
								RelativePoint = "BOTTOMRIGHT",
								OffsetX = 1
							}
						},
					},
					Racial = {
						ActivePoints = 2,
						Points = {
							{
								Point = "TOPLEFT",
								RelativeFrame = "Trinket",
								RelativePoint = "TOPRIGHT",
								OffsetX = 1
							},
							{
								Point = "BOTTOMLEFT",
								RelativeFrame = "Trinket",
								RelativePoint = "BOTTOMRIGHT",
								OffsetX = 1
							}
						},
					}
				},

				Framescale = 1,

			}

		},
		Allies = {
			Enabled = true,

			ShowRealmnames = true,
			ConvertCyrillic = true,

			RangeIndicator_Enabled = true,
			RangeIndicator_Range = 34471,
			RangeIndicator_Alpha = 0.55,
			RangeIndicator_Everything = false,
			RangeIndicator_Frames = {},

			LeftButtonType = "Target",
			LeftButtonValue = "",
			RightButtonType = "Focus",
			RightButtonValue = "",
			MiddleButtonType = "Custom",
			MiddleButtonValue = "",

			["5"] = {
				Enabled = true,

				Position_X = false,
				Position_Y = false,
				BarWidth = 220,
				BarHeight = 28,
				BarVerticalGrowdirection = "downwards",
				BarVerticalSpacing = 1,
				BarColumns = 1,
				BarHorizontalGrowdirection = "rightwards",
				BarHorizontalSpacing = 100,

				PlayerCount = {
					Enabled = true,
					Text = {
						FontSize = 14,
						FontOutline = "OUTLINE",
						FontColor = {1, 1, 1, 1},
						EnableShadow = false,
						ShadowColor = {0, 0, 0, 1},
					}
				},

				ButtonModules = {
					PriorityBuffs= {
						ActivePoints = 1,
						Points = {
							{
								Point = "BOTTOMLEFT",
								RelativeFrame = "DRTracking",
								RelativePoint = "BOTTOMRIGHT",
								OffsetX = 2,
								OffsetY = 1
							}
						},
						Container = {
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "rightwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
						},
					},
					PriorityDebuffs= {
						ActivePoints = 1,
						Points = {
							{
								Point = "BOTTOMLEFT",
								RelativeFrame = "PriorityBuffs",
								RelativePoint = "BOTTOMRIGHT",
								OffsetX = 8
							}
						},
						Container = {
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "rightwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
						},
					},
					NonPriorityBuffs= {
						ActivePoints = 1,
						Points = {
							{
								Point = "BOTTOMLEFT",
								RelativeFrame = "PriorityDebuffs",
								RelativePoint = "BOTTOMRIGHT",
								OffsetX = 2,
								OffsetY = 1
							}
						},
						Container = {
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "rightwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
						},
					},
					NonPriorityDebuffs= {
						ActivePoints = 1,
						Points = {
							{
								Point = "BOTTOMLEFT",
								RelativeFrame = "NonPriorityBuffs",
								RelativePoint = "BOTTOMRIGHT",
								OffsetX = 8
							}
						},
						Container = {
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "rightwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
						},
					},
					DRTracking= {
						ActivePoints = 2,
						Points = {
							{
								Point = "TOPLEFT",
								RelativeFrame = "Button",
								RelativePoint = "TOPRIGHT",
							},
							{
								Point = "BOTTOMLEFT",
								RelativeFrame = "Button",
								RelativePoint = "BOTTOMRIGHT",
							}
						},
						Container = {
							UseButtonHeightAsSize = true,
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "rightwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
							Color = {0, 0, 1, 1},
							Border = "Blizzard Dialog",
							BorderThickness = 1,
						},
					},
					Trinket = {
						ActivePoints = 2,
						Points = {
							{
								Point = "TOPRIGHT",
								RelativeFrame = "Button",
								RelativePoint = "TOPLEFT",
								OffsetX = -1
							},
							{
								Point = "BOTTOMRIGHT",
								RelativeFrame = "Button",
								RelativePoint = "BOTTOMLEFT",
								OffsetX = -1
							}
						},
					},
					Racial = {
						ActivePoints = 2,
						Points = {
							{
								Point = "TOPRIGHT",
								RelativeFrame = "Trinket",
								RelativePoint = "TOPLEFT",
								OffsetX = -1
							},
							{
								Point = "BOTTOMRIGHT",
								RelativeFrame = "Trinket",
								RelativePoint = "BOTTOMLEFT",
								OffsetX = -1
							}
						},
					}
				},

				Framescale = 1,


								-- PositiveSound = [[Interface\AddOns\WeakAuras\Media\Sounds\BatmanPunch.ogg]],
				-- NegativeSound = [[Sound\Interface\UI_BattlegroundCountdown_Timer.ogg]],

			},
			["15"] = {
				Enabled = true,

				Position_X = false,
				Position_Y = false,
				BarWidth = 220,
				BarHeight = 28,
				BarVerticalGrowdirection = "downwards",
				BarVerticalSpacing = 1,
				BarColumns = 1,
				BarHorizontalGrowdirection = "rightwards",
				BarHorizontalSpacing = 100,

				PlayerCount = {
					Enabled = true,
					Text = {
						FontSize = 14,
						FontOutline = "OUTLINE",
						FontColor = {1, 1, 1, 1},
						EnableShadow = false,
						ShadowColor = {0, 0, 0, 1},
					}
				},

				ButtonModules = {
					PriorityBuffs= {
						ActivePoints = 1,
						Points = {
							{
								Point = "BOTTOMLEFT",
								RelativeFrame = "DRTracking",
								RelativePoint = "BOTTOMRIGHT",
								OffsetX = 2,
								OffsetY = 1
							}
						},
						Container = {
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "rightwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
						},
					},
					PriorityDebuffs= {
						ActivePoints = 1,
						Points = {
							{
								Point = "BOTTOMLEFT",
								RelativeFrame = "PriorityBuffs",
								RelativePoint = "BOTTOMRIGHT",
								OffsetX = 8
							}
						},
						Container = {
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "rightwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
						},
					},
					NonPriorityBuffs= {
						ActivePoints = 1,
						Points = {
							{
								Point = "BOTTOMLEFT",
								RelativeFrame = "PriorityDebuffs",
								RelativePoint = "BOTTOMRIGHT",
								OffsetX = 2,
								OffsetY = 1
							}
						},
						Container = {
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "rightwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
						},
					},
					NonPriorityDebuffs= {
						ActivePoints = 1,
						Points = {
							{
								Point = "BOTTOMLEFT",
								RelativeFrame = "NonPriorityBuffs",
								RelativePoint = "BOTTOMRIGHT",
								OffsetX = 8
							}
						},
						Container = {
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "rightwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
						},
					},
					DRTracking= {
						ActivePoints = 2,
						Points = {
							{
								Point = "TOPLEFT",
								RelativeFrame = "Button",
								RelativePoint = "TOPRIGHT",
							},
							{
								Point = "BOTTOMLEFT",
								RelativeFrame = "Button",
								RelativePoint = "BOTTOMRIGHT",
							}
						},
						Container = {
							UseButtonHeightAsSize = true,
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "rightwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
							Color = {0, 0, 1, 1},
							Border = "Blizzard Dialog",
							BorderThickness = 1,
						},
					},
					Trinket = {
						ActivePoints = 2,
						Points = {
							{
								Point = "TOPRIGHT",
								RelativeFrame = "Button",
								RelativePoint = "TOPLEFT",
								OffsetX = -1
							},
							{
								Point = "BOTTOMRIGHT",
								RelativeFrame = "Button",
								RelativePoint = "BOTTOMLEFT",
								OffsetX = -1
							}
						},
					},
					Racial = {
						ActivePoints = 2,
						Points = {
							{
								Point = "TOPRIGHT",
								RelativeFrame = "Trinket",
								RelativePoint = "TOPLEFT",
								OffsetX = -1
							},
							{
								Point = "BOTTOMRIGHT",
								RelativeFrame = "Trinket",
								RelativePoint = "BOTTOMLEFT",
								OffsetX = -1
							}
						},
					}
				},

				Framescale = 1,


								-- PositiveSound = [[Interface\AddOns\WeakAuras\Media\Sounds\BatmanPunch.ogg]],
				-- NegativeSound = [[Sound\Interface\UI_BattlegroundCountdown_Timer.ogg]],
			},
			["40"] = {
				Enabled = true,

				Position_X = false,
				Position_Y = false,
				BarWidth = 220,
				BarHeight = 22,
				BarVerticalGrowdirection = "downwards",
				BarVerticalSpacing = 1,
				BarColumns = 1,
				BarHorizontalGrowdirection = "rightwards",
				BarHorizontalSpacing = 100,

				PlayerCount = {
					Enabled = true,
					Text = {
						FontSize = 14,
						FontOutline = "OUTLINE",
						FontColor = {1, 1, 1, 1},
						EnableShadow = false,
						ShadowColor = {0, 0, 0, 1},
					}
				},

				ButtonModules = {
					PriorityBuffs= {
						ActivePoints = 1,
						Points = {
							{
								Point = "BOTTOMLEFT",
								RelativeFrame = "DRTracking",
								RelativePoint = "BOTTOMRIGHT",
								OffsetX = 2,
								OffsetY = 1
							}
						},
						Container = {
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "rightwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
						},
					},
					PriorityDebuffs= {
						ActivePoints = 1,
						Points = {
							{
								Point = "BOTTOMLEFT",
								RelativeFrame = "PriorityBuffs",
								RelativePoint = "BOTTOMRIGHT",
								OffsetX = 8
							}
						},
						Container = {
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "rightwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
						},
					},
					NonPriorityBuffs= {
						ActivePoints = 1,
						Points = {
							{
								Point = "BOTTOMLEFT",
								RelativeFrame = "PriorityDebuffs",
								RelativePoint = "BOTTOMRIGHT",
								OffsetX = 2,
								OffsetY = 1
							}
						},
						Container = {
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "rightwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
						},
					},
					NonPriorityDebuffs= {
						ActivePoints = 1,
						Points = {
							{
								Point = "BOTTOMLEFT",
								RelativeFrame = "NonPriorityBuffs",
								RelativePoint = "BOTTOMRIGHT",
								OffsetX = 8
							}
						},
						Container = {
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "rightwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
						},
					},
					DRTracking= {
						ActivePoints = 2,
						Points = {
							{
								Point = "TOPLEFT",
								RelativeFrame = "Button",
								RelativePoint = "TOPRIGHT",
							},
							{
								Point = "BOTTOMLEFT",
								RelativeFrame = "Button",
								RelativePoint = "BOTTOMRIGHT",
							}
						},
						Container = {
							UseButtonHeightAsSize = true,
							IconSize = 15,
							IconsPerRow = 8,
							HorizontalGrowDirection = "rightwards",
							HorizontalSpacing = 2,
							VerticalGrowdirection = "upwards",
							VerticalSpacing = 1,
							Color = {0, 0, 1, 1},
							Border = "Blizzard Dialog",
							BorderThickness = 1,
						},
					},
					Trinket = {
						ActivePoints = 2,
						Points = {
							{
								Point = "TOPRIGHT",
								RelativeFrame = "Button",
								RelativePoint = "TOPLEFT",
								OffsetX = -1
							},
							{
								Point = "BOTTOMRIGHT",
								RelativeFrame = "Button",
								RelativePoint = "BOTTOMLEFT",
								OffsetX = -1
							}
						},
					},
					Racial = {
						ActivePoints = 2,
						Points = {
							{
								Point = "TOPRIGHT",
								RelativeFrame = "Trinket",
								RelativePoint = "TOPLEFT",
								OffsetX = -1
							},
							{
								Point = "BOTTOMRIGHT",
								RelativeFrame = "Trinket",
								RelativePoint = "BOTTOMLEFT",
								OffsetX = -1
							}
						},
					}
				},


				Framescale = 1,

			}
		}
	}
}