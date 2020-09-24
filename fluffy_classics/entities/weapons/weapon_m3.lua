SWEP.Base = "weapon_cs_base"
SWEP.PrintName = "M3"

if CLIENT then
	SWEP.Slot = 2
	SWEP.SlotPos = 0

	SWEP.IconLetter = "k"
	SWEP.IconFont = "CSTypeDeath"
    killicon.AddFont("weapon_m3", "CSTypeDeath", "k", Color(255, 80, 0, 255))
end

SWEP.Primary.Damage = 26
SWEP.Primary.Delay = 0.88
SWEP.Primary.Recoil = 0.41447
SWEP.Primary.Cone = 0.04
SWEP.Primary.NumShots = 9
SWEP.Primary.Sound = "Weapon_M3.Single"

SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 40
SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.Automatic = false

SWEP.HoldType = "shotgun"
SWEP.ViewModel = "models/weapons/cstrike/c_shot_m3super90.mdl"
SWEP.WorldModel = "models/weapons/w_shot_m3super90.mdl"