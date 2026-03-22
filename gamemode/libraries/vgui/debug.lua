local _panels = {}

local function gVGUIKill(name)
	if IsValid(_panels[name]) then
		_panels[name]:Remove()
		_panels[name] = nil
	end
end

concommand.Add("g_vgui_close_all", function()
	for name in pairs(_panels) do
		gVGUIKill(name)
	end
end)

-- =========================================================
-- gFrame + gPanel + gLabel
-- =========================================================
concommand.Add("g_test_vgui", function()
	if IsValid(_panels["canvas"]) then
		gVGUIKill("canvas")
		return
	end

	local h = gTheme("elevated")

	local canvas = vgui.Create("gFrame")
	canvas:gSetSize(1920, 1080)
	canvas:gCenter()
	canvas:gSetRadius(0)
	canvas:gSetBgColor(gTheme("bg"), 252)
	canvas:gSetHeader(true, h, 252)
	canvas:gSetTitle("VGUI Debug Canvas", "OxaniumMedium", 14, gContrastText(h), TEXT_ALIGN_CENTER)
	canvas:gSetCloseButton(true, "OxaniumExtraLight", 22, gContrastText(h, 140))
	canvas:gSetDraggable(false)
	canvas:gOpen(0.15)

	_panels["canvas"] = canvas

	-- gFrame variants
	local frameConfigs = {
		{ title = "Default",       header = gTheme("surface") },
		{ title = "Accent",        header = gTheme("accent")  },
		{ title = "Succès",        header = gTheme("success") },
		{ title = "Erreur",        header = gTheme("danger")  },
		{ title = "Avertissement", header = gTheme("warning") },
	}

	local fW   = 200
	local fH   = 120
	local fPad = 12
	local fY   = 40 + 24

	for i, cfg in ipairs(frameConfigs) do
		local f = vgui.Create("gFrame", canvas)
		f:gSetSize(fW, fH)
		f:gSetPos(24 + (i - 1) * (fW + fPad), fY)
		f:gSetRadius(gThemeRadius("sm"))
		f:gSetBgColor(gTheme("bg"), 248)
		f:gSetHeader(true, cfg.header, 255, 36)
		f:gSetTitle(cfg.title, "OxaniumMedium", 13, gContrastText(cfg.header), TEXT_ALIGN_CENTER)
		f:gSetCloseButton(true, "OxaniumLight", 16, gContrastText(cfg.header, 160))
		f:gSetBorder(true, 12)
		f:gSetDraggable(false)
	end

	-- gPanel variants
	local panelConfigs = {
		{ label = "Surface",     bg = gTheme("surface"),  alpha = 245 },
		{ label = "Elevated",    bg = gTheme("elevated"), alpha = 245 },
		{ label = "Accent",      bg = gTheme("accent"),   alpha = 255 },
		{ label = "Success",     bg = gTheme("success"),  alpha = 255 },
		{ label = "Danger",      bg = gTheme("danger"),   alpha = 255 },
		{ label = "Warning",     bg = gTheme("warning"),  alpha = 255 },
		{ label = "Border only", bg = gTheme("bg"),       alpha = 0,   border = true },
		{ label = "TL / BR",     bg = gTheme("elevated"), alpha = 245, corners = { tl = true,  tr = false, bl = false, br = true  } },
		{ label = "TR / BL",     bg = gTheme("elevated"), alpha = 245, corners = { tl = false, tr = true,  bl = true,  br = false } },
	}

	local pW    = 168
	local pH    = 76
	local pPad  = 10
	local pCols = 5
	local pOffY = 40 + 24 + fH + 24

	for i, cfg in ipairs(panelConfigs) do
		local col = (i - 1) % pCols
		local row = math.floor((i - 1) / pCols)

		local p = vgui.Create("gPanel", canvas)
		p:gSetSize(pW, pH)
		p:gSetPos(24 + col * (pW + pPad), pOffY + row * (pH + pPad))
		p:gSetBgColor(cfg.bg, cfg.alpha)
		p:gSetRadius(gThemeRadius("sm"))

		if cfg.border then
			p:gSetBorder(true, gTheme("border"), 40)
		end

		if cfg.corners then
			p:gSetCorners(cfg.corners.tl, cfg.corners.tr, cfg.corners.bl, cfg.corners.br)
		end

		local lbl = vgui.Create("gLabel", p)
		lbl:gSetSize(pW - 8, 18)
		lbl:gSetPos(4, (pH - 18) * 0.5)
		lbl:gSetText(cfg.label)
		lbl:gSetFont("OxaniumMedium", 12)
		lbl:gSetColor(gContrastText(cfg.bg))
		lbl:gSetAlign(TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	-- gLabel variants
	local labelConfigs = {
		{ text = "OxaniumExtraLight — 13", font = "OxaniumExtraLight", size = 13, color = gTheme("text")     },
		{ text = "OxaniumLight — 13",      font = "OxaniumLight",      size = 13, color = gTheme("text")     },
		{ text = "OxaniumRegular — 13",    font = "OxaniumRegular",    size = 13, color = gTheme("text")     },
		{ text = "OxaniumMedium — 13",     font = "OxaniumMedium",     size = 13, color = gTheme("text")     },
		{ text = "OxaniumSemiBold — 13",   font = "OxaniumSemiBold",   size = 13, color = gTheme("text")     },
		{ text = "OxaniumBold — 13",       font = "OxaniumBold",       size = 13, color = gTheme("text")     },
		{ text = "OxaniumExtraBold — 13",  font = "OxaniumExtraBold",  size = 13, color = gTheme("text")     },
		{ text = "textDim — Regular",      font = "OxaniumRegular",    size = 13, color = gTheme("textDim")  },
		{ text = "textMute — Regular",     font = "OxaniumRegular",    size = 13, color = gTheme("textMute") },
		{ text = "Success color",          font = "OxaniumMedium",     size = 13, color = gTheme("success")  },
		{ text = "Danger color",           font = "OxaniumMedium",     size = 13, color = gTheme("danger")   },
		{ text = "Warning color",          font = "OxaniumMedium",     size = 13, color = gTheme("warning")  },
		{ text = "Accent color",           font = "OxaniumMedium",     size = 13, color = gTheme("accent")   },
		{ text = "UPPERCASE AUTO",         font = "OxaniumSemiBold",   size = 11, color = gTheme("textDim"), upper = true },
	}

	local lbgW   = 320
	local lbgH   = 28
	local lbgPad = 6
	local lbgOffY = 40 + 24 + fH + 24 + math.ceil(#panelConfigs / pCols) * (pH + pPad) + 24

	local lbg = vgui.Create("gPanel", canvas)
	lbg:gSetSize(lbgW, #labelConfigs * lbgH + lbgPad * 2)
	lbg:gSetPos(24, lbgOffY)
	lbg:gSetBgColor(gTheme("surface"), 240)
	lbg:gSetRadius(gThemeRadius("sm"))
	lbg:gSetBorder(true, gTheme("border"), 15)

	for i, cfg in ipairs(labelConfigs) do
		local lbl = vgui.Create("gLabel", lbg)
		lbl:gSetSize(lbgW - lbgPad * 2, lbgH)
		lbl:gSetPos(lbgPad, lbgPad + (i - 1) * lbgH)
		lbl:gSetFont(cfg.font, cfg.size)
		lbl:gSetColor(cfg.color)
		lbl:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		lbl:gSetUppercase(cfg.upper or false)
		lbl:gSetText(cfg.text)
	end
end)

-- =========================================================
-- gButton
-- =========================================================
concommand.Add("g_test_vgui_buttons", function()
	if IsValid(_panels["canvasBtn"]) then
		gVGUIKill("canvasBtn")
		return
	end

	local h = gTheme("elevated")

	local canvas = vgui.Create("gFrame")
	canvas:gSetSize(1920, 1080)
	canvas:gCenter()
	canvas:gSetRadius(0)
	canvas:gSetBgColor(gTheme("bg"), 252)
	canvas:gSetHeader(true, h, 252)
	canvas:gSetTitle("gButton Showcase", "OxaniumMedium", 14, gContrastText(h), TEXT_ALIGN_CENTER)
	canvas:gSetCloseButton(true, "OxaniumExtraLight", 22, gContrastText(h, 140))
	canvas:gSetDraggable(false)
	canvas:gOpen(0.15)

	_panels["canvasBtn"] = canvas

	local pad  = 24
	local bW   = 180
	local bH   = 42
	local bPad = 12
	local offY = 40 + pad

	local buttonConfigs = {
		{ label = "Default",     bg = gTheme("elevated"), tc = nil                                     },
		{ label = "Accent",      bg = gTheme("accent"),   tc = gContrastText(gTheme("accent"))         },
		{ label = "Success",     bg = gTheme("success"),  tc = gContrastText(gTheme("success"))        },
		{ label = "Danger",      bg = gTheme("danger"),   tc = gContrastText(gTheme("danger"))         },
		{ label = "Warning",     bg = gTheme("warning"),  tc = gContrastText(gTheme("warning"))        },
		{ label = "Border only", bg = gTheme("bg"),       tc = gTheme("text"),     border = true       },
		{ label = "Disabled",    bg = gTheme("elevated"), tc = nil,                disabled = true     },
		{ label = "Radius LG",   bg = gTheme("accent"),   tc = gContrastText(gTheme("accent")), radius = "lg" },
		{ label = "TL / BR",     bg = gTheme("elevated"), tc = nil,
			corners = { tl = true, tr = false, bl = false, br = true }                                 },
	}

	for i, cfg in ipairs(buttonConfigs) do
		local col = (i - 1) % 5
		local row = math.floor((i - 1) / 5)

		local btn = vgui.Create("gButton", canvas)
		btn:gSetSize(bW, bH)
		btn:gSetPos(pad + col * (bW + bPad), offY + row * (bH + bPad))
		btn:gSetBgColor(cfg.bg, 248)
		btn:gSetText(cfg.label, "OxaniumMedium", 13, cfg.tc)

		if cfg.radius then
			btn:gSetRadius(gThemeRadius(cfg.radius))
		end

		if cfg.border then
			btn:gSetBorder(true, gTheme("border"), 35)
		end

		if cfg.corners then
			btn:gSetCorners(cfg.corners.tl, cfg.corners.tr, cfg.corners.bl, cfg.corners.br)
		end

		if cfg.disabled then
			btn:gSetDisabled(true)
		end

		btn.DoClick = function()
			print("[gButton] Clicked: " .. cfg.label)
		end
	end
end)

-- =========================================================
-- gTextEntry
-- =========================================================
concommand.Add("g_test_vgui_inputs", function()
	if IsValid(_panels["canvasInputs"]) then
		gVGUIKill("canvasInputs")
		return
	end

	local h = gTheme("elevated")

	local canvas = vgui.Create("gFrame")
	canvas:gSetSize(1920, 1080)
	canvas:gCenter()
	canvas:gSetRadius(0)
	canvas:gSetBgColor(gTheme("bg"), 252)
	canvas:gSetHeader(true, h, 252)
	canvas:gSetTitle("gTextEntry Showcase", "OxaniumMedium", 14, gContrastText(h), TEXT_ALIGN_CENTER)
	canvas:gSetCloseButton(true, "OxaniumExtraLight", 22, gContrastText(h, 140))
	canvas:gSetDraggable(false)
	canvas:gOpen(0.15)

	_panels["canvasInputs"] = canvas

	local pad   = 24
	local eW    = 300
	local eH    = 38
	local ePadX = 16
	local ePadY = 44
	local offY  = 40 + pad

	local entryConfigs = {
		{
			label       = "Default",
			placeholder = "Écrivez quelque chose...",
			state       = "default",
		},
		{
			label       = "State Success",
			placeholder = "Champ valide",
			state       = "success",
		},
		{
			label       = "State Danger",
			placeholder = "Champ en erreur",
			state       = "danger",
		},
		{
			label       = "State Warning",
			placeholder = "Attention requise",
			state       = "warning",
		},
		{
			label       = "Radius LG",
			placeholder = "Coins arrondis lg",
			state       = "default",
			radius      = "lg",
		},
		{
			label       = "Désactivé",
			placeholder = "Non éditable",
			state       = "default",
			disabled    = true,
		},
		{
			label       = "Align Center",
			placeholder = "Texte centré",
			state       = "default",
			align       = TEXT_ALIGN_CENTER,
		},
		{
			label       = "Align Right",
			placeholder = "Texte droite",
			state       = "default",
			align       = TEXT_ALIGN_RIGHT,
		},
		{
			label       = "Font Bold 15",
			placeholder = "Police lourde",
			state       = "default",
			font        = "OxaniumBold",
			size        = 15,
		},
		{
			label       = "Padding custom",
			placeholder = "Padding X = 24",
			state       = "default",
			padX        = 24,
		},
		{
			label       = "Couleur accent",
			placeholder = "Texte en accent",
			state       = "default",
			textColor   = gTheme("accent"),
		},
		{
			label       = "Border custom",
			placeholder = "Bordure success",
			state       = "default",
			border      = { color = gTheme("success"), alpha = 160 },
		},
	}

	for i, cfg in ipairs(entryConfigs) do
		local col = (i - 1) % 3
		local row = math.floor((i - 1) / 3)

		local px = pad + col * (eW + ePadX)
		local py = offY + row * (eH + ePadY)

		local lbl = vgui.Create("gLabel", canvas)
		lbl:gSetSize(eW, 16)
		lbl:gSetPos(px, py)
		lbl:gSetFont("OxaniumMedium", 11)
		lbl:gSetColor(gTheme("textDim"))
		lbl:gSetText(cfg.label)

		local e = vgui.Create("gTextEntry", canvas)
		e:gSetSize(eW, eH)
		e:gSetPos(px, py + 18)
		e:gSetPlaceholder(cfg.placeholder)
		e:gSetFont(cfg.font or "OxaniumRegular", cfg.size or 13)
		e:gSetState(cfg.state)

		if cfg.padX then
			e:gSetPadding(cfg.padX)
		end

		if cfg.align then
			e:gSetAlign(cfg.align)
		end

		if cfg.radius then
			e:gSetRadius(gThemeRadius(cfg.radius))
		end

		if cfg.disabled then
			e:gSetDisabled(true)
		end

		if cfg.textColor then
			e:gSetTextColor(cfg.textColor)
		end

		if cfg.border then
			e:gSetBorder(true, cfg.border.color, cfg.border.alpha)
		end
	end
end)

-- =========================================================
-- gCheckBox
-- =========================================================
concommand.Add("g_test_vgui_checkbox", function()
	if IsValid(_panels["canvasCheckBox"]) then
		gVGUIKill("canvasCheckBox")
		return
	end

	local h = gTheme("elevated")

	local canvas = vgui.Create("gFrame")
	canvas:gSetSize(1920, 1080)
	canvas:gCenter()
	canvas:gSetRadius(0)
	canvas:gSetBgColor(gTheme("bg"), 252)
	canvas:gSetHeader(true, h, 252)
	canvas:gSetTitle("gCheckBox Showcase", "OxaniumMedium", 14, gContrastText(h), TEXT_ALIGN_CENTER)
	canvas:gSetCloseButton(true, "OxaniumExtraLight", 22, gContrastText(h, 140))
	canvas:gSetDraggable(false)
	canvas:gOpen(0.15)

	_panels["canvasCheckBox"] = canvas

	local pad  = 24
	local cbS  = 22
	local offY = 40 + pad

	local configs = {
		{ label = "Default",          state = "default",  checked = false },
		{ label = "Pre-checked",      state = "default",  checked = true  },
		{ label = "State Accent",     state = "accent",   checked = false },
		{ label = "State Success",    state = "success",  checked = false },
		{ label = "State Danger",     state = "danger",   checked = false },
		{ label = "State Warning",    state = "warning",  checked = false },
		{ label = "Radius LG",        state = "default",  checked = false, radius = "lg" },
		{ label = "Disabled off",     state = "default",  checked = false, disabled = true },
		{ label = "Disabled on",      state = "accent",   checked = true,  disabled = true },
		{ label = "Custom color",     state = "default",  checked = false, checkColor = gTheme("danger") },
		{ label = "Size 28",          state = "accent",   checked = false, size = 28 },
		{ label = "No border",        state = "accent",   checked = false, border = false },
	}

	local cols  = 4
	local itemW = 220
	local itemH = 32
	local itemP = 12

	for i, cfg in ipairs(configs) do
		local col = (i - 1) % cols
		local row = math.floor((i - 1) / cols)
		local px  = pad + col * (itemW + itemP)
		local py  = offY + row * (itemH + itemP)
		local s   = cfg.size or cbS

		local cb = vgui.Create("gCheckBox", canvas)
		cb:gSetSize(s, s)
		cb:gSetPos(px, py + (itemH - s) * 0.5)
		cb:gSetChecked(cfg.checked)
		cb:gSetState(cfg.state)

		if cfg.radius then
			cb:gSetRadius(gThemeRadius(cfg.radius))
		end

		if cfg.disabled then
			cb:gSetDisabled(true)
		end

		if cfg.checkColor then
			cb:gSetCheckColor(cfg.checkColor)
		end

		if cfg.border == false then
			cb:gSetBorder(false)
		end

		cb.OnChange = function(self, checked)
			print("[gCheckBox] " .. cfg.label .. " → " .. tostring(checked))
		end

		local lbl = vgui.Create("gLabel", canvas)
		lbl:gSetSize(itemW - s - 10, itemH)
		lbl:gSetPos(px + s + 8, py)
		lbl:gSetFont("OxaniumRegular", 13)
		lbl:gSetColor(cfg.disabled and gTheme("textMute") or gTheme("text"))
		lbl:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		lbl:gSetText(cfg.label)
	end
end)