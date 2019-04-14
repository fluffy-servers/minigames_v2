if CLIENT then
	-- Define the name and slot clientside
	SWEP.PrintName = "Laser Dance Cannon"
	SWEP.Slot = 0
	SWEP.SlotPos = 0
	SWEP.IconLetter = "f"
    killicon.AddFont("weapon_laserdance", "HL2MPTypeDeath", ".", Color( 255, 80, 0, 255 ))
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
SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.ViewModelFOV = 62
SWEP.WorldModel = "models/weapons/w_357.mdl"

function SWEP:PrimaryAttack()
	self.Weapon:EmitSound('weapons/airboat/airboat_gun_energy1.wav', 75, math.random(100, 160))
	self:ShootBullet(self.Primary.Damage, 1, self.Primary.Cone)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    
    -- Send the player flying backwards
	self.Owner:ViewPunch(Angle(-10, 0, 0))
	self.Owner:SetGroundEntity(NULL)
	self.Owner:SetLocalVelocity(self.Owner:GetAimVector() * -1000)
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
    bullet.HullSize = 3
	bullet.Tracer = 1
	bullet.TracerName = "ld_tracer"
    bullet.Callback = function(a, t, dmg)
        dmg:SetDamageType(DMG_DISSOLVE)
    end
	self.Owner:FireBullets(bullet)
    
	-- Make the firing look nice
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	--self.Owner:MuzzleFlash()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:DoImpactEffect( tr, nDamageType )
	if (tr.HitSky) then return end

	local effectdata = EffectData()
	effectdata:SetOrigin(tr.HitPos + tr.HitNormal)
	effectdata:SetNormal(tr.HitNormal)
	util.Effect("AR2Impact", effectdata)
    return true
end