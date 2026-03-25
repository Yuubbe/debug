local _panel     = nil
local _logsData  = {}
local _logsScroll = nil
local _totalLogs = 0
local _page      = 0
local _scope     = ""
local _pageLabel = nil
local _lastReq   = 0

local PER_PAGE   = 50
local SCOPE_COLORS = {
	Command  = Color(100, 100, 255),
	Rank     = Color(60,  200, 100),
	Warn     = Color(220, 155, 30),
	Ban      = Color(220, 55,  55),
	Storage  = Color(140, 140, 150),
}

local function gLogsGetScopeColor(scope)
	return SCOPE_COLORS[scope] or gTheme("textDim")
end

local function gLogsFormatTime(ts)
	ts = tonumber(ts) or 0
	if ts == 0 then return "—" end
	return os.date("%d/%m/%Y %H:%M", ts)
end

local function gLogsRequest(page, scope)
	if RealTime() - _lastReq < 0.5 then return end
	_lastReq = RealTime()
	_page  = page or 0
	_scope = scope or ""

	net.Start("gAdmin.RequestLogs")
	net.WriteUInt(_page, 16)
	net.WriteString(_scope)
	net.SendToServer()
end

local function gLogsStyleScrollBar(sbar)
	sbar:SetWide(gRespX(4))
	function sbar:Paint()
		local w, h = self:GetSize()
		if w < 1 or h < 1 then return end
		draw.RoundedBox(2, 0, 0, w, h, ColorAlpha(gTheme("elevated"), 80))
	end
	function sbar.btnUp:Paint() end
	function sbar.btnDown:Paint() end
	function sbar.btnGrip:Paint()
		local w, h = self:GetSize()
		if w < 1 or h < 1 then return end
		draw.RoundedBox(2, 0, 0, w, h, ColorAlpha(gTheme("accent"), 60))
	end
end

