
---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)

---@class BattleGroundEnemies



local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")


BattleGroundEnemies.Mixins = BattleGroundEnemies.Mixins or {}

local EditModeSystemSettingsDialog = {}

EditModeSystemSettingsDialog.UpdateDialog = function(self, systemFrame)
	
	
end

EditModeSystemSettingsDialog.AttachToSystemFrame = function(self, systemFrame)
	AceConfigDialog:SelectGroup(AddonName)
	print("test124")
	DevTool:AddData(CopyTable(systemFrame) , "systemFrame")
	--get playertype and playercount and navigate through the settings panel
	
end

BattleGroundEnemies.Mixins.CustomEditModeSystemMixin = {};

local EditModeSystemSelectionLayout = EditModeSystemSelectionLayout or
{
	["TopRightCorner"] = { atlas = "%s-NineSlice-Corner", mirrorLayout = true, x=8, y=8 },
	["TopLeftCorner"] = { atlas = "%s-NineSlice-Corner", mirrorLayout = true, x=-8, y=8 },
	["BottomLeftCorner"] = { atlas = "%s-NineSlice-Corner", mirrorLayout = true, x=-8, y=-8 },
	["BottomRightCorner"] = { atlas = "%s-NineSlice-Corner",  mirrorLayout = true, x=8, y=-8 },
	["TopEdge"] = { atlas = "_%s-NineSlice-EdgeTop" },
	["BottomEdge"] = { atlas = "_%s-NineSlice-EdgeBottom" },
	["LeftEdge"] = { atlas = "!%s-NineSlice-EdgeLeft" },
	["RightEdge"] = { atlas = "!%s-NineSlice-EdgeRight" },
	["Center"] = { atlas = "%s-NineSlice-Center", x = -8, y = 8, x1 = 8, y1 = -8, },
};

BattleGroundEnemies.Mixins.CustomEditModeSystemSelectionBaseMixin = {};

function BattleGroundEnemies.Mixins.CustomEditModeSystemSelectionBaseMixin:OnLoad()
	self.parent = self:GetParent();
	if self.Label then
		self.Label:SetFontObjectsToTry("GameFontHighlightLarge", "GameFontHighlightMedium", "GameFontHighlightSmall");
	end
	if self.HorizontalLabel then
		self.HorizontalLabel:SetFontObjectsToTry("GameFontHighlightLarge", "GameFontHighlightMedium", "GameFontHighlightSmall");
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemSelectionBaseMixin:ShowHighlighted()
	NineSliceUtil.ApplyLayout(self, EditModeSystemSelectionLayout, self.highlightTextureKit);
	self.isSelected = false;
	self:UpdateLabelVisibility();
	self:Show();
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemSelectionBaseMixin:ShowSelected()
	NineSliceUtil.ApplyLayout(self, EditModeSystemSelectionLayout, self.selectedTextureKit);
	self.isSelected = true;
	self:UpdateLabelVisibility();
	self:Show();
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemSelectionBaseMixin:OnDragStart()
	self.parent:OnDragStart();
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemSelectionBaseMixin:OnDragStop()
	self.parent:OnDragStop();
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemSelectionBaseMixin:OnMouseDown()
	print("on mouse down")
	BattleGroundEnemies.EditMode.EditModeManager:SelectSystem(self.parent);
end

local EditModeSystemSelectionMixin = EditModeSystemSelectionMixin

if not EditModeSystemSelectionMixin then
    EditModeSystemSelectionMixin = {};

    function EditModeSystemSelectionMixin:SetGetLabelTextFunction(getLabelText)
        self.getLabelText = getLabelText;
    end

    function EditModeSystemSelectionMixin:UpdateLabelVisibility()
        if self.getLabelText then
            self.Label:SetText(self.getLabelText());
        end

        self.Label:SetShown(self.isSelected);
    end
end

