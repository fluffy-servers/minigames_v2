local mat_light = Material("sprites/physg_glow1")

function EFFECT:Init(data)
    self.Position = data:GetOrigin()
    local c = data:GetStart()
    self.Color = Color(c.x * 255, c.y * 255, c.z * 255)
    self.Alpha = 255
end

function EFFECT:Think()
    self.Alpha = self.Alpha - FrameTime() * 85

    return self.Alpha > 0
end

function EFFECT:Render()
    if self.Alpha < 1 then return end
    local c = self.Color
    c.a = self.Alpha
    render.SetMaterial(mat_light)
    render.DrawSprite(self.Position, 32, 32, c)
end