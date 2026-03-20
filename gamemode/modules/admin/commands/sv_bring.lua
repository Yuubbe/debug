gAdminRegisterCommand("bring", {
	usage       = "!bring <joueur>",
	description = "Ramener un joueur sur toi",
	callback    = function(actor, args)
		if not IsValid(actor) then
			gAdminReply(actor, "La console ne peut pas utiliser !bring.")
			return
		end

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

		target:SetPos(actor:GetPos() + actor:GetForward() * 100 + Vector(0, 0, 10))
		gAdminReply(actor, ("%s a été ramené."):format(target:Nick()))
		gAdminLog("Cmd", ("!bring: %s <- %s"):format(actor:Nick(), target:Nick()))
	end,
})