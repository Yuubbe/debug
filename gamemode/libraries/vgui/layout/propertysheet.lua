local PANEL = {}

local _TAB_H = 36

function PANEL:Init()
	self:SetPaintBackground(false)

	self._radius      = gThemeRadius("sm")
	self._bgColor     = nil
	self._bgAlpha     = gThemeAlpha("mid")

	self._border      = false
	self._borderColor = nil
	self._borderAlpha = gThemeAlpha("border")
	self._borderSize  = 1

	self._tabH        = _TAB_H
	self._tabFont     = "OxaniumMedium"
	self._tabSize     = 13
	self._tabColor    = nil
	self._tabBg       = nil
	self._tabBgAlpha  = gThemeAlpha("mid")
	self._tabActiveBg = nil
	self._tabActiveColor = nil
	self._tabPadX     = 16

	self._tabs        = {}
	self._activeIdx   = nil
	self._tabHovers   = {}
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

function PANEL:gSetTabHeight(h)
	self._tabH = h
	self:InvalidateLayout()
end

function PANEL:gSetTabFont(font, size)
	self._tabFont = font or "OxaniumMedium"
	self._tabSize = size or 13
end

function PANEL:gSetTabColors(normal, active, bgNormal, bgActive, bgAlpha)
	self._tabColor       = normal
	self._tabActiveColor = active
	self._tabBg          = bgNormal
	self._tabActiveBg    = bgActive
	self._tabBgAlpha     = bgAlpha or gThemeAlpha("mid")
end

function PANEL:gSetTabPadding(x)
	self._tabPadX = x or 16
	self:InvalidateLayout()
end

function PANEL:gAddTab(label, panel)
	local idx = #self._tabs + 1

	table.insert(self._tabs, {
		label  = label,
		panel  = panel,
		hover  = 0,
	})

	panel:SetParent(self)
	panel:SetVisible(false)

	self._tabHovers[idx] = 0

	if not self._activeIdx then
		self:gSetActive(1)
	else
		self:InvalidateLayout()
	end

	return idx
end

function PANEL:gSetActive(idx)
	if not self._tabs[idx] then return end

	if self._activeIdx and self._tabs[self._activeIdx] then
		self._tabs[self._activeIdx].panel:SetVisible(false)
	end

	self._activeIdx = idx
	self._tabs[idx].panel:SetVisible(true)
	self:InvalidateLayout()
	self:OnTabChanged(idx, self._tabs[idx].label)
end

function PANEL:gGetActive()
	return self._activeIdx
end

function PANEL:gGetTab(idx)
	return self._tabs[idx]
end

function PANEL:OnTabChanged(idx, label) end

function PANEL:_tabRects()
	local w      = self:GetWide()
	local count  = #self._tabs
	if count == 0 then return {} end

	local tabW   = math.floor(w / count)
	local rects  = {}

	for i = 1, count do
		local x = (i - 1) * tabW
		local tw = (i == count) and (w - x) or tabW
		rects[i] = { x = x, w = tw }
	end

	return rects
end

function PANEL:OnMousePressed(code)
	if code ~= MOUSE_LEFT then return end

	local mx, my = self:CursorPos()
	local tabH   = gRespY(self._tabH)

	if my > tabH then return end

	local rects = self:_tabRects()
	for i, r in ipairs(rects) do
		if mx >= r.x and mx <= r.x + r.w then
			self:gSetActive(i)
			return
		end
	end
end

function PANEL:Think()
	local speed  = FrameTime() * 10
	local mx, my = self:CursorPos()
	local tabH   = gRespY(self._tabH)
	local rects  = self:_tabRects()

	for i, r in ipairs(rects) do
		local hovering = my >= 0 and my <= tabH and mx >= r.x and mx <= r.x + r.w and i ~= self._activeIdx
		local target   = hovering and gThemeAlpha("hover") or 0
		self._tabs[i].hover = math.Clamp(
			self._tabs[i].hover + (target - self._tabs[i].hover) * speed,
			0, gThemeAlpha("hover")
		)
	end
end

function PANEL:PerformLayout(w, h)
	local tabH  = gRespY(self._tabH)
	local rects = self:_tabRects()

	for i, tab in ipairs(self._tabs) do
		if IsValid(tab.panel) then
			tab.panel:SetPos(0, tabH)
			tab.panel:SetSize(w, h - tabH)
		end
	end
end

function PANEL:Paint(w, h)
	local r    = self._radius
	local tabH = gRespY(self._tabH)
	local bg   = self._bgColor or gTheme("surface")

	draw.RoundedBox(r, 0, 0, w, h, Color(bg.r, bg.g, bg.b, self._bgAlpha))

	local tabBg = self._tabBg or gTheme("elevated")
	draw.RoundedBoxEx(r, 0, 0, w, tabH, Color(tabBg.r, tabBg.g, tabBg.b, self._tabBgAlpha), true, true, false, false)

	local rects = self:_tabRects()
	local font  = self._tabFont .. ":" .. self._tabSize
	local padX  = gRespX(self._tabPadX)

	for i, tab in ipairs(self._tabs) do
		local rx   = rects[i].x
		local rw   = rects[i].w
		local isActive = i == self._activeIdx

		if isActive then
			local abg = self._tabActiveBg or gTheme("surface")
			local tl  = i == 1
			local tr  = i == #self._tabs
			draw.RoundedBoxEx(r, rx, 0, rw, tabH, Color(abg.r, abg.g, abg.b, self._bgAlpha), tl, tr, false, false)

			local sep = gTheme("accent")
			surface.SetDrawColor(sep.r, sep.g, sep.b, 200)
			surface.DrawLine(rx, tabH - 1, rx + rw, tabH - 1)
			surface.DrawLine(rx, tabH - 2, rx + rw, tabH - 2)
		elseif tab.hover > 0 then
			local hc = gTheme("border")
			draw.RoundedBox(0, rx, 0, rw, tabH, Color(hc.r, hc.g, hc.b, tab.hover))
		end

		local tc = isActive
			and (self._tabActiveColor or gTheme("text"))
			or (self._tabColor or gTheme("textDim"))

		draw.SimpleText(tab.label, font, rx + rw * 0.5, tabH * 0.5, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		if i < #self._tabs then
			local sep = gTheme("border")
			surface.SetDrawColor(sep.r, sep.g, sep.b, gThemeAlpha("sep"))
			surface.DrawLine(rx + rw, 4, rx + rw, tabH - 4)
		end
	end

	local sep = gTheme("border")
	surface.SetDrawColor(sep.r, sep.g, sep.b, gThemeAlpha("sep"))
	surface.DrawLine(0, tabH, w, tabH)

	if self._border then
		local bc = self._borderColor or gTheme("border")
		surface.SetDrawColor(bc.r, bc.g, bc.b, self._borderAlpha)
		surface.DrawOutlinedRect(0, 0, w, h, self._borderSize)
	end
end

vgui.Register("gPropertySheet", PANEL, "DPanel")