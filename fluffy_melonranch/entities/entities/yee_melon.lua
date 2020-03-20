AddCSLuaFile()
ENT.Type = 'anim'

function ENT:Initialize()
    if CLIENT then return end
    self:SetModel("models/props_junk/watermelon01.mdl")
    self:PrecacheGibs()
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    
    self:GetPhysicsObject():Wake()
    self:StartMotionController()
end

function ENT:GetPlayer()
    return self:GetNWEntity('player')
end

function ENT:SetPlayer(ply)
    return self:SetNWEntity('player', ply)
end

function ENT:Think()
    if CLIENT then return end
    if not IsValid(self:GetPlayer()) then self:Remove() return end
    
    self:GetPlayer():SetPos(self:GetPos())
end

function ENT:PhysicsSimulate(phys, deltatime)
    if not IsValid(self:GetPlayer()) then return SIM_NOTHING end
    
    local ply = self:GetPlayer()
    local move = Vector(0, 0, 0)
    local ang = ply:EyeAngles()
    if ply:KeyDown(IN_FORWARD) then move = move + ang:Forward() end
    if ply:KeyDown(IN_BACK) then move = move - ang:Forward() end
    if ply:KeyDown(IN_MOVELEFT) then move = move - ang:Right() end
    if ply:KeyDown(IN_MOVERIGHT) then move = move + ang:Right() end
    move.z = 0
    move:Normalize()
    move = move * 150000 * deltatime
    
    local maxboost = 50
    if ply:KeyDown(IN_ATTACK) then 
        move = move * (self.Boost or 10)
        self.Boost = (self.Boost or 0) - (deltatime*maxboost*10)
    else
        self.Boost = (self.Boost or 0) + (deltatime*maxboost*2)
    end
    
    self.Boost = math.Clamp(self.Boost, 0, maxboost)
    
    return Vector(0, 0, 0), move, SIM_GLOBAL_FORCE
end

function ENT:PhysicsCollide(data, physobj)
    if data.HitEntity and data.HitEntity:GetClass() == 'prop_physics' then
        data.HitEntity:Fire('break', '', 0)
        physobj:SetVelocity(data.OurOldVelocity)
        return
    elseif data.HitEntity and data.HitEntity:IsPlayer() and data.Speed > 50 then
        local damage = math.Clamp(data.Speed * 0.05, 5, 50)
        data.HitEntity:TakeDamage(damage, self:GetPlayer() or nil, self)
    end
    
    local speed = data.Speed
    if speed > 100 then
        self:EmitSound("physics/flesh/flesh_squishy_impact_hard"..math.random(1, 4)..".wav", 100, 100)
    end
end

function ENT:Destroy()
    if self.Broken then return end
    self.Broken = true
    
    if IsValid(self:GetPlayer()) and self:GetPlayer():Alive() then
        self:GetPlayer():Kill()
    end
    
    self:GibBreakClient(self:GetVelocity())
    timer.Simple(0.1, function() self:Remove() end)
end

function ENT:OnTakeDamage(dmginfo)
    local attacker = dmginfo:GetAttacker()
    if not attacker:IsPlayer() then return end
    
    self:Destroy()
end