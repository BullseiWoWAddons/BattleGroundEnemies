---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)

local allieDefaults15man = {
	Enabled = true,
	minPlayerCount = 6,
	maxPlayerCount = 15,

	Position_X = false,
	Position_Y = false,
	BarWidth = 180,
	BarHeight = 28,
	BarVerticalGrowdirection = "downwards",
	BarVerticalSpacing = 3,
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
			JustifyV = "MIDDLE",
			JustifyH = "LEFT"
		}
	},

	ButtonModules = {
		CastBar = {
			UsePlayerCountSpecificSettings = true,
			Enabled = false,
			Points = {
				{
					Point = "LEFT",
					RelativeFrame = "Button",
					RelativePoint = "RIGHT",
					OffsetX = 28,
				},
			},
		},
		Cooldowns = {
			UsePlayerCountSpecificSettings = true,
			Points = {
				{
					Point = "TOPLEFT",
					RelativeFrame = "Racial",
					RelativePoint = "TOPRIGHT",
				}
			},
			Container = {
				HorizontalGrowDirection = "rightwards",
				VerticalGrowdirection = "upwards",
			},
		},
		DRTracking = {
			UsePlayerCountSpecificSettings = true,
			Points = {
				{
					Point = "TOPLEFT",
					RelativeFrame = "Button",
					RelativePoint = "TOPRIGHT",
				}
			},
			Container = {
				HorizontalGrowDirection = "rightwards",
				VerticalGrowdirection = "upwards",
			},
		},
		NonPriorityBuffs = {
			UsePlayerCountSpecificSettings = true,
			Enabled = false,
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
				HorizontalGrowDirection = "rightwards",
				VerticalGrowdirection = "upwards",
			},
		},
		NonPriorityDebuffs = {
			UsePlayerCountSpecificSettings = true,
			Enabled = false,
			Points = {
				{
					Point = "BOTTOMLEFT",
					RelativeFrame = "NonPriorityBuffs",
					RelativePoint = "BOTTOMRIGHT",
					OffsetX = 8
				}
			},
			Container = {
				HorizontalGrowDirection = "rightwards",
				VerticalGrowdirection = "upwards",
			}
		},
		PriorityBuffs = {
			UsePlayerCountSpecificSettings = true,
			Enabled = true,
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
				HorizontalGrowDirection = "rightwards",
				VerticalGrowdirection = "upwards",
			}
		},
		PriorityDebuffs = {
			UsePlayerCountSpecificSettings = true,
			Enabled = true,
			Points = {
				{
					Point = "BOTTOMLEFT",
					RelativeFrame = "PriorityBuffs",
					RelativePoint = "BOTTOMRIGHT",
					OffsetX = 8
				}
			},
			Container = {
				HorizontalGrowDirection = "rightwards",
				VerticalGrowdirection = "upwards",
			}
		},
		Racial = {
			UsePlayerCountSpecificSettings = true,
			Points = {
				{
					Point = "TOPRIGHT",
					RelativeFrame = "Trinket",
					RelativePoint = "TOPLEFT",
					OffsetX = -1
				}
			}
		},
		Trinket = {
			UsePlayerCountSpecificSettings = true,
			Points = {
				{
					Point = "TOPRIGHT",
					RelativeFrame = "SpecClassPriorityOne",
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

	Position_X = false,
	Position_Y = false,
	BarWidth = 180,
	BarHeight = 28,
	BarVerticalGrowdirection = "downwards",
	BarVerticalSpacing = 3,
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
			JustifyV = "MIDDLE",
			JustifyH = "LEFT"
		}
	},

	ButtonModules = {
		CastBar = {
			UsePlayerCountSpecificSettings = true,
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
			UsePlayerCountSpecificSettings = true,
			Points = {
				{
					Point = "TOPLEFT",
					RelativeFrame = "Racial",
					RelativePoint = "TOPRIGHT",
				}
			},
			Container = {
				HorizontalGrowDirection = "rightwards",
				VerticalGrowdirection = "upwards",
			},
		},
		DRTracking = {
			UsePlayerCountSpecificSettings = true,
			Points = {
				{
					Point = "TOPRIGHT",
					RelativeFrame = "SpecClassPriorityOne",
					RelativePoint = "TOPLEFT",
					OffsetX = -2
				}
			},
			Container = {
				HorizontalGrowDirection = "leftwards",
				VerticalGrowdirection = "upwards",
			}
		},
		NonPriorityBuffs = {
			UsePlayerCountSpecificSettings = true,
			Enabled = false,
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
				HorizontalGrowDirection = "leftwards",
				VerticalGrowdirection = "upwards",
			}
		},
		NonPriorityDebuffs = {
			UsePlayerCountSpecificSettings = true,
			Enabled = false,
			Points = {
				{
					Point = "BOTTOMRIGHT",
					RelativeFrame = "NonPriorityBuffs",
					RelativePoint = "BOTTOMLEFT",
					OffsetX = -8
				}
			},
			Container = {
				HorizontalGrowDirection = "leftwards",
				VerticalGrowdirection = "upwards",
			}
		},
		PriorityBuffs = {
			UsePlayerCountSpecificSettings = true,
			Enabled = true,
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
				HorizontalGrowDirection = "leftwards",
				VerticalGrowdirection = "upwards",
			}
		},
		PriorityDebuffs = {
			UsePlayerCountSpecificSettings = true,
			Enabled = true,
			Points = {
				{
					Point = "BOTTOMRIGHT",
					RelativeFrame = "PriorityBuffs",
					RelativePoint = "BOTTOMLEFT",
					OffsetX = -8
				}
			},
			Container = {
				HorizontalGrowDirection = "leftwards",
				VerticalGrowdirection = "upwards",
			},
		},
		Racial = {
			UsePlayerCountSpecificSettings = true,
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
			UsePlayerCountSpecificSettings = true,
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
		Font = "PT Sans Narrow Bold",
		Locked = false,
		Debug = false,

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
		EnableMouseWheelPlayerTargeting = true,
		UseBigDebuffsPriority = true,
		ConvertCyrillic = true,

		RoleSortingOrder = "HEALER_TANK_DAMAGER",

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

					Position_X = false,
					Position_Y = false,
					BarWidth = 200,
					BarHeight = 47,
					BarVerticalGrowdirection = "downwards",
					BarVerticalSpacing = 40,
					BarColumns = 1,
					BarHorizontalGrowdirection = "rightwards",
					BarHorizontalSpacing = 100,

					PlayerCount = {
						Enabled = false,
						Text = {
							FontSize = 14,
							FontOutline = "OUTLINE",
							FontColor = {1, 1, 1, 1},
							EnableShadow = false,
							ShadowColor = {0, 0, 0, 1},
							JustifyV = "MIDDLE",
							JustifyH = "LEFT"
						}
					},
					ButtonModules = {
						SpecClassPriorityOne = {
							UsePlayerCountSpecificSettings = true,
							Width = 52
						},
						CastBar = {
							UsePlayerCountSpecificSettings = true,
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
							UsePlayerCountSpecificSettings = true,
							Enabled = false
						},
						Cooldowns = {
							UsePlayerCountSpecificSettings = true,
							Points = {
								{
									Point = "TOPLEFT",
									RelativeFrame = "Racial",
									RelativePoint = "TOPRIGHT",
								}
							},
							Container = {
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "upwards",
							},
						},
						DRTracking = {
							UsePlayerCountSpecificSettings = true,
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
							UsePlayerCountSpecificSettings = true,
							HealthTextEnabled = true,
							HealthTextType = "health",
							HealthText = {
								FontSize = 18,
								JustifyV = "BOTTOM"
							}
						},
						Name = {
							UsePlayerCountSpecificSettings = true,
							Text = {
								JustifyV = "TOP"
							}
						},
						NonPriorityBuffs = {
							UsePlayerCountSpecificSettings = true,
							Enabled = true,
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
								HorizontalGrowDirection = "leftwards",
								VerticalGrowdirection = "upwards",
							}
						},
						NonPriorityDebuffs = {
							UsePlayerCountSpecificSettings = true,
							Enabled = true,
							Points = {
								{
									Point = "BOTTOMRIGHT",
									RelativeFrame = "NonPriorityBuffs",
									RelativePoint = "BOTTOMLEFT",
									OffsetX = -8
								}
							},
							Container = {
								HorizontalGrowDirection = "leftwards",
								VerticalGrowdirection = "upwards",
							}
						},
						Power = {
							UsePlayerCountSpecificSettings = true,
							Height = 8,
						},
						PriorityBuffs = {
							UsePlayerCountSpecificSettings = true,
							Enabled = true,
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
								UseButtonHeightAsSize = false,
								IconSize = 25,
								IconsPerRow = 8,
								HorizontalGrowDirection = "leftwards",
								VerticalGrowdirection = "upwards",
							}
						},
						PriorityDebuffs = {
							UsePlayerCountSpecificSettings = true,
							Enabled = true,
							Points = {
								{
									Point = "BOTTOMRIGHT",
									RelativeFrame = "PriorityBuffs",
									RelativePoint = "BOTTOMLEFT",
									OffsetX = -8
								}
							},
							Container = {
								UseButtonHeightAsSize = false,
								IconSize = 25,
								IconsPerRow = 8,
								HorizontalGrowDirection = "leftwards",
								VerticalGrowdirection = "upwards",
							}
						},
						Racial = {
							UsePlayerCountSpecificSettings = true,
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
							UsePlayerCountSpecificSettings = true,
							Enabled = false
						},
						Trinket = {
							UsePlayerCountSpecificSettings = true,
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

					Position_X = false,
					Position_Y = false,
					BarWidth = 180,
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
							JustifyV = "MIDDLE",
							JustifyH = "LEFT"
						}
					},
					ButtonModules = {
						CastBar = {
							UsePlayerCountSpecificSettings = true,
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
							UsePlayerCountSpecificSettings = true,
							Points = {
								{
									Point = "TOPLEFT",
									RelativeFrame = "Racial",
									RelativePoint = "TOPRIGHT",
								}
							},
							Container = {
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "upwards",
							},
						},
						DRTracking = {
							UsePlayerCountSpecificSettings = true,
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
								VerticalGrowdirection = "upwards",
							}
						},
						NonPriorityBuffs = {
							UsePlayerCountSpecificSettings = true,
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
								HorizontalGrowDirection = "leftwards",
								VerticalGrowdirection = "upwards",
							}
						},
						NonPriorityDebuffs = {
							UsePlayerCountSpecificSettings = true,
							Points = {
								{
									Point = "BOTTOMRIGHT",
									RelativeFrame = "NonPriorityBuffs",
									RelativePoint = "BOTTOMLEFT",
									OffsetX = -8
								}
							},
							Container = {
								HorizontalGrowDirection = "leftwards",
								VerticalGrowdirection = "upwards",
							}
						},
						Power = {
							UsePlayerCountSpecificSettings = true,
							Enabled = false,
						},
						PriorityBuffs = {
							UsePlayerCountSpecificSettings = true,
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
								HorizontalGrowDirection = "leftwards",
								VerticalGrowdirection = "upwards",
							}
						},
						PriorityDebuffs = {
							UsePlayerCountSpecificSettings = true,
							Points = {
								{
									Point = "BOTTOMRIGHT",
									RelativeFrame = "PriorityBuffs",
									RelativePoint = "BOTTOMLEFT",
									OffsetX = -8
								}
							},
							Container = {
								HorizontalGrowDirection = "leftwards",
								VerticalGrowdirection = "upwards",
							}
						},
						Racial = {
							UsePlayerCountSpecificSettings = true,
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
							UsePlayerCountSpecificSettings = true,
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

					Position_X = false,
					Position_Y = false,
					BarWidth = 200,
					BarHeight = 47,
					BarVerticalGrowdirection = "downwards",
					BarVerticalSpacing = 40,
					BarColumns = 1,
					BarHorizontalGrowdirection = "rightwards",
					BarHorizontalSpacing = 100,

					PlayerCount = {
						Enabled = false,
						Text = {
							FontSize = 14,
							FontOutline = "OUTLINE",
							FontColor = {1, 1, 1, 1},
							EnableShadow = false,
							ShadowColor = {0, 0, 0, 1},
							JustifyV = "MIDDLE",
							JustifyH = "LEFT"
						}
					},
					ButtonModules = {
						CastBar = {
							UsePlayerCountSpecificSettings = true,
							Enabled = true,
							Points = {
								{
									Point = "LEFT",
									RelativeFrame = "Button",
									RelativePoint = "RIGHT",
									OffsetX = 28,
								},
							},
						},
						SpecClassPriorityOne = {
							UsePlayerCountSpecificSettings = true,
							Width = 52
						},
						Covenant = {
							UsePlayerCountSpecificSettings = true,
							Enabled = false
						},
						Cooldowns = {
							UsePlayerCountSpecificSettings = true,
							Points = {
								{
									Point = "TOPRIGHT",
									RelativeFrame = "Button",
									RelativePoint = "TOPRIGHT",
								}
							},
							Container = {
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "upwards",
							},
						},
						DRTracking = {
							UsePlayerCountSpecificSettings = true,
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
							UsePlayerCountSpecificSettings = true,
							HealthTextEnabled = true,
							HealthTextType = "health",
							HealthText = {
								FontSize = 18,
								JustifyV = "BOTTOM"
							}
						},
						Name = {
							UsePlayerCountSpecificSettings = true,
							Text = {
								JustifyV = "TOP"
							}
						},
						NonPriorityBuffs = {
							UsePlayerCountSpecificSettings = true,
							Enabled = true,
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
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "upwards",
							}
						},
						NonPriorityDebuffs = {
							UsePlayerCountSpecificSettings = true,
							Enabled = true,
							Points = {
								{
									Point = "BOTTOMLEFT",
									RelativeFrame = "NonPriorityBuffs",
									RelativePoint = "BOTTOMRIGHT",
									OffsetX = 8
								}
							},
							Container = {
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "upwards",
							}
						},
						Power = {
							UsePlayerCountSpecificSettings = true,
							Height = 8,
						},
						PriorityBuffs = {
							UsePlayerCountSpecificSettings = true,
							Enabled = true,
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
								UseButtonHeightAsSize = false,
								IconSize = 25,
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "upwards",
							}
						},
						PriorityDebuffs = {
							UsePlayerCountSpecificSettings = true,
							Enabled = true,
							Points = {
								{
									Point = "BOTTOMLEFT",
									RelativeFrame = "PriorityBuffs",
									RelativePoint = "BOTTOMRIGHT",
									OffsetX = 8
								}
							},
							Container = {
								UseButtonHeightAsSize = false,
								IconSize = 25,
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "upwards",
							}
						},
						Racial = {
							UsePlayerCountSpecificSettings = true,
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
							UsePlayerCountSpecificSettings = true,
							Enabled = false
						},
						Trinket = {
							UsePlayerCountSpecificSettings = true,
							Points = {
								{
									Point = "TOPRIGHT",
									RelativeFrame = "SpecClassPriorityOne",
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

					Position_X = false,
					Position_Y = false,
					BarWidth = 180,
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
							JustifyV = "MIDDLE",
							JustifyH = "LEFT"
						}
					},
					ButtonModules = {
						CastBar = {
							UsePlayerCountSpecificSettings = true,
							Enabled = false,
							Points = {
								{
									Point = "LEFT",
									RelativeFrame = "Button",
									RelativePoint = "RIGHT",
									OffsetX = 28,
								}
							}
						},
						Cooldowns = {
							UsePlayerCountSpecificSettings = true,
							Points = {
								{
									Point = "TOPLEFT",
									RelativeFrame = "Racial",
									RelativePoint = "TOPRIGHT",
								}
							},
							Container = {
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "upwards",
							},
						},
						DRTracking = {
							UsePlayerCountSpecificSettings = true,
							Points = {
								{
									Point = "TOPLEFT",
									RelativeFrame = "Button",
									RelativePoint = "TOPRIGHT",
								}
							},
							Container = {
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "upwards",
							}
						},
						NonPriorityBuffs = {
							UsePlayerCountSpecificSettings = true,
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
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "upwards",
							}
						},
						NonPriorityDebuffs = {
							UsePlayerCountSpecificSettings = true,
							Points = {
								{
									Point = "BOTTOMLEFT",
									RelativeFrame = "NonPriorityBuffs",
									RelativePoint = "BOTTOMRIGHT",
									OffsetX = 8
								}
							},
							Container = {
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "upwards",
							}
						},
						Power = {
							UsePlayerCountSpecificSettings = true,
							Enabled = false,
						},
						PriorityBuffs = {
							UsePlayerCountSpecificSettings = true,
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
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "upwards",
							}
						},
						PriorityDebuffs = {
							UsePlayerCountSpecificSettings = true,
							Points = {
								{
									Point = "BOTTOMLEFT",
									RelativeFrame = "PriorityBuffs",
									RelativePoint = "BOTTOMRIGHT",
									OffsetX = 8
								}
							},
							Container = {
								HorizontalGrowDirection = "rightwards",
								VerticalGrowdirection = "upwards",
							}
						},
						Racial = {
							UsePlayerCountSpecificSettings = true,
							Points = {
								{
									Point = "TOPRIGHT",
									RelativeFrame = "Trinket",
									RelativePoint = "TOPLEFT",
									OffsetX = -1
								}
							}
						},
						Trinket = {
							UsePlayerCountSpecificSettings = true,
							Points = {
								{
									Point = "TOPRIGHT",
									RelativeFrame = "SpecClassPriorityOne",
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