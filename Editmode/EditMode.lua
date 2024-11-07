---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)

---@class BattleGroundEnemies
local BattleGroundEnemies = BattleGroundEnemies


local AceGUI = LibStub("AceGUI-3.0")

local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

AceConfigDialog:SetDefaultSize("BattleGroundEnemies", 800, 700)

BattleGroundEnemies.EditMode = {}
BattleGroundEnemies.EditMode.EditModeManager = Mixin({}, BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin)
BattleGroundEnemies.EditMode.EditModeManager:OnLoad()



function BattleGroundEnemies.EditMode.EditModeManager:AddFrame(frame, systemName, systemNameLocalized, playerButton)
	frame.Selection = CreateFrame("frame", nil, frame, "NineSliceCodeTemplate")
	frame.Selection:SetAllPoints()
	frame.Selection.highlightTextureKit = "editmode-actionbar-highlight"
	frame.Selection.selectedTextureKit = "editmode-actionbar-selected"
	frame.Selection.ignoreInLayout = true
	frame.Selection:EnableMouse(true)
	frame.Selection:RegisterForDrag("LeftButton")
	frame.Selection:SetToplevel(true)
	frame.Selection:SetIgnoreParentAlpha(true)
	frame.Selection:SetFrameStrata("MEDIUM")
	frame.Selection:SetFrameLevel(1000)
	frame.Selection.Label = frame.Selection:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
	frame.Selection.Label:SetAllPoints()
	frame.Selection.Label:SetIgnoreParentScale(true)
	Mixin(frame.Selection.Label, ShrinkUntilTruncateFontStringMixin)
	Mixin(frame.Selection, BattleGroundEnemies.Mixins.CustomEditModeSystemSelectionBaseMixin, BattleGroundEnemies.Mixins.EditModeSystemSelectionMixin)
	Mixin(frame, BattleGroundEnemies.Mixins.CustomEditModeSystemMixin)
	frame.Selection:SetScript("OnMouseDown", frame.Selection.OnMouseDown)
	frame.Selection:SetScript("OnDragStart", frame.Selection.OnDragStart)
	frame.Selection:SetScript("OnDragStop", frame.Selection.OnDragStop)
	frame.Selection:OnLoad()
	frame.Selection:Hide()
	frame.system = systemName
	frame.systemLocalized = systemNameLocalized
	frame.playerButton = playerButton
	frame:OnSystemLoad()
end

function BattleGroundEnemies.EditMode.EditModeManager:OpenEditmode()
    --highlight all frames and make them clickable which opens the optons for that system
	for i = 1, #self.registeredSystemFrames do
		self.registeredSystemFrames[i]:OnEditModeEnter()
	end
	self:SetEnableSnap(true)
end

function BattleGroundEnemies.EditMode.EditModeManager:CloseEditmode()
    --highlight all frames and make them clickable which opens the optons for that system
	for i = 1, #self.registeredSystemFrames do
		self.registeredSystemFrames[i]:OnEditModeExit()
	end
	self:SetEnableSnap(false)
end
