if CLIENT then
	SWEP.PrintName = "Mingames Base Weapon"
	SWEP.Slot = 0
	SWEP.SlotPos = 0

	SWEP.IconLetter = '-'
	SWEP.IconFont = 'HL2MPTypeDeath'
	surface.CreateFont("CSSelectIcons", {font="csd", size=72})


	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		draw.SimpleText(self.IconLetter, self.IconFont, x + wide/2, y + tall/2.5, Color(241, 196, 15), TEXT_ALIGN_CENTER)
	end
end

-- Primary fire damage and aim settings
SWEP.Primary.Damage = 1000
SWEP.Primary.Delay = 0.5
SWEP.Primary.Recoil = 0
SWEP.Primary.Cone = 0
SWEP.Primary.NumShots = 1

-- Primary ammo settings
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = false

SWEP.HoldType = 'pistol'

-- We don't have anything that uses secondary ammo so there's nothing here for it
-- If making a gun derived from this you'd have to add this yourself

-- Set the model for the gun
-- Using hands is preferred
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.ViewModelFOV = 62
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

-- Apply the weapon hold type
function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end 

-- Generic primary attack function
function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    
    self.Weapon:EmitSound(self.Primary.Sound)
	self:ShootBulletEx(self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone, self.Primary.Tracer)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
    self:TakePrimaryAmmo(1)
    self.Owner:ViewPunch(Angle(math.Rand(-0.2, -0.1) * self.Primary.Recoil, math.Rand(-0.1, 0.1) * self.Primary.Recoil, 0))
end

function SWEP:SecondaryAttack()
	-- Nothing here (in the base)
	-- This can be overwritten for secondary-fire functionality
    if not self:CanSecondaryAttack() then return end
end

function SWEP:Reload()
    self:DefaultReload(ACT_VM_RELOAD)
end

-- Helper function to fire bullets
-- Firing bullets can be a bit of a pain but this really helps
function SWEP:ShootBullet(damage, numbullets, aimcone)
	if self.StableAccuracy then
    	-- Spread penalty for moving
    	if self.Owner:KeyDown(IN_FORWARD) or self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_MOVELEFT) or self.Owner:KeyDown(IN_MOVERIGHT) then
    	    aimcone = aimcone * 2.5
    	end
	
    	-- Accuracy increase for crouching or walking
    	if self.Owner:KeyDown(IN_DUCK) or self.Owner:KeyDown(IN_WALK) then
    	    aimcone = math.Clamp(aimcone/2.5, 0, 10)
    	end
	end

	-- Setup the bullet table and fire it
	local scale = aimcone
	local bullet = {}
	bullet.Num 		= numbullets
	bullet.Src 		= self.Owner:GetShootPos()
	bullet.Dir 		= self.Owner:GetAimVector()
	bullet.Spread 	= Vector(scale, scale, 0)	
	bullet.Force	= math.Round(damage/10)							
	bullet.Damage	= math.Round(damage)
	bullet.AmmoType = self.Primary.Ammo
	self.Owner:FireBullets(bullet)
    
	-- Make the firing look nice
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	--self.Owner:MuzzleFlash()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
end

-- Helper function with slightly more functionality
function SWEP:ShootBulletEx(damage, numbullets, aimcone, tracer, callback)
	if self.StableAccuracy then
    	-- Spread penalty for moving
    	if self.Owner:KeyDown(IN_FORWARD) or self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_MOVELEFT) or self.Owner:KeyDown(IN_MOVERIGHT) then
    	    aimcone = aimcone * 2.5
    	end
	
    	-- Accuracy increase for crouching or walking
    	if self.Owner:KeyDown(IN_DUCK) or self.Owner:KeyDown(IN_WALK) then
    	    aimcone = math.Clamp(aimcone/2.5, 0, 10)
    	end
	end

	-- Setup the bullet table and fire it
	local scale = aimcone
	local bullet = {}
	bullet.Num 		= numbullets
	bullet.Src 		= self.Owner:GetShootPos()
	bullet.Dir 		= self.Owner:GetAimVector()
	bullet.Spread 	= Vector(scale, scale, 0)
	bullet.Force	= math.Round(damage/10)
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