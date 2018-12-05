AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
AddCSLuaFile('balls.lua')

include('shared.lua')
include('ply_extension.lua')

-- Give the player these weapons on loadout
function GM:PlayerLoadout( ply )
    ply:StripWeapons()
    ply:StripAmmo()
end