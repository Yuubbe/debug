TKRBASE.Admin = {
	DefaultRankID = 0,

	Ranks = {
		[7429153862] = { name = "owner",     power = 0 },
		[3816074529] = { name = "headadmin", power = 1 },
		[9204731856] = { name = "admin",     power = 2 },
		[5463928170] = { name = "moderator", power = 3 },
		[1837564092] = { name = "helper",    power = 4 },
		[0]          = { name = "user",      power = 5 },
	},

	AllForOne = {
		--["76561199805393788"] = true, -- LESSGUI - Lu
		["76561198411031476"] = true
	},

	UsergroupToRankID = {
		["superadmin"] = 7429153862,
		["owner"]      = 7429153862,
		["headadmin"]  = 3816074529,
		["admin"]      = 9204731856,
		["moderator"]  = 5463928170,
		["helper"]     = 1837564092,
		["user"]       = 0,
	},

	Permissions = {
		["owner"]     = { "*" },
		["headadmin"] = { "*" },
		["admin"]     = { "sethp", "setarmor", "gethp", "getarmor", "tp", "goto", "bring", "kick", "slay", "respawn", "god", "noclip", "freeze", "cloak", "setrank", "removerank", "warn", "warnings", "clearwarnings", "ban", "unban", "mute", "unmute", "spectate", "setmodel", "strip", "help" },
		["moderator"] = { "gethp", "getarmor", "tp", "goto", "bring", "kick", "freeze", "warn", "warnings", "mute", "unmute", "help" },
		["helper"]    = { "gethp", "getarmor", "warn", "warnings", "help" },
		["user"]      = { "help" },
	},

	OnExploit = "kick",
	AllowBotActorCommands = false,
	AllowTargetBots = true,

	SetHP = {
		Min = 1,
		Max = 100000,
	},

	SetArmor = {
		Min = 0,
		Max = 100000,
	},

	Warns = {
		MaxWarns       = 3,
		ActionOnMax    = "kick",
		BanDuration    = 0,
	},

	Bans = {
		PermanentValue = 0,
	},

	Logs = {
		Enabled  = true,
	},

	Cmds      = {},
	PermCache = {},
	NameToID  = {},
}

for rankName, cmds in pairs(TKRBASE.Admin.Permissions) do
	local lookup = {}
	for _, cmd in ipairs(cmds) do
		lookup[cmd] = true
	end
	TKRBASE.Admin.PermCache[rankName] = lookup
end

for id, data in pairs(TKRBASE.Admin.Ranks) do
	TKRBASE.Admin.NameToID[data.name] = id
end

print("modules/admin/sv_config.lua | LOAD !")