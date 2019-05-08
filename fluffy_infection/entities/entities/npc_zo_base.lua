AddCSLuaFile()
ENT.Base = 'base_nextbot'

if CLIENT then
    language.Add('npc_zo_base', 'Basic Zombie' )
end

-- Speed
ENT.Speed = 200
ENT.WalkSpeedAnimation = 2
ENT.Acceleration = 25
ENT.MoveType = 1

-- Health & Other
ENT.BaseHealth = 100
ENT.Damage = 15
ENT.ModelScale = 1

-- Other Behaviour
ENT.SearchRadius = 2000
ENT.LoseTargetDistance = 4000

-- Collisons
ENT.CollisionHeight = 64
ENT.CollisionSide = 7

-- Attack
ENT.AttackRange = 60
ENT.NextAttack = 1.3

-- Model & Animations
ENT.Model = "models/player/zombie_classic.mdl"
ENT.AttackAnim = (ACT_GMOD_GESTURE_RANGE_ZOMBIE)
ENT.WalkAnim = (ACT_HL2MP_WALK_ZOMBIE_01) -- { (ACT_HL2MP_RUN_ZOMBIE), (ACT_HL2MP_WALK_ZOMBIE_03) }
ENT.FlinchAnim = (ACT_HL2MP_ZOMBIE_SLUMP_RISE)
ENT.AttackDoorAnim = (ACT_GMOD_GESTURE_RANGE_ZOMBIE)

-- Sound
ENT.AttackSounds = { 
    Sound("npc/zombie/zo_attack1.wav"), 
    Sound("npc/zombie/zo_attack2.wav") 
}

ENT.AlertSounds = { 
    Sound("npc/zombie/zombie_alert1.wav"), 
    Sound("npc/zombie/zombie_alert2.wav"), 
    Sound("npc/zombie/zombie_alert3.wav") 
}

ENT.DeathSounds = { 
    Sound("npc/zombie/zombie_die1.wav"), 
    Sound("npc/zombie/zombie_die2.wav"), 
    Sound("npc/zombie/zombie_die3.wav") 
}

ENT.IdleSounds = { 
    Sound("npc/zombie/zombie_voice_idle1.wav"), 
    Sound("npc/zombie/zombie_voice_idle2.wav"), 
    Sound("npc/zombie/zombie_voice_idle3.wav"), 
    Sound("npc/zombie/zombie_voice_idle4.wav"), 
    Sound("npc/zombie/zombie_voice_idle5.wav") 
}

ENT.PainSounds = {
    Sound("npc/zombie/zombie_pain1.wav"),
    Sound("npc/zombie/zombie_pain2.wav"),
    Sound("npc/zombie/zombie_pain3.wav"),
    Sound("npc/zombie/zombie_pain4.wav"),
    Sound("npc/zombie/zombie_pain5.wav")
}

-- More sound
ENT.HitSound = Sound("npc/zombie/claw_strike1.wav")
ENT.Miss = Sound("npc/zombie/claw_miss1.wav")
ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetHealth(self.BaseHealth)
    self:CollisionSetup(self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER)
    self:SetModelScale(self.ModelScale or 1)
    
    if self.BoldColor then self:SetColor(self.BoldColor) end
    
    if CLIENT then return end
    self.loco:SetDesiredSpeed(self.Speed)
    self.loco:SetAcceleration(self.Acceleration)
    self.loco:SetDeceleration(self.Acceleration * 8)
    self:SetMaxHealth(self.BaseHealth) -- idk why this isn't clientside but hey, not my fault
end

-- Create the collisions for this entity
function ENT:CollisionSetup(side, height, group)
    self:SetCollisionGroup(group)
    self:SetCollisionBounds(Vector(-side, -side, 0), Vector(side, side, height))
    self:PhysicsInitShadow(true, false)
    self.NEXTBOT = true
end

-- Color the playermodel if set
function ENT:GetPlayerColor()
    if not self.Color then return end
    local c = self.Color
    return Vector(c.r/255, c.g/255, c.b/255)
