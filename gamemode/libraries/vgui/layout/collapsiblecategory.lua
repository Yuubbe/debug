local PANEL = {}

local _HEADER_H = 36

function PANEL:Init()
	self:SetPaintBackground(false)
	self:SetCursor("hand")

	self._radius       = gThemeRadius("sm")
	self._bgColor      = nil
	self._bgAlpha      = gThemeAlpha("mid")

	self._headerColor  = nil
	self._headerAlpha  = gThemeAlpha("high")
	self._headerH      = _HEADER_H

	self._border       = false
	self._borderColor  = nil
	self._borderAlpha  = gThemeAlpha("border")
	self._borderSize   = 1

	self._font         = "OxaniumMedium"
	self._size         = 13
	self._titleColor   = nil

	self._expanded     = true
	self._expandAlpha  = 1
	self._hoverAlpha   = 0
	self._arrowAngle   = 0

	self._contentH     = 0
	self._padX         = 0
	self._padY         = 4
	self._spaceY       = 4

	self._content      = vgui.Create("DPanel", self)
	self._content:SetPaintBackground(false)

	self._animating    = false
	self._animT        = 0
	self._animFrom     = 0
	self._animTo       = 0
	self._animDur      = 0.2

	self._title        = ""
end

function PANEL:gSetRadius(r)
	self._radius = r
end

function PANEL:gSetBgColor(color, alpha)
	self._bgColor = color
	if alpha then self._bgAlpha = alpha end
end

function PANEL:gSetHeaderColor(color, alpha)
	self._headerColor = color
	if alpha then self._headerAlpha = alpha end
end

function PANEL:gSetHeaderHeight(h)
	self._headerH = h
	self:InvalidateLayout()
end

function PANEL:gSetBorder(enabled, color, alpha, size)
	self._border      = enabled
	self._borderColor = color
	self._borderAlpha = alpha or gThemeAlpha("border")
	self._borderSize  = size  or 1
end

function PANEL:gSetFont(font, size)
	self._font = font or "OxaniumMedium"
	self._size = size or 13
end

function PANEL:gSetTitleColor(color)
	self._titleColor = color
end

function PANEL:gSetTitle(text)
	self._title = text
end

function PANEL:gSetExpanded(expanded, instant)
	self._expanded = expanded

	if instant then
		self._expandAlpha = expanded and 1 or 0
		self._arrowAngle  = expanded and 0 or -90
		self._animating   = false
		self:InvalidateLayout()
		return
	end

	self._animating = true
	self._animT     = 0
	self._animFrom  = self._expandAlpha
	self._animTo    = expanded and 1 or 0
end

function PANEL:gGetExpanded()
	return self._expanded
end

function PANEL:gSetPadding(x, y)
	self._padX = x or 0
	self._padY = y or x or 4
	self:InvalidateLayout()
end

function PANEL:gSetSpacing(y)
	self._spaceY = y or 4
	self:InvalidateLayout()
end

function PANEL:GetContent()
	return self._content
end

function PANEL:gAddItem(panel)
	panel:SetParent(self._content)
	self:InvalidateLayout()
	return panel
end

function PANEL:OnToggle(expanded) end

function PANEL:OnMousePressed(code)
	if code ~= MOUSE_LEFT then return end
	local _, my = self:CursorPos()
	local headerH = gRespY(self._headerH)
	if my > headerH then return end

	self:gSetExpanded(not self._expanded)
	self:OnToggle(self._expanded)
end

function PANEL:Think()
	local speed = FrameTime() * 10
	local mx, my = self:CursorPos()
	local w, h   = self:GetSize()
	local headerH = gRespY(self._headerH)
	local hovering = mx >= 0 and mx <= w and my >= 0 and my <= headerH

	self._hoverAlpha = math.Clamp(
		self._hoverAlpha + ((hovering and gThemeAlpha("hover") or 0) - self._hoverAlpha) * speed,
		0, gThemeAlpha("hover")
	)

	if self._animating then
		self._animT = self._animT + FrameTime() / self._animDur
		local t     = math.Clamp(self._animT, 0, 1)
		local ease  = t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t

		self._expandAlpha = self._animFrom + (self._animTo - self._animFrom) * ease

		if t >= 1 then
			self._expandAlpha = self._animTo
			self._animating   = false
		end

		self:InvalidateLayout()
	end

	local targetAngle = self._expanded and 0 or -90
	self._arrowAngle  = self._arrowAngle + (targetAngle - self._arrowAngle) * speed
end

function PANEL:PerformLayout(w, h)
	local headerH = gRespY(self._headerH)
	local padX    = gRespX(self._padX)
	local padY    = gRespY(self._padY)

	self._content:SetPos(padX, headerH + padY)
	self._content:SetWide(w - padX * 2)
	self._content:SizeToChildren(false, true)

	self._contentH = self._content:GetTall()
	local visH     = self._contentH * self._expandAlpha

	self._content:SetTall(self._contentH)
	self._content:SetAlpha(self._expandAlpha * 255)

	self:SetTall(headerH + (self._expandAlpha > 0.01 and math.floor(visH + padY) or 0))
end

function PANEL:Paint(w, h)
	local r       = self._radius
	local headerH = gRespY(self._headerH)
	local bg      = self._bgColor or gTheme("surface")
	local hc      = self._headerColor or gTheme("elevated")
	local font    = self._font .. ":" .. self._size
	local padX    = gRespX(16)

	if self._expandAlpha > 0.01 then
		draw.RoundedBox(r, 0, 0, w, h, Color(bg.r, bg.g, bg.b, self._bgAlpha * self._expandAlpha))
	end

	local roundBL = self._expandAlpha < 0.05
	local roundBR = roundBL
	draw.RoundedBoxEx(r, 0, 0, w, headerH, Color(hc.r, hc.g, hc.b, self._headerAlpha), true, true, roundBL, roundBR)

	if self._hoverAlpha > 0 then
		local hover = gTheme("border")
		draw.RoundedBoxEx(r, 0, 0, w, headerH, Color(hover.r, hover.g, hover.b, self._hoverAlpha), true, true, roundBL, roundBR)
	end

	local tc = self._titleColor or gTheme("text")
	draw.SimpleText(self._title, font, padX, headerH * 0.5, tc, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	local ac = self._expanded and gTheme("accent") or gTheme("textDim")
	draw.SimpleText("▼", "OxaniumRegular:10", w - gRespX(20), headerH * 0.5, ac, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if self._expandAlpha > 0.01 and self._border then
		local bc = self._borderColor or gTheme("border")
		surface.SetDrawColor(bc.r, bc.g, bc.b, self._borderAlpha)
		surface.DrawOutlinedRect(0, 0, w, h, self._borderSize)
	end

	if self._expandAlpha > 0.01 then
		local sep = gTheme("border")
		surface.SetDrawColor(sep.r, sep.g, sep.b, gThemeAlpha("sep"))
		surface.DrawLine(0, headerH, w, headerH)
	end
end

vgui.Register("gCollapsibleCategory", PANEL, "DPanel")