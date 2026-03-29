local PANEL = {}

local _BTN_W = 28

function PANEL:Init()
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
	self._padX        = 8

	self._min         = nil
	self._max         = nil
	self._step        = 1
	self._decimals    = 0
	self._value       = 0

	self._disabled    = false
	self._focused     = false

	self._btnHoverL   = 0
	self._btnHoverR   = 0

	self._entry = vgui.Create("DTextEntry", self)
	self._entry:SetDrawBackground(false)
	self._entry:SetPaintBackground(false)
	self._entry:SetDrawLanguageIDAtLeft(false)
	self._entry:SetNumeric(true)

	self._entry.OnGetFocus = function()
		self._focused = true
	end

	self._entry.OnLoseFocus = function()
		self._focused = false
		self:_commitEntry()
	end

	self._entry.OnEnter = function()
		self:_commitEntry()
		self:OnEnter(self._value)
	end

	self:_syncEntry()
end

function PANEL:_commitEntry()
	local raw = tonumber(self._entry:GetValue())
	if raw then
		self:gSetValue(raw)
	else
		self._entry:SetValue(string.format("%." .. self._decimals .. "f", self._value))
	end
end

function PANEL:_syncEntry()
	local w, h = self:GetSize()
	local bW   = gRespX(_BTN_W)
	local padX = gRespX(self._padX)

	self._entry:SetFont(self._font .. ":" .. self._size)
	self._entry:SetTextColor(self._textColor or gTheme("text"))
	self._entry:SetCursorColor(self._textColor or gTheme("text"))
	self._entry:SetHighlightColor(gTheme("accent"))

	if w > 0 and h > 0 then
		self._entry:SetPos(bW + padX, 0)
		self._entry:SetSize(w - bW * 2 - padX * 2, h)
		self._entry:SetValue(string.format("%." .. self._decimals .. "f", self._value))
	end
end

function PANEL:PerformLayout(w, h)
	self:_syncEntry()
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
	self:_syncEntry()
end

function PANEL:gSetTextColor(color)
	self._textColor = color
	self:_syncEntry()
end

function PANEL:gSetPadding(x)
	self._padX = x or 8
	self:_syncEntry()
end

function PANEL:gSetRange(min, max)
	self._min   = min
	self._max   = max
	self._value = math.Clamp(self._value, min or self._value, max or self._value)
	self:_syncEntry()
end

function PANEL:gSetStep(step)
	self._step     = step or 1
	self._decimals = (tostring(step):find("%.") and #tostring(step):match("%.(.*)") or 0)
	self:_syncEntry()
end

function PANEL:gSetValue(val)
	local stepped = math.Round(val / self._step) * self._step
	if self._min then stepped = math.max(stepped, self._min) end
	if self._max then stepped = math.min(stepped, self._max) end
	self._value = stepped
	self._entry:SetValue(string.format("%." .. self._decimals .. "f", self._value))
	self:OnChange(self._value)
end

function PANEL:gGetValue()
	return self._value
end

function PANEL:gSetDisabled(disabled)
	self._disabled = disabled
	self._entry:SetEditable(not disabled)
	self._entry:SetMouseInputEnabled(not disabled)
	self:SetMouseInputEnabled(not disabled)
end

function PANEL:OnChange(value) end
function PANEL:OnEnter(value)  end

function PANEL:OnMousePressed(code)
	if code ~= MOUSE_LEFT then return end
	if self._disabled then return end

	local mx   = self:CursorPos()
	local bW   = gRespX(_BTN_W)
	local w    = self:GetWide()

	if mx <= bW then
		self:gSetValue(self._value - self._step)
	elseif mx >= w - bW then
		self:gSetValue(self._value + self._step)
	end
end

function PANEL:Think()
	local speed  = FrameTime() * 10
	local mx, my = self:CursorPos()
	local w, h   = self:GetSize()
	local bW     = gRespX(_BTN_W)

	local hoverL = not self._disabled and mx >= 0 and mx <= bW and my >= 0 and my <= h
	local hoverR = not self._disabled and mx >= w - bW and mx <= w and my >= 0 and my <= h

	self._btnHoverL = math.Clamp(self._btnHoverL + ((hoverL and gThemeAlpha("hover") or 0) - self._btnHoverL) * speed, 0, gThemeAlpha("hover"))
	self._btnHoverR = math.Clamp(self._btnHoverR + ((hoverR and gThemeAlpha("hover") or 0) - self._btnHoverR) * speed, 0, gThemeAlpha("hover"))

	local targetBorder = self._focused and 80 or 0
	self._borderFocusAlpha = math.Clamp(self._borderFocusAlpha + (targetBorder - self._borderFocusAlpha) * speed, 0, 80)
end

function PANEL:Paint(w, h)
	local r   = self._radius
	local bg  = self._bgColor or gTheme("surface")
	local a   = self._disabled and gThemeAlpha("disabled") or self._bgAlpha
	local bW  = gRespX(_BTN_W)
	local font = self._font .. ":" .. self._size

	draw.RoundedBox(r, 0, 0, w, h, Color(bg.r, bg.g, bg.b, a))

	local sep = gTheme("border")
	local sa  = self._borderAlpha

	if self._btnHoverL > 0 then
		local hc = gTheme("border")
		draw.RoundedBoxEx(r, 0, 0, bW, h, Color(hc.r, hc.g, hc.b, self._btnHoverL), true, false, true, false)
	end

	if self._btnHoverR > 0 then
		local hc = gTheme("border")
		draw.RoundedBoxEx(r, w - bW, 0, bW, h, Color(hc.r, hc.g, hc.b, self._btnHoverR), false, true, false, true)
	end

	local tc = self._disabled and gTheme("textMute") or (self._textColor or gTheme("textDim"))
	draw.SimpleText("−", font, bW * 0.5, h * 0.5, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText("+", font, w - bW * 0.5, h * 0.5, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	surface.SetDrawColor(sep.r, sep.g, sep.b, sa)
	surface.DrawLine(bW, 0, bW, h)
	surface.DrawLine(w - bW, 0, w - bW, h)

	if self._border then
		local bc = self._borderColor or gTheme("border")
		surface.SetDrawColor(bc.r, bc.g, bc.b, self._borderAlpha)
		surface.DrawOutlinedRect(0, 0, w, h, self._borderSize)

		if self._borderFocusAlpha > 0 then
			local ac = gTheme("accent")
			surface.SetDrawColor(ac.r, ac.g, ac.b, self._borderFocusAlpha)
			surface.DrawOutlinedRect(0, 0, w, h, self._borderSize)
		end
	end
end

vgui.Register("gNumberWang", PANEL, "DPanel")