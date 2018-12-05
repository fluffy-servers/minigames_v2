AddCSLuaFile()
ENT.Type 			= "anim"
ENT.Base 			= "base_anim"

function ENT:Initialize()
    if CLIENT then return end
	self.Entity:SetModel( "models/fw/fw_flag.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )  
	
	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:Sleep()
	end
end

function ENT:OnTakeDamage( dmg )
    -- Remove if in contact with a trigger hurt
    if dmg:GetInflictor():GetClass() == 'trigger_hurt' or dmg:GetAttacker():GetClass() == 'trigger_hurt' then
        self:Remove()
        return
    end
	self.Entity:TakePhysicsDamage( dmg ) 
end

function ENT:OnRemove()
    -- if anything happens to the ball, spawn a new one
    if CLIENT then return end
    GAMEMODE:SpawnBall()
end
 
function ENT:PhysicsUpdate()
end

if CLIENT then
    killicon.AddFont("db_dodgeball", "HL2MPTypeDeath", "8", Color( 255, 80, 0, 255 ))
    local mat = Material( "models/fw/flaginner" )
    local col = Vector( 0, 0, 0 )
    local progress = 0
    local changing = false
    
    function ENT:Think()
        local goalcol = self.Entity:GetNWVector( "RColor", Vector( 1, 1, 1 ) ) //R from Refract!
        local thinktime = 1/45
        
        if col != goalcol then
            if !changing then
                progress = 0
                changing = true
            end
        else
            changing = false
        end
        
        if changing then
            progress = progress + FrameTime()/2
            if progress >= 1 then
                progress = 1
                changing = false
                col = goalcol
            end
            col = LerpVector( progress, col, goalcol )
        else
            col = goalcol
            thinktime = 1/15
        end
        
        mat:SetVector( "$refracttint", col )
        
        local size = 256
        
        local dlight = DynamicLight( self:EntIndex() )
        if dlight then
            dlight.Pos = self:GetPos()
            dlight.r = col.x * 127
            dlight.g = col.y * 127
            dlight.b = col.z * 127
            dlight.Brightness = 3
            dlight.Size = size
            dlight.Decay = 100
            dlight.DieTime = CurTime() + 1
        end
        
        self.Entity:NextThink( CurTime() + thinktime )
        return true
    end
    
    function ENT:Draw()
        self.Entity:DrawModel()
    end
end