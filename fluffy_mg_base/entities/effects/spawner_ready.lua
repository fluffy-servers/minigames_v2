EFFECT.Mat = Material('sprites/physg_glow1')

--sprites/light_ignorez
--sprites/physg_glow1
--sprites/glow04_noz
--sprites/sent_ball
--sprites/key_0
--sprites/key_10
--sprites/hud1
--sprites/tp_beam001
--sprites/dot
--sprites/animglow02
function EFFECT:Init(data)
    self.Radius = 24
    self.Life = 1
    self.Number = 5
    self.Pos = data:GetOrigin()
    self.Angle = 0
    self.AngOff = (math.pi / self.Number) * 2
    self.Z = 0
    self.ParticleSize = 12
    self.Duration = 5
end

function EFFECT:Think()
    self.Life = self.Life - (FrameTime() / self.Duration)
    self.Angle = self.Angle + FrameTime() * 1
    self.Z = self.Z + FrameTime() * 20

    return (self.Life > 0)
end

function EFFECT:Render()
    local p = self.Pos
    local c = HSVToColor(CurTime() * 20 % 360, 1, 1)
    c.a = 255 * 4 * (self.Life - (self.Life * self.Life))

    for i = 1, self.Number do
        local angle = self.Angle + i * self.AngOff
        local p = self.Pos + Vector(self.Radius * math.cos(angle), self.Radius * math.sin(angle), self.Z)
        local ps = self.ParticleSize
        render.SetMaterial(self.Mat)
        render.DrawSprite(p, ps, ps, c)
    end
end