local mat_beam = Material("trails/laser")
local mat_light = Material("sprites/light_glow02_add")

function EFFECT:Init(data)
    -- Get data from the weapon
    self.Position = data:GetStart()
    self.Weapon = data:GetEntity()
    self.Attachment = data:GetAttachment()
    -- Calculate the positions
    self.StartPos = self:GetTracerShootPos(self.Position, self.Weapon, self.Attachment)
    self.EndPos = data:GetOrigin()
    self.Length = (self.StartPos - self.EndPos):Length()
    -- Calculate the color
    self.Color = color_white
    self.Alpha = 255

    if IsValid(self.Weapon) then
        local owner = self.Weapon:GetOwner()

        if IsValid(owner) then
            local cv = owner:GetPlayerColor()
            self.Color = Color(cv[1] * 255, cv[2] * 255, cv[3] * 255)
        end
    end
end

function EFFECT:Think()
    self.Alpha = self.Alpha - FrameTime() * 150
    self.Entity:SetRenderBoundsWS(self.StartPos, self.EndPos)
    -- Kill the tracer if alpha is less than 0

    return (self.Alpha > 0)
end

function EFFECT:Render()
    if self.Alpha < 1 then return end
    local texcoord = CurTime() * -0.2
    render.SetMaterial(mat_beam)
    render.DrawBeam(self.StartPos, self.EndPos, 1 + self.Alpha * 0.4, texcoord, texcoord + self.Length / (128 + self.Alpha), self.Color)
    render.SetMaterial(mat_light)
    render.DrawSprite(self.EndPos, 32, 32, Color(self.Color.r, self.Color.g, self.Color.b, self.Alpha))
end