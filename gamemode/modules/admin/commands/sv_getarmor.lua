gAdminRegisterCommand("getarmor", {
	usage       = "!getarmor <joueur>",
	description = "Afficher l'armure d'un joueur",
	callback    = function(actor, args)
		if #args < 1 then
			gAdminReply(actor, gAdminErrorMsg("missing_args"))
			return
		end

		local target = gAdminResolveTarget(actor, args[1])
		if not target then return end

		gAdminReply(actor, ("%s — Armure : %d"):format(target:Nick(), target:Armor()))
	end,
})