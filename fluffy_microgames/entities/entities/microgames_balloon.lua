AddCSLuaFile()

ENT.Type = "anim"

-- Balloon properties
ENT.PrintName = "Balloon"
ENT.Model = "models/maxofs2d/balloon_classic.mdl"
ENT.Points = 1
ENT.SpeedMin = 20
ENT.SpeedMax = 30
ENT.Balloon = true

ENT.BalloonTypes = {
    classic = {
        points = 1,
        minspeed = 20,
        maxspeed = 30,
        model = "models/maxofs2d/balloon_classic.mdl"
    },

    heart = {
        points = 1,
        minspeed = 20,
        maxspeed = 30,
        model = "models/maxofs2d/balloon_classic.mdl"
    },

    star = {
        points = 1,
        minspeed = 20,
        maxspeed = 30,
        model = "models/maxofs2d/balloon_classic.mdl"
    }
}

-- Create the balloon
function ENT:Initialize()
    -- Select the type of balloon
    local r = util.SharedRandom("BalloonTypeRandom", 0, 1, self:EntIndex())
    local bType = 'classic'
    if r < 0.1 then
        btype = 'star'
    elseif r < 0.25 then
        btype = 'heart'
    end

    -- Load balloon properties
    local bTable = self.BalloonTypes[btype]
    self.Speed = util.SharedRandom("BalloonSpeedRandom", bTable.minspeed, bTable.maxspeed, self:EntIndex())
    self.Points = bTable.points
    self:SetModel(bTable.model)
    self:SetColor(HSVToColor(math.random(360), 1, 1))
    self:SetRenderMode(RENDERMODE_TRANSALPHA)

    -- Create physics object
    self:PhysicsInit(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetMass(100)
        phys:Wake()
        phys:EnableGravity(false)
    end
    self:StartMotionController()

    -- Add a little bit of sideways velocity
    local xx = util.SharedRandom("BalloonXRandom", -1, 1, self:EntIndex())
    local yy = util.SharedRandom("BalloonYRandom", -1, 1, self:EntIndex())
    self.SideMotion = Vector(xx, yy, 0) * self.Speed
end

-- Pop the balloon if we hit the world
function ENT:PhysicsCollide(data, phys)
    if data.HitEntity == game.GetWorld() then
        -- Balloon prop effect
        local c = self:GetColor()
        local ed = EffectData()
        ed:SetOrigin(self:GetPos())
        ed:SetStart(Vector(c.r, c.g, c.b))
        util.Effect("balloon_pop", ed)

        self:Remove()
    end
end

-- Handle balloon popping effects
function ENT:OnTakeDamage(dmginfo)
    -- Balloon prop effect
    local c = self:GetColor()
    local ed = EffectData()
    ed:SetOrigin(self:GetPos())
    ed:SetStart(Vector(c.r, c.g, c.b))
    util.Effect("balloon_pop", ed)

    -- Register this with the gamemode
    local attacker = dmginfo:GetAttacker()
    if IsValid(attacker) and attacker:IsPlayer() then
        hook.Run("PropBreak", attacker, self)
    end
    self:Remove()
end

-- Make the balloon physically float upwards
function ENT:PhysicsSimulate(phys, delta)
    local vLinear = Vector(0, 0, (self.Speed or 5) * 5000 * delta) + (self.SideMotion * 500 * delta)
    local vAngular = Vector(0, 0, 0)

    return vAngular, vLinear, SIM_GLOBAL_FORCE
end