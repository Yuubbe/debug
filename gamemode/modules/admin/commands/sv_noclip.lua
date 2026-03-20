gAdminRegisterCommand("noclip", {
	usage       = "!noclip [joueur]",
	description = "Activer/désactiver le noclip",
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

		local noclip = target:GetMoveType() == MOVETYPE_NOCLIP
		if noclip then
			target:SetMoveType(MOVETYPE_WALK)
			gAdminReply(actor, ("%s n'est plus en noclip."):format(target:Nick()))
		else
			target:SetMoveType(MOVETYPE_NOCLIP)
			gAdminReply(actor, ("%s est en noclip."):format(target:Nick()))
		end

		gAdminLog("Cmd", ("!noclip: %s -> %s (%s)"):format(
			IsValid(actor) and actor:Nick() or "Console", target:Nick(),
			noclip and "désactivé" or "activé"
		))
	end,
})