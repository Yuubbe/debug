local PANEL = {}

local _HEADER_H = 32
local _ROW_H    = 28

function PANEL:Init()
	self:SetPaintBackground(false)

	self._radius       = gThemeRadius("sm")
	self._bgColor      = nil
	self._bgAlpha      = gThemeAlpha("mid")

	self._border       = false
	self._borderColor  = nil
	self._borderAlpha  = gThemeAlpha("border")
	self._borderSize   = 1

	self._headerH      = _HEADER_H
	self._headerColor  = nil
	self._headerAlpha  = gThemeAlpha("high")
	self._headerFont   = "OxaniumSemiBold"
	self._headerSize   = 12
	self._headerTextColor = nil

	self._rowH         = _ROW_H
	self._rowFont      = "OxaniumRegular"
	self._rowSize      = 12
	self._rowTextColor = nil
	self._rowBgEven    = nil
	self._rowBgOdd     = nil
	self._rowBgAlpha   = 20
	self._stripes      = true

	self._padX         = 10
	self._sepAlpha     = gThemeAlpha("sep")

	self._cols         = {}
	self._rows         = {}
	self._selectedRow  = nil
	self._hoverRow     = nil
	self._hoverAlpha   = {}

	self._sortCol      = nil
	self._sortDesc     = false

	self._scrollY      = 0
	self._scrollTarget = 0
	self._scrollAlpha  = 0
	self._scrollW      = 4
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

function PANEL:gSetHeaderStyle(color, alpha, font, size, textColor)
	self._headerColor     = color
	self._headerAlpha     = alpha    or gThemeAlpha("high")
	self._headerFont      = font     or "OxaniumSemiBold"
	self._headerSize      = size     or 12
	self._headerTextColor = textColor
end

function PANEL:gSetRowStyle(font, size, textColor, stripes, evenColor, oddColor, alpha)
	self._rowFont      = font     or "OxaniumRegular"
	self._rowSize      = size     or 12
	self._rowTextColor = textColor
	self._stripes      = stripes ~= false
	self._rowBgEven    = evenColor
	self._rowBgOdd     = oddColor
	self._rowBgAlpha   = alpha    or 20
end

function PANEL:gSetRowHeight(h)
	self._rowH = h
end

function PANEL:gSetHeaderHeight(h)
	self._headerH = h
end

function PANEL:gSetPadding(x)
	self._padX = x or 10
end

function PANEL:gAddColumn(label, width, align)
	table.insert(self._cols, {
		label = label,
		width = width,
		align = align or TEXT_ALIGN_LEFT,
		hover = 0,
	})
end

function PANEL:gAddRow(data)
	table.insert(self._rows, {
		data     = data,
		hover    = 0,
		selected = false,
	})
	return #self._rows
end

function PANEL:gClear()
	self._rows        = {}
	self._selectedRow = nil
	self._hoverRow    = nil
	self._scrollY     = 0
	self._scrollTarget = 0
end

function PANEL:gGetSelected()
	if not self._selectedRow then return nil end
	return self._rows[self._selectedRow] and self._rows[self._selectedRow].data or nil
end

function PANEL:gGetSelectedIndex()
	return self._selectedRow
end

function PANEL:gSetSelected(idx)
	self._selectedRow = idx
end

function PANEL:gRemoveRow(idx)
	table.remove(self._rows, idx)
	if self._selectedRow == idx then self._selectedRow = nil end
end

function PANEL:gSort(colIdx, desc)
	self._sortCol  = colIdx
	self._sortDesc = desc or false

	table.sort(self._rows, function(a, b)
		local va = a.data[colIdx] or ""
		local vb = b.data[colIdx] or ""
		local na, nb = tonumber(va), tonumber(vb)
		if na and nb then
			return self._sortDesc and na > nb or na < nb
		end
		return self._sortDesc and tostring(va) > tostring(vb) or tostring(va) < tostring(vb)
	end)
end

function PANEL:OnSelect(idx, data) end

