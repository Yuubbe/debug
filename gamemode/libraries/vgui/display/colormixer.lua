local PANEL = {}

function PANEL:Init()
	self:SetPaintBackground(false)

	self._radius    = gThemeRadius("sm")
	self._bgColor   = nil
	self._bgAlpha   = gThemeAlpha("mid")

	self._border    = false
	self._borderColor = nil
	self._borderAlpha = gThemeAlpha("border")
	self._borderSize  = 1

	self._color     = Color(255, 0, 0)
	self._h         = 0
	self._s         = 1
	self._v         = 1
	self._a         = 255
	self._showAlpha = false

	self._font      = "OxaniumRegular"
	self._size      = 11

	self._draggingSV = false
	self._draggingH  = false
	self._draggingA  = false

	self._pad       = 8
	self._hueW      = 14
	self._alphaW    = 14
	self._gap       = 6

	self._previewH  = 24
	self._showPreview = true
end

function PANEL:gSetRadius(r)
	self._radius = r
end

function PANEL:gSetBgColor(color, alpha)
	self._bgColor = color
	if alpha then self._bgAlpha = alpha end
end

function PANEL:gSetBorder(enabled, color, alpha, size)
	self._border      = enabled
	self._borderColor = color
	self._borderAlpha = alpha or gThemeAlpha("border")
	self._borderSize  = size  or 1
end

function PANEL:gSetColor(color)
	local h, s, v = ColorToHSV(color)
	self._h     = h
	self._s     = s
	self._v     = v
	self._a     = color.a or 255
	self._color = color
end

function PANEL:gGetColor()
	return self._color
end

function PANEL:gSetShowAlpha(enabled)
	self._showAlpha = enabled
end

function PANEL:gSetShowPreview(enabled)
	self._showPreview = enabled
end

function PANEL:gSetFont(font, size)
	self._font = font or "OxaniumRegular"
	self._size = size or 11
end

function PANEL:OnChange(color) end

function PANEL:_updateColor()
	local c       = HSVToColor(self._h, self._s, self._v)
	c.a           = self._a
	self._color   = c
	self:OnChange(c)
end

function PANEL:_layout(w, h)
	local pad    = gRespX(self._pad)
	local hueW   = gRespX(self._hueW)
	local alphaW = self._showAlpha and gRespX(self._alphaW) or 0
	local gap    = gRespX(self._gap)
	local prevH  = self._showPreview and gRespY(self._previewH) or 0
	local prevGap = prevH > 0 and gap or 0

	local svX = pad
	local svY = pad
	local svW = w - pad * 2 - hueW - gap - (alphaW > 0 and alphaW + gap or 0)
	local svH = h - pad * 2 - prevH - prevGap

	local hX  = svX + svW + gap
	local hY  = svY
	local hH  = svH

	local aX  = hX + hueW + gap
	local aH  = svH

	local prX = pad
	local prY = svY + svH + prevGap
	local prW = w - pad * 2

	return {
		svX = svX, svY = svY, svW = svW, svH = svH,
		hX  = hX,  hY  = hY,  hH  = hH,  hueW = hueW,
		aX  = aX,  aH  = aH,  alphaW = alphaW,
		prX = prX, prY = prY, prW = prW, prH = prevH,
		pad = pad,
	}
end

function PANEL:OnMousePressed(code)
	if code ~= MOUSE_LEFT then return end
	local mx, my = self:CursorPos()
	local w, h   = self:GetSize()
	local l      = self:_layout(w, h)

	if mx >= l.svX and mx <= l.svX + l.svW and my >= l.svY and my <= l.svY + l.svH then
		self._draggingSV = true
		self:MouseCapture(true)
	elseif mx >= l.hX and mx <= l.hX + l.hueW and my >= l.hY and my <= l.hY + l.hH then
		self._draggingH = true
		self:MouseCapture(true)
	elseif self._showAlpha and mx >= l.aX and mx <= l.aX + l.alphaW and my >= l.svY and my <= l.svY + l.aH then
		self._draggingA = true
		self:MouseCapture(true)
	end
end

function PANEL:OnMouseReleased(code)
	if code ~= MOUSE_LEFT then return end
	self._draggingSV = false
	self._draggingH  = false
	self._draggingA  = false
	self:MouseCapture(false)
end

