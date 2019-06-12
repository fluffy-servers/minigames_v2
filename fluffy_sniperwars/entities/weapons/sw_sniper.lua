AddCSLuaFile()

if CLIENT then
    killicon.AddFont('sw_sniper', 'CSKillIcons', 'r', Color(255, 80, 0, 255))
    
    SWEP.IconFont = "CSSelectIcons"
    SWEP.IconLetter = "r"
    surface.CreateFont("CSSelectIcons", {font="csd", size=ScreenScale(60)})
    
    function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		draw.SimpleText( self.IconLetter, self.IconFont, x + wide/2, y + tall/2.5, Color( 15, 20, 200, 255 ), TEXT_ALIGN_CENTER )
	end
end

-- Model information
SWEP.PrintName = 'Sniper Rifle [New]'
SWEP.ViewModel = "models/weapons/cstrike/c_snip_awp.mdl"
SWEP.ViewModelFOV = 75
SWEP.ViewModelFlip = false
SWEP.HoldType = "ar2"
SWEP.WorldModel = "models/weapons/w_snip_awp.mdl"
SWEP.UseHands = true
SWEP.Slot = 0
SWEP.DrawCrosshair = false

-- Primary information
SWEP.Primary.Sound = Sound("npc/sniper/echo1.wav")
SWEP.Primary.Recoil = 3.5
SWEP.Primary.Damage = 100
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.00025
SWEP.Primary.Delay = 1.5

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

-- Set the correct hold type
function SWEP:Initialize()
    self:SetWeaponHoldType(self.HoldType)
end

-- Play the deploy animation
function SWEP:Deploy()
    self:SendWeaponAnim(ACT_VM_DRAW)
    self:ZoomOut()
end

function SWEP:Think()

end

-- Handle reload code
function SWEP:Reload()
    if self:Clip1() == self.Primary.ClipSize then return end
    
    -- Zoom out if applicable
    self:ZoomOut()
    
	self.Weapon:DefaultReload(ACT_VM_RELOAD)
end

function SWEP:CanSecondaryAttack()
    return true
end

-- Automatically reload if out of ammo
function SWEP:CanPrimaryAttack()
    if self.Weapon:Clip1() <= 0 then
        self:SetNextPrimaryFire(CurTime() + 0.5)
        self:Reload()
        self:ZoomOut()
        
        return false
    end
    
    return true
end

-- Logic for firing on left click
function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:EmitSound(self.Primary.Sound, 100, math.random(95, 105))
    self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone, 1, 'line_tracer')
    self:TakePrimaryAmmo(1)
    
    if SERVER then
        local strength1 = math.Rand(-0.15, -0.05) * self.Primary.Recoil
        local strength2 = math.Rand(-0.15, 0.15) * self.Primary.Recoil
        self.Owner:ViewPunch(Angle(strength1, strength2, 0))
    end
end

-- Useful function for shooting bullets
function SWEP:ShootBullets(damage, number, aimcone, numtracer, tracername)
    -- Spread penalty for moving
    if self.Owner:KeyDown(IN_FORWARD) or self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_MOVELEFT) or self.Owner:KeyDown(IN_MOVERIGHT) then
        aimcone = aimcone * 2.5
    end
    
    -- Accuracy increase for crouching or walking
    if self.Owner:KeyDown(IN_DUCK) or self.Owner:KeyDown(IN_WALK) then
        aimcone = math.Clamp(aimcone/2.5, 0, 10)
    end
    
    -- Create the bullet table
    local bullet = {}
    bullet.Num = numbullets
    bullet.Src = self.Owner:GetShootPos()
    bullet.Dir = self.Owner:GetAimVector()
    bullet.Spread = Vector(scale, scale, 0)
    bullet.Force = math.Round(damage * 2)
    bullet.Damage = math.Round(damage)
    bullet.AmmoType = 'Pistol'
    bullet.Tracer = 1
    bullet.TracerName = 'line_tracer'
    
    self.Owner:FireBullets(bullet)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self.Owner:MuzzleFlash()
    self.Owner:SetAnimation(PLAYER_ATTACK1)
end

-- Handle scope in logic on right click
function SWEP:SecondaryAttack()
    if not self:CanSecondaryAttack() then return end
    self:SetNextSecondaryFire(CurTime() + 0.35)
    self:EmitSound(self.Secondary.Sound)
    
    if CLIENT then return end
    self:SetZoomMode(self:GetZoomMode() + 1)
end

-- Update the zoom mode
-- This adjusts the FOV and performs the animation
function SWEP:SetZoomMode(num)
    if num > #self.ZoomModes then
        num = 1
        --self:SetNWBool('ReverseAnim', true)
        --self:SetViewModelPosition(self.ScopePos, self.ScopeAng, 0.3)
        --self.Owner:DrawViewModel(true)
    end
    
    -- Update the zoom
    self:SetNWInt('Mode', num)
    self.Owner:SetFOV(self.ZoomModes[num], self.ZoomSpeeds[num])
    self.Owner:DrawViewModel(num == 1)
end

-- Get the current zoom mode
function SWEP:GetZoomMode()
    return self:GetNWInt('Mode', 1)
end

-- Useful function to return to zoom level 1 when needed
function SWEP:ZoomOut()
    if self.Weapon:GetZoomMode() != 1 and SERVER then
        self:SetZoomMode(1)
        self.Owner:DrawViewModel(true)
    end
end

-- Adjust the mouse sensitivity based on zoom level
function SWEP:AdjustMouseSensitivity()
    local num = self:GetNWInt('Mode', 1)
    local scale = self.ZoomModes[num] / 80
    return scale
end

-- Draw the scope if applicable
function SWEP:DrawHUD()
    local vm = self.Owner:GetViewModel()
    local mode = self:GetNWInt('Mode', 1)
    
    if mode != 1 then
        -- Handle scope-related drawing
        local w = ScrW()
        local h = ScrH()
        local wr = (h/3) * 4
        local wr_half = (wr/2)
        local w_half = (w/2)
        
        -- Draw the scope circle
        surface.SetTexture(surface.GetTextureID('gmod/scope'))
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawTexturedRect(w_half - wr_half, 0, wr, h)
        
        -- Draw the black outside of the scope
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(0, 0, w_half - wr_half + 4, h)
        surface.DrawRect(w_half + wr_half - 4, 0, w - (w_half + wr_half) + 8, h)
        
        -- Draw the crosshair
        -- No longer the stupid one from before I'm sorry
        surface.DrawLine(0, h/2, w, h/2)
        surface.DrawLine(w/2, 0, w/2, h)
        
        -- Draw the ammo & health on top of the darkness
        -- This will probably not be great for performance but hey
        GAMEMODE:DrawAmmo()
        GAMEMODE:DrawHealth()
    end
end