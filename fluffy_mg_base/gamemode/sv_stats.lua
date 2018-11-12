--[[
    This file is used as a handy stat tracking file
    Useful for tracking kills, round wins, damage dealt, etc.
]]--
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

-- Get the player with the highest score in a certain stat
function GM:GetStatWinner(stat)
    local highest_score = 0
    local winning_player = nil
    for k,v in pairs(GAMEMODE.StatsTracking) do
        if not v[stat] then continue end
        
        if v[stat] > highest_score then
            highest_score = v[stat]
            winning_player = k
        end
    end
    
    return {winning_player, highest_score}
end

local meta = FindMetaTable("Player")
function meta:GetStat(stat)
    return GAMEMODE:GetStat(self, stat)
end

function meta:GetStatTable()
    return GAMEMODE:GetPlayerStatTable(self)
end

function meta:AddStatPoints(stat, amount)
    return GAMEMODE:AddStatPoints(self, stat, amount)
end