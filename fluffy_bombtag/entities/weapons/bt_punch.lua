if SERVER then
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if CLIENT then
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true
	SWEP.CSMuzzleFlashes	= true

	SWEP.ViewModelFOV		= 75
	SWEP.ViewModelFlip		= false
	
	SWEP.PrintName = "Puncher"
	SWEP.IconLetter = "m"
	SWEP.Slot = 0
	SWEP.Slotpos = 0
	
	--SWEP.IconFont = "CSSelectIcons"
	SWEP.KillFont = "CSKillIcons"
	
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		draw.SimpleText( self.IconLetter, self.IconFont, x + wide/2, y + tall/2.5, Color( 50, 200, 50, 255 ), TEXT_ALIGN_CENTER )
	end
	
	SWEP.IconLetter = "m"
	surface.CreateFont( "SWB_KillIcons", {font = "csd", size = ScreenScale(30), weight = 500, blursize = 0, antialias = true, shadow = false} )
	killicon.AddFont("bt_punch", "SWB_KillIcons", SWEP.IconLetter, Color(1, 177, 236, 150))
	
end
	
SWEP.HoldType = "pistol"
SWEP.ViewModel			= "models/weapons/c_357.mdl"
SWEP.WorldModel			= "models/weapons/w_357.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound			= Sound( "Weapon_AR2.Single" )
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.020
SWEP.Primary.Delay			= 0.400
SWEP.Primary.Damage         = 0

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	return true
end  

function SWEP:Think()	

end

function SWEP:Reload()
	
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:PrimaryAttack()
    self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self.Weapon:EmitSound( self.Primary.Sound, 100, math.random(110,130) )
	self.Weapon:ShootBullets( self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone )
end

function SWEP:SecondaryAttack()

end

function SWEP:ShootBullets( damage, numbullets, aimcone )
	local scale = aimcone
	if self.Owner:KeyDown(IN_FORWARD) or self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_MOVELEFT) or self.Owner:KeyDown(IN_MOVERIGHT) then
		scale = aimcone * 1.5
	elseif self.Owner:KeyDown(IN_DUCK) or self.Owner:KeyDown(IN_WALK) then
		scale = math.Clamp( aimcone / 2, 0, 10 )
	end
	
	local bullet = {}
	bullet.Num 		= numbullets
	bullet.Src 		= self.Owner:GetShootPos()			
	bullet.Dir 		= self.Owner:GetAimVector()			
	bullet.Spread 	= Vector( scale, scale, 0 )		
	bullet.Tracer	= 1	
	bullet.Force	= 100							
	bullet.Damage	= -1
	bullet.AmmoType = "Pistol"
	bullet.TracerName 	= "beam_tracer"
	bullet.Callback = function ( attacker, tr, dmginfo )
        dmginfo:SetDamage(0)
		if CLIENT then return end
		if tr.Entity:IsPlayer() then
			local vel = self.Owner:GetAimVector() * 1000
			vel.z = 300
			tr.Entity:SetVelocity( vel )
		end
	end
	
	self.Owner:FireBullets( bullet )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end
