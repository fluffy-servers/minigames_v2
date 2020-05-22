MOD.Name = 'Propkillers'

MOD.Elimination = true
MOD.KillValue = 1

local prop_list = {
    "models/props_junk/sawblade001a.mdl",
    "models/props_junk/watermelon01.mdl",
}

local function spawnProps()
    local number1 = GAMEMODE:PlayerScale(0.4, 4, 8)
    local positions1 = GAMEMODE:GetRandomLocations(number1, 'ground')

    for i=1,number1 do
        local ent = ents.Create("prop_physics")
        ent:SetModel(table.Random(prop_list))
        ent:SetPos(positions1[i] + Vector(0, 0, 16))
        ent:SetAngles(AngleRand())
        ent:Spawn()
    end

    local number2 = GAMEMODE:PlayerScale(0.7, 8, 14)
    local positions2 = GAMEMODE:GetRandomLocations(number2, 'crate')

    for i=1,number2 do
        local ent = ents.Create("prop_physics")
        ent:SetModel(table.Random(prop_list))
        ent:SetPos(positions2[i]+ Vector(0, 0, 16))
        ent:SetAngles(AngleRand())
        ent:Spawn()
    end
end

function MOD:Initialize()
    spawnProps()
    GAMEMODE:Announce("Prop Kill!")
end

function MOD:Loadout(ply)
    ply:Give('weapon_physcannon')
end