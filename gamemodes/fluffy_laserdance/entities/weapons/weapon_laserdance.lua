SWEP.Base = "weapon_mg_base"

if CLIENT then
    SWEP.IconLetter = "."
    SWEP.IconFont = "HL2MPTypeDeath"
    killicon.AddFont("weapon_laserdance", "HL2MPTypeDeath", ".", Color(255, 80, 0, 255))
end

SWEP.PrintName = "Laser Cannon"
-- Primary fire damage and aim settings
SWEP.Primary.Damage = 1000
SWEP.Primary.Delay = 0.5
SWEP.Primary.Recoil = 0
SWEP.Primary.Cone = 0
-- Primary ammo settings
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = false
-- Set the model for the gun
-- Using hands is preferred
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.ViewModelFOV = 62
SWEP.WorldModel = "models/weapons/w_357.mdl"

function SWEP:PrimaryAttack()
    self:EmitSound("weapons/airboat/airboat_gun_energy1.wav", 75, math.random(100, 160))
    self:ShootBulletEx(self.Primary.Damage, 1, self.Primary.Cone, "ld_tracer")
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    -- Send the player flying backwards
    local owner = self:GetOwner()
    owner:ViewPunch(Angle(-10, 0, 0))
    owner:SetGroundEntity(NULL)
    owner:SetLocalVelocity(owner:GetAimVector() * -1000)
end

function SWEP:SecondaryAttack()
    -- Nothing here!
    -- Make sure this is blank to override the default
end

function SWEP:DoImpactEffect(tr, nDamageType)
    if (tr.HitSky) then return end
    local effectdata = EffectData()
    effectdata:SetOrigin(tr.HitPos + tr.HitNormal)
    effectdata:SetNormal(tr.HitNormal)
    util.Effect("AR2Impact", effectdata)

    return true
end