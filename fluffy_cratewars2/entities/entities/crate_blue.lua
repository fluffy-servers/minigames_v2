AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Health = 50
ENT.Model = "models/props_junk/wood_crate001a.mdl"

function ENT:Initialize()
    if CLIENT then return end
    self:SetModel(self.Model)
end

function ENT:OnTakeDamage(dmg)
    -- todo
end

function ENT:OnRemove()

end