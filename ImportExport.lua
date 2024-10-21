---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)
---@class BattleGroundEnemies
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L

local AceGUI = LibStub("AceGUI-3.0")
local LibDeflate = LibStub("LibDeflate")
local LibSerialize = LibStub("LibSerialize")


local ButtonFrameTemplate_HidePortrait = ButtonFrameTemplate_HidePortrait
local CreateFrame = CreateFrame

local CopyTable = CopyTable or function(settings, shallow)
	local copy = {};
	for k, v in pairs(settings) do
		if type(v) == "table" and not shallow then
			copy[k] = CopyTable(v);
		else
			copy[k] = v;
		end
	end
	return copy;
end



local MergeTable = MergeTable or function(destination, source)
	for k, v in pairs(source) do
		destination[k] = v;
	end
end

local frameShown
function BattleGroundEnemies:CreateAceGUIImportExportFrame(mode)
	---@class AceGUI: AceGUIFrame
	local frame = AceGUI:Create("Frame")
	frame:EnableResize(false)
	frame:SetTitle("Example Frame")
	local text
	if mode == "Import" then
		text = L.ImportTextMessage
	else
		text = L.ExportTextMessage
	end
	frame:SetStatusText(text)
	frame:SetCallback("OnClose", function(widget)
		frameShown = false
		AceGUI:Release(widget)
	end)
	frame:SetLayout("Flow")

	---@class editbox: AceGUIMultiLineEditBox
	local editbox = AceGUI:Create("MultiLineEditBox")
	editbox:SetFullWidth(true)
	editbox:SetHeight(380)


	frame:AddChild(editbox)
	frame.EditBox = editbox

	if mode == "Import" then
		editbox:SetCallback("OnEnterPressed", function(widget, callbackName, text)
			frame:SetUserData("input", text)
			if text and text ~= "" then
				frame.ImportButton:SetDisabled(false)
			else
				frame.ImportButton:SetDisabled(true)
			end
		end)
		editbox:SetCallback("OnTextChanged", function(widget, callbackName, text)
			frame.ImportButton:SetDisabled(true)
		end)

		---@class importButton: AceGUIButton
		local importButton = AceGUI:Create("Button")
		importButton:SetWidth(200)

		importButton:SetCallback("OnClick", function(widget, ...)
			if frame:GetUserData("mode") == "Import" then
				local stringg = frame:GetUserData("input")
				if not stringg or stringg == "" then
					return BattleGroundEnemies:Information("Empty input, please enter a exported string here.")
				end
				local data, error = BattleGroundEnemies:DecodeReceivedData(stringg, true)
				if error then return BattleGroundEnemies:Information(error) end
				MergeTable(BattleGroundEnemies.db.profile, data)

				BattleGroundEnemies:NotifyChange()
			end
			frame:Hide()
		end)

		frame:AddChild(importButton)
		frame.ImportButton = importButton
	end



	return frame
end

function BattleGroundEnemies:ImportExportFrameSetupForMode(mode, exportString)
	if frameShown and self.ImportExportFrame then
		self.ImportExportFrame:Release()
	end
	frameShown = true
	self.ImportExportFrame = BattleGroundEnemies:CreateAceGUIImportExportFrame(mode)

	self.ImportExportFrame:SetTitle(AddonName..": "..mode)
	--self.ImportExportFrame:SetStatusText("AceGUI-3.0 Example Container Frame")
	if mode == "Import" then
		self.ImportExportFrame.EditBox:SetLabel(L.InsertExportedStringHere)
		self.ImportExportFrame.EditBox:SetText("")
		self.ImportExportFrame.ImportButton:SetText(L.Import)
	else
		self.ImportExportFrame.EditBox:SetLabel(L.ImportEditBoxLabel)
		self.ImportExportFrame.EditBox:SetText(exportString)
		self.ImportExportFrame.EditBox:HighlightText()
	end
	self.ImportExportFrame.EditBox:SetFocus()
	self.ImportExportFrame.EditBox:SetHeight(380)
	self.ImportExportFrame:SetUserData("mode", mode)
	self.ImportExportFrame:DoLayout()
end


function BattleGroundEnemies:ExportDataCompressed(data, forPrint)
	local serialized = LibSerialize:Serialize(data)
	if not serialized then return false, "An serialization error happened" end

	local compressed = LibDeflate:CompressDeflate(serialized)
	if not compressed then return false, "An compression error happened" end

	local encoded
	if forPrint then
		encoded = LibDeflate:EncodeForPrint(compressed)
	else
		encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
	end
	if not encoded then return false, "An encoding error happened" end
	return encoded
end


function BattleGroundEnemies:DecodeReceivedData(encoded, fromPrint)
	local decoded
	if fromPrint then
		decoded = LibDeflate:DecodeForPrint(encoded)
	else
		decoded = LibDeflate:DecodeForWoWAddonChannel(encoded)
	end
	if not decoded then return false, "An decoding error happened" end
	local decompressed = LibDeflate:DecompressDeflate(decoded)
    if not decompressed then return false, "An decompressing error happened" end

    local success, data = LibSerialize:Deserialize(decompressed)
    if not success then return false, "An decompressing error happened" end
	return data
end

function BattleGroundEnemies:ExportButtonPressed()
	local data, error = self:ExportDataCompressed(self.db.profile, true)
	if error then
		return self:Information(error)
	end
	self:ImportExportFrameSetupForMode("Export", data)
end