function PANEL:_colWidths(w)
	local pad      = gRespX(self._padX)
	local scrollW  = gRespX(self._scrollW) + gRespX(4)
	local avail    = w - pad * 2 - scrollW
	local total    = 0
	local widths   = {}
	local flexCols = 0

	for _, col in ipairs(self._cols) do
		if col.width then
			local cw = gRespX(col.width)
			table.insert(widths, cw)
			total = total + cw
		else
			table.insert(widths, 0)
			flexCols = flexCols + 1
		end
	end

	local flexW = flexCols > 0 and math.max(0, (avail - total) / flexCols) or 0
	for i, col in ipairs(self._cols) do
		if not col.width then
			widths[i] = flexW
		end
	end

	return widths, pad
end

function PANEL:_rowAt(my, w, h)
	local headerH = gRespY(self._headerH)
	local rowH    = gRespY(self._rowH)
	if my < headerH then return nil end
	local idx = math.floor((my - headerH + self._scrollY) / rowH) + 1
	if idx < 1 or idx > #self._rows then return nil end
	return idx
end

function PANEL:OnMousePressed(code)
	if code ~= MOUSE_LEFT then return end
	local mx, my = self:CursorPos()
	local w, h   = self:GetSize()
	local headerH = gRespY(self._headerH)

	if my < headerH then
		local widths, pad = self:_colWidths(w)
		local cx = pad
		for i, cw in ipairs(widths) do
			if mx >= cx and mx <= cx + cw then
				if self._sortCol == i then
					self._sortDesc = not self._sortDesc
				else
					self._sortDesc = false
				end
				self:gSort(i, self._sortDesc)
				return
			end
			cx = cx + cw
		end
		return
	end

	local idx = self:_rowAt(my, w, h)
	if idx then
		self._selectedRow = idx
		self:OnSelect(idx, self._rows[idx].data)
	end
end

function PANEL:OnMouseWheeled(delta)
	local rowH      = gRespY(self._rowH)
	local headerH   = gRespY(self._headerH)
	local totalH    = #self._rows * rowH
	local maxScroll = math.max(0, totalH - (self:GetTall() - headerH))
	self._scrollTarget = math.Clamp(self._scrollTarget - delta * rowH, 0, maxScroll)
end

function PANEL:Think()
	local speed     = FrameTime() * 12
	local w, h      = self:GetSize()
	local mx, my    = self:CursorPos()
	local headerH   = gRespY(self._headerH)
	local rowH      = gRespY(self._rowH)
	local totalH    = #self._rows * rowH
	local maxScroll = math.max(0, totalH - (h - headerH))

	self._scrollY = self._scrollY + (self._scrollTarget - self._scrollY) * speed

	local hovered  = vgui.GetHoveredPanel()
	local hovering = IsValid(hovered) and (hovered == self or hovered:IsOurChild(self))
		and mx >= 0 and mx <= w and my >= 0 and my <= h

	self._scrollAlpha = math.Clamp(
		self._scrollAlpha + ((hovering and maxScroll > 0 and 160 or 0) - self._scrollAlpha) * speed,
		0, 160
	)

	local hoverIdx = nil
	if hovering then
		hoverIdx = self:_rowAt(my, w, h)
	end

	for i = 1, #self._rows do
		local target = (i == hoverIdx) and gThemeAlpha("hover") or 0
		self._rows[i].hover = math.Clamp(
			(self._rows[i].hover or 0) + (target - (self._rows[i].hover or 0)) * speed,
			0, gThemeAlpha("hover")
		)
	end
end

