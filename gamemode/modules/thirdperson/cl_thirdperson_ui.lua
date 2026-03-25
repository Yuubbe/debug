local _settingsPanel = nil

local SETTINGS = {
	{ key = "distance",  label = "Distance",    get = gTPGetDistance,  set = gTPSetDistance,  step = 5,   min = 20,   max = 500 },
	{ key = "right",     label = "Décalage X",  get = gTPGetRight,    set = gTPSetRight,     step = 5,   min = -150, max = 150 },
	{ key = "up",        label = "Décalage Y",  get = gTPGetUp,       set = gTPSetUp,        step = 2,   min = -100, max = 100 },
	{ key = "fov",       label = "FOV",         get = gTPGetFOV,      set = gTPSetFOV,       step = 5,   min = 0,    max = 150 },
	{ key = "smooth",    label = "Lissage",     get = gTPGetSmooth,   set = gTPSetSmooth,    step = 1,   min = 1,    max = 30 },
}

-- ── Number row builder ───────────────────────────────────

local function gTPBuildNumberRow(parent, cfg)
	local row = vgui.Create("DPanel", parent)
	row:SetPaintBackground(false)
	row:Dock(TOP)
	row:DockMargin(0, gRespY(3), 0, 0)
	row:SetTall(gRespY(30))

	local lbl = vgui.Create("gLabel", row)
	lbl:SetPos(0, 0)
	lbl:SetSize(gRespX(90), gRespY(30))
	lbl:gSetFont("OxaniumRegular", 12)
	lbl:gSetColor(gTheme("textDim"))
	lbl:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	lbl:gSetText(cfg.label)

	local te = vgui.Create("gTextEntry", row)
	te:SetPos(gRespX(92), 0)
	te:SetSize(gRespX(80), gRespY(28))
	te:gSetFont("OxaniumRegular", 12)
	te:gSetAlign(TEXT_ALIGN_CENTER)
	te:gSetPlaceholder(tostring(cfg.get()))
	te:SetValue(tostring(cfg.get()))

	local function applyValue(val)
		val = math.Clamp(tonumber(val) or cfg.get(), cfg.min, cfg.max)
		cfg.set(val)
		te:SetValue(tostring(val))
	end

	te.OnEnter = function()
		applyValue(te:GetValue())
	end

	local btnMinus = vgui.Create("gButton", row)
	btnMinus:SetPos(gRespX(178), 0)
	btnMinus:gSetSize(28, 28)
	btnMinus:gSetBgColor(gTheme("elevated"), gThemeAlpha("mid"))
	btnMinus:gSetText("−", "OxaniumMedium", 14)
	btnMinus:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))
	btnMinus.DoClick = function()
		applyValue(cfg.get() - cfg.step)
	end

	local btnPlus = vgui.Create("gButton", row)
	btnPlus:SetPos(gRespX(210), 0)
	btnPlus:gSetSize(28, 28)
	btnPlus:gSetBgColor(gTheme("elevated"), gThemeAlpha("mid"))
	btnPlus:gSetText("+", "OxaniumMedium", 14)
	btnPlus:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))
	btnPlus.DoClick = function()
		applyValue(cfg.get() + cfg.step)
	end

	return te
end

-- ── Settings panel ───────────────────────────────────────

