if CLIENT then
	-- Define the name and slot clientside
	SWEP.PrintName = "Pew Pew"
	SWEP.Slot = 0
	SWEP.SlotPos = 0
	SWEP.IconLetter = "f"
    killicon.AddFont("oitc_gun", "CSKillIcons", "f", Color( 255, 80, 0, 255 ))
end

-- Primary fire damage and aim settings
SWEP.Primary.Damage = 1000
SWEP.Primary.Delay = 0.32
SWEP.Primary.Recoil = 0
SWEP.Primary.Cone = 0.0

-- Primary ammo settings
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Automatic = false

-- We don't have anything that uses secondary ammo so there's nothing here for it

-- Set the model for the gun
-- Using hands is preferred
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
SWEP.Primary.Sound = Sound("Weapon_357.Single")

function SWEP:PrimaryAttack()
	-- Make sure the weapon is allowed to fire
	if !self:CanPrimaryAttack() then return end
	-- Set the next fire time
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	
	-- Take ammo and fire the bullets
	self:TakePrimaryAmmo(1)
	self:ShootBullets(self.Primary.Damage, 1, self.Primary.Cone)
	self.Weapon:EmitSound(self.Primary.Sound, 100, math.random(95,105))
end

function SWEP:SecondaryAttack()
	-- Nothing here!
	-- Make sure this is blank to override the default
end

-- Feel free to steal this code for any weapons
function SWEP:ShootBullets(damage, numbullets, aimcone)
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
	self.Owner:FireBullets(bullet)
	
	-- Make the firing look nice
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
end