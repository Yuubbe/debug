local PANEL = {}

function PANEL:Init()
	self:SetPaintBackground(false)

	self._radius      = gThemeRadius("sm")
	self._bgColor     = nil
	self._bgAlpha     = gThemeAlpha("mid")

	self._border      = false
	self._borderColor = nil
	self._borderAlpha = gThemeAlpha("border")
	self._borderSize  = 1

	self._scrollbar   = true
	self._scrollW     = 4
	self._scrollColor = nil
	self._scrollAlpha = 0
	self._scrollTarget = 0

	self._padX        = 0
	self._padY        = 0

	self._canvas = vgui.Create("DPanel", self)
	self._canvas:SetPaintBackground(false)
	self._canvas:SetPos(0, 0)

	self._scrolling   = false
	self._scrollStart = 0
	self._scrollOffY  = 0
	self._scrollY     = 0
	self._contentH    = 0
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

function PANEL:gSetScrollbar(enabled, width, color)
	self._scrollbar   = enabled
	self._scrollW     = width or 4
	self._scrollColor = color
end

function PANEL:gSetPadding(x, y)
	self._padX = x or 0
	self._padY = y or 0
	self:InvalidateLayout()
end

function PANEL:GetCanvas()
	return self._canvas
end

function PANEL:Add(panel)
	panel:SetParent(self._canvas)
	return panel
end

function PANEL:_updateCanvas()
	local w, h    = self:GetSize()
	local padX    = gRespX(self._padX)
	local padY    = gRespY(self._padY)
	local canvasW = w - padX * 2 - (self._scrollbar and gRespX(self._scrollW) + gRespX(4) or 0)

	self._canvas:SetPos(padX, padY)
	self._canvas:SetWide(canvasW)
	self._canvas:SizeToChildren(false, true)

	self._contentH = self._canvas:GetTall() + padY * 2
	self._scrollY  = math.Clamp(self._scrollY, 0, math.max(0, self._contentH - h))
	self._canvas:SetY(padY - self._scrollY)
end

function PANEL:PerformLayout(w, h)
	self:_updateCanvas()
end

function PANEL:OnMouseWheeled(delta)
	if self._disabled then return end
	local speed = gRespY(40)
	self._scrollTarget = math.Clamp(self._scrollTarget - delta * speed, 0, math.max(0, self._contentH - self:GetTall()))
end

function PANEL:Think()
	local speed  = FrameTime() * 12
	local w, h   = self:GetSize()
	local maxScroll = math.max(0, self._contentH - h)

	self._scrollY = math.Clamp(
		self._scrollY + (self._scrollTarget - self._scrollY) * speed,
		0, maxScroll
	)

	self._canvas:SetY(gRespY(self._padY) - self._scrollY)

	local mx, my   = self:CursorPos()
	local hovering = mx >= 0 and mx <= w and my >= 0 and my <= h
	local targetA  = (hovering and maxScroll > 0 and self._scrollbar) and 160 or 0

	self._scrollAlpha = math.Clamp(
		self._scrollAlpha + (targetA - self._scrollAlpha) * speed,
		0, 160
	)

	if self._scrolling then
		local _, gy   = gui.MousePos()
		local delta   = gy - self._scrollStart
		local ratio   = maxScroll / (h - self:_thumbH())
		self._scrollY  = math.Clamp(self._scrollOffY + delta * ratio, 0, maxScroll)
		self._scrollTarget = self._scrollY
		self._canvas:SetY(gRespY(self._padY) - self._scrollY)
	end
end

function PANEL:_thumbH()
	local h        = self:GetTall()
	local ratio    = math.min(h / math.max(self._contentH, 1), 1)
	return math.max(ratio * h, gRespY(24))
end

function PANEL:_thumbY()
	local h        = self:GetTall()
	local maxScroll = math.max(0, self._contentH - h)
	if maxScroll == 0 then return 0 end
	return (self._scrollY / maxScroll) * (h - self:_thumbH())
end

function PANEL:OnMousePressed(code)
	if code ~= MOUSE_LEFT then return end
	local w, h  = self:GetSize()
	local sw    = gRespX(self._scrollW)
	local mx, my = self:CursorPos()

	if mx >= w - sw - gRespX(2) and mx <= w - gRespX(2) then
		local ty = self:_thumbY()
		local th = self:_thumbH()

		if my >= ty and my <= ty + th then
			self._scrolling   = true
			self._scrollStart = select(2, gui.MousePos())
			self._scrollOffY  = self._scrollY
			self:MouseCapture(true)
		end
	end
end

function PANEL:OnMouseReleased(code)
	if code ~= MOUSE_LEFT then return end
	self._scrolling = false
	self:MouseCapture(false)
end

function PANEL:Paint(w, h)
	local r  = self._radius
	local bg = self._bgColor or gTheme("surface")
	local a  = self._bgAlpha

	draw.RoundedBox(r, 0, 0, w, h, Color(bg.r, bg.g, bg.b, a))

	if self._border then
		local bc = self._borderColor or gTheme("border")
		surface.SetDrawColor(bc.r, bc.g, bc.b, self._borderAlpha)
		surface.DrawOutlinedRect(0, 0, w, h, self._borderSize)
	end

	if self._scrollbar and self._scrollAlpha > 0 and self._contentH > h then
		local sw   = gRespX(self._scrollW)
		local sx   = w - sw - gRespX(2)
		local ty   = self:_thumbY()
		local th   = self:_thumbH()
		local sc   = self._scrollColor or gTheme("border")

		draw.RoundedBox(sw, sx, 0, sw, h, Color(sc.r, sc.g, sc.b, self._scrollAlpha * 0.3))
		draw.RoundedBox(sw, sx, ty, sw, th, Color(sc.r, sc.g, sc.b, self._scrollAlpha))
	end
end

vgui.Register("gScrollPanel", PANEL, "DPanel")