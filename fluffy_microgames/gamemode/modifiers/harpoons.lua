MOD.Name = 'Harpoons'
MOD.Region = 'knockback'
MOD.Elimination = true

MOD.KillValue = 1

local function HarpoonTouch(ent, data)
    local touch = data.HitEntity
    if not touch:IsPlayer() then return end

    if not ent.HarpoonOwner then return end
    if touch == ent.HarpoonOwner then return end

    local d = DamageInfo()
    d:SetAttacker(ent.HarpoonOwner)
    d:SetInflictor(ent)
    d:SetDamage(500)
    d:SetDamageForce(data.OurOldVelocity * 500)
    d:SetDamageType(DMG_SLASH)
    touch:TakeDamageInfo(d)
end

function MOD:Initialize()
    GAMEMODE:Announce("Harpoons!", "Stab your enemies!")
    local number = GAMEMODE:PlayerScale(1, 3, 24) + math.random(1, 3)
    local positions = GAMEMODE:GetRandomLocations(1, 'center')

    for i=1,number do
        local pos = positions[1] + Vector(0, 0, i*32)
        local ang = Angle(0, math.random(360), 0)
        local ent = ents.Create("prop_physics")
        ent:SetPos(pos)
        ent:SetAngles(ang)
        ent:SetModel('models/props_junk/harpoon002a.mdl')
        ent:Spawn()

        ent:GetPhysicsObject():SetMass(10)

        -- Add the damage callback
        ent:AddCallback("PhysicsCollide", HarpoonTouch)
    end
end

function GM:AllowPlayerPickup(ply, ent)
    if ent.HarpoonOwner and ent.HarpoonOwner != ply then return false end

    ent.HarpoonOwner = ply
    return true
end

GM.ThinkTime = 1
function GM:Think()
    for k,v in pairs(ents.FindByClass('prop_physics')) do
        if not v:IsPlayerHolding() then
            v.HarpoonOwner = nil
        end
    end
end