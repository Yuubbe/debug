local PANEL = {}

function PANEL:Init()
	self:SetText("")
	self:SetTextColor(gTheme("text"))
	self:SetFont("OxaniumRegular:14")
	self:SetContentAlignment(4)

	self._font      = "OxaniumRegular"
	self._size      = 14
	self._color     = nil
	self._alignX    = TEXT_ALIGN_LEFT
	self._alignY    = TEXT_ALIGN_CENTER
	self._autoSize  = false
	self._uppercase = false
	self._text      = ""
end

function PANEL:gSetFont(font, size)
	self._font = font or "OxaniumRegular"
	self._size = size or 14
	self:SetFont(self._font .. ":" .. self._size)
end

function PANEL:gSetColor(color)
	self._color = color
	self:SetTextColor(color)
end

function PANEL:gSetAlign(alignX, alignY)
	self._alignX = alignX or TEXT_ALIGN_LEFT
	self._alignY = alignY or TEXT_ALIGN_CENTER

	local mapping = {
		[TEXT_ALIGN_LEFT]   = { [TEXT_ALIGN_TOP]    = 7, [TEXT_ALIGN_CENTER] = 4, [TEXT_ALIGN_BOTTOM] = 1 },
		[TEXT_ALIGN_CENTER] = { [TEXT_ALIGN_TOP]    = 8, [TEXT_ALIGN_CENTER] = 5, [TEXT_ALIGN_BOTTOM] = 2 },
		[TEXT_ALIGN_RIGHT]  = { [TEXT_ALIGN_TOP]    = 9, [TEXT_ALIGN_CENTER] = 6, [TEXT_ALIGN_BOTTOM] = 3 },
	}

	local alignV = mapping[self._alignX] and mapping[self._alignX][self._alignY]
	if alignV then
		self:SetContentAlignment(alignV)
	end
end

function PANEL:gSetText(text)
	self._text = text
	if self._uppercase then
		self:SetText(string.upper(text))
	else
		self:SetText(text)
	end
end

function PANEL:gSetUppercase(enabled)
	self._uppercase = enabled
	self:gSetText(self._text)
end

function PANEL:gSetAutoSize(enabled)
	self._autoSize = enabled
	if enabled then
		self:SizeToContents()
	end
end

function PANEL:PerformLayout(w, h)
	if self._autoSize then
		self:SizeToContents()
	end
end

vgui.Register("gLabel", PANEL, "DLabel")