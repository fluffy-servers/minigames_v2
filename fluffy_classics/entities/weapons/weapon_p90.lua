SWEP.Base = "weapon_cs_base"
SWEP.PrintName = "P90"

if CLIENT then
	SWEP.Slot = 2
	SWEP.SlotPos = 0

	SWEP.IconLetter = "m"
	SWEP.IconFont = "CSTypeDeath"
    killicon.AddFont("weapon_p90", "CSTypeDeath", "m", Color(255, 80, 0, 255))
end

SWEP.Primary.Damage = 26
SWEP.Primary.Delay = 0.07
SWEP.Primary.Recoil = 0.32605
SWEP.Primary.Cone = 0.001
SWEP.Primary.NumShots = 1
SWEP.Primary.Sound = "Weapon_P90.Single"

SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = 250
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.Automatic = true

SWEP.HoldType = "smg"
SWEP.ViewModel = "models/weapons/cstrike/c_smg_p90.mdl"
SWEP.WorldModel = "models/weapons/w_smg_p90.mdl"