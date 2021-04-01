local addonName, Data = ...
local defaultLocale = {}


local gameLocale = GetLocale()
if gameLocale == "enGB" then
	gameLocale = "enUS"
end

local errorReported, missingReported = false, false

Data.L = setmetatable({}, { --key set by all non english clients, Table gets accessed to read translations
    __index = function(t, k)  -- t is the normal table (no metatable)
        if defaultLocale[k] then
            if gameLocale ~= "enUS" and not missingReported then
                C_Timer.After(3, function() 
                    BattleGroundEnemies:Information("Missing localizations for your ingame language. You can help translating this addon on https://www.curseforge.com/wow/addons/battlegroundenemies/localization")
                end)
                missingReported = true
            end
            --t[k] = defaultLocale[k] --add it to the table so we dont have to invoce the metatable in the future
            return defaultLocale[k]
        else
            C_Timer.After(3, function() 
                BattleGroundEnemies:Information("Missing localization entry for['"..k.."']. Please report this to the addon author.")
            end)
            return k
        end
    end
})

local L = defaultLocale --set to L for curseforges system

--@localization(locale="enUS", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@