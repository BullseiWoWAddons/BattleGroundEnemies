local AddonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L
local CreateFrame = CreateFrame
local GetTime = GetTime
local GetSpellTexture = GetSpellTexture
local GameTooltip = GameTooltip

local IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

local defaultSettings = {
	Enabled = true,
	Parent = "Button",
	UseButtonHeightAsHeight = true,
	UseButtonHeightAsWidth = true,
	Cooldown = {
		ShowNumber = true,
		FontSize = 12,
		FontOutline = "OUTLINE",
		EnableShadow = false,
		ShadowColor = {0, 0, 0, 1},
	}
}

local options = function(location)
	return {
		CooldownTextSettings = {
			type = "group",
			name = L.Countdowntext,
			inline = true,
			order = 1,
			get = function(option)
				return Data.GetOption(location.Cooldown, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.Cooldown, option, ...)
			end,
			args = Data.AddCooldownSettings(location.Cooldown)
		}
	}
end

local trinket = BattleGroundEnemies:NewButtonModule({
	moduleName = "Trinket",
	localizedModuleName = L.Trinket,
	defaultSettings = defaultSettings,
	options = options,
	events = {"ShouldQueryAuras", "CareAboutThisAura", "UnitAura", "SPELL_CAST_SUCCESS"},
	expansions = "All"
})

function trinket:AttachToPlayerButton(playerButton)

	local frame = CreateFrame("frame", nil, playerButton)
	-- trinket
	frame:HookScript("OnEnter", function(self)
		if self.SpellID then
			BattleGroundEnemies:ShowTooltip(self, function()
				if IsClassic then return end
				GameTooltip:SetSpellByID(self.SpellID)
			end)
		end
	end)

	frame:HookScript("OnLeave", function(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end)


	frame.Icon = frame:CreateTexture()
	frame.Icon:SetAllPoints()
	frame:SetScript("OnSizeChanged", function(self, width, height)
		BattleGroundEnemies.CropImage(self.Icon, width, height)
	end)

	frame.Cooldown = BattleGroundEnemies.MyCreateCooldown(frame)
	function frame:TrinketCheck(spellID)
		if not Data.TrinketData[spellID] then return end
		self:DisplayTrinket(spellID, Data.TrinketData[spellID].fileID or GetSpellTexture(spellID))
		if Data.TrinketData[spellID].cd then
			self:SetTrinketCooldown(GetTime(), Data.TrinketData[spellID].cd or 0)
		end
	end

	function frame:DisplayTrinket(spellID, texture)
		self.SpellID = spellID
		self.Icon:SetTexture(texture)
	end

	function frame:SetTrinketCooldown(startTime, duration)
		if (startTime ~= 0 and duration ~= 0) then
			self.Cooldown:SetCooldown(startTime, duration)
		else
			self.Cooldown:Clear()
		end
	end

	function frame:ShouldQueryAuras(unitID, filter)
		return filter == "HARMFUL"
	end


	function frame:CareAboutThisAura(unitID, auraInfo, filter, spellID, unitCaster, canStealOrPurge, canApplyAura, debuffType)
		if spellID == 336139 then return true end

		return not self.SpellID and Data.cCdurationBySpellID[spellID]
	end


	function frame:UnitAura(unitID, filter, spellName, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, nameplateShowAll, timeMod)
		if filter == "HELPFUL" then return end

		if spellID == 336139 then --adapted debuff > adaptation
			local currentTime = GetTime()
			self:DisplayTrinket(spellID, GetSpellTexture(214027))
			self:SetTrinketCooldown(currentTime, expirationTime - currentTime)
			return -- we are done don't do relentless check
		end


		--BattleGroundEnemies:Debug(operation, spellID)
		local continue = not self.SpellID and Data.cCdurationBySpellID[spellID]
		if not continue then return end

		local Racefaktor = 1
	--[[ 	if drCat == "stun" and playerButton.PlayerRace == "Orc" then
			--Racefaktor = 0.8	--Hardiness, but since september 5th hotfix hardiness no longer stacks with relentless so we have no way of determing if the player is running relentless or not
			return
		end ]]


		--local diminish = actualduraion/(Racefaktor * normalDuration * Trinketfaktor)
		--local trinketFaktor * diminish = duration/(Racefaktor * normalDuration)
		--trinketTimesDiminish = trinketFaktor * diminish
		--trinketTimesDiminish = without relentless : 1, 0.5, 0.25, with relentless: 0.8, 0.4, 0.2

		local trinketTimesDiminish = duration/(Racefaktor * Data.cCdurationBySpellID[spellID])

		if trinketTimesDiminish == 0.8 or trinketTimesDiminish == 0.4 or trinketTimesDiminish == 0.2 then --Relentless
			self.SpellID = 336128
			self.Icon:SetTexture(GetSpellTexture(196029))
		end
	
	end

	function frame:SPELL_CAST_SUCCESS(srcName, destName, spellID)
		self:TrinketCheck(spellID)
	end


	function frame:Reset()
		self.SpellID = false
		self.Icon:SetTexture(nil)
		self.Cooldown:Clear()	--reset Trinket Cooldown
	end

	function frame:ApplyAllSettings()

		local moduleSettings = self.config
		self.Cooldown:ApplyCooldownSettings(moduleSettings.Cooldown, false, true, {0, 0, 0, 0.5})
	end
	playerButton.Trinket = frame
end

