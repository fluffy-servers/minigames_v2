SWEP.Base = "weapon_mg_knife"
SWEP.PrintName = "Paintbrush"

if CLIENT then
    SWEP.Slot = 0
    SWEP.IconLetter = "j"
    killicon.AddFont("paint_knife", "CSKillIcons", "j", Color(255, 80, 0, 255))
    SWEP.PaintSplat = Material('decals/decal_paintsplatterpink001')
end

-- Primary fire damage and aim settings
SWEP.Primary.Damage = 100
SWEP.Primary.Delay = 0.75
SWEP.Primary.Recoil = 0
SWEP.Primary.Cone = 0

function SWEP:Holster()
    local owner = self:GetOwner()
    owner:SetRunSpeed(300)
    owner:SetWalkSpeed(200)
    owner:SetJumpPower(160)

    return true
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    owner:SetRunSpeed(400)
    owner:SetWalkSpeed(300)
    owner:SetJumpPower(200)
end

function SWEP:DrawWorldModel()
    local v = self:GetOwner():GetNWVector('WeaponColor', Vector(1, 1, 1))
    render.SetColorModulation(v.x, v.y, v.z)
    self:DrawModel()
    render.SetColorModulation(1, 1, 1)
end

function SWEP:PreDrawViewModel(vm, wep)
    local v = self:GetOwner():GetNWVector('WeaponColor', Vector(1, 1, 1))
    wep:SetColor(Color(v.x * 255, v.y * 255, v.z * 255))
end

function SWEP:DoImpactEffect(tr, nDamageType)
    if SERVER then return end
    if tr.HitSky then return end
    local v = self:GetOwner():GetNWVector('WeaponColor', Vector(1, 1, 1))
    c = Color(v.x * 255, v.y * 255, v.z * 255)
    local s = 0.7 + 0.4 * math.random()
    util.DecalEx(self.PaintSplat, tr.HitEntity or game.GetWorld(), tr.HitPos, tr.HitNormal, c, s, s)

    return true
end