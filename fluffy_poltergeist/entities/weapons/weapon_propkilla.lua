SWEP.Base = 'weapon_mg_base'

if CLIENT then
    SWEP.PrintName = "Prop Shooter"
    SWEP.IconLetter = '2'
    SWEP.IconFont = 'HL2MPTypeDeath'
    killicon.AddFont("weapon_propkilla", "HL2MPTypeDeath", "2", Color(255, 80, 0, 255))
end

SWEP.HoldType = "ar2"
SWEP.ViewModel = "models/weapons/c_irifle.mdl"
SWEP.WorldModel = "models/weapons/w_irifle.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = "weapons/ar1/ar1_dist1.wav"
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.005
SWEP.Primary.Delay = 0.3
SWEP.Primary.Damage = 45
SWEP.Primary.Tracer = "mg_tracer"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = 'none'

SWEP.Secondary.Sound = "Weapon_AR2.Single"
SWEP.Secondary.NumShots = 1
SWEP.Secondary.Cone = 0.05
SWEP.Secondary.Damage = 22
SWEP.Secondary.Tracer = "mg_tracer"
SWEP.Secondary.Delay = 3
SWEP.Secondary.BurstTime = 0.125

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = 'none'

function SWEP:CanPrimaryAttack()
    return true
end

-- Burst fire?
function SWEP:SecondaryAttack()
    self.BurstFireTime = CurTime() + 2
    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
    self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
end

function SWEP:Think()
    if (self.BurstFireTime or 0) > CurTime() then
        if (self.BurstShotTime or 0) < CurTime() then
            self:EmitSound(self.Secondary.Sound, 100, math.random(120, 140))
            self:ShootBulletEx(self.Secondary.Damage, self.Secondary.NumShots, self.Secondary.Cone, self.Secondary.Tracer)
            self.BurstShotTime = CurTime() + self.Secondary.BurstTime
        end
    elseif (self.BurstFireTime or 0) != -1 then
        self.BurstFireTime = -1
        self:SendWeaponAnim(ACT_VM_RELOAD)
    end
end