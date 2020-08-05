--[[
    Main logic for the rounds system
    Useful hooks to know:
        - PreRoundStart
        - RoundStart
        - RoundEnd
    Please don't override the functions unless absolutely critical
    Some functions regarding winning conditions are designed to be overridden
--]]

-- Thinking for round coordination
-- Usually check for round start and end conditions
hook.Add('Think', 'MinigamesRoundThink', function()
    -- Check if the game is ready to start
    if GAMEMODE:GetRoundState() == 'GameNotStarted' then
        if GAMEMODE:CanRoundStart() then
            -- Transition into a warmup period before all goes well
            GAMEMODE:SetRoundState('Warmup')
            SetGlobalFloat('WarmupTime', CurTime())
            timer.Simple(GAMEMODE.WarmupTime, function() GAMEMODE:StartGame() end)
        end
    elseif GAMEMODE:InRound() then
        -- Delegate this to each gamemode (defaults are provided lower down for reference)
        GAMEMODE:CheckRoundEnd()
    end
end)

-- Waiting cooldown period has now ended, start the game proper
function GM:StartGame()
    if not GAMEMODE:CanRoundStart() then
        -- Uh oh, something went wrong in the cooldown period
        GAMEMODE:SetRoundState('GameNotStarted')
        return
    end

    -- Store the starting time of the game for TIMED gamemodes
    -- Timed gamemodes don't have a fixed number of rounds
    if GAMEMODE.RoundType == 'timed' or GAMEMODE.RoundType == 'timed_endless' then
        SetGlobalFloat('GameStartTime', CurTime())
    end
    GAMEMODE:PreStartRound()
end

-- Check if there enough players to start a round
function GM:CanRoundStart()
    -- If team based, check there is at least player on each team
    -- (Override this function if there is ever a four-team gamemode)
    -- (Hopefully there won't be but that'll be pretty cool)
    if GAMEMODE.TeamBased and !GAMEMODE.TeamSurvival then
        if #team.GetPlayers(1) >= 1 and #team.GetPlayers(2) >= 1 then
            return true
        else
            return false
        end
    -- If FFA, check there's at least two people not spectating
    else
        if GAMEMODE:NumNonSpectators() >= GAMEMODE.MinPlayers then
            return true
        else
            return false
        end
    end
end

-- Called just before the round starts
-- Cleans up the map and resets round data
function GM:PreStartRound()
    local round = GetGlobalInt('RoundNumber', 0)
    
    -- Make sure we have enough players to start the next round
    if not GAMEMODE:CanRoundStart() then
        SetGlobalString('RoundState', 'GameNotStarted')
        return
    end
    
    -- Reset stuff
    game.CleanUpMap()
    hook.Call('PostCleanup')
    
    -- End the game if needed
    -- Different gamemode round types have different logic
    if GAMEMODE.RoundType == 'default' then
        -- End the game once all the rounds have been played
        if round >= GAMEMODE.RoundNumber then
            GAMEMODE:EndGame()
            return
        end
    elseif GAMEMODE.RoundType == 'timed' then
        -- End the game if the game has exceeded the time limit
        local gametime = GetGlobalFloat('GameStartTime', -1)
        if gametime > -1 and gametime + GAMEMODE.GameTime < CurTime() then
            GAMEMODE:EndGame()
            return
        end
    elseif GAMEMODE.RoundType == 'timed_endless' then
        -- This gamemode should only have one round
        -- Timing is handled in the Think hook - see below
        if round >= 1 then
            GAMEMODE:EndGame()
            return
        end
    end

    if GAMEMODE.TeamBased then
        team.SetRoundScore(1, 0)
        team.SetRoundScore(2, 0)
    end
    
    -- Set global round data
    SetGlobalInt('RoundNumber', round + 1)
    SetGlobalString('RoundState', 'PreRound')
	SetGlobalFloat('RoundStart', CurTime())
    hook.Call('PreRoundStart')
    
    -- Respawn everybody & freeze them until the round actually starts
    -- This has a timer to allow for any map entity editing to take place
    timer.Simple(FrameTime(), function()
        for k,v in pairs(player.GetAll()) do
            -- Reset FFA kill tracking
            if !GAMEMODE.TeamBased then 
                if v:Team() != TEAM_SPECTATOR then v:SetTeam(TEAM_UNASSIGNED) end
                v:SetNWInt("RoundKills", 0)
                v.FFAKills = 0
            end
            
            -- Respawn non-spectators
            if v:Team() != TEAM_SPECTATOR then
                v:Spawn()
                v:Freeze(true)
            end

            -- Add round points to anyone that isn't spectating
            if (not GAMEMODE.TeamBased and v:Team() != TEAM_SPECTATOR) or (GAMEMODE.TeamBased and v:Team() != TEAM_UNASSIGNED and v:Team() != TEAM_SPECTATOR) then
                v:AddStatPoints('Rounds Played', 1)
            end
        end
    end)
    
    -- Start the round after a short cooldown
    timer.Simple(GAMEMODE.RoundCooldown, function() GAMEMODE:StartRound() end)
