AddCSLuaFile()
DEFINE_BASECLASS("base_anim")

function ENT:Initialize()
    if CLIENT then return end
    self:SetModel('models/dynamite/dynamite.mdl')
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysWake()
end

function ENT:Explode()
    local ed = EffectData()
	ed:SetOrigin(self:GetPos())
	util.Effect("Explosion", ed, true, true)
	util.BlastDamage(self, self.Owner or self, self:GetPos(), 300, 100)
    
    -- stop red message of doom
    timer.Simple(0.01, function() self:Remove() end)
end

function ENT:PhysicsCollide(data, phys)
    self:Explode()
end