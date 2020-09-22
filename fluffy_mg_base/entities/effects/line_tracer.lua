local mat_smoke = Material("trails/smoke")

function EFFECT:Init(data)
    self.Position = data:GetStart()
    self.WeaponEnt = data:GetEntity()
    self.Attachment = data:GetAttachment()

    self.StartPos = self:GetTracerShootPos(self.Position, self.WeaponEnt, self.Attachment)
    self.EndPos = data:GetOrigin()
    self.Norm = (self.StartPos - self.EndPos):GetNormalized()
    self.Entity:SetRenderBoundsWS(self.StartPos, self.EndPos)

    self.Alpha = 200
    self.Color = Color(150, 150, 150, self.Alpha)
end

function EFFECT:Think()
    self.Alpha = self.Alpha - FrameTime() * 100
    self.Color.a = self.Alpha

    return self.Alpha > 0
end

function EFFECT:Render()
    if self.Alpha < 1 then return end

    local sc = self.Alpha / 200
    render.SetMaterial(mat_beam)
    render.DrawBeam(self.StartPos, self.EndPos, sc * 2.5 + 1.0, 0, 0, self.Color)
end