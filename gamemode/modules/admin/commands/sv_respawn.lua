gAdminRegisterCommand("respawn", {
	usage       = "!respawn <joueur>",
	description = "Faire réapparaître un joueur",
	callback    = function(actor, args)
		if #args < 1 then
			gAdminReply(actor, gAdminErrorMsg("missing_args"))
			return
		end

		local target = gAdminResolveAndValidate(actor, args[1])
		if not target then return end

		target:Spawn()
		gAdminReply(actor, ("%s a été réapparu."):format(target:Nick()))
		gAdminLog("Cmd", ("!respawn: %s -> %s"):format(
			IsValid(actor) and actor:Nick() or "Console", target:Nick()
		))
	end,
})