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

-- Return false if multiple players are alive
-- Return a single player if they are the last player alive
function GM:GetLastPlayer(exclude_player)
    local last_alive = nil
    for k,v in pairs( player.GetAll() ) do
        if v:Alive() and v:Team() == GAMEMODE.SurvivorTeam and !v.Spectating then
            if exclude_player and v == exclude_player then continue end
            print(v, exclude_player, 'alive!')
            if IsValid(last_alive) then
                return false
            else
                last_alive = v
            end
        end
    end
    return last_alive
end

-- Last Survivor gets a message and a stat bonus
hook.Add('DoPlayerDeath', 'AwardLastSurvivor', function(ply)
    if not GAMEMODE.TeamSurvival then return end
    if GAMEMODE.DisableLoneSurvivor then return end
    
    if ply:Team() != GAMEMODE.SurvivorTeam then return end
    local last_player = GAMEMODE:GetLastPlayer(ply)
    if IsValid(last_player) and last_player != false then
        -- Award the last survivor bonus
        local name = string.sub(last_player:Nick(), 1, 10)
        GAMEMODE:PulseAnnouncement(4, name .. ' is the lone survivor!', 0.8)
        last_player:AddStatPoints('LastSurvivor', 1)
    end
end)