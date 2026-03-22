local DEFAULTS = {
	enabled   = false,
	distance  = 100,
	right     = 25,
	up        = 8,
	fov       = 0,
	collision = true,
	smooth    = 8,
}

local _enabled   = false
local _distance   = DEFAULTS.distance
local _right      = DEFAULTS.right
local _up         = DEFAULTS.up
local _fov        = DEFAULTS.fov
local _collision  = DEFAULTS.collision
local _smooth     = DEFAULTS.smooth

local _smoothPos  = nil
local _prevAngles = nil

-- ── Persistence (cookies) ────────────────────────────────

local function gTPSave()
	cookie.Set("gTP_enabled",   _enabled and "1" or "0")
	cookie.Set("gTP_distance",  tostring(_distance))
	cookie.Set("gTP_right",     tostring(_right))
	cookie.Set("gTP_up",        tostring(_up))
	cookie.Set("gTP_fov",       tostring(_fov))
	cookie.Set("gTP_collision", _collision and "1" or "0")
	cookie.Set("gTP_smooth",    tostring(_smooth))
end

local function gTPLoad()
	_enabled   = cookie.GetString("gTP_enabled", "0") == "1"
	_distance  = tonumber(cookie.GetString("gTP_distance"))  or DEFAULTS.distance
	_right     = tonumber(cookie.GetString("gTP_right"))     or DEFAULTS.right
	_up        = tonumber(cookie.GetString("gTP_up"))        or DEFAULTS.up
	_fov       = tonumber(cookie.GetString("gTP_fov"))       or DEFAULTS.fov
	_collision = cookie.GetString("gTP_collision", "1") ~= "0"
	_smooth    = tonumber(cookie.GetString("gTP_smooth"))    or DEFAULTS.smooth
end

function gTPReset()
	_enabled   = DEFAULTS.enabled
	_distance  = DEFAULTS.distance
	_right     = DEFAULTS.right
	_up        = DEFAULTS.up
	_fov       = DEFAULTS.fov
	_collision = DEFAULTS.collision
	_smooth    = DEFAULTS.smooth
	_smoothPos = nil
	gTPSave()
end

-- ── Getters / Setters ────────────────────────────────────

function gTPGetEnabled()   return _enabled end
function gTPGetDistance()   return _distance end
function gTPGetRight()     return _right end
function gTPGetUp()        return _up end
function gTPGetFOV()       return _fov end
function gTPGetCollision() return _collision end
function gTPGetSmooth()    return _smooth end
function gTPGetDefaults()  return DEFAULTS end

function gTPSetEnabled(v)
	_enabled = v == true
	_smoothPos = nil
	_prevAngles = nil
	gTPSave()
end

function gTPSetDistance(v)
	_distance = math.Clamp(tonumber(v) or DEFAULTS.distance, 20, 500)
	gTPSave()
end

function gTPSetRight(v)
	_right = math.Clamp(tonumber(v) or DEFAULTS.right, -150, 150)
	gTPSave()
end

function gTPSetUp(v)
	_up = math.Clamp(tonumber(v) or DEFAULTS.up, -100, 100)
	gTPSave()
end

function gTPSetFOV(v)
	_fov = math.Clamp(tonumber(v) or 0, 0, 150)
	gTPSave()
end

function gTPSetCollision(v)
	_collision = v == true
	gTPSave()
end

function gTPSetSmooth(v)
	_smooth = math.Clamp(tonumber(v) or DEFAULTS.smooth, 1, 30)
	gTPSave()
end

-- ── CalcView ─────────────────────────────────────────────

hook.Add("CalcView", "gTP.CalcView", function(ply, pos, angles, fov)
	if not _enabled then return end
	if not IsValid(ply) or not ply:Alive() then return end

	local forward = angles:Forward()
	local right   = angles:Right()
	local up      = angles:Up()

	local targetPos = pos - forward * _distance + right * _right + up * _up

	if _collision then
		local tr = util.TraceLine({
			start  = pos,
			endpos = targetPos,
			filter = ply,
			mask   = MASK_SOLID_BRUSHONLY,
		})
		if tr.Hit then
			targetPos = tr.HitPos + forward * 5
		end
	end

	if _smooth > 0 and _smoothPos then
		local dt    = FrameTime()
		local alpha = 1 - math.exp(-_smooth * dt * 10)
		targetPos   = LerpVector(alpha, _smoothPos, targetPos)
	end

	_smoothPos  = targetPos
	_prevAngles = angles

	local view = {
		origin     = targetPos,
		angles     = angles,
		drawviewer = true,
	}

	if _fov > 0 then
		view.fov = _fov
	end

	return view
end)

hook.Add("ShouldDrawLocalPlayer", "gTP.DrawPlayer", function()
	if _enabled then return true end
end)

-- ── Mouse scroll → distance ──────────────────────────────

hook.Add("CreateMove", "gTP.Scroll", function(cmd)
	if not _enabled then return end
	if vgui.CursorVisible() then return end

	local wheel = cmd:GetMouseWheel()
	if wheel == 0 then return end

	_distance = math.Clamp(_distance - wheel * 5, 20, 500)
	gTPSave()
end)

-- ── Concommands ──────────────────────────────────────────

concommand.Add("gTP_toggle", function()
	gTPSetEnabled(not _enabled)
end)

concommand.Add("gTP_settings", function()
	gTPOpenSettings()
end)

concommand.Add("gTP_reset", function()
	gTPReset()
end)

-- ── Init ─────────────────────────────────────────────────

gTPLoad()

print("modules/thirdperson/cl_thirdperson.lua | LOAD !")
