local _panel   = nil
local _perms   = {}
local _selSID  = nil
local _entries = {}

local _rightBody   = nil
local _infoName    = nil
local _infoRank    = nil
local _infoHP      = nil
local _infoArmor   = nil
local _infoAlive   = nil
local _actionsWrap = nil
local _statusBar   = nil
local _warnsScroll = nil
local _warnsHeader = nil
local _warnsData   = {}
local _warnsClear  = nil

local RANK_COLORS = {
	owner     = Color(100, 100, 255),
	headadmin = Color(130, 90,  255),
	admin     = Color(60,  200, 100),
	moderator = Color(220, 155, 30),
	helper    = Color(140, 140, 150),
	user      = Color(70,  70,  80),
}

local CMD_GROUPS = {
	{
		key   = "move",
		title = "Déplacement",
		cmds  = {
			{ name = "goto",  label = "Goto" },
			{ name = "bring", label = "Bring" },
			{ name = "tp",    label = "Téléporter" },
		},
	},
	{
		key   = "status",
		title = "Statut",
		cmds  = {
			{ name = "god",    label = "God" },
			{ name = "noclip", label = "Noclip" },
			{ name = "freeze", label = "Freeze" },
			{ name = "cloak",  label = "Cloak" },
			{ name = "mute",   label = "Mute" },
			{ name = "unmute", label = "Unmute" },
		},
	},
	{
		key   = "combat",
		title = "Combat",
		cmds  = {
			{ name = "slay",    label = "Slay" },
			{ name = "respawn", label = "Respawn" },
			{ name = "strip",   label = "Strip" },
		},
	},
}

local INPUT_CMDS = {
	{ name = "sethp",    label = "Vie",    placeholder = "ex: 500",       btn = "OK",   color = nil },
	{ name = "setarmor", label = "Armure", placeholder = "ex: 255",       btn = "OK",   color = nil },
	{ name = "kick",     label = "Kick",   placeholder = "Raison...",     btn = "Kick", color = "warning" },
	{ name = "warn",     label = "Warn",   placeholder = "Raison...",     btn = "Warn", color = "warning" },
	{ name = "ban",      label = "Ban",    placeholder = "raison 1h/1j",  btn = "Ban",  color = "danger" },
}

-- ── Helpers ──────────────────────────────────────────────

local function gAdminGetRankName(ply)
	if not IsValid(ply) then return "?" end
	return ply:GetUserGroup() or "user"
end

local function gAdminGetRankColor(ply)
	return RANK_COLORS[gAdminGetRankName(ply)] or RANK_COLORS.user
end

local function gAdminSendCmd(cmdName, targetSID, extra)
	net.Start("gAdmin.Cmd")
	net.WriteString(cmdName)
	net.WriteString(targetSID or "")
	net.WriteString(extra or "")
	net.SendToServer()
end

local function gAdminHasPerm(cmd)
	return _perms[cmd] == true
end

local function gAdminStatusMsg(text)
	if not IsValid(_statusBar) then return end
	_statusBar:gSetText(text)
end

local function gAdminGetSelectedPly()
	if not _selSID then return nil end
	for _, ply in ipairs(player.GetAll()) do
		if ply:SteamID64() == _selSID then return ply end
	end
	return nil
end

local function gAdminRequestWarns(sid64)
	if not sid64 or not gAdminHasPerm("warnings") then return end
	net.Start("gAdmin.RequestWarns")
	net.WriteString(sid64)
	net.SendToServer()
end

-- ── Player info update ───────────────────────────────────

local function gAdminUpdateInfo()
	local ply = gAdminGetSelectedPly()

	if not ply or not IsValid(ply) then
		if IsValid(_infoName)  then _infoName:gSetText("Aucun joueur sélectionné") end
		if IsValid(_infoRank)  then _infoRank:gSetText("")  end
		if IsValid(_infoHP)    then _infoHP:gSetText("")    end
		if IsValid(_infoArmor) then _infoArmor:gSetText("") end
		if IsValid(_infoAlive) then _infoAlive:gSetText("") end
		return
	end

	local suffix = ply == LocalPlayer() and " (moi)" or ""

	if IsValid(_infoName) then
		_infoName:gSetText(ply:Nick() .. suffix)
	end

	if IsValid(_infoRank) then
		local rk = gAdminGetRankName(ply)
		_infoRank:gSetText(rk)
		_infoRank:gSetColor(gAdminGetRankColor(ply))
	end

	if IsValid(_infoHP) then
		_infoHP:gSetText("Vie : " .. ply:Health() .. " / " .. ply:GetMaxHealth())
	end

	if IsValid(_infoArmor) then
		_infoArmor:gSetText("Armure : " .. ply:Armor())
	end

	if IsValid(_infoAlive) then
		_infoAlive:gSetText(ply:Alive() and "Vivant" or "Mort")
		_infoAlive:gSetColor(ply:Alive() and gTheme("success") or gTheme("danger"))
	end
