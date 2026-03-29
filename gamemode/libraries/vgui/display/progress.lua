local PANEL = {}

function PANEL:Init()
	self:SetPaintBackground(false)

	self._radius      = gThemeRadius("sm")
	self._bgColor     = nil
	self._bgAlpha     = gThemeAlpha("mid")
	self._fillColor   = nil
	self._fillAlpha   = 255

	self._border      = false
	self._borderColor = nil
	self._borderAlpha = gThemeAlpha("border")
	self._borderSize  = 1

	self._value       = 0
	self._displayValue = 0
	self._animated    = true

	self._showLabel   = false
	self._font        = "OxaniumMedium"
	self._size        = 11
	self._textColor   = nil
	self._labelFormat = "%d%%"

	self._vertical    = false
	self._reversed    = false
end

function PANEL:gSetRadius(r)
	self._radius = r
end

function PANEL:gSetBgColor(color, alpha)
	self._bgColor = color
	if alpha then self._bgAlpha = alpha end
end

function PANEL:gSetFillColor(color, alpha)
	self._fillColor = color
	if alpha then self._fillAlpha = alpha end
end

function PANEL:gSetBorder(enabled, color, alpha, size)
	self._border      = enabled
	self._borderColor = color
	self._borderAlpha = alpha or gThemeAlpha("border")
	self._borderSize  = size  or 1
end

function PANEL:gSetValue(val)
	self._value = math.Clamp(val, 0, 1)
	if not self._animated then
		self._displayValue = self._value
	end
end

function PANEL:gGetValue()
	return self._value
end

function PANEL:gSetAnimated(enabled)
	self._animated = enabled
	if not enabled then
		self._displayValue = self._value
	end
end

function PANEL:gSetLabel(enabled, font, size, color, format)
	self._showLabel   = enabled
	self._font        = font   or "OxaniumMedium"
	self._size        = size   or 11
	self._textColor   = color
	self._labelFormat = format or "%d%%"
end

function PANEL:gSetVertical(enabled)
	self._vertical = enabled
end

function PANEL:gSetReversed(enabled)
	self._reversed = enabled
end

function PANEL:Think()
	if not self._animated then return end
	local speed = FrameTime() * 4
	self._displayValue = self._displayValue + (self._value - self._displayValue) * speed
	if math.abs(self._value - self._displayValue) < 0.001 then
		self._displayValue = self._value
	end
end

function PANEL:Paint(w, h)
	local r    = self._radius
	local bg   = self._bgColor or gTheme("elevated")
	local fill = self._fillColor or gTheme("accent")
	local dv   = self._displayValue

	draw.RoundedBox(r, 0, 0, w, h, Color(bg.r, bg.g, bg.b, self._bgAlpha))

	if dv > 0 then
		if self._vertical then
			local fh = math.floor(h * dv)
			local fy = self._reversed and 0 or (h - fh)
			local tl = not self._reversed
			local bl = self._reversed
			draw.RoundedBoxEx(r, 0, fy, w, fh, Color(fill.r, fill.g, fill.b, self._fillAlpha), tl, tl, bl, bl)
		else
			local fw = math.floor(w * dv)
			local fx = self._reversed and (w - fw) or 0
			local tr = not self._reversed
			local tl = self._reversed
			draw.RoundedBoxEx(r, fx, 0, fw, h, Color(fill.r, fill.g, fill.b, self._fillAlpha), tl, tr, tl, tr)
		end
	end

	if self._showLabel then
		local font  = self._font .. ":" .. self._size
		local tc    = self._textColor or gContrastText(fill)
		local label = string.format(self._labelFormat, math.floor(dv * 100))
		draw.SimpleText(label, font, w * 0.5, h * 0.5, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if self._border then
		local bc = self._borderColor or gTheme("border")
		surface.SetDrawColor(bc.r, bc.g, bc.b, self._borderAlpha)
		surface.DrawOutlinedRect(0, 0, w, h, self._borderSize)
	end
end

vgui.Register("gProgress", PANEL, "DPanel")