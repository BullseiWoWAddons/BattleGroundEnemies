---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)

---@class BattleGroundEnemies

BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin = {}

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:OnLoad()
	self.registeredSystemFrames = {};
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:OnDragStart()
	self:StartMoving();
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:OnDragStop()
	self:StopMovingOrSizing();
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:OnUpdate()
	self:InvokeOnAnyEditModeSystemAnchorChanged();
	self:RefreshSnapPreviewLines();
end

local function callOnEditModeEnter(index, systemFrame)
	systemFrame:OnEditModeEnter();
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:ShowSystemSelections()
	secureexecuterange(self.registeredSystemFrames, callOnEditModeEnter);
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:EnterEditMode()
	self.editModeActive = true;
	self:ClearActiveChangesFlags();
	self:ShowSystemSelections();
	self.AccountSettings:OnEditModeEnter();
    EventRegistry:TriggerEvent("EditMode.Enter");
end

local function callOnEditModeExit(index, systemFrame)
	systemFrame:OnEditModeExit();
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:HideSystemSelections()
	secureexecuterange(self.registeredSystemFrames, callOnEditModeExit);
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:ExitEditMode()
	self.editModeActive = false;
	self:RevertAllChanges();
	self:HideSystemSelections();
	self.AccountSettings:OnEditModeExit();
	self:InvokeOnAnyEditModeSystemAnchorChanged(true);
	PlaySound(SOUNDKIT.IG_MAINMENU_QUIT);
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:OnShow()
	if not self:IsEditModeLocked() then
		self:EnterEditMode();
	elseif self:IsEditModeInLockState("hideSelections")  then
		self:ShowSystemSelections();
		self.AccountSettings:OnEditModeEnter();
	end

	self:ClearEditModeLockState();
	self:Layout();
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:OnHide()
	if not self:IsEditModeLocked() then
		self:ExitEditMode();
	elseif self:IsEditModeInLockState("hideSelections") then
		self:HideSystemSelections();
		self.AccountSettings:OnEditModeExit();
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:IsEditModeActive()
	return self.editModeActive;
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:SetEditModeLockState(lockState)
	self.editModeLockState = lockState;
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:IsEditModeInLockState(lockState)
	return self.editModeLockState == lockState;
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:ClearEditModeLockState()
	self.editModeLockState = nil;
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:IsEditModeLocked()
	return self.editModeLockState ~= nil;
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:OnEvent(event, ...)
	if true then return end
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:IsInitialized()
	return self.layoutInfo ~= nil;
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:RegisterSystemFrame(systemFrame)
	table.insert(self.registeredSystemFrames, systemFrame);
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:GetRegisteredSystemFrame(system, systemIndex)
	local foundSystem = nil;
	local function findSystem(index, systemFrame)
		if not foundSystem and systemFrame.system == system and systemFrame.systemIndex == systemIndex then
			foundSystem = systemFrame;
		end
	end
	secureexecuterange(self.registeredSystemFrames, findSystem);
	return foundSystem;
end

local function AreAnchorsEqual(anchorInfo, otherAnchorInfo)
	if anchorInfo and otherAnchorInfo then
		return anchorInfo.point == otherAnchorInfo.point
		and anchorInfo.relativeTo == otherAnchorInfo.relativeTo
		and anchorInfo.relativePoint == otherAnchorInfo.relativePoint
		and anchorInfo.offsetX == otherAnchorInfo.offsetX
		and anchorInfo.offsetY == otherAnchorInfo.offsetY
	end

	return anchorInfo == otherAnchorInfo;
end

local function CopyAnchorInfo(anchorInfo, otherAnchorInfo)
	if anchorInfo and otherAnchorInfo then
		anchorInfo.point = otherAnchorInfo.point;
		anchorInfo.relativeTo = otherAnchorInfo.relativeTo;
		anchorInfo.relativePoint = otherAnchorInfo.relativePoint;
		anchorInfo.offsetX = otherAnchorInfo.offsetX;
		anchorInfo.offsetY = otherAnchorInfo.offsetY;
	end
end

