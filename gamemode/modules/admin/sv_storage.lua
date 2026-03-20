if TKRBASE.StorageSystem == "SQLite" then

	function gAdminInitStorage()
		gSQLiteCreateTable("tkr_admin_ranks", {
			steamid64 = "TEXT PRIMARY KEY",
			rank_id   = "INTEGER NOT NULL DEFAULT 0",
			set_by    = "TEXT DEFAULT 'system'",
			set_at    = "INTEGER DEFAULT 0",
		}, function(result, err)
			if not result then
				gAdminLog("Storage", "Erreur création table tkr_admin_ranks: " .. tostring(err))
			end
		end)

		gSQLiteCreateTable("tkr_admin_warns", {
			id        = "INTEGER PRIMARY KEY AUTOINCREMENT",
			steamid64 = "TEXT NOT NULL",
			reason    = "TEXT DEFAULT ''",
			given_by  = "TEXT DEFAULT 'system'",
			given_at  = "INTEGER DEFAULT 0",
		}, function(result, err)
			if not result then
				gAdminLog("Storage", "Erreur création table tkr_admin_warns: " .. tostring(err))
			end
		end)

		gSQLiteCreateTable("tkr_admin_bans", {
			steamid64  = "TEXT PRIMARY KEY",
			reason     = "TEXT DEFAULT ''",
			banned_by  = "TEXT DEFAULT 'system'",
			banned_at  = "INTEGER DEFAULT 0",
			expires_at = "INTEGER DEFAULT 0",
		}, function(result, err)
			if not result then
				gAdminLog("Storage", "Erreur création table tkr_admin_bans: " .. tostring(err))
			end
		end)

		gSQLiteCreateTable("tkr_admin_logs", {
			id         = "INTEGER PRIMARY KEY AUTOINCREMENT",
			scope      = "TEXT NOT NULL",
			msg        = "TEXT NOT NULL",
			created_at = "INTEGER DEFAULT 0",
		}, function(result, err)
			if not result then
				gAdminLog("Storage", "Erreur création table tkr_admin_logs: " .. tostring(err))
			end
		end)

		gAdminLog("Storage", "Tables prêtes (SQLite).")
	end

	function gAdminLoadRank(steamid64, callback)
		if not steamid64 or steamid64 == "" then
			if callback then callback(nil) end
			return
		end
		local result, _ = gSQLiteSelect("tkr_admin_ranks", { "rank_id" }, { steamid64 = steamid64 })
		if result and result[1] then
			if callback then callback(tonumber(result[1].rank_id)) end
			return
		end
		if callback then callback(nil) end
	end

	function gAdminSaveRank(steamid64, rankID, setBy, callback)
		if not steamid64 or steamid64 == "" then
			if callback then callback(false) end
			return
		end
		local existing, _ = gSQLiteSelect("tkr_admin_ranks", { "steamid64" }, { steamid64 = steamid64 })
		if existing and existing[1] then
			local result, _ = gSQLiteUpdate("tkr_admin_ranks", {
				rank_id = rankID,
				set_by  = setBy or "system",
				set_at  = os.time(),
			}, { steamid64 = steamid64 })
			if callback then callback(result ~= false) end
		else
			local result, _ = gSQLiteInsert("tkr_admin_ranks", {
				steamid64 = steamid64,
				rank_id   = rankID,
				set_by    = setBy or "system",
				set_at    = os.time(),
			})
			if callback then callback(result ~= false) end
		end
	end

	function gAdminDeleteRank(steamid64, callback)
		if not steamid64 or steamid64 == "" then
			if callback then callback(false) end
			return
		end
		local result, _ = gSQLiteDelete("tkr_admin_ranks", { steamid64 = steamid64 })
		if callback then callback(result ~= false) end
	end

	function gAdminAddWarn(steamid64, reason, givenBy, callback)
		if not steamid64 or steamid64 == "" then
			if callback then callback(false) end
			return
		end
		local result, _ = gSQLiteInsert("tkr_admin_warns", {
			steamid64 = steamid64,
			reason    = reason or "",
			given_by  = givenBy or "system",
			given_at  = os.time(),
		})
		if callback then callback(result ~= false) end
	end

	function gAdminGetWarns(steamid64, callback)
		if not steamid64 or steamid64 == "" then
			if callback then callback({}) end
			return
		end
		local result, _ = gSQLiteSelect("tkr_admin_warns", nil, { steamid64 = steamid64 })
		if callback then callback(result or {}) end
	end

	function gAdminClearWarns(steamid64, callback)
		if not steamid64 or steamid64 == "" then
			if callback then callback(false) end
			return
		end
		local result, _ = gSQLiteDelete("tkr_admin_warns", { steamid64 = steamid64 })
		if callback then callback(result ~= false) end
	end

	function gAdminAddBan(steamid64, reason, bannedBy, duration, callback)
		if not steamid64 or steamid64 == "" then
			if callback then callback(false) end
			return
		end
		local expiresAt = duration and duration > 0 and (os.time() + duration) or 0
		local existing, _ = gSQLiteSelect("tkr_admin_bans", { "steamid64" }, { steamid64 = steamid64 })
		if existing and existing[1] then
			local result, _ = gSQLiteUpdate("tkr_admin_bans", {
				reason     = reason or "",
				banned_by  = bannedBy or "system",
				banned_at  = os.time(),
				expires_at = expiresAt,
			}, { steamid64 = steamid64 })
			if callback then callback(result ~= false) end
		else
			local result, _ = gSQLiteInsert("tkr_admin_bans", {
				steamid64  = steamid64,
				reason     = reason or "",
				banned_by  = bannedBy or "system",
				banned_at  = os.time(),
				expires_at = expiresAt,
			})
			if callback then callback(result ~= false) end
		end
	end

	function gAdminGetBan(steamid64, callback)
		if not steamid64 or steamid64 == "" then
			if callback then callback(nil) end
			return
		end
		local result, _ = gSQLiteSelect("tkr_admin_bans", nil, { steamid64 = steamid64 })
		if result and result[1] then
			if callback then callback(result[1]) end
			return
		end
		if callback then callback(nil) end
	end

	function gAdminRemoveBan(steamid64, callback)
		if not steamid64 or steamid64 == "" then
			if callback then callback(false) end
			return
		end
		local result, _ = gSQLiteDelete("tkr_admin_bans", { steamid64 = steamid64 })
		if callback then callback(result ~= false) end
	end

	function gAdminSaveLog(scope, msg, callback)
		if not TKRBASE.Admin.Logs.Enabled then return end
		local result, _ = gSQLiteInsert("tkr_admin_logs", {
			scope      = scope or "",
			msg        = msg or "",
			created_at = os.time(),
		})
		if callback then callback(result ~= false) end
	end

	gAdminInitStorage()

