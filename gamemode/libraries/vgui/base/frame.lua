local PANEL = {}

local _DRAG_H  = gRespY(40)
local _CLOSE_W = gRespX(40)
local _PAD     = gRespX(14)

function PANEL:Init()
	self:SetTitle("")
	self:SetDraggable(false)
	self:ShowCloseButton(false)
	self:SetSizable(false)
	self:SetScreenLock(true)
	self:SetDeleteOnClose(true)

	self._draggable  = true
	self._dragging   = false
	self._dragOffX   = 0
	self._dragOffY   = 0

	self._radius      = gThemeRadius("lg")
	self._bgAlpha     = gThemeAlpha("mid")
	self._bgColor     = nil
	self._border      = false
	self._borderAlpha = gThemeAlpha("border")

	self._header      = false
	self._headerAlpha = gThemeAlpha("high")
	self._headerColor = nil
	self._headerH     = _DRAG_H

	self._title       = nil
	self._titleFont   = "OxaniumMedium"
	self._titleSize   = 16
	self._titleColor  = nil
	self._titleAlignX = TEXT_ALIGN_CENTER

	self._closeBtn        = false
	self._closeFont       = "OxaniumRegular"
	self._closeSize       = 18
	self._closeColor      = nil
	self._closeHoverAlpha = 0
end

function PANEL:gSetRadius(r)
	self._radius = r
end

function PANEL:gSetBgColor(color, alpha)
	self._bgColor = color
	if alpha then self._bgAlpha = alpha end
end

function PANEL:gSetBgAlpha(alpha)
	self._bgAlpha = alpha
end

function PANEL:gSetBorder(enabled, alpha)
	self._border      = enabled
	self._borderAlpha = alpha or gThemeAlpha("border")
end

function PANEL:gSetHeader(enabled, color, alpha, height)
	self._header      = enabled
	self._headerColor = color
	self._headerAlpha = alpha or gThemeAlpha("high")
	self._headerH     = height and gRespY(height) or _DRAG_H
end

function PANEL:gSetTitle(text, font, size, color, alignX)
	self._title       = text
	self._titleFont   = font  or "OxaniumMedium"
	self._titleSize   = size  or 16
	self._titleColor  = color
	self._titleAlignX = alignX or TEXT_ALIGN_CENTER

	if not self._header then self._header = true end
end

function PANEL:gSetCloseButton(enabled, font, size, color)
	self._closeBtn   = enabled
	self._closeFont  = font  or "OxaniumRegular"
	self._closeSize  = size  or 18
	self._closeColor = color

	if not self._header then self._header = true end
end

function PANEL:gSetDraggable(enabled)
	self._draggable = enabled
	if not enabled then
		self._dragging = false
		self:MouseCapture(false)
	end
end

function PANEL:OnMousePressed(code)
	if code ~= MOUSE_LEFT then return end

	local mx, my = self:CursorPos()

	if self._closeBtn and self._header then
		local cx = self:GetWide() - _CLOSE_W
		if mx >= cx and my >= 0 and my <= self._headerH then
			self:gClose()
			return
		end
	end

	if not self._draggable then return end
	if not self._header then return end
	if my > self._headerH then return end

	self._dragging = true
	local fx, fy   = self:GetPos()
	local gx, gy   = gui.MousePos()
	self._dragOffX = gx - fx
	self._dragOffY = gy - fy

	self:MouseCapture(true)
end

function PANEL:OnMouseReleased(code)
	if code ~= MOUSE_LEFT then return end
	self._dragging = false
	self:MouseCapture(false)
end

function PANEL:Think()
	if self._dragging then
		local gx, gy = gui.MousePos()
		local nx     = gx - self._dragOffX
		local ny     = gy - self._dragOffY

		if self:GetScreenLock() then
			nx = math.Clamp(nx, 0, ScrW() - self:GetWide())
			ny = math.Clamp(ny, 0, ScrH() - self:GetTall())
		end

		self:SetPos(nx, ny)
	end

	if self._closeBtn and self._header then
		local mx, my  = self:CursorPos()
		local w, h    = self:GetSize()
		local cx      = self:GetWide() - _CLOSE_W
		local inPanel = mx >= 0 and mx <= w and my >= 0 and my <= h
		local hover   = inPanel and mx >= cx and my >= 0 and my <= self._headerH
		local speed   = gThemeAlpha("hover") * FrameTime() * 10

		if hover then
			self._closeHoverAlpha = math.min(self._closeHoverAlpha + speed, gThemeAlpha("hover"))
		else
			self._closeHoverAlpha = math.max(self._closeHoverAlpha - speed, 0)
		end
	end
end

function PANEL:Paint(w, h)
	local r   = self._radius
	local bgC = self._bgColor or gTheme("bg")

	draw.RoundedBox(r, 0, 0, w, h, Color(bgC.r, bgC.g, bgC.b, self._bgAlpha))

	if self._header then
		local hh = self._headerH
		local hc = self._headerColor or gTheme("surface")

		draw.RoundedBoxEx(r, 0, 0, w, hh, Color(hc.r, hc.g, hc.b, self._headerAlpha), true, true, false, false)

		if self._title then
			local tc   = self._titleColor or gTheme("text")
			local font = self._titleFont .. ":" .. self._titleSize

			local tx
			if self._titleAlignX == TEXT_ALIGN_CENTER then
				tx = w * 0.5
			elseif self._titleAlignX == TEXT_ALIGN_RIGHT then
				tx = w - _PAD
			else
				tx = _PAD
			end

			draw.SimpleText(self._title, font, tx, hh * 0.5, tc, self._titleAlignX, TEXT_ALIGN_CENTER)
		end

		if self._closeBtn then
			local cx = w - _CLOSE_W

			if self._closeHoverAlpha > 0 then
				local hc2 = gTheme("border")
				draw.RoundedBoxEx(r, cx, 0, _CLOSE_W, hh, Color(hc2.r, hc2.g, hc2.b, self._closeHoverAlpha), false, true, false, false)
			end

			local cc   = self._closeColor or gTheme("textDim")
			local font = self._closeFont .. ":" .. self._closeSize
			draw.SimpleText("×", font, cx + _CLOSE_W * 0.5, hh * 0.5, cc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		local sep = gTheme("border")
		surface.SetDrawColor(sep.r, sep.g, sep.b, gThemeAlpha("sep"))
		surface.DrawLine(0, hh, w, hh)
	end

	if self._border then
		local bc = gTheme("border")
		surface.SetDrawColor(bc.r, bc.g, bc.b, self._borderAlpha)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end
end

function PANEL:gOpen(duration, callback)
	self:SetVisible(true)
	self:SetAlpha(0)
	self:MakePopup()
	self:gFadeIn(duration or 0.2, 0, callback)
end

function PANEL:gClose(duration, callback)
	self:gFadeOut(duration or 0.15, 0, function()
		if self:GetDeleteOnClose() then
			self:Remove()
		else
			self:SetVisible(false)
		end
		if callback then callback() end
	end)
end

vgui.Register("gFrame", PANEL, "DFrame")