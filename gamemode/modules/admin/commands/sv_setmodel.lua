gAdminRegisterCommand("setmodel", {
	usage       = "!setmodel <joueur> <model>",
	description = "Changer le modèle d'un joueur",
	callback    = function(actor, args)
		if #args < 2 then
			gAdminReply(actor, gAdminErrorMsg("missing_args"))
			return
		end

		local target = gAdminResolveAndValidate(actor, args[1])
		if not target then return end

		local model = args[2]

		if not util.IsValidModel(model) then
			gAdminReply(actor, "Modèle invalide.")
			return
		end

		target:SetModel(model)
		gAdminReply(actor, ("%s — Modèle défini à %s."):format(target:Nick(), model))
		gAdminLog("Cmd", ("!setmodel: %s -> %s (%s)"):format(
			IsValid(actor) and actor:Nick() or "Console", target:Nick(), model
		))
	end,
})