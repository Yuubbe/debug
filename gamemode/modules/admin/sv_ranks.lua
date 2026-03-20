local _cfg   = TKRBASE.Admin
local _ranks = _cfg.Ranks
local _perm  = _cfg.PermCache
local _n2id  = _cfg.NameToID

function gAdminGetRankByID(rankID)
	return _ranks[rankID]
end

function gAdminGetRankByName(name)
	local id = _n2id[name]
	if id == nil then return nil end
	return _ranks[id], id
end

function gAdminGetRankID(ply)
	if not IsValid(ply) then return _cfg.DefaultRankID end

	local sid64 = ply:SteamID64()
	if sid64 and _cfg.AllForOne[sid64] then
		local ownerID = _n2id["owner"]
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
	local data = _ranks[id]
	return data and data.name or "user"
end

function gAdminGetRankPower(ply)
	local id = gAdminGetRankID(ply)
	local data = _ranks[id]
	return data and data.power or 999
end

function gAdminSetRank(ply, rankID, reason, callback)
	if not IsValid(ply) or not ply:IsPlayer() then
		if callback then callback(false, "invalid_player") end
		return
	end

	local data = _ranks[rankID]
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
	local perms = _perm[rankName]
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
	local sid64 = ply:SteamID64()

	if sid64 and _cfg.AllForOne[sid64] then
		local ownerID = _n2id["owner"]
		if ownerID and _ranks[ownerID] then
			ply:SetUserGroup(_ranks[ownerID].name)
			gAdminLog("Rank", ply:Nick() .. " -> AllForOne (owner)")
			return
		end
	end

	gAdminLoadRank(sid64, function(storedID)
		if storedID ~= nil and _ranks[storedID] then
			ply:SetUserGroup(_ranks[storedID].name)
			gAdminLog("Rank", ply:Nick() .. " -> Storage (" .. _ranks[storedID].name .. ")")
			return
		end

		local ug = ply:GetUserGroup()
		local ugID = _cfg.UsergroupToRankID[ug]
		if ugID and _ranks[ugID] then
			ply:SetUserGroup(ug)
			gAdminLog("Rank", ply:Nick() .. " -> UserGroup (" .. ug .. " => " .. _ranks[ugID].name .. ")")
			return
		end

		ply:SetUserGroup(_ranks[_cfg.DefaultRankID] and _ranks[_cfg.DefaultRankID].name or "user")
		gAdminLog("Rank", ply:Nick() .. " -> Default (user)")
	end)
end)

print("modules/admin/sv_ranks.lua | LOAD !")