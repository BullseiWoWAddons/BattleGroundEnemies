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
	self:UpdateDropdownOptions();
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
	C_EditMode.OnEditModeExit();
    EventRegistry:TriggerEvent("EditMode.Exit");
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
	if event == "EDIT_MODE_LAYOUTS_UPDATED" then
		local layoutInfo, reconcileLayouts = ...;
		self:UpdateLayoutInfo(layoutInfo, reconcileLayouts);
		self:InitializeAccountSettings();
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		local layoutInfo = C_EditMode.GetLayouts();
		local activeLayoutChanged = (layoutInfo.activeLayout ~= self.layoutInfo.activeLayout);
		self:UpdateLayoutInfo(layoutInfo);
		if activeLayoutChanged then
			self:NotifyChatOfLayoutChange();
		end
	elseif event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" then
		self:UpdateRightActionBarPositions();
		BattleGroundEnemies.CustomEditModeMagnetismManager:UpdateUIParentPoints();
	end
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
		local anchorInfo = {};
		anchorInfo.point = point;
		anchorInfo.relativeTo = relativeTo and relativeTo:GetName() or "UIParent";
		anchorInfo.relativePoint = relativePoint;
		anchorInfo.offsetX = offsetX;
		anchorInfo.offsetY = offsetY;
		return anchorInfo;
	end

	return nil;
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:SetHasActiveChanges(hasActiveChanges)
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
	local systemInfo = self:GetActiveLayoutSystemInfo(systemFrame.system, systemFrame.systemIndex);
	if systemInfo then
		local anchorInfoChanged = false;

		local point, relativeTo, relativePoint, offsetX, offsetY = systemFrame:GetPoint(1);

		-- If we don't have a relativeTo then we are gonna set our relativeTo to be UIParent
		if not relativeTo then
			relativeTo = UIParent;

			-- When setting our relativeTo to UIParent it's possible for our y position to change slightly depending on UIParent's size from stuff like debug menus
			-- To account for this set out position and then track the change in our top and adjust for that
			local originalSystemFrameTop = systemFrame:GetTop();
			systemFrame:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY);

			offsetY = offsetY + originalSystemFrameTop - systemFrame:GetTop();
			systemFrame:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY);
		end

		-- Undo offset changes due to scale so we're always working as if we're at 1.0 scale
		local frameScale = systemFrame:GetScale();
		offsetX = offsetX * frameScale;
		offsetY = offsetY * frameScale;

		local newAnchorInfo = ConvertToAnchorInfo(point, relativeTo, relativePoint, offsetX, offsetY);
		if not AreAnchorsEqual(systemInfo.anchorInfo, newAnchorInfo) then
			CopyAnchorInfo(systemInfo.anchorInfo, newAnchorInfo);
			anchorInfoChanged = true;
		end

		point, relativeTo, relativePoint, offsetX, offsetY = systemFrame:GetPoint(2);

		-- Undo offset changes due to scale so we're always working as if we're at 1.0 scale
		-- May not always have a second point so nil check first
		if point ~= nil then
			offsetX = offsetX * frameScale;
			offsetY = offsetY * frameScale;
		end

		newAnchorInfo = ConvertToAnchorInfo(point, relativeTo, relativePoint, offsetX, offsetY);
		if not AreAnchorsEqual(systemInfo.anchorInfo2, newAnchorInfo) then
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
		systemFrame:SetHasActiveChanges(true);

		self:UpdateActionBarLayout(systemFrame);

		if systemFrame.isBottomManagedFrame or systemFrame.isRightManagedFrame then
			UIParent_ManageFramePositions();
		end

		EditModeSystemSettingsDialog:UpdateDialog(systemFrame);
	end

	--self:OnEditModeSystemAnchorChanged();
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:MirrorSetting(system, systemIndex, setting, value)
	local mirroredSettings = EditModeSettingDisplayInfoManager:GetMirroredSettings(system, systemIndex, setting);
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

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:RevertSystemChanges(systemFrame)
	local activeLayoutInfo = self:GetActiveLayoutInfo();
	if activeLayoutInfo then
		for index, systemInfo in ipairs(activeLayoutInfo.systems) do
			if systemInfo.system == systemFrame.system and systemInfo.systemIndex == systemFrame.systemIndex then
				activeLayoutInfo.systems[index] = systemFrame.savedSystemInfo;

				systemFrame:BreakSnappedFrames();
				systemFrame:UpdateSystem(systemFrame.savedSystemInfo);
				self:CheckForSystemActiveChanges();
				return;
			end
		end
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:GetSettingValue(system, systemIndex, setting, useRawValue)
	local systemFrame = self:GetRegisteredSystemFrame(system, systemIndex);
	if systemFrame then
		return systemFrame:GetSettingValue(setting, useRawValue)
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:GetSettingValueBool(system, systemIndex, setting, useRawValue)
	local systemFrame = self:GetRegisteredSystemFrame(system, systemIndex);
	if systemFrame then
		return systemFrame:GetSettingValueBool(setting, useRawValue)
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:DoesSettingValueEqual(system, systemIndex, setting, value)
	local systemFrame = self:GetRegisteredSystemFrame(system, systemIndex);
	if systemFrame then
		return systemFrame:DoesSettingValueEqual(setting, value);
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:DoesSettingDisplayValueEqual(system, systemIndex, setting, value)
	local systemFrame = self:GetRegisteredSystemFrame(system, systemIndex);
	if systemFrame then
		return systemFrame:DoesSettingDisplayValueEqual(setting, value);
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:ArePartyFramesForcedShown()
	return self:IsEditModeActive() and self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowPartyFrames);
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:GetNumArenaFramesForcedShown()
	if self:IsEditModeActive() and self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowArenaFrames) then
		local viewArenaSize = self:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Arena, Enum.EditModeUnitFrameSetting.ViewArenaSize);
		if viewArenaSize == Enum.ViewArenaSize.Two then
			return 2;
		else
			return 3;
		end
	end

	return 0;
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:UseRaidStylePartyFrames()
	return self:GetSettingValueBool(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Party, Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames);
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:ShouldShowPartyFrameBackground()
	return self:GetSettingValueBool(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Party, Enum.EditModeUnitFrameSetting.ShowPartyFrameBackground);
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:UpdateRaidContainerFlow()
	local maxPerLine, orientation;

	local raidGroupDisplayType = self:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Raid, Enum.EditModeUnitFrameSetting.RaidGroupDisplayType);
	if raidGroupDisplayType == Enum.RaidGroupDisplayType.SeparateGroupsVertical then
		orientation = "vertical";
		CompactRaidFrameContainer:ApplyToFrames("group", CompactRaidGroup_UpdateBorder);
		maxPerLine = 5;
	elseif raidGroupDisplayType == Enum.RaidGroupDisplayType.SeparateGroupsHorizontal then
		orientation = "horizontal";
		CompactRaidFrameContainer:ApplyToFrames("group", CompactRaidGroup_UpdateBorder);
		maxPerLine = 5;
	elseif raidGroupDisplayType == Enum.RaidGroupDisplayType.CombineGroupsVertical then
		orientation = "vertical";
		maxPerLine = self:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Raid, Enum.EditModeUnitFrameSetting.RowSize);
	else
		orientation = "horizontal";
		maxPerLine = self:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Raid, Enum.EditModeUnitFrameSetting.RowSize);
	end

	-- Setting CompactRaidFrameContainer to a really big size because the flow container bases its calculations off the size of the container itself
	-- The layout call below shrinks the container back down to fit the actual contents after they have been anchored
	FlowContainer_SetOrientation(CompactRaidFrameContainer, orientation);
	FlowContainer_SetMaxPerLine(CompactRaidFrameContainer, maxPerLine);
	CompactRaidFrameContainer:TryUpdate();
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:AreRaidFramesForcedShown()
	return self:IsEditModeActive() and self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowRaidFrames);
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:GetNumRaidGroupsForcedShown()
	if self:AreRaidFramesForcedShown() then
		local viewRaidSize = self:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Raid, Enum.EditModeUnitFrameSetting.ViewRaidSize);
		if viewRaidSize == Enum.ViewRaidSize.Ten then
			return 2;
		elseif viewRaidSize == Enum.ViewRaidSize.TwentyFive then
			return 5;
		elseif viewRaidSize == Enum.ViewRaidSize.Forty then
			return 8;
		else
			return 0;
		end
	else
		return 0;
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:GetNumRaidMembersForcedShown()
	if self:AreRaidFramesForcedShown() then
		local viewRaidSize = self:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Raid, Enum.EditModeUnitFrameSetting.ViewRaidSize);
		if viewRaidSize == Enum.ViewRaidSize.Ten then
			return 10;
		elseif viewRaidSize == Enum.ViewRaidSize.TwentyFive then
			return 25;
		elseif viewRaidSize == Enum.ViewRaidSize.Forty then
			return 40;
		else
			return 0;
		end
	else
		return 0;
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:GetRaidFrameWidth(systemIndex)
	local raidFrameWidth = self:GetSettingValue(Enum.EditModeSystem.UnitFrame, systemIndex, Enum.EditModeUnitFrameSetting.FrameWidth);
	return (raidFrameWidth and raidFrameWidth > 0) and raidFrameWidth or NATIVE_UNIT_FRAME_WIDTH;
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:GetRaidFrameHeight(systemIndex)
	local raidFrameHeight = self:GetSettingValue(Enum.EditModeSystem.UnitFrame, systemIndex, Enum.EditModeUnitFrameSetting.FrameHeight);
	return (raidFrameHeight and raidFrameHeight > 0) and raidFrameHeight or NATIVE_UNIT_FRAME_HEIGHT;
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:ShouldRaidFrameUseHorizontalRaidGroups(systemIndex)
	if systemIndex == Enum.EditModeUnitFrameSystemIndices.Party then
		return self:GetSettingValueBool(Enum.EditModeSystem.UnitFrame, systemIndex, Enum.EditModeUnitFrameSetting.UseHorizontalGroups);
	elseif systemIndex == Enum.EditModeUnitFrameSystemIndices.Raid then
		return self:DoesSettingValueEqual(Enum.EditModeSystem.UnitFrame, systemIndex, Enum.EditModeUnitFrameSetting.RaidGroupDisplayType, Enum.RaidGroupDisplayType.SeparateGroupsHorizontal);
	end

	return false;
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:ShouldRaidFrameDisplayBorder(systemIndex)
	return self:GetSettingValueBool(Enum.EditModeSystem.UnitFrame, systemIndex, Enum.EditModeUnitFrameSetting.DisplayBorder);
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:ShouldRaidFrameShowSeparateGroups()
	local raidGroupDisplayType = self:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Raid, Enum.EditModeUnitFrameSetting.RaidGroupDisplayType);
	return (raidGroupDisplayType == Enum.RaidGroupDisplayType.SeparateGroupsVertical) or (raidGroupDisplayType == Enum.RaidGroupDisplayType.SeparateGroupsHorizontal);
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:UpdateActionBarLayout(systemFrame)
	if EditModeUtil:IsBottomAnchoredActionBar(systemFrame) then
		self:UpdateBottomActionBarPositions();
	elseif EditModeUtil:IsRightAnchoredActionBar(systemFrame) or systemFrame == MinimapCluster then
		self:UpdateRightActionBarPositions();
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:UpdateActionBarPositions()
	self:UpdateBottomActionBarPositions();
	self:UpdateRightActionBarPositions();
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:UpdateRightActionBarPositions()
	if not self:IsInitialized() or self.layoutApplyInProgress then
		return;
	end

	local barsToUpdate = { MultiBarRight, MultiBarLeft };

	-- Determine new scale
	local topLimit = MinimapCluster:IsInDefaultPosition() and (MinimapCluster:GetBottom() - 10) or UIParent:GetTop();
	local bottomLimit = MicroButtonAndBagsBar:GetTop() + 24;
	local availableSpace = topLimit - bottomLimit;
	local multiBarHeight = MultiBarRight:GetHeight();
	local newScale = multiBarHeight > availableSpace and availableSpace / multiBarHeight or 1;

	-- Update bars
	local offsetX = RIGHT_ACTION_BAR_DEFAULT_OFFSET_X;
	local offsetY = RIGHT_ACTION_BAR_DEFAULT_OFFSET_Y;
	local leftMostBar = nil;
	for index, bar in ipairs(barsToUpdate) do
		if bar and bar:IsShown() then
			local isInDefaultPosition = bar:IsInDefaultPosition();
			bar:SetScale(isInDefaultPosition and newScale or 1);

			if isInDefaultPosition then
				local leftMostBarWidth = leftMostBar and -leftMostBar:GetWidth() - 5 or 0;
				offsetX = offsetX + leftMostBarWidth;

				bar:ClearAllPoints();
				bar:SetPoint("RIGHT", UIParent, "RIGHT", offsetX, offsetY);

				-- Bar position changed so we should update our flyout direction
				if bar.UpdateSpellFlyoutDirection then
					bar:UpdateSpellFlyoutDirection();
				end

				leftMostBar = bar;
			end
		end
	end

	UIParent_ManageFramePositions();
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:UpdateBottomActionBarPositions()
	if not self:IsInitialized() or self.layoutApplyInProgress then
		return;
	end

	local barsToUpdate = { MainMenuBar, MultiBarBottomLeft, MultiBarBottomRight, StanceBar, PetActionBar, PossessActionBar, MainMenuBarVehicleLeaveButton };

	local offsetX = 0;
	local offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y;

	if OverrideActionBar and OverrideActionBar:IsShown() then
		local xpBarHeight = OverrideActionBar.xpBar:IsShown() and OverrideActionBar.xpBar:GetHeight() or 0;
		offsetY = OverrideActionBar:GetHeight() + xpBarHeight + 10;
	end

	local topMostBar = nil;

	local layoutInfo = self:GetActiveLayoutInfo();
	local isPresetLayout = layoutInfo.layoutType == Enum.EditModeLayoutType.Preset;
	local isOverrideLayout = layoutInfo.layoutType == Enum.EditModeLayoutType.Override; 

	for index, bar in ipairs(barsToUpdate) do
		if bar and bar:IsShown() and bar:IsInDefaultPosition() then
			bar:ClearAllPoints();

			if bar.useDefaultAnchors and isPresetLayout then
				local anchorInfo = EditModePresetLayoutManager:GetPresetLayoutSystemAnchorInfo(layoutInfo.layoutIndex, bar.system, bar.systemIndex);
				bar:SetPoint(anchorInfo.point, anchorInfo.relativeTo, anchorInfo.relativePoint, anchorInfo.offsetX, anchorInfo.offsetY);
			elseif bar.useDefaultAnchors and isOverrideLayout then
				local anchorInfo = EditModePresetLayoutManager:GetOverrideLayoutSystemAnchorInfo(layoutInfo.layoutIndex, bar.system, bar.systemIndex);
				bar:SetPoint(anchorInfo.point, anchorInfo.relativeTo, anchorInfo.relativePoint, anchorInfo.offsetX, anchorInfo.offsetY);
			else
				if not topMostBar then
					offsetX = -bar:GetWidth() / 2;
				end

				local topBarHeight = topMostBar and topMostBar:GetHeight() + 5 or 0;
				offsetY = offsetY + topBarHeight;

				bar:ClearAllPoints();
				bar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", offsetX, offsetY);

				topMostBar = bar;
			end

			-- Bar position changed so we should update our flyout direction
			if bar.UpdateSpellFlyoutDirection then
				bar:UpdateSpellFlyoutDirection();
			end
		end
	end

	UIParent_ManageFramePositions();
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:SelectSystem(selectFrame)
	print("hier dadfasdf")
	--custom we hgihlight all frames of this system of the same plaeyrtype
	--if not self:IsEditModeLocked() then
		local function selectMatchingSystem(index, systemFrame)
			print('one')
			if systemFrame.system == selectFrame.system and systemFrame.PlayerType == selectFrame.PlayerType then
				print("3")
				systemFrame:SelectSystem();
			else
				print("2")
				-- Only highlight a system if it was already highlighted
				if systemFrame.isHighlighted then
					systemFrame:HighlightSystem();
				end
			end
		end
		print("dfasdf")
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
	EditModeSystemSettingsDialog:Hide();
