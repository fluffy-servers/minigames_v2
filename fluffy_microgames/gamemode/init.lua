--[[
	This gamemode is significantly more complicated than the other gamemodes
	This is due to the nature of having smaller 'modifiers' in the gamemode
	Don't be scared! A lot of this code is just repeated from the base gamemode
	with slight modifications to call the microgame hooks
]]--

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
AddCSLuaFile('ply_extension.lua')

include('shared.lua')
include('sv_markers.lua')
include('sv_modifiers.lua')
include('sv_spawnpoints.lua')

GM.ForceNextModifier = CreateConVar("microgames_force_modifier", "")

-- Reset the map before the round starts
function GM:PreStartRound()
    local round = GetGlobalInt('RoundNumber', 0)

    -- Restore everyone back to the generic region (if applicable)
    if GAMEMODE.CurrentRegion then
        GAMEMODE.CurrentRegion = nil

        for k,v in pairs(player.GetAll()) do
            v:Spawn()
        end
    end
    
    -- Reset stuff
    game.CleanUpMap()
    
    -- Check that we're not running over time
    local gametime = GetGlobalFloat('GameStartTime', -1)
    if gametime > -1 and gametime + GAMEMODE.GameTime < CurTime() then
        GAMEMODE:EndGame()
        return
    end
    
    -- Set global round data
    SetGlobalInt('RoundNumber', round + 1)
    SetGlobalString('RoundState', 'PreRound')
	SetGlobalFloat('RoundStart', CurTime())
    hook.Call('PreRoundStart')
    
    -- Respawn the dead
    for k,v in pairs(player.GetAll()) do
        if v.Spectating and v:Team() != TEAM_SPECTATOR then
            v:EndSpectate()
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
	SetGlobalString('RoundState', 'InRound')
	SetGlobalFloat('RoundStart', CurTime())
    
    -- yay hooks
    hook.Call('RoundStart')
    
    local roundtime = GAMEMODE.CurrentModifier.RoundTime or GAMEMODE.RoundTime
    
    -- End the round after a certain time
    -- Does not apply to endless round types
    timer.Create('GamemodeTimer', roundtime, 0, function()
        GAMEMODE:EndRound('TimeEnd')
    end)
end

-- End a round and check subgame functionality
function GM:EndRound(reason)
    -- Check that we're in a round
    if not GAMEMODE:InRound() then return end
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
    -- Force modifiers if applicable
    local force = GAMEMODE.ForceNextModifier:GetString()
    if GAMEMODE.Modifiers[force] then
        GAMEMODE.CurrentModifier = GAMEMODE.Modifiers[force]
        GAMEMODE:SetupModifier(GAMEMODE.CurrentModifier)
        return
    end

    -- Setup the queue if it doesn't exist
    if not GAMEMODE.ModifierQueue then
        local keys = table.GetKeys(GAMEMODE.Modifiers)
        GAMEMODE.ModifierQueue = table.Shuffle(keys)
        GAMEMODE.ModifierIndex = 1
    end

    -- Shuffle the queue if moving too fast
    if GAMEMODE.ModifierIndex > #GAMEMODE.ModifierQueue then
        local keys = table.GetKeys(GAMEMODE.Modifiers)
        GAMEMODE.ModifierQueue = table.Shuffle(keys)
        GAMEMODE.ModifierIndex = 1
    end

    -- Play the next modifier in the queue
    local modifier_key = GAMEMODE.ModifierQueue[GAMEMODE.ModifierIndex]
    GAMEMODE.CurrentModifier = GAMEMODE.Modifiers[modifier_key]
    GAMEMODE.ModifierIndex = GAMEMODE.ModifierIndex + 1
    GAMEMODE:SetupModifier(GAMEMODE.CurrentModifier)
end

-- Handles victory conditions for Free for All based gamemodes
function GM:HandleFFAWin(reason)
    local winner = nil -- Default: everyone sucks
    local msg = 'The round has ended!'
    local modifier = GAMEMODE.CurrentModifier
    
    -- If the time ran out, get the player with the most frags
    -- Otherwise, the reason is likely the winner entity
    if reason == 'TimeEnd' then
        winner = GAMEMODE:GetWinningPlayer(modifier)
    elseif IsEntity(reason) and reason:IsPlayer() then
        winner = reason
    end
    
    -- Award bonus win points based on modifier properties
    if winner then
        if modifier.WinValue then
            winner:AddFrags(modifier.WinValue)
        elseif modifier.SurviveValue then
            winner:AddFrags(modifier.SurviveValue * 2)
        elseif modifier.KillValue then
            winner:AddFrags(modifier.KillValue * 2)
        end
    end

    if IsValid(winner) then
        msg = winner:Nick() .. ' wins the round!'
    else
        msg = 'Nobody has won the round'
    end
    return winner, msg
end

-- Handle death points
function GM:HandlePlayerDeath(ply, attacker, dmginfo) 
    if !attacker:IsValid() or !attacker:IsPlayer() then return end -- We only care about player kills from here on
    if attacker == ply then return end -- Suicides aren't important
    if !GAMEMODE:InRound() then return end
    
    -- Add the frag to scoreboard
    if GAMEMODE.CurrentModifier.KillValue then
        attacker:AddFrags(GAMEMODE.CurrentModifier.KillValue)
        GAMEMODE:AddStatPoints(attacker, 'Kills', 1)
    end
end

-- Players cannot respawn in the middle of rounds
function GM:CanRespawn(ply)
    return (GAMEMODE:GetRoundState() == 'PreRound')
end

-- Helper function to relay announcements
function GM:Announce(title, subtext)
    if subtext then
        GAMEMODE:PulseAnnouncementTwoLine(3, title, subtext, 1, 'center')
    else
        GAMEMODE:PulseAnnouncement(3, title, 1, 'center')
    end
end