BattleGroundEnemies.Mixins.EditModeSystemSelectionMixin = EditModeSystemSelectionMixin
BattleGroundEnemies.Mixins.CustomEditModeSystemMixin = {}

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:OnSystemLoad()
	if not self.system then
		-- All systems must have self.system set on them
		return;
	end

	-- Override set scale so we can keep systems in place as their scale changes
	self.SetScaleBase = self.SetScale;
	self.SetScale = self.SetScaleOverride;

	self.SetPointBase = self.SetPoint;
	self.SetPoint = self.SetPointOverride;

	self.ClearAllPointsBase = self.ClearAllPoints;
	self.ClearAllPoints = self.ClearAllPointsOverride;

	BattleGroundEnemies.EditMode.EditModeManager:RegisterSystemFrame(self);



	self.Selection:SetGetLabelTextFunction(function() return self:GetSystemName(); end);
	self:SetupSettingsDialogAnchor();
	self.snappedFrames = {};
	self.downKeys = {};

	self.settingDisplayInfoMap = EditModeSettingDisplayInfoManager:GetSystemSettingDisplayInfoMap(self.system);
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:OnSystemHide()
	if self.isSelected then
		BattleGroundEnemies.EditMode.EditModeManager:ClearSelectedSystem();
	end

	if self.isManagedFrame then
		UIParentManagedFrameMixin.OnHide(self);
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:ProcessMovementKey(key)
	if not self:CanBeMoved() then
		return;
	end

	local deltaAmount = self:IsShiftKeyDown() and 10 or 1;
	local xDelta, yDelta = 0, 0;
	if key == "UP" then
		yDelta = deltaAmount;
	elseif key == "DOWN" then
		yDelta = -deltaAmount;
	elseif key == "LEFT" then
		xDelta = -deltaAmount;
	elseif key == "RIGHT" then
		xDelta = deltaAmount;
	end

	if self.isManagedFrame and self:IsInDefaultPosition() then
		self:BreakFromFrameManager();
	end

	if self == PlayerCastingBarFrame then
		BattleGroundEnemies.EditMode.EditModeManager:OnSystemSettingChange(self, Enum.EditModeCastBarSetting.LockToPlayerFrame, 0);
	end

	self:StopMovingOrSizing();
end

local movementKeys = {
	UP = true,
	DOWN = true,
	LEFT = true,
	RIGHT = true,
};

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:OnKeyDown(key)
	self.downKeys[key] = true;
	if movementKeys[key] then
		self:ProcessMovementKey(key);
	end

end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:OnKeyUp(key)
	self.downKeys[key] = false;
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:ClearDownKeys()
	self.downKeys = {};
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:IsShiftKeyDown()
	return self.downKeys["LSHIFT"] or self.downKeys["RSHIFT"];
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:PrepareForSave()
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:SetScaleOverride(newScale)
	local oldScale = self:GetScale();

	self:SetScaleBase(newScale);

	if oldScale == newScale then
		return;
	end

	-- Update position to try and keep the system frame in the same position since scale changes how offsets work
	local numPoints = self:GetNumPoints();
	for i = 1, numPoints do
		local point, relativeTo, relativePoint, offsetX, offsetY = self:GetPoint(i);

		-- Undo old scale adjustment so we're working with 1.0 scale offsets
		-- Then apply the newScale adjustment
		offsetX = offsetX * oldScale / newScale;
		offsetY = offsetY * oldScale / newScale;
		self:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY);
	end

	if self.isManagedFrame and self:IsInDefaultPosition() then
		UIParent_ManageFramePositions();

		if self.isRightManagedFrame and ObjectiveTrackerFrame and ObjectiveTrackerFrame:IsInDefaultPosition() then
			ObjectiveTrackerFrame:Update();
		end
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:SetPointOverride(point, relativeTo, relativePoint, offsetX, offsetY)
	self:SetPointBase(point, relativeTo, relativePoint, offsetX, offsetY);
	self:SetSnappedToFrame(relativeTo);
	--BattleGroundEnemies.EditMode.EditModeManager:OnEditModeSystemAnchorChanged();
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:ClearAllPointsOverride()
	self:ClearAllPointsBase();
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:UpdateClampOffsets()
	if not self:GetLeft() then
		self:SetClampRectInsets(0, 0, 0, 0);
		return;
	end

	local leftOffset = self.Selection:GetLeft() - self:GetLeft();
	local rightOffset = self.Selection:GetRight() - self:GetRight();
	local topOffset = self.Selection:GetTop() - self:GetTop();
	local bottomOffset = self.Selection:GetBottom() - self:GetBottom();

	self:SetClampRectInsets(leftOffset, rightOffset, topOffset, bottomOffset);
end

-- Override in inheriting mixins as needed
function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:AnchorSelectionFrame()
	self:UpdateClampOffsets();
end

