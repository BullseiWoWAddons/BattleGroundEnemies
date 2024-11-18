---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)

local allieDefaults15man = {
	Enabled = true,
	minPlayerCount = 6,
	maxPlayerCount = 15,

	Position_X = 150,
	Position_Y = 600,
	BarWidth = 180,
	BarHeight = 28,
	BarVerticalGrowdirection = "downwards",
	BarVerticalSpacing = 3,
	BarColumns = 1,
	BarHorizontalGrowdirection = "rightwards",
	BarHorizontalSpacing = 100,
	
	PlayerCount = {
		Enabled = true,
	},

	ButtonModules = {
		CastBar = {
			Enabled = false,
			Points = {
				{
					Point = "LEFT",
					RelativeFrame = "SpecClassPriorityOne",
					RelativePoint = "RIGHT",
					OffsetX = 28,
				},
			},
		},
		Cooldowns = {
			Points = {
				{
					Point = "TOPLEFT",
					RelativeFrame = "Racial",
					RelativePoint = "TOPRIGHT",
				}
			},
			Container = {
				HorizontalGrowDirection = "rightwards",
				VerticalGrowdirection = "downwards",
			},
		},
		DRTracking = {
			Points = {
				{
					Point = "BOTTOMLEFT",
					RelativeFrame = "SpecClassPriorityOne",
					RelativePoint = "BOTTOMRIGHT",
				}
			},
			Container = {
				HorizontalGrowDirection = "rightwards",
				VerticalGrowdirection = "downwards",
			},
		},
		NonPriorityBuffs = {
			Enabled = false,
			Points = {
				{
					Point = "TOPLEFT",
					RelativeFrame = "PriorityDebuffs",
					RelativePoint = "TOPRIGHT",
					OffsetX = 2,
					OffsetY = 0
				}
			},
			Container = {
				HorizontalGrowDirection = "rightwards",
				VerticalGrowdirection = "downwards",
			},
		},
		NonPriorityDebuffs = {
			Enabled = false,
			Points = {
				{
					Point = "TOPLEFT",
					RelativeFrame = "NonPriorityBuffs",
					RelativePoint = "TOPRIGHT",
					OffsetX = 8
				}
			},
			Container = {
				HorizontalGrowDirection = "rightwards",
				VerticalGrowdirection = "downwards",
			}
		},
		PriorityBuffs = {
			Enabled = true,
			Points = {
				{
					Point = "TOPLEFT",
					RelativeFrame = "DRTracking",
					RelativePoint = "TOPRIGHT",
					OffsetX = 2,
					OffsetY = 0
				}
			},
			Container = {
				HorizontalGrowDirection = "rightwards",
				VerticalGrowdirection = "downwards",
			}
		},
		PriorityDebuffs = {
			Enabled = true,
			Points = {
				{
					Point = "TOPLEFT",
					RelativeFrame = "PriorityBuffs",
					RelativePoint = "TOPRIGHT",
					OffsetX = 8
				}
			},
			Container = {
				HorizontalGrowDirection = "rightwards",
				VerticalGrowdirection = "downwards",
			}
		},
		Racial = {
			Points = {
				{
					Point = "TOPRIGHT",
					RelativeFrame = "Trinket",
					RelativePoint = "TOPLEFT",
					OffsetX = -1
				}
			}
		},
		SpecClassPriorityOne = {
			Cooldown = {
				FontSize = 20,
			},
			Points = {
				{
					Point = "TOPLEFT",
					RelativeFrame = "Button",
					RelativePoint = "TOPRIGHT",
				}
			}
		},
		Trinket = {
			Points = {
				{
					Point = "TOPRIGHT",
					RelativeFrame = "Button",
					RelativePoint = "TOPLEFT",
					OffsetX = -1
				}
			}
		}
	},

	Framescale = 1,


					-- PositiveSound = [[Interface\AddOns\WeakAuras\Media\Sounds\BatmanPunch.ogg]],
	-- NegativeSound = [[Sound\Interface\UI_BattlegroundCountdown_Timer.ogg]],
}
local enemyDefault15man = {
	Enabled = true,
	minPlayerCount = 6,
	maxPlayerCount = 15,

	Position_X = 1100,
	Position_Y = 600,
	BarWidth = 180,
	BarHeight = 28,
	BarVerticalGrowdirection = "downwards",
	BarVerticalSpacing = 3,
	BarColumns = 1,
	BarHorizontalGrowdirection = "rightwards",
	BarHorizontalSpacing = 100,

	PlayerCount = {
		Enabled = true,
	},

	ButtonModules = {
		CastBar = {
			Enabled = false,
			Points = {
				{
					Point = "RIGHT",
					RelativeFrame = "SpecClassPriorityOne",
					RelativePoint = "LEFT",
					OffsetX = -28
				},
			}
		},
		Cooldowns = {
			Points = {
				{
					Point = "TOPLEFT",
					RelativeFrame = "Racial",
					RelativePoint = "TOPRIGHT",
				}
			},
			Container = {
				HorizontalGrowDirection = "rightwards",
				VerticalGrowdirection = "downwards",
			},
		},
		DRTracking = {
			Points = {
				{
					Point = "BOTTOMRIGHT",
					RelativeFrame = "SpecClassPriorityOne",
					RelativePoint = "BOTTOMLEFT",
					OffsetX = -2
				}
			},
			Container = {
				HorizontalGrowDirection = "leftwards",
				VerticalGrowdirection = "downwards",
			}
		},
		NonPriorityBuffs = {
			Enabled = false,
			Points = {
				{
					Point = "TOPRIGHT",
					RelativeFrame = "PriorityDebuffs",
					RelativePoint = "TOPLEFT",
					OffsetX = -2,
					OffsetY = 0
				}
			},
			Container = {
				HorizontalGrowDirection = "leftwards",
				VerticalGrowdirection = "downwards",
			}
		},
		NonPriorityDebuffs = {
			Enabled = false,
			Points = {
				{
					Point = "TOPRIGHT",
					RelativeFrame = "NonPriorityBuffs",
					RelativePoint = "TOPLEFT",
					OffsetX = -8
				}
			},
			Container = {
				HorizontalGrowDirection = "leftwards",
				VerticalGrowdirection = "downwards",
			}
		},
		PriorityBuffs = {
			Enabled = true,
			Points = {
				{
					Point = "TOPRIGHT",
					RelativeFrame = "DRTracking",
					RelativePoint = "TOPLEFT",
					OffsetX = -2,
					OffsetY = 0
				}
			},
			Container = {
				HorizontalGrowDirection = "leftwards",
				VerticalGrowdirection = "downwards",
			}
		},
		PriorityDebuffs = {
			Enabled = true,
			Points = {
				{
					Point = "TOPRIGHT",
					RelativeFrame = "PriorityBuffs",
					RelativePoint = "TOPLEFT",
					OffsetX = -8
				}
			},
			Container = {
				HorizontalGrowDirection = "leftwards",
				VerticalGrowdirection = "downwards",
			},
		},
		Racial = {
			Points = {
				{
					Point = "TOPLEFT",
					RelativeFrame = "Trinket",
					RelativePoint = "TOPRIGHT",
					OffsetX = 1
				}
			}
		},
		SpecClassPriorityOne = {
			Cooldown = {
				FontSize = 20,
			},
			Points = {
				{
					Point = "TOPRIGHT",
					RelativeFrame = "Button",
					RelativePoint = "TOPLEFT",
				}
			}
		},
		Trinket = {
			Points = {
				{
					Point = "TOPLEFT",
					RelativeFrame = "Button",
					RelativePoint = "TOPRIGHT",
					OffsetX = 1
				}
			}
		}
	},

	Framescale = 1,
}
-- PositiveSound = [[Interface\AddOns\WeakAuras\Media\Sounds\BatmanPunch.ogg]],
-- NegativeSound = [[Sound\Interface\UI_BattlegroundCountdown_Timer.ogg]],

