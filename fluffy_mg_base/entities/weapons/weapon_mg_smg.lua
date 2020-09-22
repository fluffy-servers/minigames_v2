SWEP.Base = "weapon_mg_base"

if CLIENT then
    SWEP.Slot = 1
    SWEP.SlotPos = 1
    SWEP.IconLetter = '/'
    SWEP.IconFont = 'HL2MPTypeDeath'
    killicon.AddFont("weapon_mg_smg", "HL2MPTypeDeath", "/", Color(255, 80, 0, 255))
end

SWEP.PrintName = "SMG"
-- Primary fire damage and aim settings
SWEP.Primary.Damage = 8
SWEP.Primary.Cone = 0.045
SWEP.Primary.Delay = 0.075
SWEP.Primary.NumShots = 1
SWEP.Primary.Sound = Sound("Weapon_SMG1.Single")
SWEP.Primary.Recoil = 1
-- Primary ammo settings
SWEP.Primary.ClipSize = 60
SWEP.Primary.DefaultClip = 60
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.Automatic = true
SWEP.Secondary.Automatic = true
-- Set the model for the gun
-- Using hands is preferred
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_smg1.mdl"
SWEP.ViewModelFOV = 62
SWEP.WorldModel = "models/weapons/w_smg1.mdl"
SWEP.HoldType = 'smg'