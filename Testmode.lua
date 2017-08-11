local addonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies

local LibRaces = LibStub("LibRaces-1.0")
local DRData = LibStub("DRData-1.0")
local LibPlayerSpells = LibStub("LibPlayerSpells-1.0")


local math.random = math.random
local table.insert = table.insert
local table.remove = table.remove


local playerFaction = UnitFactionGroup("player")
local fakeEnemies = {}
local randomTrinkets = {}
local randomRacials = {}
local randomDrCategory = {} --key = number, value = categorieName
local DrCategoryToSpell = {} --key = categorieName, value = table with key = number and value = spellID
local harmfulPlayerSpells = {} --key = number, value = spellID
local FakeEnemiesOnUpdateFrame = CreateFrame("frame")
FakeEnemiesOnUpdateFrame:Hide()


local function SetupTestmode()
	
	local i = 1
	for categorieName, localizedCategoryName in pairs(DRData.categoryNames) do
		randomDrCategory[i] = categorieName
		DrCategoryToSpell[categorieName] = {}
		i = i + 1
	end
	


	for spellID, categorieName in pairs(DRData.spells) do
		table.insert(DrCategoryToSpell[categorieName], spellID)
	end


	
	


	do
		local count = 1
		for triggerSpellID, tinketNumber in pairs(Data.TriggerSpellIDToTrinketnumber) do
			randomTrinkets[count] = triggerSpellID
			count = count + 1
		end
		
	end

	do
		local count = 1
		for racialSpelliD, cd in pairs(Data.RacialSpellIDtoCooldown) do
			randomRacials[count] = racialSpelliD
			count = count + 1
		end
		
	end
end








function BattleGroundEnemies.ToggleTestmode()
	if BattleGroundEnemies.TestmodeActive then --disable testmode
		BattleGroundEnemies:DisableTestMode()
	else --enable Testmode
		BattleGroundEnemies:Show()
		BattleGroundEnemies:CreateTestdata()
		FakeEnemiesOnUpdateFrame:Show()
		BattleGroundEnemies.TestmodeActive = true
	end

end

function BattleGroundEnemies:DisableTestMode()
	FakeEnemiesOnUpdateFrame:Hide()
	self:Hide()
	self.TestmodeActive = false
end



