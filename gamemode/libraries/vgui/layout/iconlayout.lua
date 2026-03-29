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

	self._itemW       = 64
	self._itemH       = 64
	self._padX        = 4
	self._padY        = 4
	self._spaceX      = 4
	self._spaceY      = 4

	self._alignX      = TEXT_ALIGN_LEFT
	self._items       = {}
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

function PANEL:gSetItemSize(w, h)
	self._itemW = w
	self._itemH = h or w
	self:InvalidateLayout()
end

function PANEL:gSetPadding(x, y)
	self._padX = x or 4
	self._padY = y or x or 4
	self:InvalidateLayout()
end

function PANEL:gSetSpacing(x, y)
	self._spaceX = x or 4
	self._spaceY = y or x or 4
	self:InvalidateLayout()
end

function PANEL:gSetAlign(alignX)
	self._alignX = alignX or TEXT_ALIGN_LEFT
	self:InvalidateLayout()
end

function PANEL:gAddItem(panel)
	table.insert(self._items, panel)
	panel:SetParent(self)
	self:InvalidateLayout()
	return panel
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

function PANEL:PerformLayout(w, h)
	local iW     = gRespX(self._itemW)
	local iH     = gRespY(self._itemH)
	local padX   = gRespX(self._padX)
	local padY   = gRespY(self._padY)
	local spaceX = gRespX(self._spaceX)
	local spaceY = gRespY(self._spaceY)

	local cols   = math.max(1, math.floor((w - padX * 2 + spaceX) / (iW + spaceX)))
	local rows   = math.ceil(#self._items / cols)
	local totalH = padY * 2 + rows * iH + math.max(0, rows - 1) * spaceY

	for i, panel in ipairs(self._items) do
		if IsValid(panel) then
			local col = (i - 1) % cols
			local row = math.floor((i - 1) / cols)

			local rowCount = math.min(cols, #self._items - row * cols)
			local rowW     = rowCount * iW + (rowCount - 1) * spaceX
			local startX

			if self._alignX == TEXT_ALIGN_CENTER then
				startX = (w - rowW) * 0.5
			elseif self._alignX == TEXT_ALIGN_RIGHT then
				startX = w - padX - rowW
			else
				startX = padX
			end

			panel:SetPos(startX + col * (iW + spaceX), padY + row * (iH + spaceY))
			panel:SetSize(iW, iH)
		end
	end

	self:SetTall(totalH)
end

function PANEL:Paint(w, h)
	if self._bgColor then
		draw.RoundedBox(self._radius, 0, 0, w, h, Color(self._bgColor.r, self._bgColor.g, self._bgColor.b, self._bgAlpha))
	end

	if self._border then
		local bc = self._borderColor or gTheme("border")
		surface.SetDrawColor(bc.r, bc.g, bc.b, self._borderAlpha)
		surface.DrawOutlinedRect(0, 0, w, h, self._borderSize)
	end
end

vgui.Register("gIconLayout", PANEL, "DPanel")