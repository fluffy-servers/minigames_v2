MOD.Name = 'Climb'
MOD.RoundTime = 10
MOD.Countdown = true

local function spawnProps()
    local number = GAMEMODE:PlayerScale(0.3, 3, 20)
    local positions = GAMEMODE:GetRandomLocations(number, 'sky')

    for i=1,number do
        local pos = positions[i]
        local ent = ents.Create("prop_physics")
        ent:SetPos(pos)
        ent:SetModel('models/props_c17/FurnitureWashingmachine001a.mdl')
        ent:Spawn()

        -- Add downwards velocity to scatter the props better
        local vel = VectorRand() * 1000
        vel.z = -math.abs(vel.z)
        ent:GetPhysicsObject():SetVelocity(vel)
    end
end

function MOD:Initialize()
    spawnProps()
    GAMEMODE:Announce("Climb", "Get on a prop!")
end

function MOD:Loadout(ply)
    ply:Give('weapon_crowbar')
end

function MOD:PlayerFinish(ply)
    local ground = ply:GetGroundEntity()
    if IsValid(ground) and ground:GetClass() == 'prop_physics' then
        ply:AddFrags(1)
    else
        ply:Kill()
    end
end

MOD.EntityTakeDamage = GM.CrowbarKnockback