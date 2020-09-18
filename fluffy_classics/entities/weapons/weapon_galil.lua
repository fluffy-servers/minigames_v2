SWEP.Base = 'weapon_cs_base'
SWEP.PrintName = "GALIL"

if CLIENT then
	SWEP.Slot = 2
	SWEP.SlotPos = 0
    
	SWEP.IconLetter = 'v'
	SWEP.IconFont = 'CSTypeDeath'
    killicon.AddFont("weapon_galil", "CSTypeDeath", "v", Color(255, 80, 0, 255))
end

SWEP.Primary.Damage = 30
SWEP.Primary.Delay = 0.09
SWEP.Primary.Recoil = 0.49275
SWEP.Primary.Cone = 0.0006
SWEP.Primary.NumShots = 1
SWEP.Primary.Sound = "Weapon_Galil.Single"

SWEP.Primary.ClipSize = 35
SWEP.Primary.DefaultClip = 175
SWEP.Primary.Ammo = "AR2"
SWEP.Primary.Automatic = true

SWEP.HoldType = 'ar2'
SWEP.ViewModel = "models/weapons/cstrike/c_rif_galil.mdl"
SWEP.WorldModel = "models/weapons/w_rif_galil.mdl"