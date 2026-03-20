gAdminRegisterCommand("warnings", {
	usage       = "!warnings <joueur>",
	description = "Consulter les avertissements d'un joueur",
	callback    = function(actor, args)
		if #args < 1 then
			gAdminReply(actor, gAdminErrorMsg("missing_args"))
			return
		end

		local target = gAdminResolveTarget(actor, args[1])
		if not target then return end

		gAdminGetWarns(target:SteamID64(), function(warns)
			if #warns == 0 then
				gAdminReply(actor, ("%s n'a aucun avertissement."):format(target:Nick()))
				return
			end

			gAdminReply(actor, ("%s — %d avertissement(s) :"):format(target:Nick(), #warns))
			for i, warn in ipairs(warns) do
				gAdminReply(actor, ("[%d] %s | par %s | %s"):format(
					i,
					tostring(warn.reason or ""),
					tostring(warn.given_by or "system"),
					os.date("%d/%m/%Y %H:%M", tonumber(warn.given_at) or 0)
				))
			end
		end)
	end,
})