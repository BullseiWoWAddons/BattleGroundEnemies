---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)
---@class BattleGroundEnemies
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L
local CreateFrame = CreateFrame
local GetTime = GetTime
local GetSpellTexture = C_Spell and C_Spell.GetSpellTexture or GetSpellTexture
local GameTooltip = GameTooltip
local IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

local DRList = LibStub("DRList-1.0")


local IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

local defaultSettings = {
	Enabled = true,
	Parent = "Button",
	UseButtonHeightAsHeight = true,
	UseButtonHeightAsWidth = true,
	ActivePoints = 1,
	Cooldown = {
		FontSize = 12,
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
	events = {"ShouldQueryAuras", "NewAura", "SPELL_CAST_SUCCESS"},
	enabledInThisExpansion = true
})

function trinket:AttachToPlayerButton(playerButton)

	local frame = CreateFrame("frame", nil, playerButton)
	-- trinket
	frame:HookScript("OnEnter", function(self)
		if self.spellId then
			BattleGroundEnemies:ShowTooltip(self, function()
				if IsClassic then return end
				GameTooltip:SetSpellByID(self.spellId)
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


	function frame:TrinketCheck(spellId)
		if not Data.TrinketData[spellId] then return end
		self:DisplayTrinket(spellId, Data.TrinketData[spellId].itemID)
		if Data.TrinketData[spellId].cd then
			local trinketCD=Data.TrinketData[spellId].cd or 0
			
			-- If healer in retail reduce 2 min trinkets to 90 seconds.
			if IsRetail and playerButton.PlayerDetails.PlayerRole == "HEALER" and trinketCD == 120 then
				trinketCD=90
			end
			self:SetTrinketCooldown(GetTime(), trinketCD)
		end
	end

	function frame:DisplayTrinket(spellId, itemID)
		local texture
		if(itemID and itemID ~= 0) then
			texture = GetItemIcon(itemID)
		else
			if spellId == 336139 then --adapted
				texture = GetSpellTexture(214027) --Adaptation
			else
				local spellTexture, spellTextureNoOverride = GetSpellTexture(spellId)
				texture = spellTextureNoOverride
			end
		end

		self.spellId = spellId
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

	function frame:NewAura(unitID, filter, aura)
		if filter == "HELPFUL" then return end

		local spellId = aura.spellId
		local spellName = aura.name
		if spellId == 336139 then --adapted debuff > adaptation
			local currentTime = GetTime()
			self:DisplayTrinket(spellId)
			self:SetTrinketCooldown(currentTime, aura.expirationTime - currentTime)
			return -- we are done don't do relentless check
		end


		--self:Debug(operation, spellId)
		local continue = not self.spellId and Data.cCdurationBySpellID[spellId]
		if not continue then return end

		local drCat = DRList:GetCategoryBySpellID(IsClassic and spellName or spellId)
		if not drCat then return end

		local Racefaktor = 1
		if drCat == "stun" and playerButton.PlayerDetails.PlayerRace == "Orc" then
			--Racefaktor = 0.8	--Hardiness, but since september 5th hotfix hardiness no longer stacks with relentless so we have no way of determing if the player is running relentless or not
			return
		end


		--local diminish = actualduraion/(Racefaktor * normalDuration * Trinketfaktor)
		--local trinketFaktor * diminish = duration/(Racefaktor * normalDuration)
		--trinketTimesDiminish = trinketFaktor * diminish
		--trinketTimesDiminish = without relentless : 1, 0.5, 0.25, with relentless: 0.8, 0.4, 0.2

		local trinketTimesDiminish = aura.duration/(Racefaktor * Data.cCdurationBySpellID[spellId])

		if trinketTimesDiminish == 0.8 or trinketTimesDiminish == 0.4 or trinketTimesDiminish == 0.2 then --Relentless
			self.spellId = 336128
			self.Icon:SetTexture(GetSpellTexture(196029))
		end
	end

	function frame:SPELL_CAST_SUCCESS(srcGUID, srcName, destGUID, destName, spellId)
		self:TrinketCheck(spellId)
	end


	function frame:Reset()
		self.spellId = false
		self.Icon:SetTexture(nil)
		self.Cooldown:Clear()	--reset Trinket Cooldown
	end

	function frame:ApplyAllSettings()
		local moduleSettings = self.config
		if not moduleSettings then return end
		self.Cooldown:ApplyCooldownSettings(moduleSettings.Cooldown, false, {0, 0, 0, 0.5})
	end
	playerButton.Trinket = frame
	return playerButton.Trinket
end