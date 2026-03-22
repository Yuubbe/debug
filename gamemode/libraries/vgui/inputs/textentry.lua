local PANEL = {}

function PANEL:Init()
	self:SetPaintBackground(false)

	self._radius           = gThemeRadius("sm")
	self._bgColor          = nil
	self._bgAlpha          = gThemeAlpha("mid")

	self._border           = true
	self._borderColor      = nil
	self._borderAlpha      = gThemeAlpha("border")
	self._borderFocusAlpha = 0
	self._borderSize       = 1

	self._font             = "OxaniumRegular"
	self._size             = 13
	self._textColor        = nil
	self._alignX           = TEXT_ALIGN_LEFT
	self._padX             = 10

	self._placeholder      = ""
	self._placeholderColor = nil

	self._focused          = false
	self._disabled         = false

	self._state            = "default"
	self._stateColors      = {
		success = "success",
		danger  = "danger",
		warning = "warning",
	}

	self._entry = vgui.Create("DTextEntry", self)
	self._entry:SetDrawBackground(false)
	self._entry:SetPaintBackground(false)
	self._entry:SetDrawLanguageIDAtLeft(false)
	self._entry:SetCursor("beam")

	self._entry.OnGetFocus = function()
		self._focused = true
	end

	self._entry.OnLoseFocus = function()
		self._focused = false
	end

	self._entry.OnChange = function()
		self:OnChange()
	end

	self._entry.OnEnter = function()
		self:OnEnter()
	end

	self:_syncEntry()
end

function PANEL:_syncEntry()
	local w, h = self:GetSize()
	local padX = gRespX(self._padX)

	self._entry:SetFont(self._font .. ":" .. self._size)
	self._entry:SetTextColor(self._textColor or gTheme("text"))
	self._entry:SetCursorColor(self._textColor or gTheme("text"))
	self._entry:SetHighlightColor(gTheme("accent"))

	if w > 0 and h > 0 then
		if self._alignX == TEXT_ALIGN_RIGHT then
			self._entry:SetPos(0, 0)
			self._entry:SetSize(w - padX, h)
		elseif self._alignX == TEXT_ALIGN_CENTER then
			self._entry:SetPos(0, 0)
			self._entry:SetSize(w, h)
		else
			self._entry:SetPos(padX, 0)
			self._entry:SetSize(w - padX, h)
		end
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
	self._padX = x or 10
	self:_syncEntry()
end

function PANEL:gSetAlign(alignX)
	self._alignX = alignX or TEXT_ALIGN_LEFT
	self:_syncEntry()
end

function PANEL:gSetPlaceholder(text, color)
	self._placeholder      = text
	self._placeholderColor = color
end

function PANEL:gSetDisabled(disabled)
	self._disabled = disabled
	self._entry:SetEditable(not disabled)
	self._entry:SetMouseInputEnabled(not disabled)
end

function PANEL:gSetState(state)
	self._state = state or "default"
end

function PANEL:GetValue()
	return self._entry:GetValue()
end

function PANEL:SetValue(val)
	self._entry:SetValue(val)
end

function PANEL:OnChange() end
function PANEL:OnEnter()  end

function PANEL:Think()
	local speed        = FrameTime() * 10
	local targetBorder = self._focused and 80 or 0
	self._borderFocusAlpha = math.Clamp(
		self._borderFocusAlpha + (targetBorder - self._borderFocusAlpha) * speed,
		0, 80
	)
end

function PANEL:Paint(w, h)
	local r  = self._radius
	local bg = self._bgColor or gTheme("surface")
	local a  = self._disabled and gThemeAlpha("disabled") or self._bgAlpha

	draw.RoundedBox(r, 0, 0, w, h, Color(bg.r, bg.g, bg.b, a))

	if self._border then
		local stateKey = self._stateColors[self._state]
		local bc       = stateKey and gTheme(stateKey) or (self._borderColor or gTheme("border"))
		local ba       = stateKey and 180 or self._borderAlpha

		surface.SetDrawColor(bc.r, bc.g, bc.b, ba)
		surface.DrawOutlinedRect(0, 0, w, h, self._borderSize)

		if self._borderFocusAlpha > 0 and not stateKey then
			local ac = gTheme("accent")
			surface.SetDrawColor(ac.r, ac.g, ac.b, self._borderFocusAlpha)
			surface.DrawOutlinedRect(0, 0, w, h, self._borderSize)
		end
	end

	if not self._focused and self._entry:GetValue() == "" and self._placeholder ~= "" then
		local pc   = self._placeholderColor or gTheme("textMute")
		local font = self._font .. ":" .. self._size
		local padX = gRespX(self._padX)
		local tx

		if self._alignX == TEXT_ALIGN_CENTER then
			tx = w * 0.5
		elseif self._alignX == TEXT_ALIGN_RIGHT then
			tx = w - padX
		else
			tx = padX
		end

		draw.SimpleText(self._placeholder, font, tx, h * 0.5, pc, self._alignX, TEXT_ALIGN_CENTER)
	end
end

vgui.Register("gTextEntry", PANEL, "DPanel")