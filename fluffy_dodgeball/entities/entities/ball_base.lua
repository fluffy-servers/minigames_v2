AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.SpriteSize = 32

if SERVER then
    ENT.InitialVelocity 	= 1000 	// How much speed should it have when it spawns?
    ENT.NumBounces 		    = 3 	// How many bounces before it dissipates?
    ENT.HitEffect 		    = "" 	// Todo: effect to play when ball hits the ground/wall. Leave as "" for no effect
    ENT.DieEffect		    = "smoke_poof"	// Todo: effect to use on the ball for death. Leave as "" for no effect.
    ENT.Bounciness 	    	= 0.9 // How much hitnormal force to apply when ball hits a surface?
    ENT.Trail 		        = "" 	// Todo: effect to use on the ball for trails etc. Leave as "" for no effect.
    ENT.Damage              = 50    // How much damage does the ball deal upon impact?
    ENT.BouncePower         = 100   // How hard should the ball punch players?
    ENT.HitSound			= Sound("Rubber.BulletImpact")
    ENT.DieSound    	    = Sound("physics/plastic/plastic_box_impact_hard1.wav")
    
    function ENT:Initialize()
        util.PrecacheModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
        self.Entity:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
        self.Entity:PhysicsInitSphere( 16, "metal_bouncy" )
	
        local phys = self.Entity:GetPhysicsObject()
        if (phys:IsValid()) then
            phys:Wake()
            if self:GetOwner() and self:GetOwner():IsValid() then
                phys:ApplyForceCenter( self:GetOwner():GetAimVector() * self.InitialVelocity )
            end
        end
	
        self.Entity:SetCollisionBounds( Vector( -16, -16, -16 ), Vector( 16, 16, 16 ) )
	
        if self.Trail != "" then
            local ed = EffectData()
            ed:SetEntity( self.Entity )
            util.Effect( self:GetTrail(), ed, true, true )
        end
    end
    
    function ENT:OnRemove()
        if self.DieEffect != "" then
            local ed = EffectData()
            ed:SetOrigin( self:GetPos() )
            util.Effect( self.DieEffect, ed, true, true )
        end
        self:EmitSound( self.DieSound, 100, math.random(90,110) )
    end
    
    function ENT:PhysicsCollide( data, phys )
        if self.HitEffect != "" then
            local ed = EffectData()
            ed:SetOrigin( data.HitPos )
            ed:SetNormal( data.HitNormal ) 
            util.Effect( self.HitEffect, ed, true, true )
        end
    
        if data.HitEntity then
            if data.HitEntity:IsValid() and data.HitEntity:IsPlayer() and data.HitEntity:Team() != self:GetOwner():Team() then
                local norm = data.HitNormal
                data.HitEntity:SetVelocity( norm * self.BouncePower + Vector(0,0,100) )
                data.HitEntity:TakeDamage( self.Damage, self:GetOwner() )
                self:Remove()
            end
        end
        
        // Play sound on bounce
        if (data.Speed > 80 && data.DeltaTime > 0.2 ) then
            self.Entity:EmitSound( self.HitSound, 100, math.random(90,110) )
        end
        
        // Bounce like a crazy bitch - the default ball
        local LastSpeed = math.max( data.OurOldVelocity:Length(), data.Speed )
        local NewVelocity = phys:GetVelocity()
        NewVelocity:Normalize()
        
        LastSpeed = math.max( NewVelocity:Length(), LastSpeed )
        
        local TargetVelocity = NewVelocity * LastSpeed * self.Bounciness
        
        phys:SetVelocity( TargetVelocity )
        
        self.NumBounces = self.NumBounces - 1
        if self.NumBounces == 0 then
            timer.Simple(0.1, function() if IsValid(self) then self:Remove() end end)
        end
    end
    
    function ENT:GetPlayer()
        return self:GetOwner()
    end
    
elseif CLIENT then
    ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
    ENT.Material = Material( "sprites/sent_ball" )

    function ENT:Initialize()
        if self:GetOwner() and self:GetOwner():IsValid() then
            self.Color = table.Copy( team.GetColor( self:GetOwner():Team() ) )
        end
	end

    function ENT:Draw()
        if not self.Color then
            if self:GetOwner() and self:GetOwner():IsValid() then
                self.Color = table.Copy( team.GetColor( self:GetOwner():Team() ) )
            else
                self.Color = Color(200,200,200,255)
            end
        end
	
        local pos = self.Entity:GetPos()
        local vel = self.Entity:GetVelocity()
		
        render.SetMaterial( self.Material )
	
        local lcolor = render.GetLightColor( self:GetPos() ) * 2
	
        lcolor.x = self.Color.r * math.Clamp( lcolor.x, 0, 1 )
        lcolor.y = self.Color.g * math.Clamp( lcolor.y, 0, 1 )
        lcolor.z = self.Color.b * math.Clamp( lcolor.z, 0, 1 )
		
        if vel:Length() > 1 then
            for i = 1, 10 do
                local col = Color( lcolor.x, lcolor.y, lcolor.z, 200 / i )
                render.DrawSprite( pos + vel*(i*-0.005), self.SpriteSize, self.SpriteSize, col )
            end
		end
        
        render.DrawSprite( pos, self.SpriteSize, self.SpriteSize, Color( lcolor.x, lcolor.y, lcolor.z, 255 ) )
	end
end