end

-- Start a round
function GM:StartRound()
    -- Unfreeze all players
    for k,v in pairs(player.GetAll()) do
        v:Freeze(false)
    end
    
    -- Set global round data
	SetGlobalString('RoundState', 'InRound')
	SetGlobalFloat('RoundStart', CurTime())
    
    -- yay hooks
    hook.Call('RoundStart')
    
    -- End the round after a certain time
    -- Does not apply to endless round types
    if GAMEMODE.RoundType != 'timed_endless' and GAMEMODE.RoundTime > 0 then
        timer.Create('GamemodeTimer', GAMEMODE.RoundTime, 0, function()
            GAMEMODE:EndRound('TimeEnd')
        end)
    end
end

-- End the round
function GM:EndRound(reason, extra)
    -- Check that we're in a round
    if not GAMEMODE:InRound() then return end
    -- Stop the timer
    timer.Remove('GamemodeTimer')
    
    -- The end of each round is honestly the painful part
    -- Delegate this to each gamemode (defaults are provided lower down for reference)
    local winners = nil
    local msg = "The round has ended!"
    local extra = nil
    winners, msg, extra = GAMEMODE:HandleEndRound(reason)
    
    -- Send the result to the players
    net.Start('EndRound')
        net.WriteString(msg)
        net.WriteString(extra or '')
    net.Broadcast()
    
    -- STATS: Add round wins
    GAMEMODE:StatsRoundWin(winners)
    
    -- Apply confetti effect
    GAMEMODE:ConfettiEffect(winners)
    
    -- Move to next round
    hook.Call('RoundEnd')
    SetGlobalString('RoundState', 'EndRound')
    timer.Simple(GAMEMODE.RoundCooldown, function() GAMEMODE:PreStartRound() end)
end

-- End the game
-- This occurs at the end of a map
function GM:EndGame()
    -- Open the end screen on clients
    net.Start('MinigamesGameEnd')
    net.Broadcast()
    
    for k,v in pairs(player.GetAll()) do
        v:Freeze(true)
    end
    
    -- Start the mapvote process
    GAMEMODE:StartVoting()
end

-- Make sure that Timed gamemodes end at the right time
hook.Add('Think', 'TimedGamemodeThink', function()
    if GAMEMODE.RoundType == 'default' then return end
    
    if GAMEMODE.RoundType == 'timed' and GAMEMODE.EndOnTimeOut then
        -- End the gamemode if EndOnTimeOut is enabled
        -- This does not have a countdown announcement - possible future addition?
        local gametime = GetGlobalFloat('GameStartTime', -1)
        if gametime > -1 and gametime + GAMEMODE.GameTime < CurTime() then
            GAMEMODE:EndRound('TimeEnd')
        end
    elseif GAMEMODE.RoundType == 'timed_endless' then
        -- End the gamemode if the time has been exceeded
        -- This also has a 5-second countdown announcement
        local gametime = GetGlobalFloat('GameStartTime', -1)
        if gametime > -1 and gametime + GAMEMODE.GameTime < CurTime() then
            GAMEMODE:EndRound('TimeEnd')
        elseif gametime > -1 and gametime + GAMEMODE.GameTime - 5 < CurTime() and not GAMEMODE.CountdownStarted then
            GAMEMODE.CountdownStarted = true
            GAMEMODE:CountdownAnnouncement(5, nil, "center")
        end
    end
end)

