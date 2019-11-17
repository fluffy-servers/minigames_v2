if SERVER then
	AddCSLuaFile()
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if CLIENT then
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true
	SWEP.CSMuzzleFlashes	= true

	SWEP.ViewModelFOV		= 60
	SWEP.ViewModelFlip		= false
	
	SWEP.PrintName = "Laser"
	SWEP.IconLetter = "t"
	SWEP.Slot = 0
	SWEP.Slotpos = 0
	
	--SWEP.IconFont = "CSSelectIcons"
	
	function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
		draw.SimpleText(self.IconLetter, self.IconFont, x + wide/2, y + tall/2.5, Color(50, 200, 50, 255), TEXT_ALIGN_CENTER)
	end
	killicon.AddFont("weapon_propkilla", "HL2MPTypeDeath", "2", Color(255, 80, 0, 255))
end

SWEP.HoldType = "ar2"
SWEP.ViewModel		= "models/weapons/c_irifle.mdl"
SWEP.WorldModel		= "models/weapons/w_irifle.mdl"
SWEP.UseHands			= true

SWEP.Primary.Sound			= Sound("weapons/ar1/ar1_dist1.wav")
SWEP.Primary.Burst          = Sound("Weapon_AR2.Single")
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.020
SWEP.Primary.Delay			= 0.450

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= 'none'

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo = 'none'

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self.Weapon:SetVar("FireTime", -1)
	
	return true
end  

function SWEP:Reload()
	
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Weapon:EmitSound(self.Primary.Sound, 100, math.random(90,110))
	self.Weapon:ShootBullets(40, self.Primary.NumShots, self.Primary.Cone, "mg_tracer")	
end

function SWEP:SecondaryAttack()
	self.Weapon:SetVar("FireTime", CurTime() + 2.0)
	self.Weapon:SetNextSecondaryFire(CurTime() + 2.0)
	self.Weapon:SetNextPrimaryFire(CurTime() + 5.0)
end

function SWEP:Think()	
	if self.Weapon:GetVar("FireTime", 0) > CurTime() then
		if self.Weapon:GetVar("BurstTime", 0) < CurTime() then
			self.Weapon:ShootBullets(40, self.Primary.NumShots, self.Primary.Cone, "blast_tracer")
			self.Weapon:EmitSound(self.Primary.Burst, 100, math.random(120,140))
			self.Weapon:SetVar("BurstTime", CurTime() + 0.08)
		end
	elseif self.Weapon:GetVar("FireTime", 0) != -1 then
		self.Weapon:SetVar("FireTime", -1)
		self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
		self.Weapon:SetNextSecondaryFire(CurTime() + 3)
	end
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

function SWEP:DoImpactEffect(tr, nDamageType)
	if tr.HitSky then return end

	local effectdata = EffectData()
	effectdata:SetOrigin(tr.HitPos + tr.HitNormal)
	effectdata:SetNormal(tr.HitNormal)
	util.Effect("AR2Impact", effectdata)
    return true
end
