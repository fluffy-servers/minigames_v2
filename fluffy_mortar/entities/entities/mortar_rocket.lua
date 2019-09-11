AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Paint Bomb"

function ENT:Initialize()
    self.SpawnTime = CurTime()
    if CLIENT then return end
    
    self:SetModel('models/weapons/w_missile_closed.mdl')
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysWake()
    self:SetGravity(1)
    
    -- Add a trail
    self.Trail = util.SpriteTrail(self, 0, team.GetColor(self.Player:Team()) or color_white, false, 24, 2, 4, 1, 'trails/laser')
end

function ENT:Explode()
    local ed = EffectData()
	ed:SetOrigin(self:GetPos())
    ed:SetScale(0.1)
	util.Effect("Explosion", ed, true, true)
    
    local wep = self.Weapon
    if not IsValid(wep) then wep = self.Player end
	util.BlastDamage(wep, self.Player, self:GetPos(), 300, 150)
    --self:EmitSound('AlyxEMP.Discharge')
    
    -- stop red message of doom
    timer.Simple(0.01, function() self:Remove() end)
end

function ENT:OnRemove()
    if IsValid(self.Trail) then
        SafeRemoveEntity(self.Trail)
    end
end

function ENT:PhysicsCollide(data, phys)
    self:Explode()
end