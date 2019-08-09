if CLIENT then
	-- Define the name and slot clientside
	SWEP.PrintName = "Base Weapon"
	SWEP.Slot = 0
	SWEP.SlotPos = 0
end

-- Primary fire damage and aim settings
SWEP.Primary.Damage = 1000
SWEP.Primary.Delay = 0.5
SWEP.Primary.Recoil = 0
SWEP.Primary.Cone = 0

-- Primary ammo settings
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = false

-- We don't have anything that uses secondary ammo so there's nothing here for it

-- Set the model for the gun
-- Using hands is preferred
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.ViewModelFOV = 62
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

-- Generic primary attack function
function SWEP:PrimaryAttack()
    self.Weapon:EmitSound(self.Primary.Sound)
	self:ShootBullet(self.Primary.Damage, 1, self.Primary.Cone)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:SecondaryAttack()
	-- Nothing here!
	-- Make sure this is blank to override the default
end

-- Helper function to fire bullets
function SWEP:ShootBullet(damage, numbullets, aimcone)
	-- Setup the bullet table and fire it
	local scale = aimcone
	local bullet = {}
	bullet.Num 		= numbullets
	bullet.Src 		= self.Owner:GetShootPos()
	bullet.Dir 		= self.Owner:GetAimVector()
	bullet.Spread 	= Vector(scale, scale, 0)	
	bullet.Force	= math.Round(damage * 2)							
	bullet.Damage	= math.Round(damage)
	bullet.AmmoType = self.Primary.Ammo
    bullet.Callback = function(a, t, dmg)
        dmg:SetDamageType(DMG_DISSOLVE)
    end
	self.Owner:FireBullets(bullet)
    
	-- Make the firing look nice
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	--self.Owner:MuzzleFlash()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
end

-- Helper function with slightly more functionality
function SWEP:ShootBulletEx(damage, numbullets, aimcone, tracer, callback)
	-- Setup the bullet table and fire it
	local scale = aimcone
	local bullet = {}
	bullet.Num 		= numbullets
	bullet.Src 		= self.Owner:GetShootPos()
	bullet.Dir 		= self.Owner:GetAimVector()
	bullet.Spread 	= Vector(scale, scale, 0)
	bullet.Force	= math.Round(damage * 2)
	bullet.Damage	= math.Round(damage)
	bullet.AmmoType = self.Primary.Ammo
	bullet.Tracer = 1
	bullet.TracerName = tracer
    if callback then
        bullet.Callback = callback
    end
	self.Owner:FireBullets(bullet)
    
	-- Make the firing look nice
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	--self.Owner:MuzzleFlash()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
end