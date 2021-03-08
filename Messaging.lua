local addonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local L = LibStub("AceLocale-3.0"):GetLocale("BattleGroundEnemies")


local CTimerNewTicker = C_Timer.NewTicker
local SendAddonMessage = C_ChatInfo.SendAddonMessage
BattleGroundEnemies.Objects.DR = {}

local BGE_VERSION = "9.0.2.8"
local AddonPrefix = "BGE"
local versionQueryString, versionResponseString = "Q^%s", "V^%s"
local versions = {} --
local highestVersion = BGE_VERSION

versionQueryString = versionQueryString:format(BGE_VERSION)
versionResponseString = versionResponseString:format(BGE_VERSION)

BattleGroundEnemies:RegisterEvent("CHAT_MSG_ADDON")
BattleGroundEnemies:RegisterEvent("GROUP_ROSTER_UPDATE")

C_ChatInfo.RegisterAddonMessagePrefix(AddonPrefix)




SLASH_BattleGroundEnemiesVersion1 = "/bgev"
SLASH_BattleGroundEnemiesVersion2 = "/BGEV"
SlashCmdList.BattleGroundEnemiesVersion = function()
	if not IsInGroup() then
        BattleGroundEnemies:Information("You are using Version", BGE_VERSION)
		return
	end

	local function coloredNameVersion(name, version)
		if not version then
			version = ""
        else
			version = ("|cFFCCCCCC(%s%s)|r"):format(version, "") 
		end

		local _, class = UnitClass(name)
		local tbl = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class] or GRAY_FONT_COLOR
		return ("|cFF%02x%02x%02x%s|r%s"):format(tbl.r*255, tbl.g*255, tbl.b*255, name, version)
	end

    local groupMembers = {}

    

    local unitIDPrefix
    if IsInRaid() then
        unitIDPrefix = "raid"
    else
        groupMembers[1] = UnitName("player") --the player does not get a party unitID but he gets assigned a raid unitID
        unitIDPrefix = "party"
    end



    for i = 1, GetNumGroupMembers() do -- the player itself only shows up here when he is in a raid
        local name, realm = UnitName(unitIDPrefix..i)
       
        if name then
            if realm then 
                name = name.."-"..realm
            end
            groupMembers[#groupMembers + 1] = name
        end
    end


    local results = {
        current = {},  --users of the current version
        old = {},-- users of an old version
        none = {} -- no BGE detected
    }
    local texts = {
        current = L.CurrentVersion,
        old = L.OldVersion,
        none = L.NoVersion
    }


    --loop through all of the groupMembers to find out which one of them send us their addon version
    for i = 1, #groupMembers do
        local name = groupMembers[i]
  
        if versions[name] then
            if versions[name] < highestVersion then
                results.old[#results.old+1] = coloredNameVersion(name, versions[name])
            else
                results.current[#results.current+1] = coloredNameVersion(name, versions[name])  
            end
        else
            results.none[#results.none+1] = coloredNameVersion(name, versions[name])        
        end
    end

    for k,v in pairs(results) do
        if #v> 0 then
            BattleGroundEnemies:Information(texts[k]..":", unpack(v))
        end
    end
end





local grouped = nil
function BattleGroundEnemies:GROUP_ROSTER_UPDATE()
    local groupType = (IsInGroup(2) and 3) or (IsInRaid() and 2) or (IsInGroup() and 1) -- LE_PARTY_CATEGORY_INSTANCE = 2
    if (not grouped and groupType) or (grouped and groupType and grouped ~= groupType) then
        grouped = groupType
        SendAddonMessage(AddonPrefix, versionQueryString, groupType == 3 and "INSTANCE_CHAT" or "RAID")
    elseif grouped and not groupType then
        grouped = nil
        versions = {}
    end
end





local responseTimer = nil
local outdatedTimer = nil


function BattleGroundEnemies:VersionCheck(prefix, version, sender)
    if prefix == "Q" then
        if responseTimer then responseTimer:Cancel() end
        responseTimer = CTimerNewTicker(3, function() 
            if IsInGroup() then
                SendAddonMessage(AddonPrefix, versionResponseString, IsInGroup(2) and "INSTANCE_CHAT" or "RAID") -- LE_PARTY_CATEGORY_INSTANCE = 2
            end
            responseTimer = nil
        end, 1)
    end
    if prefix == "V" or prefix == "Q" then -- V = version response, Q = version query
        if version then
            versions[sender] = version
            if version > highestVersion then highestVersion = version end

            if version > BGE_VERSION then
                if outdatedTimer then outdatedTimer:Cancel() end
                outdatedTimer = CTimerNewTicker(3, function() 
                    BattleGroundEnemies:Information("A newer version is available.")
                    outdatedTimer = nil
                end, 1)
            end
        end
    end
end


function BattleGroundEnemies:CHAT_MSG_ADDON(addonPrefix, message, channel, sender)
	if channel ~= "RAID" and channel ~= "PARTY" and channel ~= "INSTANCE_CHAT" and addonPrefix == AddonPrefix then return end
	
    local msgPrefix, msg = strsplit("^", message)
    sender = Ambiguate(sender, "none")
    if msgPrefix == "V" or msgPrefix == "Q" then
        self:VersionCheck(msgPrefix, msg, sender)
    end
end


--/run test = {"9.0.7.5", "9.2.7.5", "9.2.7.4"}; table.sort(test); for i =1, #test do print(test[i])end
-- sortiert aufsteigent 