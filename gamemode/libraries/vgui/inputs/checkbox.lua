local PANEL = {}

function PANEL:Init()
	self:SetCursor("hand")
	self:SetPaintBackground(false)

	self._radius      = gThemeRadius("sm")
	self._size        = 18

	self._checked     = false
	self._disabled    = false

	self._bgColor     = nil
	self._bgAlpha     = gThemeAlpha("mid")
	self._checkColor  = nil

	self._border      = true
	self._borderColor = nil
	self._borderAlpha = gThemeAlpha("border")
	self._borderSize  = 1

	self._hoverAlpha  = 0
	self._checkAlpha  = 0

	self._state       = "default"
	self._stateColors = {
		success = "success",
		danger  = "danger",
		warning = "warning",
		accent  = "accent",
	}
end

function PANEL:gSetRadius(r)
	self._radius = r
end

function PANEL:gSetBoxSize(size)
	self._size = size
	self:gSetSize(size, size)
end

function PANEL:gSetChecked(checked)
	self._checked = checked
end

function PANEL:gGetChecked()
	return self._checked
end

function PANEL:gSetDisabled(disabled)
	self._disabled = disabled
	self:SetMouseInputEnabled(not disabled)
end

function PANEL:gSetBgColor(color, alpha)
	self._bgColor = color
	if alpha then self._bgAlpha = alpha end
end

function PANEL:gSetCheckColor(color)
	self._checkColor = color
end

function PANEL:gSetBorder(enabled, color, alpha, size)
	self._border      = enabled
	self._borderColor = color
	self._borderAlpha = alpha or gThemeAlpha("border")
	self._borderSize  = size  or 1
end

function PANEL:gSetState(state)
	self._state = state or "default"
end

function PANEL:OnMousePressed(code)
	if code ~= MOUSE_LEFT then return end
	if self._disabled then return end
	self._checked = not self._checked
	self:OnChange(self._checked)
end

function PANEL:OnChange(checked) end

function PANEL:Think()
	local speed   = FrameTime() * 10
	local mx, my  = self:CursorPos()
	local w, h    = self:GetSize()
	local hovering = not self._disabled and mx >= 0 and mx <= w and my >= 0 and my <= h

	self._hoverAlpha = math.Clamp(
		self._hoverAlpha + ((hovering and gThemeAlpha("hover") or 0) - self._hoverAlpha) * speed,
		0, gThemeAlpha("hover")
	)

	self._checkAlpha = math.Clamp(
		self._checkAlpha + ((self._checked and 255 or 0) - self._checkAlpha) * speed,
		0, 255
	)
end

function PANEL:Paint(w, h)
	local r   = self._radius
	local bg  = self._bgColor or gTheme("surface")
	local a   = self._disabled and gThemeAlpha("disabled") or self._bgAlpha

	draw.RoundedBox(r, 0, 0, w, h, Color(bg.r, bg.g, bg.b, a))

	if self._hoverAlpha > 0 then
		local hc = gTheme("border")
		draw.RoundedBox(r, 0, 0, w, h, Color(hc.r, hc.g, hc.b, self._hoverAlpha))
	end

	if self._checkAlpha > 0 then
		local stateKey = self._stateColors[self._state]
		local cc       = self._checkColor or (stateKey and gTheme(stateKey) or gTheme("accent"))
		draw.RoundedBox(r, 0, 0, w, h, Color(cc.r, cc.g, cc.b, self._checkAlpha))

		local tc = gContrastText(cc, self._checkAlpha)
		local m  = math.floor(math.min(w, h) * 0.28)
		surface.SetDrawColor(tc.r, tc.g, tc.b, self._checkAlpha)
		surface.DrawLine(m,          h * 0.55, w * 0.42, h - m - 1)
		surface.DrawLine(m + 1,      h * 0.55, w * 0.42 + 1, h - m - 1)
		surface.DrawLine(w * 0.42,   h - m - 1, w - m,     m)
		surface.DrawLine(w * 0.42 + 1, h - m - 1, w - m + 1, m)
	end

	if self._border then
		local stateKey = self._stateColors[self._state]
		local bc       = stateKey and self._checked and gTheme(stateKey) or (self._borderColor or gTheme("border"))
		local ba       = self._borderAlpha

		surface.SetDrawColor(bc.r, bc.g, bc.b, ba)
		surface.DrawOutlinedRect(0, 0, w, h, self._borderSize)
	end
end

vgui.Register("gCheckBox", PANEL, "DPanel")