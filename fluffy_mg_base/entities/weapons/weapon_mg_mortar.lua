SWEP.Base = "weapon_mg_base"
-- Use an RPG model for the weapon
SWEP.PrintName = "Mortar"
SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"
SWEP.HoldType = "rpg"
SWEP.UseHands = true

-- Primary ammo settings
SWEP.Primary.ClipSize = 3
SWEP.Primary.DefaultClip = 3
SWEP.Primary.Ammo = "RPG_Round"
SWEP.Primary.Automatic = false
SWEP.Slot = 5

-- Fire a rocket on primary attack
function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    self:Launch()
    self:SetNextPrimaryFire(CurTime() + 2)
    self:TakePrimaryAmmo(1)
end

function SWEP:SecondaryAttack()
    -- nothing
end

-- Actually launch the rocket entity
function SWEP:Launch()
    if CLIENT then return end

    -- Find starting position & angles for the rocket
    local owner = self:GetOwner()
    -- local ang = owner:EyeAngles()
    local src = owner:GetShootPos() + (owner:GetAimVector() * 8)

    -- Play animation & effects
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    owner:SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("Weapon_RPG.Single")

    -- FIRE THE ROCKET!
    self:CreateRocket(src, owner:GetAimVector() * 1000)
end

-- Helper function to create a rocket entity
function SWEP:CreateRocket(pos, velocity)
    local grenade = ents.Create("mg_mortar_rocket")
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