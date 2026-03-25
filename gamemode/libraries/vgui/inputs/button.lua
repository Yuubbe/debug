local PANEL = {}

function PANEL:Init()
	self:SetText("")
	self:SetCursor("hand")

	self._radius      = gThemeRadius("sm")

	self._bgColor     = nil
	self._bgAlpha     = gThemeAlpha("mid")
	self._bgHoverAlpha = 0

	self._border      = false
	self._borderColor = nil
	self._borderAlpha = gThemeAlpha("border")
	self._borderSize  = 1

	self._text        = ""
	self._font        = "OxaniumMedium"
	self._size        = 13
	self._textColor   = nil
	self._alignX      = TEXT_ALIGN_CENTER
	self._alignY      = TEXT_ALIGN_CENTER

	self._icon        = nil
	self._iconSize    = 16
	self._iconPad     = 6

	self._disabled    = false
	self._pressing    = false
	self._pressAlpha  = 0

	self._corners     = { tl = true, tr = true, bl = true, br = true }
	self._roundedEx   = false
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

function PANEL:gSetCorners(tl, tr, bl, br)
	self._corners   = { tl = tl, tr = tr, bl = bl, br = br }
	self._roundedEx = not (tl and tr and bl and br)
end

function PANEL:gSetText(text, font, size, color, alignX, alignY)
	self._text    = text
	self._font    = font   or self._font
	self._size    = size   or self._size
	self._textColor = color
	self._alignX  = alignX or TEXT_ALIGN_CENTER
	self._alignY  = alignY or TEXT_ALIGN_CENTER
end

function PANEL:gSetFont(font, size)
	self._font = font or "OxaniumMedium"
	self._size = size or 13
end

function PANEL:gSetTextColor(color)
	self._textColor = color
end

function PANEL:gSetIcon(mat, size, pad)
	self._icon     = mat
	self._iconSize = size or 16
	self._iconPad  = pad  or 6
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

	if self._pressing then
		self._pressing = false
		local mx, my = self:CursorPos()
		if mx >= 0 and mx <= self:GetWide() and my >= 0 and my <= self:GetTall() then
			self:DoClick()
		end
	end
end

function PANEL:DoClick() end

function PANEL:Think()
	local target

	if self._disabled then
		self._bgHoverAlpha = 0
		self._pressAlpha   = 0
		return
	end

	local mx, my  = self:CursorPos()
	local hovering = mx >= 0 and mx <= self:GetWide() and my >= 0 and my <= self:GetTall()
	local speed    = FrameTime() * 10

	if self._pressing then
		target = gThemeAlpha("press")
	elseif hovering then
		target = gThemeAlpha("hover")
	else
		target = 0
	end

	self._bgHoverAlpha = math.Clamp(
		self._bgHoverAlpha + (target - self._bgHoverAlpha) * speed,
		0,
		gThemeAlpha("press")
	)
end

function PANEL:Paint(w, h)
	local r   = self._radius
	local bg  = self._bgColor or gTheme("elevated")
	local a   = self._disabled and gThemeAlpha("disabled") or self._bgAlpha
	local c   = Color(bg.r, bg.g, bg.b, a)

	if self._roundedEx then
		local co = self._corners
		draw.RoundedBoxEx(r, 0, 0, w, h, c, co.tl, co.tr, co.bl, co.br)
	else
		draw.RoundedBox(r, 0, 0, w, h, c)
	end

	if self._bgHoverAlpha > 0 then
		local hc = gTheme("border")
		if self._roundedEx then
			local co = self._corners
			draw.RoundedBoxEx(r, 0, 0, w, h, Color(hc.r, hc.g, hc.b, self._bgHoverAlpha), co.tl, co.tr, co.bl, co.br)
		else
			draw.RoundedBox(r, 0, 0, w, h, Color(hc.r, hc.g, hc.b, self._bgHoverAlpha))
		end
	end

	local tc = self._textColor or (self._disabled and gTheme("textMute") or gTheme("text"))

	if self._icon and self._text ~= "" then
		local iconS = gRespX(self._iconSize)
		local iconP = gRespX(self._iconPad)
		local font  = self._font .. ":" .. self._size
		surface.SetFont(font)
		local tw = surface.GetTextSize(self._text)
		local totalW = iconS + iconP + tw
		local startX = (w - totalW) * 0.5

		pMaterials(self._icon, startX, (h - gRespY(self._iconSize)) * 0.5, self._iconSize, self._iconSize, tc)
		draw.SimpleText(self._text, font, startX + iconS + iconP, h * 0.5, tc, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	elseif self._icon then
		local iconS = gRespX(self._iconSize)
		pMaterials(self._icon, (w - iconS) * 0.5, (h - gRespY(self._iconSize)) * 0.5, self._iconSize, self._iconSize, tc)

	elseif self._text ~= "" then
		local font = self._font .. ":" .. self._size
		local tx = self._alignX == TEXT_ALIGN_CENTER and w * 0.5 or (self._alignX == TEXT_ALIGN_RIGHT and w - gRespX(10) or gRespX(10))
		draw.SimpleText(self._text, font, tx, h * 0.5, tc, self._alignX, TEXT_ALIGN_CENTER)
	end

	if self._border then
		local bc = self._borderColor or gTheme("border")
		surface.SetDrawColor(bc.r, bc.g, bc.b, self._borderAlpha)
		surface.DrawOutlinedRect(0, 0, w, h, self._borderSize)
	end
end

vgui.Register("gButton", PANEL, "DPanel")