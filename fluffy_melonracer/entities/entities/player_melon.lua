AddCSLuaFile()
ENT.Type = 'anim'

function ENT:Initialize()
    if CLIENT then return end
    self:SetModel("models/props_junk/watermelon01.mdl")
    self:PrecacheGibs()
    self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
    
    self:GetPhysicsObject():Wake()
    self:StartMotionController()
    
    self.Jump = 0
end

function ENT:GetPlayer()
    return self:GetNWEntity('player')
end

function ENT:SetPlayer(ply)
    self:SetNWEntity('player', ply)
end

function ENT:Think()
    if CLIENT then return end
    if !IsValid(self:GetPlayer()) then self:Remove() return end
    
    self.Jump = math.Approach(self.Jump, 1, 0.1)
    self:GetPlayer():SetPos(self:GetPos())
end

function ENT:PhysicsSimulate(phys, deltatime)
    if !IsValid(self:GetPlayer()) then return SIM_NOTHING end
    
    local ply = self:GetPlayer()
    local move = Vector(0, 0, 0)
    local ang = ply:EyeAngles()
    
    
    if ply:KeyDown(IN_FORWARD) then move = move + ang:Forward() end
    if ply:KeyDown(IN_BACK) then move = move - ang:Forward() end
    if ply:KeyDown(IN_MOVELEFT) then move = move - ang:Right() end
    if ply:KeyDown(IN_MOVERIGHT) then move = move + ang:Right() end
    move.z = 0
    move:Normalize()
    move = move * 200000 * deltatime
    
    if ply:KeyDown(IN_JUMP) then
        local speed = Vector(0, 0, 6000) * deltatime
        self.Jump = math.Approach(self.Jump, 0, speed.z * 0.001)
        phys:AddVelocity(speed * self.Jump)
    end
    
    return Vector(0, 0, 0), move, SIM_GLOBAL_FORCE
end

function ENT:PhysicsCollide(data, physobj)
    if data.HitEntity and data.HitEntity:GetClass() == 'prop_physics' then
        data.HitEntity:Fire('break', '', 0)
        physobj:SetVelocity( data.OurOldVelocity )
        return
    end
    
    local dot = data.OurOldVelocity:GetNormalized()
    dot = dot:Dot(data.HitNormal)
    local speed = data.Speed * dot
    
    if speed > 100 then
        self:EmitSound("physics/flesh/flesh_squishy_impact_hard"..math.random(1, 4)..".wav", 100, 100)
    end
    
    if speed > 400 then
        if IsValid(self:GetPlayer()) then
            self:GetPlayer():Kill()
        end
        self:GibBreakClient(data.OurOldVelocity)
        timer.Simple(0.1, function() self:Remove() end)
    end
end