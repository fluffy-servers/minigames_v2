--[[
    Useful functions that are used for TeamSurvival gamemodes
--]]

-- Make new players join the Hunter team on connection
function GM:PlayerInitialSpawn(ply)
    if GAMEMODE.TeamSurvival and GAMEMODE.HunterTeam then
        ply:SetTeam( GAMEMODE.HunterTeam )
    end
end

-- If team survival pick one player to be a hunter
hook.Add('PreRoundStart', 'SurvivalPickHunter', function()
    if GAMEMODE.TeamSurvival then
        for k,v in pairs( player.GetAll() ) do
            if v:Team() == TEAM_SPECTATOR then continue end
            v:SetTeam( GAMEMODE.SurvivorTeam )
        end
        GAMEMODE:GetRandomPlayer():SetTeam( GAMEMODE.HunterTeam )
    end
end )

-- Assign dead survivors to the hunter team
hook.Add('PlayerDeath', 'SurvivalDeath', function(ply)
    if ply:Team() == GAMEMODE.SurvivorTeam then
        ply:SetTeam(GAMEMODE.HunterTeam)
    end
end)