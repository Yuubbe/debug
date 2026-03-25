local _cfg      = TKRBASE.Admin
local _cooldown = {}

util.AddNetworkString("gAdmin.Perms")
util.AddNetworkString("gAdmin.RequestPerms")
util.AddNetworkString("gAdmin.Cmd")
util.AddNetworkString("gAdmin.RequestWarns")
util.AddNetworkString("gAdmin.Warns")
util.AddNetworkString("gAdmin.RequestLogs")
util.AddNetworkString("gAdmin.Logs")
util.AddNetworkString("gAdmin.RequestAllWarns")
util.AddNetworkString("gAdmin.AllWarns")

function gAdminSendPerms(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end

	local sid64 = ply:SteamID64()
	if _cooldown[sid64] and _cooldown[sid64] > CurTime() then return end
	_cooldown[sid64] = CurTime() + 0.5

	local cmds = {}
	local seen = {}
	for name, cmd in pairs(_cfg.Cmds) do
		if name == cmd.primary and not seen[name] then
			seen[name] = true
			if gAdminHasCommand(ply, name) then
				cmds[#cmds + 1] = name
			end
		end
	end

	net.Start("gAdmin.Perms")
	net.WriteUInt(#cmds, 8)
	for _, c in ipairs(cmds) do
		net.WriteString(c)
	end
	net.Send(ply)
end

net.Receive("gAdmin.RequestPerms", function(_, ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if not gAdminHasCommand(ply, "admin") then return end
	gAdminSendPerms(ply)
end)

net.Receive("gAdmin.Cmd", function(_, ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end

	local cmdName   = net.ReadString()
	local targetSID = net.ReadString()
	local extra     = net.ReadString()

	if not cmdName or cmdName == "" then return end
	if #cmdName > 32 or #targetSID > 20 or #extra > 256 then
		gAdminHandleExploit(ply, "net_overflow")
		return
	end

	local args    = {}
	local rawArgs = ""

	if targetSID ~= "" then
		args[1]  = targetSID
		rawArgs  = targetSID
	end

	if extra ~= "" then
		args[#args + 1] = extra
		rawArgs = rawArgs ~= "" and (rawArgs .. " " .. extra) or extra
	end

	gAdminDispatch(ply, cmdName, args, rawArgs)
end)

net.Receive("gAdmin.RequestWarns", function(_, ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if not gAdminHasCommand(ply, "warnings") then return end

	local sid64 = ply:SteamID64()
	if _cooldown[sid64 .. "_w"] and _cooldown[sid64 .. "_w"] > CurTime() then return end
	_cooldown[sid64 .. "_w"] = CurTime() + 0.5

	local targetSID = net.ReadString()
	if not targetSID or #targetSID ~= 17 then return end

	gAdminGetWarns(targetSID, function(warns)
		if not IsValid(ply) then return end

		local count = math.min(#warns, 50)

		net.Start("gAdmin.Warns")
		net.WriteString(targetSID)
		net.WriteUInt(count, 8)
		for i = 1, count do
			local w = warns[i]
			net.WriteString(tostring(w.reason or ""))
			net.WriteString(tostring(w.given_by or "system"))
			net.WriteUInt(tonumber(w.given_at) or 0, 32)
		end
		net.Send(ply)
	end)
end)

net.Receive("gAdmin.RequestAllWarns", function(_, ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if not gAdminHasCommand(ply, "warnings") then
		net.Start("gAdmin.AllWarns")
		net.WriteBool(true)
		net.Send(ply)
		return
	end

	local sid64 = ply:SteamID64()
	if _cooldown[sid64 .. "_aw"] and _cooldown[sid64 .. "_aw"] > CurTime() then return end
	_cooldown[sid64 .. "_aw"] = CurTime() + 1

	local page = math.Clamp(net.ReadUInt(16), 0, 9999)
	local perPage = 50

	gAdminCountAllWarns(function(total)
		gAdminGetAllWarns(perPage, page * perPage, function(rows)
			if not IsValid(ply) then return end

			rows = rows or {}
			local count = math.min(#rows, perPage)

			net.Start("gAdmin.AllWarns")
			net.WriteBool(false)
			net.WriteUInt(total, 32)
			net.WriteUInt(page, 16)
			net.WriteUInt(count, 8)
			for i = 1, count do
				local w = rows[i]
				net.WriteUInt(tonumber(w.id) or 0, 32)
				net.WriteString(string.sub(tostring(w.steamid64 or ""), 1, 20))
				net.WriteString(string.sub(tostring(w.reason or ""), 1, 300))
				net.WriteString(string.sub(tostring(w.given_by or "system"), 1, 64))
				net.WriteUInt(tonumber(w.given_at) or 0, 32)
			end
			net.Send(ply)
		end)
	end)
end)

net.Receive("gAdmin.RequestLogs", function(_, ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if not gAdminHasCommand(ply, "admin") then
		net.Start("gAdmin.Logs")
		net.WriteBool(true)
		net.Send(ply)
		return
	end

	local sid64 = ply:SteamID64()
	if _cooldown[sid64 .. "_l"] and _cooldown[sid64 .. "_l"] > CurTime() then return end
	_cooldown[sid64 .. "_l"] = CurTime() + 1

	local page  = math.Clamp(net.ReadUInt(16), 0, 9999)
	local scope = net.ReadString()
	if #scope > 32 then scope = "" end

	local perPage = 50

	gAdminCountLogs(scope, function(total)
		gAdminGetLogs(perPage, page * perPage, scope, function(logs)
			if not IsValid(ply) then return end

			local count = math.min(#logs, perPage)

			net.Start("gAdmin.Logs")
			net.WriteBool(false)
			net.WriteUInt(total, 32)
			net.WriteUInt(page, 16)
			net.WriteUInt(count, 8)
			for i = 1, count do
				local l = logs[i]
				net.WriteString(tostring(l.scope or ""))
				net.WriteString(tostring(l.msg or ""))
				net.WriteUInt(tonumber(l.created_at) or 0, 32)
			end
			net.Send(ply)
		end)
	end)
end)

gAdminRegisterCommand("admin", {
	usage       = "!admin",
	description = "Ouvrir le panneau d'administration",
	callback    = function(actor)
		if actor == nil then
			gAdminReply(actor, "Commande joueur uniquement.")
			return
		end
		if not IsValid(actor) or not actor:IsPlayer() then return end
		gAdminSendPerms(actor)
	end,
})

hook.Add("PlayerDisconnected", "gAdmin.CleanCooldown", function(ply)
	local sid = ply:SteamID64()
	_cooldown[sid] = nil
	_cooldown[sid .. "_w"] = nil
	_cooldown[sid .. "_l"] = nil
	_cooldown[sid .. "_aw"] = nil
end)

print("modules/admin/sv_admin_net.lua | LOAD !")
