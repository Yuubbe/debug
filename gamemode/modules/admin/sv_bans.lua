local _cfg = TKRBASE.Admin

function gAdminBan(actor, target, duration, reason, callback)
	if not IsValid(target) or not target:IsPlayer() then
		if callback then callback(false, "invalid_target") end
		return
	end

	local sid64     = target:SteamID64()
	local actorName = IsValid(actor) and actor:Nick() or "console"

	gAdminGetBan(sid64, function(existing)
		if existing then
			if callback then callback(false, "already_banned") end
			return
		end

		gAdminAddBan(sid64, reason or "", actorName, duration or 0, function(saved)
			if not saved then
				if callback then callback(false, "storage_error") end
				return
			end

			local durationStr = gAdminFormatDuration(duration or 0)

			gAdminLog("Ban", ("%s -> %s (%s) : %s"):format(
				actorName, target:Nick(), durationStr, reason or ""
			))

			gAdminBroadcast(("%s a été banni. (%s)"):format(target:Nick(), durationStr))
			target:Kick("Banni : " .. (reason or "") .. " | Durée : " .. durationStr)

			if callback then callback(true) end
		end)
	end)
end

function gAdminUnban(actor, steamid64, callback)
	if not steamid64 or steamid64 == "" then
		if callback then callback(false, "invalid_target") end
		return
	end

	local actorName = IsValid(actor) and actor:Nick() or "console"

	gAdminGetBan(steamid64, function(existing)
		if not existing then
			if callback then callback(false, "not_banned") end
			return
		end

		gAdminRemoveBan(steamid64, function(removed)
			if not removed then
				if callback then callback(false, "storage_error") end
				return
			end

			gAdminLog("Ban", ("Unban: %s par %s"):format(steamid64, actorName))

			if callback then callback(true) end
		end)
	end)
end

function gAdminCheckBan(steamid64, callback)
	if not steamid64 or steamid64 == "" then
		if callback then callback(nil) end
		return
	end

	gAdminGetBan(steamid64, function(ban)
		if not ban then
			if callback then callback(nil) end
			return
		end

		local expiresAt = tonumber(ban.expires_at) or 0

		if expiresAt > 0 and os.time() >= expiresAt then
			gAdminRemoveBan(steamid64, function()
				if callback then callback(nil) end
			end)
			return
		end

		if callback then callback(ban) end
	end)
end

hook.Add("PlayerConnect", "gAdmin.CheckBan", function(name, ip, steamID, steamID64, uniqueID, networkID)
	if not steamID64 or steamID64 == "" then return end

	gAdminCheckBan(steamID64, function(ban)
		if not ban then return end

		local expiresAt  = tonumber(ban.expires_at) or 0
		local remaining  = expiresAt > 0 and gAdminFormatDuration(expiresAt - os.time()) or "permanent"
		local reason     = tostring(ban.reason or "")

		gAdminLog("Ban", ("Connexion refusée: %s (%s) | %s | Restant: %s"):format(
			name, steamID64, reason, remaining
		))

		game.KickID(networkID, "Banni : " .. reason .. " | Restant : " .. remaining)
	end)
end)

print("modules/admin/sv_bans.lua | LOAD !")