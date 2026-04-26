local _logsPanel = nil

local function gAdminCreate(class, parent)
	local p = vgui.Create(class, parent)
	if p.gSetRadius then p:gSetRadius(0) end
	return p
end

local SCOPES = { "", "ban", "kick", "warn", "god", "noclip", "slay", "tp", "mute" }

local PANEL = {}

PANEL._type = "logs"

function PANEL:Init()
	local base = vgui.GetControlTable("gFrame")
	if base and base.Init then base.Init(self) end
	if self.gSetRadius then self:gSetRadius(0) end

	self._page       = 0
	self._total      = 0
	self._perPage    = 50
	self._rows       = {}
	self._scope      = ""
	self._listView   = nil
	self._lblInfo    = nil
	self._btnPrev    = nil
	self._btnNext    = nil
	self._scopeCombo = nil

	_logsPanel = self
end

function PANEL:OnRemove()
	if _logsPanel == self then _logsPanel = nil end
end

function PANEL:gRequestPage(page)
	self._page = math.max(0, page)
	net.Start("gAdmin.RequestLogs")
		net.WriteUInt(self._page, 16)
		net.WriteString(self._scope)
	net.SendToServer()
end

function PANEL:gOnReceive(total, page, rows)
	self._total = total
	self._page  = page
	self._rows  = rows
	self:gBuildList()
end

function PANEL:gBuildList()
	if not IsValid(self._listView) then return end

	local existing = #self._listView._rows
	local incoming = #self._rows

	if existing == incoming and existing > 0 then
		for i, l in ipairs(self._rows) do
			self._listView._rows[i].data = {
				tostring(l.id or ""),
				l.scope ~= "" and l.scope or "global",
				l.msg,
				os.date("%d/%m/%y %H:%M", l.created_at),
			}
		end
	else
		self._listView:gClear()
		for _, l in ipairs(self._rows) do
			self._listView:gAddRow({
				tostring(l.id or ""),
				l.scope ~= "" and l.scope or "global",
				l.msg,
				os.date("%d/%m/%y %H:%M", l.created_at),
			})
		end
	end

	local totalPages = math.max(1, math.ceil(self._total / self._perPage))
	local cur        = self._page + 1

	if IsValid(self._lblInfo) then
		self._lblInfo:gSetText(
			#self._rows .. " entrées  —  page " .. cur .. " / " .. totalPages ..
			"  —  " .. self._total .. " au total"
		)
	end

	if IsValid(self._btnPrev) then self._btnPrev:gSetDisabled(self._page <= 0) end
	if IsValid(self._btnNext) then self._btnNext:gSetDisabled(cur >= totalPages) end
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
	self:gSetTitle("Logs admin", "OxaniumMedium", 14, gContrastText(hc), TEXT_ALIGN_LEFT)
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

	local refreshBtn = gAdminCreate("gButton", ctrlWrap)
	refreshBtn:SetPos(gRespX(152), 0)
	refreshBtn:SetSize(gRespX(70), gRespY(CTRL_H))
	refreshBtn:gSetBgColor(gTheme("elevated"), gThemeAlpha("mid"))
	refreshBtn:gSetText("Rafraîchir", "OxaniumRegular", 11)
	refreshBtn:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))
	refreshBtn.DoClick = function()
		pnl:gRequestPage(pnl._page)
	end

	-- Filtre scope
	local scopeCombo = vgui.Create("DComboBox", ctrlWrap)
	scopeCombo:SetPos(gRespX(230), 0)
	scopeCombo:SetSize(gRespX(130), gRespY(CTRL_H))
	scopeCombo:SetFont("OxaniumRegular:" .. gRespFont(11))
	scopeCombo:SetValue("Tous les scopes")

	for _, s in ipairs(SCOPES) do
		scopeCombo:AddChoice(s == "" and "Tous" or s, s)
	end

	scopeCombo.OnSelect = function(_, _, _, value)
		pnl._scope = value
		pnl:gRequestPage(0)
	end

	function scopeCombo:Paint(w, h)
		surface.SetDrawColor(gTheme("elevated").r, gTheme("elevated").g, gTheme("elevated").b, gThemeAlpha("mid"))
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(gTheme("border").r, gTheme("border").g, gTheme("border").b, gThemeAlpha("border"))
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end

	self._lblInfo = gAdminCreate("gLabel", ctrlWrap)
	self._lblInfo:SetPos(gRespX(368), 0)
	self._lblInfo:SetSize(gRespX(W - PAD * 2 - 368), gRespY(CTRL_H))
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
	self._listView:gAddColumn("ID",      40,  TEXT_ALIGN_CENTER)
	self._listView:gAddColumn("Scope",   100, TEXT_ALIGN_CENTER)
	self._listView:gAddColumn("Message", nil,  TEXT_ALIGN_LEFT)
	self._listView:gAddColumn("Date",    110,  TEXT_ALIGN_CENTER)

	self._listView.OnRowRightClick = function(_, idx, data, x, y)
		local logID = tonumber(data[1])
		if not logID then return end

		local m = gMenu(x, y)
		m:gAddItem("Log #" .. logID .. " — " .. tostring(data[3]):sub(1, 30), nil, gTheme("textMute"))
		m:gAddSeparator()
		m:gAddDanger("Supprimer ce log", function()
			gStringRequest(
				"Supprimer le log",
				"Tapez CONFIRMER pour supprimer le log #" .. logID,
				"CONFIRMER",
				function(val)
					if val ~= "CONFIRMER" then return end
					net.Start("gAdmin.DeleteLog")
						net.WriteUInt(logID, 32)
					net.SendToServer()
				end
			)
		end)
	end

	self:gOpen(0.12)

	timer.Simple(0, function()
		if not IsValid(self) then return end
		self:gRequestPage(0)
	end)
end

vgui.Register("gAdminLogsPanel", PANEL, "gFrame")

net.Receive("gAdmin.Logs", function()
	local denied = net.ReadBool()
	if denied then return end

	local total = net.ReadUInt(32)
	local page  = net.ReadUInt(16)
	local count = net.ReadUInt(8)
	local rows  = {}

	for _ = 1, count do
		rows[#rows + 1] = {
			id         = net.ReadUInt(32),
			scope      = net.ReadString(),
			msg        = net.ReadString(),
			created_at = net.ReadUInt(32),
		}
	end

	if IsValid(_logsPanel) then
		_logsPanel:gOnReceive(total, page, rows)
	end
end)

net.Receive("gAdmin.DeleteDone", function()
	local dtype = net.ReadString()
	local ok    = net.ReadBool()
	local id    = net.ReadUInt(32)

	if dtype ~= "log" then return end
	if not IsValid(_logsPanel) then return end

	if ok then
		gNotify("Log #" .. id .. " supprimé.", "success", 3)
		_logsPanel:gRequestPage(_logsPanel._page)
	else
		gNotify("Erreur lors de la suppression.", "danger", 3)
	end
end)