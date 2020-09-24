local PANEL = {}

function PANEL:Init()
    local cl_playermodel = LocalPlayer():GetInfo("cl_playermodel")
    local modelname = GAMEMODE:TranslatePlayerModel(cl_playermodel, LocalPlayer())
    self:SetModel(modelname or LocalPlayer():GetModel())
end

function PANEL:DragMousePress()
    self.PressX, self.PressY = gui.MousePos()
    self.Pressed = true
end

function PANEL:DragMouseRelease()
    self.Pressed = false
end

function PANEL:LayoutEntity(ent)
    self:RunAnimation()
    ent:SetEyeTarget(Vector(24, 0, 64))

    if not self.Angles then
        self.Angles = Angle(0, 0, 0)
    end

    if self.Transition then
        ent:SetAngles(self.Angles)

        return
    end

    if self.Pressed then
        local mx, _ = gui.MousePos()
        self.Angles = self.Angles - Angle(0, (self.PressX or mx) - mx, 0)
        self.PressX, self.PressY = gui.MousePos()
        ent:SetAngles(self.Angles)
    end
end

function PANEL:SetCamera(height, distance)
    self:SetCamPos(Vector(distance or 0, 0, height))
    self:SetLookAt(Vector(0, 0, height))
end

function PANEL:SetAngle(angle)
    self.Angles = Angle(0, angle, 0)
end

function PANEL:TransitionCamera(height, distance, angle, duration)
    if not self.Angles then
        self.Angles = Angle(0, 0, 0)
    end

    self.Transition = {
        old = self:GetCamPos(),
        old_look = self:GetLookAt(),
        new = Vector(distance or 0, 0, height),
        new_look = Vector(0, 0, height),
        start = CurTime(),
        duration = duration,
        old_angle = self.Angles.y,
        new_angle = angle
    }
end

function PANEL:Think()
    if self.Transition then
        local time_percent = (CurTime() - self.Transition.start) / self.Transition.duration
        local smooth = math.EaseInOut(time_percent, 0.5, 0.5)
        smooth = math.min(smooth, 1)
        local trans_pos = self.Transition.old + (self.Transition.new - self.Transition.old) * smooth
        local trans_look = self.Transition.old_look + (self.Transition.new_look - self.Transition.old_look) * smooth
        local angle = self.Transition.old_angle + (self.Transition.new_angle - self.Transition.old_angle) * smooth
        self:SetCamPos(trans_pos)
        self:SetLookAt(trans_look)
        self.Angles = Angle(0, angle, 0)

        if time_percent >= 1 then
            self.Transition = nil
        end
    end

    self.Entity.GetPlayerColor = function() return LocalPlayer():GetPlayerColor() end
end

function PANEL:PostDrawModel(ent)
    SHOP:RenderCosmetics(ent, LocalPlayer(), true)
end

vgui.Register("ShopMirror", PANEL, "DModelPanel")