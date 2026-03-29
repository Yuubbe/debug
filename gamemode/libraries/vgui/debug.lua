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

-- =========================================================
-- gComboBox
-- =========================================================
concommand.Add("g_test_vgui_combobox", function()
	if IsValid(_panels["canvasCombo"]) then
		gVGUIKill("canvasCombo")
		return
	end

	local h = gTheme("elevated")

	local canvas = vgui.Create("gFrame")
	canvas:gSetSize(1920, 1080)
	canvas:gCenter()
	canvas:gSetRadius(0)
	canvas:gSetBgColor(gTheme("bg"), 252)
	canvas:gSetHeader(true, h, 252)
	canvas:gSetTitle("gComboBox Showcase", "OxaniumMedium", 14, gContrastText(h), TEXT_ALIGN_CENTER)
	canvas:gSetCloseButton(true, "OxaniumExtraLight", 22, gContrastText(h, 140))
	canvas:gSetDraggable(false)
	canvas:gOpen(0.15)

	_panels["canvasCombo"] = canvas

	local pad   = 24
	local cW    = 280
	local cH    = 38
	local cPadX = 16
	local cPadY = 48
	local offY  = 40 + pad

	local jobs = { "Citoyen", "Policier", "Médecin", "Pompier", "Mécanicien", "Maire" }

	local configs = {
		{ label = "Default",           items = jobs                                              },
		{ label = "Pré-sélectionné",   items = jobs,    selected = 3                             },
		{ label = "Placeholder custom",items = jobs,    placeholder = "Choisir un métier..."     },
		{ label = "Radius LG",         items = jobs,    radius = "lg"                            },
		{ label = "Font Bold",         items = jobs,    font = "OxaniumBold",   size = 13        },
		{ label = "Désactivé",         items = jobs,    disabled = true                          },
		{ label = "Couleur texte",     items = jobs,    textColor = gTheme("accent")             },
		{ label = "Padding 20",        items = jobs,    padX = 20                                },
	}

	for i, cfg in ipairs(configs) do
		local col = (i - 1) % 3
		local row = math.floor((i - 1) / 3)
		local px  = pad + col * (cW + cPadX)
		local py  = offY + row * (cH + cPadY)

		local lbl = vgui.Create("gLabel", canvas)
		lbl:gSetSize(cW, 16)
		lbl:gSetPos(px, py)
		lbl:gSetFont("OxaniumMedium", 11)
		lbl:gSetColor(gTheme("textDim"))
		lbl:gSetText(cfg.label)

		local cb = vgui.Create("gComboBox", canvas)
		cb:gSetSize(cW, cH)
		cb:gSetPos(px, py + 18)
		cb:gSetItems(cfg.items)
		cb:gSetFont(cfg.font or "OxaniumRegular", cfg.size or 13)

		if cfg.placeholder then cb:gSetPlaceholder(cfg.placeholder) end
		if cfg.radius      then cb:gSetRadius(gThemeRadius(cfg.radius)) end
		if cfg.disabled    then cb:gSetDisabled(true) end
		if cfg.textColor   then cb:gSetTextColor(cfg.textColor) end
		if cfg.padX        then cb:gSetPadding(cfg.padX) end
		if cfg.selected    then cb:gSetSelected(cfg.selected) end

		cb.OnSelect = function(_, idx, label, value)
			print("[gComboBox] " .. cfg.label .. " → #" .. idx .. " " .. label)
		end
	end
end)

-- =========================================================
-- gNumSlider
-- =========================================================
concommand.Add("g_test_vgui_slider", function()
	if IsValid(_panels["canvasSlider"]) then
		gVGUIKill("canvasSlider")
		return
	end

	local h = gTheme("elevated")

	local canvas = vgui.Create("gFrame")
	canvas:gSetSize(1920, 1080)
	canvas:gCenter()
	canvas:gSetRadius(0)
	canvas:gSetBgColor(gTheme("bg"), 252)
	canvas:gSetHeader(true, h, 252)
	canvas:gSetTitle("gNumSlider Showcase", "OxaniumMedium", 14, gContrastText(h), TEXT_ALIGN_CENTER)
	canvas:gSetCloseButton(true, "OxaniumExtraLight", 22, gContrastText(h, 140))
	canvas:gSetDraggable(false)
	canvas:gOpen(0.15)

	_panels["canvasSlider"] = canvas

	local pad   = 24
	local sW    = 340
	local sH    = 36
	local sPadX = 16
	local sPadY = 48
	local offY  = 40 + pad

	local configs = {
		{ label = "Default (0-100)",       min = 0,   max = 100,  step = 1,   value = 40                          },
		{ label = "Step 5",                min = 0,   max = 100,  step = 5,   value = 50                          },
		{ label = "Décimales (0.0-1.0)",   min = 0,   max = 1,    step = 0.1, value = 0.3                         },
		{ label = "Couleur fill Success",  min = 0,   max = 100,  step = 1,   value = 70, fill = gTheme("success") },
		{ label = "Couleur fill Danger",   min = 0,   max = 100,  step = 1,   value = 25, fill = gTheme("danger")  },
		{ label = "Couleur fill Warning",  min = 0,   max = 100,  step = 1,   value = 55, fill = gTheme("warning") },
		{ label = "Sans valeur affichée",  min = 0,   max = 100,  step = 1,   value = 60, noValue = true           },
		{ label = "Désactivé",             min = 0,   max = 100,  step = 1,   value = 45, disabled = true          },
		{ label = "Track épais",           min = 0,   max = 100,  step = 1,   value = 80, trackH = 8               },
	}

	for i, cfg in ipairs(configs) do
		local col = (i - 1) % 2
		local row = math.floor((i - 1) / 2)
		local px  = pad + col * (sW + sPadX)
		local py  = offY + row * (sH + sPadY)

		local lbl = vgui.Create("gLabel", canvas)
		lbl:gSetSize(sW, 16)
		lbl:gSetPos(px, py)
		lbl:gSetFont("OxaniumMedium", 11)
		lbl:gSetColor(gTheme("textDim"))
		lbl:gSetText(cfg.label)

		local s = vgui.Create("gNumSlider", canvas)
		s:gSetSize(sW, sH)
		s:gSetPos(px, py + 18)
		s:gSetRange(cfg.min, cfg.max)
		s:gSetStep(cfg.step)
		s:gSetValue(cfg.value)

		if cfg.fill      then s:gSetFillColor(cfg.fill) end
		if cfg.noValue   then s:gSetShowValue(false) end
		if cfg.disabled  then s:gSetDisabled(true) end
		if cfg.trackH    then s:gSetTrackHeight(cfg.trackH) end

		s.OnChange = function(_, val)
			print("[gNumSlider] " .. cfg.label .. " → " .. tostring(val))
		end
	end
end)