function PANEL:Think()
	if not self._draggingSV and not self._draggingH and not self._draggingA then return end

	local mx, my = self:CursorPos()
	local w, h   = self:GetSize()
	local l      = self:_layout(w, h)

	if self._draggingSV then
		self._s = math.Clamp((mx - l.svX) / l.svW, 0, 1)
		self._v = 1 - math.Clamp((my - l.svY) / l.svH, 0, 1)
		self:_updateColor()
	elseif self._draggingH then
		self._h = math.Clamp((my - l.hY) / l.hH, 0, 1) * 360
		self:_updateColor()
	elseif self._draggingA then
		self._a = math.floor(math.Clamp(1 - (my - l.svY) / l.aH, 0, 1) * 255)
		self:_updateColor()
	end
end

function PANEL:Paint(w, h)
	local r  = self._radius
	local bg = self._bgColor or gTheme("surface")
	local l  = self:_layout(w, h)

	draw.RoundedBox(r, 0, 0, w, h, Color(bg.r, bg.g, bg.b, self._bgAlpha))

	local hueColor = HSVToColor(self._h, 1, 1)

	-- SV picker
	draw.RoundedBox(0, l.svX, l.svY, l.svW, l.svH, hueColor)

	surface.SetDrawColor(255, 255, 255, 255)
	local whiteGrad = Material("vgui/gradient-r")
	if whiteGrad then
		surface.SetMaterial(whiteGrad)
		surface.DrawTexturedRect(l.svX, l.svY, l.svW, l.svH)
	end

	local blackGrad = Material("vgui/gradient-d")
	if blackGrad then
		surface.SetMaterial(blackGrad)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(l.svX, l.svY, l.svW, l.svH)
	end

	local crossX = l.svX + self._s * l.svW
	local crossY = l.svY + (1 - self._v) * l.svH
	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawRect(crossX - 5, crossY - 1, 10, 2)
	surface.DrawRect(crossX - 1, crossY - 5, 2, 10)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawRect(crossX - 4, crossY - 0, 8, 2)
	surface.DrawRect(crossX - 0, crossY - 4, 2, 8)

	-- Hue bar
	for i = 0, l.hH - 1 do
		local frac  = i / l.hH
		local hc    = HSVToColor(frac * 360, 1, 1)
		surface.SetDrawColor(hc.r, hc.g, hc.b, 255)
		surface.DrawRect(l.hX, l.hY + i, l.hueW, 1)
	end

	local hueY = l.hY + (self._h / 360) * l.hH
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawRect(l.hX - 1, hueY - 1, l.hueW + 2, 2)
	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawOutlinedRect(l.hX - 2, hueY - 2, l.hueW + 4, 4, 1)

	-- Alpha bar
	if self._showAlpha then
		local checkerS = gRespX(4)
		for iy = 0, math.ceil(l.aH / checkerS) - 1 do
			for ix = 0, math.ceil(l.alphaW / checkerS) - 1 do
				local light = (ix + iy) % 2 == 0
				surface.SetDrawColor(light and 200 or 140, light and 200 or 140, light and 200 or 140, 255)
				surface.DrawRect(l.aX + ix * checkerS, l.svY + iy * checkerS, checkerS, checkerS)
			end
		end

		local fc = self._color
		for i = 0, l.aH - 1 do
			local frac = 1 - (i / l.aH)
			surface.SetDrawColor(fc.r, fc.g, fc.b, math.floor(frac * 255))
			surface.DrawRect(l.aX, l.svY + i, l.alphaW, 1)
		end

		local aY = l.svY + (1 - self._a / 255) * l.aH
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawRect(l.aX - 1, aY - 1, l.alphaW + 2, 2)
		surface.SetDrawColor(0, 0, 0, 200)
		surface.DrawOutlinedRect(l.aX - 2, aY - 2, l.alphaW + 4, 4, 1)
	end

	-- Preview
	if self._showPreview and l.prH > 0 then
		local c = self._color
		surface.SetDrawColor(c.r, c.g, c.b, 255)
		surface.DrawRect(l.prX, l.prY, l.prW * 0.5, l.prH)

		surface.SetDrawColor(c.r, c.g, c.b, self._a)
		surface.DrawRect(l.prX + l.prW * 0.5, l.prY, l.prW * 0.5, l.prH)

		local font  = self._font .. ":" .. self._size
		local tc    = gContrastText(c)
		local hex   = string.format("#%02X%02X%02X", c.r, c.g, c.b)
		draw.SimpleText(hex, font, l.prX + l.prW * 0.5, l.prY + l.prH * 0.5, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if self._border then
		local bc = self._borderColor or gTheme("border")
		surface.SetDrawColor(bc.r, bc.g, bc.b, self._borderAlpha)
		surface.DrawOutlinedRect(0, 0, w, h, self._borderSize)
	end
end

vgui.Register("gColorMixer", PANEL, "DPanel")