local function ConvertToAnchorInfo(point, relativeTo, relativePoint, offsetX, offsetY)
	
	if point then
		local relativeToo
		if type(relativeTo) == "string" then
			relativeToo = relativeTo
		else
			if (type(relativeTo) == "table") then
				relativeToo = relativeTo.system == "playerButton" and "Button" or relativeTo.system
			end
		end
		local anchorInfo = {};
		anchorInfo.point = point;
		--anchorInfo.relativeTo = relativeTo and relativeTo:GetName() or "UIParent";
		anchorInfo.relativeTo = relativeToo;
		anchorInfo.relativePoint = relativePoint;
		anchorInfo.offsetX = offsetX;
		anchorInfo.offsetY = offsetY;
		return anchorInfo;
	end

	return nil;
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:SetHasActiveChanges(hasActiveChanges)
	if true then return end
	-- Clear taint off of the value passed in
	if hasActiveChanges then
		self.hasActiveChanges = true;
	else
		self.hasActiveChanges = false;
	end
	self.SaveChangesButton:SetEnabled(hasActiveChanges);
	self.RevertAllChangesButton:SetEnabled(hasActiveChanges);
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:CheckForSystemActiveChanges()
	local hasActiveChanges = false;
	local function checkIfSystemHasActiveChanges(index, systemFrame)
		if not hasActiveChanges and systemFrame:HasActiveChanges() then
			hasActiveChanges = true;
		end
	end
	secureexecuterange(self.registeredSystemFrames, checkIfSystemHasActiveChanges);

	self:SetHasActiveChanges(hasActiveChanges);
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:HasActiveChanges()
	return self.hasActiveChanges;
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:UpdateSystemAnchorInfo(systemFrame)
	--DevTool:AddData(CopyTable(systemFrame, true) , "systemFrame")
	local firstPoint = systemFrame.config.Points[1]
	local systemInfo = {anchorInfo = ConvertToAnchorInfo(firstPoint.Point,  firstPoint.RelativeFrame, firstPoint.RelativePoint, firstPoint.OffsetX or 0, firstPoint.OffsetY or 0)}   --self:GetActiveLayoutSystemInfo(systemFrame.system, systemFrame.systemIndex);
	if systemInfo then
		local anchorInfoChanged = false;

		local point, relativeTo, relativePoint, offsetX, offsetY = systemFrame:GetPoint(1);
		BattleGroundEnemies:Debug("1", point, relativeTo, relativePoint, offsetX, offsetY)

		if relativeTo and relativeTo.GetName then
			BattleGroundEnemies:Debug("2", point, relativeTo, relativePoint, offsetX, offsetY, relativeTo:GetName(), relativeTo.playerButton.PlayerDetails.PlayerName)

		end


		-- If we don't have a relativeTo then we are gonna set our relativeTo to be the playerButton
		if not relativeTo then
			relativeTo = systemFrame.playerButton;

			-- When setting our relativeTo to UIParent it's possible for our y position to change slightly depending on UIParent's size from stuff like debug menus
			-- To account for this set out position and then track the change in our top and adjust for that
			
			local scaleSystemFrame = systemFrame:GetEffectiveScale()
			local originalSystemFrameLeft = systemFrame:GetLeft() * scaleSystemFrame;
			local originalSystemFrameTop = systemFrame:GetTop() * scaleSystemFrame;
			--BattleGroundEnemies:Debug("3", originalSystemFrameLeft, originalSystemFrameTop)

			local scaleRelativeTo = relativeTo:GetEffectiveScale()
			local relativeLeft= relativeTo:GetLeft() * scaleRelativeTo
			local relativeTop = relativeTo:GetTop()  * scaleRelativeTo

			--BattleGroundEnemies:Debug("4", relativeLeft, relativeTop)

			point = "TOPLEFT"
			relativePoint = "TOPLEFT"
			

			--systemFrame:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY);

			offsetX = (originalSystemFrameLeft - relativeLeft)
			offsetY = (originalSystemFrameTop - relativeTop)

			--offsetY = offsetY + originalSystemFrameTop - systemFrame:GetTop();
			--BattleGroundEnemies:Debug("5", point, relativeTo, relativePoint, offsetX, offsetY)
			--systemFrame:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY);
		end

		-- Undo offset changes due to scale so we're always working as if we're at 1.0 scale
		--local frameScale = systemFrame:GetScale();
		offsetX = offsetX --* frameScale;
		offsetY = offsetY --* frameScale;

		local newAnchorInfo = ConvertToAnchorInfo(point, relativeTo, relativePoint, offsetX, offsetY);
		if not AreAnchorsEqual(systemInfo.anchorInfo, newAnchorInfo) then
			--BattleGroundEnemies:Debug("not equal")
			--DevTool:AddData(CopyTable(newAnchorInfo, true) , "newAnchorInfo")
			--DevTool:AddData(CopyTable(systemInfo.anchorInfo, true) , "systemInfo.anchorInfo")

			firstPoint.Point = newAnchorInfo.point
			firstPoint.RelativeFrame = newAnchorInfo.relativeTo
			firstPoint.RelativePoint = newAnchorInfo.relativePoint
			firstPoint.OffsetX = newAnchorInfo.offsetX
			firstPoint.OffsetY = newAnchorInfo.offsetY
			--CopyAnchorInfo(systemInfo.anchorInfo, newAnchorInfo);
			anchorInfoChanged = true;
		end

		point, relativeTo, relativePoint, offsetX, offsetY = systemFrame:GetPoint(2);

		newAnchorInfo = ConvertToAnchorInfo(point, relativeTo, relativePoint, offsetX, offsetY);
		if not AreAnchorsEqual(systemInfo.anchorInfo2, newAnchorInfo) then
			--BattleGroundEnemies:Debug("anchorInfo2 not equal")

			CopyAnchorInfo(systemInfo.anchorInfo2, newAnchorInfo);
			anchorInfoChanged = true;
		end

		if anchorInfoChanged then
			systemInfo.isInDefaultPosition = false;
		end

		return anchorInfoChanged;
	end

	return false;
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:OnSystemPositionChange(systemFrame)
	if self:UpdateSystemAnchorInfo(systemFrame) then
		--systemFrame:SetHasActiveChanges(true);

		--self:UpdateActionBarLayout(systemFrame);


		BattleGroundEnemies:NotifyChange()
		--EditModeSystemSettingsDialog:UpdateDialog(systemFrame);
	end

	--self:OnEditModeSystemAnchorChanged();
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:MirrorSetting(system, systemIndex, setting, value)
	local mirroredSettings -- = EditModeSettingDisplayInfoManager:GetMirroredSettings(system, systemIndex, setting);
	if mirroredSettings then
		for _, mirroredSettingInfo in ipairs(mirroredSettings) do
			local systemFrame = self:GetRegisteredSystemFrame(mirroredSettingInfo.system, mirroredSettingInfo.systemIndex);
			if systemFrame then
				systemFrame:UpdateSystemSettingValue(setting, value);
			end
		end
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:OnSystemSettingChange(systemFrame, changedSetting, newValue)
	local systemInfo = self:GetActiveLayoutSystemInfo(systemFrame.system, systemFrame.systemIndex);
	if systemInfo then
		systemFrame:UpdateSystemSettingValue(changedSetting, newValue);
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:SelectSystem(selectFrame)
	--custom we hgihlight all frames of this system of the same plaeyrtype
	--if not self:IsEditModeLocked() then
		local function selectMatchingSystem(index, systemFrame)
			if systemFrame.system == selectFrame.system and systemFrame.playerButton.PlayerType == selectFrame.playerButton.PlayerType then
				systemFrame:SelectSystem();
			else
				-- Only highlight a system if it was already highlighted
				if systemFrame.isHighlighted then
					systemFrame:HighlightSystem();
				end
			end
		end
		secureexecuterange(self.registeredSystemFrames, selectMatchingSystem);
	--end
