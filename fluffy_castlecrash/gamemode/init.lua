AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Give the player these weapons on loadout
function GM:PlayerLoadout( ply )
    ply:Give("weapon_crowbar")
    ply:Give("weapon_physcannon") -- for flag movement
end