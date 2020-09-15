SWEP.Base = 'weapon_css_pistol-base'
SWEP.PrintName = "Desert Eagle.50 AE"
SWEP.Spawnable = true
SWEP.Category = "CSS Weapons"

SWEP.Slot = 2
SWEP.Slotpos = 0

SWEP.Primary.Damage = 45
SWEP.Primary.Delay = 0.2
SWEP.Primary.Recoil = 1
SWEP.Primary.Cone = 0.07
SWEP.Primary.NumShots = 1

SWEP.Primary.Sound = "weapons/deagle/deagle-1.wav"

SWEP.Primary.ClipSize = 7
SWEP.Primary.DefaultClip = 7
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Automatic = false

SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"

SWEP.HoldType = 'pistol'
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.ViewModelFov = 62
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"

function SWEP:Initialize() 
	self:SetWeaponHoldType(self.HoldType)
end