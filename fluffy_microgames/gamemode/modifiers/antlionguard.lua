MOD.Name = 'Antlionguard 2: Electric Boogaloo'
MOD.Region = 'empty'

MOD.SurviveValue = 3

local function spawnAntlionGuard()
    local number = GAMEMODE:PlayerScale(0.75, 5, 16)
    local positions = GAMEMODE:GetRandomLocations(number, 'ground')

    for i=1,number do
        local pos = positions[i]
        local ent = ents.Create("npc_antlionguard") 
        ent:SetPos(pos)
        ent:Spawn()

    end
end

function MOD:Initialize()
    spawnAntlionGuard()
    GAMEMODE:Announce("Anybody got bugbait?")
end

function MOD:Loadout(ply)
    ply:SetMaxHealth(1)
    ply:SetHealth(1)
    ply:SetRunSpeed(225)
end
    
function MOD:EntityTakeDamage(ent, dmg)
    if not ent:IsPlayer() then return end
end