-- Panneau admin : état sur l'instance VGUI (vgui.Register), pas en locals fichier.
-- Un seul pointeur pour les nets (évite de scanner l'arbre VGUI).

local _activeAdminPanel = nil

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

-- ── Helpers sans état panel ──────────────────────────────

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

-- ── VGUI : gAdminPanel (hérite gFrame) ───────────────────

local PANEL = {}

function PANEL:Init()
	local gFrameTbl = vgui.GetControlTable("gFrame")
	if gFrameTbl and gFrameTbl.Init then
		gFrameTbl.Init(self)
	end

	self._perms       = {}
	self._selSID      = nil
	self._entries     = {}
	self._warnsData   = {}
	self._nextInfoAt  = 0

	self._playerScroll = nil
	self._searchEntry  = nil
	self._rightBody    = nil
	self._infoName     = nil
	self._infoRank     = nil
	self._infoHP       = nil
	self._infoArmor    = nil
	self._infoAlive    = nil
	self._actionsWrap  = nil
	self._statusBar    = nil
	self._warnsScroll  = nil
	self._warnsHeader  = nil
	self._warnsClear   = nil

	_activeAdminPanel = self
end

function PANEL:OnRemove()
	if _activeAdminPanel == self then
		_activeAdminPanel = nil
	end
end

function PANEL:gAdminHasPerm(cmd)
	return self._perms[cmd] == true
end

function PANEL:gAdminStatusMsg(text)
	if IsValid(self._statusBar) then
		self._statusBar:gSetText(text)
	end
end

function PANEL:gAdminGetSelectedPly()
	if not self._selSID then return nil end
	for _, ply in ipairs(player.GetAll()) do
		if ply:SteamID64() == self._selSID then return ply end
	end
	return nil
end

function PANEL:gAdminRequestWarns(sid64)
	if not sid64 or not self:gAdminHasPerm("warnings") then return end
	net.Start("gAdmin.RequestWarns")
	net.WriteString(sid64)
	net.SendToServer()
end

function PANEL:gAdminUpdateInfo()
	local ply = self:gAdminGetSelectedPly()

	if not ply or not IsValid(ply) then
		if IsValid(self._infoName)  then self._infoName:gSetText("Aucun joueur sélectionné") end
		if IsValid(self._infoRank)  then self._infoRank:gSetText("")  end
		if IsValid(self._infoHP)    then self._infoHP:gSetText("")    end
		if IsValid(self._infoArmor) then self._infoArmor:gSetText("") end
		if IsValid(self._infoAlive) then self._infoAlive:gSetText("") end
		return
	end

	local suffix = ply == LocalPlayer() and " (moi)" or ""

	if IsValid(self._infoName) then
		self._infoName:gSetText(ply:Nick() .. suffix)
	end

	if IsValid(self._infoRank) then
		local rk = gAdminGetRankName(ply)
		self._infoRank:gSetText(rk)
		self._infoRank:gSetColor(gAdminGetRankColor(ply))
	end

	if IsValid(self._infoHP) then
		self._infoHP:gSetText("Vie : " .. ply:Health() .. " / " .. ply:GetMaxHealth())
	end

	if IsValid(self._infoArmor) then
		self._infoArmor:gSetText("Armure : " .. ply:Armor())
	end

	if IsValid(self._infoAlive) then
		self._infoAlive:gSetText(ply:Alive() and "Vivant" or "Mort")
		self._infoAlive:gSetColor(ply:Alive() and gTheme("success") or gTheme("danger"))
	end
end

function PANEL:gAdminBuildWarns()
	if not IsValid(self._warnsScroll) then return end
	self._warnsScroll:Clear()

	if IsValid(self._warnsHeader) then
		self._warnsHeader:gSetText("Avertissements (" .. #self._warnsData .. ")")
	end

	if IsValid(self._warnsClear) then
		self._warnsClear:SetVisible(#self._warnsData > 0 and self:gAdminHasPerm("clearwarnings"))
	end

	if #self._warnsData == 0 then
		local empty = vgui.Create("gLabel", self._warnsScroll)
		empty:Dock(TOP)
		empty:SetTall(gRespY(28))
		empty:DockMargin(gRespX(8), gRespY(4), 0, 0)
		empty:gSetFont("OxaniumRegular", 11)
		empty:gSetColor(gTheme("textMute"))
		empty:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		empty:gSetText("Aucun avertissement.")
		return
	end

	for i, w in ipairs(self._warnsData) do
		local row = vgui.Create("gPanel", self._warnsScroll)
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

function PANEL:gAdminSelectPlayer(sid64)
	self._selSID = sid64

	for sid, entry in pairs(self._entries) do
		if IsValid(entry) then
			if sid == sid64 then
				entry:gSetBgColor(gTheme("accent"), 40)
			else
				entry:gSetBgColor(gTheme("elevated"), gThemeAlpha("mid"))
			end
		end
	end

	self:gAdminUpdateInfo()

	self._warnsData = {}
	self:gAdminBuildWarns()
	self:gAdminRequestWarns(sid64)
end

function PANEL:gAdminBuildPlayerList(scroll, searchQ)
	if not IsValid(scroll) then return end

	scroll:Clear()
	self._entries = {}

	local q     = string.lower(searchQ or "")
	local plist = player.GetAll()
	local lp    = LocalPlayer()
	local pnl   = self

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
		entry._bgColor = sid64 == self._selSID and gTheme("accent") or gTheme("elevated")
		entry._bgAlpha = sid64 == self._selSID and 40 or gThemeAlpha("mid")
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
			if code == MOUSE_LEFT then pnl:gAdminSelectPlayer(sid64) end
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

		self._entries[sid64] = entry
	end
end

function PANEL:gAdminBuildActions(parent)
	if not IsValid(parent) then return end
	parent:Clear()

	local padX = 8
	local padY = 6
	local btnW = 100
	local btnH = 30
	local pnl  = self

	for _, grp in ipairs(CMD_GROUPS) do
		local hasCmds = false
		for _, cmd in ipairs(grp.cmds) do
			if pnl:gAdminHasPerm(cmd.name) then hasCmds = true break end
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
			if not pnl:gAdminHasPerm(cmd.name) then continue end

			local btn = vgui.Create("gButton", row)
			btn:SetPos(gRespX(ox), 0)
			btn:gSetSize(btnW, btnH)
			btn:gSetBgColor(gTheme("elevated"), gThemeAlpha("mid"))
			btn:gSetText(cmd.label, "OxaniumMedium", 12)
			btn:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))

			local cname = cmd.name
			btn.DoClick = function()
				local ply = pnl:gAdminGetSelectedPly()
				if not ply then
					pnl:gAdminStatusMsg("Sélectionne un joueur d'abord.")
					return
				end
				gAdminSendCmd(cname, ply:SteamID64())
				pnl:gAdminStatusMsg("!" .. cname .. " → " .. ply:Nick())
			end

			ox = ox + btnW + padX
		end
	end

	local hasInputCmds = false
	for _, ic in ipairs(INPUT_CMDS) do
		if pnl:gAdminHasPerm(ic.name) then hasInputCmds = true break end
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
		if not pnl:gAdminHasPerm(ic.name) then continue end

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
			local ply = pnl:gAdminGetSelectedPly()
			if not ply then
				pnl:gAdminStatusMsg("Sélectionne un joueur d'abord.")
				return
			end
			local val = te:GetValue():Trim()
			if val == "" then
				pnl:gAdminStatusMsg("Valeur requise pour !" .. cname)
				return
			end
			gAdminSendCmd(cname, ply:SteamID64(), val)
			pnl:gAdminStatusMsg("!" .. cname .. " " .. val .. " → " .. ply:Nick())
		end

		te.OnEnter = function()
			btn:DoClick()
		end
	end
end

function PANEL:SetPerms(perms)
	self._perms = perms or {}
end

function PANEL:Think()
	local gFrameTbl = vgui.GetControlTable("gFrame")
	if gFrameTbl and gFrameTbl.Think then
		gFrameTbl.Think(self)
	end

	local now = RealTime()
	if now >= self._nextInfoAt then
		self._nextInfoAt = now + 0.25
		self:gAdminUpdateInfo()
	end
end

function PANEL:BuildLayout()
	local W, H       = 920, 620
	local HEADER_H   = 40
	local SIDEBAR_W  = 230
	local STATUS_H   = 30
	local CONTENT_W  = W - SIDEBAR_W
	local CONTENT_H  = H - HEADER_H - STATUS_H
	local PAD        = 10

	local hc = gTheme("surface")

	self:gSetSize(W, H)
	self:gCenter()
	self:gSetRadius(gThemeRadius("lg"))
	self:gSetBgColor(gTheme("bg"), gThemeAlpha("full"))
	self:gSetHeader(true, hc, gThemeAlpha("high"), HEADER_H)
	self:gSetTitle("Panneau Admin", "OxaniumMedium", 15, gContrastText(hc), TEXT_ALIGN_CENTER)
	self:gSetCloseButton(true, "OxaniumLight", 20, gContrastText(hc, 160))
	self:gSetDraggable(true)
	self:gSetBorder(true, gThemeAlpha("border"))

	-- ── Sidebar ──────────────────────────────────────────

	local sidebar = vgui.Create("gPanel", self)
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
	self._searchEntry = search

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
	self._playerScroll = scroll

	local pnl = self
	self:gAdminBuildPlayerList(scroll, "")

	search.OnChange = function()
		pnl:gAdminBuildPlayerList(scroll, search:GetValue())
	end

	refreshBtn.DoClick = function()
		pnl:gAdminBuildPlayerList(scroll, search:GetValue())
		pnl:gAdminUpdateInfo()
		if pnl._selSID then pnl:gAdminRequestWarns(pnl._selSID) end
		pnl:gAdminStatusMsg("Liste rafraîchie.")
	end

	-- ── Right panel ──────────────────────────────────────

	local rightScroll = vgui.Create("DScrollPanel", self)
	rightScroll:SetPos(gRespX(SIDEBAR_W), gRespY(HEADER_H))
	rightScroll:SetSize(gRespX(CONTENT_W), gRespY(CONTENT_H))
	gAdminStyleScrollBar(rightScroll:GetVBar())

	self._rightBody = vgui.Create("DPanel", rightScroll)
	self._rightBody:SetPaintBackground(false)
	self._rightBody:Dock(TOP)
	self._rightBody:DockPadding(gRespX(PAD + 4), gRespY(PAD), gRespX(PAD + 4), gRespY(PAD))

	-- Player info
	local infoWrap = vgui.Create("gPanel", self._rightBody)
	infoWrap:Dock(TOP)
	infoWrap:SetTall(gRespY(82))
	infoWrap:gSetBgColor(gTheme("surface"), gThemeAlpha("high"))
	infoWrap:gSetRadius(gThemeRadius("sm"))
	infoWrap:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))
	infoWrap:DockPadding(gRespX(12), gRespY(8), gRespX(12), gRespY(8))

	self._infoName = vgui.Create("gLabel", infoWrap)
	self._infoName:Dock(TOP)
	self._infoName:SetTall(gRespY(20))
	self._infoName:gSetFont("OxaniumSemiBold", 15)
	self._infoName:gSetColor(gTheme("text"))
	self._infoName:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	self._infoName:gSetText("Aucun joueur sélectionné")

	local infoRow = vgui.Create("DPanel", infoWrap)
	infoRow:SetPaintBackground(false)
	infoRow:Dock(TOP)
	infoRow:SetTall(gRespY(16))
	infoRow:DockMargin(0, gRespY(3), 0, 0)

	self._infoRank = vgui.Create("gLabel", infoRow)
	self._infoRank:SetPos(0, 0)
	self._infoRank:SetSize(gRespX(120), gRespY(16))
	self._infoRank:gSetFont("OxaniumMedium", 12)
	self._infoRank:gSetColor(gTheme("textDim"))
	self._infoRank:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	self._infoRank:gSetText("")

	self._infoAlive = vgui.Create("gLabel", infoRow)
	self._infoAlive:SetPos(gRespX(130), 0)
	self._infoAlive:SetSize(gRespX(80), gRespY(16))
	self._infoAlive:gSetFont("OxaniumRegular", 11)
	self._infoAlive:gSetColor(gTheme("textDim"))
	self._infoAlive:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	self._infoAlive:gSetText("")

	local infoRow2 = vgui.Create("DPanel", infoWrap)
	infoRow2:SetPaintBackground(false)
	infoRow2:Dock(TOP)
	infoRow2:SetTall(gRespY(16))
	infoRow2:DockMargin(0, gRespY(3), 0, 0)

	self._infoHP = vgui.Create("gLabel", infoRow2)
	self._infoHP:SetPos(0, 0)
	self._infoHP:SetSize(gRespX(160), gRespY(16))
	self._infoHP:gSetFont("OxaniumRegular", 12)
	self._infoHP:gSetColor(gTheme("text"))
	self._infoHP:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	self._infoHP:gSetText("")

	self._infoArmor = vgui.Create("gLabel", infoRow2)
	self._infoArmor:SetPos(gRespX(170), 0)
	self._infoArmor:SetSize(gRespX(160), gRespY(16))
	self._infoArmor:gSetFont("OxaniumRegular", 12)
	self._infoArmor:gSetColor(gTheme("text"))
	self._infoArmor:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	self._infoArmor:gSetText("")

	-- Actions
	self._actionsWrap = vgui.Create("DPanel", self._rightBody)
	self._actionsWrap:SetPaintBackground(false)
	self._actionsWrap:Dock(TOP)
	self._actionsWrap:DockMargin(0, gRespY(6), 0, 0)
	self._actionsWrap:SetTall(gRespY(500))

	self:gAdminBuildActions(self._actionsWrap)

	-- Warns
	if self:gAdminHasPerm("warnings") then
		local warnsWrap = vgui.Create("gPanel", self._rightBody)
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

		self._warnsHeader = vgui.Create("gLabel", warnsTop)
		self._warnsHeader:SetPos(0, 0)
		self._warnsHeader:SetSize(gRespX(200), gRespY(24))
		self._warnsHeader:gSetFont("OxaniumSemiBold", 12)
		self._warnsHeader:gSetColor(gTheme("warning"))
		self._warnsHeader:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		self._warnsHeader:gSetText("Avertissements (0)")

		local refreshWarnsBtn = vgui.Create("gButton", warnsTop)
		refreshWarnsBtn:SetPos(gRespX(200), 0)
		refreshWarnsBtn:gSetSize(80, 22)
		refreshWarnsBtn:gSetBgColor(gTheme("elevated"), gThemeAlpha("mid"))
		refreshWarnsBtn:gSetText("Recharger", "OxaniumRegular", 10)
		refreshWarnsBtn:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))
		refreshWarnsBtn.DoClick = function()
			if pnl._selSID then
				pnl:gAdminRequestWarns(pnl._selSID)
				pnl:gAdminStatusMsg("Warns rechargés.")
			end
		end

		if self:gAdminHasPerm("clearwarnings") then
			self._warnsClear = vgui.Create("gButton", warnsTop)
			self._warnsClear:SetPos(gRespX(288), 0)
			self._warnsClear:gSetSize(100, 22)
			self._warnsClear:gSetBgColor(gTheme("danger"), gThemeAlpha("mid"))
			self._warnsClear:gSetText("Effacer tout", "OxaniumMedium", 10, gContrastText(gTheme("danger")))
			self._warnsClear:SetVisible(false)
			self._warnsClear.DoClick = function()
				local ply = pnl:gAdminGetSelectedPly()
				if not ply then return end
				gAdminSendCmd("clearwarnings", ply:SteamID64())
				pnl:gAdminStatusMsg("Warns effacés pour " .. ply:Nick())
				timer.Simple(0.3, function()
					if not IsValid(pnl) then return end
					if pnl._selSID then pnl:gAdminRequestWarns(pnl._selSID) end
				end)
			end
		end

		local warnsScrollWrap = vgui.Create("DPanel", warnsWrap)
		warnsScrollWrap:SetPaintBackground(false)
		warnsScrollWrap:Dock(FILL)
		warnsScrollWrap:DockMargin(0, gRespY(4), 0, 0)

		self._warnsScroll = vgui.Create("DScrollPanel", warnsScrollWrap)
		self._warnsScroll:Dock(FILL)
		gAdminStyleScrollBar(self._warnsScroll:GetVBar())

		self:gAdminBuildWarns()
	end

	local totalH = 82 + 6 + 500 + (self:gAdminHasPerm("warnings") and (10 + 220) or 0) + PAD * 2
	self._rightBody:SetTall(gRespY(totalH))

	-- Status bar
	local statusWrap = vgui.Create("gPanel", self)
	statusWrap:SetPos(gRespX(SIDEBAR_W), gRespY(HEADER_H + CONTENT_H))
	statusWrap:SetSize(gRespX(CONTENT_W), gRespY(STATUS_H))
	statusWrap:gSetBgColor(gTheme("surface"), gThemeAlpha("high"))
	statusWrap:gSetRadius(0)
	statusWrap:gSetCorners(false, false, false, true)

	self._statusBar = vgui.Create("gLabel", statusWrap)
	self._statusBar:SetPos(gRespX(12), 0)
	self._statusBar:SetSize(gRespX(CONTENT_W - 24), gRespY(STATUS_H))
	self._statusBar:gSetFont("OxaniumRegular", 11)
	self._statusBar:gSetColor(gTheme("textMute"))
	self._statusBar:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	self._statusBar:gSetText("F10 ou !admin pour ouvrir ce panneau.")

	self:gOpen(0.15)
end

vgui.Register("gAdminPanel", PANEL, "gFrame")

-- ── Net / concommand ─────────────────────────────────────

net.Receive("gAdmin.Perms", function()
	local count = net.ReadUInt(8)
	local perms = {}

	for _ = 1, count do
		local cmd = net.ReadString()
		perms[cmd] = true
	end

	if IsValid(_activeAdminPanel) then
		_activeAdminPanel:Remove()
	end

	local pnl = vgui.Create("gAdminPanel")
	pnl:SetPerms(perms)
	pnl:BuildLayout()
end)

net.Receive("gAdmin.Warns", function()
	local pnl = _activeAdminPanel
	if not IsValid(pnl) then return end

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

	if targetSID ~= pnl._selSID then return end

	pnl._warnsData = warns
	pnl:gAdminBuildWarns()
end)

concommand.Add("gAdmin_open", function()
	net.Start("gAdmin.RequestPerms")
	net.SendToServer()
end)

print("modules/admin/cl_admin_ui.lua | LOAD !")
