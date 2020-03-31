SWEP.Base = "weapon_mg_base"

if CLIENT then
	-- Define the name and slot clientside
	SWEP.PrintName = "Revolver"
	SWEP.Slot = 0
	SWEP.SlotPos = 0

	SWEP.IconLetter = '.'
	SWEP.IconFont = 'HL2MPTypeDeath'
	
    killicon.AddFont("oitc_gun", "HL2MPTypeDeath", ".", Color(255, 80, 0, 255))
end

-- Primary fire damage and aim settings
SWEP.Primary.Damage = 1000
SWEP.Primary.Delay = 0.32
SWEP.Primary.Recoil = 0
SWEP.Primary.Cone = 0.0

-- Primary ammo settings
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Automatic = false

-- Set the model for the gun
-- Using hands is preferred
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.Primary.Sound = Sound("Weapon_357.Single")