end

-- ── Scroll bar styling ───────────────────────────────────

local function gAdminStyleScrollBar(sbar)
	sbar:SetWide(gRespX(4))
	sbar:SetHideButtons(true)

	function sbar:Paint(w, h) end
	function sbar.btnUp:Paint(w, h) end
	function sbar.btnDown:Paint(w, h) end
	function sbar.btnGrip:Paint(w, h)
		draw.RoundedBox(gRespX(2), 0, 0, w, h, gThemeColor("border", 40))
	end
end

-- ── Warns panel builder ─────────────────────────────────

local function gAdminBuildWarns()
	if not IsValid(_warnsScroll) then return end
	_warnsScroll:Clear()

	if IsValid(_warnsHeader) then
		_warnsHeader:gSetText("Avertissements (" .. #_warnsData .. ")")
	end

	if IsValid(_warnsClear) then
		_warnsClear:SetVisible(#_warnsData > 0 and gAdminHasPerm("clearwarnings"))
	end

	if #_warnsData == 0 then
		local empty = vgui.Create("gLabel", _warnsScroll)
		empty:Dock(TOP)
		empty:SetTall(gRespY(28))
		empty:DockMargin(gRespX(8), gRespY(4), 0, 0)
		empty:gSetFont("OxaniumRegular", 11)
		empty:gSetColor(gTheme("textMute"))
		empty:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		empty:gSetText("Aucun avertissement.")
		return
	end

	for i, w in ipairs(_warnsData) do
		local row = vgui.Create("gPanel", _warnsScroll)
		row:Dock(TOP)
		row:DockMargin(0, 0, 0, gRespY(2))
		row:SetTall(gRespY(42))
		row:gSetBgColor(gTheme("elevated"), gThemeAlpha("mid"))
		row:gSetRadius(gThemeRadius("sm"))
		row:DockPadding(gRespX(10), gRespY(4), gRespX(10), gRespY(4))

		local reasonLbl = vgui.Create("gLabel", row)
		reasonLbl:Dock(TOP)
		reasonLbl:SetTall(gRespY(16))
		reasonLbl:gSetFont("OxaniumRegular", 12)
		reasonLbl:gSetColor(gTheme("text"))
		reasonLbl:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		reasonLbl:gSetText("#" .. i .. "  " .. w.reason)

		local metaLbl = vgui.Create("gLabel", row)
		metaLbl:Dock(TOP)
		metaLbl:SetTall(gRespY(14))
		metaLbl:DockMargin(0, gRespY(1), 0, 0)
		metaLbl:gSetFont("OxaniumLight", 10)
		metaLbl:gSetColor(gTheme("textDim"))
		metaLbl:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		metaLbl:gSetText("par " .. w.given_by .. "  •  " .. os.date("%d/%m/%Y %H:%M", w.given_at))
	end
end

-- ── Player list ──────────────────────────────────────────

local function gAdminSelectPlayer(sid64)
	_selSID = sid64

	for sid, entry in pairs(_entries) do
		if IsValid(entry) then
			if sid == sid64 then
				entry:gSetBgColor(gTheme("accent"), 40)
			else
				entry:gSetBgColor(gTheme("elevated"), gThemeAlpha("mid"))
			end
		end
	end

	gAdminUpdateInfo()

	_warnsData = {}
	gAdminBuildWarns()
	gAdminRequestWarns(sid64)
end

local function gAdminBuildPlayerList(scroll, searchQ)
	if not IsValid(scroll) then return end

	scroll:Clear()
	_entries = {}

	local q     = string.lower(searchQ or "")
	local plist = player.GetAll()
	local lp    = LocalPlayer()

	table.sort(plist, function(a, b)
		if a == lp then return true end
		if b == lp then return false end
		local pa = RANK_COLORS[gAdminGetRankName(a)] and 1 or 2
		local pb = RANK_COLORS[gAdminGetRankName(b)] and 1 or 2
		if pa ~= pb then return pa < pb end
		return a:Nick() < b:Nick()
	end)

	for _, ply in ipairs(plist) do
		if q ~= "" and not string.find(string.lower(ply:Nick()), q, 1, true) then continue end

		local sid64  = ply:SteamID64()
		local rc     = gAdminGetRankColor(ply)
		local isSelf = (ply == lp)

		local entry = vgui.Create("DPanel", scroll)
		entry:SetPaintBackground(false)
		entry:Dock(TOP)
		entry:DockMargin(0, 0, 0, gRespY(2))
		entry:SetTall(gRespY(34))
		entry:SetCursor("hand")

		entry._radius  = gThemeRadius("sm")
		entry._bgColor = sid64 == _selSID and gTheme("accent") or gTheme("elevated")
		entry._bgAlpha = sid64 == _selSID and 40 or gThemeAlpha("mid")
		entry._hover   = 0

		function entry:gSetBgColor(c, a)
			self._bgColor = c
			self._bgAlpha = a
		end

		function entry:Think()
			local mx, my = self:CursorPos()
			local w, h   = self:GetSize()
			local hov    = mx >= 0 and mx <= w and my >= 0 and my <= h
			local speed  = FrameTime() * 10
			local target = hov and gThemeAlpha("hover") or 0
			self._hover  = math.Clamp(self._hover + (target - self._hover) * speed, 0, gThemeAlpha("hover"))
		end

		function entry:Paint(w, h)
			draw.RoundedBox(self._radius, 0, 0, w, h, Color(self._bgColor.r, self._bgColor.g, self._bgColor.b, self._bgAlpha))
			if self._hover > 0 then
				local bc = gTheme("border")
				draw.RoundedBox(self._radius, 0, 0, w, h, Color(bc.r, bc.g, bc.b, self._hover))
			end
		end

		function entry:OnMousePressed(code)
			if code == MOUSE_LEFT then gAdminSelectPlayer(sid64) end
		end

		local dot = vgui.Create("DPanel", entry)
		dot:SetSize(gRespX(8), gRespY(8))
		dot:SetPos(gRespX(10), (gRespY(34) - gRespY(8)) * 0.5)
		dot:SetPaintBackground(false)
		function dot:Paint(w, h)
			draw.RoundedBox(w * 0.5, 0, 0, w, h, rc)
		end

		local nick = isSelf and (ply:Nick() .. " (moi)") or ply:Nick()
		local nickColor = isSelf and gTheme("accent") or gTheme("text")

		local lbl = vgui.Create("gLabel", entry)
		lbl:SetPos(gRespX(24), 0)
		lbl:SetSize(gRespX(180), gRespY(34))
		lbl:gSetFont("OxaniumRegular", 12)
		lbl:gSetColor(nickColor)
		lbl:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		lbl:gSetText(nick)
		lbl:SetMouseInputEnabled(false)

		_entries[sid64] = entry
	end
end

-- ── Action buttons builder ───────────────────────────────

local function gAdminBuildActions(parent)
	if not IsValid(parent) then return end
	parent:Clear()

	local padX = 8
	local padY = 6
	local btnW = 100
	local btnH = 30

	for _, grp in ipairs(CMD_GROUPS) do
		local hasCmds = false
		for _, cmd in ipairs(grp.cmds) do
			if gAdminHasPerm(cmd.name) then hasCmds = true break end
		end
		if not hasCmds then continue end

		local header = vgui.Create("gLabel", parent)
		header:Dock(TOP)
		header:DockMargin(0, gRespY(padY), 0, gRespY(3))
		header:SetTall(gRespY(18))
		header:gSetFont("OxaniumSemiBold", 11)
		header:gSetColor(gTheme("textDim"))
		header:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		header:gSetText(grp.title)
		header:gSetUppercase(true)

		local row = vgui.Create("DPanel", parent)
		row:SetPaintBackground(false)
		row:Dock(TOP)
		row:DockMargin(0, 0, 0, gRespY(2))
		row:SetTall(gRespY(btnH + 2))

		local ox = 0
		for _, cmd in ipairs(grp.cmds) do
			if not gAdminHasPerm(cmd.name) then continue end

			local btn = vgui.Create("gButton", row)
			btn:SetPos(gRespX(ox), 0)
			btn:gSetSize(btnW, btnH)
			btn:gSetBgColor(gTheme("elevated"), gThemeAlpha("mid"))
			btn:gSetText(cmd.label, "OxaniumMedium", 12)
			btn:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))

			local cname = cmd.name
			btn.DoClick = function()
				local ply = gAdminGetSelectedPly()
				if not ply then
					gAdminStatusMsg("Sélectionne un joueur d'abord.")
					return
				end
				gAdminSendCmd(cname, ply:SteamID64())
				gAdminStatusMsg("!" .. cname .. " → " .. ply:Nick())
			end

			ox = ox + btnW + padX
		end
	end

	local hasInputCmds = false
	for _, ic in ipairs(INPUT_CMDS) do
		if gAdminHasPerm(ic.name) then hasInputCmds = true break end
	end

	if not hasInputCmds then return end

	local sepHeader = vgui.Create("gLabel", parent)
	sepHeader:Dock(TOP)
	sepHeader:DockMargin(0, gRespY(10), 0, gRespY(3))
	sepHeader:SetTall(gRespY(18))
	sepHeader:gSetFont("OxaniumSemiBold", 11)
	sepHeader:gSetColor(gTheme("textDim"))
	sepHeader:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	sepHeader:gSetText("Commandes")
	sepHeader:gSetUppercase(true)

	local labelW  = 65
	local inputW  = 220
	local inputBW = 90
	local inputH  = 30

	for _, ic in ipairs(INPUT_CMDS) do
		if not gAdminHasPerm(ic.name) then continue end

		local irow = vgui.Create("DPanel", parent)
		irow:SetPaintBackground(false)
		irow:Dock(TOP)
		irow:DockMargin(0, gRespY(3), 0, 0)
		irow:SetTall(gRespY(inputH + 2))

		local lbl = vgui.Create("gLabel", irow)
		lbl:SetPos(0, 0)
		lbl:SetSize(gRespX(labelW), gRespY(inputH))
		lbl:gSetFont("OxaniumMedium", 11)
		lbl:gSetColor(gTheme("textDim"))
		lbl:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		lbl:gSetText(ic.label)

		local te = vgui.Create("gTextEntry", irow)
		te:SetPos(gRespX(labelW + 2), 0)
		te:SetSize(gRespX(inputW), gRespY(inputH))
		te:gSetFont("OxaniumRegular", 12)
		te:gSetPlaceholder(ic.placeholder)

		local btnColor = ic.color and gTheme(ic.color) or gTheme("elevated")
		local btnText  = ic.color and gContrastText(btnColor) or nil

		local btn = vgui.Create("gButton", irow)
		btn:SetPos(gRespX(labelW + inputW + 8), 0)
		btn:SetSize(gRespX(inputBW), gRespY(inputH))
		btn:gSetBgColor(btnColor, gThemeAlpha("mid"))
		btn:gSetText(ic.btn, "OxaniumMedium", 12, btnText)

		local cname = ic.name
		btn.DoClick = function()
			local ply = gAdminGetSelectedPly()
			if not ply then
				gAdminStatusMsg("Sélectionne un joueur d'abord.")
				return
			end
			local val = te:GetValue():Trim()
			if val == "" then
				gAdminStatusMsg("Valeur requise pour !" .. cname)
				return
			end
			gAdminSendCmd(cname, ply:SteamID64(), val)
			gAdminStatusMsg("!" .. cname .. " " .. val .. " → " .. ply:Nick())
		end

		te.OnEnter = function()
			btn:DoClick()
		end
	end
