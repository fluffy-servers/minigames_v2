SWEP.Base = "weapon_cs_base"
SWEP.PrintName = "TMP"

if CLIENT then
	SWEP.Slot = 2
	SWEP.SlotPos = 0

	SWEP.IconLetter = "d"
	SWEP.IconFont = "CSTypeDeath"
    killicon.AddFont("weapon_tmp", "CSTypeDeath", "d", Color(255, 80, 0, 255))
end

SWEP.Primary.Damage = 26
SWEP.Primary.Delay = 0.07
SWEP.Primary.Recoil = 0.21184
SWEP.Primary.Cone = 0.001
SWEP.Primary.NumShots = 1
SWEP.Primary.Sound = "Weapon_TMP.Single"

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 150
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.Automatic = true

SWEP.HoldType = "smg"
SWEP.ViewModel = "models/weapons/cstrike/c_smg_tmp.mdl"
SWEP.WorldModel = "models/weapons/w_smg_tmp.mdl"