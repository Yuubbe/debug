local _cfg          = TKRBASE.Admin
local _initialized  = {}

function gAdminGetRankByID(rankID)
	return _cfg.Ranks[rankID]
end

function gAdminGetRankByName(name)
	local id = _cfg.NameToID[name]
	if id == nil then return nil end
	return _cfg.Ranks[id], id
end

function gAdminGetRankID(ply)
	if not IsValid(ply) then return _cfg.DefaultRankID end

	local sid64 = ply:SteamID64()
	if sid64 and _cfg.AllForOne[sid64] then
		local ownerID = _cfg.NameToID["owner"]
		if ownerID ~= nil then return ownerID end
	end

	local ug = ply:GetUserGroup()
	if ug and _cfg.UsergroupToRankID[ug] ~= nil then
		return _cfg.UsergroupToRankID[ug]
	end

	return _cfg.DefaultRankID
end

function gAdminGetRankName(ply)
	local id = gAdminGetRankID(ply)
	local data = _cfg.Ranks[id]
	return data and data.name or "user"
end

function gAdminGetRankPower(ply)
	local id = gAdminGetRankID(ply)
	local data = _cfg.Ranks[id]
	return data and data.power or 999
end

function gAdminSetRank(ply, rankID, reason, callback)
	if not IsValid(ply) or not ply:IsPlayer() then
		if callback then callback(false, "invalid_player") end
		return
	end

	local data = _cfg.Ranks[rankID]
	if not data then
		if callback then callback(false, "invalid_rank") end
		return
	end

	local sid64 = ply:SteamID64()

	gAdminSaveRank(sid64, rankID, reason or "system", function(saved)
		if not saved then
			if callback then callback(false, "storage_error") end
			return
		end

		ply:SetUserGroup(data.name)

		gAdminLog("Rank", ("%s -> %s (ID:%d) par %s"):format(
			ply:Nick(), data.name, rankID, reason or "system"
		))

		if callback then callback(true) end
	end)
end

function gAdminHasCommand(actor, cmdName)
	if actor == nil then return true end
	if not IsValid(actor) or not actor:IsPlayer() then return true end

	local sid64 = actor:SteamID64()
	if sid64 and _cfg.AllForOne[sid64] then return true end

	local rankName = gAdminGetRankName(actor)
	local perms    = _cfg.PermCache[rankName]
	if not perms then return false end
	if perms["*"] then return true end
	return perms[cmdName] == true
end

function gAdminCanTarget(actor, target)
	if actor == nil then return true end
	if not IsValid(actor) or not actor:IsPlayer() then return false, "invalid_actor" end
	if not IsValid(target) or not target:IsPlayer() then return false, "invalid_target" end
	if actor == target then return true end

	if target:IsBot() then
		if _cfg.AllowTargetBots ~= false then return true end
		return false, "invalid_target"
	end

	local aPow = gAdminGetRankPower(actor)
	local tPow = gAdminGetRankPower(target)

	if aPow >= tPow then
		return false, "insufficient_rank"
	end

	return true
end

function gAdminValidateInteraction(actor, target)
	if actor ~= nil and (not IsValid(actor) or not actor:IsPlayer()) then
		return false, "invalid_actor"
	end
	if not IsValid(target) or not target:IsPlayer() then
		return false, "invalid_target"
	end
	return gAdminCanTarget(actor, target)
end

hook.Add("PlayerSpawn", "gAdmin.InitRank", function(ply)
	if not IsValid(ply) then return end

	local sid64 = ply:SteamID64()
	if _initialized[sid64] then return end
	_initialized[sid64] = true

	if _cfg.AllForOne[sid64] then
		local ownerID = _cfg.NameToID["owner"]
		if ownerID and _cfg.Ranks[ownerID] then
			timer.Simple(0, function()
				if not IsValid(ply) then return end
				ply:SetUserGroup(_cfg.Ranks[ownerID].name)
				gAdminLog("Rank", ply:Nick() .. " -> AllForOne (owner)")
			end)
			return
		end
	end

	gAdminLoadRank(sid64, function(storedID)
		if not IsValid(ply) then return end

		if storedID ~= nil and _cfg.Ranks[storedID] then
			timer.Simple(0, function()
				if not IsValid(ply) then return end
				ply:SetUserGroup(_cfg.Ranks[storedID].name)
				gAdminLog("Rank", ply:Nick() .. " -> Storage (" .. _cfg.Ranks[storedID].name .. ")")
			end)
			return
		end

		local ug   = ply:GetUserGroup()
		local ugID = _cfg.UsergroupToRankID[ug]
		if ugID and _cfg.Ranks[ugID] then
			timer.Simple(0, function()
				if not IsValid(ply) then return end
				ply:SetUserGroup(ug)
				gAdminLog("Rank", ply:Nick() .. " -> UserGroup (" .. ug .. " => " .. _cfg.Ranks[ugID].name .. ")")
			end)
			return
		end

		timer.Simple(0, function()
			if not IsValid(ply) then return end
			ply:SetUserGroup(_cfg.Ranks[_cfg.DefaultRankID] and _cfg.Ranks[_cfg.DefaultRankID].name or "user")
			gAdminLog("Rank", ply:Nick() .. " -> Default (user)")
		end)
	end)
end)

hook.Add("PlayerDisconnected", "gAdmin.CleanInit", function(ply)
	_initialized[ply:SteamID64()] = nil
end)

print("modules/admin/sv_ranks.lua | LOAD !")