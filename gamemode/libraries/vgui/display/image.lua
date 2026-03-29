local PANEL = {}

function PANEL:Init()
	self:SetPaintBackground(false)

	self._mat           = nil
	self._color         = color_white
	self._alpha         = 255
	self._fitMode       = "fill"

	self._border        = false
	self._borderColor   = nil
	self._borderAlpha   = gThemeAlpha("border")
	self._borderSize    = 1

	self._fallbackColor = nil
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

function PANEL:gSetBorder(enabled, color, alpha, size)
	self._border      = enabled
	self._borderColor = color
	self._borderAlpha = alpha or gThemeAlpha("border")
	self._borderSize  = size  or 1
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
	local c = Color(self._color.r, self._color.g, self._color.b, self._alpha)

	if not self._mat then
		local fc = self._fallbackColor or gTheme("elevated")
		surface.SetDrawColor(fc.r, fc.g, fc.b, self._alpha)
		surface.DrawRect(0, 0, w, h)
	else
		self:_drawMat(w, h, c)
	end

	if self._border then
		local bc = self._borderColor or gTheme("border")
		surface.SetDrawColor(bc.r, bc.g, bc.b, self._borderAlpha)
		surface.DrawOutlinedRect(0, 0, w, h, self._borderSize)
	end
end

vgui.Register("gImage", PANEL, "DPanel")