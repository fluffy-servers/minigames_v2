local mat_beam = Material("sprites/physbeam")
local mat_light = Material("sprites/light_glow02_add")

function EFFECT:Init(data)
    -- Load weapon data
    self.Position = data:GetStart()
    self.Weapon = data:GetEntity()
    self.Attachment = data:GetAttachment()
    -- Calculate positions
    self.StartPos = self:GetTracerShootPos(self.Position, self.Weapon, self.Attachment)
    self.EndPos = data:GetOrigin()
    self.Norm = (self.StartPos - self.EndPos):GetNormalized()
    self.Entity:SetRenderBoundsWS(self.StartPos, self.EndPos)
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
    self.Alpha = self.Alpha - FrameTime() * 100
    self.Color.a = self.Alpha

    return self.Alpha > 0
end

function EFFECT:Render()
    if self.Alpha < 1 then return end
    local sc = self.Alpha / 255
    render.SetMaterial(mat_beam)
    render.DrawBeam(self.StartPos, self.EndPos, sc * 2.5 + 1.0, CurTime(), CurTime(), self.Color)
    render.SetMaterial(mat_light)
    render.DrawSprite(self.StartPos, sc * 30, sc * 30, self.Color)
    render.DrawSprite(self.EndPos, sc * 30, sc * 30, self.Color)
end