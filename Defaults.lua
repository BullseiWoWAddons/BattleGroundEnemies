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
			TargetCalling_NotificationEnable = false
		},
	
		Enemies = {
			Enabled = true,
			
			ShowRealmnames = true,
			ConvertCyrillic = true,
			Level = {
				Enabled = false,
				OnlyShowIfNotMaxLevel = true,
				Text = {
					Fontsize = 18,
					Outline = "",
					Textcolor = {1, 1, 1, 1},
					EnableTextshadow = false,
					TextShadowcolor = {0, 0, 0, 1}
				}
			},

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
			
				Name = {
					Text = {
						Fontsize = 13,
						Outline = "",
						Textcolor = {1, 1, 1, 1}, 
						EnableTextshadow = true,
						TextShadowcolor = {0, 0, 0, 1},
					}
				},
			
				
				Position_X = false,
				Position_Y = false,
				BarWidth = 220,
				BarHeight = 28,
				BarVerticalGrowdirection = "downwards",
				BarVerticalSpacing = 1,
				BarColumns = 1,
				BarHorizontalGrowdirection = "rightwards",
				BarHorizontalSpacing = 100,
				
				HealthBar_Texture = 'UI-StatusBar',
				HealthBar_Background = {0, 0, 0, 0.66},

				HealthBar_HealthPrediction_Enabled = true,
				
				PowerBar_Enabled = false,
				PowerBar_Height = 4,
				PowerBar_Texture = 'UI-StatusBar',
				PowerBar_Background = {0, 0, 0, 0.66},
				

				RoleIcon_Enabled = true,
				RoleIcon_Size = 13,
				RoleIcon_VerticalPosition = 2,

				CovenantIcon_Enabled = true,
				CovenantIcon_Size = 20,
				CovenantIcon_VerticalPosition = 3,
				
				PlayerCount = {
					Enabled = true,
					Text = {
						Fontsize = 14,
						Outline = "OUTLINE",
						Textcolor = {1, 1, 1, 1},
						EnableTextshadow = false,
						TextShadowcolor = {0, 0, 0, 1},
					}
				},
			
				Framescale = 1,
				
				Spec_Enabled = true,
				Spec_Width = 36,
							
				TargetIndicator = {
					Numeric = {
						Enabled = true,
						Text = {
							Fontsize = 18,
							Outline = "",
							Textcolor = {1, 1, 1, 1},
							EnableTextshadow = false,
							TextShadowcolor = {0, 0, 0, 1}
						}
					},
					SymbolicTargetIndicator_Enabled = true,
				},
					
				RaidTargetIcon_Enabled = true,		
				
				
				-- PositiveSound = [[Interface\AddOns\WeakAuras\Media\Sounds\BatmanPunch.ogg]],
				-- NegativeSound = [[Sound\Interface\UI_BattlegroundCountdown_Timer.ogg]],
			},
			["15"] = {
				Enabled = true,
			
				Name = {
					Text = {
						Fontsize = 13,
						Outline = "",
						Textcolor = {1, 1, 1, 1}, 
						EnableTextshadow = true,
						TextShadowcolor = {0, 0, 0, 1},
					}
				},
				Position_X = false,
				Position_Y = false,
				BarWidth = 220,
				BarHeight = 28,
				BarVerticalGrowdirection = "downwards",
				BarVerticalSpacing = 1,
				BarColumns = 1,
				BarHorizontalGrowdirection = "rightwards",
				BarHorizontalSpacing = 100,
				
				HealthBar_Texture = 'UI-StatusBar',
				HealthBar_Background = {0, 0, 0, 0.66},

				HealthBar_HealthPrediction_Enabled = true,
				
				PowerBar_Enabled = false,
				PowerBar_Height = 4,
				PowerBar_Texture = 'UI-StatusBar',
				PowerBar_Background = {0, 0, 0, 0.66},
				

				RoleIcon_Enabled = true,
				RoleIcon_Size = 13,
				RoleIcon_VerticalPosition = 2,

				CovenantIcon_Enabled = true,
				CovenantIcon_Size = 20,
				CovenantIcon_VerticalPosition = 3,
				
				PlayerCount = {
					Enabled = true,
					Text = {
						Fontsize = 14,
						Outline = "OUTLINE",
						Textcolor = {1, 1, 1, 1},
						EnableTextshadow = false,
						TextShadowcolor = {0, 0, 0, 1},
					}
				},
				
				Framescale = 1,
				
				Spec_Enabled = true,
				Spec_Width = 36,
				
				TargetIndicator = {
					Numeric = {
						Enabled = true,
						Text = {
							Fontsize = 18,
							Outline = "",
							Textcolor = {1, 1, 1, 1},
							EnableTextshadow = false,
							TextShadowcolor = {0, 0, 0, 1}
						}
					},
					SymbolicTargetIndicator_Enabled = true,
				},

				RaidTargetIcon_Enabled = true,
				
				
				-- PositiveSound = [[Interface\AddOns\WeakAuras\Media\Sounds\BatmanPunch.ogg]],
				-- NegativeSound = [[Sound\Interface\UI_BattlegroundCountdown_Timer.ogg]],
			},
			["40"] = {
				Enabled = true,
				
				Name = {
					Text = {
						Fontsize = 13,
						Outline = "",
						Textcolor = {1, 1, 1, 1}, 
						EnableTextshadow = true,
						TextShadowcolor = {0, 0, 0, 1},
					}
				},
				
				Position_X = false,
				Position_Y = false,
				BarWidth = 220,
				BarHeight = 22,
				BarVerticalGrowdirection = "downwards",
				BarVerticalSpacing = 1,
				BarColumns = 1,
				BarHorizontalGrowdirection = "rightwards",
				BarHorizontalSpacing = 100,
				
				HealthBar_Texture = 'UI-StatusBar',
				HealthBar_Background = {0, 0, 0, 0.66},

				HealthBar_HealthPrediction_Enabled = true,
				
				PowerBar_Enabled = false,
				PowerBar_Height = 4,
				PowerBar_Texture = 'UI-StatusBar',
				PowerBar_Background = {0, 0, 0, 0.66},
				
				
				RoleIcon_Enabled = true,
				RoleIcon_Size = 13,
				RoleIcon_VerticalPosition = 2,

				CovenantIcon_Enabled = true,
				CovenantIcon_Size = 20,
				CovenantIcon_VerticalPosition = 3,
				
				PlayerCount = {
					Enabled = true,
					Text = {
						Fontsize = 14,
						Outline = "OUTLINE",
						Textcolor = {1, 1, 1, 1},
						EnableTextshadow = false,
						TextShadowcolor = {0, 0, 0, 1},
					}
				},
				
				Framescale = 1,
				
				Spec_Enabled = true,
				Spec_Width = 36,
								
				TargetIndicator = {
					Numeric = {
						Enabled = true,
						Text = {
							Fontsize = 18,
							Outline = "",
							Textcolor = {1, 1, 1, 1},
							EnableTextshadow = false,
							TextShadowcolor = {0, 0, 0, 1}
						}
					},
					SymbolicTargetIndicator_Enabled = true,
				},

				RaidTargetIcon_Enabled = false,
			}
			
		},
		Allies = {
			Enabled = true,
			
			ShowRealmnames = true,
			ConvertCyrillic = true,
			Level = {
				Enabled = false,
				OnlyShowIfNotMaxLevel = true,
				Text = {
					Fontsize = 18,
					Outline = "",
					Textcolor = {1, 1, 1, 1},
					EnableTextshadow = false,
					TextShadowcolor = {0, 0, 0, 1}
				}
			},
			
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
			
				Name = {
					Text = {
						Fontsize = 13,
						Outline = "",
						Textcolor = {1, 1, 1, 1}, 
						EnableTextshadow = true,
						TextShadowcolor = {0, 0, 0, 1},
					}
				},
				
				Position_X = false,
				Position_Y = false,
				BarWidth = 220,
				BarHeight = 28,
				BarVerticalGrowdirection = "downwards",
				BarVerticalSpacing = 1,
				BarColumns = 1,
				BarHorizontalGrowdirection = "rightwards",
				BarHorizontalSpacing = 100,
				
				HealthBar_Texture = 'UI-StatusBar',
				HealthBar_Background = {0, 0, 0, 0.66},

				HealthBar_HealthPrediction_Enabled = true,
				
				PowerBar_Enabled = false,
				PowerBar_Height = 4,
				PowerBar_Texture = 'UI-StatusBar',
				PowerBar_Background = {0, 0, 0, 0.66},
				
				
				RoleIcon_Enabled = true,
				RoleIcon_Size = 13,
				RoleIcon_VerticalPosition = 2,

				CovenantIcon_Enabled = true,
				CovenantIcon_Size = 20,
				CovenantIcon_VerticalPosition = 3,
				
				PlayerCount = {
					Enabled = true,
					Text = {
						Fontsize = 14,
						Outline = "OUTLINE",
						Textcolor = {1, 1, 1, 1},
						EnableTextshadow = false,
						TextShadowcolor = {0, 0, 0, 1},
					}
				},
				
				Framescale = 1,
				
				Spec_Enabled = true,
				Spec_Width = 36,
								
				TargetIndicator = {
					Numeric = {
						Enabled = true,
						Text = {
							Fontsize = 18,
							Outline = "",
							Textcolor = {1, 1, 1, 1},
							EnableTextshadow = false,
							TextShadowcolor = {0, 0, 0, 1}
						}
					},
					SymbolicTargetIndicator_Enabled = true,
				},
				
				RaidTargetIcon_Enabled = true,
	
								-- PositiveSound = [[Interface\AddOns\WeakAuras\Media\Sounds\BatmanPunch.ogg]],
				-- NegativeSound = [[Sound\Interface\UI_BattlegroundCountdown_Timer.ogg]],

			},
			["15"] = {
				Enabled = true,
			
				Name = {
					Text = {
						Fontsize = 13,
						Outline = "",
						Textcolor = {1, 1, 1, 1}, 
						EnableTextshadow = true,
						TextShadowcolor = {0, 0, 0, 1},
					}
				},
				
				Position_X = false,
				Position_Y = false,
				BarWidth = 220,
				BarHeight = 28,
				BarVerticalGrowdirection = "downwards",
				BarVerticalSpacing = 1,
				BarColumns = 1,
				BarHorizontalGrowdirection = "rightwards",
				BarHorizontalSpacing = 100,
				
				HealthBar_Texture = 'UI-StatusBar',
				HealthBar_Background = {0, 0, 0, 0.66},

				HealthBar_HealthPrediction_Enabled = true,
				
				PowerBar_Enabled = false,
				PowerBar_Height = 4,
				PowerBar_Texture = 'UI-StatusBar',
				PowerBar_Background = {0, 0, 0, 0.66},
				
				
				RoleIcon_Enabled = true,
				RoleIcon_Size = 13,
				RoleIcon_VerticalPosition = 2,

				CovenantIcon_Enabled = true,
				CovenantIcon_Size = 20,
				CovenantIcon_VerticalPosition = 3,
				
				PlayerCount = {
					Enabled = true,
					Text = {
						Fontsize = 14,
						Outline = "OUTLINE",
						Textcolor = {1, 1, 1, 1},
						EnableTextshadow = false,
						TextShadowcolor = {0, 0, 0, 1},
					}
				},
				
				Framescale = 1,
				
				Spec_Enabled = true,
				Spec_Width = 36,
								
				TargetIndicator = {
					Numeric = {
						Enabled = true,
						Text = {
							Fontsize = 18,
							Outline = "",
							Textcolor = {1, 1, 1, 1},
							EnableTextshadow = false,
							TextShadowcolor = {0, 0, 0, 1}
						}
					},
					SymbolicTargetIndicator_Enabled = true,
				},

				RaidTargetIcon_Enabled = true,

								-- PositiveSound = [[Interface\AddOns\WeakAuras\Media\Sounds\BatmanPunch.ogg]],
				-- NegativeSound = [[Sound\Interface\UI_BattlegroundCountdown_Timer.ogg]],
			},
			["40"] = {
				Enabled = true,
			
				Name = {
					Text = {
						Fontsize = 13,
						Outline = "",
						Textcolor = {1, 1, 1, 1}, 
						EnableTextshadow = true,
						TextShadowcolor = {0, 0, 0, 1},
					}
				},
				
				Position_X = false,
				Position_Y = false,
				BarWidth = 220,
				BarHeight = 22,
				BarVerticalGrowdirection = "downwards",
				BarVerticalSpacing = 1,
				BarColumns = 1,
				BarHorizontalGrowdirection = "rightwards",
				BarHorizontalSpacing = 100,
				
				HealthBar_Texture = 'UI-StatusBar',
				HealthBar_Background = {0, 0, 0, 0.66},

				HealthBar_HealthPrediction_Enabled = true,
				
				PowerBar_Enabled = false,
				PowerBar_Height = 4,
				PowerBar_Texture = 'UI-StatusBar',
				PowerBar_Background = {0, 0, 0, 0.66},
				
				
				RoleIcon_Enabled = true,
				RoleIcon_Size = 13,
				RoleIcon_VerticalPosition = 2,

				CovenantIcon_Enabled = true,
				CovenantIcon_Size = 20,
				CovenantIcon_VerticalPosition = 3,
				
				PlayerCount = {
					Enabled = true,
					Text = {
						Fontsize = 14,
						Outline = "OUTLINE",
						Textcolor = {1, 1, 1, 1},
						EnableTextshadow = false,
						TextShadowcolor = {0, 0, 0, 1},
					}
				},
				
				Framescale = 1,
				
				Spec_Enabled = true,
				Spec_Width = 36,
								
				TargetIndicator = {
					Numeric = {
						Enabled = true,
						Text = {
							Fontsize = 18,
							Outline = "",
							Textcolor = {1, 1, 1, 1},
							EnableTextshadow = false,
							TextShadowcolor = {0, 0, 0, 1}
						}
					},
					SymbolicTargetIndicator_Enabled = true,
				},

				RaidTargetIcon_Enabled = false,
			}
		}
	}
}