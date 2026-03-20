gAdminRegisterCommand("cloak", {
	usage       = "!cloak [joueur]",
	description = "Activer/désactiver l'invisibilité",
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

		local cloaked = target:GetColor().a < 255
		if cloaked then
			target:SetColor(Color(255, 255, 255, 255))
			target:SetRenderMode(RENDERMODE_NORMAL)
			target:SetNoDraw(false)
			target:DrawShadow(true)
			gAdminReply(actor, ("%s n'est plus invisible."):format(target:Nick()))
		else
			target:SetColor(Color(255, 255, 255, 0))
			target:SetRenderMode(RENDERMODE_TRANSALPHA)
			target:SetNoDraw(true)
			target:DrawShadow(false)
			gAdminReply(actor, ("%s est maintenant invisible."):format(target:Nick()))
		end

		gAdminLog("Cmd", ("!cloak: %s -> %s (%s)"):format(
			IsValid(actor) and actor:Nick() or "Console", target:Nick(),
			cloaked and "visible" or "invisible"
		))
	end,
})