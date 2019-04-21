if SERVER then
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if CLIENT then
	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.CSMuzzleFlashes	= true

	SWEP.ViewModelFOV		= 75
	SWEP.ViewModelFlip		= false
	
	SWEP.PrintName = "Time Bomb"
	SWEP.IconLetter = "C"
	SWEP.Slot = 0
	SWEP.Slotpos = 0
	
	--SWEP.IconFont = "CSSelectIcons"
	
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		draw.SimpleText( self.IconLetter, self.IconFont, x + wide/2, y + tall/2.5, Color( 15, 20, 200, 255 ), TEXT_ALIGN_CENTER )
	end
	killicon.AddFont("bt_bomb", "HL2MPTypeDeath", "*", Color( 255, 80, 0, 255 ))
end

SWEP.HoldType = "slam"
SWEP.ViewModel		= "models/weapons/cstrike/c_c4.mdl"
SWEP.WorldModel		= "models/weapons/w_c4.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound			= Sound("buttons/blip2.wav")
SWEP.Primary.Deploy         = Sound("ambient/alarms/warningbell1.wav")
SWEP.Primary.Warning        = Sound("ambient/alarms/klaxon1.wav")
SWEP.Primary.Recoil			= 3.5
SWEP.Primary.Damage			= 0
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.025
SWEP.Primary.Delay			= 0.05

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.NextTick = 0
SWEP.EndingTime = nil

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self.Weapon:EmitSound( self.Primary.Deploy )
	
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.75 )
	
	return true
end  

function SWEP:Think()
    -- Calculate the times for the ammo display
	if CLIENT and not self.EndingTime then
		self.EndingTime = CurTime() + math.Clamp(self.Owner:GetNWInt("Time", 0) - 1, 0, 60)
		self.TimeLength = math.Clamp( self.Owner:GetNWInt("Time", 0) - 1, 0, 60 )
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
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:Trace()
end

function SWEP:Trace()
	if CLIENT then return end
	
	local pos = self.Owner:GetShootPos()
	local aim = self.Owner:GetAimVector() * 70
	
    -- Run a trace for any players
	local tr = {}
	tr.start = pos
	tr.endpos = pos + aim
	tr.filter = self.Owner
	tr.mins = Vector(-16,-16,-16)
	tr.maxs = Vector(16,16,16)

	local trace = util.TraceHull( tr )
	local ent = trace.Entity

	if not IsValid( ent ) or not ent:IsPlayer() then 
		return 
	else
        -- Pass the bomb to a new player
		if ent:Team() == TEAM_SPECTATOR or !ent:Alive() then return end
        self.Owner:SetCarrier(false)
		self.Owner:Give("bt_punch")
		self.Owner:StripWeapon("bt_bomb")
		ent:SetCarrier(true)
		ent:SetTime(self.Owner:GetTime())
		ent:StripWeapons()
		ent:Give("bt_bomb")
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