local PANEL = {}

TKRBASE.VGUI.Notify = {
	queue   = {},
	active  = {},
	maxVisible = 5,
	offsetX = 16,
	offsetY = 16,
	spaceY  = 8,
	side    = "bottomright",
}

local _W = 320
local _H = 56

local function gNotifyRestack()
	local cfg    = TKRBASE.VGUI.Notify
	local sw, sh = ScrW(), ScrH()
	local nW     = gRespX(_W)
	local nH     = gRespY(_H)
	local spY    = gRespY(cfg.spaceY)
	local offX   = gRespX(cfg.offsetX)
	local offY   = gRespY(cfg.offsetY)
	local count  = #cfg.active

	for i, pnl in ipairs(cfg.active) do
		if not IsValid(pnl) then continue end

		local tx, ty
		local idx = count - i + 1

		if cfg.side == "bottomright" then
			tx = sw - nW - offX
			ty = sh - offY - idx * (nH + spY)
		elseif cfg.side == "bottomleft" then
			tx = offX
			ty = sh - offY - idx * (nH + spY)
		elseif cfg.side == "topright" then
			tx = sw - nW - offX
			ty = offY + (idx - 1) * (nH + spY)
		elseif cfg.side == "topleft" then
			tx = offX
			ty = offY + (idx - 1) * (nH + spY)
		end

		pnl:MoveTo(tx, ty, 0.2, 0, -1)
	end
end

local function gNotifySpawn(data)
	local cfg = TKRBASE.VGUI.Notify

	if #cfg.active >= cfg.maxVisible then
		local oldest = cfg.active[1]
		if IsValid(oldest) then oldest:gDismiss() end
	end

	local sw, sh = ScrW(), ScrH()
	local nW     = gRespX(_W)
	local nH     = gRespY(_H)
	local offX   = gRespX(cfg.offsetX)
	local offY   = gRespY(cfg.offsetY)

	local startX, startY
	if cfg.side == "bottomright" then
		startX = sw - nW - offX
		startY = sh + nH
	elseif cfg.side == "bottomleft" then
		startX = offX
		startY = sh + nH
	elseif cfg.side == "topright" then
		startX = sw - nW - offX
		startY = -nH
	elseif cfg.side == "topleft" then
		startX = offX
		startY = -nH
	end

	local pnl = vgui.Create("gNotify")
	pnl:SetSize(nW, nH)
	pnl:SetPos(startX, startY)
	pnl:SetZPos(32767)
	pnl:_setup(data)

	table.insert(cfg.active, pnl)
	gNotifyRestack()
	pnl:gShow()

	if data.duration and data.duration > 0 then
		timer.Simple(data.duration, function()
			if IsValid(pnl) then pnl:gDismiss() end
		end)
	end
end

function gNotify(text, type, duration)
	local types = {
		default = gTheme("elevated"),
		success = gTheme("success"),
		danger  = gTheme("danger"),
		warning = gTheme("warning"),
		accent  = gTheme("accent"),
	}

	gNotifySpawn({
		text     = text     or "",
		color    = types[type or "default"] or types.default,
		duration = duration or 4,
	})
end

function gNotifyCustom(data)
	gNotifySpawn(data)
end

function gNotifySetSide(side)
	TKRBASE.VGUI.Notify.side = side or "bottomright"
end

function gNotifySetMax(max)
	TKRBASE.VGUI.Notify.maxVisible = max or 5
end

function PANEL:Init()
	self:SetPaintBackground(false)
	self._bgColor     = nil
	self._bgAlpha     = 248
	self._accentColor = nil

	self._border      = false
	self._borderColor = nil
	self._borderAlpha = gThemeAlpha("border")
	self._borderSize  = 1

	self._text        = ""
	self._font        = "OxaniumMedium"
	self._size        = 13
	self._textColor   = nil

	self._icon        = nil
	self._iconSize    = 18
	self._padX        = 12
	self._accentW     = 4
end

function PANEL:_setup(data)
	self._text        = data.text     or ""
	self._accentColor = data.color    or gTheme("accent")
	self._bgColor     = data.bg       or gTheme("surface")
	self._textColor   = data.textColor
	self._icon        = data.icon
	self._font        = data.font     or "OxaniumMedium"
	self._size        = data.size     or 13
end

function PANEL:gShow()
	self:SetAlpha(0)
	self:AlphaTo(255, 0.2, 0)
end

function PANEL:gDismiss()
	local cfg = TKRBASE.VGUI.Notify

	for i, p in ipairs(cfg.active) do
		if p == self then
			table.remove(cfg.active, i)
			break
		end
	end

	self:AlphaTo(0, 0.15, 0, function()
		if IsValid(self) then self:Remove() end
		gNotifyRestack()
	end)
end

function PANEL:OnMousePressed(code)
	if code == MOUSE_LEFT then self:gDismiss() end
end

function PANEL:Paint(w, h)
	local bg  = self._bgColor or gTheme("surface")
	local ac  = self._accentColor or gTheme("accent")
	local aW  = gRespX(self._accentW)
	local padX = gRespX(self._padX)

	surface.SetDrawColor(bg.r, bg.g, bg.b, self._bgAlpha)
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(ac.r, ac.g, ac.b, 255)
	surface.DrawRect(0, 0, aW, h)

	local tc   = self._textColor or gTheme("text")
	local font = self._font .. ":" .. self._size
	local tx   = aW + padX

	if self._icon then
		pMaterials(self._icon, tx, (h - gRespY(self._iconSize)) * 0.5, self._iconSize, self._iconSize, tc)
		tx = tx + gRespX(self._iconSize) + gRespX(6)
	end

	draw.SimpleText(self._text, font, tx, h * 0.5, tc, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	if self._border then
		local bc = self._borderColor or gTheme("border")
		surface.SetDrawColor(bc.r, bc.g, bc.b, self._borderAlpha)
		surface.DrawOutlinedRect(0, 0, w, h, self._borderSize)
	end
end

vgui.Register("gNotify", PANEL, "DPanel")