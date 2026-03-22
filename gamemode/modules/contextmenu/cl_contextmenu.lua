local _panel  = nil
local _isOpen = false

local MENU_ITEMS = {
	{
		label = "Vue 3ème Personne",
		icon  = "◉",
		color = "accent",
		action = function()
			gTPOpenSettings()
		end,
	},
	{
		label  = "Logs Serveur",
		icon   = "☰",
		color  = "accent",
		action = function()
			gLogsOpenPanel()
		end,
	},
	{
		label  = "Tous les warns",
		icon   = "⚠",
		color  = "warning",
		action = function()
			gWarnsOpenAllPanel()
		end,
	},
	{
		label  = "Panneau Admin",
		icon   = "★",
		color  = "warning",
		action = function()
			net.Start("gAdmin.RequestPerms")
			net.SendToServer()
		end,
	},
}

-- ── Open / Close ─────────────────────────────────────────

local function gContextOpen()
	if _isOpen then return end
	_isOpen = true

	if IsValid(_panel) then _panel:Remove() end

	local W, H     = 260, 50 + #MENU_ITEMS * 48
	local HEADER_H = 36
	local PAD      = 10
	local hc       = gTheme("surface")

	_panel = vgui.Create("gFrame")
	_panel:gSetSize(W, H)
	_panel:gCenter()
	_panel:gSetRadius(gThemeRadius("lg"))
	_panel:gSetBgColor(gTheme("bg"), gThemeAlpha("full"))
	_panel:gSetHeader(true, hc, gThemeAlpha("high"), HEADER_H)
	_panel:gSetTitle("ALL FOR ONE", "OxaniumSemiBold", 13, gContrastText(hc), TEXT_ALIGN_CENTER)
	_panel:gSetCloseButton(true, "OxaniumLight", 16, gContrastText(hc, 140))
	_panel:gSetDraggable(false)
	_panel:gSetBorder(true, gThemeAlpha("border"))
	_panel:SetDeleteOnClose(false)

	_panel.gClose = function(self, dur, cb)
		self:gFadeOut(dur or 0.1, 0, function()
			self:SetVisible(false)
			_isOpen = false
			gui.EnableScreenClicker(false)
			if cb then cb() end
		end)
	end

	local body = vgui.Create("DPanel", _panel)
	body:SetPaintBackground(false)
	body:SetPos(0, gRespY(HEADER_H))
	body:SetSize(gRespX(W), gRespY(H - HEADER_H))
	body:DockPadding(gRespX(PAD), gRespY(PAD), gRespX(PAD), gRespY(PAD))

	for i, item in ipairs(MENU_ITEMS) do
		local btnColor = gTheme(item.color or "elevated")

		local btn = vgui.Create("gButton", body)
		btn:Dock(TOP)
		btn:SetTall(gRespY(38))
		if i > 1 then btn:DockMargin(0, gRespY(6), 0, 0) end
		btn:gSetBgColor(btnColor, 30)
		btn:gSetText(item.icon .. "  " .. item.label, "OxaniumMedium", 13, gTheme("text"))
		btn:gSetBorder(true, btnColor, 40)
		btn:gSetRadius(gThemeRadius("sm"))

		local action = item.action
		btn.DoClick = function()
			if IsValid(_panel) then
				_panel:gClose(0.1, function()
					action()
				end)
			end
		end
	end

	_panel:gOpen(0.12)
	gui.EnableScreenClicker(true)
end

local function gContextClose()
	if not _isOpen then return end

	if IsValid(_panel) then
		_panel:gClose(0.1)
	else
		_isOpen = false
		gui.EnableScreenClicker(false)
	end
end

local function gContextToggle()
	if _isOpen then
		gContextClose()
	else
		gContextOpen()
	end
end

-- ── Bind hook ────────────────────────────────────────────

hook.Add("PlayerBindPress", "gContext.Bind", function(ply, bind, pressed)
	if bind == "+menu_context" and pressed then
		gContextToggle()
		return true
	end
end)

print("modules/contextmenu/cl_contextmenu.lua | LOAD !")
