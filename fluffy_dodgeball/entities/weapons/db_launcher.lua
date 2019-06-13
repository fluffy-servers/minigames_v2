AddCSLuaFile()

SWEP.PrintName = 'Dodgeball Launcher'
SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"
SWEP.UseHands = true

SWEP.ShootSound = Sound("weapons/grenade_launcher1.wav")
SWEP.Primary.Automatic = true

function SWEP:Initialize()
    self:SetWeaponHoldType("rpg")
end

function SWEP:Deploy()
    self:SendWeaponAnim(ACT_VM_DRAW)
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:SetNextSecondaryFire(CurTime() + 0.5)
    self:EmitSound(self.ShootSound, 100, math.random(80, 115))
    
    if SERVER then
        self:FireBall()
    end
end

function SWEP:SecondaryAttack()
    self:SetNextPrimaryFire(CurTime() + 1)
    self:SetNextSecondaryFire(CurTime() + 1)
    self:EmitSound(self.ShootSound, 100, math.random(50, 65))
    
    if SERVER then
        self:FireBall(2000, 4)
    end
end

function SWEP:FireBall(velocity, bounces)
    local ball = ents.Create('db_projectile')
    ball:SetPos(self.Owner:GetShootPos() + self.Owner:GetAimVector()*25)
    ball:SetOwner(self.Owner)
    ball.InitialVelocity = velocity or 1000
    ball.NumBounces = bounces or 3
    ball:Spawn()
end

function SWEP:CustomAmmoDisplay()
    return {Draw = false}
end