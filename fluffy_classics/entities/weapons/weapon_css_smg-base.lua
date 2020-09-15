SWEP.PrintName = "CSS Pistol Base"
    
SWEP.Author = "Xobile"
SWEP.Contact = "https://steamcommunity.com/id/xobile1/"
SWEP.Category = "CSS Weapons"

SWEP.Slots = 2
SWEP.Slotpos = 0
SWEP.AdminOnly = false
SWEP.Spawnable = true

SWEP.Primary.Damage = 12.5
SWEP.Primary.Delay = 0.1
SWEP.Primary.Recoil = 1
SWEP.Primary.Cone = 0.07
SWEP.Primary.NumShots = 1

SWEP.Primary.Sound = "Weapon_Pistol.Single"

SWEP.Primary.ClipSize = 7
SWEP.Primary.DefaultClip = 7
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Automatic = false

SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"

SWEP.HoldType = 'pistol'
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.ViewModelFov = 62
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

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