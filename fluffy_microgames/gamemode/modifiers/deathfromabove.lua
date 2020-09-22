MOD.Name = "Death from Above"
MOD.SurviveValue = 1

local function spawnBarrels()
    local number = GAMEMODE:PlayerScale(0.4, 3, 6)
    local positions = GAMEMODE:GetRandomLocations(number, "sky")

    for i = 1, number do
        local pos = positions[i]
        local ent = ents.Create("prop_physics")
        ent:SetPos(pos)
        ent:SetAngles(AngleRand())
        ent:SetModel("models/props_c17/oildrum001_explosive.mdl")
        ent:Spawn()
        -- Add some downwards force to each barrel
        local vel = VectorRand() * math.random(800, 1200)
        vel.z = -math.abs(vel.z) * 0.1
        ent:GetPhysicsObject():SetVelocity(vel)
    end
end

function MOD:Initialize()
    spawnBarrels()
    GAMEMODE:Announce("Survive!")
end

function MOD:Loadout(ply)
    ply:Give("weapon_mg_pistol")
end

function MOD:EntityTakeDamage(ent, dmg)
    if not ent:IsPlayer() then return end
    if not dmg:IsExplosionDamage() then return true end
end

MOD.ThinkTime = 1

function MOD:Think()
    spawnBarrels()
end