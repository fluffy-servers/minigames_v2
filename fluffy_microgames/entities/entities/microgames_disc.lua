AddCSLuaFile()
ENT.Type = "anim"
ENT.Radius = 72

function ENT:Initialize()
    if CLIENT then
        local mins = Vector(-self.Radius, -self.Radius, -2)
        local maxs = -1 * mins
        self:SetRenderBounds(mins, maxs)

        return
    end

    self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_NONE)
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    self:SetTrigger(true)
    self:DrawShadow(false)
    self:SetNWInt("Radius", self.Radius)
end

function ENT:GetPlayers()
    local radius = self:GetNWInt("Radius", self.Radius) + 4
    local entities = ents.FindInSphere(self:GetPos(), radius)
    local results = {}

    for k, v in pairs(entities) do
        if not v:IsPlayer() then continue end
        table.insert(results, v)
    end

    return results
end

if CLIENT then
    ENT.Circle = Material("sprites/sent_ball")

    function ENT:Draw()
        local radius = self:GetNWInt("Radius", self.Radius)
        render.SetMaterial(self.Circle)
        render.DrawQuadEasy(self:GetPos() + Vector(0, 0, 1), self:GetUp(), radius * 2, radius * 2, self:GetColor())
    end
end