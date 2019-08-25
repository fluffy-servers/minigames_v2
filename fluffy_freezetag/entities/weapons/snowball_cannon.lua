if CLIENT then
	-- Define the name and slot clientside
	SWEP.PrintName = "Snowball Cannon"
	SWEP.Slot = 1
	SWEP.SlotPos = 0
	SWEP.IconLetter = "f"
    killicon.AddFont("snowball_cannon", "HL2MPTypeDeath", "-", Color( 255, 80, 0, 255 ))
end

-- Primary fire damage and aim settings
SWEP.Primary.Damage = 100
SWEP.Primary.Delay = 0.5
SWEP.Primary.Recoil = 0
SWEP.Primary.Cone = 0.02

-- Primary ammo settings
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = false
SWEP.Primary.Sound = Sound("Weapon_357.Single")

-- We don't have anything that uses secondary ammo so there's nothing here for it

-- Set the model for the gun
-- Using hands is preferred
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.ViewModelFOV = 62
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

function SWEP:Initialize()
    self:SetHoldType('pistol')
end

function SWEP:PrimaryAttack()
    --models/debug/debugwhite
    --weapons/357/357_fire2.wav
	self.Weapon:EmitSound(self.Primary.Sound, 35, math.random(95,105))
	self:ShootBullet(self.Primary.Damage, 1, self.Primary.Cone)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:SecondaryAttack()
	-- Nothing here!
	-- Make sure this is blank to override the default
end

-- Feel free to steal this code for any weapons
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
	bullet.AmmoType = "Pistol"
    bullet.HullSize = 12
	bullet.Tracer = 1
    bullet.TracerName = 'snowball_tracer'
	self.Owner:FireBullets(bullet)
    
    -- Make the firing look nice
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	--self.Owner:MuzzleFlash()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
end