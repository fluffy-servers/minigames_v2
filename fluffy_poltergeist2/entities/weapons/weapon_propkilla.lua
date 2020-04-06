SWEP.Base = 'weapon_mg_base'

if CLIENT then
    SWEP.PrintName = "Prop Shooter"
    SWEP.IconLetter = '-'
    SWEP.IconFont = 'HL2MPTypeDeath'
    killicon.AddFont("weapon_barrel_killa", "HL2MPTypeDeath", "-", Color(255, 80, 0, 255))
end

SWEP.HoldType = "ar2"
SWEP.ViewModel = "models/weapons/c_irifle.mdl"
SWEP.WorldModel = "models/weapons/w_irifle.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("weapons/ar1/ar1_dist1.wav")
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.005
SWEP.Primary.Delay = 0.3

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = 'none'

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = 'none'

function SWEP:CanPrimaryAttack()
    return true
end

-- Burst fire?
function SWEP:SecondaryAttack()

end