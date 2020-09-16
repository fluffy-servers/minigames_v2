SWEP.Base = 'weapon_cs_base'
SWEP.PrintName = "M249"

if CLIENT then
	SWEP.Slot = 2
	SWEP.SlotPos = 0
    
	SWEP.IconLetter = 'z'
	SWEP.IconFont = 'CSTypeDeath'
    killicon.AddFont("weapon_m249", "CSTypeDeath", "z", Color(255, 80, 0, 255))
end

SWEP.Primary.Damage = 35
SWEP.Primary.Delay = 0.08
SWEP.Primary.Recoil = 0.78288
SWEP.Primary.Cone = 0.002
SWEP.Primary.NumShots = 1
SWEP.Primary.Sound = "Weapon_M249.Single"

SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 500
SWEP.Primary.Ammo = "AR2"
SWEP.Primary.Automatic = true

SWEP.HoldType = 'ar2'
SWEP.ViewModel = "models/weapons/cstrike/c_mach_m249para.mdl"
SWEP.WorldModel = "models/weapons/w_mach_m249para.mdl"