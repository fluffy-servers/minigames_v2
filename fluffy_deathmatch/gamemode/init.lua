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

function GM:GiveAmmo(wep, ply)
    local ammo_table = GAMEMODE.WeaponSpawners["ammo"]
    if ammo_table[wep:GetClass()] then
        local ammo = ammo_table[wep:GetClass()]
        ply:GiveAmmo(ammo[2], ammo[1])
    end
end

function GM:PlayerCanPickupWeapon(ply, wep)
    if ply:HasWeapon(wep:GetClass()) then
        GAMEMODE:WeaponEquip(wep, ply)
        wep:Remove()

        GAMEMODE:GiveAmmo(wep, ply)
    else
        return true
    end
end