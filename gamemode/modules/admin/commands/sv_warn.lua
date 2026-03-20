gAdminRegisterCommand("warn", {
	usage       = "!warn <joueur> [raison]",
	description = "Avertir un joueur",
	callback    = function(actor, args, rawArgs)
		if #args < 1 then
			gAdminReply(actor, gAdminErrorMsg("missing_args"))
			return
		end

		local target = gAdminResolveAndValidate(actor, args[1])
		if not target then return end

		local reason = #args > 1 and rawArgs:sub(#args[1] + 1):Trim() or "Aucune raison."

		gAdminWarn(actor, target, reason, function(ok, err)
			if not ok then
				gAdminReply(actor, gAdminErrorMsg(err))
			end
		end)
	end,
})