-- Send the required files to clients & include shared
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function GM:PlayerLoadout(ply)
    ply:StripWeapons()
    ply:StripAmmo()

    ply:Give('weapon_crowbar')

    ply:SetRunSpeed(400)
    ply:SetWalkSpeed(300)
    ply:SetJumpPower(200)
end

function GM:WeaponEquip(wep, ply)
    if wep.SpawnerEntity then
        wep.SpawnerEntity:CollectWeapon(ply)
    end
end

function GM:PlayerCanPickupWeapon(ply, wep)
    if ply:HasWeapon(wep:GetClass()) then
        GAMEMODE:WeaponEquip(wep, ply)
        wep:Remove()
    else
        return true
    end
end