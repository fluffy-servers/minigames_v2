SWEP.Base = "weapon_mg_base"

if CLIENT then
    SWEP.IconLetter = "G"
    SWEP.IconFont = "CSSelectIcons"
    killicon.AddFont("bt_bomb", "HL2MPTypeDeath", "*", Color(255, 80, 0, 255))
end

SWEP.HoldType = "slam"
SWEP.ViewModel = "models/weapons/cstrike/c_c4.mdl"
SWEP.WorldModel = "models/weapons/w_c4.mdl"
SWEP.UseHands = true
SWEP.DrawCrosshair = false
SWEP.PrintName = "Time Bomb"

SWEP.Primary.Sound = Sound("buttons/blip2.wav")
SWEP.Primary.Deploy = Sound("ambient/alarms/warningbell1.wav")
SWEP.Primary.Warning = Sound("ambient/alarms/klaxon1.wav")
SWEP.Primary.Delay = 0.025

SWEP.NextTick = 0
SWEP.EndingTime = 0

function SWEP:Initialize()
    self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Deploy()
    self:SendWeaponAnim(ACT_VM_DRAW)
    self:EmitSound(self.Primary.Deploy)
    self:SetNextPrimaryFire(CurTime() + 0.5)

    return true
end

function SWEP:Think()
    -- Calculate the times for the ammo display
    local owner = self:GetOwner()
    if CLIENT and not self.EndingTime then
        self.EndingTime = CurTime() + math.Clamp(owner:GetNWInt("Time", 0) - 1, 0, 60)
        self.TimeLength = math.Clamp(owner:GetNWInt("Time", 0) - 1, 0, 60)
    end

    -- Tick down the bomb
    if self.NextTick < CurTime() then
        self.NextTick = CurTime() + 1
        if CLIENT then return end
        owner:AddTime(-1)

        -- Emit warning beeps
        if owner:GetNWInt("Time", 1) <= 5 and owner:GetNWInt("Time", 1) > 0 then
            owner:EmitSound(self.Primary.Warning, 100, 150 - 50 * owner:GetNWInt("Time", 1) / 5)
        else
            owner:EmitSound(self.Primary.Sound, 100, 120)
        end
    end
end

function SWEP:Reload()
    self:PrimaryAttack()
end

function SWEP:CanPrimaryAttack()
    return true
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:Trace()
end

-- Pass the bomb to a new player
function SWEP:PassBomb(ply)
    if ply:Team() == TEAM_SPECTATOR or not ply:Alive() then return end
    local owner = self:GetOwner()
    owner:SetCarrier(false)
    owner:Give("bt_punch")
    ply:SetCarrier(true)
    ply:SetTime(owner:GetTime())
    ply:StripWeapons()
    owner:AddStatPoints("Bomb Passes", 1)
    owner:StripWeapon("bt_bomb")

    timer.Simple(0.1, function()
        ply:Give("bt_bomb")
    end)

    local name = string.sub(ply:Nick(), 1, 10)
    GAMEMODE:PulseAnnouncement(2, name .. " has the bomb!", 1, "top")
end

function SWEP:Trace()
    if CLIENT then return end
    local owner = self:GetOwner()
    local pos = owner:GetShootPos()
    local aim = owner:GetAimVector() * 32

    -- Search for player in a radius just in front of the player
    -- This is nothing short of scuffed - move this to handled like a melee weapon
    local entities = ents.FindInSphere(pos + aim, 32)
    for k, v in pairs(entities) do
        if v:IsPlayer() and v ~= owner then
            self:PassBomb(v)
            return
        end
    end
end

function SWEP:SecondaryAttack()
    self:PrimaryAttack()
end

function SWEP:CustomAmmoDisplay()
    self.AmmoDisplay = self.AmmoDisplay or {}
    self.AmmoDisplay.PrimaryClip = self:GetOwner():GetNWInt("Time") or 0
    self.AmmoDisplay.MaxPrimaryClip = self.TimeLength or 0

    return self.AmmoDisplay
end