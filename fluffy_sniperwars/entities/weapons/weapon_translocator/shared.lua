if SERVER then

	AddCSLuaFile("shared.lua")
	
end

if CLIENT then

	SWEP.ViewModelFOV		= 75
	SWEP.ViewModelFlip		= false
	
	SWEP.PrintName = "Utility Device"
	SWEP.IconLetter = "H"
	SWEP.Slot = 2
	SWEP.Slotpos = 2
	
end

SWEP.Base = "sniper_base"

SWEP.HoldType = "slam"

SWEP.ViewModel	= "models/weapons/cstrike/c_c4.mdl"
SWEP.WorldModel = "models/weapons/w_c4.mdl"
SWEP.UseHands = true

SWEP.SprintPos = Vector(0,0,0)
SWEP.SprintAng = Vector(0,0,0)

SWEP.Primary.Sound			= Sound("ambient/machines/teleport3.wav")
SWEP.Primary.Recoil			= 3.5
SWEP.Primary.Damage			= 1
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.030
SWEP.Primary.Delay			= 1.500

SWEP.Primary.ClipSize		= 100
SWEP.Primary.Automatic		= false

SWEP.LoadTime = 0

hook.Add( "PlayerSpawn", "Utility", function(ply)
	ply:SetNWFloat( "LastUtility", CurTime() )
end )

function SWEP:CustomAmmoDisplay()
	self.LastUtility = self.Owner:GetNWFloat( "LastUtility" )
	self.AmmoDisplay = self.AmmoDisplay or {}

	self.AmmoDisplay.Draw = true //draw the display?
	if !self.LastUtility then self.LastUtility = 0 end
	self.AmmoDisplay.PrimaryClip = math.Clamp( math.floor( (CurTime() - self.LastUtility) * 4 ), 0, 100 )

	return self.AmmoDisplay //return the table
end

function SWEP:TeleportTrace()
	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = tr.start + self.Owner:GetAimVector() * 3000
	tr.filter = self.Owner
	tr = util.TraceLine( tr )

	return tr.HitPos + tr.HitNormal * 150
end

function SWEP:Teleport()
	local ed = EffectData()
	ed:SetOrigin( self.Owner:GetPos() )
	util.Effect( "teleport_flash", ed, true, true )
	
	local pos = self:TeleportTrace()
	self.Owner:SetPos( pos )
	
	local ed = EffectData()
	ed:SetOrigin( self.Owner:GetPos() )
	util.Effect( "teleport_flash", ed, true, true )
end

local function Uncloak( ply )
	if IsValid( ply ) then
		if ply:Alive() then
			ply:SetNoDraw( false )
			ply:Give( "sniper_normal" )
			ply:Give( "firearm_p228" )
			ply:Give( "weapon_translocator" )
		end
	end
end

function SWEP:Cloak()
	local ed = EffectData()
	ed:SetOrigin( self.Owner:GetPos() )
	util.Effect( "teleport_flash", ed, true, true )
	
	self.Owner:SetNoDraw( true )
	self.Owner:StripWeapons()
	local ply = self.Owner
	timer.Simple( 5, function() Uncloak( ply ) end )
end

local function SpeedBoostEnd( ply )
	ply:SetRunSpeed( 500 )
	ply:SetWalkSpeed( 250 )
end

function SWEP:SpeedBoost()
	self.Owner:SetRunSpeed( 1000 )
	self.Owner:SetWalkSpeed( 1000 )
	local ply = self.Owner
	timer.Simple( 10, function() SpeedBoostEnd( ply ) end )
end

local function LowGravEnd( ply )
	ply:SetGravity( 1 )
	ply:SetJumpPower( 200 )
end

function SWEP:LowGrav()
	self.Owner:SetGravity( 0.25 )
	self.Owner:SetJumpPower( 500 )
	local ply = self.Owner
	timer.Simple( 15, function() LowGravEnd( ply ) end )
end

function SWEP:Initialize()
	local types = {'teleport', 'cloak', 'speed', 'lowgrav'}
	self.Action = table.Random( types )
	self:SetNWString('Action', self.Action )
end

function SWEP:Deploy()
	if SERVER then
		self.Weapon:SetViewModelPosition()
		self.Weapon:SetZoomMode(1)
		self.Owner:DrawViewModel( true )
	end	
	
	self.LastUtility = self.Owner:GetNWFloat( "LastUtility" )
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	return true
end

function SWEP:Reload()

end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:PrimaryAttack()

	if not self.Weapon:CanPrimaryAttack() then return end
	if math.Clamp( math.floor( (CurTime() - self.LastUtility) * 4 ), 0, 100 ) != 100 then return end

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self.Weapon:EmitSound( self.Primary.Sound )
	self.Weapon:TakePrimaryAmmo( 100 )
	
	self.LoadTime = CurTime() + 0.5
	
	if SERVER then
		if self.Action == 'cloak' then
			self:Cloak()
			self.Owner:SetNWFloat( "LastUtility", CurTime() + 5 )
		elseif self.Action == 'teleport' then
			self:Teleport()
			self.Owner:SetNWFloat( "LastUtility", CurTime() )
		elseif self.Action == 'speed' then
			self:SpeedBoost()
			self.Owner:SetNWFloat( "LastUtility", CurTime() + 10 )
		elseif self.Action == 'lowgrav' then
			self:LowGrav()
			self.Owner:SetNWFloat( "LastUtility", CurTime() + 15 )
		end
	end
	
	self.LastUtility = self.Owner:GetNWFloat( "LastUtility" )
end

function SWEP:DrawHUD()
	self.PrintName = self:GetNWString('Action')
	
	local w = ScrW()
	local h = ScrH()
	
	local wh, lh, sh = w*.5, h*.5, 4
		
	surface.SetDrawColor( CrossRed:GetInt(), CrossGreen:GetInt(), CrossBlue:GetInt(), CrossAlpha:GetInt() )
	surface.DrawLine(wh - sh, lh - sh, wh + sh, lh - sh) //top line
	surface.DrawLine(wh - sh, lh + sh, wh + sh, lh + sh) //bottom line
	surface.DrawLine(wh - sh, lh - sh, wh - sh, lh + sh) //left line
	surface.DrawLine(wh + sh, lh - sh, wh + sh, lh + sh) //right line
	
	surface.SetDrawColor( color_white )
	surface.SetTextPos( ScrW() - 128, ScrH() - 128 )
	surface.SetFont( 'Default' )
	surface.DrawText( self:GetNWString('Action' ) )
	
end


