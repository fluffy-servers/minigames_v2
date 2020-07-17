SWEP.Base = "weapon_mg_base"

if CLIENT then
	SWEP.Slot = 1
	SWEP.SlotPos = 0
	
	SWEP.IconLetter = '-'
	SWEP.IconFont = 'HL2MPTypeDeath'
    killicon.AddFont("weapon_mg_pistol", "HL2MPTypeDeath", "-", Color(255, 80, 0, 255))
end
SWEP.PrintName = "Pistol"

-- Primary fire damage and aim settings
SWEP.Primary.Damage = 20
SWEP.Primary.Cone = 0.015
SWEP.Primary.Delay = 0.125
SWEP.Primary.NumShots = 1
SWEP.Primary.Sound = Sound("Weapon_Pistol.Single")
SWEP.Primary.Recoil = 1

-- Primary ammo settings
SWEP.Primary.ClipSize = 12
SWEP.Primary.DefaultClip = 12
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Automatic = false
SWEP.Secondary.Automatic = true -- ???

-- Set the model for the gun
-- Using hands is preferred
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.ViewModelFOV = 62
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.HoldType = 'pistol'