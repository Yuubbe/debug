local _playerPanel = nil

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
		title = "Déplacement",
		cmds  = {
			{ name = "goto",  label = "Goto"  },
			{ name = "bring", label = "Bring" },
			{ name = "tp",    label = "Tp"    },
		},
	},
	{
		title = "Statut",
		cmds  = {
			{ name = "god",    label = "God"    },
			{ name = "noclip", label = "Noclip" },
			{ name = "freeze", label = "Freeze" },
			{ name = "cloak",  label = "Cloak"  },
			{ name = "mute",   label = "Mute"   },
			{ name = "unmute", label = "Unmute" },
		},
	},
	{
		title = "Combat",
		cmds  = {
			{ name = "slay",    label = "Slay"    },
			{ name = "respawn", label = "Respawn" },
			{ name = "strip",   label = "Strip"   },
		},
	},
}

local INPUT_CMDS = {
	{ name = "sethp",    label = "Vie",    placeholder = "ex: 100",      btn = "OK",   color = nil       },
	{ name = "setarmor", label = "Armure", placeholder = "ex: 255",      btn = "OK",   color = nil       },
	{ name = "kick",     label = "Kick",   placeholder = "Raison...",    btn = "Kick", color = "warning" },
	{ name = "warn",     label = "Warn",   placeholder = "Raison...",    btn = "Warn", color = "warning" },
	{ name = "ban",      label = "Ban",    placeholder = "raison 1h/1j", btn = "Ban",  color = "danger"  },
}

local function gAdminCreate(class, parent)
	local p = vgui.Create(class, parent)
	if p.gSetRadius then p:gSetRadius(0) end
	return p
end

local function gAdminRankColor(ply)
	if not IsValid(ply) then return RANK_COLORS.user end
	return RANK_COLORS[ply:GetUserGroup()] or RANK_COLORS.user
end

local function gAdminSendCmd(cmd, sid, extra)
	net.Start("gAdmin.Cmd")
		net.WriteString(cmd)
		net.WriteString(sid   or "")
		net.WriteString(extra or "")
	net.SendToServer()
end

local PANEL = {}

PANEL._type = "player"

function PANEL:Init()
	local base = vgui.GetControlTable("gFrame")
	if base and base.Init then base.Init(self) end
	if self.gSetRadius then self:gSetRadius(0) end

	self._leftRef   = nil
	self._sid64     = nil
	self._perms     = {}
	self._infoTick  = 0
	self._warnsData = {}

	self._lblHP      = nil
	self._lblArmor   = nil
	self._lblAlive   = nil
	self._warnsTitle = nil
	self._warnsScroll = nil
	self._warnsClear  = nil
	self._statusLbl   = nil

	_playerPanel = self
end

function PANEL:OnRemove()
	if _playerPanel == self then _playerPanel = nil end
end

function PANEL:gHasPerm(cmd)
	return self._perms[cmd] == true
end

function PANEL:gStatus(msg)
	if IsValid(self._statusLbl) then
		self._statusLbl:gSetText(msg)
	end
end

function PANEL:gGetPly()
	if not self._sid64 then return nil end
	for _, ply in ipairs(player.GetAll()) do
		if ply:SteamID64() == self._sid64 then return ply end
	end
	return nil
end

function PANEL:gUpdateInfo()
	local ply = self:gGetPly()
	if not IsValid(ply) then return end

	if IsValid(self._lblHP) then
		self._lblHP:gSetText("HP  " .. ply:Health() .. " / " .. ply:GetMaxHealth())
	end

	if IsValid(self._lblArmor) then
		self._lblArmor:gSetText("Armure  " .. ply:Armor())
	end

	if IsValid(self._lblAlive) then
		local alive = ply:Alive()
		self._lblAlive:gSetText(alive and "Vivant" or "Mort")
		self._lblAlive:gSetColor(alive and gTheme("success") or gTheme("danger"))
	end
end

