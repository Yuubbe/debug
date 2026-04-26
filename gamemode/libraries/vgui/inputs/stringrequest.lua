local PANEL = {}

function PANEL:Init()
	local base = vgui.GetControlTable("gFrame")
	if base and base.Init then base.Init(self) end
	if self.gSetRadius then self:gSetRadius(0) end

	self._onConfirm = nil
	self._onCancel  = nil
	self._entry     = nil
	self._btnOk     = nil
	self._btnCancel = nil
end

function PANEL:gBuild(title, message, placeholder, onConfirm, onCancel)
	local W        = 400
	local H        = 160
	local HEADER_H = 36
	local PAD      = 12
	local BTN_H    = 30
	local hc       = gTheme("elevated")
	local pnl      = self

	self._onConfirm = onConfirm
	self._onCancel  = onCancel

	self:gSetSize(W, H)
	self:gCenter()
	self:gSetBgColor(gTheme("bg"), gThemeAlpha("full"))
	self:gSetHeader(true, hc, gThemeAlpha("high"), HEADER_H)
	self:gSetTitle(title or "Confirmation", "OxaniumMedium", 13, gContrastText(hc), TEXT_ALIGN_LEFT)
	self:gSetCloseButton(true, "OxaniumLight", 16, gContrastText(hc, 160))
	self:gSetDraggable(false)
	self:gSetBorder(true, gThemeAlpha("border"))

	local msgLbl = vgui.Create("gLabel", self)
	msgLbl:SetPos(gRespX(PAD), gRespY(HEADER_H + PAD))
	msgLbl:SetSize(gRespX(W - PAD * 2), gRespY(16))
	msgLbl:gSetFont("OxaniumRegular", 11)
	msgLbl:gSetColor(gTheme("textDim"))
	msgLbl:gSetText(message or "")

	self._entry = vgui.Create("gTextEntry", self)
	self._entry:SetPos(gRespX(PAD), gRespY(HEADER_H + PAD + 16 + 6))
	self._entry:SetSize(gRespX(W - PAD * 2), gRespY(28))
	if self._entry.gSetRadius then self._entry:gSetRadius(0) end
	self._entry:gSetFont("OxaniumRegular", 12)
	self._entry:gSetPlaceholder(placeholder or "")
	self._entry.OnEnter = function()
		pnl:_confirm()
	end

	local btnY = H - PAD * 0.5 - BTN_H
	local btnW = (W - PAD * 3) * 0.5

	self._btnCancel = vgui.Create("gButton", self)
	self._btnCancel:SetPos(gRespX(PAD), gRespY(btnY))
	self._btnCancel:SetSize(gRespX(btnW), gRespY(BTN_H))
	if self._btnCancel.gSetRadius then self._btnCancel:gSetRadius(0) end
	self._btnCancel:gSetBgColor(gTheme("elevated"), gThemeAlpha("mid"))
	self._btnCancel:gSetText("Annuler", "OxaniumRegular", 12)
	self._btnCancel:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))
	self._btnCancel.DoClick = function()
		pnl:_cancel()
	end

	self._btnOk = vgui.Create("gButton", self)
	self._btnOk:SetPos(gRespX(PAD + btnW + PAD), gRespY(btnY))
	self._btnOk:SetSize(gRespX(btnW), gRespY(BTN_H))
	if self._btnOk.gSetRadius then self._btnOk:gSetRadius(0) end
	self._btnOk:gSetBgColor(gTheme("accent"), gThemeAlpha("mid"))
	self._btnOk:gSetText("Confirmer", "OxaniumMedium", 12, gContrastText(gTheme("accent")))
	self._btnOk.DoClick = function()
		pnl:_confirm()
	end

	self:gOpen(0.12)

	timer.Simple(0, function()
		if IsValid(self._entry) then
			self._entry:RequestFocus()
		end
	end)
end

function PANEL:_confirm()
	local val = IsValid(self._entry) and self._entry:GetValue():Trim() or ""
	if self._onConfirm then self._onConfirm(val) end
	self:gClose(0.1)
end

function PANEL:_cancel()
	if self._onCancel then self._onCancel() end
	self:gClose(0.1)
end

vgui.Register("gStringRequest", PANEL, "gFrame")

function gStringRequest(title, message, placeholder, onConfirm, onCancel)
	local p = vgui.Create("gStringRequest")
	if p.gSetRadius then p:gSetRadius(0) end
	p:gBuild(title, message, placeholder, onConfirm, onCancel)
	return p
end