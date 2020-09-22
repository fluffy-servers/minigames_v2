--[[
    Ball pickup entity
    Heavily based off the default Sandbox ball entity
]]
--
AddCSLuaFile()

ENT.PrintName = "Ball"
ENT.MinSize = 24
ENT.MaxSize = 64
ENT.LifeTime = 15
ENT.BounceSound = Sound("garrysmod/balloon_pop_cute.wav")

-- Setup networked variables
function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "BallSize", {
        KeyName = "ballsize",
        Edit = {
            type = "Float",
            min = self.MinSize,
            max = self.MaxSize,
            order = 1
        }
    })

    self:NetworkVar("Vector", 0, "BallColor", {
        KeyName = "ballcolor",
        Edit = {
            type = "VectorColor",
            order = 2
        }
    })

    self:NetworkVarNotify("BallSize", self.OnBallSizeChanged)
end

-- Create the ball with spherical physics
function ENT:Initialize()
    if CLIENT then return end
    -- Approximate the ball with spherical physics
    self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
    self:RebuildPhysics()
    self:SetTrigger(true)

    -- Should be overriden in the gamemode
    self:SetBallColor(table.Random({Vector(1, 0.3, 0.3), Vector(0.3, 1, 0.3), Vector(1, 1, 0.3), Vector(0.2, 0.3, 1)}))

    -- Remove balls that have lived for too long
    timer.Simple(self.LifeTime, function()
        if IsValid(self) then
            self:Remove()
        end
    end)
end

-- Borrowed from Sandbox implementation
function ENT:RebuildPhysics(value)
    self.ConstraintSystem = nil
    local size = math.Clamp(value or self:GetBallSize(), self.MinSize, self.MaxSize) / 2.1
    self:PhysicsInitSphere(size, "metal_bouncy")
    self:SetCollisionBounds(Vector(-size, -size, -size), Vector(size, size, size))
    self:PhysWake()
end

function ENT:OnBallSizeChanged(varname, oldvalue, newvalue)
    if oldvalue == newvalue then return end
    self:RebuildPhysics(newvalue)
end

function ENT:PhysicsCollide(data, physobj)
    -- Play sound on bounce
    if data.Speed > 60 and data.DeltaTime > 0.2 then
        local pitch = 32 + 128 - math.Clamp(self:GetBallSize(), self.MinSize, self.MaxSize)
        sound.Play(self.BounceSound, self:GetPos(), 75, math.random(pitch - 10, pitch + 10), math.Clamp(data.Speed / 150, 0, 1))
    end

    -- Make the ball bouncier
    local LastSpeed = math.max(data.OurOldVelocity:Length(), data.Speed)
    local NewVelocity = physobj:GetVelocity()
    NewVelocity:Normalize()
    LastSpeed = math.max(NewVelocity:Length(), LastSpeed)
    local TargetVelocity = NewVelocity * LastSpeed * 0.9
    physobj:SetVelocity(TargetVelocity)
end

function ENT:OnTakeDamage(dmginfo)
    -- React physically when shot/getting blown
    self:TakePhysicsDamage(dmginfo)
end

function ENT:StartTouch(entity)
    if entity:IsPlayer() then
        self:Remove()
        GAMEMODE:CollectBall(entity)
    end
end

if SERVER then return end -- We do NOT want to execute anything below in this FILE on SERVER
local matBall = Material("sprites/sent_ball")

-- Render the ball as a 2D sprite
function ENT:Draw()
    render.SetMaterial(matBall)
    local pos = self:GetPos()
    local lcolor = render.ComputeLighting(pos, Vector(0, 0, 1))
    local c = self:GetBallColor()
    lcolor.x = c.r * (math.Clamp(lcolor.x, 0, 1) + 0.5) * 255
    lcolor.y = c.g * (math.Clamp(lcolor.y, 0, 1) + 0.5) * 255
    lcolor.z = c.b * (math.Clamp(lcolor.z, 0, 1) + 0.5) * 255
    local size = math.Clamp(self:GetBallSize(), self.MinSize, self.MaxSize)
    render.DrawSprite(pos, size, size, Color(lcolor.x, lcolor.y, lcolor.z, 255))
end