if SERVER then

	AddCSLuaFile("shared.lua")
	
end

if CLIENT then

	SWEP.ViewModelFOV		= 75
	SWEP.ViewModelFlip		= false
	
	SWEP.PrintName = "P228 Compact"
	SWEP.IconLetter = "y"
	SWEP.Slot = 1
	SWEP.Slotpos = 1
	
	killicon.AddFont( "firearm_p228", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) );
	
end

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {}

	self.AmmoDisplay.Draw = true //draw the display?
	self.AmmoDisplay.PrimaryClip = self:Clip1()

	return self.AmmoDisplay //return the table
end

SWEP.Base = "firearm_base"

SWEP.HoldType = "pistol"

SWEP.ViewModel	= "models/weapons/cstrike/c_pist_p228.mdl"
SWEP.WorldModel = "models/weapons/w_pist_p228.mdl"
SWEP.UseHands = true

SWEP.SprintPos = Vector(0, 0, -2)
SWEP.SprintAng = Vector(-16.9413, -5.786, 4.0159)

SWEP.Primary.Sound			= Sound("weapons/p228/p228-1.wav")
SWEP.Primary.Recoil			= 3.5
SWEP.Primary.Damage			= 35
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.030
SWEP.Primary.Delay			= 0.180

SWEP.Primary.ClipSize		= 12
SWEP.Primary.Automatic		= false

