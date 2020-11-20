function EFFECT:Init(data)
    local vOffset = data:GetOrigin()
    local color = data:GetStart()
    sound.Play("garrysmod/balloon_pop_cute.wav", vOffset, 90, math.random(90, 120))
    local num = math.random(16, 24)
    local emitter = ParticleEmitter(vOffset, true)

    for i = 0, num do
        local pos = Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-1, 1))
        local darkness = math.Rand(0.8, 1.0)
        local particle = emitter:Add("particles/balloon_bit", vOffset + pos * 8)

        if particle then
            particle:SetVelocity(pos * 500)
            particle:SetLifeTime(0)
            particle:SetDieTime(3)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(255)
            particle:SetStartSize(math.Rand(1, 3))
            particle:SetEndSize(0)
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-2, 2))
            particle:SetAirResistance(100)
            particle:SetGravity(Vector(0, 0, -300))
            particle:SetColor(color.r * darkness, color.g * darkness, color.b * darkness)
            particle:SetCollide(true)
            particle:SetAngleVelocity(Angle(math.Rand(-160, 160), math.Rand(-160, 160), math.Rand(-160, 160)))
            particle:SetBounce(1)
            particle:SetLighting(true)
        end
    end

    emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end