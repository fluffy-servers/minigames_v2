AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')
include('ply_extension.lua')

-- Players get the punch weapon by default
function GM:PlayerLoadout(ply)
    ply:SetCarrier(false)
    ply:Give('bt_punch')
end

-- Get a table of all alive players
function GM:GetAlivePlayers()
    local tbl = {}
    for k,v in pairs(player.GetAll() ) do
        if v:Alive() and v:Team() != TEAM_SPECTATOR and !v.Spectating then table.insert(tbl, v) end
    end
    
    return tbl
end

-- Timing based on active players
function GM:GetNewBombTime()
    local amount = player.GetCount()
    if amount < 4 then
        return math.random(16, 30)
    elseif amount < 8 then
        return math.random(12, 20)
    else
        return math.random(10, 15)
    end
end

-- Select a bomber at random
function GM:PickBomber()
	for k,v in pairs( player.GetAll() ) do 
		v:SetCarrier( false )
        v:StripWeapon('bt_bomb')
	end
    
    if #GAMEMODE:GetAlivePlayers() < 2 then return end
	
	-- Give the bomb & set the time randomly
	local newply = table.Random( GAMEMODE:GetAlivePlayers() )
	newply:SetCarrier( true )
	newply:SetTime(GAMEMODE:GetNewBombTime())
	newply:StripWeapons()
	newply:Give('bt_bomb')
end

-- Pick a new bomb carrier if the current one dies :(
hook.Add('DoPlayerDeath', 'CheckBomb', function(ply)
    if ply:IsCarrier() then
        timer.Simple(1, function() GAMEMODE:PickBomber() end)
    end
end )

-- Pick a new bomb carrier at round start
hook.Add('RoundStart', 'PickUnluckyStart', function()
    GAMEMODE:PickBomber()
end )

-- Remove any bombs still around when the timer runs out
hook.Add('RoundEnd', 'RemoveSpareBombs', function()
	for k,v in pairs(player.GetAll()) do
		v:StripWeapons()
	end
end )

-- Check disconnected players for bombs
-- This should help ensure there is always a bomb in play
hook.Add('PlayerDisconnected', 'DisconnectBombCheck', function(ply)
    if ply:IsCarrier() then
        timer.Simple(1, function() GAMEMODE:PickBomber() end)
        ply:KillSilent()
    end
end)

-- Track survived rounds
function GM:StatsRoundWin(winners)
    for k,v in pairs(player.GetAll()) do
        if v:Alive() and !v.Spectating then
            GAMEMODE:AddStatPoints(v, 'survived_rounds', 1)
        end
    end
end

function GM:DoPlayerDeath( ply, attacker, dmginfo )
    -- Always make the ragdoll
    ply:CreateRagdoll()
    
    -- Do not count deaths unless in round
    if GetGlobalString( 'RoundState' ) != 'InRound' then return end
    ply:AddDeaths(1)
    GAMEMODE:AddStatPoints(ply, 'deaths', 1)
    
    -- Every living players earns a point
    for k,v in pairs(player.GetAll()) do
        if !v:Alive() or v == ply or v.Spectating then continue end
        v:AddFrags(1)
        GAMEMODE:AddStatPoints(v, 'bombtag_score', 1)
    end
end