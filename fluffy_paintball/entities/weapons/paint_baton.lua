SWEP.Base = "weapon_mg_base"

if CLIENT then
    SWEP.Slot = 0
    SWEP.SlotPos = 0
    SWEP.IconLetter = "!"
    killicon.AddFont("paint_baton", "HL2MPTypeDeath", "!", Color(255, 80, 0, 255))
    SWEP.PaintSplat = Material('decals/decal_paintsplatterpink001')
end

SWEP.PrintName = "Paint Roller"
-- Primary fire damage and aim settings
SWEP.Primary.Damage = 40
SWEP.Primary.Delay = 0.4
SWEP.Primary.Recoil = 0
SWEP.Primary.Cone = 0
-- Primary ammo settings
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = true
-- Set the model for the gun
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
SWEP.ViewModelFOV = 62
SWEP.WorldModel = "models/weapons/w_stunbaton.mdl"

function SWEP:Initialize()
    self:SetWeaponHoldType("knife")
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

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    local startpos = owner:GetShootPos()
    local endpos = startpos + owner:GetAimVector() * 88

    local tr = util.TraceLine({
        start = startpos,
        endpos = endpos,
        filter = owner,
        mask = MASK_SHOT_HULL
    })

    if IsValid(tr.Entity) or tr.HitWorld then
        self:SendWeaponAnim(ACT_VM_HITCENTER)
        self:EmitSound('Weapon_Crowbar.Melee_Hit')
        self:ShootBullet(-1, 1, 0)
    else
        self:SendWeaponAnim(ACT_VM_MISSCENTER)
        self:EmitSound('Weapon_Crowbar.Single')
    end

    if IsValid(tr.Entity) and SERVER then
        local dmg = DamageInfo()
        dmg:SetDamage(self.Primary.Damage)
        dmg:SetAttacker(owner)
        dmg:SetInflictor(self)
        dmg:SetDamageType(DMG_CLUB)
        tr.Entity:TakeDamageInfo(dmg)
    end

    owner:SetAnimation(PLAYER_ATTACK1)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:SecondaryAttack()
    -- Nothing here!
    -- Make sure this is blank to override the default
end

-- Feel free to steal this code for any weapons
function SWEP:ShootBullet(damage, numbullets, aimcone)
    -- Setup the bullet table and fire it
    local owner = self:GetOwner()
    local scale = aimcone
    local bullet = {}
    bullet.Num = numbullets
    bullet.Src = owner:GetShootPos()
    bullet.Dir = owner:GetAimVector()
    bullet.Spread = Vector(scale, scale, 0)
    bullet.Force = math.Round(damage * 2)
    bullet.Damage = math.Round(damage)
    bullet.AmmoType = "Pistol"
    bullet.HullSize = 8
    bullet.Tracer = 0
    owner:FireBullets(bullet)
end

function SWEP:DoImpactEffect(tr, nDamageType)
    if SERVER then return end
    if tr.HitSky then return end
    
    local v = self:GetOwner():GetNWVector('WeaponColor', Vector(1, 1, 1))
    c = Color(v.x * 255, v.y * 255, v.z * 255)
    local s = 1 + 0.4 * math.random()
    util.DecalEx(self.PaintSplat, tr.HitEntity or game.GetWorld(), tr.HitPos, tr.HitNormal, c, s, s)
    return true
end