gAdminRegisterCommand("giveweapon", {
	usage       = "!giveweapon <joueur> <classname>",
	description = "Donner une arme à un joueur",
	callback    = function(actor, args)
		if #args < 2 then
			gAdminReply(actor, gAdminErrorMsg("missing_args"))
			return
		end

		local target = gAdminResolveAndValidate(actor, args[1])
		if not target then return end

		if not target:Alive() then
			gAdminReply(actor, target:Nick() .. " est mort.")
			return
		end

		local classname = args[2]

		if not weapons.GetStored(classname) then
			gAdminReply(actor, "Arme invalide : " .. classname)
			return
		end

		target:Give(classname)
		gAdminReply(actor, ("%s a reçu %s."):format(target:Nick(), classname))
		gAdminLog("Cmd", ("!giveweapon: %s -> %s (%s)"):format(
			IsValid(actor) and actor:Nick() or "Console", target:Nick(), classname
		))
	end,
})