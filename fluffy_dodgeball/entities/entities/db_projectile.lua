AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.InitialVelocity = 1250
ENT.NumBounces = 3
ENT.DieEffect = ""
ENT.Bounciness = 0.8
ENT.Damage = 100
ENT.BounceSound = Sound("Rubber.BulletImpact")
ENT.DieSound = Sound("physics/plastic/plastic_box_impact_hard1.wav")
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Material = Material("sprites/sent_ball")

function ENT:Initialize()
    -- Physics initialisation
    self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
    self:PhysicsInitSphere(16, "metal_bouncy")
    self:SetCollisionBounds(Vector(-16, -16, -16), Vector(16, 16, 16))
    -- Activate the physics object and apply force (if applicable)
    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()

        if self:GetOwner() and self:GetOwner():IsValid() then
            phys:ApplyForceCenter(self:GetOwner():GetAimVector() * self.InitialVelocity)
        end
    end
end

-- Play a sound effect on removal
function ENT:OnRemove()
    self:EmitSound(self.DieSound, 100, math.random(80, 115))
end

-- Bounce like crazy, keeping track of how many bounces have occured
function ENT:PhysicsCollide(data, phys)
    -- Play bounce sounds
    if data.Speed > 80 then
        self:EmitSound(self.BounceSound, 100, math.random(80, 115))
    end

    -- Damage players
    if IsValid(data.HitEntity) and data.HitEntity:IsPlayer() then
        if data.HitEntity:Team() ~= self:GetOwner():Team() then
            local damage = self:GetNWInt("Size", 25)
            data.HitEntity:TakeDamage(damage, self:GetOwner())

            timer.Simple(0, function()
                self:Remove()
            end)

            return
        end
    end

    -- Adjust velocity
    local last = math.max(data.OurOldVelocity:Length(), data.Speed)
    local new = phys:GetVelocity():GetNormalized()
    local target = new * last * self.Bounciness
    phys:SetVelocity(target)
    -- Remove ball after so many bounces
    self.NumBounces = self.NumBounces - 1

    if self.NumBounces <= 0 then
        timer.Simple(0, function()
            if IsValid(self) then
                self:Remove()
            end
        end)
    end
end

-- Render the ball sprite
function ENT:Draw()
    if not self.Color then
        if self:GetOwner() and self:GetOwner():IsValid() then
            self.Color = team.GetColor(self:GetOwner():Team())
        else
            self.Color = color_white
        end
    end

    local size = self:GetNWInt("Size", 25)
    render.SetMaterial(self.Material)
    render.DrawSprite(self:GetPos(), size, size, self.Color)
end