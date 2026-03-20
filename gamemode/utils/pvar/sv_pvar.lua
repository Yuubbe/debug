TKRBASE.PlayerData = {}

util.AddNetworkString("gSetVar")

function gSetVar(ply, key, value)
	if not IsValid(ply) then return end
	TKRBASE.PlayerData[ply] = TKRBASE.PlayerData[ply] or {}
	TKRBASE.PlayerData[ply][key] = value

	net.Start("gSetVar")
		net.WriteString(key)
		net.WriteType(value)
	net.Send(ply)
end

function gGetVar(ply, key)
	if not IsValid(ply) then return nil end
	local data = TKRBASE.PlayerData[ply]
	return data and data[key] or nil
end

hook.Add("PlayerDisconnected", "gClearPlayerData", function(ply)
	TKRBASE.PlayerData[ply] = nil
end)


print("utils/pvar/sv_pvar.lua | LOAD !")