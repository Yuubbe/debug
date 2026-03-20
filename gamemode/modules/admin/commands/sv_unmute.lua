gAdminRegisterCommand("unmute", {
	usage       = "!unmute <joueur>",
	description = "Autoriser un joueur à parler en chat",
	callback    = function(actor, args)
		if #args < 1 then
			gAdminReply(actor, gAdminErrorMsg("missing_args"))
			return
		end

		local target = gAdminResolveAndValidate(actor, args[1])
		if not target then return end

		if not target:GetNWBool("adminMuted", false) then
			gAdminReply(actor, target:Nick() .. " n'est pas muet.")
			return
		end

		target:SetNWBool("adminMuted", false)
		gAdminReply(actor, ("%s peut à nouveau parler."):format(target:Nick()))
		target:ChatPrint("[ADMIN] Tu peux à nouveau parler.")
		gAdminLog("Cmd", ("!unmute: %s -> %s"):format(
			IsValid(actor) and actor:Nick() or "Console", target:Nick()
		))
	end,
})