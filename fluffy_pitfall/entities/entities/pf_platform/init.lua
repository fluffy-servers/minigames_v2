AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

local mixedmodels = {
    "models/hunter/blocks/cube2x2x025.mdl",
    "models/hunter/blocks/cube2x2x025.mdl",
    "models/hunter/tubes/circle2x2.mdl",
    "models/hunter/tubes/circle2x2.mdl",
    "models/hunter/blocks/cube075x075x075.mdl",
    "models/hunter/misc/shell2x2a.mdl",
    "models/hunter/tubes/circle4x4c.mdl",
    "models/hunter/triangles/2x2.mdl",
    "models/hunter/triangles/2x2.mdl",
    "models/hunter/triangles/3x3.mdl",
}

local props = {

}

local gametypefunctions = {}
gametypefunctions['square'] = function(p) p:SetModel("models/hunter/blocks/cube2x2x025.mdl") end
gametypefunctions['circle'] = function(p) p:SetModel("models/hunter/tubes/circle2x2.mdl") end
gametypefunctions['mixed'] = function(p) p:SetModel( table.Random( mixedmodels ) ); p:SetAngles( Angle(0, math.random(360), 0 ) ) end
 
function ENT:Initialize()
    local mode = GetGlobalString( 'PitfallType', 'square' )
	self:SetModel("models/hunter/blocks/cube2x2x025.mdl")
    gametypefunctions[mode]( self )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	
	self:SetColor( Color( 0, 255, 0 ) )
	
	local phys = self:GetPhysicsObject()
	if ( phys:IsValid() ) then
		phys:EnableMotion( false )
		phys:Sleep()
	end
	
	self.MyHealth = 100
    self.CreationTime = CurTime()

end

function ENT:OnRemove()
	local ed = EffectData()
	ed:SetEntity( Entity )
	util.Effect( "entity_remove", ed, true, true )
end

function ENT:OnTakeDamage( dmg )
	local attacker = dmg:GetAttacker()
	--local damageamount = dmg:GetDamage()
    
    local tmod = CurTime() - self.CreationTime
    
    local damageamount = 5 + 20*(tmod/120)
    
    
	self.MyHealth = self.MyHealth - damageamount
	
	local scale = math.Clamp( self.MyHealth / 100, 0, 1 )
	local r,g,b = (255 - scale * 255), (30 + scale * 200), (200)
    
	self:SetColor( Color( r, g, b ) )

	if( self.MyHealth <= 0 ) then
	
		self.LastAttacker = attacker
		
		if !self.IsFalling then
			self.IsFalling = true
			self:SetMoveType( MOVETYPE_VPHYSICS )
			
			local phys = self:GetPhysicsObject()
			if ( phys:IsValid() ) then
				phys:EnableMotion( true ) 
				phys:Wake()
				phys:SetVelocity(Vector(0, 0, -600) )
			else
				print("Could not enable motion on entity")
			end
		end
	end
    
end

function ENT:GetCenter()
	return self:LocalToWorld( self:OBBCenter() )
end
 
function ENT:Think()
end
 
function ENT:PhysicsUpdate()
end

function ENT:Touch( hitEnt )
	if IsValid( hitEnt ) and hitEnt:IsPlayer() then
		hitEnt.LastPlatformTouched = self
	end
end

function ENT:EndTouch( hitEnt )
	if IsValid( hitEnt ) and hitEnt:IsPlayer() then
		hitEnt.LastPlatformTouched = self
	end
end