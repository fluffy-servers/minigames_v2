function GM:PlayerRequestTeam(ply, teamid)
    -- If players are spectating, they can change to Unassigned (and vice versa)
    -- This only applies in some cases where general team switching won't fly
    if (ply:Team() == TEAM_SPECTATOR and teamid == TEAM_UNASSIGNED) or (ply:Team() == TEAM_UNASSIGNED and teamid == TEAM_SPECTATOR) then
        if not GAMEMODE.TeamBased or GAMEMODE.TeamSurvival or (not GAMEMODE.PlayerChooseTeams) then
            if not hook.Run('PlayerCanJoinTeam', ply, teamid) then return end -- still follow these rules
            GAMEMODE:PlayerJoinTeam(ply, teamid)
        end
    end

    -- No team swapping in FFA gamemodes (except the above case)
    if not GAMEMODE.TeamBased then return end

    -- Stop players joining weird teams (eg. Unassigned in team gamemodes)
	if not team.Joinable(teamid) then
		ply:ChatPrint("You can't join that team")
        return 
    end
    
    -- Stop players changing teams in certain gamemodes
    if not GAMEMODE.PlayerChooseTeams then
        ply:ChatPrint("You can't change teams in this gamemode!")
    end
        
	-- Run the can join hook
	if not hook.Run('PlayerCanJoinTeam', ply, teamid) then return end
	GAMEMODE:PlayerJoinTeam(ply, teamid)
end

function GM:PlayerCanJoinTeam(ply, teamid)
    -- Stop rejoining same team
    if ply:Team() == teamid then
        return false
    end

    -- Team swap as frequently as required before game start
    if GAMEMODE:GetRoundState() == 'GameNotStarted' or GAMEMODE:GetRoundState() == 'Warmup' then
        ply.LastTeamSwitch = RealTime()
        return true
    end

    -- Stop from frequently changing teams in game
    if ply.LastTeamSwitch and RealTime() - ply.LastTeamSwitch < 10 then
        ply:ChatPrint('Please wait before changing teams')
        return false
    else
        ply.LastTeamSwitch = RealTime()
        return true
    end
end

function GM:OnPlayerChangedTeam(ply, old, new)
    -- Spectators respawn in place
    if new == TEAM_SPECTATOR then
        local pos = ply:EyePos()
        ply:Spawn()
        ply:SetPos(pos)
    end

    PrintMessage(HUD_PRINTTALK, Format("%s joined '%s'", ply:Nick(), team.GetName(new)))
end

-- Useful function to swap the current teams
function GM:SwapTeams(respawn, swapscores)
    local red_players = team.GetPlayers(TEAM_RED)
    local blue_players = team.GetPlayers(TEAM_BLUE)
    local respawn = respawn or true
    
    -- Move red players to blue
    for k,v in pairs(red_players) do 
        v:SetTeam(TEAM_BLUE)
        if respawn then v:Spawn() end
    end
    
    -- Move blue players to red
    for k,v in pairs(blue_players) do 
        v:SetTeam(TEAM_RED)
        if respawn then v:Spawn() end
    end

    -- Swap scores if applicable
    if swapscores then
        local old_red_score = team.GetScore(TEAM_RED)
        local old_blue_score = team.GetScore(TEAM_BLUE)
        team.SetScore(TEAM_RED, old_blue_score)
        team.SetScore(TEAM_BLUE, old_red_score)
    end
end

-- Useful function to scramble the teams nicely
-- This is good for rebalancing if things go really badly
function GM:ShuffleTeams(respawn)
    -- Figure out what players are eligible for team swaps
    local respawn = respawn or true
    local players = {}
    local num = 0
    for k,v in pairs(player.GetAll()) do
        if v:Team() != TEAM_SPECTATOR and v:Team() != TEAM_UNASSIGNED and v:Team() != 0 then 
            num = num + 1
            table.insert(players, v)
        end
    end
    
    -- Reassign the teams
    players = table.Shuffle(players)
    for i = 1,num do
        if i%2 == 0 then 
            players[i]:SetTeam(TEAM_RED) 
        else 
            players[i]:SetTeam(TEAM_BLUE) 
        end
        
        if respawn then players[i]:Spawn() end
    end
end