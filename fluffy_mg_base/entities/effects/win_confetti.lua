function EFFECT:Init(data)
    local sounds = {"vo/coast/odessa/male01/nlo_cheer01.wav", "vo/coast/odessa/male01/nlo_cheer02.wav", "vo/coast/odessa/male01/nlo_cheer03.wav", "vo/coast/odessa/male01/nlo_cheer04.wav", "vo/coast/odessa/female01/nlo_cheer01.wav", "vo/coast/odessa/female01/nlo_cheer02.wav", "vo/coast/odessa/female01/nlo_cheer03.wav",}

    local pos = data:GetOrigin() + Vector(0, 0, 16)
    local color = data:GetStart()
    local num = 50
    local emitter = ParticleEmitter(pos, true)
    local material = Material("particles/balloon_bit")

    --sound.Play(table.Random(sounds), pos)
    for i = 0, num do
        local sp = 1.2
        local offset = Vector(math.Rand(-sp, sp), math.Rand(-sp, sp), math.Rand(3, 5))
        local color = HSVToColor(math.Rand(0, 360), math.Rand(0.6, 1), math.Rand(0.8, 1))
        local particle = emitter:Add(material, pos + offset)

        if false then
            color = Color(255, 255, 255)
        end

        if particle then
            particle:SetColor(color.r, color.g, color.b)
            particle:SetLifeTime(0)
            particle:SetDieTime(4)
            particle:SetStartSize(math.Rand(1.5, 3.75))
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-2, 2))
            local rm = 100
            particle:SetAngleVelocity(Angle(math.Rand(-rm, rm), math.Rand(-rm, rm), math.Rand(-rm, rm)))
            local vel = Vector(offset.x * 40, offset.y * 40, offset.z * 70)
            particle:SetVelocity(vel)
            particle:SetAirResistance(50)
            local gm = 50
            particle:SetGravity(Vector(math.Rand(-gm, gm), math.Rand(-gm, gm), -300))
            particle:SetCollide(true)
            particle:SetBounce(0.5)
        end
    end

    emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end