function PANEL:gRequestWarns()
	if not self._sid64 or not self:gHasPerm("warnings") then return end
	net.Start("gAdmin.RequestWarns")
		net.WriteString(self._sid64)
	net.SendToServer()
end

function PANEL:gBuildWarns()
	if not IsValid(self._warnsScroll) then return end

	local canvas = self._warnsScroll:GetCanvas()
	for _, c in ipairs(canvas:GetChildren()) do
		if IsValid(c) then c:Remove() end
	end

	if IsValid(self._warnsTitle) then
		self._warnsTitle:gSetText("Warns (" .. #self._warnsData .. ")")
	end

	if IsValid(self._warnsClear) then
		self._warnsClear:SetVisible(#self._warnsData > 0 and self:gHasPerm("clearwarnings"))
	end

	local cW = self._warnsScroll:GetWide() - gRespX(4)

	if #self._warnsData == 0 then
		local empty = gAdminCreate("gLabel", canvas)
		empty:SetSize(cW, gRespY(24))
		empty:SetPos(gRespX(8), gRespY(4))
		empty:gSetFont("OxaniumRegular", 11)
		empty:gSetColor(gTheme("textMute"))
		empty:gSetText("Aucun avertissement.")
		return
	end

	local rowH = gRespY(46)
	local rowP = gRespY(2)
	local cWPad = cW - gRespX(8)

	for i, w in ipairs(self._warnsData) do
		local row = gAdminCreate("gPanel", canvas)
		row:SetSize(cWPad, rowH)
		row:SetPos(0, (i - 1) * (rowH + rowP))
		row:gSetBgColor(gTheme("elevated"), gThemeAlpha("mid"))

		local reason = gAdminCreate("gLabel", row)
		reason:SetSize(cWPad - gRespX(16), gRespY(20))
		reason:SetPos(gRespX(8), gRespY(4))
		reason:gSetFont("OxaniumRegular", 12)
		reason:gSetColor(gTheme("text"))
		reason:gSetText("#" .. i .. "  " .. w.reason)

		local meta = gAdminCreate("gLabel", row)
		meta:SetSize(cWPad - gRespX(16), gRespY(16))
		meta:SetPos(gRespX(8), gRespY(26))
		meta:gSetFont("OxaniumLight", 10)
		meta:gSetColor(gTheme("textDim"))
		meta:gSetText("par " .. w.given_by .. "  •  " .. os.date("%d/%m/%Y %H:%M", w.given_at))
	end
end

function PANEL:Think()
	local base = vgui.GetControlTable("gFrame")
	if base and base.Think then base.Think(self) end

	local now = RealTime()
	if now >= self._infoTick then
		self._infoTick = now + 0.25
		self:gUpdateInfo()
	end
end

function PANEL:gBuild(leftPanel, sid64)
	self._leftRef = leftPanel
	self._sid64   = sid64
	self._perms   = IsValid(leftPanel) and leftPanel._perms or {}

	local ply = self:gGetPly()
	if not IsValid(ply) then
		self:Remove()
		return
	end

	local W        = 420
	local H        = 680
	local HEADER_H = 40
	local STATUS_H = 24
	local PAD      = 8
	local hc       = gTheme("elevated")
	local rc       = gAdminRankColor(ply)
	local pnl      = self

	local leftX, leftY = 0, 0
	if IsValid(leftPanel) then
		leftX, leftY = leftPanel:GetPos()
	end
	local leftW        = IsValid(leftPanel) and leftPanel:GetWide() or gRespX(320)

	self:gSetSize(W, H)
	self:SetPos(leftX + leftW + gRespX(4), (ScrH() - gRespY(H)) * 0.5)
	self:gSetBgColor(gTheme("bg"), gThemeAlpha("full"))
	self:gSetHeader(true, hc, gThemeAlpha("high"), HEADER_H)
	self:gSetCloseButton(true, "OxaniumLight", 18, gContrastText(hc, 160))
	self:gSetDraggable(true)
	self:gSetBorder(true, gThemeAlpha("border"))

	local suffix = ply == LocalPlayer() and " (moi)" or ""
	self:gSetTitle(ply:Nick() .. suffix, "OxaniumMedium", 14, gContrastText(hc), TEXT_ALIGN_LEFT)

	-- Rank badge
	local rankLbl = gAdminCreate("gLabel", self)
	rankLbl:SetPos(gRespX(PAD), gRespY(HEADER_H + PAD))
	rankLbl:SetSize(gRespX(W - PAD * 2), gRespY(16))
	rankLbl:gSetFont("OxaniumMedium", 11)
	rankLbl:gSetColor(rc)
	rankLbl:gSetText(ply:GetUserGroup())

	-- Info bar
	local infoY = HEADER_H + PAD + 16 + PAD * 0.5
	local infoWrap = gAdminCreate("gPanel", self)
	infoWrap:SetPos(gRespX(PAD), gRespY(infoY))
	infoWrap:SetSize(gRespX(W - PAD * 2), gRespY(28))
	infoWrap:gSetBgColor(gTheme("surface"), gThemeAlpha("high"))
	infoWrap:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))

	self._lblHP = gAdminCreate("gLabel", infoWrap)
	self._lblHP:SetPos(gRespX(10), 0)
	self._lblHP:SetSize(gRespX(130), gRespY(28))
	self._lblHP:gSetFont("OxaniumRegular", 11)
	self._lblHP:gSetColor(gTheme("text"))
	self._lblHP:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	self._lblArmor = gAdminCreate("gLabel", infoWrap)
	self._lblArmor:SetPos(gRespX(150), 0)
	self._lblArmor:SetSize(gRespX(120), gRespY(28))
	self._lblArmor:gSetFont("OxaniumRegular", 11)
	self._lblArmor:gSetColor(gTheme("text"))
	self._lblArmor:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	self._lblAlive = gAdminCreate("gLabel", infoWrap)
	self._lblAlive:SetPos(gRespX(280), 0)
	self._lblAlive:SetSize(gRespX(100), gRespY(28))
	self._lblAlive:gSetFont("OxaniumMedium", 11)
	self._lblAlive:gSetColor(gTheme("success"))
	self._lblAlive:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	self:gUpdateInfo()

	-- Commandes
	local cmdsY    = infoY + 28 + PAD
	local scroll   = gAdminCreate("gScrollPanel", self)
	scroll:SetPos(gRespX(PAD), gRespY(cmdsY))
	scroll:SetSize(gRespX(W - PAD * 2), gRespY(H - cmdsY - STATUS_H - PAD * 2))
	scroll:gSetBgColor(gTheme("bg"), 0)
	scroll:gSetScrollbar(true, 3, gTheme("textMute"))
	scroll:gSetPadding(0, 4)

	local canvas = scroll:GetCanvas()
	local cW     = gRespX(W - PAD * 2 - 14)
	local curY   = 0
	local btnH   = gRespY(26)
	local btnPad = gRespX(6)

	for _, grp in ipairs(CMD_GROUPS) do
		local hasCmds = false
		for _, cmd in ipairs(grp.cmds) do
			if pnl:gHasPerm(cmd.name) then hasCmds = true break end
		end
		if not hasCmds then continue end

		local header = gAdminCreate("gLabel", canvas)
		header:SetSize(cW, gRespY(14))
		header:SetPos(0, curY)
		header:gSetFont("OxaniumSemiBold", 10)
		header:gSetColor(gTheme("textMute"))
		header:gSetUppercase(true)
		header:gSetText(grp.title)
		curY = curY + gRespY(14) + gRespY(4)

		local row = vgui.Create("DPanel", canvas)
		row:SetPaintBackground(false)
		row:SetPos(0, curY)
		row:SetSize(cW, btnH)

		local ox = 0
		for _, cmd in ipairs(grp.cmds) do
			if not pnl:gHasPerm(cmd.name) then continue end

			local btn = gAdminCreate("gButton", row)
			btn:SetPos(ox, 0)
			btn:SetSize(gRespX(60), btnH)
			btn:gSetBgColor(gTheme("elevated"), gThemeAlpha("mid"))
			btn:gSetText(cmd.label, "OxaniumRegular", 11)
			btn:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))

			local cname = cmd.name
			btn.DoClick = function()
				local ply2 = pnl:gGetPly()
				if not IsValid(ply2) then pnl:gStatus("Joueur introuvable.") return end
				gAdminSendCmd(cname, ply2:SteamID64())
				pnl:gStatus("!" .. cname .. " → " .. ply2:Nick())
			end

			ox = ox + gRespX(60) + btnPad
		end

		curY = curY + btnH + gRespY(10)
	end

	local hasInput = false
	for _, ic in ipairs(INPUT_CMDS) do
		if pnl:gHasPerm(ic.name) then hasInput = true break end
	end

	if hasInput then
		local sepH = gAdminCreate("gLabel", canvas)
		sepH:SetSize(cW, gRespY(14))
		sepH:SetPos(0, curY)
		sepH:gSetFont("OxaniumSemiBold", 10)
		sepH:gSetColor(gTheme("textMute"))
		sepH:gSetUppercase(true)
		sepH:gSetText("Commandes")
		curY = curY + gRespY(14) + gRespY(4)

		local labelW  = gRespX(56)
		local inputW  = gRespX(180)
		local inputBW = gRespX(60)
		local inputH  = gRespY(26)

		for _, ic in ipairs(INPUT_CMDS) do
			if not pnl:gHasPerm(ic.name) then continue end

			local irow = vgui.Create("DPanel", canvas)
			irow:SetPaintBackground(false)
			irow:SetPos(0, curY)
			irow:SetSize(cW, inputH)

			local lbl = gAdminCreate("gLabel", irow)
			lbl:SetPos(0, 0)
			lbl:SetSize(labelW, inputH)
			lbl:gSetFont("OxaniumMedium", 10)
			lbl:gSetColor(gTheme("textDim"))
			lbl:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			lbl:gSetText(ic.label)

			local te = gAdminCreate("gTextEntry", irow)
			te:SetPos(labelW + gRespX(4), 0)
			te:SetSize(inputW, inputH)
			te:gSetFont("OxaniumRegular", 11)
			te:gSetPlaceholder(ic.placeholder)

			local bc  = ic.color and gTheme(ic.color) or gTheme("elevated")
			local btc = ic.color and gContrastText(bc) or nil

			local btn = gAdminCreate("gButton", irow)
			btn:SetPos(labelW + inputW + gRespX(6), 0)
			btn:SetSize(inputBW, inputH)
			btn:gSetBgColor(bc, gThemeAlpha("mid"))
			btn:gSetText(ic.btn, "OxaniumMedium", 11, btc)

			local cname = ic.name
			local doCmd = function()
				local ply2 = pnl:gGetPly()
				if not IsValid(ply2) then pnl:gStatus("Joueur introuvable.") return end
				local val = te:GetValue():Trim()
				if val == "" then pnl:gStatus("Valeur requise.") return end
				gAdminSendCmd(cname, ply2:SteamID64(), val)
				pnl:gStatus("!" .. cname .. " " .. val .. " → " .. ply2:Nick())
			end

			btn.DoClick = doCmd
			te.OnEnter  = doCmd

			curY = curY + inputH + gRespY(5)
		end
	end

	-- Warns
	if self:gHasPerm("warnings") then
		curY = curY + gRespY(10)

		local warnsSep = gAdminCreate("gPanel", canvas)
		warnsSep:SetPos(0, curY)
		warnsSep:SetSize(cW, gRespY(1))
		warnsSep:gSetBgColor(gTheme("border"), gThemeAlpha("sep"))
		curY = curY + gRespY(1) + gRespY(8)

		local warnsTop = vgui.Create("DPanel", canvas)
		warnsTop:SetPaintBackground(false)
		warnsTop:SetPos(0, curY)
		warnsTop:SetSize(cW, gRespY(20))

		self._warnsTitle = gAdminCreate("gLabel", warnsTop)
		self._warnsTitle:SetPos(0, 0)
		self._warnsTitle:SetSize(gRespX(160), gRespY(20))
		self._warnsTitle:gSetFont("OxaniumSemiBold", 11)
		self._warnsTitle:gSetColor(gTheme("warning"))
		self._warnsTitle:gSetText("Warns (0)")

		local reloadBtn = gAdminCreate("gButton", warnsTop)
		reloadBtn:SetPos(gRespX(165), 0)
		reloadBtn:SetSize(gRespX(60), gRespY(20))
		reloadBtn:gSetBgColor(gTheme("elevated"), gThemeAlpha("mid"))
		reloadBtn:gSetText("Reload", "OxaniumRegular", 10)
		reloadBtn:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))
		reloadBtn.DoClick = function()
			pnl:gRequestWarns()
			pnl:gStatus("Warns rechargés.")
		end

		if self:gHasPerm("clearwarnings") then
			self._warnsClear = gAdminCreate("gButton", warnsTop)
			self._warnsClear:SetPos(gRespX(232), 0)
			self._warnsClear:SetSize(gRespX(90), gRespY(20))
			self._warnsClear:gSetBgColor(gTheme("danger"), gThemeAlpha("mid"))
			self._warnsClear:gSetText("Effacer tout", "OxaniumMedium", 10, gContrastText(gTheme("danger")))
			self._warnsClear:SetVisible(false)
			self._warnsClear.DoClick = function()
				local ply2 = pnl:gGetPly()
				if not IsValid(ply2) then return end
				gAdminSendCmd("clearwarnings", ply2:SteamID64())
				pnl:gStatus("Warns effacés.")
				timer.Simple(0.4, function()
					if IsValid(pnl) then pnl:gRequestWarns() end
				end)
			end
		end

		curY = curY + gRespY(20) + gRespY(4)

		self._warnsScroll = gAdminCreate("gScrollPanel", canvas)
		self._warnsScroll:SetPos(0, curY)
		self._warnsScroll:SetSize(cW, gRespY(160))
		self._warnsScroll:gSetBgColor(gTheme("surface"), gThemeAlpha("mid"))
		self._warnsScroll:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))
		self._warnsScroll:gSetScrollbar(true, 3, gTheme("textMute"))
		self._warnsScroll:gSetPadding(2, 6)

		self:gRequestWarns()
		self:gBuildWarns()
	end

	-- Status bar
	local statusWrap = gAdminCreate("gPanel", self)
	statusWrap:SetPos(gRespX(PAD), gRespY(H - STATUS_H - PAD * 0.5))
	statusWrap:SetSize(gRespX(W - PAD * 2), gRespY(STATUS_H))
	statusWrap:gSetBgColor(gTheme("surface"), gThemeAlpha("high"))

	self._statusLbl = gAdminCreate("gLabel", statusWrap)
	self._statusLbl:SetPos(gRespX(8), 0)
	self._statusLbl:SetSize(gRespX(W - PAD * 2 - 16), gRespY(STATUS_H))
	self._statusLbl:gSetFont("OxaniumRegular", 10)
	self._statusLbl:gSetColor(gTheme("textMute"))
	self._statusLbl:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	self._statusLbl:gSetText("Sélectionné : " .. ply:Nick())

	self:gOpen(0.12)
end

vgui.Register("gAdminPlayerPanel", PANEL, "gFrame")

net.Receive("gAdmin.Warns", function()
	local sid   = net.ReadString()
	local count = net.ReadUInt(8)
	local warns = {}

	for _ = 1, count do
		warns[#warns + 1] = {
			reason   = net.ReadString(),
			given_by = net.ReadString(),
			given_at = net.ReadUInt(32),
		}
	end

	if IsValid(_playerPanel) and _playerPanel._sid64 == sid then
		_playerPanel._warnsData = warns
		_playerPanel:gBuildWarns()
	end
end)