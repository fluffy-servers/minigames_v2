AddCSLuaFile()
ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.RespawnTime     = 10

function ENT:Initialize()
    if CLIENT then return end
	self.Entity:SetModel( "models/fw/fw_flag.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )  
	
    self.Entity:PhysicsInitSphere(16, "metal_bouncy")
	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
        phys:EnableMotion(true)
        phys:EnableGravity(false)
	end
    
    self.LastTime = -1
    if math.random() > 0.2 then self:SetNWBool('Explosive', true) end
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
    if not self.Number then return end
    GAMEMODE:RespawnBall(self.Number)
end

function ENT:Think()
    if self.LastTime == -1 then return end
    
    if CurTime() > self.LastTime + self.RespawnTime then
        self:Remove()
    end
end
 
function ENT:PhysicsUpdate( phys )
	vel = Vector( 0, 0, ( ( -9.81 * phys:GetMass() ) * 0.65 ) )
	phys:ApplyForceCenter( vel )
end 

function ENT:PhysicsCollide( data, physobj )
    if data.HitEntity:IsPlayer() and data.Speed > 50 then
        local ply = data.HitEntity
        if (self:GetNWString('CurrentTeam') == 'blue' and ply:Team() == TEAM_RED) or (self:GetNWString('CurrentTeam') == 'red' and ply:Team() == TEAM_BLUE) then
            local info = DamageInfo()
            info:SetDamage(data.Speed)
            info:SetDamageType(DMG_DISSOLVE)
            info:SetAttacker(self.LastHolder or self)
            info:SetInflictor(self)
            ply:TakeDamageInfo(info)
        end
    end
    
    if data.Speed > 150 and self.Explosive then
        self:Remove()
	elseif data.Speed > 70 then
		self:EmitSound( "Rubber.BulletImpact" )
	end
	
	// Bounce like a crazy bitch
	local LastSpeed = math.max( data.OurOldVelocity:Length(), data.Speed )
	local NewVelocity = physobj:GetVelocity()
	NewVelocity:Normalize()
	LastSpeed = math.max( NewVelocity:Length(), LastSpeed )
	local TargetVelocity = NewVelocity * LastSpeed * 0.8
	physobj:SetVelocity( TargetVelocity )
end

if CLIENT then
    killicon.AddFont("db_dodgeball", "HL2MPTypeDeath", "8", Color( 255, 80, 0, 255 ))
    local mat = Material( "models/fw/flaginner" )
    local boom_mat = Material('phoenix_storms/stripes')
    ENT.col = Vector( 0, 0, 0 )
    ENT.progress = 0
    ENT.changing = false
    
    function ENT:Think()
        local thinktime = 1/45
        if self:GetNWBool('explosive', false) then
            self:SetMaterial(boom_mat, true)
        else
            local goalcol = self:GetNWVector( "RColor", Vector( 1, 1, 1 ) ) //R from Refract!
            
            if self.col != goalcol then
                if !changing then
                    self.progress = 0
                    self.changing = true
                end
            else
                self.changing = false
            end
            
            if self.changing then
                self.progress = self.progress + FrameTime()*2
                if self.progress >= 1 then
                    self.progress = 1
                    self.changing = false
                    self.col = goalcol
                end
                self.col = LerpVector(self.progress, self.col, goalcol )
            else
                self.col = goalcol
                thinktime = 1/15
            end
            
            mat:SetVector( "$refracttint", self.col )
            local size = 256
        end
        
        local dlight = DynamicLight( self:EntIndex() )
        if dlight then
            dlight.Pos = self:GetPos()
            dlight.r = self.col.x * 127
            dlight.g = self.col.y * 127
            dlight.b = self.col.z * 127
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