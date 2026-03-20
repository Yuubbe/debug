local _cfg = TKRBASE.Admin

function gAdminWarn(actor, target, reason, callback)
	if not IsValid(target) or not target:IsPlayer() then
		if callback then callback(false, "invalid_target") end
		return
	end

	local sid64    = target:SteamID64()
	local actorName = IsValid(actor) and actor:Nick() or "console"

	gAdminAddWarn(sid64, reason or "", actorName, function(saved)
		if not saved then
			if callback then callback(false, "storage_error") end
			return
		end

		gAdminGetWarns(sid64, function(warns)
			local count = #warns

			gAdminLog("Warn", ("%s -> %s (%d/%d) : %s"):format(
				actorName, target:Nick(), count, _cfg.Warns.MaxWarns, reason or ""
			))

			gAdminReply(actor, ("%s a reçu un avertissement (%d/%d) : %s"):format(
				target:Nick(), count, _cfg.Warns.MaxWarns, reason or ""
			))

			target:ChatPrint(("[ADMIN] Tu as reçu un avertissement (%d/%d) : %s"):format(
				count, _cfg.Warns.MaxWarns, reason or ""
			))

			if count >= _cfg.Warns.MaxWarns then
				local action = _cfg.Warns.ActionOnMax

				gAdminClearWarns(sid64)

				if action == "ban" then
					local duration = _cfg.Warns.BanDuration
					gAdminAddBan(sid64, "Avertissements max atteints", "system", duration, function(banned)
						if banned then
							target:Kick("Banni : avertissements max atteints. Durée : " .. gAdminFormatDuration(duration))
							gAdminBroadcast(("%s a été banni automatiquement (warns max)."):format(target:Nick()))
							gAdminLog("Warn", ("Auto-ban: %s (warns max)"):format(target:Nick()))
						end
					end)
				else
					target:Kick("Avertissements max atteints.")
					gAdminBroadcast(("%s a été expulsé automatiquement (warns max)."):format(target:Nick()))
					gAdminLog("Warn", ("Auto-kick: %s (warns max)"):format(target:Nick()))
				end
			end

			if callback then callback(true) end
		end)
	end)
end

print("modules/admin/sv_warns.lua | LOAD !")