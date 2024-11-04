---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)
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
                    BattleGroundEnemies:OnetimeInformation("Missing localizations for your ingame language. You can help translating this addon on https://www.curseforge.com/wow/addons/battlegroundenemies/localization")
                end)
                missingReported = true
            end
            --t[k] = defaultLocale[k] --add it to the table so we dont have to invoce the metatable in the future
            return defaultLocale[k]
        else
            C_Timer.After(3, function()
                BattleGroundEnemies:OnetimeDebug("Missing localization entry for['"..k.."']. Please report this to the addon author.")
            end)
            return k
        end
    end
})

local L = defaultLocale --set to L for curseforges system

--@localization(locale="enUS", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@

L = Data.L;

if LOCALE_deDE then
--@localization(locale="deDE", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
elseif LOCALE_esES or LOCALE_esMX then
--@localization(locale="esES", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
elseif LOCALE_frFR then
--@localization(locale="frFR", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
elseif LOCALE_itIT then
--@localization(locale="itIT", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
elseif LOCALE_koKR then
--@localization(locale="koKR", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
elseif LOCALE_ptBR or LOCALE_ptPT then
--@localization(locale="ptBR", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
elseif LOCALE_ruRU then
--@localization(locale="ruRU", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
elseif LOCALE_zhCN then
--@localization(locale="zhCN", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
elseif LOCALE_zhTW then
--@localization(locale="zhTW", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
end