end

-- Useful function to set up movement animations
function ENT:MovementFunctions(type, act, speed, rate)
    if type == 1 then
        self:StartActivity(act)
    else
        self:ResetSequence(act)
        self:SetPlaybackRate(rate)
    end
    
    self:SetPoseParameter('move_x', rate)
end

function ENT:DefaultMovement()
    self:MovementFunctions(self.MoveType, self.WalkAnim, self.Speed, self.WalkSpeedAnimation)
end

-- Useful functions to track the current enemy
function ENT:SetEnemy(ent)
    self.Enemy = ent
end

function ENT:GetEnemy(ent)
    return self.Enemy
end

-- Check if we currently have an enemy, if not, find one
function ENT:HaveEnemy()
    if self:GetEnemy() and IsValid(self:GetEnemy()) then
        -- Find new enemy if target is dead or out of range
        if self:GetRangeTo(self:GetEnemy():GetPos()) > self.LoseTargetDistance then
            return self:FindEnemy()
        elseif self:GetEnemy():IsPlayer() and not self:GetEnemy():Alive() then
            return self:FindEnemy()
        end
        
        return true
    else
        -- Search for a new enemy
        return self:FindEnemy()
    end
end

-- Search for a new enemy for this NPC
function ENT:FindEnemy()
    local players = team.GetPlayers(TEAM_BLUE)
    local distances = {}
    
    -- Get how far away every living player is
    for k,v in pairs(players) do
        if v.Spectating then continue end
        table.insert(distances, {v, self:GetPos():DistToSqr(v:GetPos())})
    end
    
    -- Sort players based on distance
    if distances and #distances >= 1 then
        table.sort(distances, function(a, b) return a[2] < b[2] end)
    else
        self:SetEnemy(nil)
        return false
    end
    
    -- Target the closest player
    self:SetEnemy(distances[1][1])
    return true
end

function ENT:DistanceToEnemy(enemy)
    -- Return the distance to a given enemy
    -- This is inefficent! See the below functon
    local enemy = enemy or self:GetEnemy()
    return self:GetPos():Distance(enemy:GetPos())
end

function ENT:DistSqrToEnemy(enemy)
    -- More efficient distance check
    local enemy = enemy or self:GetEnemy()
    return self:GetPos():DistToSqr(enemy:GetPos())
end

-- Determine what activities to do
function ENT:RunBehaviour()
    while true do
        if self:HaveEnemy() then
            local enemy = self:GetEnemy()
            local pos = enemy:GetPos()
            if pos then
                if enemy:IsValid() and enemy:Health() > 0 then
                    self:ChaseEnemy()
                else
                    self:SetEnemy(nil)
                    self:FindEnemy()
                end
            end
        else
            self:Idle()
            self:FindEnemy()
        end
        coroutine.yield()
    end
end

-- hi my name is zombie i'm lazy
function ENT:Idle()
    self:MovementFunctions(1, self.WalkAnim, 0, 1)
    self:MoveToPos(self:GetPos() + Vector(math.random(-512, 512), math.random(-512, 512), 0), {repath=3, maxage=5})
end

-- Chase down the enemy!
function ENT:ChaseEnemy()
    local enemy = self:GetEnemy()
    local pos = enemy:GetPos()
    self:MovementFunctions(1, self.WalkAnim, 0, 1)
    
    -- Pathing stuff?
    local path = Path('Follow')
    path:SetMinLookAheadDistance(300)
    path:SetGoalTolerance(20)
    local result = path:Compute(self, pos)
    
    while path:IsValid() and self:HaveEnemy() do
        -- Keep the path updated
        if path:GetAge() > 1 then
            path:Compute(self, self:GetEnemy():GetPos())
        end
        path:Update(self)
        --path:Draw()
        
        -- Ensure we are not stuck
        if self.loco:IsStuck() then
            self:CheckTrace()
            return false
        end
        
        -- Idle sounds if approaching an enemy
        if enemy and enemy:IsValid() and enemy:Health() > 0 then
            if math.random() > 0.995 and not self.IsAttacking then
                if self:DistanceToEnemy() < 600 then
                    self:IdleSound()
                end
            end
        end
        
        -- Check the enemy every so often
        if math.random() > 0.5 then
            self:FindEnemy()
        end
        
        self:CheckTrace()
        coroutine.yield()
    end
    
    return true
