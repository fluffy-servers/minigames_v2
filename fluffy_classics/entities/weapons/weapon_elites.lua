SWEP.Base = "weapon_css_pistol-base"
SWEP.PrintName = "Dual 96G Elite Berettas"
SWEP.Spawnable = true
SWEP.Category = "CSS Weapons"

SWEP.Slot = 2
SWEP.Slotpos = 0

SWEP.Primary.Damage = 12.5
SWEP.Primary.Delay = 0.15
SWEP.Primary.Recoil = 1
SWEP.Primary.Cone = 0.07
SWEP.Primary.NumShots = 1

SWEP.Primary.Sound = "weapons/elite/elite-1.wav"

SWEP.Primary.ClipSize = 15
SWEP.Primary.DefaultClip = 15
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Automatic = false

SWEP.Secondary.ClipSize = 15
SWEP.Secondary.DefaultClip = 15
SWEP.Secondary.Ammo = "Pistol"

SWEP.Secondary.Damage = 12.5
SWEP.Secondary.Delay = 0.15
SWEP.Secondary.Recoil = 1
SWEP.Secondary.Cone = 0.07
SWEP.Secondary.NumShots = 1

SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_pist_elite.mdl"
SWEP.ViewModelFov = 62
SWEP.WorldModel = "models/weapons/w_pist_elite.mdl"


function SWEP:ShootBullet(damage, numbullets, aimcone)

	local scale = aimcone
	local bullet = {}
	bullet.Num 		= numbullets
	bullet.Src 		= self.Owner:GetShootPos()
	bullet.Dir 		= self.Owner:GetAimVector()
	bullet.Spread 	= Vector(scale, scale, 0)	
	bullet.Force	= math.Round(damage/10)							
	bullet.Damage	= math.Round(damage)
	bullet.AmmoType = self.Primary.Ammo
	bullet.Tracer = 0

	self.Owner:FireBullets(bullet)
	self.Owner:MuzzleFlash()
    self.Owner:SetAnimation(PLAYER_ATTACK1)
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

function SWEP:SecondaryAttack()
	if not self:CanSecondaryAttack() then return end

    self.Weapon:EmitSound(self.Primary.Sound)
    self:ShootBullet(self.Secondary.Damage, self.Secondary.NumShots, self.Secondary.Cone)
    self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
    self:TakeSecondaryAmmo(1)
    self.Owner:ViewPunch(Angle(math.Rand(-0.2, -0.1) * self.Secondary.Recoil, math.Rand(-0.1, 0.1) * self.Secondary.Recoil, 0))
end

function SWEP:Reload()
    self:DefaultReload(ACT_VM_RELOAD)
end

function SWEP:Initialize() 
	self:SetWeaponHoldType(self.HoldType)
end
