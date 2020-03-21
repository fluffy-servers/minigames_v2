MOD.Name = 'Death from Above'

local function spawnBarrels()
    local number = GAMEMODE:PlayerScale(0.3, 2, 5)
    local positions = GAMEMODE:GetRandomLocations(number, 'sky')

    for i=1,number do
        local pos = positions[i]
        local ent = ents.Create("prop_physics")
        ent:SetPos(pos)
        ent:SetAngles(AngleRand())
        ent:SetModel('models/props_c17/oildrum001_explosive.mdl')
        ent:Spawn()

        -- Add some downwards force to each barrel
        local vel = VectorRand() * math.random(400, 800)
        vel.z = -math.abs(vel.z)
        ent:GetPhysicsObject():SetVelocity(vel)
    end
end

function MOD:Initialize()
    spawnBarrels()
    GAMEMODE:Announce("Survive!")
end

function MOD:Loadout(ply)
    ply:Give('weapon_mg_pistol')
end

function MOD:EntityTakeDamage(ent, dmg)
    if not ent:IsPlayer() then return end
    if not dmg:IsExplosionDamage() then return true end
end

MOD.ThinkTime = 1.5
function MOD:Think()
    spawnBarrels()
end