AddCSLuaFile()
EFFECT.Mat = Material("sprites/sent_ball")

function EFFECT:Init(data)
    -- Get data from the weapon
    self.Position = data:GetStart()
    self.Weapon = data:GetEntity()
    self.Attachment = data:GetAttachment()
    -- Calculate the positions
    self.StartPos = self:GetTracerShootPos(self.Position, self.Weapon, self.Attachment)
    self.EndPos = data:GetOrigin()
    self.Dir = self.EndPos - self.StartPos
    self.Length = (self.StartPos - self.EndPos):Length()
    self.Size = math.random(5, 12)
    -- Calculate the color
    self.Color = color_white
    self.Life = 1

    if IsValid(self.Weapon) then
        local c = self.Weapon.Owner:GetNWVector('WeaponColor', Vector(1, 1, 1))
        self.Color = Color(c.x * 255, c.y * 255, c.z * 255)
    end
end

function EFFECT:Think()
    self.Life = self.Life - 10 * FrameTime()

    return (self.Life > 0)
end

function EFFECT:Render()
    local delta = 1 - self.Life
    render.SetMaterial(self.Mat)
    local pos = self.StartPos + self.Dir * delta
    render.DrawSprite(pos, self.Size, self.Size, self.Color)
end