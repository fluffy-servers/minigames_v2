SWEP.Base = "weapon_mg_base"

if CLIENT then
	SWEP.Slot = 1
	SWEP.SlotPos = 0
	
	SWEP.IconLetter = '-'
	SWEP.IconFont = 'HL2MPTypeDeath'
    killicon.AddFont("balloon_popper", "HL2MPTypeDeath", "-", Color(255, 80, 0, 255))
end
SWEP.PrintName = "Balloon Popper"

-- Primary fire damage and aim settings
SWEP.Primary.Damage = 20
SWEP.Primary.Cone = 0.015
SWEP.Primary.Delay = 0.1
SWEP.Primary.NumShots = 1
SWEP.Primary.Sound = Sound("Weapon_Pistol.Single")
SWEP.Primary.Recoil = 1
SWEP.Primary.Tracer = "mg_tracer"

-- Primary ammo settings
SWEP.Primary.ClipSize = 12
SWEP.Primary.DefaultClip = 12
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Automatic = false
SWEP.Secondary.Automatic = true -- ???

-- Set the model for the gun
-- Using hands is preferred
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.ViewModelFOV = 62
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.HoldType = 'pistol'

-- Custom bullet firing because we have an extra check to make the weapon 'wider'
function SWEP:ShootBullets(damage, numbullets, aimcone)
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
    bullet.HullSize = 32
	self.Owner:FireBullets(bullet)
    
	-- Make the firing look nice
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	--self.Owner:MuzzleFlash()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	-- Fire a secondary tracer
	-- Traces a box slightly bigger than a balloon
	-- Near-misses will still pop the balloon
	if SERVER then
		local startpos = self.Owner:GetShootPos()
		local endpos = self.Owner:GetShootPos() + (self.Owner:GetAimVector() * 1000)
		local mins = Vector(-10, -10, -10)
		local maxs = Vector(10, 10, 10)
		
		local tr = util.TraceHull( {
			start = startpos,
			endpos = endpos,
			filter = self.Owner,
			mins = mins,
			maxs = maxs,
			mask = MASK_SHOT_HULL
		} )
		
		-- If the tracer hits a balloon - apply damage to it
		if tr.Hit and !tr.HitWorld then
			if tr.Entity.Balloon then
				tr.Entity:TakeDamage(100, self.Owner, self)
			end
		end
	end
end