elseif TKRBASE.StorageSystem == "MySQL" then

	function gAdminInitStorage()
		gMySQLCreateTable("tkrbase", "tkr_admin_ranks", {
			steamid64 = "VARCHAR(64) PRIMARY KEY",
			rank_id   = "INT NOT NULL DEFAULT 0",
			set_by    = "VARCHAR(64) DEFAULT 'system'",
			set_at    = "INT DEFAULT 0",
		}, function(result, err)
			if not result then
				gAdminLog("Storage", "Erreur création table tkr_admin_ranks: " .. tostring(err))
			end
		end)

		gMySQLCreateTable("tkrbase", "tkr_admin_warns", {
			id        = "INT AUTO_INCREMENT PRIMARY KEY",
			steamid64 = "VARCHAR(64) NOT NULL",
			reason    = "VARCHAR(255) DEFAULT ''",
			given_by  = "VARCHAR(64) DEFAULT 'system'",
			given_at  = "INT DEFAULT 0",
		}, function(result, err)
			if not result then
				gAdminLog("Storage", "Erreur création table tkr_admin_warns: " .. tostring(err))
			end
		end)

		gMySQLCreateTable("tkrbase", "tkr_admin_bans", {
			steamid64  = "VARCHAR(64) PRIMARY KEY",
			reason     = "VARCHAR(255) DEFAULT ''",
			banned_by  = "VARCHAR(64) DEFAULT 'system'",
			banned_at  = "INT DEFAULT 0",
			expires_at = "INT DEFAULT 0",
		}, function(result, err)
			if not result then
				gAdminLog("Storage", "Erreur création table tkr_admin_bans: " .. tostring(err))
			end
		end)

		gMySQLCreateTable("tkrbase", "tkr_admin_logs", {
			id         = "INT AUTO_INCREMENT PRIMARY KEY",
			scope      = "VARCHAR(64) NOT NULL",
			msg        = "TEXT NOT NULL",
			created_at = "INT DEFAULT 0",
		}, function(result, err)
			if not result then
				gAdminLog("Storage", "Erreur création table tkr_admin_logs: " .. tostring(err))
			end
		end)

		gAdminLog("Storage", "Tables prêtes (MySQL).")
	end

	function gAdminLoadRank(steamid64, callback)
		if not steamid64 or steamid64 == "" then
			if callback then callback(nil) end
			return
		end
		gMySQLSelect("tkrbase", "tkr_admin_ranks", { "rank_id" }, { steamid64 = steamid64 }, function(result, err)
			if result and result[1] then
				if callback then callback(tonumber(result[1].rank_id)) end
				return
			end
			if callback then callback(nil) end
		end)
	end

	function gAdminSaveRank(steamid64, rankID, setBy, callback)
		if not steamid64 or steamid64 == "" then
			if callback then callback(false) end
			return
		end
		gMySQLSelect("tkrbase", "tkr_admin_ranks", { "steamid64" }, { steamid64 = steamid64 }, function(result, err)
			if result and result[1] then
				gMySQLUpdate("tkrbase", "tkr_admin_ranks", {
					rank_id = rankID,
					set_by  = setBy or "system",
					set_at  = os.time(),
				}, { steamid64 = steamid64 }, function(r, e)
					if callback then callback(r ~= false) end
				end)
			else
				gMySQLInsert("tkrbase", "tkr_admin_ranks", {
					steamid64 = steamid64,
					rank_id   = rankID,
					set_by    = setBy or "system",
					set_at    = os.time(),
				}, function(r, e)
					if callback then callback(r ~= false) end
				end)
			end
		end)
	end

	function gAdminDeleteRank(steamid64, callback)
		if not steamid64 or steamid64 == "" then
			if callback then callback(false) end
			return
		end
		gMySQLDelete("tkrbase", "tkr_admin_ranks", { steamid64 = steamid64 }, function(result, err)
			if callback then callback(result ~= false) end
		end)
	end

	function gAdminAddWarn(steamid64, reason, givenBy, callback)
		if not steamid64 or steamid64 == "" then
			if callback then callback(false) end
			return
		end
		gMySQLInsert("tkrbase", "tkr_admin_warns", {
			steamid64 = steamid64,
			reason    = reason or "",
			given_by  = givenBy or "system",
			given_at  = os.time(),
		}, function(r, e)
			if callback then callback(r ~= false) end
		end)
	end

	function gAdminGetWarns(steamid64, callback)
		if not steamid64 or steamid64 == "" then
			if callback then callback({}) end
			return
		end
		gMySQLSelect("tkrbase", "tkr_admin_warns", nil, { steamid64 = steamid64 }, function(result, err)
			if callback then callback(result or {}) end
		end)
	end

	function gAdminClearWarns(steamid64, callback)
		if not steamid64 or steamid64 == "" then
			if callback then callback(false) end
			return
		end
		gMySQLDelete("tkrbase", "tkr_admin_warns", { steamid64 = steamid64 }, function(result, err)
			if callback then callback(result ~= false) end
		end)
	end

	function gAdminAddBan(steamid64, reason, bannedBy, duration, callback)
		if not steamid64 or steamid64 == "" then
			if callback then callback(false) end
			return
		end
		local expiresAt = duration and duration > 0 and (os.time() + duration) or 0
		gMySQLSelect("tkrbase", "tkr_admin_bans", { "steamid64" }, { steamid64 = steamid64 }, function(result, err)
			if result and result[1] then
				gMySQLUpdate("tkrbase", "tkr_admin_bans", {
					reason     = reason or "",
					banned_by  = bannedBy or "system",
					banned_at  = os.time(),
					expires_at = expiresAt,
				}, { steamid64 = steamid64 }, function(r, e)
					if callback then callback(r ~= false) end
				end)
			else
				gMySQLInsert("tkrbase", "tkr_admin_bans", {
					steamid64  = steamid64,
					reason     = reason or "",
					banned_by  = bannedBy or "system",
					banned_at  = os.time(),
					expires_at = expiresAt,
				}, function(r, e)
					if callback then callback(r ~= false) end
				end)
			end
		end)
	end

	function gAdminGetBan(steamid64, callback)
		if not steamid64 or steamid64 == "" then
			if callback then callback(nil) end
			return
		end
		gMySQLSelect("tkrbase", "tkr_admin_bans", nil, { steamid64 = steamid64 }, function(result, err)
			if result and result[1] then
				if callback then callback(result[1]) end
				return
			end
			if callback then callback(nil) end
		end)
	end

	function gAdminRemoveBan(steamid64, callback)
		if not steamid64 or steamid64 == "" then
			if callback then callback(false) end
			return
		end
		gMySQLDelete("tkrbase", "tkr_admin_bans", { steamid64 = steamid64 }, function(result, err)
			if callback then callback(result ~= false) end
		end)
	end

	function gAdminSaveLog(scope, msg, callback)
		if not TKRBASE.Admin.Logs.Enabled then return end
		gMySQLInsert("tkrbase", "tkr_admin_logs", {
			scope      = scope or "",
			msg        = msg or "",
			created_at = os.time(),
		}, function(r, e)
			if callback then callback(r ~= false) end
		end)
	end

	gAdminInitStorage()

else
	MsgC(Color(255, 80, 80), "[ADMIN] StorageSystem invalide: " .. tostring(TKRBASE.StorageSystem) .. "\n")
end

print("modules/admin/sv_storage.lua | LOAD !")