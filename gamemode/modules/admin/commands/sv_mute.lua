gAdminRegisterCommand("mute", {
	usage       = "!mute <joueur>",
	description = "Empêcher un joueur de parler en chat",
	callback    = function(actor, args)
		if #args < 1 then
			gAdminReply(actor, gAdminErrorMsg("missing_args"))
			return
		end

		local target = gAdminResolveAndValidate(actor, args[1])
		if not target then return end

		if target:GetNWBool("adminMuted", false) then
			gAdminReply(actor, target:Nick() .. " est déjà muet.")
			return
		end

		target:SetNWBool("adminMuted", true)
		gAdminReply(actor, ("%s a été rendu muet."):format(target:Nick()))
		target:ChatPrint("[ADMIN] Tu as été rendu muet.")
		gAdminLog("Cmd", ("!mute: %s -> %s"):format(
			IsValid(actor) and actor:Nick() or "Console", target:Nick()
		))
	end,
})

hook.Add("PlayerSay", "gAdmin.Mute", function(ply, text)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if not ply:GetNWBool("adminMuted", false) then return end

	ply:ChatPrint("[ADMIN] Tu es muet et ne peux pas parler.")
	return ""
end)