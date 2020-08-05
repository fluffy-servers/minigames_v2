AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.CrateHealth = 50
ENT.Model = "models/props_junk/wood_crate001a.mdl"
ENT.Team = TEAM_BLUE

function ENT:Initialize()
    if CLIENT then return end
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end

    self:PrecacheGibs()
    self:SetHealth(self.CrateHealth)

    -- Apply team color
    self:SetColor(team.GetColor(self.Team))
end

function ENT:OnTakeDamage(dmg)
    local attacker = dmg:GetAttacker()
    if attacker:IsPlayer() then
        if attacker:Team() == self.Team then return end
    end

    self:SetHealth(self:Health() - dmg:GetDamage())
    if self:Health() <= 0 then
        self:Break(dmg:GetDamageForce())
    end
end

function ENT:Break(force)
    self:GibBreakClient(force * 0.1)
    self:Remove()

    -- Decrement team score
    team.AddRoundScore(self.Team, -1)
    GAMEMODE:CheckRoundEnd()
end