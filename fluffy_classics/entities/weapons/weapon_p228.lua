SWEP.Base = 'weapon_cs_base'
SWEP.PrintName = "P228"

if CLIENT then
	SWEP.Slot = 2
	SWEP.SlotPos = 0
    
	SWEP.IconLetter = 'y'
	SWEP.IconFont = 'CSTypeDeath'
    killicon.AddFont("weapon_p228", "CSTypeDeath", "y", Color(255, 80, 0, 255))
end

SWEP.Primary.Damage = 40
SWEP.Primary.Delay = 0.15
SWEP.Primary.Recoil = 0.27631
SWEP.Primary.Cone = 0.004
SWEP.Primary.NumShots = 1
SWEP.Primary.Sound = "Weapon_P228.Single"

SWEP.Primary.ClipSize = 13
SWEP.Primary.DefaultClip = 65
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Automatic = false

SWEP.HoldType = 'pistol'
SWEP.ViewModel = "models/weapons/cstrike/c_pist_p228.mdl"
SWEP.WorldModel = "models/weapons/w_pist_p228.mdl"