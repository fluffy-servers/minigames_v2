AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Give the player the gravity gun
function GM:PlayerLoadout(ply)
    ply:Give("weapon_physcannon")
end