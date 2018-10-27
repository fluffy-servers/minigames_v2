AddCSLuaFile()
ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.Speed = 600

if SERVER then
    -- Cactus initialize
    function ENT:Initialize()
        self:SetModel( "models/props_lab/cactus.mdl" ) 
        
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:SetSolid( SOLID_VPHYSICS )
        
        self:PhysicsInitSphere(12, 'metal')
    
        local phys = self:GetPhysicsObject()
        if (phys:IsValid()) then
            phys:Sleep()
            phys:Wake()
            phys:EnableDrag(false)
        end
        
        self:SetGravity(0.25)
        
        self.NextSpam = 0
        self.CactusType = self.CactusType or "normal"
        self.PlayerObj = self.PlayerObj or nil
        self.Trail = util.SpriteTrail(self, 0, Color(0, 255, 0), false, 16, 1, 2, 1/32, "trails/plasma.vmt")
    end
    
    function ENT:Spam()
        if self.PlayerObj then
            local aim = self.PlayerObj:GetAimVector()
            local v = aim * self.Speed * math.random(10, 25)
            self:ApplyMove(v)
        else
            local v = VectorRand() * self.Speed * math.random(8, 20)
            self:ApplyMove(v)
        end
    end
    
    -- Take damage
    function ENT:OnTakeDamage( dmginfo )
        self:TakePhysicsDamage( dmginfo )
	end
    
    -- Take damage when the cactus smashes into players
    function ENT:StartTouch( ent )
        if !self.PlayerObj then return end
        if ent:IsPlayer() and ent:Team() == TEAM_BLUE then
            local speed = self:GetVelocity():Length()
            local dmg = 50 + speed/10
            ent:TakeDamage( dmg, self.PlayerObj, self )
        end
    end
    
    function ENT:OnRemove()
        if IsValid(self.Trail) then SafeRemoveEntity(self.Trail) end
    end
    
    function ENT:Think()
        local ply = self.PlayerObj
        if not ply then 
            if self.NextSpam < CurTime() then
                self:Spam()
                self:EmitSound('cactus/cactus.mp3', 150, math.random(75, 150), 1, CHAN_VOICE)
                self.NextSpam = CurTime() + math.random(4, 12)
            end
            
            return 
        end
        
        local phys = self:GetPhysicsObject()
        if not phys or not phys:IsValid() then return end
        
        local aim = ply:GetAimVector()
        local ang = aim:Angle()
        ang.y = ang.y + 90
        
        local alt = util.QuickTrace(self:GetPos(), self:GetPos() + Vector(0, 0, -40000), {self} )
        alt = self:GetPos():Distance(alt.HitPos)
        local toohigh = false
        
        if alt > 1500 then
            phys:ApplyForceCenter( Vector(0, 0, -400 ) )
            toohigh = true
        end
        
        -- Spam!!
        if ply:KeyDown(IN_ATTACK) then
            if self.NextSpam < CurTime() then
                self:Spam()
                self.NextSpam = CurTime() + math.random(2, 4)
            end
        end
        
        -- Forward movement
        if ply:KeyDown(IN_FORWARD) then
            phys:ApplyForceCenter( aim * self.Speed )
        elseif ply:KeyDown(IN_BACK) then
            phys:ApplyForceCenter( aim * -self.Speed )
        end
        
        if ply:KeyDown(IN_JUMP) and not toohigh then
            phys:ApplyForceCenter( Vector(0, 0, 1) * self.Speed )
        end
        
        if ply:KeyDown(IN_MOVELEFT) then
            phys:ApplyForceCenter( ang:Forward() * self.Speed )
        elseif ply:KeyDown(IN_MOVERIGHT) then
            phys:ApplyForceCenter( ang:Forward() * -self.Speed )
        end
    end
    
    function ENT:ApplyMove(v)
        local phys = self:GetPhysicsObject()
        if not phys or !IsValid(phys) then return end
        
        phys:ApplyForceCenter( self:GetVelocity()*-1 + v )
    end
    
    function ENT:Taunt()
        if !self.LastTaunt then self.LastTaunt = 0 end
        if self.LastTaunt > CurTime() - 1 then
            self:EmitSound('cactus/cactus.mp3')
            self.LastTaunt = CurTime()
        end
    end

elseif CLIENT then
    ENT.Glow = Material("sprites/light_glow02_add")

    function ENT:Draw()
        self.Entity:DrawModel()
        local s = 60
        render.SetMaterial( self.Glow )
        render.DrawSprite( self:GetPos(), s, s, color_white)
    end
end