end


function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:UpdateLayoutInfo(layoutInfo, reconcileLayouts)
	self.layoutApplyInProgress = true;
	self.layoutInfo = layoutInfo;

	if reconcileLayouts then
		self:ReconcileLayoutsWithModern();
	end

	local savedLayouts = self.layoutInfo.layouts;
	self.layoutInfo.layouts = EditModePresetLayoutManager:GetCopyOfPresetLayouts();
	tAppendAll(self.layoutInfo.layouts, savedLayouts);

	self:UpdateLayoutCounts(savedLayouts);

	self:InitSystemAnchors();
	self:UpdateSystems();
	self:ClearActiveChangesFlags();

	if self:IsShown() then
		self:UpdateDropdownOptions();
	end

	self.layoutApplyInProgress = false;
	self:UpdateActionBarPositions();

	local forceInvokeYes = true;
	self:InvokeOnAnyEditModeSystemAnchorChanged(forceInvokeYes);
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

	if isUserInput then
		self:OnAccountSettingChanged(Enum.EditModeAccountSetting.EnableSnap, enableSnap);
	else
		self.EnableSnapCheckButton:SetControlChecked(enableSnap);
	end
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

local function GetNewLayoutText(disabled)
	if disabled then
		return HUD_EDIT_MODE_NEW_LAYOUT_DISABLED:format(CreateAtlasMarkup("editmode-new-layout-plus-disabled"));
	end
	return HUD_EDIT_MODE_NEW_LAYOUT:format(CreateAtlasMarkup("editmode-new-layout-plus"));
