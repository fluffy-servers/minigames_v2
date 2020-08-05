AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Health = 50
ENT.Model = "models/props_junk/wood_crate001a.mdl"
ENT.Team = TEAM_BLUE

function ENT:Initialize()
    if CLIENT then return end
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    -- Apply team color
    self:SetColor(team.GetColor(self.Team))
end

function ENT:OnTakeDamage(dmg)
    -- todo
end

function ENT:OnRemove()
    -- Decrement team score
    team.AddScore(self.Team, 1)
    GAMEMODE:CheckRoundEnd()
end