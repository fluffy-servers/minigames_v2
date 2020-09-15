SWEP.Base = "weapon_css_rifle-base"
SWEP.PrintName = "AK47"
SWEP.Spawnable = true
SWEP.Category = "CSS Weapons"

SWEP.Slot = 1
SWEP.Slotpos = 0

SWEP.Primary.Damage = 20
SWEP.Primary.Delay = 0.15
SWEP.Primary.Recoil = 7.5
SWEP.Primary.Cone = 0.03
SWEP.Primary.NumShots = 1

SWEP.Primary.Sound = "weapons/ak47/ak47-1.wav"

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Automatic = true

SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"

SWEP.HoldType = 'ar2'
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.ViewModelFov = 62
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"

function SWEP:Initialize() 
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    self.Weapon:EmitSound(self.Primary.Sound)
    self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone)
    self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
    self:TakePrimaryAmmo(1)
    self.Owner:ViewPunch(Angle(math.Rand(-0.2, -0.1) * self.Primary.Recoil, math.Rand(-0.1, 0.1) * self.Primary.Recoil, 0))
end

function SWEP:Reload()
    self:DefaultReload(ACT_VM_RELOAD)
end