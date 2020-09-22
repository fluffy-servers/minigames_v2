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
    self:SetNextPrimaryFire(CurTime() + 0.75)
    self:SetNextSecondaryFire(CurTime() + 0.75)
    self:EmitSound(self.ShootSound, 50, math.random(80, 115))

    if SERVER then
        self:FireBall()
    end
end

function SWEP:SecondaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.75)
    self:SetNextSecondaryFire(CurTime() + 1.5)
    self:EmitSound(self.ShootSound, 50, math.random(50, 65))

    if SERVER then
        local ball = self:FireBall(3000, 4)
        ball:SetNWInt('Size', 35)
    end
end

function SWEP:FireBall(velocity, bounces)
    local ball = ents.Create('db_projectile')
    ball:SetPos(self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 25)
    ball:SetOwner(self:GetOwner())
    ball.InitialVelocity = velocity or 2000
    ball.NumBounces = bounces or 3
    ball:Spawn()

    return ball
end

function SWEP:CustomAmmoDisplay()
    return {
        Draw = false
    }
end