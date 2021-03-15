local addonName, Data = ...
local BattleGroundEnemies = BattleGroundEnemies
local L = LibStub("AceLocale-3.0"):GetLocale("BattleGroundEnemies")


local CTimerNewTicker = C_Timer.NewTicker
local SendAddonMessage = C_ChatInfo.SendAddonMessage
BattleGroundEnemies.Objects.DR = {}

local BGE_VERSION = "9.0.2.8"
local AddonPrefix = "BGE"
local versionQueryString, versionResponseString = "Q^%s", "V^%s"
local targetCallVolunteerString = "TV^%s" -- wil be send to all the viewers to show if you are volunteering vor target calling
local targetCallDecisionString = "TD^%s" -- wil be send to all the viewers to show if you are volunteering vor target calling

local highestVersion = BGE_VERSION
local versions = {}

versionQueryString = versionQueryString:format(BGE_VERSION)
versionResponseString = versionResponseString:format(BGE_VERSION)

BattleGroundEnemies:RegisterEvent("CHAT_MSG_ADDON")

C_ChatInfo.RegisterAddonMessagePrefix(AddonPrefix)



--[[
    targetcallilng, thoughts:
    The group leader can decice who the target caller will be

    people can choose if they want to be a target caller via the interface, this message will be sent to the other players, SendAddonMessage
    then all the other people can see who would volunteer for target calling,
        the group leader can then choose who should be the target caller, his decission will be sent to everyone SendAddonMessage
            then all the clients can display the target calelrs target on the unitframe
]]

--[[ 
LE_PARTY_CATEGORY_HOME will query information about your "real" group -- the group you were in on your Home realm, before entering any instance/battleground.
LE_PARTY_CATEGORY_INSTANCE will query information about your "fake" group -- the group created by the instance/battleground matching mechanism.
 ]]

SLASH_BattleGroundEnemiesVersion1 = "/bgev"
SLASH_BattleGroundEnemiesVersion2 = "/BGEV"
SlashCmdList.BattleGroundEnemiesVersion = function()
	if not IsInGroup() then
        BattleGroundEnemies:Information(L.MyVersion, BGE_VERSION)
		return
	end

	local function coloredNameVersion(playerDetails, version)
        local coloredName = BattleGroundEnemies.GetColoredName(playerDetails)
		if version ~= "" then
			version = ("|cFFCCCCCC(%s%s)|r"):format(version, "") 
		end
		return (coloredName..version)
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


    --loop through all of the BattleGroundEnemies.Allies.groupMembers to find out which one of them send us their addon version
    for name, details in pairs(BattleGroundEnemies.Allies.groupMembers) do
  
        if versions[name] then
            if versions[name] < highestVersion then
                results.old[#results.old+1] = coloredNameVersion(details, versions[name])
            else
                results.current[#results.current+1] = coloredNameVersion(details, versions[name])  
            end
        else
            results.none[#results.none+1] = coloredNameVersion(details, "")        
        end
    end

    for k,v in pairs(results) do
        if #v> 0 then
            BattleGroundEnemies:Information(texts[k]..":", unpack(v))
        end
    end
end


local responseTimer = nil
local outdatedTimer = nil

local wasInGroup = nil
function BattleGroundEnemies:SendMessagesOnGroupUpdate()
    local iWantToDoTargetcalling = self.db.profile.targetCallingVolunteer
    local groupType = (IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and 3) or (IsInRaid() and 2) or (IsInGroup() and 1)
    if (not grouped and groupType) or (grouped and groupType and grouped ~= groupType) then
        wasInGroup = groupType
        SendAddonMessage(AddonPrefix, versionQueryString, groupType == 3 and "INSTANCE_CHAT" or "RAID")
        SendAddonMessage(AddonPrefix, targetCallVolunteerString:format(iWantToDoTargetcalling and "y" or "n"), groupType == 3 and "INSTANCE_CHAT" or "RAID")
    elseif wasInGroup and not groupType then
        wasInGroup = nil
        versions = {}
    end
end

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
                    BattleGroundEnemies:Information(L.NewVersionAvailable)
                    outdatedTimer = nil
                end, 1)
            end
        end
    end
end


function BattleGroundEnemies:SetTargetCallingVolunteer(sender, message)
    BattleGroundEnemies.TargetCalllingVolunteers[sender] = message == "y" and true or false
end


function BattleGroundEnemies:CHAT_MSG_ADDON(addonPrefix, message, channel, sender)  --the sender always contains the realm of the player, even when from same realm
	if channel ~= "RAID" and channel ~= "PARTY" and channel ~= "INSTANCE_CHAT" or addonPrefix ~= AddonPrefix then return end
	
    local msgPrefix, msg = strsplit("^", message)
    sender = Ambiguate(sender, "none")
    if msgPrefix == "V" or msgPrefix == "Q" then
        self:VersionCheck(msgPrefix, msg, sender)
    end
    if msgPrefix == "TV" then
        self:SetTargetCallingVolunteer(sender, msg)
    end
    if msgPrefix == "TD" then
        -- msg contains the GUID of the targetcaller selected by the grupleader
        --check if sender is raid leader
        if sender == groupleader then
            self:Information(msg == UnitGUID("player") and YOU or msg, L.TargetCallerUpdated)
            BattleGroundEnemies.TargetCaller = self.Allies.GuidToGroupMember[msg]
        end
    end
end




--/run test = {"9.0.7.5", "9.2.7.5", "9.2.7.4"}; table.sort(test); for i =1, #test do print(test[i])end
-- sortiert aufsteigent 