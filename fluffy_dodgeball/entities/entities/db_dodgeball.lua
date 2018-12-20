AddCSLuaFile()
ENT.Type 			= "anim"
ENT.Base 			= "base_anim"

ENT.RespawnTime     = 10
ENT.LastTime = -1

ENT.Size = 32
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
    if CLIENT then return end
	self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
	
    local size = self.Size
    self:PhysicsInitSphere(size, "metal_bouncy")
    self:SetCollisionBounds(Vector(-size, -size, -size), Vector(size, size, size))
    self:PhysWake()
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
    local ball_mat = Material("sprites/sent_ball")
    function ENT:Draw()
        render.SetMaterial(ball_mat)
        
        local pos = self:GetPos()
        local lcolor = render.ComputeLighting( pos, Vector( 0, 0, 1 ) )
        local c = self:GetNWVector('RColor', Vector(1, 1, 1))
        
        lcolor.x = c.r * ( math.Clamp( lcolor.x, 0, 1 ) + 0.5 ) * 255
        lcolor.y = c.g * ( math.Clamp( lcolor.y, 0, 1 ) + 0.5 ) * 255
        lcolor.z = c.b * ( math.Clamp( lcolor.z, 0, 1 ) + 0.5 ) * 255
        
        local size = self.Size
        render.DrawSprite(pos, size, size, Color( lcolor.x, lcolor.y, lcolor.z, 225 ))
    end
end