-- STATS: Give round win points
function GM:StatsRoundWin(winners)
    if IsEntity(winners) then
        if winners:IsPlayer() then
            winners:AddStatPoints('Rounds Won', 1)
        end
    elseif type(winners) == 'number' then
        if winners > 0 then
            for k,v in pairs(team.GetPlayers(winners)) do
                v:AddStatPoints('Rounds Won', 1)
            end
        end
    elseif type(winners) == 'table' then
        for k,v in pairs(winners) do
            if not IsEntity(v) then continue end
            if not v:IsPlayer() then continue end
            v:AddStatPoints('Rounds Won', 1)
        end
    end
end

--[[
    Example (basic) round end handlers
]]--

-- Handles victory conditions for team based gamemodes
function GM:HandleTeamWin(reason)
    local winners = reason -- Default: set to winning team in certain gamemodes
    local msg = 'The round has ended!'
    local extra = nil
    
    if reason == 'TimeEnd' then
        --If team survival, surviving team wins, otherwise determine which team has more kills
        if GAMEMODE.TeamSurvival then
            winners = GAMEMODE.SurvivorTeam
            msg = team.GetName(GAMEMODE.SurvivorTeam) .. ' win the round!'
        elseif team.GetRoundScore(2) < team.GetRoundScore(1) then
            winners = 1
            msg = team.GetName(1) .. ' win the round!'
        elseif team.GetRoundScore(2) > team.GetRoundScore(1) then
            winners = 2
            msg = team.GetName(2) .. ' win the round!'
        else
            winners = 0
            msg = 'Draw! Both teams are tied!'
        end
    elseif GAMEMODE.TeamSurvival then
        winners = GAMEMODE.HunterTeam
        msg = team.GetName(GAMEMODE.HunterTeam) .. ' win the round!'    
        if GAMEMODE.LastSurvivor then
            extra = string.sub(GAMEMODE.LastSurvivor:Nick(), 1, 10) .. ' was the last survivor'
        end
    end
    
    if msg == 'The round has ended!' and type(winners) == 'number' then
        msg = team.GetName(winners) .. ' win the round!'
    elseif msg == 'The round has ended!' and type(winners) == 'Player' then
        msg = winners:Nick() .. ' wins the round!'
    end
    
    if winners and winners > 0 then team.AddScore(winners, 1) end
    return winners, msg, extra
end

-- Handles victory conditions for Free for All based gamemodes
function GM:HandleFFAWin(reason)
    local winner = nil -- Default: everyone sucks
    local msg = 'The round has ended!'
    
    -- If the time ran out, get the player with the most frags
    -- Otherwise, the reason is likely the winner entity
    if reason == 'TimeEnd' then
        winner = GAMEMODE:GetWinningPlayer()
    elseif IsEntity(reason) and reason:IsPlayer() then
        winner = reason
    end
    
    if IsValid(winner) then
        msg = winner:Nick() .. ' wins the round!'
    else
        msg = 'Nobody has won the round'
    end
    return winner, msg
end

-- Handles FFA Elimination
function GM:CheckFFAElimination()
    if GAMEMODE.WinBySurvival then
        if GAMEMODE:GetNumberAlive() <= 1 then
            for k,v in pairs(player.GetAll()) do
                if v:Alive() and !v.Spectating then
                    GAMEMODE:EndRound(v)
                    return
                end
            end
            GAMEMODE:EndRound(nil)
        end
    elseif GAMEMODE.Elimination then
        if GAMEMODE:GetNumberAlive() == 0 then
            GAMEMODE:EndRound(nil)
        end
    end
end

-- Handles Team Elimination
function GM:CheckTeamElimination()
    if GAMEMODE.Elimination then
        if GAMEMODE:GetTeamLivingPlayers(1) == 0 then
            GAMEMODE:EndRound(2)
        elseif GAMEMODE:GetTeamLivingPlayers(2) == 0 then
            GAMEMODE:EndRound(1)
        end
    end
    
    if GAMEMODE.TeamSurvival then
        if GAMEMODE:GetTeamLivingPlayers(GAMEMODE.SurvivorTeam) == 0 then
            GAMEMODE:EndRound(GAMEMODE.HunterTeam)
        end
    end
end

-- Default functions for round stuff
function GM:CheckRoundEnd()
    if GAMEMODE.TeamBased then
        return GAMEMODE:CheckTeamElimination()
    else
        return GAMEMODE:CheckFFAElimination()
    end
end

function GM:HandleEndRound(reason)
    if GAMEMODE.TeamBased then
        return GAMEMODE:HandleTeamWin(reason)
    else
        return GAMEMODE:HandleFFAWin(reason)
    end
end
