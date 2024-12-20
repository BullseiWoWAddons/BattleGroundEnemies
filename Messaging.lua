---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)

---@class BattleGroundEnemies
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L

---@class BattleGroundEnemies: AceComm-3.0
LibStub("AceComm-3.0"):Embed(BattleGroundEnemies)


local CTimerNewTicker = C_Timer.NewTicker
local GetTime = GetTime
local max = math.max

local BGE_VERSION = "11.0.5.9"
local AddonPrefix = "BGE"
local versionQueryString, versionResponseString = "Q^%s^%i", "V^%s^%i"
local profileQueryString, profileResponseString = "PQ^%s", "PR^%s"
local targetCallVolunteerQueryString = "TVQ^%s" -- wil be send to all the viewers to show if you are volunteering vor target calling
local targetCallVolunteerResponseString = "TVR^%s"
local targetCallCallerQueryString = "TCQ" -- wil be send to all the viewers to show if you are volunteering vor target calling
local targetCallCallerResponseString = "TCV^%s" -- wil be send to all the viewers to show if you are volunteering vor target calling


local highestVersion = BGE_VERSION
local playerData = {}



local function generateStrings()
	versionQueryString = versionQueryString:format(BGE_VERSION, BattleGroundEnemies.db.profile.shareActiveProfile and 1 or 0)
	versionResponseString = versionResponseString:format(BGE_VERSION, BattleGroundEnemies.db.profile.shareActiveProfile and 1 or 0)
	return {
		vq = versionQueryString,
		vr = versionResponseString
	}
end

local function encodeProfileResponse(profile)
	local encoded = BattleGroundEnemies:ExportDataCompressed(profile, false)
	if not encoded then return end
	profileResponseString = profileResponseString:format(encoded)
	return profileResponseString
end

--[[
	targetcallilng, thoughts:
	The group leader can decice who the target caller will be
	the addon then automatically marks the target of the target caller with a raid icon (can be choosen from the menu) via SetRaidTarget()
	RAID_TARGET_UPDATE fires when a raid target changes.


	the addon then reacts to that and shows the icon on the playerbutton as well and notifies the player when the target changed.
]]