-- =========================================================
-- gNumberWang
-- =========================================================
concommand.Add("g_test_vgui_numberwang", function()
	if IsValid(_panels["canvasNW"]) then
		gVGUIKill("canvasNW")
		return
	end

	local h = gTheme("elevated")

	local canvas = vgui.Create("gFrame")
	canvas:gSetSize(1920, 1080)
	canvas:gCenter()
	canvas:gSetRadius(0)
	canvas:gSetBgColor(gTheme("bg"), 252)
	canvas:gSetHeader(true, h, 252)
	canvas:gSetTitle("gNumberWang Showcase", "OxaniumMedium", 14, gContrastText(h), TEXT_ALIGN_CENTER)
	canvas:gSetCloseButton(true, "OxaniumExtraLight", 22, gContrastText(h, 140))
	canvas:gSetDraggable(false)
	canvas:gOpen(0.15)

	_panels["canvasNW"] = canvas

	local pad   = 24
	local nW    = 200
	local nH    = 38
	local nPadX = 16
	local nPadY = 48
	local offY  = 40 + pad

	local configs = {
		{ label = "Default (0-100)",     min = 0,   max = 100,  step = 1,   value = 50  },
		{ label = "Step 5",              min = 0,   max = 100,  step = 5,   value = 25  },
		{ label = "Décimales (0.0-1.0)", min = 0,   max = 1,    step = 0.1, value = 0.5 },
		{ label = "Sans limite",         min = nil, max = nil,  step = 1,   value = 0   },
		{ label = "Négatif (-50/50)",    min = -50, max = 50,   step = 1,   value = 0   },
		{ label = "Radius LG",           min = 0,   max = 100,  step = 1,   value = 10, radius = "lg" },
		{ label = "Font Bold",           min = 0,   max = 100,  step = 1,   value = 42, font = "OxaniumBold", size = 13 },
		{ label = "Couleur accent",      min = 0,   max = 100,  step = 1,   value = 7,  textColor = gTheme("accent") },
		{ label = "Désactivé",           min = 0,   max = 100,  step = 1,   value = 33, disabled = true },
	}

	for i, cfg in ipairs(configs) do
		local col = (i - 1) % 3
		local row = math.floor((i - 1) / 3)
		local px  = pad + col * (nW + nPadX)
		local py  = offY + row * (nH + nPadY)

		local lbl = vgui.Create("gLabel", canvas)
		lbl:gSetSize(nW, 16)
		lbl:gSetPos(px, py)
		lbl:gSetFont("OxaniumMedium", 11)
		lbl:gSetColor(gTheme("textDim"))
		lbl:gSetText(cfg.label)

		local n = vgui.Create("gNumberWang", canvas)
		n:gSetSize(nW, nH)
		n:gSetPos(px, py + 18)
		n:gSetStep(cfg.step)
		n:gSetValue(cfg.value)

		if cfg.min or cfg.max then n:gSetRange(cfg.min, cfg.max) end
		if cfg.radius    then n:gSetRadius(gThemeRadius(cfg.radius)) end
		if cfg.font      then n:gSetFont(cfg.font, cfg.size) end
		if cfg.textColor then n:gSetTextColor(cfg.textColor) end
		if cfg.disabled  then n:gSetDisabled(true) end

		n.OnChange = function(_, val)
			print("[gNumberWang] " .. cfg.label .. " → " .. tostring(val))
		end
	end
end)

-- =========================================================
-- gScrollPanel
-- =========================================================
concommand.Add("g_test_vgui_scroll", function()
	if IsValid(_panels["canvasScroll"]) then
		gVGUIKill("canvasScroll")
		return
	end

	local h = gTheme("elevated")

	local canvas = vgui.Create("gFrame")
	canvas:gSetSize(1920, 1080)
	canvas:gCenter()
	canvas:gSetRadius(0)
	canvas:gSetBgColor(gTheme("bg"), 252)
	canvas:gSetHeader(true, h, 252)
	canvas:gSetTitle("gScrollPanel Showcase", "OxaniumMedium", 14, gContrastText(h), TEXT_ALIGN_CENTER)
	canvas:gSetCloseButton(true, "OxaniumExtraLight", 22, gContrastText(h, 140))
	canvas:gSetDraggable(false)
	canvas:gOpen(0.15)

	_panels["canvasScroll"] = canvas

	local pad  = 24
	local offY = 40 + pad

	-- Scroll basique avec beaucoup de contenu
	local sp1 = vgui.Create("gScrollPanel", canvas)
	sp1:gSetSize(300, 320)
	sp1:gSetPos(pad, offY)
	sp1:gSetBgColor(gTheme("surface"), 245)
	sp1:gSetBorder(true, gTheme("border"), 15)
	sp1:gSetPadding(10, 8)

	for i = 1, 20 do
		local item = vgui.Create("gPanel", sp1:GetCanvas())
		item:gSetSize(280, 32)
		item:gSetPos(0, (i - 1) * (32 + 4))
		item:gSetBgColor(i % 2 == 0 and gTheme("elevated") or gTheme("surface"), 240)
		item:gSetRadius(gThemeRadius("sm"))

		local lbl = vgui.Create("gLabel", item)
		lbl:gSetSize(260, 32)
		lbl:gSetPos(8, 0)
		lbl:gSetFont("OxaniumRegular", 12)
		lbl:gSetColor(gTheme("text"))
		lbl:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		lbl:gSetText("Item #" .. i)
	end

	-- Scroll avec scrollbar colorée
	local sp2 = vgui.Create("gScrollPanel", canvas)
	sp2:gSetSize(300, 320)
	sp2:gSetPos(pad + 300 + pad, offY)
	sp2:gSetBgColor(gTheme("surface"), 245)
	sp2:gSetBorder(true, gTheme("border"), 15)
	sp2:gSetScrollbar(true, 6, gTheme("accent"))
	sp2:gSetPadding(10, 8)

	for i = 1, 20 do
		local colors = { gTheme("accent"), gTheme("success"), gTheme("danger"), gTheme("warning") }
		local item = vgui.Create("gPanel", sp2:GetCanvas())
		item:gSetSize(260, 32)
		item:gSetPos(0, (i - 1) * (32 + 4))
		item:gSetBgColor(colors[(i % 4) + 1], 40)
		item:gSetRadius(gThemeRadius("sm"))

		local lbl = vgui.Create("gLabel", item)
		lbl:gSetSize(240, 32)
		lbl:gSetPos(8, 0)
		lbl:gSetFont("OxaniumMedium", 12)
		lbl:gSetColor(colors[(i % 4) + 1])
		lbl:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		lbl:gSetText("Entrée " .. i)
	end

	-- Scroll sans scrollbar visible
	local sp3 = vgui.Create("gScrollPanel", canvas)
	sp3:gSetSize(300, 320)
	sp3:gSetPos(pad + (300 + pad) * 2, offY)
	sp3:gSetBgColor(gTheme("bg"), 245)
	sp3:gSetBorder(true, gTheme("border"), 15)
	sp3:gSetScrollbar(false)
	sp3:gSetPadding(10, 8)

	local lbl3 = vgui.Create("gLabel", canvas)
	lbl3:gSetSize(300, 18)
	lbl3:gSetPos(pad + (300 + pad) * 2, offY - 20)
	lbl3:gSetFont("OxaniumMedium", 11)
	lbl3:gSetColor(gTheme("textDim"))
	lbl3:gSetText("Sans scrollbar visible")

	for i = 1, 15 do
		local item = vgui.Create("gPanel", sp3:GetCanvas())
		item:gSetSize(260, 36)
		item:gSetPos(0, (i - 1) * (36 + 4))
		item:gSetBgColor(gTheme("elevated"), 245)
		item:gSetRadius(gThemeRadius("sm"))

		local lbl = vgui.Create("gLabel", item)
		lbl:gSetSize(240, 36)
		lbl:gSetPos(8, 0)
		lbl:gSetFont("OxaniumRegular", 12)
		lbl:gSetColor(gTheme("textDim"))
		lbl:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		lbl:gSetText("Ligne " .. i)
	end
end)

