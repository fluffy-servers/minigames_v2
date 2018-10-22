AddCSLuaFile()
DEFINE_BASECLASS("base_anim")

ENT.PrintName = "Balloon"
ENT.Model = "models/maxofs2d/balloon_classic.mdl"
ENT.Points = 1
ENT.SpeedMin = 20 
ENT.SpeedMax = 30
ENT.Balloon = true

function ENT:Initialize()
	if CLIENT then return end

	self:SetModel(self.Model)
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetRenderMode( RENDERMODE_TRANSALPHA )

	-- Set up our physics object here
	local phys = self:GetPhysicsObject()
	if ( IsValid( phys ) ) then
		phys:SetMass( 100 )
		phys:Wake()
		phys:EnableGravity( false )
	end
	
	self.Speed = math.random(self.SpeedMin, self.SpeedMax)
	self:StartMotionController()
	
	
	self:SetColor( HSVToColor(math.random(360), 1, 1) )
end

function ENT:OnTakeDamage(dmginfo)
	local c = self:GetColor()
	
	local effectdata = EffectData()
	effectdata:SetOrigin( self:GetPos() )
	effectdata:SetStart( Vector( c.r, c.g, c.b ) )
	util.Effect( "balloon_pop", effectdata )
	
	local attacker = dmginfo:GetAttacker()
	if IsValid(attacker) and attacker:IsPlayer() then
		GAMEMODE:PopBalloon(attacker, self.Points, self:GetClass())
	end
	self:Remove()
end

function ENT:PhysicsSimulate(phys, deltatime)
	local vLinear = Vector(0, 0, (self.Speed or 5)) * 5000 * deltatime
	local vAngular = Vector(0, 0, 0)
	
	return vAngular, vLinear, SIM_GLOBAL_FORCE
end