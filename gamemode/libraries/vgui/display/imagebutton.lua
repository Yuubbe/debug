local PANEL = {}

function PANEL:Init()
	self:SetCursor("hand")
	self:SetPaintBackground(false)

	self._mat           = nil
	self._color         = color_white
	self._alpha         = 255
	self._fitMode       = "fill"

	self._fallbackColor = nil

	self._bgColor       = nil
	self._bgAlpha       = 0

	self._border        = false
	self._borderColor   = nil
	self._borderAlpha   = gThemeAlpha("border")
	self._borderSize    = 1

	self._hoverAlpha    = 0
	self._pressAlpha    = 0
	self._pressing      = false
	self._disabled      = false

	self._label         = nil
	self._labelFont     = "OxaniumMedium"
	self._labelSize     = 12
	self._labelColor    = nil
	self._labelAlignX   = TEXT_ALIGN_CENTER
	self._labelAlignY   = TEXT_ALIGN_BOTTOM
	self._labelPad      = 6
end

function PANEL:gSetImage(path, fallback)
	self._fallbackColor = fallback

	if not path or path == "" then
		self._mat = nil
		return
	end

	local mat = Material(path, "noclamp smooth")
	self._mat = (mat and not mat:IsError()) and mat or nil
end

function PANEL:gSetColor(color, alpha)
	self._color = color or color_white
	if alpha then self._alpha = alpha end
end

function PANEL:gSetAlpha(alpha)
	self._alpha = alpha
end

function PANEL:gSetFitMode(mode)
	self._fitMode = mode or "fill"
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

function PANEL:gSetLabel(text, font, size, color, alignX, alignY, pad)
	self._label      = text
	self._labelFont  = font   or "OxaniumMedium"
	self._labelSize  = size   or 12
	self._labelColor = color
	self._labelAlignX = alignX or TEXT_ALIGN_CENTER
	self._labelAlignY = alignY or TEXT_ALIGN_BOTTOM
	self._labelPad   = pad    or 6
end

function PANEL:gSetDisabled(disabled)
	self._disabled = disabled
	self:SetMouseInputEnabled(not disabled)
end

function PANEL:OnMousePressed(code)
	if code ~= MOUSE_LEFT then return end
	if self._disabled then return end
	self._pressing = true
end

function PANEL:OnMouseReleased(code)
	if code ~= MOUSE_LEFT then return end
	if self._disabled then return end
	if not self._pressing then return end
	self._pressing = false
	local mx, my = self:CursorPos()
	if mx >= 0 and mx <= self:GetWide() and my >= 0 and my <= self:GetTall() then
		self:DoClick()
	end
end

function PANEL:DoClick() end

function PANEL:Think()
	local speed    = FrameTime() * 10
	local mx, my   = self:CursorPos()
	local w, h     = self:GetSize()
	local hovering = not self._disabled and mx >= 0 and mx <= w and my >= 0 and my <= h

	local targetHover = self._pressing and 0 or (hovering and gThemeAlpha("hover") or 0)
	local targetPress = self._pressing and gThemeAlpha("press") or 0

	self._hoverAlpha = math.Clamp(self._hoverAlpha + (targetHover - self._hoverAlpha) * speed, 0, gThemeAlpha("hover"))
	self._pressAlpha = math.Clamp(self._pressAlpha + (targetPress - self._pressAlpha) * speed, 0, gThemeAlpha("press"))
end

function PANEL:_matSize(w, h)
	local iw = self._mat:Width()
	local ih = self._mat:Height()
	if not iw or iw == 0 then iw = w end
	if not ih or ih == 0 then ih = h end
	return iw, ih
end

function PANEL:_drawMat(w, h, c)
	if self._fitMode == "contain" then
		local iw, ih = self:_matSize(w, h)
		local scl    = math.min(w / iw, h / ih)
		pMaterials(self._mat, (w - iw * scl) * 0.5, (h - ih * scl) * 0.5, iw * scl, ih * scl, c)
	elseif self._fitMode == "center" then
		local iw, ih = self:_matSize(w, h)
		pMaterials(self._mat, (w - iw) * 0.5, (h - ih) * 0.5, iw, ih, c)
	else
		pMaterials(self._mat, 0, 0, w, h, c)
	end
end

function PANEL:Paint(w, h)
	local a = self._disabled and gThemeAlpha("disabled") or self._alpha
	local c = Color(self._color.r, self._color.g, self._color.b, a)

	if self._bgColor then
		surface.SetDrawColor(self._bgColor.r, self._bgColor.g, self._bgColor.b, self._bgAlpha)
		surface.DrawRect(0, 0, w, h)
	end

	if not self._mat then
		local fc = self._fallbackColor or gTheme("elevated")
		surface.SetDrawColor(fc.r, fc.g, fc.b, a)
		surface.DrawRect(0, 0, w, h)
	else
		self:_drawMat(w, h, c)
	end

	if self._hoverAlpha > 0 then
		local hc = gTheme("border")
		surface.SetDrawColor(hc.r, hc.g, hc.b, self._hoverAlpha)
		surface.DrawRect(0, 0, w, h)
	end

	if self._pressAlpha > 0 then
		local pc = gTheme("border")
		surface.SetDrawColor(pc.r, pc.g, pc.b, self._pressAlpha)
		surface.DrawRect(0, 0, w, h)
	end

	if self._label then
		local font = self._labelFont .. ":" .. self._labelSize
		local tc   = self._labelColor or gTheme("text")
		local pad  = gRespY(self._labelPad)
		local tx, ty

		if self._labelAlignX == TEXT_ALIGN_CENTER then
			tx = w * 0.5
		elseif self._labelAlignX == TEXT_ALIGN_RIGHT then
			tx = w - gRespX(self._labelPad)
		else
			tx = gRespX(self._labelPad)
		end

		if self._labelAlignY == TEXT_ALIGN_BOTTOM then
			ty = h - pad
		elseif self._labelAlignY == TEXT_ALIGN_CENTER then
			ty = h * 0.5
		else
			ty = pad
		end

		draw.SimpleText(self._label, font, tx, ty, tc, self._labelAlignX, self._labelAlignY)
	end

	if self._border then
		local bc = self._borderColor or gTheme("border")
		surface.SetDrawColor(bc.r, bc.g, bc.b, self._borderAlpha)
		surface.DrawOutlinedRect(0, 0, w, h, self._borderSize)
	end
end

vgui.Register("gImageButton", PANEL, "DPanel")