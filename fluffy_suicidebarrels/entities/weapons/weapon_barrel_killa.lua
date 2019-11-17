if SERVER then
	AddCSLuaFile()
end

if CLIENT then
	SWEP.PrintName				= "Barrel Shooter"
	SWEP.Slot					= 0
	SWEP.SlotPos				= 0
    killicon.AddFont("weapon_barrel_killa", "HL2MPTypeDeath", "-", Color( 255, 80, 0, 255 ) )
end

SWEP.Base						= "weapon_base"
SWEP.HoldType					= "pistol"
SWEP.Purpose					= "Use this to kill those damn barrels."
 
SWEP.ViewModel					= Model("models/weapons/c_pistol.mdl")
SWEP.WorldModel					= Model("models/weapons/w_pistol.mdl")
SWEP.UseHands                   = true

SWEP.Primary.Sound				= Sound( "Weapon_Pistol.Single" )
SWEP.Primary.Recoil				= 0
SWEP.Primary.Damage				= 1000
SWEP.Primary.Cone				= 0
SWEP.Primary.Automatic			= false
SWEP.Primary.ClipSize			= 1
SWEP.Primary.Ammo				= "pistol";

SWEP.Secondary.ClipSize			= -1 
SWEP.Secondary.DefaultClip		= -1 
SWEP.Secondary.Automatic		= false 
SWEP.Secondary.Ammo				= "none" 

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end

	self.Weapon:EmitSound(self.Primary.Sound)
	self:ShootBullets(self.Primary.Damage, 1, self.Primary.Cone, 'mg_tracer')
	self:TakePrimaryAmmo(1)
	self.Owner:ViewPunch(Angle(-self.Primary.Recoil, 0, 0 ))
end

function SWEP:SecondaryAttack()

end

function SWEP:ShootBullets(damage, numbullets, aimcone, tracer)
	local scale = aimcone
	if self.Owner:KeyDown(IN_FORWARD) or self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_MOVELEFT) or self.Owner:KeyDown(IN_MOVERIGHT) then
		scale = aimcone * 1.5
	elseif self.Owner:KeyDown(IN_DUCK) or self.Owner:KeyDown(IN_WALK) then
		scale = math.Clamp(aimcone / 2, 0, 10)
	end
	
	local bullet = {}
	bullet.Num 		= numbullets
	bullet.Src 		= self.Owner:GetShootPos()			
	bullet.Dir 		= self.Owner:GetAimVector()			
	bullet.Spread 	= Vector(scale, scale, 0)		
	bullet.Tracer	= 1	
	bullet.Force	= damage * 3							
	bullet.Damage	= damage
	bullet.AmmoType = "Pistol"
	bullet.TracerName 	= tracer
	bullet.Callback = function (attacker, tr, dmginfo)
	
	end
	
	self.Owner:FireBullets(bullet)
	self.Owner:SetAnimation(PLAYER_ATTACK1)				// 3rd Person Animation
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
end
