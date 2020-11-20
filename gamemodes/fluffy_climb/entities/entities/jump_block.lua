AddCSLuaFile()
ENT.Type = "anim"

function ENT:Initialize()
    self:PhysicsInitShadow(false, false)
    self:SetSolid(SOLID_VPHYSICS)
end

function ENT:SetJumpBlock()
    self.OldColor = self:GetColor()
    self:SetColor(Color(0, 255, 0))
    self:SetMaterial("tools/toolswhite", true)
    self:SetTrigger(true)
    self.JumpMode = true
end

function ENT:StartTouch(ent)
    if not self.JumpMode then return end
    if not IsValid(ent) then return end
    if not ent:IsPlayer() then return end
    ent:SetVelocity(Vector(0, 0, math.random(600, 1000)))
    self.JumpMode = false
    self:SetMaterial()
    self:SetColor(self.OldColor or color_white)
end