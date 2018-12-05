AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')
include('sv_modifiers.lua')

-- Remove fall damage
function GM:GetFallDamage( ply, speed )
    return 0
end

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
    
    -- End any properties from the last gamemode modifier
    GAMEMODE:EndModifier()
    
    -- Start the round after a short cooldown
    timer.Simple(2, function() GAMEMODE:StartRound() end )
end

function GM:StartRound()
    -- Pick new modifier
    GAMEMODE:NewModifier()
    
    -- Set global round data
	SetGlobalString( 'RoundState', 'InRound' )
	SetGlobalFloat( 'RoundStart', CurTime() )
    
    -- yay hooks
    hook.Call('RoundStart')
    
    -- End the round after a certain time
    -- Does not apply to endless round types
    timer.Create('GamemodeTimer', GAMEMODE.RoundTime, 0, function()
        GAMEMODE:EndRound('TimeEnd')
    end )
end

function GM:EndRound(reason)
    -- Check that we're in a round
    if GetGlobalString('RoundState') != 'InRound' then return end
    -- Stop the timer
    timer.Remove('GamemodeTimer')
    
    -- The end of each round is honestly the painful part
    -- Delegate this to each gamemode (defaults are provided lower down for reference)
    local winners = nil
    local msg = "The round has ended!"
    
    -- Send the result to the players
    net.Start('EndRound')
        net.WriteString( msg )
        net.WriteString('')
    net.Broadcast()
    
    -- STATS: Add round wins
    GAMEMODE:StatsRoundWin(winners)
            
    -- Move to next round
    SetGlobalString( 'RoundState', 'EndRound' )
    hook.Call('RoundEnd')
    
    -- No cooldown in this gamemode
    timer.Simple(2, function() GAMEMODE:PreStartRound() end)
end

function GM:EndModifier()
    for k,v in pairs(player.GetAll()) do
        if v.Spectating and v:Team() != TEAM_SPECTATOR then
            v.Spectating = false
            v:UnSpectate()
            v:KillSilent()
        end
        if v:Team() == TEAM_SPECTATOR then return end
        
        if not v:Alive() then v:Spawn() end
        v:AddStatPoints('RoundsPlayed', 1)
        
        v.RoundKills = 0
        v:StripWeapons()
        v:StripAmmo()
        v:SetRunSpeed(300)
        v:SetWalkSpeed(200)
        v:SetMoveType(2)
        v:SetHealth(100)
        v:SetMaxHealth(100)
        hook.Call('PlayerSetModel', GAMEMODE, v)
    end
end

function GM:NewModifier()
    -- Make sure the same modifier doesn't come up twice
    if not GAMEMODE.CurrentModifier then GAMEMODE.CurrentModifier = table.Random(GAMEMODE.Modifiers) end
    local modifier = GAMEMODE.CurrentModifier
    while modifier == GAMEMODE.CurrentModifier do
        modifier = table.Random(GAMEMODE.Modifiers)
    end
    GAMEMODE.CurrentModifier = modifier
        
    if modifier.func_init then
        modifier.func_init()
    end
    
    if modifier.func_player then
        for k,v in pairs(player.GetAll()) do
            modifier.func_player(v)
        end
    end
    
    GAMEMODE:PulseAnnouncementTwoLine(3, modifier.name, modifier.subtext)
end