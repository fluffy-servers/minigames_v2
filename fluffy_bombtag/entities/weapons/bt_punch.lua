SWEP.Base = 'weapon_mg_base'

if CLIENT then
    SWEP.IconLetter = '.'
    SWEP.IconFont = 'HL2MPTypeDeath'
    killicon.AddFont("bt_punch", "SWB_KillIcons", SWEP.IconLetter, Color(1, 177, 236, 150))
end

SWEP.PrintName = "Puncher"
SWEP.HoldType = "pistol"
SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.UseHands = true
SWEP.Primary.Sound = Sound("Weapon_AR2.Single")
SWEP.Primary.Delay = 0.4

function SWEP:Initialize()
    self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Deploy()
    self:SendWeaponAnim(ACT_VM_DRAW)

    return true
end

function SWEP:Think()
end

function SWEP:Reload()
end

function SWEP:CanPrimaryAttack()
    return true
end

function SWEP:PrimaryAttack()
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:EmitSound(self.Primary.Sound, 100, math.random(110, 130))
    self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone)
end

function SWEP:SecondaryAttack()
end

function SWEP:ShootBullets()
    local owner = self:GetOwner()
    local bullet = {}
    bullet.Num = numbullets
    bullet.Src = owner:GetShootPos()
    bullet.Dir = owner:GetAimVector()
    bullet.Spread = Vector(0.025, 0.025, 0)
    bullet.Tracer = 1
    bullet.Force = 100
    bullet.Damage = 15
    bullet.AmmoType = "Pistol"
    bullet.TracerName = "mg_tracer"

    bullet.Callback = function(attacker, tr, dmginfo)
        if CLIENT then return end

        if tr.Entity:IsPlayer() then
            dmginfo:SetDamage(0)
            local vel = owner:GetAimVector() * 1000
            vel.z = 300
            tr.Entity:SetVelocity(vel)
        end
    end

    owner:FireBullets(bullet)
    owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:DoImpactEffect(tr, nDamageType)
    if tr.HitSky then return end
    local effectdata = EffectData()
    effectdata:SetOrigin(tr.HitPos + tr.HitNormal)
    effectdata:SetNormal(tr.HitNormal)
    util.Effect("AR2Impact", effectdata)

    return true
end