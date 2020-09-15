SWEP.Base = 'weapon_cs_base'
SWEP.PrintName = "Desert Eagle"

if CLIENT then
	SWEP.Slot = 2
	SWEP.SlotPos = 0
    
	SWEP.IconLetter = 'U'
	SWEP.IconFont = 'CSTypeDeath'
    killicon.AddFont("weapon_deagle", "CSTypeDeath", "U", Color(255, 80, 0, 255))
end

SWEP.Primary.Damage = 54
SWEP.Primary.Delay = 0.225
SWEP.Primary.Recoil = 0.38683
SWEP.Primary.Cone = 0.004
SWEP.Primary.NumShots = 1
SWEP.Primary.Sound = "Weapon_DEagle.Single"

SWEP.Primary.ClipSize = 7
SWEP.Primary.DefaultClip = 35
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Automatic = false

SWEP.HoldType = 'pistol'
SWEP.ViewModel = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"