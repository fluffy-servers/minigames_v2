AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Give the player these weapons on loadout
function GM:PlayerLoadout(ply)
    ply:StripWeapons()
    ply:StripAmmo()
    ply:Give('mortar')
    ply:GiveAmmo(1000, 'RPG_Round')
end