SWEP.Base = "weapon_mg_base"

SWEP.UseHands = true
SWEP.ViewModelFOV = 62

SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"

if CLIENT then
    surface.CreateFont("CSTypeDeath", {
    	font = "csd",
    	size = ScreenScale(20),
        antialias = true,
        weight = 300
    })
end

-- Override this function to scale all the values
-- What this does is allow us to use values straight from CS:S weapons
-- while keeping consistent internal balance
function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end

    local scaled_damage = math.floor(self.Primary.Damage * 0.5)

    self:EmitSound(self.Primary.Sound)
	self:ShootBulletEx(scaled_damage, self.Primary.NumShots, self.Primary.Cone * 5, self.Primary.Tracer)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
    self:TakePrimaryAmmo(1)
    self:GetOwner():ViewPunch(Angle(math.Rand(-0.4, -0.2) * self.Primary.Recoil * 5, math.Rand(-0.1, 0.1) * self.Primary.Recoil * 5, 0))
end