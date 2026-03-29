local _warnsPanel = nil

local function gAdminCreate(class, parent)
	local p = vgui.Create(class, parent)
	if p.gSetRadius then p:gSetRadius(0) end
	return p
end

local function gAdminSendCmd(cmd, sid, extra)
	net.Start("gAdmin.Cmd")
		net.WriteString(cmd)
		net.WriteString(sid   or "")
		net.WriteString(extra or "")
	net.SendToServer()
end

local PANEL = {}

PANEL._type = "warns"

function PANEL:Init()
	local base = vgui.GetControlTable("gFrame")
	if base and base.Init then base.Init(self) end
	if self.gSetRadius then self:gSetRadius(0) end

	self._page      = 0
	self._total     = 0
	self._perPage   = 50
	self._rows      = {}
	self._listView  = nil
	self._lblInfo   = nil
	self._btnPrev   = nil
	self._btnNext   = nil
	self._btnRefresh = nil

	_warnsPanel = self
end

function PANEL:OnRemove()
	if _warnsPanel == self then _warnsPanel = nil end
end

function PANEL:gRequestPage(page)
	self._page = math.max(0, page)
	net.Start("gAdmin.RequestAllWarns")
		net.WriteUInt(self._page, 16)
	net.SendToServer()
end

function PANEL:gBuildList()
	if not IsValid(self._listView) then return end

	self._listView:gClear()

	for _, w in ipairs(self._rows) do
		self._listView:gAddRow({
			tostring(w.id),
			tostring(w.steamid64),
			w.reason,
			w.given_by,
			os.date("%d/%m/%y %H:%M", w.given_at),
		})
	end

	local totalPages = math.max(1, math.ceil(self._total / self._perPage))
	local cur        = self._page + 1

	if IsValid(self._lblInfo) then
		self._lblInfo:gSetText(
			#self._rows .. " résultats  —  page " .. cur .. " / " .. totalPages ..
			"  —  " .. self._total .. " au total"
		)
	end

	if IsValid(self._btnPrev) then
		self._btnPrev:gSetDisabled(self._page <= 0)
	end

	if IsValid(self._btnNext) then
		self._btnNext:gSetDisabled(cur >= totalPages)
	end
end

