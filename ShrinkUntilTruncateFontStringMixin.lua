if not ShrinkUntilTruncateFontStringMixin then
	ShrinkUntilTruncateFontStringMixin = {}
	function ShrinkUntilTruncateFontStringMixin:SetFontObjectsToTry(...)
		self.fontObjectsToTry = { ... };
		if self:GetText() then
			self:ApplyFontObjects();
		end
	end
	
	function ShrinkUntilTruncateFontStringMixin:ApplyFontObjects()
		if not self.fontObjectsToTry then
			error("No fonts applied to ShrinkUntilTruncateFontStringMixin, call SetFontObjectsToTry first");
		end
	
		for i, fontObject in ipairs(self.fontObjectsToTry) do
			self:SetFontObject(fontObject);
			if not self:IsTruncated() then
				break;
			end
		end
	end
	
	function ShrinkUntilTruncateFontStringMixin:SetText(text)
		if not self:GetFont() then
			if not self.fontObjectsToTry then
				error("No fonts applied to ShrinkUntilTruncateFontStringMixin, call SetFontObjectsToTry first");
			end
			self:SetFontObject(self.fontObjectsToTry[1]);
		end
	
		GetFontStringMetatable().__index.SetText(self, text);
		self:ApplyFontObjects();
	end
	
	function ShrinkUntilTruncateFontStringMixin:SetFormattedText(format, ...)
		if not self:GetFont() then
			if not self.fontObjectsToTry then
				error("No fonts applied to ShrinkUntilTruncateFontStringMixin, call SetFontObjectsToTry first");
			end
			self:SetFontObject(self.fontObjectsToTry[1]);
		end
	
		GetFontStringMetatable().__index.SetFormattedText(self, format, ...);
		self:ApplyFontObjects();
	end
end
