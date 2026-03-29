local PANEL = {}

function PANEL:Init()
	self:SetPaintBackground(false)

	self._model       = nil
	self._skin        = 0
	self._bodygroups  = {}
	self._color       = color_white
	self._sequence    = nil

	self._rotate      = true
	self._rotateSpeed = 1
	self._rotateAngle = 0

	self._camPos      = nil
	self._camAng      = nil
	self._camFOV      = 70
	self._camAuto     = true

	self._ambientLight = Color(30, 30, 30)
	self._dirLight    = nil

	self._bgColor     = nil
	self._bgAlpha     = 0

	self._border      = false
	self._borderColor = nil
	self._borderAlpha = gThemeAlpha("border")
	self._borderSize  = 1

	self._mdlPanel    = vgui.Create("DModelPanel", self)
	self._mdlPanel:SetPos(0, 0)
	self._mdlPanel:SetSize(self:GetSize())

	self._mdlPanel.LayoutEntity = function(_, ent)
		if self._rotate then
			self._rotateAngle = (self._rotateAngle + self._rotateSpeed) % 360
			ent:SetAngles(Angle(0, self._rotateAngle, 0))
		end
		if self._sequence then
			ent:SetSequence(self._sequence)
		end
	end

	self._mdlPanel.PostDrawModel = function(_, ent)
	end
end

function PANEL:gSetModel(mdl, skin, bodygroups)
	self._model = mdl
	self._mdlPanel:SetModel(mdl)

	if skin then
		self._skin = skin
		self._mdlPanel:SetSkin(skin)
	end

	if bodygroups then
		self._bodygroups = bodygroups
		for bg, val in pairs(bodygroups) do
			self._mdlPanel:GetEntity():SetBodygroup(bg, val)
		end
	end

	if self._camAuto then
		timer.Simple(0, function()
			if not IsValid(self) or not IsValid(self._mdlPanel) then return end
			local ent = self._mdlPanel:GetEntity()
			if not IsValid(ent) then return end

			local mn, mx = ent:GetModelBounds()
			local center = (mn + mx) * 0.5
			local size   = mx:Distance(mn)

			self._mdlPanel:SetLookAt(center)
			self._mdlPanel:SetCamPos(center + Vector(size, size, size * 0.5))
			self._mdlPanel:SetFOV(self._camFOV)
		end)
	end
end

function PANEL:gSetSkin(skin)
	self._skin = skin
	if IsValid(self._mdlPanel:GetEntity()) then
		self._mdlPanel:GetEntity():SetSkin(skin)
	end
end

function PANEL:gSetColor(color)
	self._color = color or color_white
	if IsValid(self._mdlPanel:GetEntity()) then
		self._mdlPanel:GetEntity():SetColor(color)
	end
end

function PANEL:gSetRotate(enabled, speed)
	self._rotate      = enabled
	self._rotateSpeed = speed or 1
end

function PANEL:gSetSequence(seq)
	self._sequence = seq
end

function PANEL:gSetCamera(pos, ang, fov)
	self._camAuto = false
	self._camPos  = pos
	self._camAng  = ang
	self._camFOV  = fov or 70

	self._mdlPanel:SetCamPos(pos)
	if ang then self._mdlPanel:SetLookAt(ang) else self._mdlPanel:SetLookAt(Vector(0, 0, 0)) end
	self._mdlPanel:SetFOV(fov or 70)
end

function PANEL:gSetAmbientLight(color)
	self._ambientLight = color
	self._mdlPanel:SetAmbientLight(color)
end

function PANEL:gSetDirectionalLight(dir, color)
	self._dirLight = { dir = dir, color = color }
	self._mdlPanel:SetDirectionalLight(dir, color)
end

function PANEL:gSetBgColor(color, alpha)
	self._bgColor = color
	self._bgAlpha = alpha or gThemeAlpha("mid")
end

function PANEL:gSetBorder(enabled, color, alpha, size)
	self._border      = enabled
	self._borderColor = color
	self._borderAlpha = alpha or gThemeAlpha("border")
	self._borderSize  = size  or 1
end

function PANEL:gSetFOV(fov)
	self._camFOV = fov or 70
	self._mdlPanel:SetFOV(fov or 70)
end

function PANEL:GetModelPanel()
	return self._mdlPanel
end

function PANEL:PerformLayout(w, h)
	self._mdlPanel:SetSize(w, h)
	self._mdlPanel:SetPos(0, 0)
end

function PANEL:Paint(w, h)
	if self._bgColor then
		surface.SetDrawColor(self._bgColor.r, self._bgColor.g, self._bgColor.b, self._bgAlpha)
		surface.DrawRect(0, 0, w, h)
	end

	if self._border then
		local bc = self._borderColor or gTheme("border")
		surface.SetDrawColor(bc.r, bc.g, bc.b, self._borderAlpha)
		surface.DrawOutlinedRect(0, 0, w, h, self._borderSize)
	end
end

vgui.Register("gModelPanel", PANEL, "DPanel")