AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Paint Bomb"

if CLIENT then
    ENT.PaintSplat = Material("decals/decal_paintsplatterpink001")
end

function ENT:Initialize()
    self.SpawnTime = CurTime()
    if CLIENT then return end
    self:SetModel("models/weapons/w_missile_closed.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysWake()
    self:SetGravity(0)
    -- Add a trail
    self.Trail = util.SpriteTrail(self, 0, team.GetColor(self.Player:Team()) or color_white, false, 24, 2, 4, 1, "trails/laser")
end

function ENT:Explode()
    local ed = EffectData()
    ed:SetOrigin(self:GetPos())
    ed:SetScale(0.1)
    util.Effect("Explosion", ed, true, true)

    local wep = self.WeaponEnt
    if not IsValid(wep) then
        wep = self.Player
    end
    util.BlastDamage(wep, self.Player, self:GetPos(), 300, 150)

    --self:EmitSound("AlyxEMP.Discharge")
    -- stop red message of doom
    timer.Simple(0.01, function()
        self:Remove()
    end)
end

function ENT:OnRemove()
    if CLIENT then
        local vel = self:GetVelocity():GetNormalized()
        local tr = util.QuickTrace(self:GetPos(), vel * 5000, self)
        self:SetPos(tr.HitPos)
        self:PaintSplatter()
    else
        if IsValid(self.Trail) then
            SafeRemoveEntity(self.Trail)
        end
    end
end

function ENT:PaintSplatter()
    if SERVER then return end

    for i = 1, 32 do
        local v = VectorRand() * math.random(120, 200)
        local tr = util.QuickTrace(self:GetPos(), v, self)
        if tr.HitSky then return end
        local c = HSVToColor(math.random(0, 360), 1, 1)
        local s = 0.6 + math.random()
        util.DecalEx(self.PaintSplat, tr.HitEntity or game.GetWorld(), tr.HitPos, tr.HitNormal, c, s, s)
    end
end

function ENT:PhysicsCollide(data, phys)
    self:Explode()
end