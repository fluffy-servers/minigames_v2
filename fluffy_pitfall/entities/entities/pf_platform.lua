AddCSLuaFile()
ENT.Type = 'anim'
ENT.Base = 'base_anim'

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

ENT.FallSounds = {
    Sound( "doors/vent_open1.wav" ),
    Sound( "doors/vent_open2.wav" ),
    Sound( "doors/vent_open3.wav" )
}

ENT.ActivateSounds = {
    Sound( "physics/metal/sawblade_stick1.wav" ),
    Sound( "physics/metal/sawblade_stick2.wav" ),
    Sound( "physics/metal/sawblade_stick3.wav" ),
}

local gametypefunctions = {}
gametypefunctions['square'] = function(p) p:SetModel("models/hunter/blocks/cube2x2x025.mdl") end
gametypefunctions['circle'] = function(p) p:SetModel("models/hunter/tubes/circle2x2.mdl") end
gametypefunctions['mixed'] = function(p) p:SetModel( table.Random( mixedmodels ) ); p:SetAngles( Angle(0, math.random(360), 0 ) ) end

function ENT:Initialize()
    if CLIENT then return end
    
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
    
    self:SetTrigger(true)
end

function ENT:Touch(ent)
    if GetGlobalString( 'RoundState', 'none' ) != 'InRound' then return end
    if GetGlobalFloat( 'RoundStart', 0 )+3 > CurTime() then return end
    
    if not IsValid(ent) then return end
    if not ent:IsPlayer() then return end
    if not ent:Alive() or ent.Spectating then return end
    
    if self.HasPowerUp and ent.ActivePowerUp == nil then
        GAMEMODE:PowerUpApply(ent, self.PowerUp, true)
        self.PowerUp = nil
        self.HasPowerUp = false
        self:AddDamage(0)
    end
    
    self:AddDamage(FrameTime() * 45)
end

function ENT:AddPowerUp(type)
    self.HasPowerUp = true
    self.PowerUp = type
    
    self:SetColor( Color(255, 140, 0) )
end

function ENT:OnTakeDamage(attacker, weapon)
    if attacker and IsValid(attacker) then
        self.LastAttacker = attacker
    end
    
    if weapon == 'crowbar' then
        self:AddDamage(100)
    else
        local tmod = CurTime() - self.CreationTime
        local damageamount = 20 + 35*(tmod/120)
        self:AddDamage(damageamount)
    end
end

function ENT:AddDamage(amount)
    self.MyHealth = self.MyHealth - amount
    local scale = math.Clamp(self.MyHealth/100, 0, 1)
    
    if not self.HasPowerUp then
        local r,g,b = (255 - scale * 255), (30 + scale * 200), (200)
        self:SetColor( Color( r, g, b ) )
    end
    
    if self.MyHealth <= 0 and not self.Dropped and not self.HasPowerUp then
        self.Dropped = true
        self:EmitSound(table.Random(self.ActivateSounds), 33, math.random(70, 130))
        
        timer.Simple(1, function()
            if not IsValid(self) then return end
            self:EmitSound(table.Random(self.FallSounds), 33, math.random(70, 130))
            self:Drop()
        end)
    end
end

function ENT:Drop()
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    
    local phys = self:GetPhysicsObject()
    if phys and IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(true)
    end
    
    timer.Simple(1, function()
        if not IsValid(self) then return end
        self:Remove()
    end)
end

function ENT:GetCenter()
    return self:LocalToWorld(self:OBBCenter())
end