--[[
LE_PARTY_CATEGORY_HOME will query information about your "real" group -- the group you were in on your Home realm, before entering any instance/battleground.
LE_PARTY_CATEGORY_INSTANCE will query information about your "fake" group -- the group created by the instance/battleground matching mechanism.
 ]]
 local function IsFirstNewerThanSecond(versionString1, versionString2)
	--versionString can be "9.2.0.10" for example, another player can have "9.2.0.9"
	-- we cant make a simple comparison like "9.2.0.10" > "9.2.0.9" because this would result in false

	local firstVersion = {strsplit(".", versionString1)}
	local secondVersion = {strsplit(".", versionString2)}

	for i = 1, max(#firstVersion, #secondVersion) do
		local firstVersionNumber = tonumber(firstVersion[i]) or 0
		local secondVersionNumber = tonumber(secondVersion[i]) or 0

		if firstVersionNumber > secondVersionNumber then
			return true
		elseif firstVersionNumber < secondVersionNumber then --otherwise its equal and we compare the next table item
			return false
		end
	end
	return false --we didnt return anything yet since all numbers where equal, we are at the end of the arrays so both versions are equal
end


SLASH_BattleGroundEnemiesVersion1 = "/bgev"
SLASH_BattleGroundEnemiesVersion2 = "/BGEV"
SlashCmdList.BattleGroundEnemiesVersion = function()
	if not IsInGroup() then
		BattleGroundEnemies:Information(L.MyVersion, BGE_VERSION)
		return
	end

	local function coloredNameVersion(allyButton, version)
		local coloredName = BattleGroundEnemies:GetColoredName(allyButton)
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


	--loop through all of the BattleGroundEnemies.Allies.Players to find out which one of them send us their addon version
	local t, v
	for allyName, allyButton in pairs(BattleGroundEnemies.Allies.Players) do
		t, v = results.none, ""
		if playerData[allyName] then
			if IsFirstNewerThanSecond(highestVersion, playerData[allyName].version) then
				t = results.old
			else
				t = results.current
			end
			v = playerData[allyName].version
		end
		table.insert(t, coloredNameVersion(allyButton, v))
	end


	for state, names in pairs(results) do
		if #names> 0 then
			BattleGroundEnemies:Information(texts[state]..":", table.concat(names, ", "))
		end
	end
end

local timers = {}
--[[
  we use timers to broadcast information, we do this because it may happen that
many players request the same information in a short time due to
 ingame events like GROUP_ROSTER_UPDATE, this way we only send out the information
once when requested in a 3 second time frame, every new request resets the timer
 ]]


function BattleGroundEnemies:QueryVersions(channel)
	BattleGroundEnemies:SendCommMessage(AddonPrefix, generateStrings().vq, channel)
end

-- function BattleGroundEnemies:QueryTargetCallVolunteers(channel)
--     SendAddonMessage(AddonPrefix, targetCallVolunteerQueryString:format(iWantToDoTargetcalling and "y" or "n"), channel)
-- end

-- function BattleGroundEnemies:QueryTargetCallCaller(channel)
--     SendAddonMessage(AddonPrefix, targetCallCallerQueryString, channel)
-- end


-- --broadcast teh target caller to everyone
-- function BattleGroundEnemies:BroadcastTargetCaller()
--     if self.Allies.TargetCaller then
--         if timers.BroadcastTargetCaller then timers.BroadcastTargetCaller:Cancel() end
--         timers.BroadcastTargetCaller = CTimerNewTicker(3, function()
--             if IsInGroup() then
--                 SendAddonMessage(AddonPrefix, targetCallVolunteerResponseString:format(self.Allies.TargetCaller.GUID), IsInGroup(2) and "INSTANCE_CHAT" or "RAID")
--             end
--             timers.BroadcastTargetCaller = nil
--         end, 1)
--     end
-- end


local wasInGroup = nil
function BattleGroundEnemies:RequestEverythingFromGroupmembers()

	local groupType = (IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and 3) or (IsInRaid() and 2) or (IsInGroup() and 1)
	if (not wasInGroup and groupType) or (wasInGroup and groupType and wasInGroup ~= groupType) then
		wasInGroup = groupType
	   -- local iWantToDoTargetcalling = self.db.profile.targetCallingVolunteer
		local channel = groupType == 3 and "INSTANCE_CHAT" or "RAID"
		--self:QueryTargetCallCaller(channel)
		--self:QueryTargetCallVolunteers(channel)
		self:QueryVersions(channel)

	elseif wasInGroup and not groupType then
		wasInGroup = nil
		playerData = {}
	end
end

function BattleGroundEnemies:ProfileReceived(sender, data)
	if type(data) ~= "table" then return end
	playerData[sender] = playerData[sender] or {}
	data.receivedAt = GetTime()
	playerData[sender].profileData = data
end

function BattleGroundEnemies:SendCurrentProfileTo(sender)
	local encoded = encodeProfileResponse({version = BGE_VERSION, profile = BattleGroundEnemies.db.profile})
	if not encoded then return end
	BattleGroundEnemies:SendCommMessage(AddonPrefix, encoded, IsInGroup(2) and "INSTANCE_CHAT" or "RAID")
end

function BattleGroundEnemies:UpdatePlayerData(sender, prefix, version, profileSharingEnabled)
	if prefix == "Q" then
		if timers.VersionCheck then timers.VersionCheck:Cancel() end
		timers.VersionCheck = CTimerNewTicker(3, function()
			if IsInGroup() then
				BattleGroundEnemies:SendCommMessage(AddonPrefix, generateStrings().vr, IsInGroup(2) and "INSTANCE_CHAT" or "RAID") -- LE_PARTY_CATEGORY_INSTANCE = 2
			end
			timers.VersionCheck = nil
		end, 1)
	end
	if prefix == "V" or prefix == "Q" then -- V = version response, Q = version query
		playerData[sender] = playerData[sender] or {}
		if version then
			playerData[sender].version = version
			if IsFirstNewerThanSecond(version, highestVersion) then

				if timers.outdatedTimer then timers.outdatedTimer:Cancel() end
				timers.outdatedTimer = CTimerNewTicker(3, function()
					BattleGroundEnemies:OnetimeInformation(L.NewVersionAvailable..": ", highestVersion)
					timers.outdatedTimer = nil
				end, 1)

				highestVersion = version
			end
		end
		if profileSharingEnabled then
			profileSharingEnabled = profileSharingEnabled == "1" and true or false
			playerData[sender].profileSharingEnabled = profileSharingEnabled
		end
	end
end


-- function BattleGroundEnemies:UpdateTargetCallingVolunteers(sender, prefix, message)
--     if prefix == "TVQ" then
--         if timers.targetCallingVolunteering then timers.targetCallingVolunteering:Cancel() end
--         timers.targetCallingVolunteering = CTimerNewTicker(3, function()
--             SendAddonMessage(AddonPrefix, targetCallVolunteerResponseString:format(self.db.profile.targetCallingVolunteer and "y" or "n"), IsInGroup(2) and "INSTANCE_CHAT" or "RAID")
--             timers.targetCallingVolunteering = nil
--         end, 1)
--     end
--     BattleGroundEnemies.TargetCalllingVolunteers[sender] = message == "y" and true or false
-- end

-- function BattleGroundEnemies:UpdateTargetCallingCallers(prefix, sender, message)
--     if prefix == "TCQ" then
--         -- when we query the taret caller we only save the Targetcaller when its send by the group leader

--         if self.PlayerDetails.isGroupLeader then -- i am the groupleader
--             self:BroadcastTargetCaller()
--         end
--     end
--     if sender == self.Allies.groupLeader then
--         self:Information(message == UnitGUID("player") and YOU or message, L.TargetCallerUpdated)
--         BattleGroundEnemies.Allies.TargetCaller = self.Allies.GuidToGroupMember[message]
--     end
-- end

function BattleGroundEnemies:CHAT_MSG_ADDON(addonPrefix, message, channel, sender)  --the sender always contains the realm of the player, even when from same realm
	if addonPrefix ~= AddonPrefix then return end
	if (channel == "RAID" or channel == "PARTY" or channel == "INSTANCE_CHAT") then

		sender = Ambiguate(sender, "none")
		local msgPrefix, version, profileSharingEnabled = strsplit("^", message) --try if there is already a msgPrefix and version, if so we got old addon version response

		if msgPrefix == "V" or msgPrefix == "Q" then
			--info 2 is whether or not that player got profile sharing enabled
			self:UpdatePlayerData(sender, msgPrefix, version, profileSharingEnabled)
	 end
	elseif channel == "WHISPER" then
		local decoded = BattleGroundEnemies:DecodeReceivedData(message, false)
		if not decoded then return end

		local msgPrefix, info1, info2 = strsplit("^", message)
		if not info1 then return end

		if msgPrefix == "PQ" then
			local requestFromPlayerName = Ambiguate(info1, "none")  -- name of the player he wants that profile from

			if requestFromPlayerName == BattleGroundEnemies.UserDetails.PlayerName and BattleGroundEnemies.db.profile.shareActiveProfile then --sender wants my profile
				self:SendCurrentProfileTo(sender)
			end
		elseif msgPrefix == "PR" then --someone send us their profile
			self:ProfileReceived(sender, info1)
		end
	end
end

--C_ChatInfo.RegisterAddonMessagePrefix(AddonPrefix)

BattleGroundEnemies:RegisterComm(AddonPrefix, "CHAT_MSG_ADDON")





--/run test = {"9.0.7.5", "9.2.7.5", "9.2.7.4"}; table.sort(test); for i =1, #test do print(test[i])end
-- sortiert aufsteigent