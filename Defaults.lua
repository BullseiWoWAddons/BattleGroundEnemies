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
		}
	},

	ButtonModules = {
		CastBar = {
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
			}
		},
		Trinket = {
			ActivePoints = 2,
			Points = {
				{
					Point = "TOPRIGHT",
					RelativeFrame = "Spec",
					RelativePoint = "TOPLEFT",
					OffsetX = -1
				},
				{
					Point = "BOTTOMRIGHT",
					RelativeFrame = "Spec",
					RelativePoint = "BOTTOMLEFT",
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
		}
	},

	ButtonModules = {
		CastBar = {
			Enabled = false,
			Points = {
				{
					Point = "RIGHT",
					RelativeFrame = "Spec",
					RelativePoint = "LEFT",
					OffsetX = -3
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
				VerticalGrowdirection = "upwards",
			},
		},
		DRTracking = {
			Points = {
				{
					Point = "TOPRIGHT",
					RelativeFrame = "Class",
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
			}
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
		UseBigDebuffsPriority = true,
		ConvertCyrillic = true,

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
						}
					},
					ButtonModules = {
						Class = {
							Width = 52,
						},
						CastBar = {
							Enabled = true,
							Points = {
								{
									Point = "RIGHT",
									RelativeFrame = "Spec",
									RelativePoint = "LEFT",
									OffsetX = -3
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
								VerticalGrowdirection = "upwards",
							},
						},
						DRTracking = {
							Points = {
								{
									Point = "TOPRIGHT",
									RelativeFrame = "Class",
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
							Height = 8,
						},
						PriorityBuffs = {
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
							}
						},
						RaidTargetIcon = {
							Enabled = false
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
						}
					},

					ButtonModules = {
						CastBar = {
							Enabled = false,
							Points = {
								{
									Point = "RIGHT",
									RelativeFrame = "Spec",
									RelativePoint = "LEFT",
									OffsetX = -3
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
								VerticalGrowdirection = "upwards",
							},
						},
						DRTracking = {
							Points = {
								{
									Point = "TOPRIGHT",
									RelativeFrame = "Class",
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
							Enabled = false,
						},
						PriorityBuffs = {
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
							}
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
						}
					},
					ButtonModules = {
						CastBar = {
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
						Class = {
							Width = 52,
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
								VerticalGrowdirection = "upwards",
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
							Height = 8,
						},
						PriorityBuffs = {
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
							}
						},
						RaidTargetIcon = {
							Enabled = false
						},
						Trinket = {
							ActivePoints = 2,
							Points = {
								{
									Point = "TOPRIGHT",
									RelativeFrame = "Spec",
									RelativePoint = "TOPLEFT",
									OffsetX = -1
								},
								{
									Point = "BOTTOMRIGHT",
									RelativeFrame = "Spec",
									RelativePoint = "BOTTOMLEFT",
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
						}
					},

					ButtonModules = {
						CastBar = {
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
							Enabled = false,
						},
						PriorityBuffs = {
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
							}
						},
						Trinket = {
							ActivePoints = 2,
							Points = {
								{
									Point = "TOPRIGHT",
									RelativeFrame = "Spec",
									RelativePoint = "TOPLEFT",
									OffsetX = -1
								},
								{
									Point = "BOTTOMRIGHT",
									RelativeFrame = "Button",
									RelativePoint = "BOTTOMLEFT",
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
		}
	}
}