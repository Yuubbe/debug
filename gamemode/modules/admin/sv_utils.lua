local function gNow()
	return os.date("[%H:%M:%S]")
end

local ERROR_MESSAGES = {
	["empty_query"]       = "Aucun joueur n'a été spécifié.",
	["no_match"]          = "Aucun joueur ne correspond à ce nom.",
	["ambiguous"]         = "Plusieurs joueurs correspondent, sois plus précis.",
	["invalid_actor"]     = "Source de commande invalide.",
	["invalid_target"]    = "Joueur cible invalide.",
	["invalid_player"]    = "Joueur invalide.",
	["insufficient_rank"] = "Tu ne peux pas cibler un joueur de rang égal ou supérieur.",
	["missing_args"]      = "Arguments manquants.",
	["invalid_number"]    = "Nombre invalide.",
	["no_permission"]     = "Tu n'as pas la permission d'utiliser cette commande.",
	["unknown_command"]   = "Commande inconnue. Utilise !help pour la liste.",
	["invalid_rank"]      = "ID de rank invalide.",
	["already_banned"]    = "Ce joueur est déjà banni.",
	["not_banned"]        = "Ce joueur n'est pas banni.",
}

function gAdminErrorMsg(code)
	return ERROR_MESSAGES[code] or tostring(code)
end

function gAdminLog(scope, msg)
	MsgC(
		Color(150, 150, 150), gNow(), " ",
		Color(255, 255, 255), "[",
		Color(255, 200, 100), "ADMIN",
		Color(255, 255, 255), "] ",
		Color(200, 200, 255), tostring(scope or "Admin"),
		Color(255, 255, 255), " - ",
		Color(255, 255, 255), tostring(msg or ""), "\n"
	)

	gAdminSaveLog(scope, msg)
end

function gAdminBroadcast(text)
	text = "[ADMIN] " .. tostring(text or "")
	for _, ply in ipairs(player.GetAll()) do
		ply:ChatPrint(text)
	end
	print(text)
end

function gAdminReply(actor, text)
	text = "[ADMIN] " .. tostring(text or "")
	if actor == nil then
		print(text)
		return
	end
	if IsValid(actor) and actor:IsPlayer() then
		actor:ChatPrint(text)
		return
	end
	print(text)
end

function gAdminHandleExploit(ply, reason)
	local action = tostring(TKRBASE.Admin.OnExploit or "kick")
	reason = tostring(reason or "exploit")

	gAdminLog("Exploit", ("Suspect: %s (%s) action=%s"):format(
		IsValid(ply) and ply:Nick() or "?", reason, action
	))

	if not IsValid(ply) or not ply:IsPlayer() then return end
	if action == "ignore" then return end
	ply:Kick("Exploit: " .. reason)
end

function gAdminFindPlayer(query)
	query = tostring(query or ""):Trim()
	if query == "" then return nil, "empty_query" end

	if #query == 17 and query:match("^%d+$") then
		for _, ply in ipairs(player.GetAll()) do
			if ply:SteamID64() == query then return ply end
		end
		return nil, "no_match"
	end

	local qlow = string.lower(query)
	local matches = {}
	for _, ply in ipairs(player.GetAll()) do
		if string.find(string.lower(ply:Nick()), qlow, 1, true) then
			matches[#matches + 1] = ply
		end
	end

	if #matches == 1 then return matches[1] end
	if #matches == 0 then return nil, "no_match" end
	return nil, "ambiguous", matches
end

function gAdminParseNumber(str, min, max)
	local n = tonumber(str)
	if not n then return nil end
	n = math.floor(n)
	if min and n < min then n = min end
	if max and n > max then n = max end
	return n
end

function gAdminFormatDuration(seconds)
	seconds = tonumber(seconds) or 0
	if seconds <= 0 then return "permanent" end
	local days    = math.floor(seconds / 86400)
	local hours   = math.floor((seconds % 86400) / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs    = seconds % 60
	local parts   = {}
	if days > 0    then parts[#parts + 1] = days    .. "j" end
	if hours > 0   then parts[#parts + 1] = hours   .. "h" end
	if minutes > 0 then parts[#parts + 1] = minutes .. "m" end
	if secs > 0    then parts[#parts + 1] = secs    .. "s" end
	return table.concat(parts, " ")
end

function gAdminParseDuration(str)
	if not str or str == "" or str == "0" or str == "perm" or str == "permanent" then
		return 0
	end
	local total = 0
	for value, unit in string.gmatch(str, "(%d+)([jhdms])") do
		value = tonumber(value)
		if unit == "j" then total = total + value * 86400
		elseif unit == "h" then total = total + value * 3600
		elseif unit == "d" then total = total + value * 86400
		elseif unit == "m" then total = total + value * 60
		elseif unit == "s" then total = total + value
		end
	end
	return total
end

print("modules/admin/sv_utils.lua | LOAD !")