AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ball_base"
ENT.SpriteSize = 8

if SERVER then
    ENT.InitialVelocity 	= 2000 	// How much speed should it have when it spawns?
    ENT.NumBounces 			= 1 	// How many bounces before it dissipates?
    ENT.HitEffect 			= "" 	// Todo: effect to play when ball hits the ground/wall. Leave as "" for no effect
    ENT.DieEffect			= "smoke_poof"	// Todo: effect to use on the ball for death. Leave as "" for no effect.
    ENT.Bounciness 			= 1.2 // How much hitnormal force to apply when ball hits a surface?
    ENT.Trail 				= "" 	// Todo: effect to use on the ball for trails etc. Leave as "" for no effect.
    ENT.Damage              = 10    // How much damage does the ball deal upon impact?
    ENT.HitSound			= Sound("Rubber.BulletImpact")
    ENT.DieSound       		= Sound("physics/plastic/plastic_box_impact_hard1.wav")
    
    function ENT:Initialize()
        self.Entity:SetModel("models/props_junk/PopCan01a.mdl")
        
        self.Entity:PhysicsInitSphere( 6, "metal_bouncy" )
        
        local phys = self.Entity:GetPhysicsObject()
        if (phys:IsValid()) then
            phys:Wake()
            phys:ApplyForceCenter(self:GetPlayer():GetAimVector() * self.InitialVelocity)
        end
        
        self.Entity:SetCollisionBounds( Vector( -6, -6, -6 ), Vector( 6, 6, 6 ) )
        
    end
elseif CLIENT then
    ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
    
    function ENT:Draw()
        local pos = self.Entity:GetPos()
        local vel = self.Entity:GetVelocity()
            
        render.SetMaterial( self.Material )
        
        if not self.Color then
            if self:GetOwner() and self:GetOwner():IsValid() then
                self.Color = table.Copy( team.GetColor( self:GetOwner():Team() ) )
            else
                self.Color = Color(200,200,200,255)
            end
        end
        
        local lcolor = render.GetLightColor( self:GetPos() ) * 2
        
        lcolor.x = self.Color.r * math.Clamp( lcolor.x, 0, 1 )
        lcolor.y = self.Color.g * math.Clamp( lcolor.y, 0, 1 )
        lcolor.z = self.Color.b * math.Clamp( lcolor.z, 0, 1 )
            
        if ( vel:Length() > 1 ) then
        
            for i = 1, 10 do
            
                local col = Color( lcolor.x, lcolor.y, lcolor.z, 200 / i )
                render.DrawSprite( pos + vel*(i*-0.005), 8, 8, col )
                
            end
        
        end
            
        render.DrawSprite( pos, 8, 8, Color( lcolor.x, lcolor.y, lcolor.z, 255 ) )
    end
end