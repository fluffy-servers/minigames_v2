MOD.Name = 'Climb'
MOD.RoundTime = 10
MOD.Countdown = true

MOD.SurviveValue = 1

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
        ply:AwardWin()
    else
        ply:Kill()
    end
end

function MOD:EntityTakeDamage(ent, dmg)
    if not ent:IsPlayer() then return end
    if not dmg:GetAttacker():IsPlayer() then return true end
    
    dmg:SetDamage(0)
    local v = dmg:GetDamageForce():GetNormalized()
    v.z = math.max(math.abs(v.z) * 0.5, 0.0025)
    ent:SetGroundEntity(nil)
    ent:SetVelocity(v * 800)
end