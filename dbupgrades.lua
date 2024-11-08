---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)

---@class BattleGroundEnemies
local BattleGroundEnemies = BattleGroundEnemies

local currentDBVersion = 2

local MergeTable = MergeTable or function(destination, source)
	for k, v in pairs(source) do
		destination[k] = v;
	end
end


--destination is the new db table which already has the new defaults in them
--just copy over the exsting settings without altering the structure of the destination table
local function MergeTableDeep(destination, source)
	for k, v in pairs(source) do
        if type(v) == "table" and type(destination[k]) == "table" then
            MergeTableDeep(destination[k], v)
        else
            if type(v) == type(destination[k]) then
                destination[k] = v;
            end
        end
	end
end

function BattleGroundEnemies:SetCurrentDbVerion(profile)
    profile.dbVersion = currentDBVersion
end

function BattleGroundEnemies:UpgradeProfile(profile, profileName)
    local didStuff = false
    local beSilent = not profile.dbVersion
    if not profile.dbVersion or profile.dbVersion < 1 then


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
                if profile[playerType] then
                    local oldSettings = profile[playerType][tostring(maxSizes[j])]
                    if oldSettings then

                        profile[playerType].playerCountConfigs = profile[playerType].playerCountConfigs or {}
                        profile[playerType].playerCountConfigs[j] = profile[playerType].playerCountConfigs[j] or {}

                        oldSettings.minPlayerCount = minSizes[j]
                        oldSettings.maxPlayerCount = maxSizes[j]

                        MergeTableDeep(profile[playerType].playerCountConfigs[j], oldSettings)
                        profile[playerType][tostring(maxSizes[j])] = nil
                        didStuff = true
                    end
                end
            end
        end
    end

    if not profile.dbVersion or profile.dbVersion < 2 then


        --[[         --in version 2 the format changed from 
            
             BattleGroundEnemies.db.profile.Font to BattleGroundEnemies.db.profile.Text.Font
        ]]

        C_Timer.After(20, function()
            if not beSilent then
                BattleGroundEnemies:Information("profile ".. profileName.." is not compatible with the current version of BattleGroundEnemies due to the fact that many options got merged into a single one its not possible to convert it. It will be reset to default settings")
            end

            BattleGroundEnemies.db:ResetProfile()
        end)

    end

    self:SetCurrentDbVerion(profile)

    if didStuff then
        C_Timer.After(20, function()
            if not beSilent then
                BattleGroundEnemies:Information("profile ".. profileName.." saved varaibles upgraded to new format")
            end
        end)
    end
    return didStuff
end

function BattleGroundEnemies:UpgradeProfiles(db)
    for profileName, profileData in pairs(db.profiles) do
        self:UpgradeProfile(profileData, profileName)
    end
end