gAdminRegisterCommand("tp", {
	usage       = "!tp <joueur> <cible>",
	description = "Téléporter un joueur sur une cible",
	callback    = function(actor, args)
		if #args < 2 then
			gAdminReply(actor, gAdminErrorMsg("missing_args"))
			return
		end

		local target = gAdminResolveAndValidate(actor, args[1])
		if not target then return end

		local dest = gAdminResolveTarget(actor, args[2])
		if not dest then return end

		if not target:Alive() then
			gAdminReply(actor, target:Nick() .. " est mort.")
			return
		end

		if not dest:Alive() then
			gAdminReply(actor, dest:Nick() .. " est mort.")
			return
		end

		target:SetPos(dest:GetPos() + dest:GetForward() * 100 + Vector(0, 0, 10))
		gAdminReply(actor, ("%s a été téléporté sur %s."):format(target:Nick(), dest:Nick()))
		gAdminLog("Cmd", ("!tp: %s -> %s -> %s"):format(
			IsValid(actor) and actor:Nick() or "Console", target:Nick(), dest:Nick()
		))
	end,
})