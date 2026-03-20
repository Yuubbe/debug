gAdminRegisterCommand("spectate", {
	usage       = "!spectate <joueur>",
	description = "Se mettre en spectateur sur un joueur",
	callback    = function(actor, args)
		if not IsValid(actor) then
			gAdminReply(actor, "La console ne peut pas utiliser !spectate.")
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

		if actor:GetObserverMode() ~= OBS_MODE_NONE and actor:GetObserverTarget() == target then
			actor:UnSpectate()
			actor:Spawn()
			gAdminReply(actor, ("Tu n'es plus en spectateur sur %s."):format(target:Nick()))
			gAdminLog("Cmd", ("!spectate stop: %s -> %s"):format(actor:Nick(), target:Nick()))
			return
		end

		actor:Spectate(OBS_MODE_IN_EYE)
		actor:SpectateEntity(target)
		gAdminReply(actor, ("Tu es maintenant en spectateur sur %s."):format(target:Nick()))
		gAdminLog("Cmd", ("!spectate: %s -> %s"):format(actor:Nick(), target:Nick()))
	end,
})