local AddonName, Data = ...

local BattleGroundEnemies = BattleGroundEnemies

local MergeTable = MergeTable or function(destination, source)
	for k, v in pairs(source) do
		destination[k] = v;
	end
end

function BattleGroundEnemies:UpgradeDB(db)
    if not db.dbversion or db.dbversion < 1 then
        --[[         --in version 1 the format chagned from 
            
                db.profile.Enemies = {
                    ["5"] = { }
                    ["15"] = { }

                }

                to
                db.profile.Enemies.playerCountSettngs = {
                    {
                        minplayerCount = 1
                        maxplayerCount = 5
                    },

                    {
                        minplayerCount = 5
                        maxplayerCount = 15
                    },


                }
        ]]

        local maxSizes = {5, 15, 40}
        local minSizes = {1, 6, 16}

        local playerTypes = {"Allies", "Enemies"}

        for i = 1, #playerTypes do
            for j = 1, #maxSizes do
                local oldSettings = db.profile[playerTypes][tostring(maxSizes)]
                db.profile[playerTypes].playerCountSettings = db.profile[playerTypes].playerCountSettings or {}
                local newTable = {}
                MergeTable(newTable, oldSettings)
                newTable.minplayerCount = minSizes[i]
                newTable.maxplayerCount = maxSizes[i]
                table.insert(db.profile[playerTypes].playerCountSettings, newTable)
            end
        end

    end

    db.dbversion = 1
end