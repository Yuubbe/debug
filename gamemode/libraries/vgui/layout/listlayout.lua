local PANEL = {}

function PANEL:Init()
	self:SetPaintBackground(false)

	self._radius      = gThemeRadius("sm")
	self._bgColor     = nil
	self._bgAlpha     = 0

	self._border      = false
	self._borderColor = nil
	self._borderAlpha = gThemeAlpha("border")
	self._borderSize  = 1

	self._padX        = 0
	self._padY        = 0
	self._spaceY      = 4

	self._itemH       = nil
	self._items       = {}

	self._stripes     = false
	self._stripeColor = nil
	self._stripeAlpha = 12
end

function PANEL:gSetRadius(r)
	self._radius = r
end

function PANEL:gSetBgColor(color, alpha)
	self._bgColor = color
	self._bgAlpha = alpha or gThemeAlpha("mid")
end

function PANEL:gSetBorder(enabled, color, alpha, size)
	self._border      = enabled
	self._borderColor = color
	self._borderAlpha = alpha or gThemeAlpha("border")
	self._borderSize  = size  or 1
end

function PANEL:gSetPadding(x, y)
	self._padX = x or 0
	self._padY = y or x or 0
	self:InvalidateLayout()
end

function PANEL:gSetSpacing(y)
	self._spaceY = y or 4
	self:InvalidateLayout()
end

function PANEL:gSetItemHeight(h)
	self._itemH = h
	self:InvalidateLayout()
end

function PANEL:gSetStripes(enabled, color, alpha)
	self._stripes     = enabled
	self._stripeColor = color
	self._stripeAlpha = alpha or 12
end

function PANEL:gAddItem(panel)
	table.insert(self._items, panel)
	panel:SetParent(self)
	self:InvalidateLayout()
	return panel
end

function PANEL:gRemoveItem(panel)
	for i, p in ipairs(self._items) do
		if p == panel then
			table.remove(self._items, i)
			if IsValid(p) then p:Remove() end
			break
		end
	end
	self:InvalidateLayout()
end

function PANEL:gClear()
	for _, p in ipairs(self._items) do
		if IsValid(p) then p:Remove() end
	end
	self._items = {}
	self:InvalidateLayout()
end

function PANEL:gGetItems()
	return self._items
end

function PANEL:gGetCount()
	return #self._items
end

function PANEL:PerformLayout(w, h)
	local padX   = gRespX(self._padX)
	local padY   = gRespY(self._padY)
	local spaceY = gRespY(self._spaceY)
	local itemW  = w - padX * 2
	local curY   = padY

	for i, panel in ipairs(self._items) do
		if IsValid(panel) then
			local iH = self._itemH and gRespY(self._itemH) or panel:GetTall()
			panel:SetPos(padX, curY)
			panel:SetWide(itemW)
			if self._itemH then panel:SetTall(iH) end
			curY = curY + iH + (i < #self._items and spaceY or 0)
		end
	end

	self:SetTall(curY + padY)
end

function PANEL:Paint(w, h)
	if self._bgColor then
		draw.RoundedBox(self._radius, 0, 0, w, h, Color(self._bgColor.r, self._bgColor.g, self._bgColor.b, self._bgAlpha))
	end

	if self._stripes then
		local padX   = gRespX(self._padX)
		local padY   = gRespY(self._padY)
		local spaceY = gRespY(self._spaceY)
		local sc     = self._stripeColor or gTheme("border")

		for i, panel in ipairs(self._items) do
			if IsValid(panel) and i % 2 == 0 then
				local py = panel:GetY()
				local ph = panel:GetTall()
				draw.RoundedBox(self._radius, padX, py, w - padX * 2, ph, Color(sc.r, sc.g, sc.b, self._stripeAlpha))
			end
		end
	end

	if self._border then
		local bc = self._borderColor or gTheme("border")
		surface.SetDrawColor(bc.r, bc.g, bc.b, self._borderAlpha)
		surface.DrawOutlinedRect(0, 0, w, h, self._borderSize)
	end
end

vgui.Register("gListLayout", PANEL, "DPanel")