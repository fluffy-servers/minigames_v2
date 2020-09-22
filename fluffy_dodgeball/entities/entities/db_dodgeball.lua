AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RespawnTime = 10
ENT.LastTime = -1
ENT.MaxBounces = 4
ENT.Size = 28
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- Initialize the ball as a basic sphere
function ENT:Initialize()
    if CLIENT then return end
    self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")

    local hsize = self.Size / 2
    self:PhysicsInitSphere(hsize, "metal_bouncy")
    self:SetCollisionBounds(Vector(-hsize, -hsize, -hsize), Vector(hsize, hsize, hsize))
    self:PhysWake()

    self.CurrentBounces = 0
    self.LastTime = CurTime()
end

-- Destroy the ball if damaged by trigger_hurt entities, otherwise apply physics damage
function ENT:OnTakeDamage(dmg)
    -- Remove if in contact with a trigger hurt
    if dmg:GetInflictor():GetClass() == "trigger_hurt" or dmg:GetAttacker():GetClass() == "trigger_hurt" then
        self:Remove()

        return
    end

    -- Physically react to the damage
    self:TakePhysicsDamage(dmg)
end

-- Respawn the ball when removed
function ENT:OnRemove()
    -- if anything happens to the ball, spawn a new one
    if CLIENT then return end
    -- GAMEMODE:SpawnBall()
end

-- Respawn balls if not touched for a long time
function ENT:Think()
    if self.LastTime == -1 then return end

    if CurTime() > self.LastTime + self.RespawnTime then
        self:Remove()
    end
end

-- Custom physics movement
function ENT:PhysicsUpdate(phys)
    vel = Vector(0, 0, -9.81 * phys:GetMass() * 0.65)
    phys:ApplyForceCenter(vel)
end

-- Custom physics bouncing
function ENT:PhysicsCollide(data, physobj)
    -- Damage checks for player damage
    -- Verify the speed is fine
    -- Make sure teamkilling is disallowed
    if data.HitEntity:IsPlayer() and data.Speed > 80 then
        local ply = data.HitEntity

        if (self:GetNWString("CurrentTeam") == "blue" and ply:Team() == TEAM_RED) or (self:GetNWString("CurrentTeam") == "red" and ply:Team() == TEAM_BLUE) then
            local info = DamageInfo()
            info:SetDamage(data.Speed)
            info:SetDamageType(DMG_DISSOLVE)
            info:SetAttacker(self.LastHolder or self)
            info:SetInflictor(self)
            ply:TakeDamageInfo(info)
        end
    end

    -- Balls can only bounce a handful of times before resetting
    self.CurrentBounces = self.CurrentBounces + 1

    if self.CurrentBounces > self.MaxBounces then
        self:ResetTracer()
        self:SetNWString("CurrentTeam", nil)
        self:SetNWVector("RColor", Vector(1, 1, 1))
        self.CurrentBounces = 0
    end

    -- Play sounds or explode
    if data.Speed > 250 and self.Explosive then
        self:Remove()
    elseif data.Speed > 70 then
        self:EmitSound("Rubber.BulletImpact")
    end

    -- Bouncing code
    -- Stolen from the Sandbox ball
    local LastSpeed = math.max(data.OurOldVelocity:Length(), data.Speed)
    local NewVelocity = physobj:GetVelocity()
    NewVelocity:Normalize()
    LastSpeed = math.max(NewVelocity:Length(), LastSpeed)
    local TargetVelocity = NewVelocity * LastSpeed * 0.8
    physobj:SetVelocity(TargetVelocity)
end

function ENT:MakeTracer(ply)
    if IsValid(self.tracer) then
        self:ResetTracer()
    end

    -- Make a new tracer
    local tracer = ents.Create("db_tracer")
    tracer:SetMoveType(MOVETYPE_NONE)
    tracer:SetPos(self:GetPos())
    tracer:SetParent(self)
    tracer:BuildTracer(team.GetColor(ply:Team()))
    tracer:Spawn()
    self.tracer = tracer
end

function ENT:ResetTracer()
    if IsValid(self.tracer) then
        local tracer = self.tracer
        tracer:SetParent(nil)
        -- Cool little spark effect for the end of the trail
        local effect = EffectData()
        effect:SetOrigin(self:GetPos())
        effect:SetStart(self:GetNWVector("RColor", Vector(1, 1, 1)))
        util.Effect("db_spark", effect)

        timer.Simple(3, function()
            if IsValid(tracer) then
                SafeRemoveEntity(tracer)
            end
        end)

        self.tracer = nil
    end
end

if CLIENT then
    killicon.AddFont("db_dodgeball", "HL2MPTypeDeath", "8", Color(255, 80, 0, 255))
    local ball_mat = Material("sprites/sent_ball")

    -- Render the ball as a 2D sprite
    function ENT:Draw()
        render.SetMaterial(ball_mat)
        local pos = self:GetPos()
        local lcolor = render.ComputeLighting(pos, Vector(0, 0, 1))
        local c = self:GetNWVector("RColor", Vector(1, 1, 1))
        lcolor.x = c.r * (math.Clamp(lcolor.x, 0, 1) + 0.5) * 255
        lcolor.y = c.g * (math.Clamp(lcolor.y, 0, 1) + 0.5) * 255
        lcolor.z = c.b * (math.Clamp(lcolor.z, 0, 1) + 0.5) * 255
        local size = self.Size
        render.DrawSprite(pos, size, size, Color(lcolor.x, lcolor.y, lcolor.z, 225))
    end
end