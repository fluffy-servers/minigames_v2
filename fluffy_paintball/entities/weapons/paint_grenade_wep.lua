AddCSLuaFile()

SWEP.PrintName = 'Paint Bomb'
SWEP.ViewModel = 'models/weapons/c_grenade.mdl'
SWEP.WorldModel = 'models/weapons/w_grenade.mdl'
SWEP.UseHands = true

SWEP.Slot = 5

function SWEP:Initialize()
    self:SetHoldType('grenade')
end

function SWEP:PrimaryAttack()
    self:Throw(2000)
    self.Weapon:EmitSound('WeaponFrag.Throw')
    self:SetNextPrimaryFire(CurTime() + 1)
    self:SetNextSecondaryFire(CurTime() + 1)
end

function SWEP:SecondaryAttack()
    self:Throw(750)
    self.Weapon:EmitSound('WeaponFrag.Roll')
    self:SetNextPrimaryFire(CurTime() + 1)
    self:SetNextSecondaryFire(CurTime() + 1)
end

function SWEP:Throw(strength)
    if CLIENT then return end
    
    local ang = self.Owner:EyeAngles()
    local src = self.Owner:GetShootPos() - Vector(0, 0, 24) + (self.Owner:GetAimVector() + Vector(0, 0, 0.2)) * 8
    
    self.Weapon:SendWeaponAnim(ACT_VM_THROW)
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    self:CreateGrenade(src, self.Owner:GetAimVector()*strength)
    timer.Simple(0.3, function() self.Weapon:SendWeaponAnim(ACT_VM_DRAW) end)
end

function SWEP:CreateGrenade(pos, velocity)
    local grenade = ents.Create('paint_grenade')
    if not IsValid(grenade) then return end
    
    grenade.Weapon = self.Weapon
    grenade.Player = self.Owner
    grenade:SetPos(pos)
    grenade:SetGravity(0.4)
    grenade:Spawn()
    
    local phys = grenade:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetVelocity(velocity)
    end
    
    return grenade
end