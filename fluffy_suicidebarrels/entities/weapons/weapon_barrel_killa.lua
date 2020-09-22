SWEP.Base = 'weapon_mg_base'

if CLIENT then
    SWEP.PrintName = "Barrel Shooter"
    SWEP.IconLetter = '-'
    SWEP.IconFont = 'HL2MPTypeDeath'
    killicon.AddFont("weapon_barrel_killa", "HL2MPTypeDeath", "-", Color(255, 80, 0, 255))
end

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.HoldType = "pistol"
SWEP.UseHands = true
SWEP.Primary.Sound = Sound("Weapon_Pistol.Single")
SWEP.Primary.Recoil = 0
SWEP.Primary.Damage = 1000
SWEP.Primary.Cone = 0
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.Tracer = "mg_tracer"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

-- Generic primary attack function
function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    self.Weapon:EmitSound(self.Primary.Sound)
    self:ShootBulletEx(self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone, self.Primary.Tracer)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
    self:TakePrimaryAmmo(1)
    self:Reload()
    self.Owner:ViewPunch(Angle(math.Rand(-0.2, -0.1) * self.Primary.Recoil, math.Rand(-0.1, 0.1) * self.Primary.Recoil, 0))
end