function PANEL:gBuild(leftPanel)
	local W        = 700
	local H        = 560
	local HEADER_H = 40
	local PAD      = 8
	local CTRL_H   = 30
	local hc       = gTheme("elevated")
	local pnl      = self

	local leftX = 0
	local leftW = IsValid(leftPanel) and leftPanel:GetWide() or gRespX(320)
	if IsValid(leftPanel) then leftX = select(1, leftPanel:GetPos()) end

	self:gSetSize(W, H)
	self:SetPos(leftX + leftW + gRespX(4), (ScrH() - gRespY(H)) * 0.5)
	self:gSetBgColor(gTheme("bg"), gThemeAlpha("full"))
	self:gSetHeader(true, hc, gThemeAlpha("high"), HEADER_H)
	self:gSetTitle("Warns globaux", "OxaniumMedium", 14, gContrastText(hc), TEXT_ALIGN_LEFT)
	self:gSetCloseButton(true, "OxaniumLight", 18, gContrastText(hc, 160))
	self:gSetDraggable(true)
	self:gSetBorder(true, gThemeAlpha("border"))

	-- Barre de contrôle
	local ctrlWrap = vgui.Create("DPanel", self)
	ctrlWrap:SetPos(gRespX(PAD), gRespY(HEADER_H + PAD))
	ctrlWrap:SetSize(gRespX(W - PAD * 2), gRespY(CTRL_H))
	ctrlWrap:SetPaintBackground(false)

	self._btnPrev = gAdminCreate("gButton", ctrlWrap)
	self._btnPrev:SetPos(0, 0)
	self._btnPrev:SetSize(gRespX(70), gRespY(CTRL_H))
	self._btnPrev:gSetBgColor(gTheme("elevated"), gThemeAlpha("mid"))
	self._btnPrev:gSetText("← Préc.", "OxaniumRegular", 11)
	self._btnPrev:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))
	self._btnPrev.DoClick = function()
		pnl:gRequestPage(pnl._page - 1)
	end

	self._btnNext = gAdminCreate("gButton", ctrlWrap)
	self._btnNext:SetPos(gRespX(76), 0)
	self._btnNext:SetSize(gRespX(70), gRespY(CTRL_H))
	self._btnNext:gSetBgColor(gTheme("elevated"), gThemeAlpha("mid"))
	self._btnNext:gSetText("Suiv. →", "OxaniumRegular", 11)
	self._btnNext:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))
	self._btnNext.DoClick = function()
		pnl:gRequestPage(pnl._page + 1)
	end

	self._btnRefresh = gAdminCreate("gButton", ctrlWrap)
	self._btnRefresh:SetPos(gRespX(152), 0)
	self._btnRefresh:SetSize(gRespX(70), gRespY(CTRL_H))
	self._btnRefresh:gSetBgColor(gTheme("elevated"), gThemeAlpha("mid"))
	self._btnRefresh:gSetText("Rafraîchir", "OxaniumRegular", 11)
	self._btnRefresh:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))
	self._btnRefresh.DoClick = function()
		pnl:gRequestPage(pnl._page)
	end

	self._lblInfo = gAdminCreate("gLabel", ctrlWrap)
	self._lblInfo:SetPos(gRespX(230), 0)
	self._lblInfo:SetSize(gRespX(W - PAD * 2 - 230), gRespY(CTRL_H))
	self._lblInfo:gSetFont("OxaniumRegular", 11)
	self._lblInfo:gSetColor(gTheme("textDim"))
	self._lblInfo:gSetAlign(TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	self._lblInfo:gSetText("Chargement...")

	-- ListView
	local listY = HEADER_H + PAD + CTRL_H + PAD
	local listH = H - listY - PAD

	self._listView = gAdminCreate("gListView", self)
	self._listView:SetPos(gRespX(PAD), gRespY(listY))
	self._listView:SetSize(gRespX(W - PAD * 2), gRespY(listH))
	self._listView:gSetBgColor(gTheme("surface"), gThemeAlpha("mid"))
	self._listView:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))
	self._listView:gSetHeaderStyle(gTheme("elevated"), gThemeAlpha("high"), "OxaniumSemiBold", 11, gTheme("textDim"))
	self._listView:gSetRowStyle("OxaniumRegular", 11, nil, true)
	self._listView:gSetRowHeight(26)
	self._listView:gSetHeaderHeight(28)
	self._listView:gAddColumn("ID",       40,  TEXT_ALIGN_CENTER)
	self._listView:gAddColumn("SteamID",  130, TEXT_ALIGN_LEFT)
	self._listView:gAddColumn("Raison",   nil, TEXT_ALIGN_LEFT)
	self._listView:gAddColumn("Par",      100, TEXT_ALIGN_LEFT)
	self._listView:gAddColumn("Date",     110, TEXT_ALIGN_CENTER)

	self:gOpen(0.12)

	timer.Simple(0, function()
		if not IsValid(self) then return end
		self:gRequestPage(0)
	end)
end

vgui.Register("gAdminWarnsPanel", PANEL, "gFrame")

net.Receive("gAdmin.AllWarns", function()
	local denied = net.ReadBool()
	if denied then return end

	local total = net.ReadUInt(32)
	local page  = net.ReadUInt(16)
	local count = net.ReadUInt(8)
	local rows  = {}

	for _ = 1, count do
		rows[#rows + 1] = {
			id        = net.ReadUInt(32),
			steamid64 = net.ReadString(),
			reason    = net.ReadString(),
			given_by  = net.ReadString(),
			given_at  = net.ReadUInt(32),
		}
	end

	if IsValid(_warnsPanel) then
		_warnsPanel._total = total
		_warnsPanel._page  = page
		_warnsPanel._rows  = rows
		_warnsPanel:gBuildList()
	end
end)