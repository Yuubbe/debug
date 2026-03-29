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
AddCSLuaFile("libraries/vgui/config.lua")
AddCSLuaFile("libraries/vgui/debug.lua")
AddCSLuaFile("libraries/vgui/base/frame.lua")
AddCSLuaFile("libraries/vgui/base/panel.lua")
AddCSLuaFile("libraries/vgui/base/label.lua")
AddCSLuaFile("libraries/vgui/inputs/button.lua")
AddCSLuaFile("libraries/vgui/inputs/textentry.lua")
AddCSLuaFile("libraries/vgui/inputs/checkbox.lua")
AddCSLuaFile("libraries/vgui/inputs/combobox.lua")
AddCSLuaFile("libraries/vgui/inputs/numslider.lua")
AddCSLuaFile("libraries/vgui/inputs/numwang.lua")
AddCSLuaFile("libraries/vgui/layout/scrollpanel.lua")
AddCSLuaFile("libraries/vgui/layout/iconlayout.lua")
AddCSLuaFile("libraries/vgui/layout/listlayout.lua")
AddCSLuaFile("libraries/vgui/layout/propertysheet.lua")
AddCSLuaFile("libraries/vgui/layout/collapsiblecategory.lua")
AddCSLuaFile("libraries/vgui/display/image.lua")
AddCSLuaFile("libraries/vgui/display/imagebutton.lua")
AddCSLuaFile("libraries/vgui/display/modelpanel.lua")
AddCSLuaFile("libraries/vgui/display/progress.lua")
AddCSLuaFile("libraries/vgui/display/colormixer.lua")
AddCSLuaFile("libraries/vgui/utility/notify.lua")
AddCSLuaFile("libraries/vgui/utility/listview.lua")
AddCSLuaFile("libraries/vgui/utility/tree.lua")
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
include("modules/admin/sv_net.lua")
AddCSLuaFile("modules/admin/vgui/cl_left.lua")
AddCSLuaFile("modules/admin/vgui/cl_logs.lua")
AddCSLuaFile("modules/admin/vgui/cl_player.lua")
AddCSLuaFile("modules/admin/vgui/cl_warns.lua")
include("modules/admin/sv_warns.lua")
include("modules/admin/sv_bans.lua")
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Thirdperson (client only)
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
AddCSLuaFile("modules/thirdperson/cl_thirdperson.lua")
AddCSLuaFile("modules/thirdperson/cl_thirdperson_ui.lua")
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Context menu (client only)
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
AddCSLuaFile("modules/contextmenu/cl_contextmenu.lua")