end

local function clearSelectedSystem(index, systemFrame)
	-- Only highlight a system if it was already highlighted
	if systemFrame.isHighlighted then
		systemFrame:HighlightSystem();
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:ClearSelectedSystem()
	secureexecuterange(self.registeredSystemFrames, clearSelectedSystem);
	--EditModeSystemSettingsDialog:Hide();
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:GetLayouts()
	return self.layoutInfo.layouts;
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:SetGridShown(gridShown, isUserInput)
	self.Grid:SetShown(gridShown);
	self.GridSpacingSlider:SetEnabled(gridShown);

	if isUserInput then
		self:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowGrid, gridShown);
	else
		self.ShowGridCheckButton:SetControlChecked(gridShown);
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:SetGridSpacing(gridSpacing, isUserInput)
	self.Grid:SetGridSpacing(gridSpacing);
	self.GridSpacingSlider:SetupSlider(gridSpacing);

	if isUserInput then
		self:OnAccountSettingChanged(Enum.EditModeAccountSetting.GridSpacing, gridSpacing);
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:SetEnableSnap(enableSnap, isUserInput)
	self.snapEnabled = enableSnap;

	if not self.snapEnabled then
		self:HideSnapPreviewLines();
	end


	-- if isUserInput then
	-- 	self:OnAccountSettingChanged(Enum.EditModeAccountSetting.EnableSnap, enableSnap);
	-- else
	-- 	self.EnableSnapCheckButton:SetControlChecked(enableSnap);
	-- end
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:IsSnapEnabled()
	return self.snapEnabled;
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:SetSnapPreviewFrame(snapPreviewFrame)
	self.snapPreviewFrame = snapPreviewFrame;
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:ClearSnapPreviewFrame()
	self.snapPreviewFrame = nil;
	self:HideSnapPreviewLines();
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:ShouldShowSnapPreviewLines()
	return self:IsSnapEnabled() and self.snapPreviewFrame;
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:RefreshSnapPreviewLines()
	self:HideSnapPreviewLines();

	if not self:ShouldShowSnapPreviewLines() then
		return;
	end

	if not self.magnetismPreviewLinesPool then
		self.magnetismPreviewLinePool = EditModeUtil.CreateLinePool(self.MagnetismPreviewLinesContainer, "MagnetismPreviewLineTemplate");
	end

	local magneticFrameInfos = BattleGroundEnemies.CustomEditModeMagnetismManager:GetMagneticFrameInfos(self.snapPreviewFrame);
	if magneticFrameInfos then
		for _, magneticFrameInfo in ipairs(magneticFrameInfos) do
			local lineAnchors = BattleGroundEnemies.CustomEditModeMagnetismManager:GetPreviewLineAnchors(magneticFrameInfo);
			for _, lineAnchor in ipairs(lineAnchors) do
				local line = self.magnetismPreviewLinePool:Acquire();
				line:Setup(magneticFrameInfo, lineAnchor);
			end
		end
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:HideSnapPreviewLines()
	if self.magnetismPreviewLinePool then
		self.magnetismPreviewLinePool:ReleaseAll();
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:SetEnableAdvancedOptions(enableAdvancedOptions, isUserInput)
	self.advancedOptionsEnabled = enableAdvancedOptions;
	self.AccountSettings:LayoutSettings();

	if isUserInput then
		self:OnAccountSettingChanged(Enum.EditModeAccountSetting.EnableAdvancedOptions, enableAdvancedOptions);
	else
		self.EnableAdvancedOptionsCheckButton:SetControlChecked(enableAdvancedOptions);
	end
