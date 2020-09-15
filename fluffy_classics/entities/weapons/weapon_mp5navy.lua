SWEP.Base = 'weapon_cs_base'
SWEP.PrintName = "MP5"

if CLIENT then
	SWEP.Slot = 2
	SWEP.SlotPos = 0
    
	SWEP.IconLetter = 'x'
	SWEP.IconFont = 'CSTypeDeath'
    killicon.AddFont("weapon_mp5navy", "CSTypeDeath", "x", Color(255, 80, 0, 255))
end

SWEP.Primary.Damage = 26
SWEP.Primary.Delay = 0.08
SWEP.Primary.Recoil = 0.39144
SWEP.Primary.Cone = 0.0006
SWEP.Primary.NumShots = 1
SWEP.Primary.Sound = "Weapon_MP5Navy.Single"

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 150
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.Automatic = true

SWEP.HoldType = 'smg'
SWEP.ViewModel = "models/weapons/cstrike/c_smg_mp5.mdl"
SWEP.WorldModel = "models/weapons/w_smg_mp5.mdl"