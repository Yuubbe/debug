local _panel      = nil
local _warnsData  = {}
local _warnsScroll = nil
local _totalWarns   = 0
local _page         = 0
local _pageLabel    = nil
local _lastReq      = 0

local PER_PAGE = 50

local function gWarnsFormatTime(ts)
	ts = tonumber(ts) or 0
	if ts == 0 then return "—" end
	return os.date("%d/%m/%Y %H:%M", ts)
end

local function gWarnsRequest(page)
	if RealTime() - _lastReq < 0.5 then return end
	_lastReq = RealTime()
	_page = page or 0

	net.Start("gAdmin.RequestAllWarns")
	net.WriteUInt(_page, 16)
	net.SendToServer()
end

local function gWarnsStyleScrollBar(sbar)
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
		draw.RoundedBox(2, 0, 0, w, h, ColorAlpha(gTheme("warning"), 60))
	end
end

local function gWarnsBuildEntries()
	if not IsValid(_warnsScroll) then return end
	_warnsScroll:GetCanvas():Clear()

	if #_warnsData == 0 then
		local empty = vgui.Create("gLabel", _warnsScroll)
		empty:Dock(TOP)
		empty:SetTall(gRespY(32))
		empty:gSetText("Aucun avertissement enregistré.", "OxaniumLight", 12, gTheme("textDim"))
		empty:gSetAlign(TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		return
	end

	for i, entry in ipairs(_warnsData) do
		local row = vgui.Create("DPanel", _warnsScroll)
		row:Dock(TOP)
		row:SetTall(gRespY(48))
		row:DockMargin(0, 0, 0, gRespY(2))

		local bgEven = i % 2 == 0
		row.Paint = function(self, w, h)
			w = w or self:GetWide()
			h = h or self:GetTall()
			if not w or not h or w < 1 or h < 1 then return end
			draw.RoundedBox(gThemeRadius("sm"), 0, 0, w, h,
				ColorAlpha(gTheme("elevated"), bgEven and 60 or 30))
		end

		local idLbl = vgui.Create("gLabel", row)
		idLbl:Dock(LEFT)
		idLbl:SetWide(gRespX(44))
		idLbl:DockMargin(gRespX(6), 0, 0, 0)
		idLbl:gSetText("#" .. tostring(entry.id or 0), "OxaniumSemiBold", 10, gTheme("textMute"))
		idLbl:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		local sidLbl = vgui.Create("gLabel", row)
		sidLbl:Dock(LEFT)
		sidLbl:SetWide(gRespX(120))
		sidLbl:DockMargin(gRespX(4), 0, 0, 0)
		sidLbl:gSetText(entry.steamid64 or "—", "OxaniumLight", 10, gTheme("accent"))
		sidLbl:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		local timeLbl = vgui.Create("gLabel", row)
		timeLbl:Dock(RIGHT)
		timeLbl:SetWide(gRespX(118))
		timeLbl:DockMargin(0, 0, gRespX(6), 0)
		timeLbl:gSetText(gWarnsFormatTime(entry.given_at), "OxaniumLight", 10, gTheme("textDim"))
		timeLbl:gSetAlign(TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

		local byLbl = vgui.Create("gLabel", row)
		byLbl:Dock(RIGHT)
		byLbl:SetWide(gRespX(90))
		byLbl:DockMargin(0, 0, gRespX(4), 0)
		byLbl:gSetText(entry.given_by or "—", "OxaniumLight", 10, gTheme("textDim"))
		byLbl:gSetAlign(TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

		local reasonLbl = vgui.Create("gLabel", row)
		reasonLbl:Dock(FILL)
		reasonLbl:DockMargin(gRespX(4), 0, gRespX(4), 0)
		reasonLbl:gSetText(entry.reason or "", "OxaniumLight", 11, gTheme("text"))
		reasonLbl:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
end

local function gWarnsUpdatePageLabel()
	if not IsValid(_pageLabel) then return end
	local maxPage = math.max(math.ceil(_totalWarns / PER_PAGE) - 1, 0)
	_pageLabel:gSetText(
		string.format("Page %d / %d  (%d warns)", _page + 1, maxPage + 1, _totalWarns),
		"OxaniumMedium", 11, gTheme("textDim")
	)
end

function gWarnsOpenAllPanel()
	if IsValid(_panel) then _panel:Remove() return end

	local W, H     = 720, 520
	local HEADER_H = 36
	local PAD      = 10
	local hc       = gTheme("surface")

	_panel = vgui.Create("gFrame")
	_panel:gSetSize(W, H)
	_panel:gCenter()
	_panel:gSetRadius(gThemeRadius("lg"))
	_panel:gSetBgColor(gTheme("bg"), gThemeAlpha("full"))
	_panel:gSetHeader(true, hc, gThemeAlpha("high"), HEADER_H)
	_panel:gSetTitle("Tous les avertissements", "OxaniumSemiBold", 14, gContrastText(hc), TEXT_ALIGN_CENTER)
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

	local refreshBtn = vgui.Create("gButton", toolbar)
	refreshBtn:Dock(LEFT)
	refreshBtn:SetWide(gRespX(100))
	refreshBtn:gSetBgColor(gTheme("success"), 30)
	refreshBtn:gSetText("Actualiser", "OxaniumMedium", 11, gTheme("text"))
	refreshBtn:gSetRadius(gThemeRadius("sm"))
	refreshBtn:gSetBorder(true, gTheme("success"), 40)
	refreshBtn.DoClick = function()
		gWarnsRequest(_page)
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
		local maxPage = math.max(math.ceil(_totalWarns / PER_PAGE) - 1, 0)
		if _page < maxPage then
			gWarnsRequest(_page + 1)
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
			gWarnsRequest(_page - 1)
		end
	end

	_pageLabel = vgui.Create("gLabel", toolbar)
	_pageLabel:Dock(FILL)
	_pageLabel:DockMargin(gRespX(8), 0, gRespX(8), 0)
	_pageLabel:gSetText("Chargement...", "OxaniumMedium", 11, gTheme("textDim"))
	_pageLabel:gSetAlign(TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local hint = vgui.Create("gLabel", body)
	hint:Dock(TOP)
	hint:SetTall(gRespY(18))
	hint:gSetText("Lecture seule — liste globale (BDD).", "OxaniumLight", 10, gTheme("textMute"))
	hint:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	local sep = vgui.Create("DPanel", body)
	sep:Dock(TOP)
	sep:SetTall(1)
	sep:DockMargin(0, gRespY(4), 0, gRespY(6))
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

	local hId = vgui.Create("gLabel", headerRow)
	hId:Dock(LEFT)
	hId:SetWide(gRespX(44))
	hId:DockMargin(gRespX(6), 0, 0, 0)
	hId:gSetText("ID", "OxaniumSemiBold", 10, gTheme("textMute"))
	hId:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	local hSid = vgui.Create("gLabel", headerRow)
	hSid:Dock(LEFT)
	hSid:SetWide(gRespX(120))
	hSid:DockMargin(gRespX(4), 0, 0, 0)
	hSid:gSetText("STEAMID64", "OxaniumSemiBold", 10, gTheme("textMute"))
	hSid:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	local hTime = vgui.Create("gLabel", headerRow)
	hTime:Dock(RIGHT)
	hTime:SetWide(gRespX(118))
	hTime:DockMargin(0, 0, gRespX(6), 0)
	hTime:gSetText("DATE", "OxaniumSemiBold", 10, gTheme("textMute"))
	hTime:gSetAlign(TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

	local hBy = vgui.Create("gLabel", headerRow)
	hBy:Dock(RIGHT)
	hBy:SetWide(gRespX(90))
	hBy:DockMargin(0, 0, gRespX(4), 0)
	hBy:gSetText("PAR", "OxaniumSemiBold", 10, gTheme("textMute"))
	hBy:gSetAlign(TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

	local hReason = vgui.Create("gLabel", headerRow)
	hReason:Dock(FILL)
	hReason:DockMargin(gRespX(4), 0, gRespX(4), 0)
	hReason:gSetText("RAISON", "OxaniumSemiBold", 10, gTheme("textMute"))
	hReason:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	_warnsScroll = vgui.Create("DScrollPanel", body)
	_warnsScroll:Dock(FILL)
	_warnsScroll:DockMargin(0, gRespY(4), 0, 0)
	gWarnsStyleScrollBar(_warnsScroll:GetVBar())

	_panel:gOpen(0.15)

	gWarnsRequest(0)
end

net.Receive("gAdmin.AllWarns", function()
	if net.ReadBool() then
		chat.AddText(gTheme("danger"), "[Admin] ", gTheme("text"), "Permission refusée (warnings).")
		if IsValid(_panel) then _panel:Remove() end
		return
	end

	_totalWarns = net.ReadUInt(32)
	_page       = net.ReadUInt(16)
	local count = net.ReadUInt(8)

	_warnsData = {}
	for i = 1, count do
		_warnsData[i] = {
			id         = net.ReadUInt(32),
			steamid64  = net.ReadString(),
			reason     = net.ReadString(),
			given_by   = net.ReadString(),
			given_at   = net.ReadUInt(32),
		}
	end

	gWarnsBuildEntries()
	gWarnsUpdatePageLabel()
end)

concommand.Add("gWarns_open_all", function()
	gWarnsOpenAllPanel()
end)

TKRBASE = TKRBASE or {}
TKRBASE.Warns = TKRBASE.Warns or {}
--- API exportable : TKRBASE.Warns.OpenAll() ou concommand gWarns_open_all (permission `warnings`)
TKRBASE.Warns.OpenAll = gWarnsOpenAllPanel

print("modules/warns/cl_warns_ui.lua | LOAD !")
