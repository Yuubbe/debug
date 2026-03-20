TKRBASE.Debug = {}

TKRBASE.Debug.Enabled = true
TKRBASE.Debug.Verbose = true

TKRBASE.Debug.Config = {
	SQLite = true,
	MySQL = true,
	CreateTable = true,
	Insert = true,
	Select = true,
	Update = true,
	Delete = true,
	Connection = true,
	Logs = true
}

function gDisableSQLDebug(operationType)
	if operationType then
		TKRBASE.Debug.Config[operationType] = false
	else
		TKRBASE.Debug.Enabled = false
	end

	gSQLDebugPrint("Config", "Debug disabled", {
		status = "info",
		data = {
			operationType = operationType or "all"
		}
	})
end

function gEnableSQLDebug(operationType)
	if operationType then
		TKRBASE.Debug.Config[operationType] = true
	else
		TKRBASE.Debug.Enabled = true
	end

	gSQLDebugPrint("Config", "Debug enabled", {
		status = "info",
		data = {
			operationType = operationType or "all"
		}
	})
end

function gSetSQLDebugVerbose(enabled)
	TKRBASE.Debug.Verbose = enabled

	gSQLDebugPrint("Config", "Verbose mode " .. (enabled and "enabled" or "disabled"), {
		status = "info"
	})
end

function gResetSQLDebug()
	TKRBASE.Debug.Enabled = true
	TKRBASE.Debug.Verbose = true

	TKRBASE.Debug.Config = {
		SQLite = true,
		MySQL = true,
		CreateTable = true,
		Insert = true,
		Select = true,
		Update = true,
		Delete = true,
		Connection = true,
		Logs = true
	}

	gSQLDebugPrint("Config", "Debug configuration reset to defaults", {
		status = "info"
	})
end

print("libraries/debug/config.lua | LOAD !")