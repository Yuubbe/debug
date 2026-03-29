local PANEL = {}

function PANEL:Init()
	self:SetCursor("hand")
	self:SetPaintBackground(false)

	self._radius      = gThemeRadius("sm")
	self._bgColor     = nil
	self._bgAlpha     = gThemeAlpha("mid")
	self._trackColor  = nil
	self._fillColor   = nil

	self._border      = false
	self._borderColor = nil
	self._borderAlpha = gThemeAlpha("border")
	self._borderSize  = 1

	self._font        = "OxaniumRegular"
	self._size        = 11
	self._textColor   = nil

	self._min         = 0
	self._max         = 100
	self._value       = 0
	self._step        = 1
	self._decimals    = 0

	self._showValue   = true
	self._valueWidth  = 42
	self._padX        = 8

	self._dragging    = false
	self._hoverAlpha  = 0
	self._knobAlpha   = 200
	self._disabled    = false

	self._trackH      = 4
	self._knobSize    = 14
end

function PANEL:gSetRadius(r)
	self._radius = r
end

function PANEL:gSetBgColor(color, alpha)
	self._bgColor = color
	if alpha then self._bgAlpha = alpha end
end

function PANEL:gSetTrackColor(color)
	self._trackColor = color
end

function PANEL:gSetFillColor(color)
	self._fillColor = color
end

function PANEL:gSetBorder(enabled, color, alpha, size)
	self._border      = enabled
	self._borderColor = color
	self._borderAlpha = alpha or gThemeAlpha("border")
	self._borderSize  = size  or 1
end

function PANEL:gSetFont(font, size)
	self._font = font or "OxaniumRegular"
	self._size = size or 11
end

function PANEL:gSetTextColor(color)
	self._textColor = color
end

function PANEL:gSetRange(min, max)
	self._min   = min or 0
	self._max   = max or 100
	self._value = math.Clamp(self._value, self._min, self._max)
end

function PANEL:gSetStep(step)
	self._step     = step or 1
	self._decimals = (tostring(step):find("%.") and #tostring(step):match("%.(.*)") or 0)
end

function PANEL:gSetValue(val)
	local stepped = math.Round(val / self._step) * self._step
	self._value   = math.Clamp(stepped, self._min, self._max)
	self:OnChange(self._value)
end

function PANEL:gGetValue()
	return self._value
end

function PANEL:gSetShowValue(enabled, width)
	self._showValue  = enabled
	self._valueWidth = width or 42
end

function PANEL:gSetTrackHeight(h)
	self._trackH = h
end

function PANEL:gSetKnobSize(s)
	self._knobSize = s
end

function PANEL:gSetDisabled(disabled)
	self._disabled = disabled
	self:SetMouseInputEnabled(not disabled)
end

function PANEL:OnChange(value) end

function PANEL:_trackX()
	local padX  = gRespX(self._padX)
	local valW  = self._showValue and gRespX(self._valueWidth) or 0
	return padX, self:GetWide() - padX - valW
end

function PANEL:_valueFromMouse()
	local mx       = self:CursorPos()
	local startX, endX = self:_trackX()
	local trackW   = endX - startX
	local fraction = math.Clamp((mx - startX) / trackW, 0, 1)
	local raw      = self._min + fraction * (self._max - self._min)
	local stepped  = math.Round(raw / self._step) * self._step
	return math.Clamp(stepped, self._min, self._max)
end

function PANEL:OnMousePressed(code)
	if code ~= MOUSE_LEFT then return end
	if self._disabled then return end
	self._dragging = true
	self:MouseCapture(true)
	self:gSetValue(self:_valueFromMouse())
end

function PANEL:OnMouseReleased(code)
	if code ~= MOUSE_LEFT then return end
	self._dragging = false
	self:MouseCapture(false)
end

function PANEL:Think()
	if self._dragging then
		self:gSetValue(self:_valueFromMouse())
	end

	local speed    = FrameTime() * 10
	local mx, my   = self:CursorPos()
	local w, h     = self:GetSize()
	local hovering = not self._disabled and mx >= 0 and mx <= w and my >= 0 and my <= h

	self._hoverAlpha = math.Clamp(
		self._hoverAlpha + ((hovering and gThemeAlpha("hover") or 0) - self._hoverAlpha) * speed,
		0, gThemeAlpha("hover")
	)

	local targetKnob = (hovering or self._dragging) and 255 or 200
	self._knobAlpha  = math.Clamp(
		self._knobAlpha + (targetKnob - self._knobAlpha) * speed,
		0, 255
	)
end

function PANEL:Paint(w, h)
	local r        = self._radius
	local padX     = gRespX(self._padX)
	local trackH   = gRespY(self._trackH)
	local knobS    = gRespX(self._knobSize)
	local startX, endX = self:_trackX()
	local trackW   = endX - startX
	local trackY   = (h - trackH) * 0.5
	local fraction = (self._value - self._min) / (self._max - self._min)
	local fillW    = trackW * fraction
	local knobX    = startX + fillW - knobS * 0.5

	if self._bgColor then
		draw.RoundedBox(r, 0, 0, w, h, Color(self._bgColor.r, self._bgColor.g, self._bgColor.b, self._bgAlpha))
	end

	local tc = self._trackColor or gTheme("elevated")
	draw.RoundedBox(gThemeRadius("sm"), startX, trackY, trackW, trackH, Color(tc.r, tc.g, tc.b, 255))

	if fillW > 0 then
		local fc = self._fillColor or gTheme("accent")
		local fa = self._disabled and gThemeAlpha("disabled") or 255
		draw.RoundedBox(gThemeRadius("sm"), startX, trackY, fillW, trackH, Color(fc.r, fc.g, fc.b, fa))
	end

	local kc = self._fillColor or gTheme("accent")
	local ka = self._disabled and gThemeAlpha("disabled") or self._knobAlpha
	draw.RoundedBox(knobS, knobX, (h - knobS) * 0.5, knobS, knobS, Color(kc.r, kc.g, kc.b, ka))

	if self._hoverAlpha > 0 and not self._disabled then
		local hc = gTheme("border")
		draw.RoundedBox(knobS, knobX, (h - knobS) * 0.5, knobS, knobS, Color(hc.r, hc.g, hc.b, self._hoverAlpha))
	end

	if self._showValue then
		local font  = self._font .. ":" .. self._size
		local tc2   = self._textColor or gTheme("textDim")
		local valW  = gRespX(self._valueWidth)
		local label = string.format("%." .. self._decimals .. "f", self._value)
		draw.SimpleText(label, font, w - padX * 0.5, h * 0.5, tc2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end

	if self._border then
		local bc = self._borderColor or gTheme("border")
		surface.SetDrawColor(bc.r, bc.g, bc.b, self._borderAlpha)
		surface.DrawOutlinedRect(0, 0, w, h, self._borderSize)
	end
end

vgui.Register("gNumSlider", PANEL, "DPanel")