-- Override in inheriting mixins as needed
function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:ShouldResetSettingsDialogAnchors(oldSelectedSystemFrame)
	return not oldSelectedSystemFrame or oldSelectedSystemFrame.system ~= self.system;
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:ConvertSettingDisplayValueToRawValue(setting, value)
	if self.settingDisplayInfoMap[setting] then
		return self.settingDisplayInfoMap[setting]:ConvertValue(value);
	else
		return value;
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:UpdateSettingMap(updateDirtySettings)
	local oldSettingsMap = self.settingMap;
	self.settingMap = EditModeUtil:GetSettingMapFromSettings(self.systemInfo.settings, self.settingDisplayInfoMap);

	if updateDirtySettings then
		self:UpdateDirtySettings(oldSettingsMap)
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:UpdateDirtySettings(oldSettingsMap)
	-- Mark changed settings as dirty
	self.dirtySettings = {};

	for setting, settingInfo in pairs(self.settingMap) do
		if not oldSettingsMap or not oldSettingsMap[setting] or oldSettingsMap[setting].value ~= settingInfo.value then
			self.dirtySettings[setting] = true;
		end
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:MarkAllSettingsDirty()
	self.settingMap = nil;
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:IsSettingDirty(setting)
	return self.dirtySettings[setting];
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:ClearDirtySetting(setting)
	self.dirtySettings[setting] = nil;
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:TrySetCompositeNumberSettingValue(setting, newValue)
	local settingDisplayInfo = self.settingDisplayInfoMap[setting];
	if not settingDisplayInfo or not settingDisplayInfo.isCompositeNumberSetting then
		return false;
	end

	-- Composite number settings are settings which represent multiple other hidden settings which combine to form the one main setting's number
	-- So when we change the main setting we actually want to be changing each of the sub settings which make up that number
	local useRawValueYes = true;
	local rawOldValue = self:GetSettingValue(setting, useRawValueYes);
	local rawNewValue = self:ConvertSettingDisplayValueToRawValue(setting, newValue);
	if rawOldValue ~= rawNewValue then
		local hundredsValue = math.floor(newValue / 100);
		BattleGroundEnemies.EditMode.EditModeManager:OnSystemSettingChange(self, settingDisplayInfo.compositeNumberHundredsSetting, hundredsValue);

		local tensAndOnesValue = math.floor(newValue % 100);
		BattleGroundEnemies.EditMode.EditModeManager:OnSystemSettingChange(self, settingDisplayInfo.compositeNumberTensAndOnesSetting, tensAndOnesValue);
	end
	return true;
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:UpdateSystemSettingValue(setting, newValue)
	if not self:IsInitialized() then
		return;
	end

	if self:TrySetCompositeNumberSettingValue(setting, newValue) then
		return;
	end

	for _, settingInfo in pairs(self.systemInfo.settings) do
		if settingInfo.setting == setting then
			local rawNewValue = self:ConvertSettingDisplayValueToRawValue(setting, newValue);
			if settingInfo.value ~= rawNewValue then
				settingInfo.value = rawNewValue;
				self:UpdateSystemSetting(setting);
			end
			return;
		end
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:ResetToDefaultPosition()
	self.systemInfo.anchorInfo = EditModePresetLayoutManager:GetModernSystemAnchorInfo(self.system, self.systemIndex);
	self.systemInfo.anchorInfo2 = nil;
	self.systemInfo.isInDefaultPosition = true;
	self:BreakSnappedFrames();
	EditModeSystemSettingsDialog:UpdateDialog(self);
	self:SetHasActiveChanges(true);
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:GetManagedFrameContainer()
	if not self.isManagedFrame then
		return nil;
	end

	if self.isBottomManagedFrame then
		return UIParentBottomManagedFrameContainer;
	elseif self.isRightManagedFrame then
		return UIParentRightManagedFrameContainer;
	else
		return PlayerFrameBottomManagedFramesContainer;
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:BreakFromFrameManager()
	local frameContainer = self:GetManagedFrameContainer();
	if not frameContainer then
		return;
	end

	self.ignoreFramePositionManager = true;
	frameContainer:RemoveManagedFrame(self);
	self:SetParent(UIParent);

	if self.isPlayerFrameBottomManagedFrame then
		self:UpdateSystemSettingFrameSize();
	end
end



