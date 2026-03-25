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
		local result = sql.Query("SELECT rank_id FROM tkr_admin_ranks WHERE steamid64 = " .. sql.SQLStr(steamid64))
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
		local existing = sql.Query("SELECT steamid64 FROM tkr_admin_ranks WHERE steamid64 = " .. sql.SQLStr(steamid64))
		if existing and existing[1] then
			local result = sql.Query(string.format(
				"UPDATE tkr_admin_ranks SET rank_id = %d, set_by = %s, set_at = %d WHERE steamid64 = %s",
				rankID, sql.SQLStr(setBy or "system"), os.time(), sql.SQLStr(steamid64)
			))
			if callback then callback(result ~= false) end
		else
			local result = sql.Query(string.format(
				"INSERT INTO tkr_admin_ranks (steamid64, rank_id, set_by, set_at) VALUES (%s, %d, %s, %d)",
				sql.SQLStr(steamid64), rankID, sql.SQLStr(setBy or "system"), os.time()
			))
			if callback then callback(result ~= false) end
		end
	end

	function gAdminDeleteRank(steamid64, callback)
		if not steamid64 or steamid64 == "" then
			if callback then callback(false) end
			return
		end
		local result = sql.Query("DELETE FROM tkr_admin_ranks WHERE steamid64 = " .. sql.SQLStr(steamid64))
		if callback then callback(result ~= false) end
	end

	function gAdminAddWarn(steamid64, reason, givenBy, callback)
		if not steamid64 or steamid64 == "" then
			if callback then callback(false) end
			return
		end
		local result = sql.Query(string.format(
			"INSERT INTO tkr_admin_warns (steamid64, reason, given_by, given_at) VALUES (%s, %s, %s, %d)",
			sql.SQLStr(steamid64), sql.SQLStr(reason or ""), sql.SQLStr(givenBy or "system"), os.time()
		))
		if callback then callback(result ~= false) end
	end

	function gAdminGetWarns(steamid64, callback)
		if not steamid64 or steamid64 == "" then
			if callback then callback({}) end
			return
		end
		local result = sql.Query("SELECT * FROM tkr_admin_warns WHERE steamid64 = " .. sql.SQLStr(steamid64))
		if callback then callback(result or {}) end
	end

	function gAdminClearWarns(steamid64, callback)
		if not steamid64 or steamid64 == "" then
			if callback then callback(false) end
			return
		end
		local result = sql.Query("DELETE FROM tkr_admin_warns WHERE steamid64 = " .. sql.SQLStr(steamid64))
		if callback then callback(result ~= false) end
	end

	function gAdminGetAllWarns(limit, offset, callback)
		limit  = math.Clamp(tonumber(limit) or 100, 1, 200)
		offset = math.max(tonumber(offset) or 0, 0)
		local q = string.format(
			"SELECT id, steamid64, reason, given_by, given_at FROM tkr_admin_warns ORDER BY given_at DESC LIMIT %d OFFSET %d",
			limit, offset
		)
		local result = sql.Query(q)
		if callback then callback(result or {}) end
	end

	function gAdminCountAllWarns(callback)
		local result = sql.Query("SELECT COUNT(*) AS total FROM tkr_admin_warns")
		local total = result and result[1] and tonumber(result[1].total) or 0
		if callback then callback(total) end
	end

	function gAdminAddBan(steamid64, reason, bannedBy, duration, callback)
		if not steamid64 or steamid64 == "" then
			if callback then callback(false) end
			return
		end
		local expiresAt = duration and duration > 0 and (os.time() + duration) or 0
		local existing  = sql.Query("SELECT steamid64 FROM tkr_admin_bans WHERE steamid64 = " .. sql.SQLStr(steamid64))
		if existing and existing[1] then
			local result = sql.Query(string.format(
				"UPDATE tkr_admin_bans SET reason = %s, banned_by = %s, banned_at = %d, expires_at = %d WHERE steamid64 = %s",
				sql.SQLStr(reason or ""), sql.SQLStr(bannedBy or "system"), os.time(), expiresAt, sql.SQLStr(steamid64)
			))
			if callback then callback(result ~= false) end
		else
			local result = sql.Query(string.format(
				"INSERT INTO tkr_admin_bans (steamid64, reason, banned_by, banned_at, expires_at) VALUES (%s, %s, %s, %d, %d)",
				sql.SQLStr(steamid64), sql.SQLStr(reason or ""), sql.SQLStr(bannedBy or "system"), os.time(), expiresAt
			))
			if callback then callback(result ~= false) end
		end
	end

	function gAdminGetBan(steamid64, callback)
		if not steamid64 or steamid64 == "" then
			if callback then callback(nil) end
			return
		end
		local result = sql.Query("SELECT * FROM tkr_admin_bans WHERE steamid64 = " .. sql.SQLStr(steamid64))
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
		local result = sql.Query("DELETE FROM tkr_admin_bans WHERE steamid64 = " .. sql.SQLStr(steamid64))
		if callback then callback(result ~= false) end
	end

	function gAdminSaveLog(scope, msg, callback)
		if not TKRBASE.Admin.Logs.Enabled then return end
		local result = sql.Query(string.format(
			"INSERT INTO tkr_admin_logs (scope, msg, created_at) VALUES (%s, %s, %d)",
			sql.SQLStr(scope or ""), sql.SQLStr(msg or ""), os.time()
		))
		if callback then callback(result ~= false) end
	end

	function gAdminGetLogs(limit, offset, scope, callback)
		limit  = math.Clamp(tonumber(limit) or 100, 1, 200)
		offset = math.max(tonumber(offset) or 0, 0)

		local where = ""
		if scope and scope ~= "" then
			where = " WHERE scope = " .. sql.SQLStr(scope)
		end

		local q = string.format(
			"SELECT id, scope, msg, created_at FROM tkr_admin_logs%s ORDER BY created_at DESC LIMIT %d OFFSET %d",
			where, limit, offset
		)
		local result = sql.Query(q)
		if callback then callback(result or {}) end
	end

	function gAdminCountLogs(scope, callback)
		local where = ""
		if scope and scope ~= "" then
			where = " WHERE scope = " .. sql.SQLStr(scope)
		end
		local result = sql.Query("SELECT COUNT(*) AS total FROM tkr_admin_logs" .. where)
		local total = result and result[1] and tonumber(result[1].total) or 0
		if callback then callback(total) end
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

	function gAdminGetLogs(limit, offset, scope, callback)
		limit  = math.Clamp(tonumber(limit) or 100, 1, 200)
		offset = math.max(tonumber(offset) or 0, 0)

		local connValid = gMySQLValidateConnection("tkrbase")
		if not connValid then
			if callback then callback({}) end
			return
		end

		local db = TKRBASE.MySQL.connections["tkrbase"].db
		local queryStr, query

		if scope and scope ~= "" then
			queryStr = string.format(
				"SELECT id, scope, msg, created_at FROM tkr_admin_logs WHERE scope = ? ORDER BY created_at DESC LIMIT %d OFFSET %d",
				limit, offset
			)
			query = db:prepare(queryStr)
			query:setString(1, scope)
		else
			queryStr = string.format(
				"SELECT id, scope, msg, created_at FROM tkr_admin_logs ORDER BY created_at DESC LIMIT %d OFFSET %d",
				limit, offset
			)
			query = db:prepare(queryStr)
		end

		gMySQLHandleQuery(query, function(result, err)
			if callback then callback((result and not err) and result or {}) end
		end, queryStr, {})
	end

	function gAdminCountLogs(scope, callback)
		local connValid = gMySQLValidateConnection("tkrbase")
		if not connValid then
			if callback then callback(0) end
			return
		end

		local db = TKRBASE.MySQL.connections["tkrbase"].db

		if scope and scope ~= "" then
			local queryStr = "SELECT COUNT(*) AS total FROM tkr_admin_logs WHERE scope = ?"
			local query = db:prepare(queryStr)
			query:setString(1, scope)
			gMySQLHandleQuery(query, function(result, err)
				local total = 0
				if result and result[1] and not err then
					total = tonumber(result[1].total) or 0
				end
				if callback then callback(total) end
			end, queryStr, {})
		else
			local queryStr = "SELECT COUNT(*) AS total FROM tkr_admin_logs"
			local query = db:prepare(queryStr)
			gMySQLHandleQuery(query, function(result, err)
				local total = 0
				if result and result[1] and not err then
					total = tonumber(result[1].total) or 0
				end
				if callback then callback(total) end
			end, queryStr, {})
		end
	end

	function gAdminGetAllWarns(limit, offset, callback)
		limit  = math.Clamp(tonumber(limit) or 100, 1, 200)
		offset = math.max(tonumber(offset) or 0, 0)

		local connValid = gMySQLValidateConnection("tkrbase")
		if not connValid then
			if callback then callback({}) end
			return
		end

		local db = TKRBASE.MySQL.connections["tkrbase"].db
		local queryStr = string.format(
			"SELECT id, steamid64, reason, given_by, given_at FROM tkr_admin_warns ORDER BY given_at DESC LIMIT %d OFFSET %d",
			limit, offset
		)
		local query = db:prepare(queryStr)

		gMySQLHandleQuery(query, function(result, err)
			if callback then callback((result and not err) and result or {}) end
		end, queryStr, {})
	end

	function gAdminCountAllWarns(callback)
		local connValid = gMySQLValidateConnection("tkrbase")
		if not connValid then
			if callback then callback(0) end
			return
		end

		local db = TKRBASE.MySQL.connections["tkrbase"].db
		local queryStr = "SELECT COUNT(*) AS total FROM tkr_admin_warns"
		local query = db:prepare(queryStr)
		gMySQLHandleQuery(query, function(result, err)
			local total = 0
			if result and result[1] and not err then
				total = tonumber(result[1].total) or 0
			end
			if callback then callback(total) end
		end, queryStr, {})
	end

	gAdminInitStorage()

else
	MsgC(Color(255, 80, 80), "[ADMIN] StorageSystem invalide: " .. tostring(TKRBASE.StorageSystem) .. "\n")
end

print("modules/admin/sv_storage.lua | LOAD !")