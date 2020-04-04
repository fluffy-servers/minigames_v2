MOD.Name = 'Ambush'
MOD.Region = 'empty'

MOD.SurviveValue = 4

local function spawnRollermine()
    local number = GAMEMODE:PlayerScale(0.5, 10, 15)
    local positions = GAMEMODE:GetRandomLocations(number, 'ground')

    for i=1,number do
        local pos = positions[i] + Vector(0, 0, 32)
        local ent = ents.Create("npc_rollermine") 
        ent:SetPos(pos)
        ent:Spawn()
    end
end

local function spawnManhack()
    local number = GAMEMODE:PlayerScale(1, 10, 24)
    local positions = GAMEMODE:GetRandomLocations(number, 'sky')

    for i=1,number do
        local pos = positions[i]
        local ent = ents.Create("npc_manhack") 
        ent:SetPos(pos)
        ent:Spawn()
    end
end

local function spawnMetrocop()
    local number = GAMEMODE:PlayerScale(0.3, 1, 16)
    local positions = GAMEMODE:GetRandomLocations(number, 'ground')

    for i=1,number do
        local pos = positions[i]
        local metrocop = ents.Create("npc_metropolice")
        metrocop:SetPos(pos)
        metrocop:Spawn()
        metrocop:Give('weapon_stunstick')
    end
end

function MOD:Initialize()
    spawnRollermine()
    spawnManhack()
    spawnMetrocop()
    GAMEMODE:Announce("Combine!", "It's an ambush!")
end

function MOD:Loadout(ply)
    ply:SetMaxHealth(30)
    ply:SetHealth(30)
end
    
function MOD:EntityTakeDamage(ent, dmg)
    if not ent:IsPlayer() then return end
end