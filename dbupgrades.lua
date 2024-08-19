local AddonName, Data = ...

local BattleGroundEnemies = BattleGroundEnemies

local MergeTable = MergeTable or function(destination, source)
	for k, v in pairs(source) do
		destination[k] = v;
	end
end

local function MergeTableDeep(destination, source)
	for k, v in pairs(source) do
        if type(v) == "table" then
            MergeTableDeep(destination[k], v)
        else
            destination[k] = v;
        end
	end
end

function BattleGroundEnemies:UpgradeDB(db)
    for profileName, profileData in pairs(db.profiles) do

        local didStuff = false
        if not profileData.dbVersion or profileData.dbVersion < 1 then


            --[[         --in version 1 the format chagned from 
                
                    db.profile.Enemies = {
                        ["5"] = { }
                        ["15"] = { }
    
                    }
    
                    to
                    db.profile.Enemies.playerCountSettngs = {
                        {
                            minPlayerCount = 1
                            maxPlayerCount = 5
                        },
    
                        {
                            minPlayerCount = 5
                            maxPlayerCount = 15
                        },
    
    
                    }
            ]]

            local maxSizes = {5, 15, 40}
            local minSizes = {1, 6, 16}

            local playerTypes = {"Allies", "Enemies"}

            for i = 1, #playerTypes do
                local playerType = playerTypes[i]
                for j = 1, #maxSizes do
                    if profileData[playerType] then
                        local oldSettings = profileData[playerType][tostring(maxSizes[j])]
                        if oldSettings then

                            profileData[playerType].playerCountConfig = profileData[playerType].playerCountConfig or {}

                            oldSettings.minPlayerCount = minSizes[j]
                            oldSettings.maxPlayerCount = maxSizes[j]

                            MergeTableDeep(profileData[playerType].playerCountConfig[j], oldSettings)
                            profileData[playerType][tostring(maxSizes[j])] = nil
                            didStuff = true
                        end
                    end
                end
            end
        end

        profileData.dbVersion = 1

        if didStuff then
            C_Timer.After(20, function()
                BattleGroundEnemies:Information("profile ".. profileName.."saved varaibles upgraded to new format")
            end)
        end
    end
end