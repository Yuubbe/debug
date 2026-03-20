gAdminRegisterCommand("freeze", {
	usage       = "!freeze <joueur>",
	description = "Geler/dégeler un joueur",
	callback    = function(actor, args)
		if #args < 1 then
			gAdminReply(actor, gAdminErrorMsg("missing_args"))
			return
		end

		local target = gAdminResolveAndValidate(actor, args[1])
		if not target then return end

		if not target:Alive() then
			gAdminReply(actor, target:Nick() .. " est mort.")
			return
		end

		local frozen = target:IsFlagSet(FL_FROZEN)
		if frozen then
			target:RemoveFlags(FL_FROZEN)
			target:SetMoveType(MOVETYPE_WALK)
			gAdminReply(actor, ("%s n'est plus gelé."):format(target:Nick()))
		else
			target:AddFlags(FL_FROZEN)
			target:SetMoveType(MOVETYPE_NONE)
			gAdminReply(actor, ("%s est gelé."):format(target:Nick()))
		end

		gAdminLog("Cmd", ("!freeze: %s -> %s (%s)"):format(
			IsValid(actor) and actor:Nick() or "Console", target:Nick(),
			frozen and "dégelé" or "gelé"
		))
	end,
})