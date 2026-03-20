gAdminRegisterCommand("strip", {
	usage       = "!strip <joueur>",
	description = "Retirer toutes les armes d'un joueur",
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

		target:StripWeapons()
		gAdminReply(actor, ("%s a été désarmé."):format(target:Nick()))
		gAdminLog("Cmd", ("!strip: %s -> %s"):format(
			IsValid(actor) and actor:Nick() or "Console", target:Nick()
		))
	end,
})