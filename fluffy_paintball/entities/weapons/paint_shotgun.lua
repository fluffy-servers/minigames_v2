SWEP.Base = "weapon_mg_shotgun"
SWEP.PrintName = "Paintball Shotgun"

if CLIENT then
    SWEP.IconLetter = "0"
    killicon.AddFont("paint_shotgun", "HL2MPTypeDeath", "0", Color(255, 80, 0, 255))
    SWEP.PaintSplat = Material("decals/decal_paintsplatterpink001")
end

function SWEP:DrawWorldModel()
    local v = self:GetOwner():GetNWVector("WeaponColor", Vector(1, 1, 1))
    render.SetColorModulation(v.x, v.y, v.z)
    self:DrawModel()
    render.SetColorModulation(1, 1, 1)
end

function SWEP:PreDrawViewModel(vm, wep)
    local v = self:GetOwner():GetNWVector("WeaponColor", Vector(1, 1, 1))
    wep:SetColor(Color(v.x * 255, v.y * 255, v.z * 255))
end

-- Primary attack
function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    self:EmitSound("weapons/flaregun/fire.wav", 35, math.random(180, 200))
    self:ShootBulletEx(self.Primary.Damage, 6, self.Primary.Cone, "paintball_tracer")
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:TakePrimaryAmmo(1)
end

-- Fire both shells on secondary attack
function SWEP:SecondaryAttack()
    if self:Clip1() < 2 then return end
    local owner = self:GetOwner()
    self:EmitSound("weapons/flaregun/fire.wav", 35, math.random(180, 200))
    self:ShootBulletEx(self.Primary.Damage, math.floor(self.Primary.NumShots * 1.5), self.Primary.Cone, "paintball_tracer")
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay + 0.25)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay + 0.25)
    self:TakePrimaryAmmo(2)
    owner:ViewPunch(Angle(math.Rand(-0.2, -0.1) * self.Primary.Recoil * 2, math.Rand(-0.1, 0.1) * self.Primary.Recoil * 2, 0))
    
    -- Adds the strong knockback effect
    owner:SetGroundEntity(NULL) -- Stop the user sticking to the ground
    owner:SetLocalVelocity(owner:GetAimVector() * -self.Knockback)
end

function SWEP:DoImpactEffect(tr, nDamageType)
    if SERVER then return end
    if tr.HitSky then return end
    local v = self:GetOwner():GetNWVector("WeaponColor", Vector(1, 1, 1))
    c = Color(v.x * 255, v.y * 255, v.z * 255)
    local s = 0.1 + 0.2 * math.random()
    util.DecalEx(self.PaintSplat, tr.HitEntity or game.GetWorld(), tr.HitPos, tr.HitNormal, c, s, s)

    return true
end