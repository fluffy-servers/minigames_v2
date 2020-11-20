AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:Initialize()
    if CLIENT then return end
    self:SetModel("models/fw/fw_flag.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Sleep()
    end

    self.NoExplode = true
end

function ENT:OnTakeDamage(dmg)
    -- Remove if in contact with a trigger hurt
    if dmg:GetInflictor():GetClass() == "trigger_hurt" or dmg:GetAttacker():GetClass() == "trigger_hurt" then
        self.NoExplode = false
        self:Remove()

        return
    end

    self:TakePhysicsDamage(dmg)
end

function ENT:OnRemove()
    if SERVER then
        GAMEMODE:SpawnFlag()
    end
end

function ENT:Use(ply)
    if IsValid(ply) and ply:IsPlayer() then
        GAMEMODE:CollectFlag(ply)
    end
end

if CLIENT then
    killicon.AddFont("ctf_flag", "HL2MPTypeDeath", "8", Color(255, 80, 0, 255))

    -- local mat = Material("models/fw/flaginner")

    function ENT:Think()
    end
end