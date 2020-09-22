MOD.Name = 'Harpoons'
MOD.Region = 'knockback'
MOD.Elimination = true
MOD.KillValue = 1

local function HarpoonTouch(ent, data)
    local touch = data.HitEntity
    if not ent.HarpoonOwner then return end

    if touch:IsPlayer() then
        if touch == ent.HarpoonOwner then return end
        -- Check for decent speed
        -- 'Thrown' harpoons can travel reasonably slowly
        -- 'Stabbed' harpoons need some speed
        local speed = data.OurOldVelocity:LengthSqr()
        if ent:IsPlayerHolding() and speed < 100000 then return end
        if not ent:IsPlayerHolding() and speed < 25000 then return end
        -- Apply the lethal damage with some insane knockback
        local d = DamageInfo()
        d:SetAttacker(ent.HarpoonOwner)
        d:SetInflictor(ent)
        d:SetDamage(500)
        d:SetDamageForce(data.OurOldVelocity * 500)
        d:SetDamageType(DMG_SLASH)
        touch:TakeDamageInfo(d)
    elseif touch:GetClass() == 'worldspawn' then
        -- Reset harpoons that get dropped onto the ground
        if not ent:IsPlayerHolding() then
            ent.HarpoonOwner = nil
            ent:SetColor(color_white)
        end
    end
end

local function spawnHarpoon(position)
    local ang = Angle(0, math.random(360), 0)
    local ent = ents.Create("prop_physics")
    ent:SetPos(position)
    ent:SetAngles(ang)
    ent:SetModel('models/props_junk/harpoon002a.mdl')
    ent:SetMaterial("models/debug/debugwhite")
    ent:Spawn()
    ent:GetPhysicsObject():SetMass(10)
    -- Add the damage callback
    ent:AddCallback("PhysicsCollide", HarpoonTouch)
end

function MOD:Initialize()
    GAMEMODE:Announce("Harpoons!", "Stab your enemies!")
    local number = GAMEMODE:PlayerScale(1, 3, 24) + math.random(1, 3)
    local position = GAMEMODE:GetRandomLocations(1, 'center')[1]

    -- Spawn some spiralling sorta upwards scattered in the center
    for i = 1, number do
        local radius = 100
        local pos = position + Vector(math.random(-radius, radius), math.random(-radius, radius), i * 32)
        spawnHarpoon(pos)
    end

    -- Spawn some fun ones in the edges too
    local number2 = GAMEMODE:PlayerScale(0.4, 2, 5) + math.random(1, 3)
    local positions = GAMEMODE:GetRandomLocations(number2, 'edge')

    for i = 1, number2 do
        spawnHarpoon(positions[i])
    end
end

function MOD:AllowPlayerPickup(ply, ent)
    if ent.HarpoonOwner and ent.HarpoonOwner ~= ply then return false end
    local pcolor = ply:GetPlayerColor()
    local color = Color(pcolor[1] * 255, pcolor[2] * 255, pcolor[3] * 255)
    ent.HarpoonOwner = ply
    ent:SetColor(color)

    return true
end