function PANEL:Paint(w, h)
	local r       = self._radius
	local headerH = gRespY(self._headerH)
	local rowH    = gRespY(self._rowH)
	local padX    = gRespX(self._padX)
	local bg      = self._bgColor or gTheme("surface")
	local hc      = self._headerColor or gTheme("elevated")
	local widths, _ = self:_colWidths(w)
	local scrollW = gRespX(self._scrollW)

	draw.RoundedBox(r, 0, 0, w, h, Color(bg.r, bg.g, bg.b, self._bgAlpha))
	draw.RoundedBoxEx(r, 0, 0, w, headerH, Color(hc.r, hc.g, hc.b, self._headerAlpha), true, true, false, false)

	local hFont = self._headerFont .. ":" .. self._headerSize
	local htc   = self._headerTextColor or gTheme("textDim")
	local cx    = padX

	for i, col in ipairs(self._cols) do
		local cw = widths[i]
		local tx = col.align == TEXT_ALIGN_CENTER and cx + cw * 0.5 or (col.align == TEXT_ALIGN_RIGHT and cx + cw - padX or cx)
		local label = col.label

		if self._sortCol == i then
			label = label .. " " .. (self._sortDesc and "▼" or "▲")
		end

		draw.SimpleText(label, hFont, tx, headerH * 0.5, htc, col.align, TEXT_ALIGN_CENTER)

		if i < #self._cols then
			local sep = gTheme("border")
			surface.SetDrawColor(sep.r, sep.g, sep.b, self._sepAlpha)
			surface.DrawLine(cx + cw, 4, cx + cw, headerH - 4)
		end

		cx = cx + cw
	end

	local sep = gTheme("border")
	surface.SetDrawColor(sep.r, sep.g, sep.b, self._sepAlpha)
	surface.DrawLine(0, headerH, w, headerH)

	local sx, sy = self:LocalToScreen(0, headerH)
	local ex, ey = self:LocalToScreen(w, h)
	render.SetScissorRect(sx, sy, ex, ey, true)

	local rFont = self._rowFont .. ":" .. self._rowSize
	local rtc   = self._rowTextColor or gTheme("text")

	for i, row in ipairs(self._rows) do
		local ry = headerH + (i - 1) * rowH - self._scrollY
		if ry + rowH < headerH or ry > h then continue end

		if self._stripes and i % 2 == 0 then
			local sc = self._rowBgEven or gTheme("border")
			surface.SetDrawColor(sc.r, sc.g, sc.b, self._rowBgAlpha)
			surface.DrawRect(0, ry, w - scrollW - gRespX(4), rowH)
		end

		if i == self._selectedRow then
			local ac = gTheme("accent")
			surface.SetDrawColor(ac.r, ac.g, ac.b, 35)
			surface.DrawRect(0, ry, w - scrollW - gRespX(4), rowH)
		end

		if row.hover > 0 and i ~= self._selectedRow then
			local hov = gTheme("border")
			surface.SetDrawColor(hov.r, hov.g, hov.b, row.hover)
			surface.DrawRect(0, ry, w - scrollW - gRespX(4), rowH)
		end

		if i == self._selectedRow then
			local ac = gTheme("accent")
			surface.SetDrawColor(ac.r, ac.g, ac.b, 180)
			surface.DrawRect(0, ry, gRespX(2), rowH)
		end

		local rcx = padX
		for j, col in ipairs(self._cols) do
			local cw  = widths[j]
			local val = tostring(row.data[j] or "")
			local tc  = i == self._selectedRow and gTheme("accent") or rtc
			local tx  = col.align == TEXT_ALIGN_CENTER and rcx + cw * 0.5 or (col.align == TEXT_ALIGN_RIGHT and rcx + cw - padX or rcx)
			draw.SimpleText(val, rFont, tx, ry + rowH * 0.5, tc, col.align, TEXT_ALIGN_CENTER)
			rcx = rcx + cw
		end

		if i < #self._rows then
			surface.SetDrawColor(sep.r, sep.g, sep.b, self._sepAlpha)
			surface.DrawLine(padX, ry + rowH, w - scrollW - gRespX(8), ry + rowH)
		end
	end

	render.SetScissorRect(0, 0, 0, 0, false)

	if self._scrollAlpha > 0 then
		local totalH    = #self._rows * rowH
		local viewH     = h - headerH
		local maxScroll = math.max(0, totalH - viewH)
		if maxScroll > 0 then
			local ratio  = math.min(viewH / totalH, 1)
			local thumbH = math.max(ratio * viewH, gRespY(20))
			local thumbY = headerH + (self._scrollY / maxScroll) * (viewH - thumbH)
			local sx     = w - scrollW - gRespX(2)

			surface.SetDrawColor(sep.r, sep.g, sep.b, self._scrollAlpha * 0.3)
			surface.DrawRect(sx, headerH, scrollW, viewH)
			surface.SetDrawColor(sep.r, sep.g, sep.b, self._scrollAlpha)
			surface.DrawRect(sx, thumbY, scrollW, thumbH)
		end
	end

	if self._border then
		local bc = self._borderColor or gTheme("border")
		surface.SetDrawColor(bc.r, bc.g, bc.b, self._borderAlpha)
		surface.DrawOutlinedRect(0, 0, w, h, self._borderSize)
	end
end

vgui.Register("gListView", PANEL, "DPanel")