EFFECT.Mat = Material('sprites/glow04_noz')
--sprites/light_ignorez
--sprites/physg_glow1

function EFFECT:Init(data)
    self.Size = 24
    self.Alpha = 255
    self.Number = 5
    self.Pos = data:GetOrigin()
    self.Angle = 0
    self.AngOff = (math.pi / self.Number) * 2
    self.Z = -16
end

function EFFECT:Think()
    self.Alpha = self.Alpha - FrameTime()*75
    self.Angle = self.Angle + FrameTime()*2
    self.Z = self.Z + FrameTime()*15
    return (self.Alpha > 0)
end

function EFFECT:Render()
    local p = self.Pos
    local c = Color(0, 255, 128, self.Alpha)
    for i=1,self.Number do
        local angle = self.Angle + i*self.AngOff
        local p = self.Pos + Vector(self.Size * math.cos(angle), self.Size * math.sin(angle), self.Z + i)
        render.SetMaterial(self.Mat)
        render.DrawSprite(p, 12, 12, c)
    end
end