local counter
function BattleGroundEnemies:FillEnemyData(amount, role)
	for i = 1, amount do
		local randomSpec = Data.RolesToSpec[role][math.random(1, #Data.RolesToSpec[role])]
		local classTag = randomSpec.classTag
		local specName = randomSpec.specName
		fakeEnemies["enemy"..counter.."-realm"..counter] = {
			Class = randomSpec.classTag,
			RoleNumber = Data.Classes[classTag][specName].roleNumber,
			SpecIcon = Data.Classes[classTag][specName].icon,
			TargetedByAlly = {},
		}
		counter = counter + 1
	end
end

local TestmodeRanOnce = false
function BattleGroundEnemies:CreateTestdata()
	if not TestmodeRanOnce then
		SetupTestmode()
		TestmodeRanOnce = true
	end
	
	wipe(fakeEnemies)
	
	wipe(harmfulPlayerSpells)
	local numTabs = GetNumSpellTabs()
	for i = 1, numTabs do
		local name, texture, offset, numSpells = GetSpellTabInfo(i)
		for j = 1, numSpells do
			local id = j + offset
			local spellName = GetSpellBookItemName(id, 'spell')
			local _, _, _, _, _, _, spellID = GetSpellInfo(spellName)
			if IsHarmfulSpell(id, 'spell') then
				local flags, providers, modifiedSpells = LibPlayerSpells:GetSpellInfo(spellID)
				if flags and bit.band(flags, LibPlayerSpells.constants.AURA) ~= 0 then -- This spell is an aura, do something meaningful with it.
					table.insert(harmfulPlayerSpells, spellID)
				end
			end
		end
	end

	for i = #self.EnemySortingTable, 1, -1 do
		local name = self.EnemySortingTable[i]
		local enemyButton = self.Enemies[name]
		self:RemoveEnemy(enemyButton, name)
	end
	
	
	if self.db.profile.EnemyCount_Enabled then
		if playerFaction == "Alliance" then -- enemy is Horde
			self.EnemyCount:SetText(format(PLAYER_COUNT_HORDE, 15))
		else --enemy is Alliance
			self.EnemyCount:SetText(format(PLAYER_COUNT_ALLIANCE, 15))
		end
	end
	
	
	local healerAmount = math.random(1, 3)
	local tankAmount = math.random(1, 2)
	local damagerAmount = 15 - healerAmount - tankAmount
	
	counter = 1
	self:FillEnemyData(healerAmount, "HEALER")
	self:FillEnemyData(tankAmount, "TANK")
	self:FillEnemyData(damagerAmount, "DAMAGER")
	
	for name, enemyDetails in pairs(fakeEnemies) do
		local enemyButton = self:GetEnemyButtonForNewPlayer()

		
		enemyButton.Spec.Icon:SetTexture(enemyDetails.SpecIcon)		


		local c = RAID_CLASS_COLORS[enemyDetails.Class]
		enemyButton.Health:SetStatusBarColor(c.r,c.g,c.b)
		enemyButton.Health:SetValue(1)	
		
		enemyDetails.DisplayedName = name
		if self.db.profile.ShowRealmnames then
			enemyButton.Name:SetText(enemyDetails.DisplayedName)
		else
			enemyButton.Name:SetText(enemyDetails.DisplayedName:match("[^%-]*"))
		end
		
		enemyButton:Show()
		enemyButton.PlayerDetails = enemyDetails
		
		table.insert(self.EnemySortingTable, name)
								
		self.Enemies[name] = enemyButton
	end
	
	self:SortEnemies()
end


do
	local holdsflag
	local targetCounts
	local TimeSinceLastOnUpdate = 0
	local UpdatePeroid = 1 --update every second
	
	function BattleGroundEnemies:TestOnUpdate(elapsed) --OnUpdate runs if the frame FakeEnemiesOnUpdateFrame is shown
		TimeSinceLastOnUpdate = TimeSinceLastOnUpdate + elapsed
		if TimeSinceLastOnUpdate > UpdatePeroid then
			local settings = BattleGroundEnemies.db.profile
		

			targetCounts = 0
			local hasFlag = false
			for name, enemyButton in pairs(BattleGroundEnemies.Enemies) do
				
				
				local number = math.random(1,10)
				--print("number", number)
				
				--print(enemyButton.ObjectiveAndRespawn.Cooldown:GetCooldownDuration())
				if enemyButton.ObjectiveAndRespawn.Cooldown:GetCooldownDuration() == 0 then --player is alive
					--print("test")
					
					--health simulation
					local health = math.random(0, 100)
					if health == 0 then --player died
						--print("dead")
						enemyButton.Health:SetValue(0)
						enemyButton.ObjectiveAndRespawn:ShowRespawnTimer(27)
					else
						enemyButton.Health:SetValue(health/100) --player still alive
						
						if settings.ObjectiveAndRespawn_ObjectiveEnabled then
							if number == 1 and not hasFlag then --this guy has a objective now
								
								-- hide old flag carrier
								local oldFlagholder = holdsflag
								if oldFlagholder then
									local enemyButtonObjective = oldFlagholder.ObjectiveAndRespawn
									
									enemyButtonObjective.AuraText:SetText("")
									enemyButtonObjective.Icon:SetTexture("")
									enemyButtonObjective:Hide()
								end
								
								
								
								
								--show new flag carrier
								local enemyButtonObjective = enemyButton.ObjectiveAndRespawn
								
								enemyButtonObjective.AuraText:SetText(math.random(1,9))
								enemyButtonObjective.Icon:SetTexture(GetSpellTexture(46392))
								enemyButtonObjective:Show()
								
								
								holdsflag = enemyButton
								hasFlag = true
							end
						end
						
						-- trinket simulation
						if number == 2 and enemyButton.Trinket.Cooldown:GetCooldownDuration() == 0 then -- trinket used
							local spellID = randomTrinkets[math.random(1, #randomTrinkets)] 
							if spellID ~= 214027 then --adapted
								if spellID == 196029 then--relentless
									enemyButton.Trinket:TrinketCheck(spellID, false)
								else
									enemyButton.Trinket:TrinketCheck(spellID, true)
								end
							end
						end
						
						--racial simulation
						if number == 3 and enemyButton.Racial.Cooldown:GetCooldownDuration() == 0 then -- racial used
							enemyButton:RacialUsed(randomRacials[math.random(1, #randomRacials)])
						end
						
						
						-- targetcounter simulation
						if targetCounts < 15 then
							local targetCounter = math.random(0,3)
							if targetCounts + targetCounter <= 15 then
								enemyButton.TargetCounter.Text:SetText(targetCounter)
							end
						end
						
						if number == 4 then --player got an diminishing CC applied
							--print("Nummber4")
							local dRCategory = randomDrCategory[math.random(1, #randomDrCategory)]
							local spellID = DrCategoryToSpell[dRCategory][math.random(1, #DrCategoryToSpell[dRCategory])]
							enemyButton:UpdateDR(spellID, false, true)

						end
						
						if number == 5 then --player got one of the players debuff's applied
							--print("Nummber5")
							local spellID = harmfulPlayerSpells[math.random(1, #harmfulPlayerSpells)]
							enemyButton:DebuffChanged(true, nil, spellID, true, true, math.random(1, 9), math.random(10, 15))
						end
						
						
					end		
				end
				if number == 6 then --toggle range
					if settings.RangeIndicator_Enabled then
						enemyButton:SetAlpha(enemyButton:GetAlpha() == 1 and settings.RangeIndicator_Alpha or 1)
					end
				end
			end
						
			TimeSinceLastOnUpdate = 0
		end
	end
	FakeEnemiesOnUpdateFrame:SetScript("OnUpdate", BattleGroundEnemies.TestOnUpdate)
end