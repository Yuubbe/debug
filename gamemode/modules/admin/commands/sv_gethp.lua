gAdminRegisterCommand("gethp", {
	usage       = "!gethp <joueur>",
	description = "Afficher la vie d'un joueur",
	callback    = function(actor, args)
		if #args < 1 then
			gAdminReply(actor, gAdminErrorMsg("missing_args"))
			return
		end

		local target = gAdminResolveTarget(actor, args[1])
		if not target then return end

		gAdminReply(actor, ("%s — Vie : %d / %d"):format(
			target:Nick(), target:Health(), target:GetMaxHealth()
		))
	end,
})