AddCSLuaFile()

if CLIENT then
    SWEP.IconFont = "CSSelectIcons"
    SWEP.IconLetter = "H"
    surface.CreateFont("CSSelectIcons", {font="csd", size=ScreenScale(60)})
    
    function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		draw.SimpleText( self.IconLetter, self.IconFont, x + wide/2, y + tall/2.5, Color( 15, 20, 200, 255 ), TEXT_ALIGN_CENTER )
	end
end

-- Menu data
SWEP.PrintName = 'Cloaking Device'
SWEP.Slot = 2
SWEP.SlotPos = 2

-- Model data
SWEP.HoldType = 'slam'
SWEP.ViewModel	= "models/weapons/cstrike/c_c4.mdl"
SWEP.WorldModel = "models/weapons/w_c4.mdl"
SWEP.UseHands = true

-- Effect data
SWEP.Primary.Sound = Sound("ambient/machines/teleport3.wav")
SWEP.Primary.Delay = 1.5

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
    self.AmmoDisplay.PrimaryClip = math.Clamp(math.floor((CurTime() - self.LastUtility) * 5), 0, 100)
    self.AmmoDisplay.MaxPrimaryClip = 100
    
    return self.AmmoDisplay
end

-- Local function to handle uncloak logic
local function Uncloak(ply)
    if not IsValid(ply) then return end
    if not ply:Alive() then return end
    
    GAMEMODE:PlayerLoadout(ply)
end

-- Actual cloaking logic
function SWEP:Cloak()
    if CLIENT then return end
    
    -- Create a cool effect
    local ed = EffectData()
    ed:SetOrigin(self.Owner:GetPos())
    util.Effect('teleport_flash', ed, true, true)
    
    -- Make the player invisible
    self.Owner:SetNoDraw(true)
    self.Owner:StripWeapons()
    self.Owner:SetWalkSpeed(500)
    self.Owner:SetRunSpeed(500)
    
    -- Uncloak after 8 seconds
    local ply = self.Owner
    timer.Simple(8, function() Uncloak(ply) end)
end

-- Sync weapon and player last utility times
function SWEP:Deploy()
    self.LastUtility = self.Owner:GetNWFloat('LastUtility')
end

-- Only allow the player to cloak if the device is fully charged
function SWEP:CanPrimaryAttack()
    return math.Clamp(math.floor((CurTime() - self.LastUtility)*4), 0, 100) >= 100
end

-- Cloak the player
function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    
    self.Weapon:EmitSound(self.Primary.Sound)
    self:Cloak()
    self.Owner:SetNWFloat('LastUtility', CurTime() + 5)
    self.LastUtility = self.Owner:GetNWFloat('LastUtility')
end

-- Disable shotgun
function SWEP:SecondaryAttack()
    return false
end