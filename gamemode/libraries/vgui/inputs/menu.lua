local PANEL = {}

local _ITEM_H = 30
local _SEP_H  = 8
local _PAD_X  = 12
local _MIN_W  = 160

function PANEL:Init()
	self:SetPaintBackground(false)
	self:SetZPos(32767)
	self:MakePopup()
	self:SetKeyboardInputEnabled(false)

	self._items       = {}
	self._hovers      = {}
	self._bgColor     = nil
	self._bgAlpha     = 248
	self._font        = "OxaniumRegular"
	self._size        = 12
	self._textColor   = nil
	self._accentColor = nil
	self._borderAlpha = gThemeAlpha("border")
	self._width       = _MIN_W
end

function PANEL:gSetBgColor(color, alpha)
	self._bgColor = color
	if alpha then self._bgAlpha = alpha end
end

function PANEL:gSetFont(font, size)
	self._font = font or "OxaniumRegular"
	self._size = size or 12
end

function PANEL:gAddItem(label, callback, color)
	table.insert(self._items, {
		type     = "item",
		label    = label,
		callback = callback,
		color    = color,
		hover    = 0,
	})
	self:_recalc()
end

function PANEL:gAddSeparator()
	table.insert(self._items, { type = "sep" })
	self:_recalc()
end

function PANEL:gAddDanger(label, callback)
	self:gAddItem(label, callback, gTheme("danger"))
end

function PANEL:gAddWarning(label, callback)
	self:gAddItem(label, callback, gTheme("warning"))
end

function PANEL:_recalc()
	local h = 4
	for _, item in ipairs(self._items) do
		h = h + (item.type == "sep" and gRespY(_SEP_H) or gRespY(_ITEM_H))
	end
	self:SetSize(gRespX(self._width), h + 4)
end

function PANEL:_itemAt(my)
	local y = 4
	for i, item in ipairs(self._items) do
		local ih = item.type == "sep" and gRespY(_SEP_H) or gRespY(_ITEM_H)
		if item.type == "item" and my >= y and my < y + ih then
			return i, item
		end
		y = y + ih
	end
	return nil, nil
end

function PANEL:OnMousePressed(code)
	if code ~= MOUSE_LEFT then
		self:Remove()
		return
	end

	local mx, my = self:CursorPos()
	local _, item = self:_itemAt(my)

	if item and item.callback then
		item.callback()
	end

	self:Remove()
end

function PANEL:Think()
	local mx, my = self:CursorPos()
	local w, h   = self:GetSize()
	local speed  = FrameTime() * 12

	if mx < -gRespX(8) or mx > w + gRespX(8) or my < -gRespY(8) or my > h + gRespY(8) then
		self:Remove()
		return
	end

	local y = 4
	for _, item in ipairs(self._items) do
		local ih = item.type == "sep" and gRespY(_SEP_H) or gRespY(_ITEM_H)
		if item.type == "item" then
			local hov    = mx >= 0 and mx <= w and my >= y and my < y + ih
			local target = hov and gThemeAlpha("hover") or 0
			item.hover   = math.Clamp(item.hover + (target - item.hover) * speed, 0, gThemeAlpha("hover"))
		end
		y = y + ih
	end
end

function PANEL:Paint(w, h)
	local bg   = self._bgColor or gTheme("elevated")
	local font = self._font .. ":" .. self._size

	surface.SetDrawColor(bg.r, bg.g, bg.b, self._bgAlpha)
	surface.DrawRect(0, 0, w, h)

	local bc = gTheme("border")
	surface.SetDrawColor(bc.r, bc.g, bc.b, self._borderAlpha)
	surface.DrawOutlinedRect(0, 0, w, h, 1)

	local y   = 4
	local padX = gRespX(_PAD_X)

	for _, item in ipairs(self._items) do
		if item.type == "sep" then
			local ih = gRespY(_SEP_H)
			surface.SetDrawColor(bc.r, bc.g, bc.b, gThemeAlpha("sep"))
			surface.DrawLine(padX, y + ih * 0.5, w - padX, y + ih * 0.5)
			y = y + ih
		else
			local ih = gRespY(_ITEM_H)

			if item.hover > 0 then
				surface.SetDrawColor(bc.r, bc.g, bc.b, item.hover)
				surface.DrawRect(0, y, w, ih)
			end

			local tc = item.color or self._textColor or gTheme("text")
			draw.SimpleText(item.label, font, padX, y + ih * 0.5, tc, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			y = y + ih
		end
	end
end

vgui.Register("gMenu", PANEL, "DPanel")

function gMenu(x, y, width)
	local m = vgui.Create("gMenu")
	if width then m._width = width end
	m:_recalc()
	m:SetPos(
		math.Clamp(x, 0, ScrW() - m:GetWide()),
		math.Clamp(y, 0, ScrH() - m:GetTall())
	)
	return m
end