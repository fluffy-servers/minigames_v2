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
GAMEMODE.RoundType = ( math.random( 1, 3 ) )
local blue_score = team.GetScore(TEAM_BLUE)
local red_score = team.GetScore(TEAM_RED)
team.SetScore(TEAM_BLUE, red_score)
team.SetScore(TEAM_RED, blue_score)
end)
hook.Add( "OnDamagedByExplosion", "DisableSound", function()
    return true
end )
function GM:PlayerLoadout( ply )
    if GAMEMODE.RoundType == 1 then
		if ply:Team() == TEAM_BLUE then
			ply:StripWeapons()
			ply:SetWalkSpeed( 250 )
			ply:SetRunSpeed( 350 )
			ply:SetHealth( 200 )
		elseif ply:Team() == TEAM_RED then
			ply:Give('weapon_crossbow')
			ply:GiveAmmo(200, "XBowBolt")
			ply:SetWalkSpeed( 250 )
			ply:SetRunSpeed( 325 )
			ply:SetHealth( 100 )
		end
	elseif GAMEMODE.RoundType == 2 then
		if ply:Team() == TEAM_BLUE then
			ply:StripWeapons()
			ply:SetWalkSpeed( 350 )
			ply:SetRunSpeed( 525 )
			ply:SetHealth( 600 )
		elseif ply:Team() == TEAM_RED then
			ply:Give('weapon_rpg')
			ply:GiveAmmo(200, "RPG_Round")
			ply:SetWalkSpeed( 250 )
			ply:SetRunSpeed( 500 )
			ply:SetHealth( 100 )
		end
	elseif GAMEMODE.RoundType == 3 then
    	if ply:Team() == TEAM_BLUE then
			ply:StripWeapons()
			ply:SetWalkSpeed( 250 )
			ply:SetRunSpeed( 350 )
			ply:SetHealth( 200 )
		elseif ply:Team() == TEAM_RED then
			ply:Give('weapon_ar2')
			ply:GiveAmmo(200, "AR2AltFire")
			ply:SetWalkSpeed( 250 )
			ply:SetRunSpeed( 325 )
			ply:SetHealth( 100 )
		end
    end
end
