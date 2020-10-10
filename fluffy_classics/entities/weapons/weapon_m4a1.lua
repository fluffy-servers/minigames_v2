SWEP.Base = "weapon_cs_base"
SWEP.PrintName = "M4A1"

if CLIENT then
	SWEP.Slot = 2
	SWEP.SlotPos = 0

	SWEP.IconLetter = "N"
	SWEP.IconFont = "CSTypeDeath"
    killicon.AddFont("weapon_m4a1", "CSTypeDeath", "N", Color(255, 80, 0, 255))
end

SWEP.Primary.Damage = 33
SWEP.Primary.Delay = 0.09
SWEP.Primary.Recoil = 0.37762
SWEP.Primary.Cone = 0.0006
SWEP.Primary.NumShots = 1
SWEP.Primary.Sound = "Weapon_M4A1.Single"

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 150
SWEP.Primary.Ammo = "AR2"
SWEP.Primary.Automatic = false

SWEP.HoldType = "ar2"
SWEP.ViewModel = "models/weapons/cstrike/c_rif_m4a1.mdl"
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"