end

-- Check if the zombie is close enough to attack the enemy
function ENT:CheckRange(enemy)
    local distance = self:DistanceToEnemy(enemy)
    
    if self:HaveEnemy() and self:GetEnemy():Alive() then
        if distance < self.AttackRange then
            self:Attack()
        end
    end
end

-- Handles when the zombie is injured
function ENT:OnInjured(info)
    if not self:HaveEnemy() then return end
    if info:GetAttacker() == self:GetEnemy() then return end
    
    -- If the person that hurt the zombie is closer than our current enemy
    -- then target the person that attacked us instead
    -- This could probably be abused in some way so might need some reworking but it works quite well
    if info:GetAttacker():IsPlayer() then
        local attacker = info:GetAttacker()
        if self:GetPos():DistToSqr(attacker:GetPos()) < self:GetPos():DistToSqr(self:GetEnemy():GetPos()) then
            self:SetEnemy(attacker)
        end
    end
end

-- Called when the zombie is killed
function ENT:OnKilled(info)
    hook.Run('OnNPCKilled', self, info:GetAttacker(), info:GetInflictor()) -- Run the hook
    
    -- Create the ragdoll then remove after 5 seconds
    local ragdoll = self:BecomeRagdoll(info)
    timer.Simple(5, function()
        if IsValid(ragdoll) then
            ragdoll:Remove()
        end
    end)
end

-- Perform a trace to do attacking stuff
function ENT:CheckTrace()
    if (self.NextAttackTime or 0) > CurTime() then return end
    
    local mins = self:OBBMins()
    local maxs = self:OBBMaxs()
    
    -- Perform a hull trace about the size of ourselves
    -- This should reasonably accurately check for obstructions
    -- allowing the zombie to deal with them quite easily
    local tr = util.TraceHull({
        mins = mins,
        maxs = maxs,
        start = self:GetPos(),
        endpos = self:GetPos() + self:GetForward()*24,
        filter = self
    })
    
    -- Attack anything that stands in our way
    -- Seperates this into seperate functions based on entity data
    if not tr.Hit or tr.HitWorld then return false end
    local ent = tr.Entity
    if ent:IsPlayer() then
        self:AttackPlayer(ent)
    elseif string.find(ent:GetClass(), 'prop_door_') then
        self:AttackDoor(ent)
    elseif ent:GetClass() == 'func_breakable' then
        self:AttackObject(ent)
    elseif ent:GetClass() == 'prop_physics' then
        self:AttackObject(ent)
    elseif ent:GetClass() == 'func_breakable_surf' then
        self:AttackWindow(ent)
    end
end

-- Attack function for player entities
function ENT:AttackPlayer(ent)
    if not IsValid(ent) then return end
    
    -- Slightly different code for our enemy vs. players that get in our way
    if ent == self:GetEnemy() then
        self:AttackSound()
        self.IsAttacking = true
        self:RestartGesture(self.AttackAnim)
        self:AttackEffect(0.9, self.Enemy, self.Damage, 0)
    else
        -- Basic attack sound and effect
        self:AttackSound()
        self:AttackEffect(0.9, ent, self.Damage, 0)
    end
    
    -- Attack cooldown
    self.NextAttackTime = CurTime() + self.NextAttack
end

