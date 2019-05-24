if CLIENT then
    killicon.AddFont('sw_sniper', 'CSKillIcons', 'r', Color(255, 80, 0, 255))
end

-- Model information
SWEP.PrintName = 'Sniper Rifle'
SWEP.ViewModel = "models/weapons/cstrike/c_snip_awp.mdl"
SWEP.ViewModelFOV = 75
SWEP.ViewModelFlip = false
SWEP.HoldType = "ar2"
SWEP.WorldModel = "models/weapons/w_snip_awp.mdl"
SWEP.UseHands = true
SWEP.Slot = 0

-- Primary information
SWEP.Primary.Sound = Sound("npc/sniper/echo1.wav")
SWEP.Primary.Recoil = 3.5
SWEP.Primary.Damage = 100
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.00025
SWEP.Primary.Delay = 1.25

SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 9999
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = 'pistol'

SWEP.Secondary.Sound = Sound("weapons/g3sg1/g3sg1_slide.wav")
SWEP.Secondary.Delay = 0.5
SWEP.Secondary.Ammo = 'none'

-- Zoom and viewmodel related stuff
SWEP.LastRunFrame = 0
SWEP.SprintPos = Vector(0, 0, -2)
SWEP.SprintAng = Vector(0, 0, 0)
SWEP.ScopePos = Vector(5.32, -5.16, 1.65)
SWEP.ScopeAng = Vector(0, -3, 0)
SWEP.ZoomModes = {0, 35, 5}
SWEP.ZoomSpeeds = {0.2, 0.3, 0.3}

function SWEP:Initialize()
    self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Deploy()

    self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
end

function SWEP:Think()

end

function SWEP:Reload()

end

function SWEP:CanSecondaryAttack()

end

function SWEP:CanPrimaryAttack()

end

function SWEP:PrimaryAttack()
    if not self.Weapon:CanPrimaryAttack() then return end
    
    self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self.Weapon:EmitSound(self.Primary.Sound, 100, math.random(95, 105))
    self.Weapon:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone, 1, 'line_tracer')
    self.Weapon:TakePrimaryAmmo(1)
    
    if SERVER then
        local strength1 = math.Rand(-0.15, -0.05) * self.Primary.Recoil
        local strength2 = math.Rand(-0.15, 0.15) * self.Primary.Recoil
        self.Owner:ViewPunch(Angle(strength1, strength2, 0))
    end
end

function SWEP:ShootBullets(damage, number, aimcone, numtracer, tracername)
    -- Spread penalty for moving
    if self.Owner:KeyDown(IN_FORWARD) or self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_MOVELEFT) or self.Owner:KeyDown(IN_MOVERIGHT) then
        aimcone = aimcone * 2.5
    end
    
    -- Accuracy increase for crouching or walking
    if self.Owner:KeyDown(IN_DUCK) or self.Owner:KeyDown(IN_WALK) then
        aimcone = math.Clamp(aimcone/2.5, 0, 10)
    end
    
    
    local bullet = {}
    
end

function SWEP:SecondaryAttack()

end

function SWEP:DrawHUD()
    local vm = self.Owner:GetViewModel()
    local mode = self.Weapon:GetNWInt('Mode', 1)
    
    if mode != 1 then
        -- Handle scope-related drawing
        local w = ScrW()
        local h = ScrH()
        local wr = (h/3) * 4
        
        -- Draw the scope circle
        surface.SetTexture(surface.GetTextureID('gmod/scope'))
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawTexturedRect((w/2) - (wr/2), 0, wr, h)
        
        -- Draw the black outside of the scope
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(0, 0, (w/2) - (wr/2), h)
        surface.DrawRect((w/2) + (wr/2), 0, w - ((w/2) + (wr/2)), h)
        
        -- Draw the crosshair
        -- No longer the stupid one from before I'm sorry
        surface.DrawLine(0, h/2, w, h/2)
        surface.DrawLine(w/2, 0, w/2, h)
    end
end