gAdminRegisterCommand("ban", {
	usage       = "!ban <joueur> <durée> [raison]",
	description = "Bannir un joueur (0/perm = permanent, ex: 1j2h30m)",
	callback    = function(actor, args, rawArgs)
		if #args < 2 then
			gAdminReply(actor, gAdminErrorMsg("missing_args"))
			return
		end

		local target = gAdminResolveAndValidate(actor, args[1])
		if not target then return end

		local duration = gAdminParseDuration(args[2])
		local reason   = #args > 2 and rawArgs:sub(#args[1] + #args[2] + 2):Trim() or "Aucune raison."

		gAdminBan(actor, target, duration, reason, function(ok, err)
			if not ok then
				gAdminReply(actor, gAdminErrorMsg(err))
			end
		end)
	end,
})