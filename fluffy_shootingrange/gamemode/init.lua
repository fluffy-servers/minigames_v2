AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

hook.Add('PreRoundStart', 'SwapTeams', function()
for k,v in pairs(player.GetAll()) do
    if v:Team() == TEAM_RED then
        v:SetTeam(TEAM_BLUE)
    elseif v:Team() == TEAM_BLUE then
        v:SetTeam(TEAM_RED)
    end
end
local blue_score = team.GetScore(TEAM_BLUE)
local red_score = team.GetScore(TEAM_RED)
team.SetScore(TEAM_BLUE, red_score)
team.SetScore(TEAM_RED, blue_score)
end)
function GM:PlayerLoadout( ply )
    if ply:Team() == TEAM_BLUE then
        ply:StripWeapons()
        ply:SetWalkSpeed( 350 )
        ply:SetRunSpeed( 450 )
    elseif ply:Team() == TEAM_RED then
        ply:Give('weapon_crossbow')
		ply:GiveAmmo(200, "XBowBolt")
        ply:SetWalkSpeed( 250 )
        ply:SetRunSpeed( 325 )
    end
end
