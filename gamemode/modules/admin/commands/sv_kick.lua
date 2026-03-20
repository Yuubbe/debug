gAdminRegisterCommand("kick", {
	usage       = "!kick <joueur> [raison]",
	description = "Expulser un joueur",
	callback    = function(actor, args, rawArgs)
		if #args < 1 then
			gAdminReply(actor, gAdminErrorMsg("missing_args"))
			return
		end

		local target = gAdminResolveAndValidate(actor, args[1])
		if not target then return end

		local reason = #args > 1 and rawArgs:sub(#args[1] + 1):Trim() or "Aucune raison."

		gAdminLog("Cmd", ("!kick: %s -> %s (%s)"):format(
			IsValid(actor) and actor:Nick() or "Console", target:Nick(), reason
		))
		gAdminReply(actor, ("%s a été expulsé. (%s)"):format(target:Nick(), reason))
		target:Kick(reason)
	end,
})