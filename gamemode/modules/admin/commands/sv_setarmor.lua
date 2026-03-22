gAdminRegisterCommand("setarmor", {
	usage       = "!setarmor <joueur> <valeur>",
	description = "Définir l'armure d'un joueur",
	callback    = function(actor, args)
		if #args < 2 then
			gAdminReply(actor, gAdminErrorMsg("missing_args"))
			return
		end

		local target = gAdminResolveAndValidate(actor, args[1])
		if not target then return end

		local cfg   = TKRBASE.Admin.SetArmor
		local value = gAdminParseNumber(args[2], cfg.Min, cfg.Max)
		if not value then
			gAdminReply(actor, gAdminErrorMsg("invalid_number"))
			return
		end

		if not target:Alive() then
			gAdminReply(actor, target:Nick() .. " est mort.")
			return
		end

		target:SetArmor(value)
		gAdminReply(actor, ("%s — Armure définie à %d."):format(target:Nick(), value))
		gAdminLog("Cmd", ("!setarmor: %s -> %s (%d)"):format(
			IsValid(actor) and actor:Nick() or "Console", target:Nick(), value
		))
	end,
})