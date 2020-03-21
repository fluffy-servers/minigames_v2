--[[
	This gamemode is significantly more complicated than the other gamemodes
	This is due to the nature of having smaller 'modifiers' in the gamemode
	Don't be scared! A lot of this code is just repeated from the base gamemode
	with slight modifications to call the microgame hooks
]]--

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')
include('sv_markers.lua')
include('sv_modifiers.lua')

GM.ForceNextModifier = CreateConVar("microgames_force_modifier", "")

-- Reset the map before the round starts
function GM:PreStartRound()
    local round = GetGlobalInt('RoundNumber', 0 )
    
    -- Reset stuff
    game.CleanUpMap()
    
    -- Check that we're not running over time
    local gametime = GetGlobalFloat('GameStartTime', -1)
    if gametime > -1 and gametime + GAMEMODE.GameTime < CurTime() then
        GAMEMODE:EndGame()
        return
    end
    
    -- Set global round data
    SetGlobalInt('RoundNumber', round + 1 )
    SetGlobalString( 'RoundState', 'PreRound' )
	SetGlobalFloat( 'RoundStart', CurTime() )
    hook.Call('PreRoundStart')
    
    -- Respawn the dead
    for k,v in pairs(player.GetAll()) do
        if v.Spectating and v:Team() != TEAM_SPECTATOR then
            v.Spectating = false
            v:UnSpectate()
            v:KillSilent()
        end
        v.RoundScore = 0
        
        if v:Team() == TEAM_SPECTATOR then return end
        if not v:Alive() then v:Spawn() end
        v:AddStatPoints('Rounds Played', 1)
    end
    
    -- Start the round after a short cooldown
    timer.Simple(GAMEMODE.RoundCooldown, function() GAMEMODE:StartRound() end )
end

-- Pick a new modifier each round
function GM:StartRound()
    -- Pick new modifier
    GAMEMODE:NewModifier()
    
    -- Set global round data
	SetGlobalString( 'RoundState', 'InRound' )
	SetGlobalFloat( 'RoundStart', CurTime() )
    
    -- yay hooks
    hook.Call('RoundStart')
    
    local roundtime = GAMEMODE.CurrentModifier.RoundTime or GAMEMODE.RoundTime
    
    -- End the round after a certain time
    -- Does not apply to endless round types
    timer.Create('GamemodeTimer', roundtime, 0, function()
        GAMEMODE:EndRound('TimeEnd')
    end )
end

-- End a round and check subgame functionality
function GM:EndRound(reason)
    -- Check that we're in a round
    if GetGlobalString('RoundState') != 'InRound' then return end
    -- Stop the timer
    timer.Remove('GamemodeTimer')

    GAMEMODE:TeardownModifier(GAMEMODE.CurrentModifier)

    local winners = nil
    local msg = "The round has ended!"
    winners, msg = GAMEMODE:HandleEndRound(reason)
    
    -- Send the result to the players
    if type(winners) == 'Player' then
        net.Start('EndRound')
            net.WriteString(msg)
            net.WriteString('')
        net.Broadcast()
    end
    
    -- STATS: Add round wins
    GAMEMODE:StatsRoundWin(winners)
            
    -- Move to next round
    SetGlobalString('RoundState', 'EndRound')
    hook.Call('RoundEnd')
    
    -- No cooldown in this gamemode
    timer.Simple(GAMEMODE.RoundCooldown, function() GAMEMODE:PreStartRound() end)
end

-- Load up a new modifier
function GM:NewModifier()
    local force = GAMEMODE.ForceNextModifier:GetString()
    if GAMEMODE.Modifiers[force] then
        GAMEMODE.CurrentModifier = GAMEMODE.Modifiers[force]
    else
        GAMEMODE.CurrentModifier = table.Random(GAMEMODE.Modifiers)
    end

    GAMEMODE:SetupModifier(GAMEMODE.CurrentModifier)
end

--Handles victory conditions for Free for All based gamemodes
function GM:HandleFFAWin(reason)
    local winner = nil -- Default: everyone sucks
    local msg = 'The round has ended!'
    
    -- If the time ran out, get the player with the most frags
    -- Otherwise, the reason is likely the winner entity
    if reason == 'TimeEnd' then
        winner = GAMEMODE:GetWinningPlayer()
    elseif IsEntity(reason) and reason:IsPlayer() then
        winner = reason
        winner:AddFrags(5)
    end
    
    if IsValid(winner) then
        msg = winner:Nick() .. ' wins the round!'
    else
        msg = 'Nobody has won the round'
    end
    return winner, msg
end

-- Basic function to get the player with the most frags
function GM:GetWinningPlayer()
    -- Doesn't really make sense in Team gamemodes
    -- if GAMEMODE.TeamBased then return nil end
    
    -- Check again that there isn't just one player alive
    -- Useful for survival gamemodes
    if GAMEMODE:GetNumberAlive() <= 1 then
        for k,v in pairs( player.GetAll() ) do
            if v:Alive() and not v.Spectating then
                return v
            end
        end
    end
    
    -- Loop through all players and return the one with the most frags
    local bestscore = 0
    local bestplayer = nil
    for k,v in pairs( player.GetAll() ) do
        local frags = v.RoundScore or 0
        if frags > bestscore then
            bestscore = frags
            bestplayer = v
        end
    end
    
    -- Return the winner! Yay!
    return bestplayer
end

-- Helper function to relay announcements
function GM:Announce(title, subtext)
    if subtext then
        GAMEMODE:PulseAnnouncementTwoLine(3, title, subtext)
    else
        GAMEMODE:PulseAnnouncement(3, title, subtext)
    end
end