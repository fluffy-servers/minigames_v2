AddCSLuaFile()
ENT.BombTimer = 3
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Paint Bomb"

if CLIENT then
    ENT.PaintSplat = Material('decals/decal_paintsplatterpink001')
end

function ENT:Initialize()
    self.SpawnTime = CurTime()
    if CLIENT then return end
    self:SetModel('models/weapons/w_grenade.mdl')
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysWake()
end

function ENT:Explode()
    local ed = EffectData()
    ed:SetOrigin(self:GetPos())
    ed:SetScale(0.1)
    util.Effect("Explosion", ed, true, true)
    local wep = self.Weapon

    if not IsValid(wep) then
        wep = self.Player
    end

    util.BlastDamage(wep, self.Player, self:GetPos(), 300, 150)

    --self:EmitSound('AlyxEMP.Discharge')
    -- stop red message of doom
    timer.Simple(0.01, function()
        self:Remove()
    end)
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

function ENT:Think()
    if not self.SpawnTime then return end

    if CurTime() - self.SpawnTime > self.BombTimer then
        self.SpawnTime = CurTime()

        if CLIENT then
            self:PaintSplatter()
        end

        if SERVER then
            self:Explode()
        end
    else
        self:EmitSound('Grenade.Blip')

        if CLIENT then
            self:SetNextClientThink(CurTime() + 0.5)
        end

        if SERVER then
            self:NextThink(CurTime() + 0.5)
        end

        return true
    end
end