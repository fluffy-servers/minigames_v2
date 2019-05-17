AddCSLuaFile()

ENT.Base = 'npc_zo_base'
ENT.PrintName = 'Boom Zombie'

if CLIENT then
    language.Add('npc_zombie_boom', 'Boom Zombie' )
end

-- Speed
ENT.Speed = 150
ENT.WalkSpeedAnimation = 0.6
ENT.Acceleration = 200
ENT.MoveType = 1

-- Health & Other
ENT.Model = "models/player/zombie_soldier.mdl"
ENT.BaseHealth = 30
ENT.Damage = 25

-- Override default death function
-- This zombie blows up on death instead of creating a ragdoll
function ENT:OnKilled(info)
    if self.Exploded then return end
    self.Exploded = true
    hook.Run('OnNPCKilled', self, info:GetAttacker(), info:GetInflictor()) -- Run the hook
    
    local ed = EffectData()
	ed:SetOrigin(self:GetPos())
	util.Effect("Explosion", ed, true, true)
	util.BlastDamage(self, self, self:GetPos(), 175, 125)
    
    self:Remove()
end