-- =========================================================
-- gIconLayout
-- =========================================================
concommand.Add("g_test_vgui_iconlayout", function()
	if IsValid(_panels["canvasIconLayout"]) then
		gVGUIKill("canvasIconLayout")
		return
	end

	local h = gTheme("elevated")

	local canvas = vgui.Create("gFrame")
	canvas:gSetSize(1920, 1080)
	canvas:gCenter()
	canvas:gSetRadius(0)
	canvas:gSetBgColor(gTheme("bg"), 252)
	canvas:gSetHeader(true, h, 252)
	canvas:gSetTitle("gIconLayout Showcase", "OxaniumMedium", 14, gContrastText(h), TEXT_ALIGN_CENTER)
	canvas:gSetCloseButton(true, "OxaniumExtraLight", 22, gContrastText(h, 140))
	canvas:gSetDraggable(false)
	canvas:gOpen(0.15)

	_panels["canvasIconLayout"] = canvas

	local pad  = 24
	local offY = 40 + pad
	local colors = {
		gTheme("accent"), gTheme("success"), gTheme("danger"),
		gTheme("warning"), gTheme("surface"), gTheme("elevated"),
	}

	-- Align LEFT
	local il1 = vgui.Create("gIconLayout", canvas)
	il1:gSetSize(560, 10)
	il1:gSetPos(pad, offY)
	il1:gSetBgColor(gTheme("surface"), 240)
	il1:gSetBorder(true, gTheme("border"), 15)
	il1:gSetItemSize(52, 52)
	il1:gSetPadding(8)
	il1:gSetSpacing(6)
	il1:gSetAlign(TEXT_ALIGN_LEFT)

	for i = 1, 12 do
		local p = vgui.Create("gPanel")
		p:gSetRadius(gThemeRadius("sm"))
		p:gSetBgColor(colors[(i % #colors) + 1], 220)
		local lbl = vgui.Create("gLabel", p)
		lbl:SetSize(52, 52)
		lbl:SetPos(0, 0)
		lbl:gSetFont("OxaniumMedium", 11)
		lbl:gSetColor(gContrastText(colors[(i % #colors) + 1]))
		lbl:gSetAlign(TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		lbl:gSetText(tostring(i))
		il1:gAddItem(p)
	end

	-- Align CENTER
	local il2 = vgui.Create("gIconLayout", canvas)
	il2:gSetSize(560, 10)
	il2:gSetPos(pad, offY + il1:GetTall() + pad)
	il2:gSetBgColor(gTheme("surface"), 240)
	il2:gSetBorder(true, gTheme("border"), 15)
	il2:gSetItemSize(52, 52)
	il2:gSetPadding(8)
	il2:gSetSpacing(6)
	il2:gSetAlign(TEXT_ALIGN_CENTER)

	for i = 1, 7 do
		local p = vgui.Create("gPanel")
		p:gSetRadius(gThemeRadius("sm"))
		p:gSetBgColor(colors[(i % #colors) + 1], 220)
		il2:gAddItem(p)
	end

	-- Taille items différente
	local il3 = vgui.Create("gIconLayout", canvas)
	il3:gSetSize(560, 10)
	il3:gSetPos(pad + 560 + pad, offY)
	il3:gSetBgColor(gTheme("surface"), 240)
	il3:gSetBorder(true, gTheme("border"), 15)
	il3:gSetItemSize(72, 40)
	il3:gSetPadding(10)
	il3:gSetSpacing(8, 6)

	for i = 1, 10 do
		local p = vgui.Create("gPanel")
		p:gSetRadius(gThemeRadius("sm"))
		p:gSetBgColor(colors[(i % #colors) + 1], 200)
		local lbl = vgui.Create("gLabel", p)
		lbl:SetSize(72, 40)
		lbl:SetPos(0, 0)
		lbl:gSetFont("OxaniumRegular", 11)
		lbl:gSetColor(gContrastText(colors[(i % #colors) + 1]))
		lbl:gSetAlign(TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		lbl:gSetText("Item " .. i)
		il3:gAddItem(p)
	end
end)

-- =========================================================
-- gListLayout
-- =========================================================
concommand.Add("g_test_vgui_listlayout", function()
	if IsValid(_panels["canvasListLayout"]) then
		gVGUIKill("canvasListLayout")
		return
	end

	local h = gTheme("elevated")

	local canvas = vgui.Create("gFrame")
	canvas:gSetSize(1920, 1080)
	canvas:gCenter()
	canvas:gSetRadius(0)
	canvas:gSetBgColor(gTheme("bg"), 252)
	canvas:gSetHeader(true, h, 252)
	canvas:gSetTitle("gListLayout Showcase", "OxaniumMedium", 14, gContrastText(h), TEXT_ALIGN_CENTER)
	canvas:gSetCloseButton(true, "OxaniumExtraLight", 22, gContrastText(h, 140))
	canvas:gSetDraggable(false)
	canvas:gOpen(0.15)

	_panels["canvasListLayout"] = canvas

	local pad  = 24
	local offY = 40 + pad

	-- Liste basique hauteur auto
	local ll1 = vgui.Create("gListLayout", canvas)
	ll1:gSetSize(320, 10)
	ll1:gSetPos(pad, offY)
	ll1:gSetBgColor(gTheme("surface"), 240)
	ll1:gSetBorder(true, gTheme("border"), 15)
	ll1:gSetPadding(8)
	ll1:gSetSpacing(4)

	for i = 1, 6 do
		local item = vgui.Create("gPanel")
		item:gSetSize(300, 36)
		item:gSetBgColor(gTheme("elevated"), 245)
		item:gSetRadius(gThemeRadius("sm"))
		local lbl = vgui.Create("gLabel", item)
		lbl:SetSize(300, 36)
		lbl:SetPos(8, 0)
		lbl:gSetFont("OxaniumRegular", 13)
		lbl:gSetColor(gTheme("text"))
		lbl:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		lbl:gSetText("Item #" .. i)
		ll1:gAddItem(item)
	end

	-- Liste avec stripes
	local ll2 = vgui.Create("gListLayout", canvas)
	ll2:gSetSize(320, 10)
	ll2:gSetPos(pad + 320 + pad, offY)
	ll2:gSetBgColor(gTheme("surface"), 240)
	ll2:gSetBorder(true, gTheme("border"), 15)
	ll2:gSetPadding(8)
	ll2:gSetSpacing(0)
	ll2:gSetStripes(true, gTheme("border"), 18)
	ll2:gSetItemHeight(36)

	local jobs = { "Citoyen", "Policier", "Médecin", "Pompier", "Mécanicien", "Maire", "Banquier", "Criminel" }
	for i, job in ipairs(jobs) do
		local item = vgui.Create("gPanel")
		item:gSetSize(300, 36)
		item:gSetBgColor(gTheme("surface"), 0)
		local lbl = vgui.Create("gLabel", item)
		lbl:SetSize(300, 36)
		lbl:SetPos(8, 0)
		lbl:gSetFont("OxaniumMedium", 12)
		lbl:gSetColor(gTheme("text"))
		lbl:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		lbl:gSetText(job)
		ll2:gAddItem(item)
	end

	-- Liste couleurs sémantiques + spacing large
	local ll3 = vgui.Create("gListLayout", canvas)
	ll3:gSetSize(320, 10)
	ll3:gSetPos(pad + (320 + pad) * 2, offY)
	ll3:gSetBorder(true, gTheme("border"), 15)
	ll3:gSetPadding(6)
	ll3:gSetSpacing(6)

	local entries = {
		{ text = "Connexion réussie",     color = gTheme("success") },
		{ text = "Erreur de chargement",  color = gTheme("danger")  },
		{ text = "Mise à jour dispo",     color = gTheme("warning") },
		{ text = "Module chargé",         color = gTheme("accent")  },
		{ text = "Déconnexion détectée",  color = gTheme("danger")  },
		{ text = "Sauvegarde complète",   color = gTheme("success") },
	}

	for _, entry in ipairs(entries) do
		local item = vgui.Create("gPanel")
		item:gSetSize(300, 32)
		item:gSetBgColor(entry.color, 20)
		item:gSetRadius(gThemeRadius("sm"))
		local lbl = vgui.Create("gLabel", item)
		lbl:SetSize(290, 32)
		lbl:SetPos(8, 0)
		lbl:gSetFont("OxaniumRegular", 12)
		lbl:gSetColor(entry.color)
		lbl:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		lbl:gSetText(entry.text)
		ll3:gAddItem(item)
	end
end)

-- =========================================================
-- gPropertySheet
-- =========================================================
concommand.Add("g_test_vgui_propertysheet", function()
	if IsValid(_panels["canvasPS"]) then
		gVGUIKill("canvasPS")
		return
	end

	local h = gTheme("elevated")

	local canvas = vgui.Create("gFrame")
	canvas:gSetSize(1920, 1080)
	canvas:gCenter()
	canvas:gSetRadius(0)
	canvas:gSetBgColor(gTheme("bg"), 252)
	canvas:gSetHeader(true, h, 252)
	canvas:gSetTitle("gPropertySheet Showcase", "OxaniumMedium", 14, gContrastText(h), TEXT_ALIGN_CENTER)
	canvas:gSetCloseButton(true, "OxaniumExtraLight", 22, gContrastText(h, 140))
	canvas:gSetDraggable(false)
	canvas:gOpen(0.15)

	_panels["canvasPS"] = canvas

	local pad  = 24
	local offY = 40 + pad

	-- PropertySheet default
	local ps1 = vgui.Create("gPropertySheet", canvas)
	ps1:gSetSize(500, 300)
	ps1:gSetPos(pad, offY)
	ps1:gSetBorder(true, gTheme("border"), 15)

	local tabContents = {
		{ label = "Profil",      color = gTheme("accent")  },
		{ label = "Inventaire",  color = gTheme("success") },
		{ label = "Paramètres",  color = gTheme("warning") },
	}

	for _, cfg in ipairs(tabContents) do
		local p = vgui.Create("gPanel")
		p:gSetBgColor(gTheme("surface"), 0)

		local lbl = vgui.Create("gLabel", p)
		lbl:SetPos(16, 16)
		lbl:gSetSize(400, 24)
		lbl:gSetFont("OxaniumMedium", 14)
		lbl:gSetColor(cfg.color)
		lbl:gSetText("Contenu — " .. cfg.label)

		ps1:gAddTab(cfg.label, p)
	end

	-- PropertySheet couleurs custom
	local ps2 = vgui.Create("gPropertySheet", canvas)
	ps2:gSetSize(500, 300)
	ps2:gSetPos(pad + 500 + pad, offY)
	ps2:gSetBorder(true, gTheme("border"), 15)
	ps2:gSetTabHeight(40)
	ps2:gSetTabFont("OxaniumSemiBold", 13)
	ps2:gSetTabColors(
		gTheme("textMute"),
		gTheme("text"),
		gTheme("elevated"),
		gTheme("surface"),
		245
	)

	local tabs2 = { "Général", "Sécurité", "Notifications", "Avancé" }
	for _, label in ipairs(tabs2) do
		local p = vgui.Create("gPanel")
		p:gSetBgColor(gTheme("surface"), 0)

		local lbl = vgui.Create("gLabel", p)
		lbl:SetPos(16, 16)
		lbl:gSetSize(400, 24)
		lbl:gSetFont("OxaniumRegular", 13)
		lbl:gSetColor(gTheme("textDim"))
		lbl:gSetText("Onglet : " .. label)

		ps2:gAddTab(label, p)
	end
end)

-- =========================================================
-- gCollapsibleCategory
-- =========================================================
concommand.Add("g_test_vgui_collapsible", function()
	if IsValid(_panels["canvasCollapsible"]) then
		gVGUIKill("canvasCollapsible")
		return
	end

	local h = gTheme("elevated")

	local canvas = vgui.Create("gFrame")
	canvas:gSetSize(1920, 1080)
	canvas:gCenter()
	canvas:gSetRadius(0)
	canvas:gSetBgColor(gTheme("bg"), 252)
	canvas:gSetHeader(true, h, 252)
	canvas:gSetTitle("gCollapsibleCategory Showcase", "OxaniumMedium", 14, gContrastText(h), TEXT_ALIGN_CENTER)
	canvas:gSetCloseButton(true, "OxaniumExtraLight", 22, gContrastText(h, 140))
	canvas:gSetDraggable(false)
	canvas:gOpen(0.15)

	_panels["canvasCollapsible"] = canvas

	local pad  = 24
	local offY = 40 + pad
	local cW   = 480

	-- Colonne gauche — catégories standalone
	local scroll = vgui.Create("gScrollPanel", canvas)
	scroll:gSetSize(cW, 1080 - offY - pad)
	scroll:gSetPos(pad, offY)
	scroll:gSetBgColor(gTheme("bg"), 0)
	scroll:gSetScrollbar(true, 4, gTheme("textMute"))
	scroll:gSetPadding(0, 4)

	local list = vgui.Create("gListLayout", scroll:GetCanvas())
	list:gSetSize(cW, 10)
	list:gSetPos(0, 0)
	list:gSetSpacing(6)

	local configs = {
		{
			title    = "Informations générales",
			header   = gTheme("elevated"),
			expanded = true,
			items    = {
				{ label = "Nom du joueur",   value = "Guillaume"    },
				{ label = "Niveau",          value = "42"           },
				{ label = "Expérience",      value = "18 400 XP"    },
			},
		},
		{
			title    = "Paramètres avancés",
			header   = gTheme("accent"),
			expanded = false,
			items    = {
				{ label = "Résolution",      value = "1920 × 1080"  },
				{ label = "Qualité",         value = "Ultra"        },
				{ label = "FOV",             value = "90°"          },
				{ label = "Motion blur",     value = "Désactivé"    },
			},
		},
		{
			title    = "Statistiques",
			header   = gTheme("success"),
			expanded = true,
			items    = {
				{ label = "Temps de jeu",    value = "128h"         },
				{ label = "Kills",           value = "340"          },
				{ label = "Deaths",          value = "89"           },
			},
		},
		{
			title    = "Zone de danger",
			header   = gTheme("danger"),
			expanded = false,
			items    = {
				{ label = "Réinitialiser",   value = "→ Effacer"    },
				{ label = "Supprimer compte",value = "→ Confirmer"  },
			},
		},
	}

	for _, cfg in ipairs(configs) do
		local cat = vgui.Create("gCollapsibleCategory")
		cat:gSetSize(cW, 10)
		cat:gSetTitle(cfg.title)
		cat:gSetHeaderColor(cfg.header, 255)
		cat:gSetTitleColor(gContrastText(cfg.header))
		cat:gSetBgColor(gTheme("surface"), 242)
		cat:gSetBorder(true, gTheme("border"), 12)
		cat:gSetRadius(gThemeRadius("sm"))
		cat:gSetPadding(0, 6)
		cat:gSetSpacing(0)
		cat:gSetExpanded(cfg.expanded, true)

		for i, item in ipairs(cfg.items) do
			local row = vgui.Create("gPanel", cat:GetContent())
			row:gSetSize(cW, 34)
			row:gSetPos(0, (i - 1) * 34)
			row:gSetBgColor(i % 2 == 0 and gTheme("elevated") or gTheme("surface"), 0)
			row:gSetRadius(0)

			local lblKey = vgui.Create("gLabel", row)
			lblKey:SetSize(220, 34)
			lblKey:SetPos(gRespX(14), 0)
			lblKey:gSetFont("OxaniumRegular", 12)
			lblKey:gSetColor(gTheme("textDim"))
			lblKey:gSetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			lblKey:gSetText(item.label)

			local lblVal = vgui.Create("gLabel", row)
			lblVal:SetSize(220, 34)
			lblVal:SetPos(cW - gRespX(14) - 220, 0)
			lblVal:gSetFont("OxaniumMedium", 12)
			lblVal:gSetColor(gTheme("text"))
			lblVal:gSetAlign(TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			lblVal:gSetText(item.value)

			local sep = vgui.Create("DPanel", row)
			sep:SetPos(gRespX(14), 33)
			sep:SetSize(cW - gRespX(28), 1)
			sep.Paint = function(_, w, h)
				surface.SetDrawColor(gTheme("border").r, gTheme("border").g, gTheme("border").b, gThemeAlpha("sep"))
				surface.DrawRect(0, 0, w, h)
			end
		end

		list:gAddItem(cat)
	end
end)

-- =========================================================
-- gImage
-- =========================================================
concommand.Add("g_test_vgui_image", function()
	if IsValid(_panels["canvasImage"]) then
		gVGUIKill("canvasImage")
		return
	end

	local h = gTheme("elevated")

	local canvas = vgui.Create("gFrame")
	canvas:gSetSize(1920, 1080)
	canvas:gCenter()
	canvas:gSetRadius(0)
	canvas:gSetBgColor(gTheme("bg"), 252)
	canvas:gSetHeader(true, h, 252)
	canvas:gSetTitle("gImage Showcase", "OxaniumMedium", 14, gContrastText(h), TEXT_ALIGN_CENTER)
	canvas:gSetCloseButton(true, "OxaniumExtraLight", 22, gContrastText(h, 140))
	canvas:gSetDraggable(false)
	canvas:gOpen(0.15)

	_panels["canvasImage"] = canvas

	local pad  = 24
	local offY = 40 + pad
	local iW   = 200
	local iH   = 140
	local iP   = 16

	local configs = {
		{ label = "Fill (défaut)",   path = "vgui/gradient-r",  fitMode = "fill"                             },
		{ label = "Contain",         path = "vgui/gradient-r",  fitMode = "contain"                          },
		{ label = "Center",          path = "vgui/gradient-r",  fitMode = "center"                           },
		{ label = "Teinté Accent",   path = "vgui/gradient-r",  fitMode = "fill",  color = gTheme("accent")  },
		{ label = "Teinté Success",  path = "vgui/gradient-r",  fitMode = "fill",  color = gTheme("success") },
		{ label = "Alpha 120",       path = "vgui/gradient-r",  fitMode = "fill",  alpha = 120               },
		{ label = "Fallback",        path = "",                  fitMode = "fill",  fallback = gTheme("elevated") },
		{ label = "Fallback Accent", path = "",                  fitMode = "fill",  fallback = gTheme("accent")   },
		{ label = "Border",          path = "vgui/gradient-r",  fitMode = "fill",  border = true             },
	}

	for i, cfg in ipairs(configs) do
		local col = (i - 1) % 4
		local row = math.floor((i - 1) / 4)
		local px  = pad + col * (iW + iP)
		local py  = offY + row * (iH + iP + 22)

		local lbl = vgui.Create("gLabel", canvas)
		lbl:gSetSize(iW, 16)
		lbl:gSetPos(px, py)
		lbl:gSetFont("OxaniumMedium", 11)
		lbl:gSetColor(gTheme("textDim"))
		lbl:gSetText(cfg.label)

		local img = vgui.Create("gImage", canvas)
		img:gSetSize(iW, iH)
		img:gSetPos(px, py + 18)
		img:gSetImage(cfg.path, cfg.fallback)
		img:gSetFitMode(cfg.fitMode)

		if cfg.color then img:gSetColor(cfg.color) end
		if cfg.alpha then img:gSetAlpha(cfg.alpha) end
		if cfg.border then img:gSetBorder(true, gTheme("border"), 40) end
	end
end)

-- =========================================================
-- gImageButton
-- =========================================================
concommand.Add("g_test_vgui_imagebutton", function()
	if IsValid(_panels["canvasImgBtn"]) then
		gVGUIKill("canvasImgBtn")
		return
	end

	local h = gTheme("elevated")

	local canvas = vgui.Create("gFrame")
	canvas:gSetSize(1920, 1080)
	canvas:gCenter()
	canvas:gSetRadius(0)
	canvas:gSetBgColor(gTheme("bg"), 252)
	canvas:gSetHeader(true, h, 252)
	canvas:gSetTitle("gImageButton Showcase", "OxaniumMedium", 14, gContrastText(h), TEXT_ALIGN_CENTER)
	canvas:gSetCloseButton(true, "OxaniumExtraLight", 22, gContrastText(h, 140))
	canvas:gSetDraggable(false)
	canvas:gOpen(0.15)

	_panels["canvasImgBtn"] = canvas

	local pad  = 24
	local offY = 40 + pad
	local bW   = 160
	local bH   = 120
	local bP   = 14

	local configs = {
		{ label = "Default",         path = "vgui/gradient-r"                                               },
		{ label = "Avec label bas",  path = "vgui/gradient-r",  lbl = "Ouvrir"                             },
		{ label = "Label haut",      path = "vgui/gradient-r",  lbl = "Titre",   lalignY = TEXT_ALIGN_TOP  },
		{ label = "Label centré",    path = "vgui/gradient-r",  lbl = "Centre",  lalignY = TEXT_ALIGN_CENTER },
		{ label = "Teinté Accent",   path = "vgui/gradient-r",  color = gTheme("accent")                   },
		{ label = "Teinté Danger",   path = "vgui/gradient-r",  color = gTheme("danger")                   },
		{ label = "Fallback",        path = "",                  fallback = gTheme("elevated"), lbl = "No img" },
		{ label = "Border",          path = "vgui/gradient-r",  border = true                              },
		{ label = "Désactivé",       path = "vgui/gradient-r",  disabled = true                            },
	}

	for i, cfg in ipairs(configs) do
		local col = (i - 1) % 5
		local row = math.floor((i - 1) / 5)
		local px  = pad + col * (bW + bP)
		local py  = offY + row * (bH + bP + 22)

		local lbl = vgui.Create("gLabel", canvas)
		lbl:gSetSize(bW, 16)
		lbl:gSetPos(px, py)
		lbl:gSetFont("OxaniumMedium", 11)
		lbl:gSetColor(gTheme("textDim"))
		lbl:gSetText(cfg.label)

		local btn = vgui.Create("gImageButton", canvas)
		btn:gSetSize(bW, bH)
		btn:gSetPos(px, py + 18)
		btn:gSetImage(cfg.path, cfg.fallback)

		if cfg.color   then btn:gSetColor(cfg.color) end
		if cfg.border  then btn:gSetBorder(true, gTheme("border"), 40) end
		if cfg.disabled then btn:gSetDisabled(true) end

		if cfg.lbl then
			btn:gSetLabel(cfg.lbl, "OxaniumMedium", 12, color_white, TEXT_ALIGN_CENTER, cfg.lalignY or TEXT_ALIGN_BOTTOM, 8)
		end

		btn.DoClick = function()
			print("[gImageButton] Clicked: " .. cfg.label)
		end
	end
end)

-- =========================================================
-- gModelPanel
-- =========================================================
concommand.Add("g_test_vgui_modelpanel", function()
	if IsValid(_panels["canvasModel"]) then
		gVGUIKill("canvasModel")
		return
	end

	local h = gTheme("elevated")

	local canvas = vgui.Create("gFrame")
	canvas:gSetSize(1920, 1080)
	canvas:gCenter()
	canvas:gSetRadius(0)
	canvas:gSetBgColor(gTheme("bg"), 252)
	canvas:gSetHeader(true, h, 252)
	canvas:gSetTitle("gModelPanel Showcase", "OxaniumMedium", 14, gContrastText(h), TEXT_ALIGN_CENTER)
	canvas:gSetCloseButton(true, "OxaniumExtraLight", 22, gContrastText(h, 140))
	canvas:gSetDraggable(false)
	canvas:gOpen(0.15)

	_panels["canvasModel"] = canvas

	local pad  = 24
	local offY = 40 + pad
	local mW   = 200
	local mH   = 260
	local mP   = 16

	local configs = {
		{
			label  = "Rotation auto",
			model  = "models/player/combine_soldier.mdl",
			rotate = true,
		},
		{
			label  = "Rotation off",
			model  = "models/player/combine_soldier.mdl",
			rotate = false,
		},
		{
			label  = "Couleur tintée",
			model  = "models/player/combine_soldier.mdl",
			rotate = true,
			color  = gTheme("accent"),
		},
		{
			label  = "Fond surface",
			model  = "models/player/combine_soldier.mdl",
			rotate = true,
			bg     = gTheme("surface"),
			bgA    = 245,
		},
		{
			label  = "Border",
			model  = "models/player/combine_soldier.mdl",
			rotate = true,
			border = true,
		},
	}

	for i, cfg in ipairs(configs) do
		local px = pad + (i - 1) * (mW + mP)
		local py = offY

		local lbl = vgui.Create("gLabel", canvas)
		lbl:gSetSize(mW, 16)
		lbl:gSetPos(px, py)
		lbl:gSetFont("OxaniumMedium", 11)
		lbl:gSetColor(gTheme("textDim"))
		lbl:gSetText(cfg.label)

		local mp = vgui.Create("gModelPanel", canvas)
		mp:gSetSize(mW, mH)
		mp:gSetPos(px, py + 18)
		mp:gSetModel(cfg.model)
		mp:gSetRotate(cfg.rotate, 0.8)

		if cfg.color  then mp:gSetColor(cfg.color) end
		if cfg.bg     then mp:gSetBgColor(cfg.bg, cfg.bgA) end
		if cfg.border then mp:gSetBorder(true, gTheme("border"), 40) end
	end
end)

-- =========================================================
-- gProgress
-- =========================================================
concommand.Add("g_test_vgui_progress", function()
	if IsValid(_panels["canvasProgress"]) then
		gVGUIKill("canvasProgress")
		return
	end

	local h = gTheme("elevated")

	local canvas = vgui.Create("gFrame")
	canvas:gSetSize(1920, 1080)
	canvas:gCenter()
	canvas:gSetRadius(0)
	canvas:gSetBgColor(gTheme("bg"), 252)
	canvas:gSetHeader(true, h, 252)
	canvas:gSetTitle("gProgress Showcase", "OxaniumMedium", 14, gContrastText(h), TEXT_ALIGN_CENTER)
	canvas:gSetCloseButton(true, "OxaniumExtraLight", 22, gContrastText(h, 140))
	canvas:gSetDraggable(false)
	canvas:gOpen(0.15)

	_panels["canvasProgress"] = canvas

	local pad  = 24
	local offY = 40 + pad
	local bW   = 340
	local bH   = 12
	local bP   = 28

	local configs = {
		{ label = "Default 65%",        value = 0.65                                              },
		{ label = "Accent",             value = 0.4,  fill = gTheme("accent")                    },
		{ label = "Success",            value = 0.8,  fill = gTheme("success")                   },
		{ label = "Danger",             value = 0.2,  fill = gTheme("danger")                    },
		{ label = "Warning",            value = 0.55, fill = gTheme("warning")                   },
		{ label = "Avec label",         value = 0.72, fill = gTheme("accent"),   label_ = true   },
		{ label = "Radius LG",          value = 0.5,  radius = "lg",             h_ = 20         },
		{ label = "Reversed",           value = 0.6,  fill = gTheme("accent"),   reversed = true },
		{ label = "Sans animation",     value = 0.9,  animated = false                           },
	}

	for i, cfg in ipairs(configs) do
		local col = (i - 1) % 2
		local row = math.floor((i - 1) / 2)
		local px  = pad + col * (bW + pad)
		local ph  = cfg.h_ or bH
		local py  = offY + row * (ph + bP)

		local lbl = vgui.Create("gLabel", canvas)
		lbl:gSetSize(bW, 16)
		lbl:gSetPos(px, py)
		lbl:gSetFont("OxaniumMedium", 11)
		lbl:gSetColor(gTheme("textDim"))
		lbl:gSetText(cfg.label)

		local p = vgui.Create("gProgress", canvas)
		p:gSetSize(bW, ph)
		p:gSetPos(px, py + 18)
		p:gSetValue(cfg.value)

		if cfg.fill     then p:gSetFillColor(cfg.fill) end
		if cfg.radius   then p:gSetRadius(gThemeRadius(cfg.radius)) end
		if cfg.reversed then p:gSetReversed(true) end
		if cfg.animated == false then p:gSetAnimated(false) end

		if cfg.label_ then
			p:gSetSize(bW, 20)
			p:gSetLabel(true, "OxaniumMedium", 11)
		end
	end

	-- Barres verticales
	local vConfigs = {
		{ fill = gTheme("accent"),  value = 0.7  },
		{ fill = gTheme("success"), value = 0.45 },
		{ fill = gTheme("danger"),  value = 0.9  },
		{ fill = gTheme("warning"), value = 0.3  },
	}

	local vW   = 28
	local vH   = 160
	local vP   = 12
	local vOffX = pad + (bW + pad)
	local vOffY = offY + 5 * (bH + bP)

	for i, cfg in ipairs(vConfigs) do
		local p = vgui.Create("gProgress", canvas)
		p:gSetSize(vW, vH)
		p:gSetPos(vOffX + (i - 1) * (vW + vP), vOffY)
		p:gSetValue(cfg.value)
		p:gSetFillColor(cfg.fill)
		p:gSetVertical(true)
		p:gSetRadius(gThemeRadius("sm"))
	end
end)

-- =========================================================
-- gColorMixer
-- =========================================================
concommand.Add("g_test_vgui_colormixer", function()
	if IsValid(_panels["canvasColorMixer"]) then
		gVGUIKill("canvasColorMixer")
		return
	end

	local h = gTheme("elevated")

	local canvas = vgui.Create("gFrame")
	canvas:gSetSize(1920, 1080)
	canvas:gCenter()
	canvas:gSetRadius(0)
	canvas:gSetBgColor(gTheme("bg"), 252)
	canvas:gSetHeader(true, h, 252)
	canvas:gSetTitle("gColorMixer Showcase", "OxaniumMedium", 14, gContrastText(h), TEXT_ALIGN_CENTER)
	canvas:gSetCloseButton(true, "OxaniumExtraLight", 22, gContrastText(h, 140))
	canvas:gSetDraggable(false)
	canvas:gOpen(0.15)

	_panels["canvasColorMixer"] = canvas

	local pad  = 24
	local offY = 40 + pad

	-- Default
	local lbl1 = vgui.Create("gLabel", canvas)
	lbl1:gSetSize(240, 16)
	lbl1:gSetPos(pad, offY)
	lbl1:gSetFont("OxaniumMedium", 11)
	lbl1:gSetColor(gTheme("textDim"))
	lbl1:gSetText("Sans alpha")

	local cm1 = vgui.Create("gColorMixer", canvas)
	cm1:gSetSize(240, 220)
	cm1:gSetPos(pad, offY + 18)
	cm1:gSetColor(Color(100, 200, 255))
	cm1:gSetBorder(true, gTheme("border"), 15)
	cm1.OnChange = function(_, c)
		print(string.format("[gColorMixer] RGB(%d, %d, %d)", c.r, c.g, c.b))
	end

	-- Avec alpha
	local lbl2 = vgui.Create("gLabel", canvas)
	lbl2:gSetSize(260, 16)
	lbl2:gSetPos(pad + 240 + pad, offY)
	lbl2:gSetFont("OxaniumMedium", 11)
	lbl2:gSetColor(gTheme("textDim"))
	lbl2:gSetText("Avec alpha")

	local cm2 = vgui.Create("gColorMixer", canvas)
	cm2:gSetSize(260, 220)
	cm2:gSetPos(pad + 240 + pad, offY + 18)
	cm2:gSetShowAlpha(true)
	cm2:gSetColor(Color(255, 100, 80, 180))
	cm2:gSetBorder(true, gTheme("border"), 15)

	-- Sans preview
	local lbl3 = vgui.Create("gLabel", canvas)
	lbl3:gSetSize(220, 16)
	lbl3:gSetPos(pad + (240 + pad) + (260 + pad), offY)
	lbl3:gSetFont("OxaniumMedium", 11)
	lbl3:gSetColor(gTheme("textDim"))
	lbl3:gSetText("Sans preview")

	local cm3 = vgui.Create("gColorMixer", canvas)
	cm3:gSetSize(220, 220)
	cm3:gSetPos(pad + (240 + pad) + (260 + pad), offY + 18)
	cm3:gSetShowPreview(false)
	cm3:gSetColor(Color(60, 200, 120))
	cm3:gSetBorder(true, gTheme("border"), 15)
end)

-- =========================================================
-- gNotify
-- =========================================================
concommand.Add("g_test_vgui_notify", function()
	gNotify("Connexion réussie au serveur", "success", 4)
end)

concommand.Add("g_test_vgui_notify_danger", function()
	gNotify("Erreur critique détectée", "danger", 5)
end)

concommand.Add("g_test_vgui_notify_warning", function()
	gNotify("Attention — action irréversible", "warning", 4)
end)

concommand.Add("g_test_vgui_notify_accent", function()
	gNotify("Mise à jour disponible", "accent", 4)
end)

concommand.Add("g_test_vgui_notify_default", function()
	gNotify("Notification par défaut", "default", 4)
end)

concommand.Add("g_test_vgui_notify_spam", function()
	local msgs = {
		{ "Module chargé",           "success" },
		{ "Connexion MySQL active",  "accent"  },
		{ "Erreur base de données",  "danger"  },
		{ "Sauvegarde en cours...",  "default" },
		{ "Token expiré",            "warning" },
		{ "Joueur déconnecté",       "default" },
	}
	for i, msg in ipairs(msgs) do
		timer.Simple((i - 1) * 0.3, function()
			gNotify(msg[1], msg[2], 4)
		end)
	end
end)

concommand.Add("g_test_vgui_notify_side", function(_, _, args)
	local side = args or "bottomright"
	gNotifySetSide(side)
	gNotify("Position : " .. side, "accent", 3)
end)

-- =========================================================
-- gListView
-- =========================================================
concommand.Add("g_test_vgui_listview", function()
	if IsValid(_panels["canvasListView"]) then
		gVGUIKill("canvasListView")
		return
	end

	local h = gTheme("elevated")

	local canvas = vgui.Create("gFrame")
	canvas:gSetSize(1920, 1080)
	canvas:gCenter()
	canvas:gSetRadius(0)
	canvas:gSetBgColor(gTheme("bg"), 252)
	canvas:gSetHeader(true, h, 252)
	canvas:gSetTitle("gListView Showcase", "OxaniumMedium", 14, gContrastText(h), TEXT_ALIGN_CENTER)
	canvas:gSetCloseButton(true, "OxaniumExtraLight", 22, gContrastText(h, 140))
	canvas:gSetDraggable(false)
	canvas:gOpen(0.15)

	_panels["canvasListView"] = canvas

	local pad  = 24
	local offY = 40 + pad

	-- ListView joueurs
	local lv1 = vgui.Create("gListView", canvas)
	lv1:gSetSize(600, 400)
	lv1:gSetPos(pad, offY)
	lv1:gSetBorder(true, gTheme("border"), 15)
	lv1:gAddColumn("Joueur",   180)
	lv1:gAddColumn("Métier",   160)
	lv1:gAddColumn("Niveau",   80,  TEXT_ALIGN_CENTER)
	lv1:gAddColumn("Statut",   nil, TEXT_ALIGN_CENTER)

	local jobs    = { "Citoyen", "Policier", "Médecin", "Pompier", "Mécanicien", "Maire", "Banquier" }
	local statuts = { "En ligne", "AFK", "Occupé" }

	for i = 1, 20 do
		lv1:gAddRow({
			"Joueur_" .. i,
			jobs[(i % #jobs) + 1],
			tostring(math.random(1, 50)),
			statuts[(i % #statuts) + 1],
		})
	end

	lv1.OnSelect = function(_, idx, data)
		print("[gListView] Sélection #" .. idx .. " — " .. data[1])
	end

	-- ListView logs
	local lv2 = vgui.Create("gListView", canvas)
	lv2:gSetSize(600, 400)
	lv2:gSetPos(pad + 600 + pad, offY)
	lv2:gSetBorder(true, gTheme("border"), 15)
	lv2:gSetHeaderStyle(gTheme("elevated"), 252, "OxaniumSemiBold", 12, gTheme("textDim"))
	lv2:gSetRowStyle("OxaniumRegular", 12, nil, true)
	lv2:gAddColumn("Heure",   80,  TEXT_ALIGN_CENTER)
	lv2:gAddColumn("Type",    100, TEXT_ALIGN_CENTER)
	lv2:gAddColumn("Message", nil)

	local types = { "INFO", "WARN", "ERROR", "DEBUG" }
	local msgs  = {
		"Module chargé avec succès",
		"Connexion MySQL active",
		"Token expiré — reconnexion",
		"Sauvegarde joueur effectuée",
		"Erreur base de données",
		"Map changée",
		"Joueur banni",
		"Config rechargée",
	}

	for i = 1, 18 do
		lv2:gAddRow({
			string.format("%02d:%02d", math.random(0,23), math.random(0,59)),
			types[(i % #types) + 1],
			msgs[(i % #msgs) + 1],
		})
	end
end)

-- =========================================================
-- gTree
-- =========================================================
concommand.Add("g_test_vgui_tree", function()
	if IsValid(_panels["canvasTree"]) then
		gVGUIKill("canvasTree")
		return
	end

	local h = gTheme("elevated")

	local canvas = vgui.Create("gFrame")
	canvas:gSetSize(1920, 1080)
	canvas:gCenter()
	canvas:gSetRadius(0)
	canvas:gSetBgColor(gTheme("bg"), 252)
	canvas:gSetHeader(true, h, 252)
	canvas:gSetTitle("gTree Showcase", "OxaniumMedium", 14, gContrastText(h), TEXT_ALIGN_CENTER)
	canvas:gSetCloseButton(true, "OxaniumExtraLight", 22, gContrastText(h, 140))
	canvas:gSetDraggable(false)
	canvas:gOpen(0.15)

	_panels["canvasTree"] = canvas

	local pad  = 24
	local offY = 40 + pad

	-- Arbre 1 — structure serveur
	local t1 = vgui.Create("gTree", canvas)
	t1:gSetSize(340, 440)
	t1:gSetPos(pad, offY)
	t1:gSetBorder(true, gTheme("border"), 15)
	t1:gSetFont("OxaniumRegular", 13)

	local nServeur  = t1:gAddNode("Serveur")
	local nJoueurs  = t1:gAddNode("Joueurs")
	local nModules  = t1:gAddNode("Modules")

	local nConfig   = t1:gAddNode("Configuration", "config", 1)
	local nDB       = t1:gAddNode("Base de données", "db",    1)

	local nAdmins   = t1:gAddNode("Admins", "admins", 2)
	local nVIP      = t1:gAddNode("VIP",    "vip",    2)

	t1:gAddNode("Admin_1", 1, 6)
	t1:gAddNode("Admin_2", 2, 6)
	t1:gAddNode("Admin_3", 3, 6)

	t1:gAddNode("Jobs",      "jobs", 3)
	t1:gAddNode("Economy",   "eco",  3)
	t1:gAddNode("Inventory", "inv",  3)

	t1.OnSelect = function(_, node)
		print("[gTree t1] Sélection : " .. node.label)
	end

	t1.OnToggle = function(_, node, expanded)
		print("[gTree t1] " .. node.label .. " → " .. tostring(expanded))
	end

	-- Arbre 2 — mêmes labels, instances séparées
	local t2 = vgui.Create("gTree", canvas)
	t2:gSetSize(340, 440)
	t2:gSetPos(pad + 340 + pad, offY)
	t2:gSetBorder(true, gTheme("border"), 15)
	t2:gSetFont("OxaniumRegular", 13)
	t2:gSetStripes(true)

	local cats = {
		{ "Personnage",   { "Nom", "Âge", "Métier", "Faction" }             },
		{ "Inventaire",   { "Arme principale", "Arme secondaire", "Items" }  },
		{ "Statistiques", { "Santé", "Stamina", "Réputation", "Niveau" }     },
		{ "Serveur",      { "IP", "Port", "Map", "Joueurs" }                 },
		{ "Modules",      { "Jobs", "Economy", "Inventory" }                 },
	}

	for ci, cat in ipairs(cats) do
		local parentNode = t2:gAddNode(cat[1])
		local parentIdx  = ci
		for _, child in ipairs(cat[2]) do
			t2:gAddNode(child, child, parentIdx)
		end
	end

	t2.OnSelect = function(_, node)
		print("[gTree t2] Sélection : " .. node.label)
	end
end)