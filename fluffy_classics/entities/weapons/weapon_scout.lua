SWEP.Base = 'weapon_cs_base'
SWEP.PrintName = "SCOUT"

if CLIENT then
	SWEP.Slot = 2
	SWEP.SlotPos = 0
    
	SWEP.IconLetter = 'n'
	SWEP.IconFont = 'CSTypeDeath'
    killicon.AddFont("weapon_scout", "CSTypeDeath", "n", Color(255, 80, 0, 255))
end

SWEP.Primary.Damage = 75
SWEP.Primary.Delay = 1.25
SWEP.Primary.Recoil = 0.24753
SWEP.Primary.Cone = 0.0003
SWEP.Primary.NumShots = 1
SWEP.Primary.Sound = "Weapon_Scout.Single"

SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 50
SWEP.Primary.Ammo = "AR2"
SWEP.Primary.Automatic = false

SWEP.HoldType = 'ar2'
SWEP.ViewModel = "models/weapons/cstrike/c_snip_scout.mdl"
SWEP.WorldModel = "models/weapons/w_snip_scout.mdl"