SWEP.Base = "weapon_cs_base"
SWEP.PrintName = "UMP45"

if CLIENT then
	SWEP.Slot = 2
	SWEP.SlotPos = 0

	SWEP.IconLetter = "q"
	SWEP.IconFont = "CSTypeDeath"
    killicon.AddFont("weapon_ump45", "CSTypeDeath", "q", Color(255, 80, 0, 255))
end

SWEP.Primary.Damage = 30
SWEP.Primary.Delay = 0.105
SWEP.Primary.Recoil = 0.30394
SWEP.Primary.Cone = 0.001
SWEP.Primary.NumShots = 1
SWEP.Primary.Sound = "Weapon_UMP45.Single"

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 150
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.Automatic = true

SWEP.HoldType = "smg"
SWEP.ViewModel = "models/weapons/cstrike/c_smg_ump45.mdl"
SWEP.WorldModel = "models/weapons/w_smg_ump45.mdl"