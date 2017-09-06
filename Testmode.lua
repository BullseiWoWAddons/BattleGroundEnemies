local addonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies

local LibRaces = LibStub("LibRaces-1.0")
local DRData = LibStub("DRData-1.0")
local LibPlayerSpells = LibStub("LibPlayerSpells-1.0")


local mathrandom = math.random
local tinsert = table.insert


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
		tinsert(DrCategoryToSpell[categorieName], spellID)
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

function BattleGroundEnemies.ToggleTestmodeOnUpdate()
	FakeEnemiesOnUpdateFrame:SetShown(not FakeEnemiesOnUpdateFrame:IsShown())
end

function BattleGroundEnemies.ToggleTestmode()
	if BattleGroundEnemies.TestmodeActive then --disable testmode
		BattleGroundEnemies:DisableTestMode()
	else --enable Testmode
		BattleGroundEnemies.TestmodeActive = true
		BattleGroundEnemies:EnableTestMode()
	end
end

function BattleGroundEnemies:DisableTestMode()
	FakeEnemiesOnUpdateFrame:Hide()
	self:Hide()
	self.TestmodeActive = false
end

do
	local counter
	
	
	function BattleGroundEnemies:FillFakeEnemyData(amount, role)
		for i = 1, amount do
			local randomSpec = Data.RolesToSpec[role][mathrandom(1, #Data.RolesToSpec[role])]
			local classTag = randomSpec.classTag
			local specName = randomSpec.specName
			local name = "Enemy"..counter.."-Realm"..counter
			fakeEnemies[name] = {
				PlayerClass = classTag,
				PlayerName = name,
				PlayerSpec = specName
			}
			counter = counter + 1
		end
	end

	local TestmodeRanOnce = false
	function BattleGroundEnemies:EnableTestMode()
		self:Show()

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
						tinsert(harmfulPlayerSpells, spellID)
					end
				end
			end
		end

		for i = #self.EnemySortingTable, 1, -1 do
			local name = self.EnemySortingTable[i]
			self:RemoveEnemy(name)
		end
		
		
		if self.db.profile.EnemyCount_Enabled then
			if playerFaction == "Alliance" then -- enemy is Horde
				self.EnemyCount:SetText(format(PLAYER_COUNT_HORDE, 15))
			else --enemy is Alliance
				self.EnemyCount:SetText(format(PLAYER_COUNT_ALLIANCE, 15))
			end
		end
		
		
		local healerAmount = mathrandom(1, 3)
		local tankAmount = mathrandom(1, 2)
		local damagerAmount = 15 - healerAmount - tankAmount
		
		counter = 1
		self:FillFakeEnemyData(healerAmount, "HEALER")
		self:FillFakeEnemyData(tankAmount, "TANK")
		self:FillFakeEnemyData(damagerAmount, "DAMAGER")
		
		for name, enemyDetails in pairs(fakeEnemies) do
			local enemyButton = self:SetupButtonForNewPlayer(enemyDetails)
			
			tinsert(self.EnemySortingTable, name)					
			self.Enemies[name] = enemyButton
		end
		
		self:SortEnemies()
		
		FakeEnemiesOnUpdateFrame:Show()
	end
end


do
	local holdsflag
	local TimeSinceLastOnUpdate = 0
	local UpdatePeroid = 1 --update every second
	
	function BattleGroundEnemies:TestOnUpdate(elapsed) --OnUpdate runs if the frame FakeEnemiesOnUpdateFrame is shown
		TimeSinceLastOnUpdate = TimeSinceLastOnUpdate + elapsed
		if TimeSinceLastOnUpdate > UpdatePeroid then
			local settings = BattleGroundEnemies.db.profile
		

			local targetCounts = 0
			local hasFlag = false
			for name, enemyButton in pairs(BattleGroundEnemies.Enemies) do
				
				
				local number = mathrandom(1,10)
				--self:Debug("number", number)
				
				--self:Debug(enemyButton.ObjectiveAndRespawn.Cooldown:GetCooldownDuration())
				if not enemyButton.ObjectiveAndRespawn.ActiveRespawnTimer then --player is alive
					--self:Debug("test")
					
					--health simulation
					local health = mathrandom(0, 100)
					if health == 0 and holdsflag ~= enemyButton then --don't let players die that are holding a flag at the moment
						--BattleGroundEnemies:Debug("dead")
						enemyButton.Health:SetValue(0)
						enemyButton:UnitIsDead(27)
					else
						enemyButton.Health:SetValue(health/100) --player still alive
						
						if number == 1 and not hasFlag and settings.ObjectiveAndRespawn_ObjectiveEnabled then --this guy has a objective now
						
				
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
							
							enemyButtonObjective.AuraText:SetText(mathrandom(1,9))
							enemyButtonObjective.Icon:SetTexture(GetSpellTexture(46392))
							enemyButtonObjective:Show()
							
							
							holdsflag = enemyButton
							hasFlag = true
						
						-- trinket simulation
						elseif number == 2 and enemyButton.Trinket.Cooldown:GetCooldownDuration() == 0 then -- trinket used
							local spellID = randomTrinkets[mathrandom(1, #randomTrinkets)] 
							if spellID ~= 214027 then --adapted
								if spellID == 196029 then--relentless
									enemyButton.Trinket:TrinketCheck(spellID, false)
								else
									enemyButton.Trinket:TrinketCheck(spellID, true)
								end
							end
						--racial simulation
						elseif number == 3 and enemyButton.Racial.Cooldown:GetCooldownDuration() == 0 then -- racial used
							enemyButton:RacialUsed(randomRacials[mathrandom(1, #randomRacials)])
						elseif number == 4 then --player got an diminishing CC applied
							--self:Debug("Nummber4")
							local dRCategory = randomDrCategory[mathrandom(1, #randomDrCategory)]
							local spellID = DrCategoryToSpell[dRCategory][mathrandom(1, #DrCategoryToSpell[dRCategory])]
							enemyButton:UpdateDR(spellID, nil, false, true)
						elseif number == 5 then --player got one of the players debuff's applied
							--self:Debug("Nummber5")
							local spellID = harmfulPlayerSpells[mathrandom(1, #harmfulPlayerSpells)]
							enemyButton:DebuffChanged(true, nil, spellID, nil, true, true, mathrandom(1, 9), mathrandom(10, 15))
							enemyButton:UpdateDR(spellID, nil, true, true)
						elseif number == 6 then --power simulation
							local power = mathrandom(0, 100)
							enemyButton.Power:SetValue(power/100)
						end
						
						-- targetcounter simulation
						if targetCounts < 15 then
							local targetCounter = mathrandom(0,3)
							if targetCounts + targetCounter <= 15 then
								enemyButton.NumericTargetindicator:SetText(targetCounter)
							end
						end
					end		
				end
				if number == 6 then --toggle range
					if settings.RangeIndicator_Enabled then
						enemyButton:UpdateRange((enemyButton.RangeIndicator_Frame:GetAlpha() ~= 1) and true or false)
					end
				end
			end
						
			TimeSinceLastOnUpdate = 0
		end
	end
	FakeEnemiesOnUpdateFrame:SetScript("OnUpdate", BattleGroundEnemies.TestOnUpdate)
end
