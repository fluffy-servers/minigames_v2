EFFECT.BeamMat = Material("trails/laser")
EFFECT.DotMat = Material("sprites/physg_glow1")

function EFFECT:Init(data)
    self.Position = data:GetStart()
    self.WeaponEnt = data:GetEntity()
    self.Attachment = data:GetAttachment()
    self.StartPos = self:GetTracerShootPos(self.Position, self.WeaponEnt, self.Attachment)
    self.EndPos = data:GetOrigin()
    self.Alpha = 255
    self.Life = 0
    self.Color = math.random(360)
    self:SetRenderBoundsWS(self.StartPos, self.EndPos)
end

function EFFECT:Think()
    self.Life = self.Life + FrameTime() * 2
    self.Alpha = 255 * (1 - self.Life)

    return self.Life < 1
end

function EFFECT:Render()
    if self.Alpha < 1 then return end
    render.SetMaterial(self.BeamMat)
    local c = HSVToColor((self.Color + self.Life * 180) % 360, 1, 1)
    local gap = (self.StartPos - self.EndPos)
    local norm = gap * self.Life
    self.Length = norm:Length()
    render.DrawBeam(self.StartPos, self.EndPos, 12, 1 - self.Life, 1 - self.Life + gap:Length() / 128, Color(c.r, c.g, c.b, 255 * (1 - self.Life)))
    render.SetMaterial(self.DotMat)
    render.DrawSprite(self.EndPos, 24, 24, Color(c.r, c.g, c.b))
end