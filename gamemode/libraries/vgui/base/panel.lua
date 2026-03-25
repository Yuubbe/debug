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

function PANEL:gSetBgAlpha(alpha)
	self._bgAlpha = alpha
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

function PANEL:Paint(w, h)
	local r  = self._radius
	local bg = self._bgColor or gTheme("surface")
	local c  = Color(bg.r, bg.g, bg.b, self._bgAlpha)

	if self._roundedEx then
		local co = self._corners
		draw.RoundedBoxEx(r, 0, 0, w, h, c, co.tl, co.tr, co.bl, co.br)
	else
		draw.RoundedBox(r, 0, 0, w, h, c)
	end

	if self._border then
		local bc = self._borderColor or gTheme("border")
		surface.SetDrawColor(bc.r, bc.g, bc.b, self._borderAlpha)
		surface.DrawOutlinedRect(0, 0, w, h, self._borderSize)
	end
end

vgui.Register("gPanel", PANEL, "DPanel")