end

local function GetDisableReason(disableOnMaxLayouts, disableOnActiveChanges)
	if disableOnMaxLayouts and EditModeManagerFrame:AreLayoutsFullyMaxed() then
		return maxLayoutsErrorText;
	elseif disableOnActiveChanges and EditModeManagerFrame:HasActiveChanges() then
		return HUD_EDIT_MODE_UNSAVED_CHANGES;
	end
	return nil;
end

local function SetPresetEnabledState(elementDescription, disableOnMaxLayouts, disableOnActiveChanges)
	local reason = GetDisableReason(disableOnMaxLayouts, disableOnActiveChanges);
	local enabled = reason == nil;
	elementDescription:SetEnabled(enabled);
	
	if not enabled then
		elementDescription:SetTooltip(function(tooltip, elementDescription)
			GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
			GameTooltip_AddErrorLine(tooltip, reason);
		end);
	end
end

function BattleGroundEnemies.Mixins.CustomEditModeManagerFrameMixin:UpdateDropdownOptions()
	local function IsSelected(index)
		return self.layoutInfo.activeLayout == index;
	end

	local function SetSelected(index)
		if not self:IsLayoutSelected(index) then
			if self:HasActiveChanges() then
				self:ShowRevertWarningDialog(index);
			else
				self:SelectLayout(index);
			end
		end
	end

	local layoutTbls, hasCharacterLayouts = self:CreateLayoutTbls();

	self.LayoutDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_EDIT_MODE_MANAGER");

		local lastLayoutType = nil;
		for _, layoutTbl in ipairs(layoutTbls) do
			local layoutInfo = layoutTbl.layoutInfo;
			local index = layoutTbl.index;
			local layoutType = layoutInfo.layoutType;

			if lastLayoutType and lastLayoutType ~= layoutType then
				rootDescription:CreateDivider();
			end
			lastLayoutType = layoutType;

			local isUserLayout = layoutType == Enum.EditModeLayoutType.Account or layoutType == Enum.EditModeLayoutType.Server;
			local isPreset = layoutType == Enum.EditModeLayoutType.Preset;
			local text = isPreset and HUD_EDIT_MODE_PRESET_LAYOUT:format(layoutInfo.layoutName) or layoutInfo.layoutName;

			local radio = rootDescription:CreateRadio(text, IsSelected, SetSelected, index);
			if isUserLayout then
				local copyButton = radio:CreateButton(HUD_EDIT_MODE_COPY_LAYOUT, function()
					self:ShowNewLayoutDialog(layoutInfo);
				end);

				local layoutsMaxed = EditModeManagerFrame:AreLayoutsFullyMaxed();
				if layoutsMaxed or self:HasActiveChanges() then
					copyButton:SetEnabled(false);

					local tooltipText = layoutsMaxed and maxLayoutsCopyErrorText or HUD_EDIT_MODE_ERROR_COPY;
					copyButton:SetTooltip(function(tooltip, elementDescription)
						GameTooltip_SetTitle(tooltip, HUD_EDIT_MODE_COPY_LAYOUT);
						GameTooltip_AddErrorLine(tooltip, tooltipText);
					end);
				end

				radio:CreateButton(HUD_EDIT_MODE_RENAME_LAYOUT, function()
					self:ShowRenameLayoutDialog(index, layoutInfo);
				end);
				
				radio:DeactivateSubmenu();

				radio:AddInitializer(function(button, description, menu)
					local gearButton = MenuTemplates.AttachAutoHideGearButton(button);
					gearButton:SetPoint("RIGHT");
					gearButton:SetScript("OnClick", function()
						description:ForceOpenSubmenu();
					end);
				
					MenuUtil.HookTooltipScripts(gearButton, function(tooltip)
						GameTooltip_SetTitle(tooltip, HUD_EDIT_MODE_RENAME_OR_COPY_LAYOUT);
					end);

					local cancelButton = MenuTemplates.AttachAutoHideCancelButton(button);
					cancelButton:SetPoint("RIGHT", gearButton, "LEFT", -3, 0);
					cancelButton:SetScript("OnClick", function()
						self:ShowDeleteLayoutDialog(index, layoutInfo);
						menu:Close();
					end);

					MenuUtil.HookTooltipScripts(cancelButton, function(tooltip)
						GameTooltip_SetTitle(tooltip, HUD_EDIT_MODE_DELETE_LAYOUT);
					end);
				end);
			else
				radio:AddInitializer(function(button, description, menu)
					local gearButton = MenuTemplates.AttachAutoHideGearButton(button);
					gearButton:SetPoint("RIGHT");
					gearButton:SetScript("OnClick", function()
						self:ShowNewLayoutDialog(layoutInfo);
						menu:Close();
					end);

					MenuUtil.HookTooltipScripts(gearButton, function(tooltip)
						GameTooltip_SetTitle(tooltip, HUD_EDIT_MODE_COPY_LAYOUT);
					end);
				end);
			end
		end

		if hasCharacterLayouts then
			rootDescription:CreateTitle(characterLayoutHeaderText);
		end

		rootDescription:CreateDivider();

		-- new layout
		local disabled = GetDisableReason(disableOnMaxLayouts, not disableOnActiveChanges) ~= nil;
		local text = GetNewLayoutText(disabled);
		local newLayoutButton = rootDescription:CreateButton(text, function()
			self:ShowNewLayoutDialog();
		end);
		SetPresetEnabledState(newLayoutButton, disableOnMaxLayouts, not disableOnActiveChanges);
		
		-- import layout
		local importLayoutButton = rootDescription:CreateButton(HUD_EDIT_MODE_IMPORT_LAYOUT, function()
			self:ShowImportLayoutDialog();
		end);
		SetPresetEnabledState(importLayoutButton, disableOnMaxLayouts, disableOnActiveChanges);

		-- share
		local shareSubmenu = rootDescription:CreateButton(HUD_EDIT_MODE_SHARE_LAYOUT);
		shareSubmenu:CreateButton(HUD_EDIT_MODE_COPY_TO_CLIPBOARD, function()
			self:CopyActiveLayoutToClipboard();
		end);
	end);
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
