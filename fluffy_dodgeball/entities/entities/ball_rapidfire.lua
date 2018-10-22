AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ball_base"
ENT.SpriteSize = 8

if SERVER then
    ENT.InitialVelocity 		= 1000 	// How much speed should it have when it spawns?
    ENT.NumBounces 				= 4 	// How many bounces before it dissipates?
    ENT.HitEffect 				= "" 	// Todo: effect to play when ball hits the ground/wall. Leave as "" for no effect
    ENT.DieEffect				= "smoke_poof"	// Todo: effect to use on the ball for death. Leave as "" for no effect.
    ENT.Bounciness 				= 1.2 // How much hitnormal force to apply when ball hits a surface?
    ENT.Trail 					= "" 	// Todo: effect to use on the ball for trails etc. Leave as "" for no effect.
    ENT.Damage              	= 20    // How much damage does the ball deal upon impact?
    
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
end