end

-- ── Main panel builder ───────────────────────────────────

local function gAdminBuildPanel()
	if IsValid(_panel) then _panel:Remove() end

	local W, H       = 920, 620
	local HEADER_H   = 40
	local SIDEBAR_W  = 230
	local STATUS_H   = 30
	local CONTENT_W  = W - SIDEBAR_W
	local CONTENT_H  = H - HEADER_H - STATUS_H
	local PAD        = 10

	local hc = gTheme("surface")

	_panel = vgui.Create("gFrame")
	_panel:gSetSize(W, H)
	_panel:gCenter()
	_panel:gSetRadius(gThemeRadius("lg"))
	_panel:gSetBgColor(gTheme("bg"), gThemeAlpha("full"))
	_panel:gSetHeader(true, hc, gThemeAlpha("high"), HEADER_H)
	_panel:gSetTitle("Panneau Admin", "OxaniumMedium", 15, gContrastText(hc), TEXT_ALIGN_CENTER)
	_panel:gSetCloseButton(true, "OxaniumLight", 20, gContrastText(hc, 160))
	_panel:gSetDraggable(true)
	_panel:gSetBorder(true, gThemeAlpha("border"))
	_panel:gOpen(0.15)

	local _nextUpdate = 0
	local oldThink = _panel.Think
	_panel.Think = function(self)
		if oldThink then oldThink(self) end
		local now = RealTime()
		if now >= _nextUpdate then
			_nextUpdate = now + 0.25
			gAdminUpdateInfo()
		end
	end

	-- ── Sidebar ──────────────────────────────────────────

	local sidebar = vgui.Create("gPanel", _panel)
	sidebar:SetPos(0, gRespY(HEADER_H))
	sidebar:gSetSize(SIDEBAR_W, H - HEADER_H)
	sidebar:gSetBgColor(gTheme("surface"), gThemeAlpha("high"))
	sidebar:gSetRadius(0)
	sidebar:gSetCorners(false, false, true, false)
	sidebar:gDockPadding(PAD, PAD, PAD, PAD)

	local search = vgui.Create("gTextEntry", sidebar)
	search:Dock(TOP)
	search:SetTall(gRespY(32))
	search:gSetFont("OxaniumRegular", 12)
	search:gSetPlaceholder("Rechercher un joueur...")
	search:gSetRadius(gThemeRadius("sm"))

	local refreshBtn = vgui.Create("gButton", sidebar)
	refreshBtn:Dock(BOTTOM)
	refreshBtn:SetTall(gRespY(30))
	refreshBtn:gSetBgColor(gTheme("elevated"), gThemeAlpha("mid"))
	refreshBtn:gSetText("Rafraîchir", "OxaniumMedium", 12)
	refreshBtn:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))

	local scrollWrap = vgui.Create("DPanel", sidebar)
	scrollWrap:SetPaintBackground(false)
	scrollWrap:Dock(FILL)
	scrollWrap:DockMargin(0, gRespY(6), 0, gRespY(6))

	local scroll = vgui.Create("DScrollPanel", scrollWrap)
	scroll:Dock(FILL)
	gAdminStyleScrollBar(scroll:GetVBar())

	gAdminBuildPlayerList(scroll, "")

	search.OnChange = function()
		gAdminBuildPlayerList(scroll, search:GetValue())
	end

	refreshBtn.DoClick = function()
		gAdminBuildPlayerList(scroll, search:GetValue())
		gAdminUpdateInfo()
		if _selSID then gAdminRequestWarns(_selSID) end
		gAdminStatusMsg("Liste rafraîchie.")
	end

	-- ── Right panel (main scroll) ────────────────────────

	local rightScroll = vgui.Create("DScrollPanel", _panel)
	rightScroll:SetPos(gRespX(SIDEBAR_W), gRespY(HEADER_H))
	rightScroll:SetSize(gRespX(CONTENT_W), gRespY(CONTENT_H))
	gAdminStyleScrollBar(rightScroll:GetVBar())

	_rightBody = vgui.Create("DPanel", rightScroll)
	_rightBody:SetPaintBackground(false)
	_rightBody:Dock(TOP)
	_rightBody:DockPadding(gRespX(PAD + 4), gRespY(PAD), gRespX(PAD + 4), gRespY(PAD))

	-- ── Player info ──────────────────────────────────────

	local infoWrap = vgui.Create("gPanel", _rightBody)
	infoWrap:Dock(TOP)
	infoWrap:SetTall(gRespY(82))
	infoWrap:gSetBgColor(gTheme("surface"), gThemeAlpha("high"))
	infoWrap:gSetRadius(gThemeRadius("sm"))
	infoWrap:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))
	infoWrap:DockPadding(gRespX(12), gRespY(8), gRespX(12), gRespY(8))

	_infoName = vgui.Create("gLabel", infoWrap)
	_infoName:Dock(TOP)
	_infoName:SetTall(gRespY(20))
	_infoName:gSetFont("OxaniumSemiBold", 15)
	_infoName:gSetColor(gTheme("text"))
	_infoName:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	_infoName:gSetText("Aucun joueur sélectionné")

	local infoRow = vgui.Create("DPanel", infoWrap)
	infoRow:SetPaintBackground(false)
	infoRow:Dock(TOP)
	infoRow:SetTall(gRespY(16))
	infoRow:DockMargin(0, gRespY(3), 0, 0)

	_infoRank = vgui.Create("gLabel", infoRow)
	_infoRank:SetPos(0, 0)
	_infoRank:SetSize(gRespX(120), gRespY(16))
	_infoRank:gSetFont("OxaniumMedium", 12)
	_infoRank:gSetColor(gTheme("textDim"))
	_infoRank:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	_infoRank:gSetText("")

	_infoAlive = vgui.Create("gLabel", infoRow)
	_infoAlive:SetPos(gRespX(130), 0)
	_infoAlive:SetSize(gRespX(80), gRespY(16))
	_infoAlive:gSetFont("OxaniumRegular", 11)
	_infoAlive:gSetColor(gTheme("textDim"))
	_infoAlive:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	_infoAlive:gSetText("")

	local infoRow2 = vgui.Create("DPanel", infoWrap)
	infoRow2:SetPaintBackground(false)
	infoRow2:Dock(TOP)
	infoRow2:SetTall(gRespY(16))
	infoRow2:DockMargin(0, gRespY(3), 0, 0)

	_infoHP = vgui.Create("gLabel", infoRow2)
	_infoHP:SetPos(0, 0)
	_infoHP:SetSize(gRespX(160), gRespY(16))
	_infoHP:gSetFont("OxaniumRegular", 12)
	_infoHP:gSetColor(gTheme("text"))
	_infoHP:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	_infoHP:gSetText("")

	_infoArmor = vgui.Create("gLabel", infoRow2)
	_infoArmor:SetPos(gRespX(170), 0)
	_infoArmor:SetSize(gRespX(160), gRespY(16))
	_infoArmor:gSetFont("OxaniumRegular", 12)
	_infoArmor:gSetColor(gTheme("text"))
	_infoArmor:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	_infoArmor:gSetText("")

	-- ── Actions ──────────────────────────────────────────

	_actionsWrap = vgui.Create("DPanel", _rightBody)
	_actionsWrap:SetPaintBackground(false)
	_actionsWrap:Dock(TOP)
	_actionsWrap:DockMargin(0, gRespY(6), 0, 0)
	_actionsWrap:SetTall(gRespY(500))

	gAdminBuildActions(_actionsWrap)

	-- ── Warns section ────────────────────────────────────

	if gAdminHasPerm("warnings") then
		local warnsWrap = vgui.Create("gPanel", _rightBody)
		warnsWrap:Dock(TOP)
		warnsWrap:DockMargin(0, gRespY(10), 0, 0)
		warnsWrap:SetTall(gRespY(220))
		warnsWrap:gSetBgColor(gTheme("surface"), gThemeAlpha("high"))
		warnsWrap:gSetRadius(gThemeRadius("sm"))
		warnsWrap:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))
		warnsWrap:DockPadding(gRespX(10), gRespY(6), gRespX(10), gRespY(8))

		local warnsTop = vgui.Create("DPanel", warnsWrap)
		warnsTop:SetPaintBackground(false)
		warnsTop:Dock(TOP)
		warnsTop:SetTall(gRespY(24))

		_warnsHeader = vgui.Create("gLabel", warnsTop)
		_warnsHeader:SetPos(0, 0)
		_warnsHeader:SetSize(gRespX(200), gRespY(24))
		_warnsHeader:gSetFont("OxaniumSemiBold", 12)
		_warnsHeader:gSetColor(gTheme("warning"))
		_warnsHeader:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		_warnsHeader:gSetText("Avertissements (0)")

		local refreshWarnsBtn = vgui.Create("gButton", warnsTop)
		refreshWarnsBtn:SetPos(gRespX(200), 0)
		refreshWarnsBtn:gSetSize(80, 22)
		refreshWarnsBtn:gSetBgColor(gTheme("elevated"), gThemeAlpha("mid"))
		refreshWarnsBtn:gSetText("Recharger", "OxaniumRegular", 10)
		refreshWarnsBtn:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))
		refreshWarnsBtn.DoClick = function()
			if _selSID then
				gAdminRequestWarns(_selSID)
				gAdminStatusMsg("Warns rechargés.")
			end
		end

		if gAdminHasPerm("clearwarnings") then
			_warnsClear = vgui.Create("gButton", warnsTop)
			_warnsClear:SetPos(gRespX(288), 0)
			_warnsClear:gSetSize(100, 22)
			_warnsClear:gSetBgColor(gTheme("danger"), gThemeAlpha("mid"))
			_warnsClear:gSetText("Effacer tout", "OxaniumMedium", 10, gContrastText(gTheme("danger")))
			_warnsClear:SetVisible(false)
			_warnsClear.DoClick = function()
				local ply = gAdminGetSelectedPly()
				if not ply then return end
				gAdminSendCmd("clearwarnings", ply:SteamID64())
				gAdminStatusMsg("Warns effacés pour " .. ply:Nick())
				timer.Simple(0.3, function()
					if _selSID then gAdminRequestWarns(_selSID) end
				end)
			end
		end

		local warnsScrollWrap = vgui.Create("DPanel", warnsWrap)
		warnsScrollWrap:SetPaintBackground(false)
		warnsScrollWrap:Dock(FILL)
		warnsScrollWrap:DockMargin(0, gRespY(4), 0, 0)

		_warnsScroll = vgui.Create("DScrollPanel", warnsScrollWrap)
		_warnsScroll:Dock(FILL)
		gAdminStyleScrollBar(_warnsScroll:GetVBar())

		gAdminBuildWarns()
	end

	-- auto-height for _rightBody
	local totalH = 82 + 6 + 500 + (gAdminHasPerm("warnings") and (10 + 220) or 0) + PAD * 2
	_rightBody:SetTall(gRespY(totalH))

	-- ── Status bar ───────────────────────────────────────

	local statusWrap = vgui.Create("gPanel", _panel)
	statusWrap:SetPos(gRespX(SIDEBAR_W), gRespY(HEADER_H + CONTENT_H))
	statusWrap:SetSize(gRespX(CONTENT_W), gRespY(STATUS_H))
	statusWrap:gSetBgColor(gTheme("surface"), gThemeAlpha("high"))
	statusWrap:gSetRadius(0)
	statusWrap:gSetCorners(false, false, false, true)

	_statusBar = vgui.Create("gLabel", statusWrap)
	_statusBar:SetPos(gRespX(12), 0)
	_statusBar:SetSize(gRespX(CONTENT_W - 24), gRespY(STATUS_H))
	_statusBar:gSetFont("OxaniumRegular", 11)
	_statusBar:gSetColor(gTheme("textMute"))
	_statusBar:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	_statusBar:gSetText("F10 ou !admin pour ouvrir ce panneau.")
end

-- ── Net handlers ─────────────────────────────────────────

net.Receive("gAdmin.Perms", function()
	local count = net.ReadUInt(8)
	_perms = {}

	for _ = 1, count do
		local cmd = net.ReadString()
		_perms[cmd] = true
	end

	gAdminBuildPanel()
end)

net.Receive("gAdmin.Warns", function()
	local targetSID = net.ReadString()
	local count     = net.ReadUInt(8)

	local warns = {}
	for _ = 1, count do
		warns[#warns + 1] = {
			reason   = net.ReadString(),
			given_by = net.ReadString(),
			given_at = net.ReadUInt(32),
		}
	end

	if targetSID ~= _selSID then return end

	_warnsData = warns
	gAdminBuildWarns()
end)

concommand.Add("gAdmin_open", function()
	net.Start("gAdmin.RequestPerms")
	net.SendToServer()
end)

print("modules/admin/cl_admin_ui.lua | LOAD !")
