SWEP.Base = "weapon_cs_base"
SWEP.PrintName = "XM1014"

if CLIENT then
	SWEP.Slot = 2
	SWEP.SlotPos = 0

	SWEP.IconLetter = "]"
	SWEP.IconFont = "CSTypeDeath"
    killicon.AddFont("weapon_xm1014", "CSTypeDeath", "]", Color(255, 80, 0, 255))
end

SWEP.Primary.Damage = 22
SWEP.Primary.Delay = 0.25
SWEP.Primary.Recoil = 0.41447
SWEP.Primary.Cone = 0.04
SWEP.Primary.NumShots = 9
SWEP.Primary.Sound = "Weapon_XM1014.Single"

SWEP.Primary.ClipSize = 7
SWEP.Primary.DefaultClip = 35
SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.Automatic = true

SWEP.HoldType = "shotgun"
SWEP.ViewModel = "models/weapons/cstrike/c_shot_xm1014.mdl"
SWEP.WorldModel = "models/weapons/w_shot_xm1014.mdl"