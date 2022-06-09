
local BattleGroundEnemies = BattleGroundEnemies
local AddonName, Data = ...
local GetTime = GetTime

local AddonName, Data = ...
local L = Data.L


local defaultSettings = {
}

local options = function(location) 
	return 
end

local events = {"UpdateRaidTargetIcon", "PlayerButtonSizeChanged"}

local raidTargetIcon = BattleGroundEnemies:NewModule("RaidTargetIcon", "RaidTargetIcon", 3, defaultSettings, options, events)

function raidTargetIcon:AttachToPlayerButton(playerButton)
	playerButton.RaidTargetIcon = CreateFrame('Frame', nil, playerButton.healthBar, BackdropTemplateMixin and "BackdropTemplate")
	playerButton.RaidTargetIcon:SetPoint("TOP")
	playerButton.RaidTargetIcon:SetPoint("BOTTOM")
	playerButton.RaidTargetIcon:SetWidth(30)
	playerButton.RaidTargetIcon.Icon = playerButton.RaidTargetIcon:CreateTexture(nil, "OVERLAY")
	playerButton.RaidTargetIcon.Icon:SetTexture("Interface/TargetingFrame/UI-RaidTargetingIcons")
	playerButton.RaidTargetIcon.Icon:SetAllPoints()
	playerButton.RaidTargetIcon:Hide()


	function playerButton.RaidTargetIcon:UpdateRaidTargetIcon()
		local config = self.config

		local unit = playerButton:GetUnitID()
		if unit then
			local index = GetRaidTargetIndex(unit)
			if index then
				SetRaidTargetIconTexture(self.Icon, index)
				self:Show()
				if index == 8 and (not self.HasIcon or self.HasIcon ~= 8) then
					if BattleGroundEnemies.IsRatedBG and BattleGroundEnemies.db.profile.RBG.TargetCalling_NotificationEnable then
						local path = LSM:Fetch("sound", BattleGroundEnemies.db.profile.RBG.TargetCalling_NotificationSound, true)
						if path then
							PlaySoundFile(path, "Master")
						end
					end 
				end

				self.HasIcon = index
			else
				self:HideIcon()
			end
		end

	end
	--	
	function playerButton.RaidTargetIcon:HideIcon()
		self:Hide()
		self.HasIcon = false
	end

	function playerButton.RaidTargetIcon:PlayerButtonSizeChanged(width, height)
		playerButton.RaidTargetIcon:SetWidth(height)
	end

	function playerButton.RaidTargetIcon:ApplyAllSettings()
		local config = self.config
		self:SetStatusBarTexture(LSM:Fetch("statusbar", config.Texture))--self.healthBar:SetStatusBarTexture(137012)
		self.Background:SetVertexColor(unpack(config.Background))
	end

	function playerButton.RaidTargetIcon:Reset()
		self:HideIcon()
	end
end










-- on new player on unit





