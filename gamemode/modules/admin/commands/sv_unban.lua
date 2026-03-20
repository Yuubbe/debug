gAdminRegisterCommand("unban", {
	usage       = "!unban <steamid64>",
	description = "Débannir un joueur via son SteamID64",
	callback    = function(actor, args)
		if #args < 1 then
			gAdminReply(actor, gAdminErrorMsg("missing_args"))
			return
		end

		local steamid64 = args[1]

		if #steamid64 ~= 17 or not steamid64:match("^%d+$") then
			gAdminReply(actor, "SteamID64 invalide.")
			return
		end

		gAdminUnban(actor, steamid64, function(ok, err)
			if not ok then
				gAdminReply(actor, gAdminErrorMsg(err))
				return
			end

			gAdminReply(actor, ("Joueur %s débanni."):format(steamid64))
		end)
	end,
})