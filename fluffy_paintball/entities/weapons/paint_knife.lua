if CLIENT then
	-- Define the name and slot clientside
	SWEP.PrintName = "Paintbrush"
	SWEP.Slot = 0
	SWEP.SlotPos = 0
	SWEP.IconLetter = "f"
    killicon.AddFont("paint_knife", "CSKillIcons", "j", Color( 255, 80, 0, 255 ))
    
    SWEP.PaintSplat = Material('decals/decal_paintsplatterpink001')
end

-- Primary fire damage and aim settings
SWEP.Primary.Damage = 100
SWEP.Primary.Delay = 0.75
SWEP.Primary.Recoil = 0
SWEP.Primary.Cone = 0

-- Primary ammo settings
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = true

-- We don't have anything that uses secondary ammo so there's nothing here for it

-- Set the model for the gun
-- Using hands is preferred
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.ViewModelFOV = 62
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"

function SWEP:Initialize()
    self:SetWeaponHoldType("knife")
end

function SWEP:Holster()
    self.Owner:SetRunSpeed(300)
    self.Owner:SetWalkSpeed(200)
    self.Owner:SetJumpPower(160)
    return true
end

function SWEP:Deploy()
    if not self.Owner:GetNWBool('IsGhost', false) then return end
    self.Owner:SetRunSpeed(400)
    self.Owner:SetWalkSpeed(300)
    self.Owner:SetJumpPower(200)
end

function SWEP:DrawWorldModel()
    local v = self.Owner:GetNWVector('WeaponColor', Vector(1, 1, 1))
    render.SetColorModulation(v.x, v.y, v.z)
    self:DrawModel()
    render.SetColorModulation(1, 1, 1)
end

function SWEP:PreDrawViewModel(vm, wep)
    local v = self.Owner:GetNWVector('WeaponColor', Vector(1, 1, 1))
    wep:SetColor(Color(v.x*255, v.y*255, v.z*255))
end

function SWEP:PrimaryAttack()
    --models/debug/debugwhite
    --weapons/357/357_fire2.wav
	--self.Weapon:EmitSound('weapons/flaregun/fire.wav', 35, math.random(180, 200))
	--self:ShootBullet(self.Primary.Damage, 1, self.Primary.Cone)
    
    local startpos = self.Owner:GetShootPos()
    local endpos = startpos + self.Owner:GetAimVector()*88
    local tr = util.TraceLine({start=startpos, endpos=endpos, filter=self.Owner, mask=MASK_SHOT_HULL})
    
    if IsValid(tr.Entity) or tr.HitWorld then
        self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
        self:EmitSound('Weapon_Crowbar.Melee_Hit')
        self:ShootBullet(-1, 1, 0)
    else
        self:SendWeaponAnim(ACT_VM_MISSCENTER)
        self:EmitSound('Weapon_Crowbar.Single')
    end
    
    if IsValid(tr.Entity) and SERVER then
        local dmg = DamageInfo()
        dmg:SetDamage(self.Primary.Damage)
        dmg:SetAttacker(self.Owner)
        dmg:SetInflictor(self)
        dmg:SetDamageType(DMG_CLUB)
        tr.Entity:TakeDamageInfo(dmg)
    end
    
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:SecondaryAttack()
	-- Nothing here!
	-- Make sure this is blank to override the default
end

-- Feel free to steal this code for any weapons
function SWEP:ShootBullet(damage, numbullets, aimcone)
	-- Setup the bullet table and fire it
	local scale = aimcone
	local bullet = {}
	bullet.Num 		= numbullets
	bullet.Src 		= self.Owner:GetShootPos()			
	bullet.Dir 		= self.Owner:GetAimVector()			
	bullet.Spread 	= Vector(scale, scale, 0)		
	bullet.Force	= math.Round(damage * 2)							
	bullet.Damage	= math.Round(damage)
	bullet.AmmoType = "Pistol"
    bullet.HullSize = 8
	bullet.Tracer = 0
	self.Owner:FireBullets(bullet)
end

function SWEP:DoImpactEffect(tr, nDamageType)
    if SERVER then return end
	if tr.HitSky then return end
    
    local v = self.Owner:GetNWVector('WeaponColor', Vector(1, 1, 1))
    c = Color(v.x*255, v.y*255, v.z*255)
    
    local s = 0.7 + 0.4*math.random()
    util.DecalEx(self.PaintSplat, tr.HitEntity or game.GetWorld(), tr.HitPos, tr.HitNormal, c, s, s)
    
    return true
end