SWEP.Base = "weapon_mg_shotgun"
SWEP.PrintName = "Super Shotgun"
SWEP.Knockback = 425

if CLIENT then
    killicon.AddFont("super_shotgun", "HL2MPTypeDeath", "0", Color(255, 80, 0, 255))
end

-- Primary fire damage and aim settings
SWEP.Primary.Damage = 15
SWEP.Primary.Cone = 0.1
SWEP.Primary.Delay = 0.45
SWEP.Primary.NumShots = 6
SWEP.Primary.Sound = Sound("Weapon_Shotgun.Single")
SWEP.Primary.Recoil = 8
-- Primary ammo settings
SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.Automatic = true
SWEP.Secondary.Automatic = true
SWEP.Secondary.Delay = 1.25

-- Fire both shells on secondary attack
function SWEP:SecondaryAttack()
    if self:Clip1() < 2 then return end
    self:EmitSound("Weapon_Shotgun.Double")
    self:ShootBullet(self.Primary.Damage, math.floor(self.Primary.NumShots * 1.5), self.Primary.Cone)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
    self:TakePrimaryAmmo(2)
    self:GetOwner():ViewPunch(Angle(math.Rand(-0.2, -0.1) * self.Primary.Recoil * 2, math.Rand(-0.1, 0.1) * self.Primary.Recoil * 2, 0))

    -- Send the shooter flying backwards
    self:GetOwner():SetGroundEntity(NULL)
    self:GetOwner():SetLocalVelocity(self:GetOwner():GetAimVector() * -self.Knockback)
end