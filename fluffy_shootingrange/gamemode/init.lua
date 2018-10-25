AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function GM:PlayerLoadout( ply )
    if ply:Team() == TEAM_BLUE then
        ply:StripWeapons()
        ply:SetWalkSpeed( 375 )
        ply:SetRunSpeed( 425 )
    elseif ply:Team() == TEAM_RED then
        ply:Give('weapon_crossbow')
		ply:GiveAmmo(200, "XBowBolt")
        ply:SetWalkSpeed( 375 )
        ply:SetRunSpeed( 425 )
    end
end
