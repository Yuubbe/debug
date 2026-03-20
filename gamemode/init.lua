TKRBASE = {}
TKRBASE.Admin = {}
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- LIBS du serveur (vitale au fonctionnement du gamemode)
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
AddCSLuaFile("shared.lua")
include("shared.lua")
AddCSLuaFile("libraries/resp/responsive.lua")
AddCSLuaFile("libraries/resp/panel.lua")
AddCSLuaFile("libraries/resp/materials.lua")
AddCSLuaFile("libraries/resp/anims.lua")
AddCSLuaFile("libraries/debug/config.lua")
AddCSLuaFile("libraries/debug/utils.lua")
include("libraries/debug/config.lua")
include("libraries/debug/utils.lua")
include("libraries/sqlite/utils.lua")
include("libraries/sqlite/create.lua")
include("libraries/sqlite/insert.lua")
include("libraries/sqlite/select.lua")
include("libraries/sqlite/update.lua")
include("libraries/sqlite/delete.lua")
include("libraries/mysql/init.lua")
include("libraries/mysql/utils.lua")
include("libraries/mysql/connect.lua")
include("libraries/mysql/create.lua")
include("libraries/mysql/insert.lua")
include("libraries/mysql/select.lua")
include("libraries/mysql/update.lua")
include("libraries/mysql/delete.lua")
AddCSLuaFile("libraries/anims/anims.lua")
include("libraries/anims/anims.lua")
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- MODULES Utilitaire (utilisation global)
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
AddCSLuaFile("utils/pvar/cl_pvar.lua")
AddCSLuaFile("utils/pgroup/sh_groups.lua")
AddCSLuaFile("utils/pgroup/sh_config.lua")
include("utils/pvar/sv_pvar.lua")
include("utils/pgroup/sh_groups.lua")
include("utils/pgroup/sh_config.lua")
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- MODULES Principaux (utilisation direct) 
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
TKRBASE.StorageSystem = "SQLite"
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
if TKRBASE.StorageSystem == "MySQL" then
	gMySQLAddConnection("test_connection", {
		host = "",
		username = "",
		password = "",
		database = "",
		port = 3306
	}, function(result, error)
		if result then
			print("✅ Connexion 'test_connection' ajoutée avec succès!")
		else
			print("❌ Erreur ajout connexion:", error)
		end
	end)

	gMySQLConnect("test_connection", function(result, error)
		if result then
			print("✅ Connexion MySQL établie avec succès!")
		else
			print("❌ Erreur connexion MySQL:", error)
		end
	end)
end
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Admin (server only) — sv_commands.lua auto-include les commands/
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
include("modules/admin/sv_config.lua")
include("modules/admin/sv_utils.lua")
include("modules/admin/sv_storage.lua")
include("modules/admin/sv_ranks.lua")
include("modules/admin/sv_commands.lua")
include("modules/admin/sv_warns.lua")
include("modules/admin/sv_bans.lua")