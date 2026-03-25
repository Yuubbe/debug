TKRBASE = {}
TKRBASE.Admin = {}
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- LIBS du serveur (vitale au fonctionnement du gamemode)
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
include("libraries/resp/responsive.lua")
include("libraries/resp/panel.lua")
include("libraries/resp/materials.lua")
include("libraries/resp/anims.lua")
include("libraries/vgui/config.lua")
include("libraries/vgui/debug.lua")
include("libraries/vgui/base/frame.lua")
include("libraries/vgui/base/panel.lua")
include("libraries/vgui/base/label.lua")
include("libraries/vgui/inputs/button.lua")
include("libraries/vgui/inputs/textentry.lua")
include("libraries/vgui/inputs/checkbox.lua")
include("libraries/debug/config.lua")
include("libraries/debug/utils.lua")
include("libraries/anims/anims.lua")
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- MODULES Utilitaire (utilisation global)
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
include("utils/pvar/cl_pvar.lua")
include("utils/pgroup/sh_groups.lua")
include("utils/pgroup/sh_config.lua")
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- MODULES Principaux (utilisation direct)
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
include("modules/admin/cl_admin_ui.lua")
include("modules/thirdperson/cl_thirdperson.lua")
include("modules/thirdperson/cl_thirdperson_ui.lua")
include("modules/logs/cl_logs_ui.lua")
include("modules/warns/cl_warns_ui.lua")
include("modules/contextmenu/cl_contextmenu.lua")