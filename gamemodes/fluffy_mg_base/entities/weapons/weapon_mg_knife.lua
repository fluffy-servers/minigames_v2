SWEP.Base = "weapon_mg_melee"

if SERVER then
    SWEP.Weight = 5
    SWEP.AutoSwitchTo = false
    SWEP.AutoSwitchFrom = false
end

if CLIENT then
    SWEP.ViewModelFOV = 65
    SWEP.ViewModelFlip = false
    SWEP.Slot = 2
    SWEP.SlotPos = 0
    SWEP.IconLetter = "j"
    SWEP.IconFont = "CSSelectIcons"
    killicon.AddFont("weapon_mg_knife", "CSKillIcons", "j", Color(255, 80, 0, 255))
end

SWEP.PrintName              = "Knife"
SWEP.ViewModel 				= "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel 			= "models/weapons/w_knife_t.mdl"
SWEP.UseHands               = true

SWEP.Primary.Automatic			= true
SWEP.Primary.Damage 			= 50
SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Damage			= -1
SWEP.Secondary.Automatic		= true
SWEP.Secondary.Ammo			    = "none"
SWEP.Secondary.Delay 			= 0.75

SWEP.AttackRange = 56

function SWEP:Think()
    if self.Idle and CurTime() >= self.Idle then
        self.Idle = nil
        self:SendWeaponAnim(ACT_VM_IDLE)
    end
end

function SWEP:Initialize()
    self:SetHoldType("knife")
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    self.Idle = CurTime() + owner:GetViewModel():SequenceDuration()
    self:SendWeaponAnim(ACT_VM_DRAW)
    self:SetNextPrimaryFire(CurTime() + owner:GetViewModel():SequenceDuration())
    self:SetNextSecondaryFire(CurTime() + owner:GetViewModel():SequenceDuration())
    self:EmitSound("Weapon_Knife.Deploy")

    return true
end

function SWEP:AttackHit(ent, tr)
    self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)

    local attacker = self:GetOwner()
    local range = self.AttackRange
    local forward = attacker:GetAimVector()
    local src = attacker:GetShootPos()
    local trace_end = src + forward * range

    if IsValid(ent) then
        -- Apply damage
        local dmg = DamageInfo()
        dmg:SetDamage(self.Primary.Damage)
        dmg:SetAttacker(attacker)
        dmg:SetInflictor(self)
        dmg:SetDamageForce(attacker:GetAimVector() * 1500)
        dmg:SetDamagePosition(tr.HitPos)
        dmg:SetDamageType(DMG_SLASH)
        ent:DispatchTraceAttack(dmg, tr)

        -- Blood effects for humans
        if ent:IsPlayer() then
            local edata = EffectData()
            edata:SetStart(attacker:GetShootPos())
            edata:SetOrigin(tr.HitPos)
            edata:SetNormal(tr.Normal)
            edata:SetEntity(ent)
            util.Effect("BloodImpact", edata)
            self:EmitSound("Weapon_Knife.Hit")
        end
    else
        -- Attack hit world
        self:EmitSound("Weapon_Crowbar.Melee_Hit")
        util.Decal("ManhackCut", src - forward, trace_end + forward, true)
    end
end

function SWEP:AttackMissed()
    self:EmitSound("Weapon_Knife.Slash")
    self:SendWeaponAnim(ACT_VM_MISSCENTER)
end

function SWEP:PrimaryAttack()
    self:SecondaryAttack()
end

function SWEP:SecondaryAttack()
    self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:DoAttack()
end

function SWEP:DoImpactEffect(tr, nDamageType)
    util.Decal("ManhackCut", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
    return true
end

function SWEP:CustomAmmoDisplay()
    self.AmmoDisplay = self.AmmoDisplay or {}
    self.AmmoDisplay.PrimaryClip = -1

    return self.AmmoDisplay
end