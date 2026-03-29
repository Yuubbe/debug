local PANEL = {}

local _ROW_H   = 28
local _INDENT  = 16
local _ARROW_W = 16

function PANEL:Init()
	self:SetPaintBackground(false)

	self._radius      = gThemeRadius("sm")
	self._bgColor     = nil
	self._bgAlpha     = gThemeAlpha("mid")

	self._border      = false
	self._borderColor = nil
	self._borderAlpha = gThemeAlpha("border")
	self._borderSize  = 1

	self._rowH        = _ROW_H
	self._indent      = _INDENT
	self._font        = "OxaniumRegular"
	self._size        = 13
	self._textColor   = nil
	self._padX        = 8

	self._nodes       = {}
	self._flat        = {}
	self._selectedIdx = nil

	self._scrollY      = 0
	self._scrollTarget = 0
	self._scrollAlpha  = 0
	self._scrollW      = 4

	self._stripes      = false
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

function PANEL:gSetFont(font, size)
	self._font = font or "OxaniumRegular"
	self._size = size or 13
end

function PANEL:gSetRowHeight(h)
	self._rowH = h
end

function PANEL:gSetIndent(indent)
	self._indent = indent or _INDENT
end

function PANEL:gSetStripes(enabled)
	self._stripes = enabled
end

function PANEL:gAddNode(label, value, parentIdx)
	self._nodeCounter = (self._nodeCounter or 0) + 1

	local node = {
		id       = self._nodeCounter,
		label    = label,
		value    = value ~= nil and value or label,
		children = {},
		depth    = 0,
		parent   = parentIdx,
	}

	if parentIdx then
		local parent = self._nodes[parentIdx]
		if parent then
			node.depth = parent.depth + 1
			table.insert(parent.children, node)
		end
	else
		table.insert(self._nodes, node)
	end

	self:_rebuild()
	return node
end

function PANEL:gClear()
	self._nodes        = {}
	self._flat         = {}
	self._selectedIdx  = nil
	self._scrollY      = 0
	self._scrollTarget = 0
	self._nodeCounter  = 0
end

function PANEL:gGetSelected()
	if not self._selectedIdx then return nil end
	local item = self._flat[self._selectedIdx]
	return item and item.node or nil
end

function PANEL:_rebuild()
	local prevExpanded = {}
	for _, item in ipairs(self._flat) do
		if item.node.id then
			prevExpanded[item.node.id] = item.expanded
		end
	end

	self._flat = {}

	local function walk(nodes)
		for _, node in ipairs(nodes) do
			if not node.id then
				self._nodeCounter = (self._nodeCounter or 0) + 1
				node.id = self._nodeCounter
			end
			local expanded = prevExpanded[node.id] or false
			local item = { node = node, depth = node.depth, hover = 0, expanded = expanded }
			table.insert(self._flat, item)
			if expanded and #node.children > 0 then
				walk(node.children)
			end
		end
	end
	walk(self._nodes)
end

function PANEL:_rowAt(my, h)
	local rowH = gRespY(self._rowH)
	if my < 0 or my > h then return nil end
	local idx = math.floor((my + self._scrollY) / rowH) + 1
	if idx < 1 or idx > #self._flat then return nil end
	return idx
end

function PANEL:OnMousePressed(code)
	if code ~= MOUSE_LEFT then return end
	local mx, my = self:CursorPos()
	local w, h   = self:GetSize()
	if mx < 0 or mx > w or my < 0 or my > h then return end

	local idx = self:_rowAt(my, h)
	if not idx then return end

	local item   = self._flat[idx]
	local node   = item.node
	local padX   = gRespX(self._padX)
	local indent = gRespX(self._indent)
	local arrowW = gRespX(_ARROW_W)
	local arrowX = padX + item.depth * indent

	if #node.children > 0 and mx >= arrowX and mx <= arrowX + arrowW then
		local item = self._flat[idx]
		item.expanded = not item.expanded
		self:_rebuild()
		self:OnToggle(node, item.expanded)
	else
		self._selectedIdx = idx
		self:OnSelect(node)
	end
end

function PANEL:OnSelect(node)         end
function PANEL:OnToggle(node, expanded) end

function PANEL:OnMouseWheeled(delta)
	local rowH      = gRespY(self._rowH)
	local totalH    = #self._flat * rowH
	local maxScroll = math.max(0, totalH - self:GetTall())
	self._scrollTarget = math.Clamp(self._scrollTarget - delta * rowH, 0, maxScroll)
end

