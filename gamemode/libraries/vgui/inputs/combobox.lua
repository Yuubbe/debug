local PANEL = {}

local _ARROW_W = 28
local _ITEM_H  = 32

function PANEL:Init()
	self:SetCursor("hand")
	self:SetPaintBackground(false)

	self._radius      = gThemeRadius("sm")
	self._bgColor     = nil
	self._bgAlpha     = gThemeAlpha("mid")

	self._border      = true
	self._borderColor = nil
	self._borderAlpha = gThemeAlpha("border")
	self._borderFocusAlpha = 0
	self._borderSize  = 1

	self._font        = "OxaniumRegular"
	self._size        = 13
	self._textColor   = nil
	self._padX        = 10

	self._placeholder = "Sélectionner..."
	self._selected    = nil
	self._selectedIdx = nil

	self._items       = {}
	self._open        = false
	self._hoverAlpha  = 0
	self._disabled    = false

	self._dropdown    = nil
	self._itemHovers  = {}
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

function PANEL:gSetTextColor(color)
	self._textColor = color
end

function PANEL:gSetPadding(x)
	self._padX = x or 10
end

function PANEL:gSetPlaceholder(text)
	self._placeholder = text
end

function PANEL:gSetDisabled(disabled)
	self._disabled = disabled
	self:SetMouseInputEnabled(not disabled)
	if disabled then self:_closeDropdown() end
end

function PANEL:gAddItem(label, value)
	table.insert(self._items, { label = label, value = value ~= nil and value or label })
end

function PANEL:gSetItems(items)
	self._items = {}
	for _, item in ipairs(items) do
		if type(item) == "string" then
			table.insert(self._items, { label = item, value = item })
		else
			table.insert(self._items, { label = item.label, value = item.value ~= nil and item.value or item.label })
		end
	end
end

function PANEL:gGetSelected()
	return self._selected
end

function PANEL:gGetSelectedIndex()
	return self._selectedIdx
end

function PANEL:gSetSelected(idx)
	if not self._items[idx] then return end
	self._selected    = self._items[idx]
	self._selectedIdx = idx
	self:OnSelect(idx, self._selected.label, self._selected.value)
end

function PANEL:gClear()
	self._selected    = nil
	self._selectedIdx = nil
end

function PANEL:OnSelect(idx, label, value) end

function PANEL:_closeDropdown()
	self._open = false
	if IsValid(self._dropdown) then
		self._dropdown:Remove()
		self._dropdown = nil
	end
end

