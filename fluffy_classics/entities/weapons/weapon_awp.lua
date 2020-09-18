SWEP.Base = 'weapon_cs_base'
SWEP.PrintName = "AWP"

if CLIENT then
	SWEP.Slot = 2
	SWEP.SlotPos = 0
    
	SWEP.IconLetter = 'r'
	SWEP.IconFont = 'CSTypeDeath'
    killicon.AddFont("weapon_awp", "CSTypeDeath", "r", Color(255, 80, 0, 255))
end

SWEP.Primary.Damage = 115
SWEP.Primary.Delay = 1.455
SWEP.Primary.Recoil = 0.34539
SWEP.Primary.Cone = 0.0002
SWEP.Primary.NumShots = 1
SWEP.Primary.Sound = "Weapon_AWP.Single"

SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 50
SWEP.Primary.Ammo = "AR2"
SWEP.Primary.Automatic = false

SWEP.HoldType = 'ar2'
SWEP.ViewModel = "models/weapons/cstrike/c_snip_awp.mdl"
SWEP.WorldModel = "models/weapons/w_snip_awp.mdl"