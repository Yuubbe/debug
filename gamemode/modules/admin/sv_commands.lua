local _cfg     = TKRBASE.Admin
local PREFIXES = {"!", "/"}

function gAdminRegisterCommand(name, opts)
	if not name or name == "" then
		ErrorNoHalt("[ADMIN] RegisterCommand: nom vide\n")
		return
	end

	name = string.lower(name)
	opts = opts or {}

	if type(opts.callback) ~= "function" then
		ErrorNoHalt("[ADMIN] RegisterCommand '" .. name .. "': callback manquant\n")
		return
	end

	opts.usage       = opts.usage or ("!" .. name)
	opts.description = opts.description or ""
	opts.aliases     = opts.aliases or {}
	opts.primary     = name

	_cfg.Cmds[name] = opts

	for _, alias in ipairs(opts.aliases) do
		_cfg.Cmds[string.lower(alias)] = opts
	end
end

local function gParseInput(text)
	local tokens = {}
	for token in string.gmatch(text, "%S+") do
		tokens[#tokens + 1] = token
	end
	local cmdName = table.remove(tokens, 1)
	local rawArgs = text:sub(#cmdName + 1):Trim()
	return cmdName, tokens, rawArgs
end

local function gDispatch(actor, cmdName, args, rawArgs)
	cmdName = string.lower(cmdName or "")

	local cmd = _cfg.Cmds[cmdName]
	if not cmd then
		gAdminReply(actor, gAdminErrorMsg("unknown_command"))
		return false
	end

	if not gAdminHasCommand(actor, cmd.primary) then
		gAdminReply(actor, gAdminErrorMsg("no_permission"))
		gAdminLog("Cmd", ("Refusé: %s -> !%s"):format(
			IsValid(actor) and actor:Nick() or "console", cmdName
		))
		return false
	end

	local ok, err = pcall(cmd.callback, actor, args, rawArgs)
	if not ok then
		gAdminLog("Cmd", ("Erreur !%s: %s"):format(cmdName, tostring(err)))
		gAdminReply(actor, "Erreur interne lors de l'exécution de !" .. cmdName .. ".")
		return false
	end

	return true
end

gAdminDispatch = gDispatch

function gAdminResolveTarget(actor, query)
	if not query or query == "" then
		gAdminReply(actor, gAdminErrorMsg("empty_query"))
		return nil
	end

	local target, errCode, matches = gAdminFindPlayer(query)
	if not target then
		gAdminReply(actor, gAdminErrorMsg(errCode))
		if errCode == "ambiguous" and matches then
			local shown = {}
			for i = 1, math.min(#matches, 5) do
				shown[#shown + 1] = matches[i]:Nick()
			end
			gAdminReply(actor, "Correspondances : " .. table.concat(shown, ", ") .. (#matches > 5 and " ..." or ""))
		end
		return nil
	end

	return target
end

function gAdminResolveAndValidate(actor, query)
	local target = gAdminResolveTarget(actor, query)
	if not target then return nil end

	local ok, errCode = gAdminValidateInteraction(actor, target)
	if not ok then
		gAdminReply(actor, gAdminErrorMsg(errCode))
		return nil
	end

	return target
end

hook.Add("PlayerSay", "gAdmin.ChatCommands", function(ply, text)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if ply:IsBot() and not _cfg.AllowBotActorCommands then return end

	text = text:Trim()
	if text == "" then return end

	local prefix
	for _, p in ipairs(PREFIXES) do
		if text:sub(1, #p) == p then
			prefix = p
			break
		end
	end
	if not prefix then return end

	local stripped = text:sub(#prefix + 1):Trim()
	if stripped == "" then return end

	local cmdName, args, rawArgs = gParseInput(stripped)
	gDispatch(ply, cmdName, args, rawArgs)
	return ""
end)

concommand.Add("tkr", function(ply, _, args, argStr)
	local actor = IsValid(ply) and ply or nil
	if #args == 0 then
		gAdminReply(actor, "Usage: tkr <commande> [args...]")
		return
	end

	local cmdName = table.remove(args, 1)
	local rawArgs = (argStr or ""):Trim()
	local space   = rawArgs:find("%s")
	rawArgs = space and rawArgs:sub(space):Trim() or ""

	gDispatch(actor, cmdName, args, rawArgs)
end)

hook.Add("ShowHelp", "gAdmin.ShowHelp", function(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end

	if gAdminHasCommand(ply, "admin") then
		gAdminSendPerms(ply)
		return
	end

	local lines  = {"--- Commandes disponibles ---"}
	local sorted = {}
	local seen   = {}

	for name, cmd in pairs(_cfg.Cmds) do
		if name == cmd.primary and not seen[cmd.primary] then
			seen[cmd.primary] = true
			sorted[#sorted + 1] = { name = name, cmd = cmd }
		end
	end
	table.sort(sorted, function(a, b) return a.name < b.name end)

	for _, entry in ipairs(sorted) do
		if gAdminHasCommand(ply, entry.name) then
			local tag = entry.cmd.usage
			if entry.cmd.description ~= "" then
				tag = tag .. " - " .. entry.cmd.description
			end
			if #entry.cmd.aliases > 0 then
				tag = tag .. " (alias: " .. table.concat(entry.cmd.aliases, ", ") .. ")"
			end
			lines[#lines + 1] = tag
		end
	end

	lines[#lines + 1] = "---"
	for _, line in ipairs(lines) do
		ply:ChatPrint(line)
	end
end)

gAdminRegisterCommand("help", {
	usage       = "!help",
	description = "Affiche les commandes disponibles",
	callback    = function(actor)
		if actor == nil then
			gAdminReply(actor, "Utilise: tkr help (ou F10 en jeu).")
			return
		end
		if not IsValid(actor) or not actor:IsPlayer() then return end
		hook.Run("ShowHelp", actor)
	end,
})

local cmdFiles = file.Find("gamemodes/mangarp/gamemode/modules/admin/commands/*.lua", "GAME")
for _, f in ipairs(cmdFiles or {}) do
	local ok, err = pcall(include, "mangarp/gamemode/modules/admin/commands/" .. f)
	if ok then
		print("modules/admin/commands/" .. f .. " | LOAD !")
	else
		MsgC(Color(255, 80, 80), "modules/admin/commands/" .. f .. " | ERROR : " .. tostring(err) .. "\n")
	end
end

print("modules/admin/sv_commands.lua | LOAD !")