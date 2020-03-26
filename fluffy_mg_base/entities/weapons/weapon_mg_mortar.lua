SWEP.Base = "weapon_mg_base"

-- Use an RPG model for the weapon
-- Look it's good enough okay
SWEP.PrintName = 'Mortar'
SWEP.ViewModel = 'models/weapons/c_rpg.mdl'
SWEP.WorldModel = 'models/weapons/w_rocket_launcher.mdl'
SWEP.HoldType = 'rpg'
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
    local ang = self.Owner:EyeAngles()
    local src = self.Owner:GetShootPos() + (self.Owner:GetAimVector()* 8)
    
    -- Play animation & effects
    self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    self.Weapon:EmitSound('Weapon_RPG.Single')
    
    -- FIRE THE ROCKET!
    self:CreateRocket(src, self.Owner:GetAimVector()*1000)
    --timer.Simple(0.3, function() self.Weapon:SendWeaponAnim(ACT_VM_DRAW) end)
end

-- Helper function to create a rocket entity
function SWEP:CreateRocket(pos, velocity)
    local grenade = ents.Create('mg_mortar_rocket')
    if not IsValid(grenade) then return end
    
    grenade.Weapon = self.Weapon
    grenade.Player = self.Owner
    grenade:SetPos(pos)
    grenade:Spawn()
    grenade:SetAngles(self.Owner:EyeAngles())
    
    local phys = grenade:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetVelocity(velocity)
    end
    
    return grenade
end