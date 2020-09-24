SWEP.Base = "weapon_mg_base"

if CLIENT then
    SWEP.Slot = 5
    SWEP.PrintName = "Paintzooka"
    SWEP.IconLetter = "-"
end

SWEP.PrintName = "Paintzooka"
SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"
SWEP.UseHands = true
-- Primary ammo settings
SWEP.Primary.ClipSize = 3
SWEP.Primary.DefaultClip = 3
SWEP.Primary.Ammo = "RPG_Round"
SWEP.Primary.Automatic = false
SWEP.Slot = 5

function SWEP:Initialize()
    self:SetHoldType("rpg")
end

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    self:Launch()
    self:SetNextPrimaryFire(CurTime() + 2)
    self:TakePrimaryAmmo(1)
end

function SWEP:SecondaryAttack()
    -- nothing
end

function SWEP:Launch()
    if CLIENT then return end
    local owner = self:GetOwner()
    local src = owner:GetShootPos() + (owner:GetAimVector() * 8)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    owner:SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("Weapon_RPG.Single")
    self:CreateRocket(src, owner:GetAimVector() * 1000)
end

function SWEP:CreateRocket(pos, velocity)
    local grenade = ents.Create("paint_rocket")
    if not IsValid(grenade) then return end
    grenade.WeaponEnt = self
    grenade.Player = self:GetOwner()
    grenade:SetPos(pos)
    grenade:Spawn()
    grenade:SetAngles(self:GetOwner():EyeAngles())
    local phys = grenade:GetPhysicsObject()

    if IsValid(phys) then
        phys:SetVelocity(velocity)
    end

    return grenade
end