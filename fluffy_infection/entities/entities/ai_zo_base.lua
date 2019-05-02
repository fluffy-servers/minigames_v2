AddCSLuaFile()
ENT.Base = "base_ai"
ENT.Type = "ai"

ENT.ClawHit = {
    "npc/zombie/claw_strike1.wav",
    "npc/zombie/claw_strike2.wav",
    "npc/zombie/claw_strike3.wav"
}

ENT.ClawMiss = {
    "npc/zombie/claw_miss1.wav",
    "npc/zombie/claw_miss2.wav"
}

ENT.DoorHit = Sound("npc/zombie/zombie_hit.wav")

ENT.IdleTalk = 0
ENT.DoorTime = 0
ENT.VoiceTime = 0
ENT.RemoveTime = 0
ENT.RemovePos = Vector(0,0,0)
ENT.SearchRadius = 4000

function ENT:Initialize()
    if CLIENT then return end
    self:SetModel('models/zombie/classic.mdl')
    self:SetHullSizeNormal()
    self:SetHullType(HULL_HUMAN)
    
    self:SetSolid(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_STEP)
    self:CapabilitiesAdd(CAP_MOVE_GROUND)
    self:CapabilitiesAdd(CAP_INNATE_MELEE_ATTACK1)
    
    self:SetMaxYawSpeed(1000)
    self:SetHealth(100)
    self:DropToFloor()
    self:UpdateEnemy(self:FindEnemy())
end

function ENT:VoiceSound(tbl)
    if self.VoiceTime > CurTime() then return end
    self.VoiceTime = CurTime() + 1
    self:EmitSound(Sound(table.Random(tbl)), 100, math.random(85, 105))
end

function ENT:FindEnemy()
    local ents = ents.FindInSphere(self:GetPos(), self.SearchRadius)
    for k, v in pairs(ents) do
        if v:IsPlayer() then
            return v
        end
    end
    return nil
end

function ENT:UpdateEnemy(ent)
    if ent and ent:IsValid() and ent:Alive() then
        self:SetEnemy(ent, true)
        self:UpdateEnemyMemory(ent, ent:GetPos())
    else
        self:SetEnemy(NULL)
    end
end

function ENT:Think()
    if self.IdleTalk < CurTime() then
        --self:VoiceSound(self.VoiceSounds.Taunt)
        self.IdleTalk = CurTime() + math.random(10, 20)
    end
    
    if self.DoorTime < CurTime() then
        local door = self:NearDoor()
        if IsValid(door) then
        
        else
            local breakable = self:NearBreakable()
            if IsValid(breakable) then
                if breakable:GetClass() == 'func_breakable_surf' then
                    breakable:Fire('shatter', '1 1 1', 0)
                else
                    self:SetSchedule(SCHED_MELEE_ATTACK1)
                    breakable:TakeDamage(self.Damage, self)
                    self:EmitSound(self.DoorHit, 100, math.random(85, 115))
                end
            end
        end
    end
    
    if self.AttackTime and self.AttackTime < CurTime() then
        self.AttackTime = nil
        local enemy = self:GetEnemy()
        if enemy and enemy:IsValid() and enemy:GetPos():Distance(self:GetPos()) < 64 then
            enemy:TakeDamage(self.Damage, self)
            self:VoiceSound(self.ClawHit)
        else
            self:VoiceSound(self.ClawMiss)
        end
    end
end

function ENT:NearDoor()
    local doors = ents.FindInSphere(self:GetPos(), 50)
    for k,v in pairs(doors) do
        if string.find(v:GetClass(), "prop_door_") then
            return v
        end
    end
    
    return nil
end

local breakables = {}
breakables['func_breakable'] = true
breakables['func_physbox'] = true
breakables['prop_physics'] = true
breakables['prop_physics_multiplayer'] = true
breakables['func_breakable_surf'] = true

function ENT:NearBreakable()
    local doors = ents.FindInSphere(self:GetPos(), 50)
    for k,v in pairs(doors) do
        if breakables[v:GetClass()] then
            return v
        end
    end
    
    return nil
end

function ENT:GetRelationship(ent)
    if ent:IsPlayer() then return D_HT end
end

function ENT:SelectSchedule()
    local enemy = self:GetEnemy()
    local sched = SCHED_IDLE_WANDER
    
    if enemy and enemy:IsValid() then
        if self:HasCondition(23) then
            sched = SCHED_MELEE_ATTACK1
            self.AttackTime = CurTime() + 1
            --self:VoiceSound(self.VoiceSounds.Attack)
        else
            sched = SCHED_CHASE_ENEMY
        end
    else
        self:UpdateEnemy(self:FindEnemy())
    end
    
    self:SetPlaybackRate(5)
    self:SetSchedule(sched)
end