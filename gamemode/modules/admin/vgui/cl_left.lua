local _left    = nil
local _right   = nil

local RANK_COLORS = {
	owner     = Color(100, 100, 255),
	headadmin = Color(130, 90,  255),
	admin     = Color(60,  200, 100),
	moderator = Color(220, 155, 30),
	helper    = Color(140, 140, 150),
	user      = Color(70,  70,  80),
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

local function gAdminCloseRight()
	if IsValid(_right) then
		_right:gClose(0.12)
		_right = nil
	end
end

local function gAdminOpenRight(class)
	gAdminCloseRight()
	local p = gAdminCreate(class)
	p:gBuild(_left)
	_right = p
end

local PANEL = {}

function PANEL:Init()
	local base = vgui.GetControlTable("gFrame")
	if base and base.Init then base.Init(self) end
	if self.gSetRadius then self:gSetRadius(0) end

	self._perms    = {}
	self._selSID   = nil
	self._entries  = {}
	self._search   = nil
	self._list     = nil

	_left = self
end

function PANEL:OnRemove()
	if _left == self then _left = nil end
	gAdminCloseRight()
end

function PANEL:gHasPerm(cmd)
	return self._perms[cmd] == true
end

function PANEL:gSelectedPly()
	if not self._selSID then return nil end
	for _, ply in ipairs(player.GetAll()) do
		if ply:SteamID64() == self._selSID then return ply end
	end
	return nil
end

function PANEL:gSelectPlayer(sid64)
	self._selSID = sid64

	for sid, entry in pairs(self._entries) do
		if IsValid(entry) then
			entry._selected = sid == sid64
		end
	end

	gAdminCloseRight()

	local p = gAdminCreate("gAdminPlayerPanel")
	p:gBuild(self, sid64)
	_right = p
end

function PANEL:gBuildList(searchQ)
	if not IsValid(self._list) then return end

	local canvas = self._list:GetCanvas()
	for _, c in ipairs(canvas:GetChildren()) do
		if IsValid(c) then c:Remove() end
	end

	self._entries = {}

	local q     = string.lower(searchQ or "")
	local plist = player.GetAll()
	local lp    = LocalPlayer()
	local pnl   = self

	table.sort(plist, function(a, b)
		if a == lp then return true end
		if b == lp then return false end
		return a:Nick() < b:Nick()
	end)

	local W      = self._list:GetWide()
	local itemH  = gRespY(32)
	local itemP  = gRespY(1)
	local idx    = 0

	for _, ply in ipairs(plist) do
		if q ~= "" and not string.find(string.lower(ply:Nick()), q, 1, true) then continue end

		local sid64  = ply:SteamID64()
		local rc     = gAdminRankColor(ply)
		local isSelf = ply == lp
		local isSel  = sid64 == self._selSID

		local entry = vgui.Create("DPanel", canvas)
		entry:SetSize(W, itemH)
		entry:SetPos(0, idx * (itemH + itemP))
		entry:SetPaintBackground(false)
		entry:SetCursor("hand")

		entry._selected = isSel
		entry._hover    = 0

		function entry:Think()
			local mx, my = self:CursorPos()
			local w, h   = self:GetSize()
			local hov    = mx >= 0 and mx <= w and my >= 0 and my <= h
			self._hover  = math.Clamp(
				self._hover + ((hov and gThemeAlpha("hover") or 0) - self._hover) * FrameTime() * 10,
				0, gThemeAlpha("hover")
			)
		end

		function entry:Paint(w, h)
			if self._selected then
				local ac = gTheme("accent")
				surface.SetDrawColor(ac.r, ac.g, ac.b, 35)
				surface.DrawRect(0, 0, w, h)
				surface.SetDrawColor(ac.r, ac.g, ac.b, 200)
				surface.DrawRect(0, 0, gRespX(2), h)
			elseif self._hover > 0 then
				local hc = gTheme("border")
				surface.SetDrawColor(hc.r, hc.g, hc.b, self._hover)
				surface.DrawRect(0, 0, w, h)
			end
		end

		function entry:OnMousePressed(code)
			if code == MOUSE_LEFT then pnl:gSelectPlayer(sid64) end
		end

		local dot = vgui.Create("DPanel", entry)
		dot:SetSize(gRespX(5), gRespY(5))
		dot:SetPos(gRespX(10), (itemH - gRespY(5)) * 0.5)
		dot:SetPaintBackground(false)
		function dot:Paint(w, h)
			surface.SetDrawColor(rc.r, rc.g, rc.b, 255)
			surface.DrawRect(0, 0, w, h)
		end
		dot:SetMouseInputEnabled(false)

		local lbl = gAdminCreate("gLabel", entry)
		lbl:SetPos(gRespX(22), 0)
		lbl:SetSize(W - gRespX(28), itemH)
		lbl:gSetFont("OxaniumRegular", 12)
		lbl:gSetColor(isSelf and gTheme("accent") or gTheme("text"))
		lbl:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		lbl:gSetText(isSelf and (ply:Nick() .. " (moi)") or ply:Nick())
		lbl:SetMouseInputEnabled(false)

		self._entries[sid64] = entry
		idx = idx + 1
	end
end

function PANEL:SetPerms(perms)
	self._perms = perms or {}
end

function PANEL:Think()
	local base = vgui.GetControlTable("gFrame")
	if base and base.Think then base.Think(self) end
end

function PANEL:gBuild()
	local W        = 320
	local H        = 680
	local HEADER_H = 40
	local PAD      = 8
	local hc       = gTheme("elevated")

	self:gSetSize(W, H)
	self:SetPos(gRespX(0), (ScrH() - gRespY(H)) * 0.5)
	self:gSetBgColor(gTheme("bg"), gThemeAlpha("full"))
	self:gSetHeader(true, hc, gThemeAlpha("high"), HEADER_H)
	self:gSetTitle("Admin", "OxaniumSemiBold", 14, gContrastText(hc), TEXT_ALIGN_CENTER)
	self:gSetCloseButton(true, "OxaniumLight", 18, gContrastText(hc, 160))
	self:gSetDraggable(true)
	self:gSetBorder(true, gThemeAlpha("border"))

	local pnl = self

	-- Search
	self._search = gAdminCreate("gTextEntry", self)
	self._search:SetPos(gRespX(PAD), gRespY(HEADER_H + PAD))
	self._search:SetSize(gRespX(W - PAD * 2), gRespY(30))
	self._search:gSetFont("OxaniumRegular", 12)
	self._search:gSetPlaceholder("Rechercher...")
	self._search.OnChange = function()
		pnl:gBuildList(pnl._search:GetValue())
	end

	-- Refresh btn
	local refreshY = HEADER_H + PAD + 30 + PAD * 0.5
	local refreshBtn = gAdminCreate("gButton", self)
	refreshBtn:SetPos(gRespX(PAD), gRespY(refreshY))
	refreshBtn:SetSize(gRespX(W - PAD * 2), gRespY(24))
	refreshBtn:gSetBgColor(gTheme("elevated"), gThemeAlpha("mid"))
	refreshBtn:gSetText("Rafraîchir la liste", "OxaniumRegular", 11, gTheme("textDim"))
	refreshBtn:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))
	refreshBtn.DoClick = function()
		pnl:gBuildList(pnl._search:GetValue())
	end

	-- Player list
	local listY = refreshY + 24 + PAD
	local listH = H - listY - PAD - 2 - 30 - PAD - 30 - PAD

	self._list = gAdminCreate("gScrollPanel", self)
	self._list:SetPos(gRespX(PAD), gRespY(listY))
	self._list:SetSize(gRespX(W - PAD * 2), gRespY(listH))
	self._list:gSetBgColor(gTheme("surface"), gThemeAlpha("mid"))
	self._list:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))
	self._list:gSetScrollbar(true, 3, gTheme("textMute"))
	self._list:gSetPadding(0, 2)

	self:gBuildList("")

	-- Separator
	local sepY = listY + listH + PAD

	-- Warns globaux btn
	if self:gHasPerm("warnings") then
		local warnsBtn = gAdminCreate("gButton", self)
		warnsBtn:SetPos(gRespX(PAD), gRespY(sepY))
		warnsBtn:SetSize(gRespX(W - PAD * 2), gRespY(30))
		warnsBtn:gSetBgColor(gTheme("elevated"), gThemeAlpha("mid"))
		warnsBtn:gSetText("Warns globaux", "OxaniumMedium", 12, gTheme("warning"))
		warnsBtn:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))
		warnsBtn.DoClick = function()
			if IsValid(_right) and _right._type == "warns" then
				gAdminCloseRight()
				return
			end
			gAdminOpenRight("gAdminWarnsPanel")
		end
	end

	-- Logs btn
	if self:gHasPerm("admin") then
		local logsBtn = gAdminCreate("gButton", self)
		logsBtn:SetPos(gRespX(PAD), gRespY(sepY + 30 + PAD * 0.5))
		logsBtn:SetSize(gRespX(W - PAD * 2), gRespY(30))
		logsBtn:gSetBgColor(gTheme("elevated"), gThemeAlpha("mid"))
		logsBtn:gSetText("Logs", "OxaniumMedium", 12, gTheme("accent"))
		logsBtn:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))
		logsBtn.DoClick = function()
			if IsValid(_right) and _right._type == "logs" then
				gAdminCloseRight()
				return
			end
			gAdminOpenRight("gAdminLogsPanel")
		end
	end

	self:gOpen(0.15)
end

vgui.Register("gAdminLeftPanel", PANEL, "gFrame")

net.Receive("gAdmin.Perms", function()
	local count = net.ReadUInt(8)
	local perms = {}
	for _ = 1, count do
		perms[net.ReadString()] = true
	end

	if IsValid(_left) then _left:Remove() end

	local pnl = gAdminCreate("gAdminLeftPanel")
	pnl:SetPerms(perms)
	pnl:gBuild()
end)

concommand.Add("gAdmin_open", function()
	net.Start("gAdmin.RequestPerms")
	net.SendToServer()
end)