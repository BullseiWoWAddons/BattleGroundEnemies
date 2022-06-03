local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")

local function SerializeAndCompress(data)
	local serialized = LibSerialize:Serialize(data)
	local compressed = LibDeflate:CompressDeflate(serialized)
	return compressed
end

local function DecompressAndDeserialize(decoded)
	if not decoded then
		return BattleGroundEnemies:Information("An decoding error happened")
	end
	local decompressed = LibDeflate:DecompressDeflate(decoded)
    if not decompressed then
		return BattleGroundEnemies:Information("An decompressing error happened")
	end
    local success, data = LibSerialize:Deserialize(decompressed)
    if not success then 
		return BattleGroundEnemies:Information("An deserialization error happened")
	end
	return data
end

-- With compression (recommended):
function BattleGroundEnemies:TransmitAddonMessageData(data)
    local compressed = SerializeAndCompress(data)
    local encoded = LibDeflate:EncodeForPrint(compressed)
    self:SendCommMessage("MyPrefix", encoded, "WHISPER", UnitName("player"))
end

function BattleGroundEnemies:ReceiveAddonMessageData(prefix, payload, distribution, sender)
	local data DecompressAndDeserialize(LibDeflate:DecodeForWoWAddonChannel(payload))
	if not data then return end
    -- Handle `data`
end



function BattleGroundEnemies:TransmitPrintData(data)
    local compressed = SerializeAndCompress(data)
	local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
    self:SendCommMessage("MyPrefix", encoded, "WHISPER", UnitName("player"))
end



function BattleGroundEnemies:ReceivePrintData(string)
    local data DecompressAndDeserialize(LibDeflate:DecodeForPrint(string))
	if not data then return end

    -- Handle `data`
end