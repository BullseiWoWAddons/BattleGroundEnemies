


function BattleGroundEnemies:NewContainer(playerButton, createChildF, setupChildF)
	local f = CreateFrame("Frame", nil, playerButton)

	f.childFrames = {}
	f.inputs = {}

	function f:Display()
		local config = self.config.Container
		local previousFrame = self
		local verticalGrowdirection = config.VerticalGrowdirection
		local horizontalGrowdirection = config.HorizontalGrowDirection
		local framesPerRow = config.IconsPerRow
		local horizontalSpacing = config.HorizontalSpacing
		local verticalSpacing = config.VerticalSpacing
		local iconSize = config.IconSize
		local useButtonHeightAsSize = config.UseButtonHeightAsSize


		if useButtonHeightAsSize then iconSize = playerButton:GetHeight() end

		local growLeft = horizontalGrowdirection == "leftwards"
		local growUp = verticalGrowdirection == "upwards"
		self:Show()
		local framesInRow = 0
		local firstFrameInRow
		local width = 0
		local widestRow = 0
		local height = 0
		local numInputs = #self.inputs
		local pointX, relativePointX, offsetX, offsetY, pointY, relativePointY, pointNewRowY, relativePointNewRowY

		if growLeft then
			pointX = "RIGHT"
			relativePointX = "LEFT"
			offsetX = -horizontalSpacing
		else
			pointX = "LEFT"
			relativePointX = "RIGHT"
			offsetX = horizontalSpacing
		end

		if growUp then
			pointY = "BOTTOM"
			relativePointY = "BOTTOM"
			pointNewRowY = "BOTTOM"
			relativePointNewRowY = "TOP"
			offsetY = verticalSpacing
		else
			pointY = "TOP"
			relativePointY = "TOP"
			pointNewRowY = "TOP"
			relativePointNewRowY = "BOTTOM"
			offsetY = -verticalSpacing
		end

		for i = 1, numInputs do
			local childFrame = self.childFrames[i]
			if not childFrame then
				childFrame = createChildF(playerButton, f)
				function childFrame:Remove()
					table.remove(f.inputs, self.key)
					f:Display()
				end
			end

			childFrame:SetSize(iconSize, iconSize)


			self.childFrames[i] = childFrame
			childFrame.key = i


			childFrame.input = self.inputs[i]
			setupChildF(f, childFrame, self.inputs[i])
			

			childFrame:ClearAllPoints()


			if framesInRow < framesPerRow then
				if i == 1 then
					childFrame:SetPoint(pointY..pointX, previousFrame, pointY..pointX, 0, 0)
					firstFrameInRow = childFrame
				else
					childFrame:SetPoint(pointY..pointX, previousFrame, relativePointY..relativePointX, offsetX, 0)
				end
				framesInRow = framesInRow + 1
				width = width + iconSize  + horizontalSpacing
				if width > widestRow then
					widestRow = width
				end
			else
				width = 0
				childFrame:SetPoint(pointNewRowY..pointX, firstFrameInRow, relativePointNewRowY..relativePointX, 0, offsetY)
				framesInRow = 1
				firstFrameInRow = childFrame
				height = height + iconSize + verticalSpacing
			end
			previousFrame = childFrame
	--		print("previousFrame inside", previousFrame)
			childFrame:Show()
		end

		for i = numInputs + 1, #self.childFrames do --hide all unused frames
			local childFrame = self.childFrames[i]
			childFrame:Hide()
		end

		if widestRow == 0 then
			self:Hide()
		else
			self:SetWidth(widestRow - horizontalSpacing)
			self:SetHeight(height + iconSize)
		end
	end


	f:SetScript("OnHide", function(self)
		self:SetWidth(0.001)
		self:SetHeight(0.001)
	end)

	function f:ResetInputs()
		wipe(self.inputs)
	end

	function f:NewInput(inputData)
		local key= #self.inputs + 1
		inputData.key = key
		self.inputs[key] = inputData
		return self.inputs[key]
	end

	function f:FindInputByAttribute(attribute, value)
		for i = 1, #self.inputs do
			if self.inputs[i][attribute] == value then
				return self.inputs[i]
			end
		end
	end

	function f:UpdateInput(input, inputData)
		Mixin(input, inputData)
		return input
	end

	function f:Reset()
		f:ResetInputs()
		self:Display()
	end

	function f:ApplyAllSettings()
		self:Display()
		for i = 1, #self.childFrames do
			local childFrame = self.childFrames[i]
			if childFrame.ApplyChildFrameSettings then childFrame:ApplyChildFrameSettings() end
		end
	end
	return f
end