if CLIENT then
	SWEP.PrintName = "Pew Pew"
	SWEP.Slot = 0
	SWEP.SlotPos = 0
	SWEP.IconLetter = "f"
end

SWEP.Primary.Damage = 1000
SWEP.Primary.Delay = 0.32
SWEP.Primary.Recoil = 0
SWEP.Primary.Cone = 0.0

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Automatic = false

SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
SWEP.Primary.Sound = Sound( "Weapon_357.Single" )

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	
	self:TakePrimaryAmmo(1)
	self:ShootBullets(self.Primary.Damage, 1, self.Primary.Cone)
	self.Weapon:EmitSound(self.Primary.Sound, 100, math.random(95,105))
end

function SWEP:SecondaryAttack()

end

function SWEP:ShootBullets( damage, numbullets, aimcone)

	local scale = aimcone
	local bullet = {}
	bullet.Num 		= numbullets
	bullet.Src 		= self.Owner:GetShootPos()			
	bullet.Dir 		= self.Owner:GetAimVector()			
	bullet.Spread 	= Vector( scale, scale, 0 )		
	bullet.Force	= math.Round(damage * 2)							
	bullet.Damage	= math.Round(damage)
	bullet.AmmoType = "Pistol"
	self.Owner:FireBullets(bullet)
	
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
end