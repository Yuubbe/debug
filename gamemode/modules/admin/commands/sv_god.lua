gAdminRegisterCommand("god", {
	usage       = "!god [joueur]",
	description = "Activer/désactiver le mode dieu",
	callback    = function(actor, args)
		local target
		if #args >= 1 then
			target = gAdminResolveAndValidate(actor, args[1])
			if not target then return end
		else
			if not IsValid(actor) then
				gAdminReply(actor, gAdminErrorMsg("missing_args"))
				return
			end
			target = actor
		end

		if not target:Alive() then
			gAdminReply(actor, target:Nick() .. " est mort.")
			return
		end

		local god = target:HasGodMode()
		if god then
			target:GodDisable()
			gAdminReply(actor, ("%s n'est plus en mode dieu."):format(target:Nick()))
		else
			target:GodEnable()
			gAdminReply(actor, ("%s est en mode dieu."):format(target:Nick()))
		end

		gAdminLog("Cmd", ("!god: %s -> %s (%s)"):format(
			IsValid(actor) and actor:Nick() or "Console", target:Nick(),
			god and "désactivé" or "activé"
		))
	end,
})