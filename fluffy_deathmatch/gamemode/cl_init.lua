include('shared.lua')

function GM:PlayerLoadout(ply)
    ply:StripWeapons()
    ply:StripAmmo()

    ply:Give('weapon_mg_knife')

    ply:SetRunSpeed(300)
    ply:SetWalkSpeed(200)
    ply:SetJumpPower(160)
end