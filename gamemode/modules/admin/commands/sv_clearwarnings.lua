gAdminRegisterCommand("clearwarnings", {
	usage       = "!clearwarnings <joueur>",
	description = "Effacer les avertissements d'un joueur",
	callback    = function(actor, args)
		if #args < 1 then
			gAdminReply(actor, gAdminErrorMsg("missing_args"))
			return
		end

		local target = gAdminResolveAndValidate(actor, args[1])
		if not target then return end

		gAdminClearWarns(target:SteamID64(), function(ok)
			if not ok then
				gAdminReply(actor, "Erreur lors de la suppression des avertissements.")
				return
			end

			gAdminReply(actor, ("Avertissements de %s effacés."):format(target:Nick()))
			gAdminLog("Warn", ("Warns effacés: %s par %s"):format(
				target:Nick(), IsValid(actor) and actor:Nick() or "console"
			))
		end)
	end,
})