function PANEL:_openDropdown()
	if IsValid(self._dropdown) then
		self:_closeDropdown()
		return
	end

	self._open = true

	local sx, sy   = self:LocalToScreen(0, 0)
	local w        = self:GetWide()
	local itemH    = gRespY(_ITEM_H)
	local totalH   = #self._items * itemH
	local r        = self._radius
	local bg       = self._bgColor or gTheme("surface")
	local font     = self._font .. ":" .. self._size
	local padX     = gRespX(self._padX)

	local drop = vgui.Create("DPanel")
	drop:SetPos(sx, sy + self:GetTall() + gRespY(4))
	drop:SetSize(w, totalH)
	drop:SetZPos(32000)
	drop:MakePopup()
	drop:SetKeyboardInputEnabled(false)

	local hovers = {}
	for i = 1, #self._items do hovers[i] = 0 end

	drop.Paint = function(_, dw, dh)
		draw.RoundedBox(r, 0, 0, dw, dh, Color(bg.r, bg.g, bg.b, gThemeAlpha("high")))

		local bc = self._borderColor or gTheme("border")
		surface.SetDrawColor(bc.r, bc.g, bc.b, self._borderAlpha)
		surface.DrawOutlinedRect(0, 0, dw, dh, self._borderSize)

		for i, item in ipairs(self._items) do
			local iy  = (i - 1) * itemH
			local tc  = self._textColor or gTheme("text")
			local isSelected = self._selectedIdx == i

			if hovers[i] > 0 then
				local hc = gTheme("border")
				draw.RoundedBox(0, 0, iy, dw, itemH, Color(hc.r, hc.g, hc.b, hovers[i]))
			end

			if isSelected then
				local ac = gTheme("accent")
				draw.RoundedBox(0, 0, iy, dw, itemH, Color(ac.r, ac.g, ac.b, 30))
				tc = gTheme("accent")
			end

			draw.SimpleText(item.label, font, padX, iy + itemH * 0.5, tc, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		local sep = gTheme("border")
		for i = 1, #self._items - 1 do
			local iy = i * itemH
			surface.SetDrawColor(sep.r, sep.g, sep.b, gThemeAlpha("sep"))
			surface.DrawLine(padX, iy, dw - padX, iy)
		end
	end

	drop.Think = function(_)
		local speed = FrameTime() * 10
		local mx, my = input.GetCursorPos()
		local dx, dy = drop:GetPos()

		for i = 1, #self._items do
			local iy      = (i - 1) * itemH
			local hovering = mx >= dx and mx <= dx + w and my >= dy + iy and my <= dy + iy + itemH
			hovers[i] = math.Clamp(hovers[i] + ((hovering and gThemeAlpha("hover") or 0) - hovers[i]) * speed, 0, gThemeAlpha("hover"))
		end

		if not self:IsValid() then
			drop:Remove()
		end
	end

	drop.OnMousePressed = function(_, code)
		if code ~= MOUSE_LEFT then return end
		local mx, my = input.GetCursorPos()
		local dx, dy = drop:GetPos()

		for i, item in ipairs(self._items) do
			local iy = (i - 1) * itemH
			if mx >= dx and mx <= dx + w and my >= dy + iy and my <= dy + iy + itemH then
				self._selected    = item
				self._selectedIdx = i
				self:OnSelect(i, item.label, item.value)
				self:_closeDropdown()
				return
			end
		end

		self:_closeDropdown()
	end

	self._dropdown  = drop
	self._itemHovers = hovers
end

function PANEL:OnMousePressed(code)
	if code ~= MOUSE_LEFT then return end
	if self._disabled then return end

	if self._open then
		self:_closeDropdown()
	else
		self:_openDropdown()
	end
end

function PANEL:OnRemove()
	self:_closeDropdown()
end

function PANEL:Think()
	local speed    = FrameTime() * 10
	local mx, my   = self:CursorPos()
	local w, h     = self:GetSize()
	local hovering = not self._disabled and mx >= 0 and mx <= w and my >= 0 and my <= h

	self._hoverAlpha = math.Clamp(
		self._hoverAlpha + ((hovering and gThemeAlpha("hover") or 0) - self._hoverAlpha) * speed,
		0, gThemeAlpha("hover")
	)

	self._borderFocusAlpha = math.Clamp(
		self._borderFocusAlpha + ((self._open and 80 or 0) - self._borderFocusAlpha) * speed,
		0, 80
	)

	if self._open and IsValid(self._dropdown) then
		local sx, sy = self:LocalToScreen(0, 0)
		self._dropdown:SetPos(sx, sy + h + gRespY(4))
	end
end

function PANEL:Paint(w, h)
	local r   = self._radius
	local bg  = self._bgColor or gTheme("surface")
	local a   = self._disabled and gThemeAlpha("disabled") or self._bgAlpha
	local font = self._font .. ":" .. self._size
	local padX = gRespX(self._padX)
	local aW   = gRespX(_ARROW_W)

	draw.RoundedBox(r, 0, 0, w, h, Color(bg.r, bg.g, bg.b, a))

	if self._hoverAlpha > 0 then
		local hc = gTheme("border")
		draw.RoundedBox(r, 0, 0, w, h, Color(hc.r, hc.g, hc.b, self._hoverAlpha))
	end

	local label = self._selected and self._selected.label or self._placeholder
	local tc    = self._selected
		and (self._textColor or gTheme("text"))
		or gTheme("textMute")

	if self._disabled then tc = gTheme("textMute") end

	draw.SimpleText(label, font, padX, h * 0.5, tc, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	local ac    = self._open and gTheme("accent") or (self._textColor or gTheme("textDim"))
	local arrow = self._open and "▲" or "▼"
	draw.SimpleText(arrow, "OxaniumRegular:10", w - aW * 0.5, h * 0.5, ac, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if self._border then
		local bc = self._borderColor or gTheme("border")
		surface.SetDrawColor(bc.r, bc.g, bc.b, self._borderAlpha)
		surface.DrawOutlinedRect(0, 0, w, h, self._borderSize)

		if self._borderFocusAlpha > 0 then
			local acc = gTheme("accent")
			surface.SetDrawColor(acc.r, acc.g, acc.b, self._borderFocusAlpha)
			surface.DrawOutlinedRect(0, 0, w, h, self._borderSize)
		end
	end
end

vgui.Register("gComboBox", PANEL, "DPanel")