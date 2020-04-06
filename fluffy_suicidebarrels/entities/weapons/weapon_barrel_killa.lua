SWEP.Base = 'weapon_mg_base'

if CLIENT then
	SWEP.PrintName = "Barrel Shooter"
	SWEP.IconLetter = '-'
	SWEP.IconFont = 'HL2MPTypeDeath'
    killicon.AddFont("weapon_barrel_killa", "HL2MPTypeDeath", "-", Color(255, 80, 0, 255))
end

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.HoldType = "pistol"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_Pistol.Single")
SWEP.Primary.Recoil = 0
SWEP.Primary.Damage = 1000
SWEP.Primary.Cone = 0
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = 1
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.Tracer = "mg_tracer"

SWEP.Secondary.ClipSize	= -1 
SWEP.Secondary.DefaultClip = -1 
SWEP.Secondary.Automatic = false 
SWEP.Secondary.Ammo = "none" 