function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:UpdateSystem(systemInfo)
	self.savedSystemInfo = CopyTable(systemInfo);
	self:SetHasActiveChanges(false);

	self.systemInfo = systemInfo;

	local updateDirtySettings = true;
	self:UpdateSettingMap(updateDirtySettings);


	self:AnchorSelectionFrame();
	EditModeSystemSettingsDialog:UpdateDialog(self);

	local entireSystemUpdate = true;
	for _, settingInfo in ipairs(systemInfo.settings) do
		self:UpdateSystemSetting(settingInfo.setting, entireSystemUpdate);
	end
end


function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:UpdateSystemSetting(setting, entireSystemUpdate)
	if not entireSystemUpdate then
		self.dirtySettings[setting] = true;
		self:SetHasActiveChanges(true);
		self:UpdateSettingMap();
		self:AnchorSelectionFrame();
		EditModeSystemSettingsDialog:UpdateDialog(self);
	end

	if self:IsSettingDirty(setting) then
		BattleGroundEnemies.EditMode.EditModeManager:MirrorSetting(self.system, self.systemIndex, setting, self:GetSettingValue(setting));
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:IsInitialized()
	return self.systemInfo ~= nil;
end

-- Override in inheriting mixins as needed
function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:SetupSettingsDialogAnchor()
	self.settingsDialogAnchor = AnchorUtil.CreateAnchor("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -250, 200);
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:SetHasActiveChanges(hasActiveChanges)
	self.hasActiveChanges = hasActiveChanges;
	if hasActiveChanges then
		BattleGroundEnemies.EditMode.EditModeManager:SetHasActiveChanges(true);
	end
	EditModeSystemSettingsDialog:UpdateButtons(self);
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:HasActiveChanges()
	return self.hasActiveChanges;
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:HasCompositeNumberSetting(setting)
	local settingDisplayInfo = self.settingDisplayInfoMap[setting];
	if not settingDisplayInfo or not settingDisplayInfo.isCompositeNumberSetting then
		return nil;
	end

	-- Composite number settings are settings which represent multiple other hidden settings which combine to form the one main setting's number
	-- So if we want to know if a composite number setting exists we actually want to be checking if all the sub settings which make up the number exist
	return self:HasSetting(settingDisplayInfo.compositeNumberHundredsSetting)
		and self:HasSetting(settingDisplayInfo.compositeNumberTensAndOnesSetting);
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:HasSetting(setting)
	local hasCompositeNumberSetting = self:HasCompositeNumberSetting(setting);
	if hasCompositeNumberSetting ~= nil then
		return hasCompositeNumberSetting;
	end

	return self.settingMap and (self.settingMap[setting] ~= nil);
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:GetCompositeNumberSettingValue(setting, useRawValue)
	local settingDisplayInfo = self.settingDisplayInfoMap[setting];
	if not settingDisplayInfo or not settingDisplayInfo.isCompositeNumberSetting then
		return nil;
	end

	-- Composite number settings are settings which represent multiple other hidden settings which combine to form the one main setting's number
	-- So if we want to get the setting's value we need to get the sub settings values and combine them to form the main setting's number
	local hundreds = self:GetSettingValue(settingDisplayInfo.compositeNumberHundredsSetting, useRawValue) or 0;
	local tensAndOnes = self:GetSettingValue(settingDisplayInfo.compositeNumberTensAndOnesSetting, useRawValue) or 0;
	return math.floor((hundreds * 100) + tensAndOnes);
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:GetSettingValue(setting, useRawValue)
	if not self:IsInitialized() then
		return 0;
	end

	local compositeNumberValue = self:GetCompositeNumberSettingValue(setting, useRawValue);
	if compositeNumberValue ~= nil then
		return compositeNumberValue;
	end

	if useRawValue then
		return self.settingMap[setting].value;
	else
		return self.settingMap[setting].displayValue or self.settingMap[setting].value;
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:GetSettingValueBool(setting, useRawValue)
	return self:GetSettingValue(setting, useRawValue) == 1;
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:DoesSettingValueEqual(setting, value)
	local useRawValue = true;
	return self:GetSettingValue(setting, useRawValue) == value;
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:DoesSettingDisplayValueEqual(setting, value)
	local useRawValueNo = false;
	return self:GetSettingValue(setting, useRawValueNo) == value;
end

-- Override in inheriting mixins as needed
function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:UseSettingAltName(setting)
	return false;
end

-- Override in inheriting mixins as needed
function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:UpdateDisplayInfoOptions(displayInfo)
	return displayInfo;
end

-- Override in inheriting mixins as needed
function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:ShouldShowSetting(setting)
	return self:HasSetting(setting);
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:GetSettingsDialogAnchor()
	return self.settingsDialogAnchor;
end

-- Override in inheriting mixins as needed
function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:AddExtraButtons(extraButtonPool)
	-- Create reset to default position button
	self.resetToDefaultPositionButton = extraButtonPool:Acquire();
	self.resetToDefaultPositionButton.layoutIndex = 3;
	self.resetToDefaultPositionButton:SetText(HUD_EDIT_MODE_RESET_POSITION);
	self.resetToDefaultPositionButton:SetOnClickHandler(GenerateClosure(self.ResetToDefaultPosition, self));
	self.resetToDefaultPositionButton:SetEnabled(not self:IsInDefaultPosition());
	self.resetToDefaultPositionButton:Show();
	return true;
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:IsToTheLeftOfFrame(systemFrame)
	local myLeft, myRight, myBottom, myTop = self:GetScaledSelectionSides();
	local systemFrameLeft, systemFrameRight, systemFrameBottom, systemFrameTop = systemFrame:GetScaledSelectionSides();
	return myRight < systemFrameLeft;
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:IsToTheRightOfFrame(systemFrame)
	local myLeft, myRight, myBottom, myTop = self:GetScaledSelectionSides();
	local systemFrameLeft, systemFrameRight, systemFrameBottom, systemFrameTop = systemFrame:GetScaledSelectionSides();
	return myLeft > systemFrameRight;
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:IsAboveFrame(systemFrame)
	local myLeft, myRight, myBottom, myTop = self:GetScaledSelectionSides();
	local systemFrameLeft, systemFrameRight, systemFrameBottom, systemFrameTop = systemFrame:GetScaledSelectionSides();
	return myBottom > systemFrameTop;
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:IsBelowFrame(systemFrame)
	local myLeft, myRight, myBottom, myTop = self:GetScaledSelectionSides();
	local systemFrameLeft, systemFrameRight, systemFrameBottom, systemFrameTop = systemFrame:GetScaledSelectionSides();
	return myTop < systemFrameBottom;
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:IsVerticallyAlignedWithFrame(systemFrame)
	local myLeft, myRight, myBottom, myTop = self:GetScaledSelectionSides();
	local systemFrameLeft, systemFrameRight, systemFrameBottom, systemFrameTop = systemFrame:GetScaledSelectionSides();
	return (myTop >= systemFrameBottom) and (myBottom <= systemFrameTop);
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:IsHorizontallyAlignedWithFrame(systemFrame)
	local myLeft, myRight, myBottom, myTop = self:GetScaledSelectionSides();
	local systemFrameLeft, systemFrameRight, systemFrameBottom, systemFrameTop = systemFrame:GetScaledSelectionSides();
	return (myRight >= systemFrameLeft) and (myLeft <= systemFrameRight);
end

-- Returns selection frame center, adjusted for scale: centerX, centerY
function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:GetScaledSelectionCenter()
	local centerX, centerY = self.Selection:GetCenter();
	local scale = self:GetScale();
	return centerX * scale, centerY * scale;
end

-- Returns center, adjusted for scale: centerX, centerY
function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:GetScaledCenter()
	local centerX, centerY = self:GetCenter();
	local scale = self:GetScale();
	return centerX * scale, centerY * scale;
end

-- Returns selection frame sides, adjusted for scale: left, right, bottom, top
function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:GetScaledSelectionSides()
	local left, bottom, width, height = self.Selection:GetRect();
	local scale = self:GetScale();
	return left * scale, (left + width) * scale, bottom * scale, (bottom + height) * scale;
end

local SELECTION_PADDING = 2;

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:GetSelectionOffset(point, forYOffset)
	local function GetLeftOffset()
		return select(4, self.Selection:GetPoint(1)) - SELECTION_PADDING;
	end
	local function GetRightOffset()
		return select(4, self.Selection:GetPoint(2)) + SELECTION_PADDING;
	end
	local function GetTopOffset()
		return select(5, self.Selection:GetPoint(1)) + SELECTION_PADDING;
	end
	local function GetBottomOffset()
		return select(5, self.Selection:GetPoint(2)) - SELECTION_PADDING;
	end

	local offset;
	if point == "LEFT" then
		offset = GetLeftOffset();
	elseif point == "RIGHT" then
		offset = GetRightOffset();
	elseif point == "TOP" then
		offset = GetTopOffset();
	elseif point == "BOTTOM" then
		offset = GetBottomOffset();
	elseif point == "TOPLEFT" then
		offset = forYOffset and GetTopOffset() or GetLeftOffset();
	elseif point == "TOPRIGHT" then
		offset = forYOffset and GetTopOffset() or GetRightOffset();
	elseif point == "BOTTOMLEFT" then
		offset = forYOffset and GetBottomOffset() or GetLeftOffset();
	elseif point == "BOTTOMRIGHT" then
		offset = forYOffset and GetBottomOffset() or GetRightOffset();
	else
		-- Center
		local selectionCenterX, selectionCenterY = self.Selection:GetCenter();
		local centerX, centerY = self:GetCenter();
		if forYOffset then
			offset = selectionCenterY - centerY;
		else
			offset = selectionCenterX - centerX;
		end
	end

	return offset * self:GetScale();
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:GetCombinedSelectionOffset(frameInfo, forYOffset)
	local offset;
	if frameInfo.frame.Selection then
		offset = -self:GetSelectionOffset(frameInfo.point, forYOffset) + frameInfo.frame:GetSelectionOffset(frameInfo.relativePoint, forYOffset) + frameInfo.offset;
	else
		offset = -self:GetSelectionOffset(frameInfo.point, forYOffset) + frameInfo.offset;
	end

	return offset / self:GetScale();
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:GetCombinedCenterOffset(frame)
	local centerX, centerY = self:GetScaledCenter();
	local frameCenterX, frameCenterY;
	if frame.GetScaledCenter then
		frameCenterX, frameCenterY = frame:GetScaledCenter();
	else
		frameCenterX, frameCenterY = frame:GetCenter();
	end

	local scale = self:GetScale();
	return (centerX - frameCenterX) / scale, (centerY - frameCenterY) / scale;
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:GetSnapOffsets(frameInfo)
	local forYOffsetNo = false;
	local forYOffsetYes = true;
	local offsetX, offsetY;
	if frameInfo.isCornerSnap then
		offsetX = self:GetCombinedSelectionOffset(frameInfo, forYOffsetNo);
		offsetY = self:GetCombinedSelectionOffset(frameInfo, forYOffsetYes);
	else
		offsetX, offsetY = self:GetCombinedCenterOffset(frameInfo.frame);
		if frameInfo.isHorizontal then
			offsetX = self:GetCombinedSelectionOffset(frameInfo, forYOffsetNo);
		else
			offsetY = self:GetCombinedSelectionOffset(frameInfo, forYOffsetYes);
		end
	end

	return offsetX, offsetY;
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:AddSnappedFrame(frame)
	self.snappedFrames[frame] = true;
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:RemoveSnappedFrame(frame)
	self.snappedFrames[frame] = nil;
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:BreakSnappedFrames()
	for snappedFrame in pairs(self.snappedFrames) do
		snappedFrame:BreakFrameSnap();
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:SetSnappedToFrame(frame)
	if type(frame) == "string" then
		frame = _G[frame];
	end

	if frame and type(frame) == "table" and frame.AddSnappedFrame then
		frame:AddSnappedFrame(self);
		self.snappedToFrame = frame;
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:ClearFrameSnap()
	if self.snappedToFrame then
		self.snappedToFrame:RemoveSnappedFrame(self);
		self.snappedToFrame = nil;
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:BreakFrameSnap(deltaX, deltaY)
	local top = self:GetTop();
	if top then
		local scale = self:GetScale();
		local offsetY = -((UIParent:GetHeight() - top * scale) / scale);

		local offsetX, anchorPoint;
		if self.alwaysUseTopRightAnchor then
			offsetX = -((UIParent:GetWidth() - self:GetRight() * scale) / scale);
			anchorPoint = "TOPRIGHT";
		else
			offsetX = self:GetLeft();
			anchorPoint = "TOPLEFT";
		end

		if deltaX then
			offsetX = offsetX + deltaX;
		end

		if deltaY then
			offsetY = offsetY + deltaY;
		end

		self:ClearAllPoints();
		self:SetPoint(anchorPoint, UIParent, anchorPoint, offsetX, offsetY);
		EditModeManagerFrame:OnSystemPositionChange(self);
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:SnapToFrame(frameInfo)
	local offsetX, offsetY = self:GetSnapOffsets(frameInfo);
	self:SetPoint(frameInfo.point, frameInfo.frame, frameInfo.relativePoint, offsetX, offsetY);
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:IsFrameAnchoredToMe(frame)
	for i = 1, frame:GetNumPoints() do
		local _, relativeTo = frame:GetPoint(i);

		if not relativeTo then
			return false;
		end

		if relativeTo == self then
			return true;
		end

		if self:IsFrameAnchoredToMe(relativeTo) then
			return true;
		end
	end

	return false;
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:GetFrameMagneticEligibility(systemFrame)
	-- Can't magnetize to myself
	if systemFrame ==  self then
		return nil;
	end

	-- Can't magnetize to anything already anchored to me
	if self:IsFrameAnchoredToMe(systemFrame) then
		return nil;
	end

	local horizontalEligible = self:IsVerticallyAlignedWithFrame(systemFrame) and (self:IsToTheLeftOfFrame(systemFrame) or self:IsToTheRightOfFrame(systemFrame));
	local verticalEligible = self:IsHorizontallyAlignedWithFrame(systemFrame) and (self:IsAboveFrame(systemFrame) or self:IsBelowFrame(systemFrame));

	return horizontalEligible, verticalEligible;
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:UpdateMagnetismRegistration()
	if self:IsVisible() and self.isHighlighted and not self.isSelected then
		BattleGroundEnemies.CustomEditModeMagnetismManager:RegisterFrame(self);
	else
		BattleGroundEnemies.CustomEditModeMagnetismManager:UnregisterFrame(self);
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:ClearHighlight()
	if self.isSelected then
		BattleGroundEnemies.EditMode.EditModeManager:ClearSelectedSystem();
		self.isSelected = false;
	end

	self.Selection:Hide();
	self.isHighlighted = false;
	self:UpdateMagnetismRegistration();
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:HighlightSystem()
	if self.isDragging then
		self:OnDragStop();
	end

	self:SetMovable(false);
	self:AnchorSelectionFrame();
	self.Selection:ShowHighlighted();
	self.isHighlighted = true;
	self.isSelected = false;
	self:UpdateMagnetismRegistration();
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:SelectSystem()
	print("blabla")
	if not self.isSelected then
		self:SetMovable(true);
		self.Selection:ShowSelected();
		EditModeSystemSettingsDialog:AttachToSystemFrame(self);
		self.isSelected = true;
		self:UpdateMagnetismRegistration();
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:SetSelectionShown(shown)
	self.Selection:SetShown(shown);
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:OnEditModeEnter()
    print("entered")
	if not self.defaultHideSelection then
		self:HighlightSystem();
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:OnEditModeExit()
	self:ClearHighlight();
	self:StopMovingOrSizing();
	EditModeSystemSettingsDialog:Hide();
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:CanBeMoved()
	return self.isSelected and not self.isLocked;
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:IsInDefaultPosition()
	return self:IsInitialized() and self.systemInfo.isInDefaultPosition;
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:OnDragStart()
	if self:CanBeMoved() then
		if self.isManagedFrame and self:IsInDefaultPosition() then
			self:BreakFromFrameManager();
		end
		self:StartMoving();
		BattleGroundEnemies.EditMode.EditModeManager:SetSnapPreviewFrame(self);
		self.isDragging = true;
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:OnDragStop()
	if self:CanBeMoved() then
		BattleGroundEnemies.EditMode.EditModeManager:ClearSnapPreviewFrame();
		self:StopMovingOrSizing();
		self.isDragging = false;

		if BattleGroundEnemies.EditMode.EditModeManager:IsSnapEnabled() then
			BattleGroundEnemies.CustomEditModeMagnetismManager:ApplyMagnetism(self);
		end
		BattleGroundEnemies.EditMode.EditModeManager:OnSystemPositionChange(self);
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:GetSystemName()
	--custom
	return self.system;
end

-- Override this as needed to do things after any edit mode system had their anchor changed.
-- Only use this if your logic depends on knowing your system's screen position or cares about the position of whatever your system is anchored to.
function BattleGroundEnemies.Mixins.CustomEditModeSystemMixin:OnAnyEditModeSystemAnchorChanged()
end