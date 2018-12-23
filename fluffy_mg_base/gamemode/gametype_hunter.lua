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
        local num_players = 0
        for k,v in pairs( player.GetAll() ) do
            if v:Team() == TEAM_SPECTATOR then continue end
            v:SetTeam( GAMEMODE.SurvivorTeam )
            num_players = num_players + 1
            v.InitialHunter = false
            v.Spectating = false
        end
        
        -- Make 20% of players (+1) hunters
        local num_hunters = math.floor((num_players-1)/5) + 1
        for k,v in pairs(GAMEMODE:GetRandomPlayer(num_hunters, true)) do
            v:SetTeam(GAMEMODE.HunterTeam)
            v.InitialHunter = true
        end
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

-- Disable cosmetics
hook.Add('ShouldDrawCosmetics', 'HideHunterCosmetics', function(ply, ITEM)
    if GAMEMODE.TeamSurvival then
        -- Cosmetics shouldn't show for the Hunter Team (in most cases)
        -- Override in some cases
        if ply:Team() == GAMEMODE.HunterTeam then
            return false
        else
            return true
        end
    end
end)