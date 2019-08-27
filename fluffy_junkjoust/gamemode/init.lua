AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Give the player the gravity gun
function GM:PlayerLoadout(ply)
    ply:Give("weapon_physcannon")
end

-- Double damage
hook.Add('EntityTakeDamage', 'DoubleDamage', function(target, dmginfo)
    if target:IsPlayer() then
        dmginfo:ScaleDamage(2)
    end
end)