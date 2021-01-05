SWEP.Base = "weapon_mg_base"

if CLIENT then
    SWEP.PrintName = "Platform Breaker!"
    SWEP.Slot = 1
    SWEP.SlotPos = 1
    SWEP.IconLetter = "-"
    SWEP.IconFont = "HL2MPTypeDeath"
    killicon.AddFont("weapon_platformbreaker", "HL2MPTypeDeath", "-", Color(255, 80, 0, 255))
end

SWEP.Purpose = "Hurt a platform or push the nearest person"
SWEP.Instructions = "Primary to attack a platform, Secondary to punt people close to you"
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.UseHands = true

SWEP.Primary.Recoil = 0.25
SWEP.Primary.Damage = 1
SWEP.Primary.BulletForce = 1
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.01
SWEP.Primary.ClipSize = -1
SWEP.Primary.Delay = 0.35
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = 9999
SWEP.Secondary.DefaultClip = 9999
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = 9999
SWEP.Secondary.Delay = 1.8
SWEP.Secondary.NextUse = 0
SWEP.Secondary.Recoil = 2

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    self:EmitSound("Weapon_AR2.Single")
    self:ShootBullet(0.01, self.Primary.NumShots, self.Primary.Cone) -- for effects

    if SERVER then
        local tr = {}
        tr.start = owner:GetShootPos()
        tr.endpos = owner:GetShootPos() + owner:GetAimVector() * 1500

        tr.filter = {owner}

        local trace = util.TraceLine(tr)

        if IsValid(trace.Entity) and trace.Entity:GetClass() == "til_tile" then
            trace.Entity:OnTakeDamage(owner)
        end
    end

    owner:ViewPunch(Angle(-self.Primary.Recoil, math.Rand(-1, 1) * self.Primary.Recoil, 0))
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:SecondaryAttack()
    self:EmitSound("AlyxEMP.Discharge")
    self:Knockback()
    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
end

function SWEP:Knockback()
    local owner = self:GetOwner()
    local ents = ents.FindInCone(owner:GetShootPos(), owner:GetAimVector(), 100, 0.3)
    local effectdata = EffectData()
    effectdata:SetStart(owner:GetShootPos())
    effectdata:SetEntity(self)
    effectdata:SetOrigin(owner:GetShootPos() + owner:GetAimVector() * 150)
    effectdata:SetAttachment(1)
    util.Effect("mg_tracer", effectdata)

    for k, v in pairs(ents) do
        if not v:IsPlayer() then continue end
        if v == owner then continue end

        if v then
            local dist = owner:GetPos():DistToSqr(v:GetPos())

            if dist < 400000 then
                v:ViewPunch(Angle(-10, 0, 0))
                local vec = owner:GetAimVector()
                vec.z = math.abs(vec.z) + 0.25
                v:SetGroundEntity(NULL)
                v:SetLocalVelocity(vec * math.random(250, 550))
            end

            v.LastKnockback = owner
            v.KnockbackTime = CurTime()
        end
    end

    owner:SetAnimation(PLAYER_ATTACK1)
end