AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Only the big bad skeleton gets fists
function GM:PlayerLoadout(ply)
    ply:StripWeapons()
    
    if ply:Team() == TEAM_RED then
        ply:Give('weapon_fists')
        ply:SetRunSpeed(300)
        ply:SetWalkSpeed(300)
    else
        ply:SetRunSpeed(250)
        ply:SetWalkSpeed(225)
    end
end

-- Pick player models
function GM:PlayerSetModel( ply )
    if ply:Team() == TEAM_RED then
        ply:SetModel("models/player/skeleton.mdl")
        ply:SetSkin(math.random(0, 4))
    else
        GAMEMODE.BaseClass:PlayerSetModel(ply)
    end
end

-- Buff fists
hook.Add('EntityTakeDamage', 'BuffFists', function(target, dmg)
    local wep = dmg:GetInflictor()
    if wep:GetClass() == 'player' then wep = wep:GetActiveWeapon() end
    if wep:GetClass() == 'weapon_fists' then
        dmg:ScaleDamage(20)
        dmg:SetDamageForce(dmg:GetDamageForce()*50)
    end
end)