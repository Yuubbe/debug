gAdminRegisterCommand("goto", {
	usage       = "!goto <joueur>",
	description = "Se téléporter sur un joueur",
	callback    = function(actor, args)
		if not IsValid(actor) then
			gAdminReply(actor, "La console ne peut pas utiliser !goto.")
			return
		end

		if #args < 1 then
			gAdminReply(actor, gAdminErrorMsg("missing_args"))
			return
		end

		local target = gAdminResolveTarget(actor, args[1])
		if not target then return end

		if not target:Alive() then
			gAdminReply(actor, target:Nick() .. " est mort.")
			return
		end

		actor:SetPos(target:GetPos() + target:GetForward() * 100 + Vector(0, 0, 10))
		gAdminReply(actor, ("Téléporté sur %s."):format(target:Nick()))
		gAdminLog("Cmd", ("!goto: %s -> %s"):format(actor:Nick(), target:Nick()))
	end,
})