AddCSLuaFile()
	
if CLIENT then
    killicon.AddFont("bt_bomb", "HL2MPTypeDeath", "*", Color( 255, 80, 0, 255 ))
end

SWEP.HoldType       = "slam"
SWEP.ViewModel		= "models/weapons/cstrike/c_c4.mdl"
SWEP.WorldModel		= "models/weapons/w_c4.mdl"
SWEP.UseHands       = true
SWEP.DrawCrosshair	= false
SWEP.PrintName      = "Time Bomb"

SWEP.Primary.Sound			= Sound("buttons/blip2.wav")
SWEP.Primary.Deploy         = Sound("ambient/alarms/warningbell1.wav")
SWEP.Primary.Warning        = Sound("ambient/alarms/klaxon1.wav")
SWEP.Primary.Delay          = 0.05

SWEP.NextTick   = 0
SWEP.EndingTime = 0

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self.Weapon:EmitSound(self.Primary.Deploy)
	
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
	
	return true
end  

function SWEP:Think()
    -- Calculate the times for the ammo display
	if CLIENT and not self.EndingTime then
		self.EndingTime = CurTime() + math.Clamp(self.Owner:GetNWInt("Time", 0) - 1, 0, 60)
		self.TimeLength = math.Clamp(self.Owner:GetNWInt("Time", 0) - 1, 0, 60)
        print(self.TimeLength)
	end
	
    -- Tick down the bomb
	if self.NextTick < CurTime() then
		self.NextTick = CurTime() + 1
		
		if CLIENT then return end
		self.Owner:AddTime(-1)
		
        -- Emit warning beeps
		if self.Owner:GetNWInt("Time", 1) <= 5 and self.Owner:GetNWInt("Time", 1) > 0 then
			self.Owner:EmitSound(self.Primary.Warning, 100, 150 - 50 * self.Owner:GetNWInt("Time", 1) / 5)
		else
			self.Owner:EmitSound(self.Primary.Sound, 100, 120)
		end
	end
end

function SWEP:Reload()
	self.Weapon:PrimaryAttack()
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Weapon:Trace()
end

function SWEP:Trace()
	if CLIENT then return end
	
	local pos = self.Owner:GetShootPos()
	local aim = self.Owner:GetAimVector() * 96
	
    -- Run a trace for any players
	local tr = {}
	tr.start = pos
	tr.endpos = pos + aim
	tr.filter = self.Owner
	tr.mins = Vector(-32,-32,-32)
	tr.maxs = Vector(32,32,32)

	local trace = util.TraceHull( tr )
	local ent = trace.Entity

	if not IsValid( ent ) or not ent:IsPlayer() then 
		return 
	else
        -- Pass the bomb to a new player
		if ent:Team() == TEAM_SPECTATOR or !ent:Alive() then return end
        self.Owner:SetCarrier(false)
		self.Owner:Give("bt_punch")
		ent:SetCarrier(true)
		ent:SetTime(self.Owner:GetTime())
		ent:StripWeapons()
        self.Owner:StripWeapon("bt_bomb")
        self.Owner:AddStatPoints('Bomb Passes', 1)
		timer.Simple(0.1, function() ent:Give("bt_bomb") end)
	end
end

function SWEP:SecondaryAttack()
	self.Weapon:PrimaryAttack()
end

function SWEP:CustomAmmoDisplay()
    self.AmmoDisplay = self.AmmoDisplay or {}
    self.AmmoDisplay.PrimaryClip = self.Owner:GetNWInt("Time") or 0
    self.AmmoDisplay.MaxPrimaryClip = self.TimeLength or 0
    return self.AmmoDisplay
end