end


local function SortLayouts(a, b)
	-- Sorts the layouts: character-specific -> account -> preset
	local layoutTypeA = a.layoutInfo.layoutType;
	local layoutTypeB = b.layoutInfo.layoutType;
	if layoutTypeA ~= layoutTypeB then
		return layoutTypeA > layoutTypeB;
	end

	return a.index < b.index;
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:CreateLayoutTbls()
	self.highestLayoutIndexByType = {};

	local layoutTbls = {};
	local hasCharacterLayouts = false;
	for index, layoutInfo in ipairs(self.layoutInfo.layouts) do
		table.insert(layoutTbls, { index = index, layoutInfo = layoutInfo });

		local layoutType = layoutInfo.layoutType;
		if layoutType == Enum.EditModeLayoutType.Character then
			hasCharacterLayouts = true;
		end

		if not self.highestLayoutIndexByType[layoutType] or self.highestLayoutIndexByType[layoutType] < index then
			self.highestLayoutIndexByType[layoutType] = index;
		end
	end

	table.sort(layoutTbls, SortLayouts);

	return layoutTbls, hasCharacterLayouts;
end


function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:UpdateSystems()
	local function callUpdateSystem(index, systemFrame)
		self:UpdateSystem(systemFrame);
	end
	secureexecuterange(self.registeredSystemFrames, callUpdateSystem);
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:UpdateSystem(systemFrame, forceFullUpdate)
	local systemInfo = self:GetActiveLayoutSystemInfo(systemFrame.system, systemFrame.systemIndex);
	if systemInfo then
		if forceFullUpdate then
			systemFrame:MarkAllSettingsDirty();
		end

		systemFrame:UpdateSystem(systemInfo);
	end
end
