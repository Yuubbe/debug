gAdminRegisterCommand("removerank", {
	usage       = "!removerank <joueur>",
	description = "Supprimer le rank stocké d'un joueur et le repasser user",
	callback    = function(actor, args)
		if #args < 1 then
			gAdminReply(actor, gAdminErrorMsg("missing_args"))
			return
		end

		local target = gAdminResolveAndValidate(actor, args[1])
		if not target then return end

		local sid64 = target:SteamID64()

		gAdminDeleteRank(sid64, function(ok)
			if not ok then
				gAdminReply(actor, "Erreur lors de la suppression du rank.")
				return
			end

			local defID   = TKRBASE.Admin.DefaultRankID
			local defName = TKRBASE.Admin.Ranks[defID] and TKRBASE.Admin.Ranks[defID].name or "user"

			target:SetUserGroup(defName)

			gAdminReply(actor, ("%s a été repassé %s et son rank supprimé."):format(target:Nick(), defName))
			gAdminLog("Rank", ("!removerank: %s -> %s par %s"):format(
				target:Nick(), defName, IsValid(actor) and actor:Nick() or "console"
			))
		end)
	end,
})