-- Attack function for prop_door_rotating entities
function ENT:AttackDoor(v)
    if not IsValid(v) then return end
    
    -- Assign health to doors
    if v.DoorHealth == nil then
        v.DoorHealth = math.random(50, 100)
    end
    
    if v.DoorHealth > 0 then
        -- Deal damage to the door with a basic attack
        self:AttackSound()
        self:RestartGesture(self.AttackAnim)  
        self:AttackEffect(0.9, v, self.Damage, 2)
        v:EmitSound(self.DoorBreak)
        v.DoorHealth = v.DoorHealth - self.Damage
    else
        -- Break the door off the hinges
        -- This creates a prop_physics that imitates the door
        local door = ents.Create("prop_physics")
        if not door then return end
        door:SetModel(v:GetModel())
        door:SetPos(v:GetPos())
        door:SetAngles(v:GetAngles())
        door:SetSkin(v:GetSkin())
		door:SetColor(v:GetColor())
        door:Spawn()
        door:EmitSound("Wood_Plank.Break")
        door:SetCollisionGroup(COLLISION_GROUP_DEBRIS) -- stop collisions
        door.FakeProp = true
        
        -- Send the door flying
        local phys = door:GetPhysicsObject()
        if phys:IsValid() then phys:ApplyForceCenter(self:GetForward():GetNormalized()*20000 + Vector(0, 0, 2)) end
        SafeRemoveEntity(v)
    end
    
    -- Attack cooldown
    self.NextAttackTime = CurTime() + self.NextAttack
end

-- Generic attack function
function ENT:AttackObject(v)
    if not IsValid(v) then return end
    if v.FakeProp then return end
    
    -- Basic attack stuff
    self:AttackSound()
    self:RestartGesture(self.AttackAnim)  
    self:AttackEffect(0.9, v, self.Damage, 1)
    v:EmitSound(self.DoorBreak)
    self.NextAttackTime = CurTime() + self.NextAttack
    
    if v:Health() > 0 then
        -- Deal health damage to the entity
        v.Damaged = true
        v:SetHealth(v:Health() - self.Damage)
    else
        if !v.Damaged then
            -- ?
            v.Damaged = true
            v:SetHealth(50)
        else
            -- Break the entity into gibs
            v:GibBreakClient(Vector(0, 0, 0))
            v:Remove()
        end
    end
end

-- Attack function for breakable windows
function ENT:AttackWindow(ent)
    -- func_breakable_surf should be shattered
    ent:Fire('shatter', '1 1 1', 0)
end

-- Basic attack effects - shared between the above functions
function ENT:AttackEffect(time, ent, dmg, type)
    timer.Simple(time, function()
        if not self:IsValid() then return end
        if self:Health() < 0 then return end
        
        if not ent:IsValid() then return end
        if self:DistanceToEnemy(ent) < self.AttackRange then
            -- Apply damage
            ent:TakeDamage(self.Damage, self)
            
            -- Emit the player damage sound for living things
            if ent:IsPlayer() or ent:IsNPC() then
                self:EmitSound(self.HitSound)
            end
            
            -- View punch the player
            if ent:IsPlayer() then
                ent:ViewPunch(Angle(math.random(-1, 1)*self.Damage*0.1, math.random(-1, 1)*self.Damage*0.1, math.random(-1, 1)*self.Damage*0.1))
            end
        else
            -- Missed! Play a miss sound effect
            self:EmitSound(self.Miss)
        end
    end)
    
    -- Reset the attacking after half a second delay
    timer.Simple(time + 0.5, function()
        if not self:IsValid() then return end
        self.IsAttacking = false
    end)
end

-- Sound functions
function ENT:PlaySound(sound)
    -- Emit a given sound with variance to pitch
    if type(sound) == 'table' then sound = sound[1] end
    self:EmitSound(sound, 100, math.Rand(80, 150) )
end

function ENT:AttackSound()
    -- Play an attack sound
    self:PlaySound(table.Random(self.AttackSounds))
end

function ENT:IdleSound()
    -- Play an idle sound
    self:PlaySound(table.Random(self.IdleSounds))
end

function ENT:DamageSound()
    -- Play a damage sound
    self:PlaySound(table.Random(self.PainSounds))
end

function ENT:AlertSound()
    -- Play alert sound
    self:PlaySound(table.Random(self.AlertSounds))
end