local function gLogsBuildEntries()
	if not IsValid(_logsScroll) then return end
	_logsScroll:GetCanvas():Clear()

	if #_logsData == 0 then
		local empty = vgui.Create("gLabel", _logsScroll)
		empty:Dock(TOP)
		empty:SetTall(gRespY(32))
		empty:gSetText("Aucun log trouvé.", "OxaniumLight", 12, gTheme("textDim"))
		empty:gSetAlign(TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		return
	end

	for i, entry in ipairs(_logsData) do
		local row = vgui.Create("DPanel", _logsScroll)
		row:Dock(TOP)
		row:SetTall(gRespY(44))
		row:DockMargin(0, 0, 0, gRespY(2))

		local bgEven = i % 2 == 0
		row.Paint = function(_, w, h)
			draw.RoundedBox(gThemeRadius("sm"), 0, 0, w, h,
				ColorAlpha(gTheme("elevated"), bgEven and 60 or 30))
		end

		local scopeCol = gLogsGetScopeColor(entry.scope)

		local scopeLbl = vgui.Create("gLabel", row)
		scopeLbl:Dock(LEFT)
		scopeLbl:SetWide(gRespX(80))
		scopeLbl:DockMargin(gRespX(8), 0, 0, 0)
		scopeLbl:gSetText(entry.scope, "OxaniumSemiBold", 11, scopeCol)
		scopeLbl:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		local timeLbl = vgui.Create("gLabel", row)
		timeLbl:Dock(RIGHT)
		timeLbl:SetWide(gRespX(120))
		timeLbl:DockMargin(0, 0, gRespX(8), 0)
		timeLbl:gSetText(gLogsFormatTime(entry.created_at), "OxaniumLight", 10, gTheme("textDim"))
		timeLbl:gSetAlign(TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

		local msgLbl = vgui.Create("gLabel", row)
		msgLbl:Dock(FILL)
		msgLbl:DockMargin(gRespX(8), 0, gRespX(4), 0)
		msgLbl:gSetText(entry.msg, "OxaniumLight", 11, gTheme("text"))
		msgLbl:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
end

local function gLogsUpdatePageLabel()
	if not IsValid(_pageLabel) then return end
	local maxPage = math.max(math.ceil(_totalLogs / PER_PAGE) - 1, 0)
	_pageLabel:gSetText(
		string.format("Page %d / %d  (%d logs)", _page + 1, maxPage + 1, _totalLogs),
		"OxaniumMedium", 11, gTheme("textDim")
	)
end

function gLogsOpenPanel()
	if IsValid(_panel) then _panel:Remove() return end

	local W, H     = 680, 520
	local HEADER_H = 36
	local PAD      = 10
	local hc       = gTheme("surface")

	_panel = vgui.Create("gFrame")
	_panel:gSetSize(W, H)
	_panel:gCenter()
	_panel:gSetRadius(gThemeRadius("lg"))
	_panel:gSetBgColor(gTheme("bg"), gThemeAlpha("full"))
	_panel:gSetHeader(true, hc, gThemeAlpha("high"), HEADER_H)
	_panel:gSetTitle("Logs Serveur", "OxaniumSemiBold", 14, gContrastText(hc), TEXT_ALIGN_CENTER)
	_panel:gSetCloseButton(true, "OxaniumLight", 16, gContrastText(hc, 140))
	_panel:gSetDraggable(true)
	_panel:gSetBorder(true, gThemeAlpha("border"))
	_panel:MakePopup()

	local body = vgui.Create("DPanel", _panel)
	body:SetPaintBackground(false)
	body:SetPos(0, gRespY(HEADER_H))
	body:SetSize(gRespX(W), gRespY(H - HEADER_H))
	body:DockPadding(gRespX(PAD), gRespY(PAD), gRespX(PAD), gRespY(PAD))

	local toolbar = vgui.Create("DPanel", body)
	toolbar:Dock(TOP)
	toolbar:SetTall(gRespY(32))
	toolbar.Paint = function() end

	local searchEntry = vgui.Create("gTextEntry", toolbar)
	searchEntry:Dock(LEFT)
	searchEntry:SetWide(gRespX(160))
	searchEntry:gSetBgColor(gTheme("elevated"), gThemeAlpha("mid"))
	searchEntry:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))
	searchEntry:gSetRadius(gThemeRadius("sm"))
	searchEntry:gSetFont("OxaniumLight", 12, gTheme("text"))
	searchEntry:gSetPlaceholder("Filtrer par scope...", gTheme("textDim"))
	searchEntry.OnEnter = function(self)
		_scope = self:GetValue() or ""
		_page  = 0
		gLogsRequest(_page, _scope)
	end

	local filterBtn = vgui.Create("gButton", toolbar)
	filterBtn:Dock(LEFT)
	filterBtn:SetWide(gRespX(70))
	filterBtn:DockMargin(gRespX(6), 0, 0, 0)
	filterBtn:gSetBgColor(gTheme("accent"), 30)
	filterBtn:gSetText("Filtrer", "OxaniumMedium", 11, gTheme("text"))
	filterBtn:gSetRadius(gThemeRadius("sm"))
	filterBtn:gSetBorder(true, gTheme("accent"), 40)
	filterBtn.DoClick = function()
		_scope = searchEntry:GetValue() or ""
		_page  = 0
		gLogsRequest(_page, _scope)
	end

	local refreshBtn = vgui.Create("gButton", toolbar)
	refreshBtn:Dock(LEFT)
	refreshBtn:SetWide(gRespX(80))
	refreshBtn:DockMargin(gRespX(6), 0, 0, 0)
	refreshBtn:gSetBgColor(gTheme("success"), 30)
	refreshBtn:gSetText("Actualiser", "OxaniumMedium", 11, gTheme("text"))
	refreshBtn:gSetRadius(gThemeRadius("sm"))
	refreshBtn:gSetBorder(true, gTheme("success"), 40)
	refreshBtn.DoClick = function()
		gLogsRequest(_page, _scope)
	end

	local navRight = vgui.Create("DPanel", toolbar)
	navRight:Dock(RIGHT)
	navRight:SetWide(gRespX(160))
	navRight.Paint = function() end

	local nextBtn = vgui.Create("gButton", navRight)
	nextBtn:Dock(RIGHT)
	nextBtn:SetWide(gRespX(36))
	nextBtn:gSetBgColor(gTheme("elevated"), 60)
	nextBtn:gSetText("▶", "OxaniumMedium", 12, gTheme("text"))
	nextBtn:gSetRadius(gThemeRadius("sm"))
	nextBtn.DoClick = function()
		local maxPage = math.max(math.ceil(_totalLogs / PER_PAGE) - 1, 0)
		if _page < maxPage then
			gLogsRequest(_page + 1, _scope)
		end
	end

	local prevBtn = vgui.Create("gButton", navRight)
	prevBtn:Dock(RIGHT)
	prevBtn:SetWide(gRespX(36))
	prevBtn:DockMargin(0, 0, gRespX(4), 0)
	prevBtn:gSetBgColor(gTheme("elevated"), 60)
	prevBtn:gSetText("◀", "OxaniumMedium", 12, gTheme("text"))
	prevBtn:gSetRadius(gThemeRadius("sm"))
	prevBtn.DoClick = function()
		if _page > 0 then
			gLogsRequest(_page - 1, _scope)
		end
	end

	_pageLabel = vgui.Create("gLabel", toolbar)
	_pageLabel:Dock(FILL)
	_pageLabel:DockMargin(gRespX(8), 0, gRespX(8), 0)
	_pageLabel:gSetText("Chargement...", "OxaniumMedium", 11, gTheme("textDim"))
	_pageLabel:gSetAlign(TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local sep = vgui.Create("DPanel", body)
	sep:Dock(TOP)
	sep:SetTall(1)
	sep:DockMargin(0, gRespY(6), 0, gRespY(6))
	sep.Paint = function(self, w, h)
		w = w or self:GetWide()
		h = h or self:GetTall()
		if not w or not h then return end
		surface.SetDrawColor(ColorAlpha(gTheme("border"), gThemeAlpha("sep")))
		surface.DrawRect(0, 0, w, h)
	end

	local headerRow = vgui.Create("DPanel", body)
	headerRow:Dock(TOP)
	headerRow:SetTall(gRespY(22))
	headerRow.Paint = function() end

	local hScope = vgui.Create("gLabel", headerRow)
	hScope:Dock(LEFT)
	hScope:SetWide(gRespX(88))
	hScope:DockMargin(gRespX(8), 0, 0, 0)
	hScope:gSetText("SCOPE", "OxaniumSemiBold", 10, gTheme("textMute"))
	hScope:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	local hTime = vgui.Create("gLabel", headerRow)
	hTime:Dock(RIGHT)
	hTime:SetWide(gRespX(128))
	hTime:DockMargin(0, 0, gRespX(8), 0)
	hTime:gSetText("DATE", "OxaniumSemiBold", 10, gTheme("textMute"))
	hTime:gSetAlign(TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

	local hMsg = vgui.Create("gLabel", headerRow)
	hMsg:Dock(FILL)
	hMsg:DockMargin(gRespX(8), 0, gRespX(4), 0)
	hMsg:gSetText("MESSAGE", "OxaniumSemiBold", 10, gTheme("textMute"))
	hMsg:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	_logsScroll = vgui.Create("DScrollPanel", body)
	_logsScroll:Dock(FILL)
	_logsScroll:DockMargin(0, gRespY(4), 0, 0)
	gLogsStyleScrollBar(_logsScroll:GetVBar())

	_panel:gOpen(0.15)

	gLogsRequest(0, "")
end

net.Receive("gAdmin.Logs", function()
	if net.ReadBool() then
		chat.AddText(gTheme("danger"), "[Admin] ", gTheme("text"), "Permission refusée (admin).")
		if IsValid(_panel) then _panel:Remove() end
		return
	end

	_totalLogs = net.ReadUInt(32)
	_page      = net.ReadUInt(16)
	local count = net.ReadUInt(8)

	_logsData = {}
	for i = 1, count do
		_logsData[i] = {
			scope      = net.ReadString(),
			msg        = net.ReadString(),
			created_at = net.ReadUInt(32),
		}
	end

	gLogsBuildEntries()
	gLogsUpdatePageLabel()
end)

concommand.Add("gLogs_open", function()
	gLogsOpenPanel()
end)

TKRBASE = TKRBASE or {}
TKRBASE.Logs = TKRBASE.Logs or {}
--- API exportable pour les autres modules client : TKRBASE.Logs.Open() ou concommand gLogs_open
TKRBASE.Logs.Open = gLogsOpenPanel

print("modules/logs/cl_logs_ui.lua | LOAD !")