function PANEL:Think()
	local speed     = FrameTime() * 12
	local w, h      = self:GetSize()
	local mx, my    = self:CursorPos()
	local rowH      = gRespY(self._rowH)
	local totalH    = #self._flat * rowH
	local maxScroll = math.max(0, totalH - h)

	self._scrollY = self._scrollY + (self._scrollTarget - self._scrollY) * speed

	local hovered  = vgui.GetHoveredPanel()
	local hovering = IsValid(hovered) and (hovered == self or hovered:IsOurChild(self))
		and mx >= 0 and mx <= w and my >= 0 and my <= h

	self._scrollAlpha = math.Clamp(
		self._scrollAlpha + ((hovering and maxScroll > 0 and 160 or 0) - self._scrollAlpha) * speed,
		0, 160
	)

	local hoverIdx = hovering and self:_rowAt(my, h) or nil

	for i, item in ipairs(self._flat) do
		local target = (i == hoverIdx) and gThemeAlpha("hover") or 0
		item.hover = math.Clamp(
			(item.hover or 0) + (target - (item.hover or 0)) * speed,
			0, gThemeAlpha("hover")
		)
	end
end

function PANEL:Paint(w, h)
	local r       = self._radius
	local bg      = self._bgColor or gTheme("surface")
	local rowH    = gRespY(self._rowH)
	local padX    = gRespX(self._padX)
	local indent  = gRespX(self._indent)
	local arrowW  = gRespX(_ARROW_W)
	local scrollW = gRespX(self._scrollW)
	local font    = self._font .. ":" .. self._size

	draw.RoundedBox(r, 0, 0, w, h, Color(bg.r, bg.g, bg.b, self._bgAlpha))

	local sx, sy = self:LocalToScreen(0, 0)
	local ex, ey = self:LocalToScreen(w, h)
	render.SetScissorRect(sx, sy, ex, ey, true)

	local sep = gTheme("border")

	for i, item in ipairs(self._flat) do
		local node = item.node
		local ry   = (i - 1) * rowH - self._scrollY

		if ry + rowH < 0 or ry > h then continue end

		if self._stripes and i % 2 == 0 then
			surface.SetDrawColor(sep.r, sep.g, sep.b, 12)
			surface.DrawRect(0, ry, w - scrollW - gRespX(4), rowH)
		end

		if i == self._selectedIdx then
			local ac = gTheme("accent")
			surface.SetDrawColor(ac.r, ac.g, ac.b, 30)
			surface.DrawRect(0, ry, w - scrollW - gRespX(4), rowH)
			surface.SetDrawColor(ac.r, ac.g, ac.b, 180)
			surface.DrawRect(0, ry, gRespX(2), rowH)
		elseif item.hover > 0 then
			surface.SetDrawColor(sep.r, sep.g, sep.b, item.hover)
			surface.DrawRect(0, ry, w - scrollW - gRespX(4), rowH)
		end

		local tx = padX + item.depth * indent + arrowW
		local tc = i == self._selectedIdx and gTheme("accent") or (self._textColor or gTheme("text"))

		if #node.children > 0 then
			local ac    = item.expanded and gTheme("accent") or gTheme("textDim")
			local arrow = item.expanded and "▼" or "▶"
			draw.SimpleText(arrow, "OxaniumRegular:9", padX + item.depth * indent + arrowW * 0.5, ry + rowH * 0.5, ac, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			local dc = gTheme("textMute")
			surface.SetDrawColor(dc.r, dc.g, dc.b, 60)
			surface.DrawRect(padX + item.depth * indent + arrowW * 0.4, ry + rowH * 0.5, arrowW * 0.2, 1)
		end

		draw.SimpleText(node.label, font, tx, ry + rowH * 0.5, tc, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		if i < #self._flat then
			surface.SetDrawColor(sep.r, sep.g, sep.b, gThemeAlpha("sep"))
			surface.DrawLine(tx, ry + rowH, w - scrollW - gRespX(8), ry + rowH)
		end
	end

	render.SetScissorRect(0, 0, 0, 0, false)

	if self._scrollAlpha > 0 then
		local tH        = #self._flat * rowH
		local maxScroll = math.max(0, tH - h)
		if maxScroll > 0 then
			local ratio  = math.min(h / tH, 1)
			local thumbH = math.max(ratio * h, gRespY(20))
			local thumbY = (self._scrollY / maxScroll) * (h - thumbH)
			local sxp    = w - scrollW - gRespX(2)

			surface.SetDrawColor(sep.r, sep.g, sep.b, self._scrollAlpha * 0.3)
			surface.DrawRect(sxp, 0, scrollW, h)
			surface.SetDrawColor(sep.r, sep.g, sep.b, self._scrollAlpha)
			surface.DrawRect(sxp, thumbY, scrollW, thumbH)
		end
	end

	if self._border then
		local bc = self._borderColor or gTheme("border")
		surface.SetDrawColor(bc.r, bc.g, bc.b, self._borderAlpha)
		surface.DrawOutlinedRect(0, 0, w, h, self._borderSize)
	end
end

vgui.Register("gTree", PANEL, "DPanel")