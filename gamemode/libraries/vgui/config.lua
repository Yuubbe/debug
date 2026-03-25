TKRBASE.VGUI = {}

TKRBASE.VGUI.Theme = "dark"

TKRBASE.VGUI.Radius = {
	sm = 8,
	lg = 16,
}

TKRBASE.VGUI.Alpha = {
	full     = 255,
	high     = 245,
	mid      = 240,
	hover    = 20,
	press    = 40,
	border   = 30,
	sep      = 25,
	disabled = 80,
}

TKRBASE.VGUI.Colors = {
	dark = {
		bg       = Color(10,  10,  12),
		surface  = Color(18,  18,  22),
		elevated = Color(28,  28,  34),
		text     = Color(240, 240, 245),
		textDim  = Color(140, 140, 150),
		textMute = Color(70,  70,  80),
		border   = Color(255, 255, 255),
		success  = Color(60,  200, 100),
		danger   = Color(220, 55,  55),
		warning  = Color(220, 155, 30),
		accent   = Color(100, 100, 255),
	},
	white = {
		bg       = Color(248, 248, 250),
		surface  = Color(255, 255, 255),
		elevated = Color(238, 238, 243),
		text     = Color(15,  15,  18),
		textDim  = Color(110, 110, 120),
		textMute = Color(180, 180, 190),
		border   = Color(0,   0,   0),
		success  = Color(30,  160, 80),
		danger   = Color(200, 40,  40),
		warning  = Color(190, 125, 15),
		accent   = Color(80,  80,  220),
	},
}

function gTheme(key)
	return TKRBASE.VGUI.Colors[TKRBASE.VGUI.Theme][key]
end

function gThemeAlpha(key)
	return TKRBASE.VGUI.Alpha[key] or 255
end

function gThemeRadius(key)
	return TKRBASE.VGUI.Radius[key or "sm"]
end

function gThemeColor(key, alpha)
	local c = gTheme(key)
	if not c then return Color(255, 255, 255) end
	return Color(c.r, c.g, c.b, alpha or gThemeAlpha("full"))
end

function gColorLuminance(c)
	return 0.299 * c.r + 0.587 * c.g + 0.114 * c.b
end

function gContrastText(bgColor, alpha)
	local a = alpha or gThemeAlpha("full")
	if gColorLuminance(bgColor) > 140 then
		return Color(10, 10, 12, a)
	end
	return Color(240, 240, 245, a)
end