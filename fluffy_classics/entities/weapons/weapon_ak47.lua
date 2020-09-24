SWEP.Base = "weapon_cs_base"
SWEP.PrintName = "AK47"

if CLIENT then
	SWEP.Slot = 2
	SWEP.SlotPos = 0

	SWEP.IconLetter = "b"
	SWEP.IconFont = "CSTypeDeath"
    killicon.AddFont("weapon_ak47", "CSTypeDeath", "b", Color(255, 80, 0, 255))
end

SWEP.Primary.Damage = 36
SWEP.Primary.Delay = 0.1
SWEP.Primary.Recoil = 0.48815
SWEP.Primary.Cone = 0.0006
SWEP.Primary.NumShots = 1
SWEP.Primary.Sound = "Weapon_AK47.Single"

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 150
SWEP.Primary.Ammo = "AR2"
SWEP.Primary.Automatic = true

SWEP.HoldType = "ar2"
SWEP.ViewModel = "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"