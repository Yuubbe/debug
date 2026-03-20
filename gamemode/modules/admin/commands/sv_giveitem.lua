gAdminRegisterCommand("giveitem", {
	usage       = "!giveitem <joueur> <classname>",
	description = "Spawner un item devant un joueur",
	callback    = function(actor, args)
		if #args < 2 then
			gAdminReply(actor, gAdminErrorMsg("missing_args"))
			return
		end

		local target = gAdminResolveAndValidate(actor, args[1])
		if not target then return end

		if not target:Alive() then
			gAdminReply(actor, target:Nick() .. " est mort.")
			return
		end

		local classname = args[2]

		if not scripted_ents.GetStored(classname) then
			gAdminReply(actor, "Item invalide : " .. classname)
			return
		end

		local forward  = target:GetForward()
		local startPos = target:GetPos() + Vector(0, 0, 16)
		local endPos   = startPos + forward * 64

		local trace = util.TraceLine({
			start  = startPos,
			endpos = endPos,
			filter = target,
			mask   = MASK_SOLID_BRUSHONLY,
		})

		local spawnPos = trace.Hit and (trace.HitPos - forward * 8) or endPos

		local item = ents.Create(classname)
		if not IsValid(item) then
			gAdminReply(actor, "Impossible de créer l'item : " .. classname)
			return
		end

		item:SetPos(spawnPos)
		item:Spawn()
		item:Activate()

		local phys = item:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
		end

		gAdminReply(actor, ("%s a reçu %s."):format(target:Nick(), classname))
		gAdminLog("Cmd", ("!giveitem: %s -> %s (%s)"):format(
			IsValid(actor) and actor:Nick() or "Console", target:Nick(), classname
		))
	end,
})