Data.defaultSettings = {
	profile = {
		Locked = false,
		Debug = false,
		DebugToSV = false,
		DebugToSV_ResetOnPlayerLogin = true,
		DebugToChat = false,
		DebugToChat_AddTimestamp = false,
		

		shareActiveProfile = false,

		DisableArenaFramesInArena = false,
		DisableArenaFramesInBattleground = false,

		DisableRaidFramesInArena = false,
		DisableRaidFramesInBattleground = false,

		ShowBGEInArena = true,
		ShowBGEInBattleground = true,

		MyTarget_Color = {1, 1, 1, 1},
		MyTarget_BorderSize = 2,
		MyFocus_Color = {0, 0.988235294117647, 0.729411764705882, 1},
		MyFocus_BorderSize = 2,
		ShowTooltips = true,
		EnableMouseWheelPlayerTargeting = false,
		UseBigDebuffsPriority = true,
		ConvertCyrillic = true,

		PlayerCount = {
			Text = {
				FontSize = 14,
				JustifyV = "MIDDLE",
				JustifyH = "LEFT"
			}
		},

		RoleSortingOrder = "HEALER_TANK_DAMAGER",

		Cooldown = {
			ShowNumber = true,
			DrawSwipe = true,
		},

		Text = {
			Font = "PT Sans Narrow Bold",
			FontColor = {1, 1, 1, 1},
			FontOutline = "",
			EnableShadow = false,
			ShadowColor = {0, 0, 0, 1}
		},

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

			CustomPlayerCountConfigsEnabled = false,

			RangeIndicator_Enabled = true,
			RangeIndicator_Range = 40,
			RangeIndicator_Alpha = 0.55,
			RangeIndicator_Everything = true,
			RangeIndicator_Frames = {},


			ActionButtonUseKeyDown = false,
			UseClique = false,


			LeftButtonType = "Target",
			LeftButtonValue = "",
			RightButtonType = "Focus",
			RightButtonValue = "",
			MiddleButtonType = "Custom",
			MiddleButtonValue = "",

			playerCountConfigs = {
				{
					Enabled = true,
					minPlayerCount = 1,
					maxPlayerCount = 5,

					Position_X = 1100,
					Position_Y = 600,
					BarWidth = 200,
					BarHeight = 47,
					BarVerticalGrowdirection = "downwards",
					BarVerticalSpacing = 40,
					BarColumns = 1,
					BarHorizontalGrowdirection = "rightwards",
					BarHorizontalSpacing = 100,

					PlayerCount = {
						Enabled = false,
					},
					ButtonModules = {
						SpecClassPriorityOne = {
							Width = 52,
							Cooldown = {
								FontSize = 26,
							},
						},
						CastBar = {
							Enabled = true,
							Points = {
								{
									Point = "RIGHT",
									RelativeFrame = "SpecClassPriorityOne",
									RelativePoint = "LEFT",
									OffsetX = -28
								}
							}
						},
						Covenant = {
							Enabled = false
						},
						Cooldowns = {
							Points = {
								{
									Point = "TOPLEFT",
									RelativeFrame = "Racial",
									RelativePoint = "TOPRIGHT",
								}
							},
							Container = {
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "downwards",
							},
						},
						DRTracking = {
							Points = {
								{
									Point = "TOPRIGHT",
									RelativeFrame = "Button",
									RelativePoint = "BOTTOMRIGHT",
									OffsetY = -2
								}
							},
							Container = {
								UseButtonHeightAsSize = false,
								IconSize = 31,
								HorizontalGrowDirection = "leftwards",
								VerticalGrowdirection = "downwards",
							}
						},
						healthBar = {
							HealthTextEnabled = true,
							HealthTextType = "health",
							HealthText = {
								FontSize = 18,
								JustifyV = "BOTTOM"
							}
						},
						Name = {
							Text = {
								JustifyV = "TOP"
							}
						},
						NonPriorityBuffs = {
							Enabled = true,
							Points = {
								{
									Point = "TOPRIGHT",
									RelativeFrame = "PriorityDebuffs",
									RelativePoint = "TOPLEFT",
									OffsetX = -2,
									OffsetY = 0
								}
							},
							Container = {
								HorizontalGrowDirection = "leftwards",
								VerticalGrowdirection = "downwards",
							}
						},
						NonPriorityDebuffs = {
							Enabled = true,
							Points = {
								{
									Point = "TOPRIGHT",
									RelativeFrame = "NonPriorityBuffs",
									RelativePoint = "TOPLEFT",
									OffsetX = -8
								}
							},
							Container = {
								HorizontalGrowDirection = "leftwards",
								VerticalGrowdirection = "downwards",
							}
						},
						Power = {
							Height = 8,
						},
						PriorityBuffs = {
							Enabled = true,
							Points = {
								{
									Point = "TOPRIGHT",
									RelativeFrame = "DRTracking",
									RelativePoint = "TOPLEFT",
									OffsetX = -2,
									OffsetY = 0
								}
							},
							Container = {
								UseButtonHeightAsSize = false,
								IconSize = 25,
								IconsPerRow = 8,
								HorizontalGrowDirection = "leftwards",
								VerticalGrowdirection = "downwards",
							}
						},
						PriorityDebuffs = {
							Enabled = true,
							Points = {
								{
									Point = "TOPRIGHT",
									RelativeFrame = "PriorityBuffs",
									RelativePoint = "TOPLEFT",
									OffsetX = -8
								}
							},
							Container = {
								UseButtonHeightAsSize = false,
								IconSize = 25,
								IconsPerRow = 8,
								HorizontalGrowDirection = "leftwards",
								VerticalGrowdirection = "downwards",
							}
						},
						Racial = {
							Cooldown = {
								FontSize = 26,
							},
							Points = {
								{
									Point = "TOPLEFT",
									RelativeFrame = "Trinket",
									RelativePoint = "TOPRIGHT",
									OffsetX = 1
								}
							}
						},
						RaidTargetIcon = {
							Enabled = false
						},
						Trinket = {
							Cooldown = {
								FontSize = 26,
							},
							Points = {
								{
									Point = "TOPLEFT",
									RelativeFrame = "Button",
									RelativePoint = "TOPRIGHT",
									OffsetX = 1
								}
							}
						}
					},

					Framescale = 1,

					-- PositiveSound = [[Interface\AddOns\WeakAuras\Media\Sounds\BatmanPunch.ogg]],
					-- NegativeSound = [[Sound\Interface\UI_BattlegroundCountdown_Timer.ogg]],
				},
				enemyDefault15man,
				{
					Enabled = true,
					minPlayerCount = 16,
					maxPlayerCount = 40,

					Position_X = 1100,
					Position_Y = 600,
					BarWidth = 180,
					BarHeight = 22,
					BarVerticalGrowdirection = "downwards",
					BarVerticalSpacing = 1,
					BarColumns = 1,
					BarHorizontalGrowdirection = "rightwards",
					BarHorizontalSpacing = 100,

					PlayerCount = {
						Enabled = true,
					},
					ButtonModules = {
						CastBar = {
							Enabled = false,
							Points = {
								{
									Point = "RIGHT",
									RelativeFrame = "SpecClassPriorityOne",
									RelativePoint = "LEFT",
									OffsetX = -28
								}
							}
						},
						Cooldowns = {
							Points = {
								{
									Point = "TOPLEFT",
									RelativeFrame = "Racial",
									RelativePoint = "TOPRIGHT",
								}
							},
							Container = {
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "downwards",
							},
						},
						DRTracking = {
							Points = {
								{
									Point = "TOPRIGHT",
									RelativeFrame = "SpecClassPriorityOne",
									RelativePoint = "TOPLEFT",
									OffsetX= -2
								}
							},
							Container = {
								HorizontalGrowDirection = "leftwards",
								VerticalGrowdirection = "downwards",
							}
						},
						NonPriorityBuffs = {
							Points = {
								{
									Point = "TOPRIGHT",
									RelativeFrame = "PriorityDebuffs",
									RelativePoint = "TOPLEFT",
									OffsetX = -2,
									OffsetY = 0
								}
							},
							Container = {
								HorizontalGrowDirection = "leftwards",
								VerticalGrowdirection = "downwards",
							}
						},
						NonPriorityDebuffs = {
							Points = {
								{
									Point = "TOPRIGHT",
									RelativeFrame = "NonPriorityBuffs",
									RelativePoint = "TOPLEFT",
									OffsetX = -8
								}
							},
							Container = {
								HorizontalGrowDirection = "leftwards",
								VerticalGrowdirection = "downwards",
							}
						},
						Power = {
							Enabled = false,
						},
						PriorityBuffs = {
							Points = {
								{
									Point = "TOPRIGHT",
									RelativeFrame = "DRTracking",
									RelativePoint = "TOPLEFT",
									OffsetX = -2,
									OffsetY = 0
								}
							},
							Container = {
								HorizontalGrowDirection = "leftwards",
								VerticalGrowdirection = "downwards",
							}
						},
						PriorityDebuffs = {
							Points = {
								{
									Point = "TOPRIGHT",
									RelativeFrame = "PriorityBuffs",
									RelativePoint = "TOPLEFT",
									OffsetX = -8
								}
							},
							Container = {
								HorizontalGrowDirection = "leftwards",
								VerticalGrowdirection = "downwards",
							}
						},
						Racial = {
							Points = {
								{
									Point = "TOPLEFT",
									RelativeFrame = "Trinket",
									RelativePoint = "TOPRIGHT",
									OffsetX = 1
								}
							}
						},
						Trinket = {
							Points = {
								{
									Point = "TOPLEFT",
									RelativeFrame = "Button",
									RelativePoint = "TOPRIGHT",
									OffsetX = 1
								}
							}
						}
					},

					Framescale = 1,

				}
			},
			customPlayerCountConfigs = 	{
				["**"] = enemyDefault15man
				-- PositiveSound = [[Interface\AddOns\WeakAuras\Media\Sounds\BatmanPunch.ogg]],
				-- NegativeSound = [[Sound\Interface\UI_BattlegroundCountdown_Timer.ogg]],
			}
		},
		Allies = {
			Enabled = true,

			CustomPlayerCountConfigsEnabled = false,

			RangeIndicator_Enabled = true,
			RangeIndicator_Range = 40,
			RangeIndicator_Alpha = 0.55,
			RangeIndicator_Everything = true,
			RangeIndicator_Frames = {},

			ActionButtonUseKeyDown = false,
			UseClique = false,

			LeftButtonType = "Target",
			LeftButtonValue = "",
			RightButtonType = "Focus",
			RightButtonValue = "",
			MiddleButtonType = "Custom",
			MiddleButtonValue = "",

			playerCountConfigs = {
				{
					Enabled = true,
					minPlayerCount = 1,
					maxPlayerCount = 5,

					Position_X = 150,
					Position_Y = 600,
					BarWidth = 200,
					BarHeight = 47,
					BarVerticalGrowdirection = "downwards",
					BarVerticalSpacing = 40,
					BarColumns = 1,
					BarHorizontalGrowdirection = "rightwards",
					BarHorizontalSpacing = 100,

					PlayerCount = {
						Enabled = false,
					},
					ButtonModules = {
						CastBar = {
							Enabled = true,
							Points = {
								{
									Point = "LEFT",
									RelativeFrame = "SpecClassPriorityOne",
									RelativePoint = "RIGHT",
									OffsetX = 28,
								},
							},
						},
						SpecClassPriorityOne = {
							Width = 52,
							Cooldown = {
								FontSize = 26,
							},
							Points = {
								{
									Point = "TOPLEFT",
									RelativeFrame = "Button",
									RelativePoint = "TOPRIGHT",
								}
							}
						},
						Covenant = {
							Enabled = false
						},
						Cooldowns = {
							Points = {
								{
									Point = "TOPRIGHT",
									RelativeFrame = "Button",
									RelativePoint = "TOPRIGHT",
								}
							},
							Container = {
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "downwards",
							},
						},
						DRTracking = {
							Points = {
								{
									Point = "TOPLEFT",
									RelativeFrame = "Button",
									RelativePoint = "BOTTOMLEFT",
									OffsetY = -2
								}
							},
							Container = {
								UseButtonHeightAsSize = false,
								IconSize = 31,
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "downwards",
							}
						},
						healthBar = {
							HealthTextEnabled = true,
							HealthTextType = "health",
							HealthText = {
								FontSize = 18,
								JustifyV = "BOTTOM"
							}
						},
						Name = {
							Text = {
								JustifyV = "TOP"
							}
						},
						NonPriorityBuffs = {
							Enabled = true,
							Points = {
								{
									Point = "TOPLEFT",
									RelativeFrame = "PriorityDebuffs",
									RelativePoint = "TOPRIGHT",
									OffsetX = 2,
									OffsetY = 0
								}
							},
							Container = {
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "downwards",
							}
						},
						NonPriorityDebuffs = {
							Enabled = true,
							Points = {
								{
									Point = "TOPLEFT",
									RelativeFrame = "NonPriorityBuffs",
									RelativePoint = "TOPRIGHT",
									OffsetX = 8
								}
							},
							Container = {
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "downwards",
							}
						},
						Power = {
							Height = 8,
						},
						PriorityBuffs = {
							Enabled = true,
							Points = {
								{
									Point = "TOPLEFT",
									RelativeFrame = "DRTracking",
									RelativePoint = "TOPRIGHT",
									OffsetX = 2,
									OffsetY = 0
								}
							},
							Container = {
								UseButtonHeightAsSize = false,
								IconSize = 25,
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "downwards",
							}
						},
						PriorityDebuffs = {
							Enabled = true,
							Points = {
								{
									Point = "TOPLEFT",
									RelativeFrame = "PriorityBuffs",
									RelativePoint = "TOPRIGHT",
									OffsetX = 8
								}
							},
							Container = {
								UseButtonHeightAsSize = false,
								IconSize = 25,
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "downwards",
							}
						},
						Racial = {
							Cooldown = {
								FontSize = 26,
							},
							Points = {
								{
									Point = "TOPRIGHT",
									RelativeFrame = "Trinket",
									RelativePoint = "TOPLEFT",
									OffsetX = -1
								}
							}
						},
						RaidTargetIcon = {
							Enabled = false
						},
						Trinket = {
							Cooldown = {
								FontSize = 26,
							},
							Points = {
								{
									Point = "TOPRIGHT",
									RelativeFrame = "Button",
									RelativePoint = "TOPLEFT",
									OffsetX = -1
								}
							}
						}
					},

					Framescale = 1,


					-- PositiveSound = [[Interface\AddOns\WeakAuras\Media\Sounds\BatmanPunch.ogg]],
					-- NegativeSound = [[Sound\Interface\UI_BattlegroundCountdown_Timer.ogg]],

				},
				allieDefaults15man,
				{
					Enabled = true,
					minPlayerCount = 16,
					maxPlayerCount = 40,

					Position_X = 150,
					Position_Y = 600,
					BarWidth = 180,
					BarHeight = 22,
					BarVerticalGrowdirection = "downwards",
					BarVerticalSpacing = 1,
					BarColumns = 1,
					BarHorizontalGrowdirection = "rightwards",
					BarHorizontalSpacing = 100,

					PlayerCount = {
						Enabled = true,
					},
					ButtonModules = {
						CastBar = {
							Enabled = false,
							Points = {
								{
									Point = "LEFT",
									RelativeFrame = "SpecClassPriorityOne",
									RelativePoint = "RIGHT",
									OffsetX = 28,
								}
							}
						},
						Cooldowns = {
							Points = {
								{
									Point = "TOPLEFT",
									RelativeFrame = "Racial",
									RelativePoint = "TOPRIGHT",
								}
							},
							Container = {
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "downwards",
							},
						},
						DRTracking = {
							Points = {
								{
									Point = "TOPLEFT",
									RelativeFrame = "SpecClassPriorityOne",
									RelativePoint = "TOPRIGHT",
								}
							},
							Container = {
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "downwards",
							}
						},
						NonPriorityBuffs = {
							Points = {
								{
									Point = "TOPLEFT",
									RelativeFrame = "PriorityDebuffs",
									RelativePoint = "TOPRIGHT",
									OffsetX = 2,
									OffsetY = 0
								}
							},
							Container = {
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "downwards",
							}
						},
						NonPriorityDebuffs = {
							Points = {
								{
									Point = "TOPLEFT",
									RelativeFrame = "NonPriorityBuffs",
									RelativePoint = "TOPRIGHT",
									OffsetX = 8
								}
							},
							Container = {
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "downwards",
							}
						},
						Power = {
							Enabled = false,
						},
						PriorityBuffs = {
							Points = {
								{
									Point = "TOPLEFT",
									RelativeFrame = "DRTracking",
									RelativePoint = "TOPRIGHT",
									OffsetX = 2,
									OffsetY = 0
								}
							},
							Container = {
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "downwards",
							}
						},
						PriorityDebuffs = {
							Points = {
								{
									Point = "TOPLEFT",
									RelativeFrame = "PriorityBuffs",
									RelativePoint = "TOPRIGHT",
									OffsetX = 8
								}
							},
							Container = {
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "downwards",
							}
						},
						Racial = {
							Points = {
								{
									Point = "TOPRIGHT",
									RelativeFrame = "Trinket",
									RelativePoint = "TOPLEFT",
									OffsetX = -1
								}
							}
						},
						SpecClassPriorityOne = {
							Points = {
								{
									Point = "TOPLEFT",
									RelativeFrame = "Button",
									RelativePoint = "TOPRIGHT",
								}
							}
						},
						Trinket = {
							Points = {
								{
									Point = "TOPRIGHT",
									RelativeFrame = "Button",
									RelativePoint = "TOPLEFT",
									OffsetX = -1
								}
							}
						}
					},


					Framescale = 1,

				}
			},
			customPlayerCountConfigs = {
				["**"] = allieDefaults15man --**means it will be used by all other keys in here, for example customPlayerCountConfigs.xyx will be allieDefaults15man
		
			}
		},
		ButtonModules = {},
	}
}