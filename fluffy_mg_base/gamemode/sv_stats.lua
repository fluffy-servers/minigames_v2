--[[
    This file is used as a handy stat tracking file
    Useful for tracking kills, round wins, damage dealt, etc.
]]--

util.AddNetworkString("SendStatsReport")

GM.StatsTracking = {}

-- Add some points to a given statistic
function GM:AddStatPoints(ply, stat, amount)
    -- Create player index if not there
    if not GAMEMODE.StatsTracking[ply] then GAMEMODE.StatsTracking[ply] = {} end
    
    -- Get current value of stat
    local current = 0
    if GAMEMODE.StatsTracking[ply][stat] then current = GAMEMODE.StatsTracking[ply][stat] end
    
    -- Add the stat points
    GAMEMODE.StatsTracking[ply][stat] = current + amount
    
    -- Return new value
    return current + amount
end

-- Get a players statistic
function GM:GetStat(ply, stat)
    if not GAMEMODE.StatsTracking[ply] then return end
    if not GAMEMODE.StatsTracking[ply][stat] then return end
    
    return GAMEMODE.StatsTracking[ply][stat]
end

-- Return the players statistic table
function GM:GetPlayerStatTable(ply)
    if GAMEMODE.StatsTracking[ply] then 
        return GAMEMODE.StatsTracking[ply]
    else
        return {}
    end
end

function GM:SendStatsToClients()
    net.Start("SendStatsReport")
        net.WriteTable(GAMEMODE.StatsTracking)
    net.Broadcast()
end