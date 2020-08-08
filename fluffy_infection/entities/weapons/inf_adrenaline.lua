SWEP.Base = 'weapon_mg_sck_base'
SWEP.HoldType = 'grenade'

if CLIENT then
    SWEP.IconFont = "CSSelectIcons"
    SWEP.IconLetter = "H"

    SWEP.PrintName = 'Adrenaline'
    SWEP.Slot = 2
    SWEP.SlotPos = 2
end

-- Model data
SWEP.ViewModel = "models/weapons/c_grenade.mdl"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.UseHands = true

SWEP.WorldModel = "models/weapons/w_grenade.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false

SWEP.ViewModelBoneMods = {
    ["ValveBiped.Grenade_body"] = { scale = Vector(0.326, 0.326, 0.326), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}
 
SWEP.VElements = {
    ["dynamite"] = { type = "Model", model = "models/healthvial.mdl", bone = "ValveBiped.Grenade_body", rel = "", pos = Vector(0.657, -0.401, -5.705), angle = Angle(0, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
 
SWEP.WElements = {
    ["dynamite"] = { type = "Model", model = "models/healthvial.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5.164, 1.86, -4.199), angle = Angle(18.398, 10.642, -4.481), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

function SWEP:Initialize()
    return self.BaseClass.Initialize(self)
end

-- Effect data
SWEP.Primary.Sound = Sound("items/medshot4.wav")
SWEP.Primary.Delay = 1.5

SWEP.AdrenalineLength = 8

-- Reset utility on player spawn
-- Players spawn with 50% of the device charged
hook.Add('PlayerSpawn', 'Utility', function(ply)
    ply:SetNWFloat('LastUtility', CurTime() - 10)
    ply:SetNoDraw(false)
end)

-- Ammo display
-- Show how charged the utility is
function SWEP:CustomAmmoDisplay()
    self.LastUtility = self.Owner:GetNWFloat('LastUtility', 0)
    self.AmmoDisplay = self.AmmoDisplay or {}
    
    self.AmmoDisplay.Draw = true
    self.AmmoDisplay.PrimaryClip = math.Clamp(math.floor((CurTime() - self.LastUtility) * 4), 0, 100)
    self.AmmoDisplay.MaxPrimaryClip = 100
    
    return self.AmmoDisplay
end

-- Local function to handle exiting adrenaline state
local function Unadrenaline(ply)
    if not IsValid(ply) then return end
    if not ply:Alive() then return end
    if ply:Team() != TEAM_BLUE then return end

    -- Reset speed
    GAMEMODE:SetHumanSpeed(ply)

    -- Reset FOV
    print('test')
    GAMEMODE:SetAdrenalineFOV(ply, 0)
end

-- Handle adrenaline usage
function SWEP:Adrenaline()
    -- Speed boost
    self.Owner:SetWalkSpeed(475)
    self.Owner:SetRunSpeed(475)

    -- Set FOV
    GAMEMODE:SetAdrenalineFOV(self.Owner, 115)

    -- Adrenaline lasts for 8 seconds
    local ply = self.Owner
    timer.Simple(self.AdrenalineLength, function() Unadrenaline(ply) end)
end

-- Sync weapon and player last utility times
function SWEP:Deploy()
    self.LastUtility = self.Owner:GetNWFloat('LastUtility')
end

-- Only allow the player to cloak if the device is fully charged
function SWEP:CanPrimaryAttack()
    return math.Clamp(math.floor((CurTime() - self.LastUtility) * 4), 0, 100) >= 100
end

-- Adrenaline usage
function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    
    self.Weapon:EmitSound(self.Primary.Sound)
    self.Owner:SetNWFloat('LastUtility', CurTime() + 5)
    self.LastUtility = self.Owner:GetNWFloat('LastUtility')
    if SERVER then
        self:Adrenaline()
    end
end

-- No secondary fire
function SWEP:SecondaryAttack()
    return false
end