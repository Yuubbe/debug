TKRBASE.Factions = TKRBASE.Factions or {}
TKRBASE.Categories = TKRBASE.Categories or {}
TKRBASE.Jobs = TKRBASE.Jobs or {}

function gCreateFaction(name, tbl)
	tbl = tbl or {}

	for _, faction in ipairs(TKRBASE.Factions) do
		if faction.name == name then
			ErrorNoHalt("[gCreateFaction] Faction '" .. name .. "' already exists\n")
			return nil
		end
	end

	tbl.name = name
	tbl.color = tbl.color or Color(255, 255, 255)
	tbl.jobs = {}
	tbl.categories = {}

	table.insert(TKRBASE.Factions, tbl)

	return #TKRBASE.Factions
end

function gGetFaction(factionID)
	for _, faction in ipairs(TKRBASE.Factions) do
		if faction.id == factionID then
			return faction
		end
	end
	return nil
end

function gGetFactions()
	return TKRBASE.Factions
end

function gGetJobFaction(teamID)
	for _, faction in ipairs(TKRBASE.Factions) do
		for _, jobID in ipairs(faction.jobs) do
			if jobID == teamID then
				return faction
			end
		end
	end
	return nil
end

function gCreateCategory(name, tbl)
	tbl = tbl or {}

	tbl.name = name
	tbl.kind = tbl.kind or "jobs"
	tbl.startExpanded = tbl.startExpanded ~= false
	tbl.sortOrder = tbl.sortOrder or 100

	TKRBASE.Categories[tbl.kind] = TKRBASE.Categories[tbl.kind] or {}

	for _, cat in ipairs(TKRBASE.Categories[tbl.kind]) do
		if cat.name == name then
			ErrorNoHalt("[gCreateCategory] Category '" .. name .. "' already exists in '" .. tbl.kind .. "'\n")
			return
		end
	end

	table.insert(TKRBASE.Categories[tbl.kind], tbl)
end

function gGetCategories(kind)
	kind = kind or "jobs"
	return TKRBASE.Categories[kind] or {}
end

function gCreateJob(name, tbl)
	tbl = tbl or {}

	for _, job in ipairs(TKRBASE.Jobs) do
		if job.name == name then
			ErrorNoHalt("[gCreateJob] Job '" .. name .. "' already exists\n")
			return nil
		end
	end

	local teamID = #TKRBASE.Jobs + 1

	tbl.name = name
	tbl.team = teamID
	tbl.command = tbl.command or string.lower(string.gsub(name, " ", ""))
	tbl.color = tbl.color or Color(255, 255, 255)
	tbl.category = tbl.category or "Other"
	tbl.faction = tbl.faction or nil

	TKRBASE.Jobs[teamID] = tbl
	team.SetUp(teamID, name, tbl.color)

	if tbl.faction then
		for _, faction in ipairs(TKRBASE.Factions) do
			if faction.name == tbl.faction then
				table.insert(faction.jobs, teamID)
				break
			end
		end
	end

	if tbl.category then
		for _, faction in ipairs(TKRBASE.Factions) do
			if faction.name == tbl.faction then
				local found = false
				for _, cat in ipairs(faction.categories) do
					if cat == tbl.category then
						found = true
						break
					end
				end
				if not found then
					table.insert(faction.categories, tbl.category)
				end
				break
			end
		end
	end

	return teamID
end

function gGetJob(teamID)
	for _, job in ipairs(TKRBASE.Jobs) do
		if job.team == teamID then
			return job
		end
	end
	return nil
end

function gGetJobs()
	return TKRBASE.Jobs
end

function gGetJobsByFaction(factionName)
	local jobs = {}
	for _, job in ipairs(TKRBASE.Jobs) do
		if job.faction == factionName then
			table.insert(jobs, job)
		end
	end
	return jobs
end

function gGetJobsByCategory(categoryName)
	local jobs = {}
	for _, job in ipairs(TKRBASE.Jobs) do
		if job.category == categoryName then
			table.insert(jobs, job)
		end
	end
	return jobs
end

print("utils/pgroup/sh_groups.lua | LOAD !")