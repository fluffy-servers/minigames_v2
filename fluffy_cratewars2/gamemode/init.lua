AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

function GM:PlayerLoadout( ply )
    ply:StripAmmo()
    ply:StripWeapons()
    ply:Give("weapon_crowbar")
end