function gTPOpenSettings()
	if IsValid(_settingsPanel) then
		_settingsPanel:Remove()
		return
	end

	local W, H = 320, 380
	local HEADER_H = 36
	local PAD = 12

	local hc = gTheme("surface")

	_settingsPanel = vgui.Create("gFrame")
	_settingsPanel:gSetSize(W, H)
	_settingsPanel:gCenter()
	_settingsPanel:gSetRadius(gThemeRadius("lg"))
	_settingsPanel:gSetBgColor(gTheme("bg"), gThemeAlpha("full"))
	_settingsPanel:gSetHeader(true, hc, gThemeAlpha("high"), HEADER_H)
	_settingsPanel:gSetTitle("Vue 3ème Personne", "OxaniumMedium", 13, gContrastText(hc), TEXT_ALIGN_CENTER)
	_settingsPanel:gSetCloseButton(true, "OxaniumLight", 18, gContrastText(hc, 160))
	_settingsPanel:gSetDraggable(true)
	_settingsPanel:gSetBorder(true, gThemeAlpha("border"))
	_settingsPanel:gOpen(0.15)

	local body = vgui.Create("DPanel", _settingsPanel)
	body:SetPaintBackground(false)
	body:SetPos(0, gRespY(HEADER_H))
	body:SetSize(gRespX(W), gRespY(H - HEADER_H))
	body:DockPadding(gRespX(PAD), gRespY(PAD), gRespX(PAD), gRespY(PAD))

	-- ── Enable toggle ────────────────────────────────────

	local toggleRow = vgui.Create("DPanel", body)
	toggleRow:SetPaintBackground(false)
	toggleRow:Dock(TOP)
	toggleRow:SetTall(gRespY(28))

	local cb = vgui.Create("gCheckBox", toggleRow)
	cb:SetPos(0, gRespY(3))
	cb:gSetSize(20, 20)
	cb:gSetChecked(gTPGetEnabled())
	cb:gSetState("accent")

	local cbLbl = vgui.Create("gLabel", toggleRow)
	cbLbl:SetPos(gRespX(28), 0)
	cbLbl:SetSize(gRespX(200), gRespY(28))
	cbLbl:gSetFont("OxaniumMedium", 13)
	cbLbl:gSetColor(gTheme("text"))
	cbLbl:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	cbLbl:gSetText("Activer la 3ème personne")

	cb.OnChange = function(_, checked)
		gTPSetEnabled(checked)
	end

	-- ── Separator ────────────────────────────────────────

	local sep = vgui.Create("DPanel", body)
	sep:SetPaintBackground(false)
	sep:Dock(TOP)
	sep:SetTall(gRespY(6))
	function sep:Paint(w, h)
		local bc = gTheme("border")
		surface.SetDrawColor(bc.r, bc.g, bc.b, gThemeAlpha("sep"))
		surface.DrawLine(0, math.floor(h * 0.5), w, math.floor(h * 0.5))
	end

	-- ── Number settings ──────────────────────────────────

	local _textEntries = {}
	for _, cfg in ipairs(SETTINGS) do
		_textEntries[cfg.key] = gTPBuildNumberRow(body, cfg)
	end

	-- ── Collision toggle ─────────────────────────────────

	local sep2 = vgui.Create("DPanel", body)
	sep2:SetPaintBackground(false)
	sep2:Dock(TOP)
	sep2:SetTall(gRespY(8))

	local collRow = vgui.Create("DPanel", body)
	collRow:SetPaintBackground(false)
	collRow:Dock(TOP)
	collRow:SetTall(gRespY(28))

	local collCb = vgui.Create("gCheckBox", collRow)
	collCb:SetPos(0, gRespY(3))
	collCb:gSetSize(20, 20)
	collCb:gSetChecked(gTPGetCollision())
	collCb:gSetState("accent")

	local collLbl = vgui.Create("gLabel", collRow)
	collLbl:SetPos(gRespX(28), 0)
	collLbl:SetSize(gRespX(200), gRespY(28))
	collLbl:gSetFont("OxaniumRegular", 12)
	collLbl:gSetColor(gTheme("text"))
	collLbl:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	collLbl:gSetText("Collision murale")

	collCb.OnChange = function(_, checked)
		gTPSetCollision(checked)
	end

	-- ── Reset button ─────────────────────────────────────

	local sep3 = vgui.Create("DPanel", body)
	sep3:SetPaintBackground(false)
	sep3:Dock(TOP)
	sep3:SetTall(gRespY(10))

	local resetBtn = vgui.Create("gButton", body)
	resetBtn:Dock(TOP)
	resetBtn:SetTall(gRespY(30))
	resetBtn:gSetBgColor(gTheme("elevated"), gThemeAlpha("mid"))
	resetBtn:gSetText("Réinitialiser", "OxaniumMedium", 12)
	resetBtn:gSetBorder(true, gTheme("border"), gThemeAlpha("border"))

	resetBtn.DoClick = function()
		gTPReset()
		cb:gSetChecked(gTPGetEnabled())
		collCb:gSetChecked(gTPGetCollision())
		for _, cfg in ipairs(SETTINGS) do
			if IsValid(_textEntries[cfg.key]) then
				_textEntries[cfg.key]:SetValue(tostring(cfg.get()))
			end
		end
	end
end

print("modules/thirdperson/cl_thirdperson_ui.lua | LOAD !")
