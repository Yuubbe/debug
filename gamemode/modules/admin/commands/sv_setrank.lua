gAdminRegisterCommand("setrank", {
	usage       = "!setrank <joueur> <rankID>",
	description = "Définir le rank d'un joueur",
	callback    = function(actor, args)
		if #args < 2 then
			gAdminReply(actor, gAdminErrorMsg("missing_args"))
			return
		end

		local target = gAdminResolveAndValidate(actor, args[1])
		if not target then return end

		local rankID = tonumber(args[2])
		if not rankID then
			gAdminReply(actor, gAdminErrorMsg("invalid_number"))
			return
		end

		if not TKRBASE.Admin.Ranks[rankID] then
			gAdminReply(actor, gAdminErrorMsg("invalid_rank"))
			return
		end

		local actorPower     = gAdminGetRankPower(actor)
		local targetNewPower = TKRBASE.Admin.Ranks[rankID].power
		local targetCurPower = gAdminGetRankPower(target)

		if actorPower >= targetNewPower then
			gAdminHandleExploit(IsValid(actor) and actor or nil, "setrank vers rank supérieur ou égal")
			return
		end

		if actorPower >= targetCurPower and actor ~= target then
			gAdminHandleExploit(IsValid(actor) and actor or nil, "setrank d'un joueur de rang égal ou supérieur")
			return
		end

		gAdminSetRank(target, rankID, IsValid(actor) and actor:Nick() or "console", function(ok, err)
			if not ok then
				gAdminReply(actor, gAdminErrorMsg(err))
				return
			end

			gAdminReply(actor, ("%s — Rank défini à %s."):format(
				target:Nick(), TKRBASE.Admin.Ranks[rankID].name
			))
			gAdminReply(target, ("Ton rank a été défini à %s."):format(
				TKRBASE.Admin.Ranks[rankID].name
			))
		end)
	end,
})